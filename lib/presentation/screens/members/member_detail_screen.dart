import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/member_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/confirm_delete_dialog.dart';

class MemberDetailScreen extends ConsumerWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDelete(
      context,
      title: AppStrings.deleteMemberTitle,
      message: AppStrings.deleteMemberMessage,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(memberRepositoryProvider).deleteMember(memberId);
      ref.invalidate(membersProvider);
      if (context.mounted) context.go('/members');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppStrings.errorMessage('$e')),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final member = ref.watch(memberDetailProvider(memberId));
    final guarantors = ref.watch(guarantorsProvider(memberId));
    final outstanding = ref.watch(memberOutstandingProvider(memberId));
    final isWide = MediaQuery.of(context).size.width > 900;

    return member.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorWidget2(message: e.toString()),
      data: (m) {
        if (m == null) return ErrorWidget2(message: AppStrings.memberNotFound);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title + actions
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/members'),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        StatusChip.forStatus(m.status),
                      ],
                    ),
                  ),
                  EditDeleteMenu(
                    onEdit: () => context.go('/members/$memberId/edit'),
                    onDelete: () => _delete(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _ProfileCard(member: m)),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _OutstandingCard(outstanding: outstanding),
                          const SizedBox(height: 16),
                          _GuarantorsCard(guarantors: guarantors),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _ProfileCard(member: m),
                    const SizedBox(height: 16),
                    _OutstandingCard(outstanding: outstanding),
                    const SizedBox(height: 16),
                    _GuarantorsCard(guarantors: guarantors),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final dynamic member;
  const _ProfileCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.sidebarBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    member.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  member.memberNo,
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  label: AppStrings.mobile,
                  value: member.mobile,
                  icon: Icons.phone_outlined,
                ),
                _InfoRow(
                  label: AppStrings.email,
                  value: member.email ?? '-',
                  icon: Icons.email_outlined,
                ),
                _InfoRow(
                  label: AppStrings.fatherName,
                  value: member.fatherName ?? '-',
                  icon: Icons.person_outline,
                ),
                _InfoRow(
                  label: AppStrings.occupation,
                  value: member.occupation ?? '-',
                  icon: Icons.work_outline,
                ),
                _InfoRow(
                  label: AppStrings.income,
                  value: member.monthlyIncome != null
                      ? CurrencyFormatter.format(member.monthlyIncome!)
                      : '-',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _InfoRow(
                  label: AppStrings.aadhaar,
                  value: member.aadhaarNumber ?? '-',
                  icon: Icons.badge_outlined,
                ),
                _InfoRow(
                  label: AppStrings.pan,
                  value: member.panNumber ?? '-',
                  icon: Icons.credit_card_outlined,
                ),
                _InfoRow(
                  label: AppStrings.joiningDate,
                  value: DateFormatter.toDisplay(
                      DateFormatter.fromApi(member.joiningDate)),
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> outstanding;
  const _OutstandingCard({required this.outstanding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              AppStrings.pendingAmount,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          outstanding.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(AppStrings.errorMessage('$e'))),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      AppStrings.noOutstandingBalance,
                      style: const TextStyle(color: AppColors.success),
                    ),
                  ),
                );
              }
              return Column(
                children: list.map((o) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o['chit_name'] ?? '-',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _MetricTile(
                              label: AppStrings.dueAmount,
                              value: CurrencyFormatter.compact(
                                  (o['total_due'] as num?)?.toDouble() ?? 0),
                            ),
                            _MetricTile(
                              label: AppStrings.paid,
                              value: CurrencyFormatter.compact(
                                  (o['total_paid'] as num?)?.toDouble() ?? 0),
                              color: AppColors.success,
                            ),
                            _MetricTile(
                              label: AppStrings.balanceAmount,
                              value: CurrencyFormatter.compact(
                                  (o['total_balance'] as num?)?.toDouble() ?? 0),
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricTile({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuarantorsCard extends StatelessWidget {
  final AsyncValue<List<dynamic>> guarantors;
  const _GuarantorsCard({required this.guarantors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.guarantor,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 14),
                  label: Text(AppStrings.addGuarantor,
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          guarantors.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppStrings.errorMessage('$e')),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      AppStrings.noGuarantorsAdded,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return Column(
                children: list.map((g) {
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.chipGreen,
                      child: Icon(Icons.person_outline,
                          color: AppColors.success, size: 16),
                    ),
                    title: Text(g.name,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      '${g.relationship} • ${g.mobile}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
