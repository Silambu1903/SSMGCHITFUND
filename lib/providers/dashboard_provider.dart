import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/auction_model.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';
import '../core/utils/date_formatter.dart';
import 'chit_provider.dart';
import 'auction_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(),
);

final dashboardMetricsProvider =
    FutureProvider.family<DashboardMetrics, String?>((ref, branchId) async {
  return ref.read(dashboardRepositoryProvider).getMetrics(branchId: branchId);
});

final recentPaymentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(dashboardRepositoryProvider).getRecentPayments(limit: 10);
});

final defaulterSummaryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(dashboardRepositoryProvider).getDefaulterSummary(limit: 10);
});

final upcomingAuctionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref
      .read(dashboardRepositoryProvider)
      .getUpcomingAuctions(limit: 5);
});

bool _isCurrentMonth(String auctionDate, DateTime now) {
  final d = DateFormatter.fromApi(auctionDate);
  if (d == null) return false;
  return d.year == now.year && d.month == now.month;
}

int? _auctionDayFor(AuctionModel auction, Map<String, int> chitDays) {
  return auction.auctionDay ?? chitDays[auction.chitId];
}

/// Refreshes shared data used by the dashboard (call after saving auctions/payments).
void refreshDashboardData(WidgetRef ref, {String? chitId}) {
  ref.invalidate(auctionsProvider(null));
  if (chitId != null) ref.invalidate(auctionsProvider(chitId));
  ref.invalidate(chitsProvider(null));
  ref.invalidate(dashboardMetricsProvider(null));
  ref.invalidate(recentPaymentsProvider);
  ref.invalidate(defaulterSummaryProvider);
  ref.invalidate(upcomingAuctionsProvider);
  ref.invalidate(monthlyGroupProvider(10));
  ref.invalidate(monthlyGroupProvider(20));
  ref.invalidate(thisMonthWinnersProvider);
}

// ── Monthly Group Summary (per auction day) ──────────────────────────────────

class MonthlyGroupSummary {
  final int auctionDay;
  final int activeChits;
  /// Sum of chit_value for all active chits on this day — total prize pool this month
  final double totalChitValue;
  /// Total money members owe you this month (sum of monthly_installment per chit)
  final double totalExpectedCollection;
  /// Sum of winner prize amounts from this month's auctions (winning member only)
  final double totalPrizeToSettle;
  /// Prize already marked as paid
  final double totalPrizePaid;
  /// Your commission from this month's settled auctions
  final double myCommission;
  /// Number of auctions held this month
  final int auctionsThisMonth;
  /// Number of auctions pending (active chits that have no auction this month yet)
  final int pendingAuctions;

  const MonthlyGroupSummary({
    required this.auctionDay,
    required this.activeChits,
    required this.totalChitValue,
    required this.totalExpectedCollection,
    required this.totalPrizeToSettle,
    required this.totalPrizePaid,
    required this.myCommission,
    required this.auctionsThisMonth,
    required this.pendingAuctions,
  });

  static const empty10 = MonthlyGroupSummary(
    auctionDay: 10,
    activeChits: 0,
    totalChitValue: 0,
    totalExpectedCollection: 0,
    totalPrizeToSettle: 0,
    totalPrizePaid: 0,
    myCommission: 0,
    auctionsThisMonth: 0,
    pendingAuctions: 0,
  );

  static const empty20 = MonthlyGroupSummary(
    auctionDay: 20,
    activeChits: 0,
    totalChitValue: 0,
    totalExpectedCollection: 0,
    totalPrizeToSettle: 0,
    totalPrizePaid: 0,
    myCommission: 0,
    auctionsThisMonth: 0,
    pendingAuctions: 0,
  );
}

// ── This month's winners (for prize settlement table) ────────────────────────

/// All auctions from the current month that have a winning member.
/// Sorted: unpaid first, then paid; within each group by auction_day.
final thisMonthWinnersProvider =
    FutureProvider<List<AuctionModel>>((ref) async {
  final auctions = await ref.watch(auctionsProvider(null).future);
  final now = DateTime.now();
  return auctions.where((a) {
    if (a.winningMemberId == null) return false;
    return _isCurrentMonth(a.auctionDate, now);
  }).toList()
    ..sort((a, b) {
      // Unpaid first
      if (a.prizePaid != b.prizePaid) return a.prizePaid ? 1 : -1;
      return (a.auctionDay ?? 0).compareTo(b.auctionDay ?? 0);
    });
});

/// Returns summary for a given auction day (10 or 20) using current month data.
final monthlyGroupProvider =
    FutureProvider.family<MonthlyGroupSummary, int>((ref, day) async {
  final chitsAsync = await ref.watch(chitsProvider(null).future);
  final auctAsync = await ref.watch(auctionsProvider(null).future);

  final now = DateTime.now();
  final chitDays = {for (final c in chitsAsync) c.id: c.auctionDay};

  // Active chits for this auction day
  final activeChits = chitsAsync
      .where((c) => c.auctionDay == day && c.status == 'active')
      .toList();

  final totalChitValue = activeChits.fold<double>(
    0,
    (sum, c) => sum + c.chitValue,
  );

  final totalCollection = activeChits.fold<double>(
    0,
    (sum, c) => sum + c.monthlyInstallment * c.totalMembers,
  );

  // Auctions from THIS month for this auction day
  final thisMonthAuctions = auctAsync.where((a) {
    if (_auctionDayFor(a, chitDays) != day) return false;
    return _isCurrentMonth(a.auctionDate, now);
  }).toList();

  // Settlement = winner prize only (auctions with a declared winner)
  final winnerAuctions = thisMonthAuctions
      .where((a) => a.winningMemberId != null)
      .toList();

  final totalSettlement = winnerAuctions.fold<double>(
    0,
    (sum, a) => sum + (a.prizeAmount ?? 0),
  );

  final totalCommission = winnerAuctions.fold<double>(
    0,
    (sum, a) => sum + (a.commissionAmount ?? 0),
  );

  final totalPrizePaid = winnerAuctions
      .where((a) => a.prizePaid)
      .fold<double>(0, (sum, a) => sum + (a.prizeAmount ?? 0));

  // Active chits that haven't had an auction this month yet
  final auctionedChitIds =
      thisMonthAuctions.map((a) => a.chitId).toSet();
  final pending =
      activeChits.where((c) => !auctionedChitIds.contains(c.id)).length;

  return MonthlyGroupSummary(
    auctionDay: day,
    activeChits: activeChits.length,
    totalChitValue: totalChitValue,
    totalExpectedCollection: totalCollection,
    totalPrizeToSettle: totalSettlement,
    totalPrizePaid: totalPrizePaid,
    myCommission: totalCommission,
    auctionsThisMonth: winnerAuctions.length,
    pendingAuctions: pending,
  );
});
