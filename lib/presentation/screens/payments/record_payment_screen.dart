import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/language_provider.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final String? chitId;
  final String? paymentId;

  const RecordPaymentScreen({
    super.key,
    this.memberId,
    this.chitId,
    this.paymentId,
  });

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState
    extends ConsumerState<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dueCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController(text: '0');
  String _mode = 'cash';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _dueCtrl.dispose();
    _paidCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  double get _balance =>
      (double.tryParse(_dueCtrl.text) ?? 0) -
      (double.tryParse(_paidCtrl.text) ?? 0);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final seq = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final data = {
      'member_id': widget.memberId ?? '',
      'chit_id': widget.chitId ?? '',
      'payment_month': DateTime.now().month,
      'due_amount': double.tryParse(_dueCtrl.text) ?? 0.0,
      'paid_amount': double.tryParse(_paidCtrl.text) ?? 0.0,
      'penalty_amount': double.tryParse(_penaltyCtrl.text) ?? 0.0,
      'payment_date': _date.toIso8601String(),
      'payment_mode': _mode,
      'receipt_number':
          'RCP-${_date.year}${_date.month.toString().padLeft(2, '0')}-$seq',
      'status': _balance <= 0 ? 'Paid' : 'Partial',
    };
    final payment =
        await ref.read(paymentFormProvider.notifier).record(data);
    if (payment != null && mounted) {
      ref.invalidate(paymentsProvider);
      final chitId = widget.chitId;
      if (chitId != null && chitId.isNotEmpty) {
        ref.invalidate(chitPaymentsProvider(chitId));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppStrings.paymentRecorded(payment.receiptNumber ?? '')),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/payments');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final state = ref.watch(paymentFormProvider);

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/payments'),
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
              Text(AppStrings.recordPayment,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Container(
              padding: Responsive.pagePadding(context),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Due amount
                  _FormRow(
                    label: AppStrings.dueAmount,
                    child: TextFormField(
                      controller: _dueCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(prefixText: '₹ '),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? AppStrings.required : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _FormRow(
                    label: AppStrings.paidAmount,
                    child: TextFormField(
                      controller: _paidCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(prefixText: '₹ '),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? AppStrings.required : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  _FormRow(
                    label: AppStrings.penaltyAmount,
                    child: TextFormField(
                      controller: _penaltyCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(prefixText: '₹ '),
                    ),
                  ),

                  // Balance display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _balance <= 0
                          ? AppColors.successLight
                          : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.balanceAmount,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text(
                          CurrencyFormatter.format(_balance.abs()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _balance <= 0
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payment mode
                  _FormRow(
                    label: AppStrings.paymentMode,
                    child: DropdownButtonFormField<String>(
                      value: _mode,
                      items: ['cash', 'upi', 'bank_transfer', 'cheque']
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(AppStrings.paymentModeLabel(m)),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _mode = v ?? 'cash'),
                    ),
                  ),

                  // Date
                  _FormRow(
                    label: AppStrings.paymentDate,
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14),
                            const SizedBox(width: 8),
                            Text(
                              '${_date.day}/${_date.month}/${_date.year}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go('/payments'),
                        child: Text(AppStrings.cancel),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: state.isLoading ? null : _submit,
                        icon: const Icon(Icons.receipt_outlined, size: 16),
                        label: Text(AppStrings.recordPayment),
                      ),
                    ],
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

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}
