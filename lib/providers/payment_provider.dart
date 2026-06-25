import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/payment_model.dart';
import '../data/repositories/payment_repository.dart';
import 'auction_provider.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(),
);

/// Status filter for the payments list (All / Paid / Partial / etc.)
final paymentStatusFilterProvider = StateProvider<String?>((ref) => null);

final paymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final status = ref.watch(paymentStatusFilterProvider);
  return ref.read(paymentRepositoryProvider).getPayments(status: status);
});

final chitPaymentsProvider =
    FutureProvider.family<List<PaymentModel>, String>((ref, chitId) async {
  final repo = ref.read(paymentRepositoryProvider);
  // Backfill due rows for any auction that has no payment records yet
  final auctions = await ref.read(auctionsProvider(chitId).future);
  for (final a in auctions) {
    final due = a.nextMonthPayable;
    if (due == null || due <= 0) continue;
    try {
      await repo.generateMonthlyDues(
        chitId: chitId,
        auctionId: a.id,
        paymentMonth: a.auctionMonth,
        dueAmount: due,
      );
    } catch (_) {}
  }
  return repo.getPaymentsForChit(chitId);
});

final defaultersProvider =
    FutureProvider<List<PaymentModel>>((ref) async {
  return ref.read(paymentRepositoryProvider).getDefaulters();
});

class PaymentFormNotifier extends StateNotifier<AsyncValue<PaymentModel?>> {
  PaymentFormNotifier(this._repo) : super(const AsyncValue.data(null));

  final PaymentRepository _repo;

  Future<PaymentModel?> record(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final payment = await _repo.recordPayment(data);
      state = AsyncValue.data(payment);
      return payment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PaymentModel?> update(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final payment = await _repo.updatePayment(id, data);
      state = AsyncValue.data(payment);
      return payment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final paymentFormProvider =
    StateNotifierProvider<PaymentFormNotifier, AsyncValue<PaymentModel?>>(
  (ref) => PaymentFormNotifier(ref.read(paymentRepositoryProvider)),
);

// Member outstanding balance
final memberOutstandingProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, memberId) async {
    return ref
        .read(paymentRepositoryProvider)
        .getMemberOutstanding(memberId);
  },
);
