import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final statusFilter = ref.watch(paymentStatusFilterProvider);
    final payments = ref.watch(paymentsProvider);
    final statuses = [null, 'Paid', 'Partial', 'Pending', 'Overdue'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((s) {
                      final isSelected = s == statusFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(s == null ? AppStrings.filterAll : AppStrings.paymentStatus(s)),
                          selected: isSelected,
                          onSelected: (_) => ref
                              .read(paymentStatusFilterProvider.notifier)
                              .state = s,
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.chipBlue,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/payments/record'),
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppStrings.recordPayment),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: payments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorWidget2(message: e.toString()),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    message: AppStrings.noPaymentsFound,
                    icon: Icons.payments_outlined,
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _PaymentCard(payment: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final dynamic payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.memberName ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.memberPaymentLine(
                        payment.memberNo ?? '',
                        payment.paymentMonth as int? ?? 0,
                        payment.chitName ?? '',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip.forStatus(payment.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _PayAmt(
                label: AppStrings.dueAmount,
                value: CurrencyFormatter.format(payment.dueAmount),
              ),
              _PayAmt(
                label: AppStrings.paidAmount,
                value: CurrencyFormatter.format(payment.paidAmount),
                color: AppColors.success,
              ),
              _PayAmt(
                label: AppStrings.balanceAmount,
                value: CurrencyFormatter.format(payment.balanceAmount),
                color: payment.balanceAmount > 0
                    ? AppColors.error
                    : AppColors.success,
              ),
              if (payment.receiptNumber != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.receiptNumber ?? '-',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(AppStrings.receiptNumber,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textMuted)),
                    ],
                  ),
                ),
            ],
          ),
          if (payment.paymentDate != null) ...[
            const SizedBox(height: 6),
            Text(
              '${payment.paymentMode?.toUpperCase()} • ${DateFormatter.toDisplay(DateTime.tryParse(payment.paymentDate ?? ''))}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayAmt extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PayAmt({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              )),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
