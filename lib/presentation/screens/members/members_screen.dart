import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/confirm_delete_dialog.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  bool _deletingAll = false;

  Future<void> _deleteAllMembers() async {
    final ok = await showConfirmDelete(
      context,
      title: AppStrings.deleteAllMembersTitle,
      message: AppStrings.deleteAllMembersMessage,
    );
    if (!ok || !mounted) return;

    setState(() => _deletingAll = true);
    try {
      await ref.read(memberRepositoryProvider).deleteAllMembers();
      ref.invalidate(membersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.allMembersDeleted),
            backgroundColor: AppColors.success,
          ),
        );
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
    } finally {
      if (mounted) setState(() => _deletingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final members = ref.watch(membersProvider(null));
    ref.watch(memberSearchQueryProvider);

    final mobile = Responsive.isMobile(context);
    final searchField = TextField(
      decoration: InputDecoration(
        hintText: AppStrings.search,
        prefixIcon: const Icon(Icons.search, size: 18),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onChanged: (v) =>
          ref.read(memberSearchQueryProvider.notifier).state = v,
    );
    final deleteButton = OutlinedButton.icon(
      onPressed: _deletingAll ? null : _deleteAllMembers,
      icon: _deletingAll
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_sweep_outlined, size: 16),
      label: Text(AppStrings.deleteAll),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
      ),
    );
    final addButton = ElevatedButton.icon(
      onPressed: () => context.go('/members/add'),
      icon: const Icon(Icons.person_add_outlined, size: 16),
      label: Text(AppStrings.newMember),
    );

    return Padding(
      padding: Responsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mobile) ...[
            searchField,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: deleteButton),
                const SizedBox(width: 8),
                Expanded(child: addButton),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 12),
                deleteButton,
                const SizedBox(width: 8),
                addButton,
              ],
            ),
          const SizedBox(height: 20),

          // Members list
          Expanded(
            child: members.when(
              loading: () => ListView.separated(
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => const _MemberCardShimmer(),
              ),
              error: (e, _) => ErrorWidget2(
                message: e.toString(),
                onRetry: () => ref.invalidate(membersProvider),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    message: AppStrings.noData,
                    icon: Icons.people_alt_outlined,
                    actionLabel: AppStrings.newMember,
                    onAction: () => context.go('/members/add'),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MemberCard(member: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final dynamic member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/members/${member.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.chipBlue,
              child: Text(
                member.name.substring(0, 1),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip.forStatus(member.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        member.memberNo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.phone_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        member.mobile,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (member.occupation != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      member.occupation!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Joined date + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormatter.toDisplay(
                    DateFormatter.fromApi(member.joiningDate),
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberCardShimmer extends StatelessWidget {
  const _MemberCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const LoadingShimmer(height: 44, width: 44, radius: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingShimmer(height: 14, width: 140),
                const SizedBox(height: 8),
                const LoadingShimmer(height: 11, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
