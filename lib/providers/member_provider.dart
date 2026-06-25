import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/member_model.dart';
import '../data/repositories/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => MemberRepository(),
);

// Search query state
final memberSearchQueryProvider = StateProvider<String>((ref) => '');

// Members list with optional branch filter
final membersProvider =
    FutureProvider.family<List<MemberModel>, String?>((ref, branchId) async {
  final query = ref.watch(memberSearchQueryProvider);
  final repo = ref.read(memberRepositoryProvider);
  if (query.length >= 2) {
    return repo.searchMembers(query);
  }
  return repo.getMembers(branchId: branchId, status: 'active');
});

// Single member
final memberDetailProvider =
    FutureProvider.family<MemberModel?, String>((ref, memberId) async {
  return ref.read(memberRepositoryProvider).getMemberById(memberId);
});

// Guarantors for a member
final guarantorsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, memberId) async {
  return ref.read(memberRepositoryProvider).getGuarantors(memberId);
});

// Create/Edit member notifier
class MemberFormNotifier extends StateNotifier<AsyncValue<MemberModel?>> {
  MemberFormNotifier(this._repo) : super(const AsyncValue.data(null));

  final MemberRepository _repo;

  Future<MemberModel?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final member = await _repo.createMember(data);
      state = AsyncValue.data(member);
      return member;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<MemberModel?> update(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final member = await _repo.updateMember(id, data);
      state = AsyncValue.data(member);
      return member;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final memberFormProvider =
    StateNotifierProvider<MemberFormNotifier, AsyncValue<MemberModel?>>(
  (ref) => MemberFormNotifier(ref.read(memberRepositoryProvider)),
);
