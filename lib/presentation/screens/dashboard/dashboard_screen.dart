import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/auction_model.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/loading_states.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final metrics        = ref.watch(dashboardMetricsProvider(null));
    final recentPayments = ref.watch(recentPaymentsProvider);
    final defaulters     = ref.watch(defaulterSummaryProvider);
    final group10        = ref.watch(monthlyGroupProvider(10));
    final group20        = ref.watch(monthlyGroupProvider(20));
    final winners        = ref.watch(thisMonthWinnersProvider);
    final isWide         = MediaQuery.of(context).size.width > 1024;

    final now        = DateTime.now();
    final monthLabel = AppStrings.monthYear(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary stats grid ─────────────────────────────────────────────
          metrics.when(
            loading: () => GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: List.generate(7, (_) => const CardShimmer()),
            ),
            error: (e, _) => ErrorWidget2(message: e.toString()),
            data: (m) => GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  title: AppStrings.totalMembers,
                  value: m.totalMembers.toString(),
                  icon: Icons.people_alt_outlined,
                  bgColor: AppColors.statCard1,
                  iconColor: AppColors.primary,
                  onTap: () => context.go('/members'),
                ),
                StatCard(
                  title: AppStrings.activeChits,
                  value: m.activeChits.toString(),
                  icon: Icons.savings_outlined,
                  bgColor: AppColors.statCard2,
                  iconColor: AppColors.success,
                  onTap: () => context.go('/chits'),
                ),
                StatCard(
                  title: AppStrings.monthlyCollection,
                  value: CurrencyFormatter.compact(m.monthlyCollection),
                  icon: Icons.account_balance_wallet_outlined,
                  bgColor: AppColors.statCard3,
                  iconColor: AppColors.warning,
                  subtitle: AppStrings.thisMonth,
                  onTap: () => context.go('/payments'),
                ),
                StatCard(
                  title: AppStrings.pendingAmount,
                  value: CurrencyFormatter.compact(m.pendingCollections),
                  icon: Icons.pending_actions_outlined,
                  bgColor: AppColors.errorLight,
                  iconColor: AppColors.error,
                  onTap: () => context.go('/payments'),
                ),
                StatCard(
                  title: AppStrings.completedChits,
                  value: m.settledChits.toString(),
                  icon: Icons.check_circle_outline,
                  bgColor: AppColors.statCard2,
                  iconColor: AppColors.success,
                ),
                StatCard(
                  title: AppStrings.defaulters,
                  value: m.defaulters.toString(),
                  icon: Icons.warning_amber_outlined,
                  bgColor: AppColors.errorLight,
                  iconColor: AppColors.error,
                ),
                StatCard(
                  title: AppStrings.upcomingAuctions,
                  value: m.upcomingAuctions.toString(),
                  icon: Icons.gavel_outlined,
                  bgColor: AppColors.statCard4,
                  iconColor: AppColors.primaryLight,
                  onTap: () => context.go('/auctions'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Monthly Group Panels (10th vs 20th) ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_month,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                AppStrings.monthlyOverview(monthLabel),
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.settlementSplitSubtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child:
                        _MonthlyGroupCard(day: 10, asyncData: group10)),
                const SizedBox(width: 16),
                Expanded(
                    child:
                        _MonthlyGroupCard(day: 20, asyncData: group20)),
              ],
            )
          else ...[
            _MonthlyGroupCard(day: 10, asyncData: group10),
            const SizedBox(height: 16),
            _MonthlyGroupCard(day: 20, asyncData: group20),
          ],

          const SizedBox(height: 28),

          // ── This Month's Winners — Prize Settlement ────────────────────────
          _MonthlyWinnersSection(
              winners: winners, monthLabel: monthLabel, ref: ref),

          const SizedBox(height: 28),

          // ── Recent payments + Defaulters ───────────────────────────────────
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _RecentPaymentsTable(payments: recentPayments),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _DefaultersList(defaulters: defaulters),
                ),
              ],
            )
          else ...[
            _RecentPaymentsTable(payments: recentPayments),
            const SizedBox(height: 16),
            _DefaultersList(defaulters: defaulters),
          ],
        ],
      ),
    );
  }
}

