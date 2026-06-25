import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/auction_model.dart';
import '../data/repositories/auction_repository.dart';

export '../data/repositories/auction_repository.dart' show AuctionRepository;

final auctionRepositoryProvider = Provider<AuctionRepository>(
  (ref) => AuctionRepository(),
);

final auctionsProvider =
    FutureProvider.family<List<AuctionModel>, String?>((ref, chitId) async {
  return ref.read(auctionRepositoryProvider).getAuctions(chitId: chitId);
});

final auctionDetailProvider =
    FutureProvider.family<AuctionModel?, String>((ref, id) async {
  return ref.read(auctionRepositoryProvider).getAuctionById(id);
});

final auctionBidsProvider =
    FutureProvider.family<List<AuctionBidModel>, String>(
  (ref, auctionId) async {
    return ref.read(auctionRepositoryProvider).getBids(auctionId);
  },
);

/// Returns the next auction month number for a given chit id.
/// Invalidate this after saving a new auction.
final nextAuctionMonthProvider =
    FutureProvider.family<int, String>((ref, chitId) async {
  return ref.read(auctionRepositoryProvider).getNextAuctionMonth(chitId);
});

// Live auction calculator state
class AuctionCalcState {
  final double chitAmount;
  final double discountAmount;
  final double commissionPercent;
  final int totalMembers;
  final double monthlyInstallment;

  const AuctionCalcState({
    this.chitAmount = 0,
    this.discountAmount = 0,
    this.commissionPercent = 5,
    this.totalMembers = 50,
    this.monthlyInstallment = 10000,
  });

  double get commission => (chitAmount * commissionPercent) / 100;
  double get dividendPool =>
      discountAmount > commission ? discountAmount - commission : 0;
  double get dividendPerMember =>
      totalMembers > 0 ? dividendPool / totalMembers : 0;
  double get prizeAmount => chitAmount - discountAmount;
  double get nextMonthPayable => monthlyInstallment - dividendPerMember > 0
      ? monthlyInstallment - dividendPerMember
      : 0;

  AuctionCalcState copyWith({
    double? chitAmount,
    double? discountAmount,
    double? commissionPercent,
    int? totalMembers,
    double? monthlyInstallment,
  }) {
    return AuctionCalcState(
      chitAmount: chitAmount ?? this.chitAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      totalMembers: totalMembers ?? this.totalMembers,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
    );
  }
}

class AuctionCalcNotifier extends StateNotifier<AuctionCalcState> {
  AuctionCalcNotifier() : super(const AuctionCalcState());

  void fromChit({
    required double chitAmount,
    required double commissionPercent,
    required int totalMembers,
    required double monthlyInstallment,
  }) {
    state = state.copyWith(
      chitAmount: chitAmount,
      commissionPercent: commissionPercent,
      totalMembers: totalMembers,
      monthlyInstallment: monthlyInstallment,
    );
  }

  void updateDiscount(double v) => state = state.copyWith(discountAmount: v);
}

final auctionCalcProvider =
    StateNotifierProvider<AuctionCalcNotifier, AuctionCalcState>(
  (ref) => AuctionCalcNotifier(),
);
