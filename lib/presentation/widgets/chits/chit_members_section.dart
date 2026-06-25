import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/language_provider.dart';
import '../common/confirm_delete_dialog.dart';
import 'chit_member_assign_card.dart';

/// Manage chit member enrollments with assignable ticket numbers.
class ChitMembersSection extends ConsumerStatefulWidget {
  final String chitId;
  final int totalMembers;
  final String startDate;

  const ChitMembersSection({
    super.key,
    required this.chitId,
    required this.totalMembers,
    required this.startDate,
  });

  @override
  ConsumerState<ChitMembersSection> createState() =>
      _ChitMembersSectionState();
}

class _ChitMembersSectionState extends ConsumerState<ChitMembersSection> {
  final _searchCtrl = TextEditingController();
  List<MemberModel> _searchResults = [];
  bool _searching = false;
  bool _saving = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EnrolledMemberEntry> _parseMembers(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      final memberJson = row['members'] as Map<String, dynamic>?;
      final member = memberJson != null
          ? MemberModel.fromJson({...memberJson, 'branch_id': ''})
          : MemberModel(
              id: row['member_id'] as String,
              memberNo: '-',
              branchId: '',
              name: AppStrings.unknown,
              mobile: '',
              joiningDate: widget.startDate,
            );
      return EnrolledMemberEntry(
        member: member,
        ticketNo: (row['ticket_no'] as num?)?.toInt() ?? 0,
        enrollmentId: row['id'] as String?,
      );
    }).toList()
      ..sort((a, b) => a.ticketNo.compareTo(b.ticketNo));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final enrolled = ref.read(chitMembersProvider(widget.chitId)).valueOrNull;
      final enrolledIds =
          enrolled?.map((r) => r['member_id'] as String).toSet() ?? {};
      final results = await MemberRepository().searchMembers(query.trim());
      setState(() {
        _searchResults = results
            .where((m) => !enrolledIds.contains(m.id))
            .toList();
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _assignMember(MemberModel member, {int? ticketNo}) async {
    final rows = ref.read(chitMembersProvider(widget.chitId)).valueOrNull ?? [];
    if (rows.length >= widget.totalMembers) {
      _showError(AppStrings.chitFullMax(widget.totalMembers));
      return;
    }
    final entries = _parseMembers(rows);
    final chosen = ticketNo ??
        suggestNextTicketNo(
          entries.map((e) => e.ticketNo),
          widget.totalMembers,
        );
    if (!mounted) return;

    final draft = [
      ...entries,
      EnrolledMemberEntry(member: member, ticketNo: chosen),
    ];
    final err = validateTicketAssignments(draft, widget.totalMembers);
    if (err != null) {
      _showError(err);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(chitRepositoryProvider).enrollMember({
        'chit_id': widget.chitId,
        'member_id': member.id,
        'ticket_no': chosen,
        'joining_date': widget.startDate,
        'status': 'active',
      });
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
      _searchCtrl.clear();
      setState(() => _searchResults = []);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.memberAssignedTicket(member.name, chosen)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError(AppStrings.couldNotAssignMember('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateTicket(String memberId, int ticketNo) async {
    final rows = ref.read(chitMembersProvider(widget.chitId)).valueOrNull ?? [];
    final entries = _parseMembers(rows);
    final updated = entries.map((e) {
      if (e.member.id == memberId) {
        return EnrolledMemberEntry(
          member: e.member,
          ticketNo: ticketNo,
          enrollmentId: e.enrollmentId,
        );
      }
      return e;
    }).toList();
    final err = validateTicketAssignments(updated, widget.totalMembers);
    if (err != null) {
      _showError(err);
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
      return;
    }
    final entry = updated.firstWhere((e) => e.member.id == memberId);
    if (entry.enrollmentId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(chitRepositoryProvider).updateChitMember(
            entry.enrollmentId!,
            {'ticket_no': ticketNo},
          );
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.ticketNumberUpdated),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError(AppStrings.couldNotUpdateTicket('$e'));
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeMember(String memberId) async {
    final rows = ref.read(chitMembersProvider(widget.chitId)).valueOrNull ?? [];
    Map<String, dynamic>? row;
    for (final r in rows) {
      if (r['member_id'] == memberId) {
        row = r;
        break;
      }
    }
    if (row == null) return;

    final entries = _parseMembers(rows);
    final match = entries.where((e) => e.member.id == memberId);
    final name =
        match.isNotEmpty ? match.first.member.name : AppStrings.member;

    final ok = await showConfirmDelete(
      context,
      title: AppStrings.removeFromChitTitle,
      message: AppStrings.removeFromChitMessage(name),
    );
    if (!ok || !mounted) return;

    final hasPayments = await ref
        .read(chitRepositoryProvider)
        .memberHasPaymentsInChit(memberId, widget.chitId);
    if (hasPayments) {
      _showError(AppStrings.cannotRemoveHasPayments);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(chitRepositoryProvider)
          .removeChitMember(row['id'] as String);
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.memberRemovedFromChit),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError(AppStrings.couldNotRemoveMember('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openAddNewMember() async {
    await context.push('/members/add?fromChit=${widget.chitId}');
    if (mounted) {
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
      _search('');
    }
  }

  Future<void> _openEditMember(String memberId) async {
    await context.push('/members/$memberId/edit');
    if (mounted) {
      ref.invalidate(chitMembersProvider(widget.chitId));
      ref.invalidate(chitPaymentsProvider(widget.chitId));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final membersAsync = ref.watch(chitMembersProvider(widget.chitId));

    return membersAsync.when(
      loading: () => Container(
        decoration: AppColors.cardDecoration,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(AppStrings.errorLoadingMembers('$e')),
      data: (rows) {
        final entries = _parseMembers(rows);
        return Stack(
          children: [
            ChitMemberAssignCard(
              enrolledMembers: entries,
              searchCtrl: _searchCtrl,
              searchResults: _searchResults,
              isSearching: _searching,
              maxMembers: widget.totalMembers,
              onSearch: _search,
              onAdd: _assignMember,
              onRemove: _removeMember,
              onTicketChanged: _updateTicket,
              onAddNewMember: _openAddNewMember,
              onEditMember: _openEditMember,
            ),
            if (_saving)
              Positioned.fill(
                child: Container(
                  color: Colors.white38,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