// ── Monthly Group Card ───────────────────────────────────────────────────────

class _MonthlyGroupCard extends StatelessWidget {
  final int day;
  final AsyncValue<MonthlyGroupSummary> asyncData;
  const _MonthlyGroupCard({required this.day, required this.asyncData});

  @override
  Widget build(BuildContext context) {
    // Color theme varies by day
    final isDay10     = day == 10;
    final accent      = isDay10 ? AppColors.primary : const Color(0xFF7C3AED);
    final accentLight = isDay10 ? AppColors.statCard1 : AppColors.chipPurple;
    final headerGrad  = isDay10
        ? [const Color(0xFF1A56DB), const Color(0xFF3B82F6)]
        : [const Color(0xFF7C3AED), const Color(0xFFA855F7)];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: accent.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: headerGrad, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppStrings.everyNth(day),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.auctionGroup,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ),
                asyncData.maybeWhen(
                  data: (s) => _StatusBadge(
                    label: AppStrings.activeChitsCount(s.activeChits),
                    color: Colors.white,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Body
          asyncData.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text(AppStrings.errorMessage('$e'),
                  style: const TextStyle(color: AppColors.error)),
            ),
            data: (s) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                children: [
                  // Settlement amount
                  _SettlementRow(
                    icon: Icons.emoji_events_rounded,
                    iconBg: accentLight,
                    iconColor: accent,
                    label: AppStrings.totalSettlement,
                    sublabel: s.auctionsThisMonth > 0
                        ? AppStrings.winnersThisMonth(s.auctionsThisMonth)
                        : AppStrings.noWinnerRecordedYet,
                    value: CurrencyFormatter.format(s.totalPrizeToSettle),
                    valueColor: accent,
                    pending: s.auctionsThisMonth == 0,
                  ),
                  if (s.auctionsThisMonth > 0 &&
                      s.totalPrizePaid > 0 &&
                      s.totalPrizePaid < s.totalPrizeToSettle) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.paidRemaining(
                          CurrencyFormatter.compact(s.totalPrizePaid),
                          CurrencyFormatter.compact(
                              s.totalPrizeToSettle - s.totalPrizePaid),
                        ),
                        style: TextStyle(
                            fontSize: 10,
                            color: accent.withOpacity(0.8)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Commission only
                  _SettlementRow(
                    icon: Icons.star_rounded,
                    iconBg: AppColors.chipGreen,
                    iconColor: AppColors.success,
                    label: AppStrings.yourCommission,
                    sublabel: AppStrings.foremanEarningsSubtitle,
                    value: CurrencyFormatter.format(s.myCommission),
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String sublabel;
  final String value;
  final Color valueColor;
  final bool pending;

  const _SettlementRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.valueColor,
    this.pending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(sublabel,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            if (pending)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.chipAmber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.auctionPending,
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Monthly Winners Settlement Section ───────────────────────────────────────

class _MonthlyWinnersSection extends StatelessWidget {
  final AsyncValue<List<AuctionModel>> winners;
  final String monthLabel;
  final WidgetRef ref;
  const _MonthlyWinnersSection({
    required this.winners,
    required this.monthLabel,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return winners.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();

        final totalPending = list
            .where((a) => !a.prizePaid)
            .fold<double>(0, (s, a) => s + (a.prizeAmount ?? 0));
        final totalPaid = list
            .where((a) => a.prizePaid)
            .fold<double>(0, (s, a) => s + (a.prizeAmount ?? 0));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppStrings.prizeSettlement(monthLabel),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                if (totalPending > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.chipAmber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppStrings.amountPending(
                          CurrencyFormatter.compact(totalPending)),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning),
                    ),
                  ),
                if (totalPaid > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.chipGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppStrings.amountPaidBadge(
                          CurrencyFormatter.compact(totalPaid)),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.auctionWinnersCount(list.length),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Winners table card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(AppStrings.winnerCol,
                                style: _hStyle)),
                        Expanded(
                            flex: 3,
                            child: Text(AppStrings.chitSchemeCol,
                                style: _hStyle)),
                        SizedBox(
                            width: 56,
                            child: Text(AppStrings.dayCol,
                                style: _hStyle,
                                textAlign: TextAlign.center)),
                        SizedBox(
                            width: 110,
                            child: Text(AppStrings.prizeAmountCol,
                                style: _hStyle,
                                textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...list.asMap().entries.map((e) => _WinnerRow(
                        auction: e.value,
                        isLast: e.key == list.length - 1,
                      )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static const _hStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
}

class _WinnerRow extends StatelessWidget {
  final AuctionModel auction;
  final bool isLast;
  const _WinnerRow({
    required this.auction,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final a = auction;
    final name = a.winnerName ?? AppStrings.unknown;
    final initials =
        name.trim().split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: a.prizePaid
            ? AppColors.chipGreen.withOpacity(0.25)
            : Colors.white,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border)),
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(14))
            : null,
      ),
      child: Row(
        children: [
          // Winner
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: a.prizePaid
                      ? AppColors.chipGreen
                      : AppColors.chipBlue,
                  child: Text(
                    initials.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: a.prizePaid
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (a.winnerMemberNo != null)
                        Text(
                          a.winnerMemberNo!,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chit name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.chitName ?? '-',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  a.chitCode ?? '',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // Auction day badge
          SizedBox(
            width: 56,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (a.auctionDay == 10)
                      ? AppColors.chipBlue
                      : AppColors.chipPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.nthDay(a.auctionDay),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: (a.auctionDay == 10)
                        ? AppColors.primary
                        : const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ),
          ),
          // Prize amount (+ paid tick when settled)
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    CurrencyFormatter.format(a.prizeAmount ?? 0),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: a.prizePaid
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (a.prizePaid) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.success),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPaymentsTable extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> payments;
  const _RecentPaymentsTable({required this.payments});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.recentPaymentsTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.recentPaymentsSubtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => context.go('/payments'),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: Text(AppStrings.viewAll,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          payments.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text(AppStrings.errorMessage('$e'),
                  style: const TextStyle(color: AppColors.error)),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(AppStrings.noRecentPayments,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }
              return Column(
                children: list
                    .take(8)
                    .map((p) => _PaymentRow(payment: p))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final status = payment['status'] ?? 'Pending';
    final statusColor = {
          'Paid': AppColors.success,
          'Overdue': AppColors.error,
          'Partial': AppColors.warning,
        }[status] ??
        AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.chipBlue,
            child: Text(
              (payment['member_name'] ?? '?').substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['member_name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppStrings.paymentMonthLine(
                    payment['payment_month'] as int? ?? 0,
                    payment['chit_name'] ?? '',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(
                    (payment['paid_amount'] as num?)?.toDouble() ?? 0),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.paymentStatus(status),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DefaultersList extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> defaulters;
  const _DefaultersList({required this.defaulters});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.warning_amber,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.defaulters,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
                Text(
                  AppStrings.defaultersSubtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          defaulters.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppStrings.errorMessage('$e')),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.noDefaulters,
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: list
                    .take(6)
                    .map((d) => _DefaulterRow(defaulter: d))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DefaulterRow extends StatelessWidget {
  final Map<String, dynamic> defaulter;
  const _DefaulterRow({required this.defaulter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline,
                color: AppColors.error, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  defaulter['member_name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppStrings.monthsOverdue(defaulter['overdue_months'] ?? 0),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.compact(
                (defaulter['total_overdue'] as num?)?.toDouble() ?? 0),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
