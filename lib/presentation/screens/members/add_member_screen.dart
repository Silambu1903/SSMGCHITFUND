import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/supabase_payload.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/chits/chit_member_assign_card.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  final String? editId; // non-null → edit mode
  final String? fromChitId; // auto-assign to this chit after create
  const AddMemberScreen({super.key, this.editId, this.fromChitId});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  bool _prefilling = false;

  bool get _isEdit => widget.editId != null;

  TextEditingController _c(String key) =>
      _controllers.putIfAbsent(key, TextEditingController.new);

  @override
  void initState() {
    super.initState();
    if (_isEdit) _prefill();
  }

  Future<void> _prefill() async {
    setState(() => _prefilling = true);
    try {
      final m = await ref
          .read(memberRepositoryProvider)
          .getMemberById(widget.editId!);
      if (m != null && mounted) {
        _c('member_no').text = m.memberNo;
        _c('name').text = m.name;
        _c('father_name').text = m.fatherName ?? '';
        _c('mobile').text = m.mobile;
        _c('alternate_mobile').text = m.alternateMobile ?? '';
        _c('email').text = m.email ?? '';
        _c('aadhaar').text = m.aadhaarNumber ?? '';
        _c('pan').text = m.panNumber ?? '';
        _c('address').text = m.address ?? '';
        _c('occupation').text = m.occupation ?? '';
        _c('income').text = m.monthlyIncome?.toStringAsFixed(0) ?? '';
      }
    } finally {
      if (mounted) setState(() => _prefilling = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _c('name').text.trim(),
      'father_name': _c('father_name').text.trim(),
      'mobile': _c('mobile').text.trim(),
      'alternate_mobile': _c('alternate_mobile').text.trim(),
      'email': _c('email').text.trim(),
      'aadhaar_number': _c('aadhaar').text.trim(),
      'pan_number': _c('pan').text.trim(),
      'address': _c('address').text.trim(),
      'occupation': _c('occupation').text.trim(),
      'monthly_income': double.tryParse(_c('income').text.trim()) ?? 0.0,
    };

    if (_isEdit) {
      // ── Update mode ──────────────────────────────────────────────────────
      try {
        await ref
            .read(memberRepositoryProvider)
            .updateMember(widget.editId!, data);
        ref.invalidate(memberDetailProvider(widget.editId!));
        ref.invalidate(membersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.memberUpdatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/members/${widget.editId}');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.errorMessage('$e')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      // ── Create mode ──────────────────────────────────────────────────────
      final createData = {
        ...data,
        'member_no': _c('member_no').text.trim().isEmpty
            ? '${AppStrings.brandPrefix}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
            : _c('member_no').text.trim(),
        'branch_id': 'a1000000-0000-0000-0000-000000000001',
        'joining_date': DateTime.now().toIso8601String().substring(0, 10),
        'status': 'active',
      };
      final member =
          await ref.read(memberFormProvider.notifier).create(createData);
      if (member != null && mounted) {
        ref.invalidate(membersProvider);

        if (widget.fromChitId != null) {
          await _assignNewMemberToChit(member);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.memberSavedSuccess(member.name)),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/members/${member.id}');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              memberSaveErrorMessage(ref.read(memberFormProvider).error),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _assignNewMemberToChit(MemberModel member) async {
    final chitId = widget.fromChitId!;
    final chitRepo = ref.read(chitRepositoryProvider);
    final chit = await chitRepo.getChitById(chitId);
    if (chit == null || !mounted) {
      context.go('/chits/$chitId');
      return;
    }

    final rows = await chitRepo.getChitMembers(chitId);
    if (rows.length >= chit.totalMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.chitFullMemberNotAssigned),
          backgroundColor: AppColors.warning,
        ),
      );
      context.go('/chits/$chitId');
      return;
    }

    final usedTickets = rows
        .map((r) => (r['ticket_no'] as num?)?.toInt() ?? 0)
        .where((n) => n > 0);
    final suggested = suggestNextTicketNo(usedTickets, chit.totalMembers);
    try {
      await chitRepo.enrollMember({
        'chit_id': chitId,
        'member_id': member.id,
        'ticket_no': suggested,
        'joining_date': chit.startDate,
        'status': 'active',
      });
      ref.invalidate(chitMembersProvider(chitId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.memberCreatedAssignedTicket(
                member.name, suggested)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.memberCreatedAssignFailed('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) context.go('/chits/$chitId');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final formState = ref.watch(memberFormProvider);
    final isWide = MediaQuery.of(context).size.width > 900;
    final isBusy = formState.isLoading || _prefilling;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go(
                    _isEdit ? '/members/${widget.editId}' : '/members'),
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
              Text(
                _isEdit ? AppStrings.editMember : AppStrings.newMember,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_prefilling)
            const Center(child: CircularProgressIndicator())
          else
            Form(
              key: _formKey,
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _PersonalSection(
                                c: _c, isEdit: _isEdit)),
                        const SizedBox(width: 20),
                        Expanded(child: _FinancialSection(c: _c)),
                      ],
                    )
                  : Column(
                      children: [
                        _PersonalSection(c: _c, isEdit: _isEdit),
                        const SizedBox(height: 20),
                        _FinancialSection(c: _c),
                      ],
                    ),
            ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => context.go(
                    _isEdit ? '/members/${widget.editId}' : '/members'),
                child: Text(AppStrings.cancel),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: isBusy ? null : _submit,
                icon: isBusy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _isEdit
                            ? Icons.save_outlined
                            : Icons.person_add_outlined,
                        size: 16),
                label: Text(_isEdit ? AppStrings.update : AppStrings.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalSection extends StatelessWidget {
  final TextEditingController Function(String) c;
  final bool isEdit;
  const _PersonalSection({required this.c, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.chipBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline,
                    size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.newMember,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(AppStrings.personalInfo,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isEdit)
            _FormField(
              label: AppStrings.memberNo,
              hint: AppStrings.autoGeneratedMemberNo,
              controller: c('member_no'),
            ),
          _FormField(
            label: AppStrings.memberName,
            hint: AppStrings.fullNameHint,
            controller: c('name'),
            required: true,
          ),
          _FormField(
            label: AppStrings.fatherName,
            hint: AppStrings.fatherHusbandHint,
            controller: c('father_name'),
          ),
          _FormField(
            label: AppStrings.mobile,
            hint: '9876543210',
            controller: c('mobile'),
            required: true,
            keyboardType: TextInputType.phone,
          ),
          _FormField(
            label: AppStrings.alternateMobile,
            hint: AppStrings.optional,
            controller: c('alternate_mobile'),
            keyboardType: TextInputType.phone,
          ),
          _FormField(
            label: AppStrings.email,
            hint: AppStrings.enterEmail,
            controller: c('email'),
            keyboardType: TextInputType.emailAddress,
          ),
          _FormField(
            label: AppStrings.aadhaar,
            hint: AppStrings.aadhaarHint,
            controller: c('aadhaar'),
            keyboardType: TextInputType.number,
            maxLength: 12,
          ),
          _FormField(
            label: AppStrings.pan,
            hint: AppStrings.panHint,
            controller: c('pan'),
          ),
          _FormField(
            label: AppStrings.address,
            hint: AppStrings.addressHint,
            controller: c('address'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _FinancialSection extends StatelessWidget {
  final TextEditingController Function(String) c;
  const _FinancialSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.chipGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: AppColors.success),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.financialDetails,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(AppStrings.incomeOccupation,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FormField(
            label: AppStrings.occupation,
            hint: AppStrings.occupationHint,
            controller: c('occupation'),
          ),
          _FormField(
            label: AppStrings.income,
            hint: AppStrings.monthlyIncomeHint,
            controller: c('income'),
            keyboardType: TextInputType.number,
            prefix: '₹',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.documentsUploadHint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? prefix;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              children: required
                  ? [
                      const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.error))
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefix,
              counterText: '',
            ),
            validator: required
                ? (v) => (v?.isEmpty ?? true) ? AppStrings.required : null
                : null,
          ),
        ],
      ),
    );
  }
}
