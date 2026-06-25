import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/language_provider.dart';

/// Ask admin to confirm ticket number before assigning a member to a chit.
Future<int?> showAssignChitMemberDialog({
  required BuildContext context,
  required MemberModel member,
  required int suggestedTicket,
  required int maxMembers,
}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => _AssignChitMemberDialog(
      member: member,
      suggestedTicket: suggestedTicket,
      maxMembers: maxMembers,
    ),
  );
}

class _AssignChitMemberDialog extends ConsumerStatefulWidget {
  final MemberModel member;
  final int suggestedTicket;
  final int maxMembers;

  const _AssignChitMemberDialog({
    required this.member,
    required this.suggestedTicket,
    required this.maxMembers,
  });

  @override
  ConsumerState<_AssignChitMemberDialog> createState() =>
      _AssignChitMemberDialogState();
}

class _AssignChitMemberDialogState
    extends ConsumerState<_AssignChitMemberDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.suggestedTicket}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, int.parse(_ctrl.text));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    return AlertDialog(
      title: Text(AppStrings.assignToChit),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.member.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.member.memberNo} • ${widget.member.mobile}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: AppStrings.ticketNo,
                hintText: '1 – ${widget.maxMembers}',
                prefixText: '#',
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null) return AppStrings.enterTicketNumber;
                if (n < 1 || n > widget.maxMembers) {
                  return AppStrings.ticketRangeError(widget.maxMembers);
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(AppStrings.assign),
        ),
      ],
    );
  }
}
