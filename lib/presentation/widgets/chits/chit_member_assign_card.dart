import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/member_model.dart';
import '../../../providers/language_provider.dart';

/// Member enrolled (or pending enrollment) in a chit with an assigned ticket number.
class EnrolledMemberEntry {
  final MemberModel member;
  int ticketNo;
  final String? enrollmentId;

  EnrolledMemberEntry({
    required this.member,
    required this.ticketNo,
    this.enrollmentId,
  });
}

/// Suggest the next ticket at the end of the list (highest used + 1).
int suggestNextTicketNo(Iterable<int> used, int maxMembers) {
  final taken = used.where((n) => n > 0).toSet();
  if (taken.isEmpty) return 1;
  final last = taken.reduce((a, b) => a > b ? a : b);
  final next = last + 1;
  if (next <= maxMembers) return next;
  for (var i = 1; i <= maxMembers; i++) {
    if (!taken.contains(i)) return i;
  }
  return maxMembers;
}

/// Returns null if valid, otherwise an error message.
String? validateTicketAssignments(
  List<EnrolledMemberEntry> entries,
  int maxMembers,
) {
  if (entries.isEmpty) return null;
  final seen = <int>{};
  for (final e in entries) {
    if (e.ticketNo < 1 || e.ticketNo > maxMembers) {
      return AppStrings.ticketRangeError(maxMembers);
    }
    if (!seen.add(e.ticketNo)) {
      return AppStrings.duplicateTicketError(e.ticketNo);
    }
  }
  return null;
}

class ChitMemberAssignCard extends ConsumerWidget {
  final List<EnrolledMemberEntry> enrolledMembers;
  final TextEditingController searchCtrl;
  final List<MemberModel> searchResults;
  final bool isSearching;
  final int maxMembers;
  final bool readOnly;
  final VoidCallback? onAddNewMember;
  final void Function(String memberId)? onEditMember;
  final ValueChanged<String> onSearch;
  final ValueChanged<MemberModel> onAdd;
  final void Function(String memberId) onRemove;
  final void Function(String memberId, int ticketNo) onTicketChanged;

  const ChitMemberAssignCard({
    super.key,
    required this.enrolledMembers,
    required this.searchCtrl,
    required this.searchResults,
    required this.isSearching,
    required this.maxMembers,
    this.readOnly = false,
    this.onAddNewMember,
    this.onEditMember,
    required this.onSearch,
    required this.onAdd,
    required this.onRemove,
    required this.onTicketChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final isFull = enrolledMembers.length >= maxMembers;

    return Container(
      decoration: AppColors.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.people_alt_outlined,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        AppStrings.assignMembersTitle,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        AppStrings.assignedCount(
                            enrolledMembers.length, maxMembers),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: enrolledMembers.isEmpty
                        ? AppColors.chipBlue
                        : isFull
                            ? AppColors.successLight
                            : AppColors.chipAmber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFull
                        ? AppStrings.full
                        : '${enrolledMembers.length}/$maxMembers',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isFull ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!readOnly) ...[
                  Text(
                    AppStrings.assignMember,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.searchMemberHint,
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  if (!isFull) ...[
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: AppStrings.typeToSearch,
                        prefixIcon: isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.search,
                                size: 18, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: onSearch,
                    ),
                    if (searchResults.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _SectionBox(
                        child: Column(
                          children: searchResults.take(5).map((m) {
                            return Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: AppColors.border)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.chipBlue,
                                    child: Text(
                                      m.name.isNotEmpty
                                          ? m.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(m.name,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                        Text('${m.memberNo} • ${m.mobile}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => onAdd(m),
                                    icon: const Icon(Icons.add, size: 14),
                                    label: Text(AppStrings.add,
                                        style: const TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(72, 32),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppStrings.allSlotsFilled,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (onAddNewMember != null)
                    ElevatedButton.icon(
                      onPressed: onAddNewMember,
                      icon: const Icon(Icons.person_add_alt_1_outlined,
                          size: 16),
                      label: Text(AppStrings.addNewMember),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 42),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.assignedMembersTitle,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (!readOnly && enrolledMembers.isNotEmpty)
                      Text(
                        AppStrings.ticketEditable,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (enrolledMembers.isEmpty)
                  _SectionBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          const Icon(Icons.people_outline,
                              size: 28, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.noMembersAssigned,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.assignMembersEmptyHint,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _SectionBox(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                          child: Row(
                            children: [
                              const SizedBox(width: 38),
                              Expanded(
                                child: Text(AppStrings.member,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)),
                              ),
                              SizedBox(
                                width: 72,
                                child: Text(AppStrings.ticketNo,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)),
                              ),
                              SizedBox(
                                width: 88,
                                child: Text(AppStrings.actions,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                        ),
                        ...enrolledMembers.map((entry) {
                          final m = entry.member;
                          return Container(
                            padding:
                                const EdgeInsets.fromLTRB(12, 8, 8, 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: AppColors.border)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.chipBlue,
                                  child: Text(
                                    m.name.isNotEmpty
                                        ? m.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(m.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                      Text('${m.memberNo} • ${m.mobile}',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 72,
                                  child: readOnly
                                      ? Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.chipBlue,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '#${entry.ticketNo}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary),
                                            ),
                                          ),
                                        )
                                      : TextFormField(
                                          key: ValueKey('ticket-${m.id}'),
                                          initialValue: '${entry.ticketNo}',
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 8),
                                            prefixText: '#',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: AppColors.border),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 2),
                                            ),
                                          ),
                                          onChanged: (v) {
                                            final n = int.tryParse(v);
                                            if (n != null &&
                                                n != entry.ticketNo) {
                                              onTicketChanged(m.id, n);
                                            }
                                          },
                                        ),
                                ),
                                if (!readOnly)
                                  SizedBox(
                                    width: 130,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (onEditMember != null)
                                          TextButton(
                                            onPressed: () =>
                                                onEditMember!(m.id),
                                            style: TextButton.styleFrom(
                                              minimumSize: const Size(48, 32),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6),
                                            ),
                                            child: Text(AppStrings.edit,
                                                style:
                                                    const TextStyle(fontSize: 11)),
                                          ),
                                        TextButton.icon(
                                          onPressed: () => onRemove(m.id),
                                          icon: const Icon(Icons.remove,
                                              size: 14,
                                              color: AppColors.error),
                                          label: Text(AppStrings.remove,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.error)),
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(72, 32),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
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

class _SectionBox extends StatelessWidget {
  final Widget child;
  const _SectionBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
