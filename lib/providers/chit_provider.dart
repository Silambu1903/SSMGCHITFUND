import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chit_model.dart';
import '../data/repositories/chit_repository.dart';

final chitRepositoryProvider = Provider<ChitRepository>(
  (ref) => ChitRepository(),
);

final chitsProvider =
    FutureProvider.family<List<ChitModel>, String?>((ref, branchId) async {
  return ref.read(chitRepositoryProvider).getChitsRaw(branchId: branchId);
});

final chitDetailProvider =
    FutureProvider.family<ChitModel?, String>((ref, chitId) async {
  return ref.read(chitRepositoryProvider).getChitById(chitId);
});

final chitMembersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, chitId) async {
    return ref.read(chitRepositoryProvider).getChitMembers(chitId);
  },
);

// Live chit form state for the Create Chit screen
class ChitFormState {
  final double chitAmount;
  final int totalMembers;
  final double commissionPercent;
  final int durationMonths;

  const ChitFormState({
    this.chitAmount = 100000,
    this.totalMembers = 20,
    this.commissionPercent = 5,
    this.durationMonths = 20,
  });

  double get monthlyInstallment =>
      totalMembers > 0 ? chitAmount / totalMembers : 0;
  double get commissionAmount => (chitAmount * commissionPercent) / 100;

  ChitFormState copyWith({
    double? chitAmount,
    int? totalMembers,
    double? commissionPercent,
    int? durationMonths,
  }) {
    return ChitFormState(
      chitAmount: chitAmount ?? this.chitAmount,
      totalMembers: totalMembers ?? this.totalMembers,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      durationMonths: durationMonths ?? this.durationMonths,
    );
  }
}

final chitFormStateProvider =
    StateNotifierProvider<ChitFormNotifier, ChitFormState>((ref) {
  return ChitFormNotifier();
});

class ChitFormNotifier extends StateNotifier<ChitFormState> {
  ChitFormNotifier() : super(const ChitFormState());

  void updateChitAmount(double v) =>
      state = state.copyWith(chitAmount: v);
  void updateTotalMembers(int v) =>
      state = state.copyWith(totalMembers: v);
  void updateCommission(double v) =>
      state = state.copyWith(commissionPercent: v);
  void updateDuration(int v) =>
      state = state.copyWith(durationMonths: v);
  void reset() => state = const ChitFormState();
}

// Create chit action
class ChitCreateNotifier extends StateNotifier<AsyncValue<ChitModel?>> {
  ChitCreateNotifier(this._repo) : super(const AsyncValue.data(null));

  final ChitRepository _repo;

  Future<ChitModel?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final chit = await _repo.createChit(data);
      state = AsyncValue.data(chit);
      return chit;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final chitCreateProvider =
    StateNotifierProvider<ChitCreateNotifier, AsyncValue<ChitModel?>>(
  (ref) => ChitCreateNotifier(ref.read(chitRepositoryProvider)),
);
