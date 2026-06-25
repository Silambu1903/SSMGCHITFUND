import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/common/responsive_layout.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';

class ChitsScreen extends ConsumerStatefulWidget {
  const ChitsScreen({super.key});
  @override
  ConsumerState<ChitsScreen> createState() => _ChitsScreenState();
}

class _ChitsScreenState extends ConsumerState<ChitsScreen> {
  int? _dayFilter; // null = All, 10, or 20

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final chits = ref.watch(chitsProvider(null));

    return Padding(
      padding: Responsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: AppStrings.chitFunds,
            subtitle: AppStrings.manageChitsSubtitle,
            action: ElevatedButton.icon(
              onPressed: () => context.go('/chits/create'),
              icon: const Icon(Icons.add, size: 16),
              label: Text(AppStrings.createNewChit),
            ),
          ),
          const SizedBox(height: 14),
          // Filter chips
          AuctionDayFilter(
            selected: _dayFilter,
            onChanged: (v) => setState(() => _dayFilter = v),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: chits.when(
              loading: () => ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const CardShimmer(),
              ),
              error: (e, _) => ErrorWidget2(message: e.toString()),
              data: (list) {
                final filtered = _dayFilter == null
                    ? list
                    : list.where((c) => c.auctionDay == _dayFilter).toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    message: _dayFilter == null
                        ? AppStrings.noChitsYet
                        : AppStrings.noChitsOnDay(_dayFilter!),
                    icon: Icons.savings_outlined,
                    actionLabel: AppStrings.createNewChit,
                    onAction: () => context.go('/chits/create'),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ChitCard(chit: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared filter chip bar: All | 10th | 20th
class AuctionDayFilter extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;
  const AuctionDayFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(label: AppStrings.filterAll, active: selected == null, onTap: () => onChanged(null)),
        const SizedBox(width: 8),
        _Chip(
          label: AppStrings.filterNth(10),
          icon: Icons.calendar_today,
          active: selected == 10,
          onTap: () => onChanged(selected == 10 ? null : 10),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: AppStrings.filterNth(20),
          icon: Icons.calendar_today,
          active: selected == 20,
          onTap: () => onChanged(selected == 20 ? null : 20),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12,
                  color: active ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String auctionScheduleLabel(int auctionDay, String? auctionTime) =>
    AppStrings.auctionSchedule(auctionDay, auctionTime);

class _ChitCard extends StatelessWidget {
  final dynamic chit;
  const _ChitCard({required this.chit});

  String _bidMonthLabel(String startDate) {
    final dt = DateTime.tryParse(startDate);
    if (dt == null) return startDate;
    return AppStrings.monthYear(dt);
  }

  @override
  Widget build(BuildContext context) {
    final scheduleLabel =
        auctionScheduleLabel(chit.auctionDay as int, chit.auctionTime as String?);
    final bidMonth = _bidMonthLabel(chit.startDate as String);

    return GestureDetector(
      onTap: () => context.go('/chits/${chit.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name + status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chit.chitName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        chit.chitCode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip.forStatus(chit.status),
              ],
            ),
            const SizedBox(height: 10),

            // Bid schedule + bid start month pills
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoPill(
                  icon: Icons.gavel,
                  label: scheduleLabel,
                  bgColor: AppColors.chipBlue,
                  textColor: AppColors.primary,
                ),
                _InfoPill(
                  icon: Icons.calendar_month,
                  label: AppStrings.bidsFromMonth(bidMonth),
                  bgColor: const Color(0xFFF0FFF4),
                  textColor: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stats
            ResponsiveLabelGrid(
              mobileColumns: 2,
              wideColumns: 4,
              items: [
                (
                  label: AppStrings.chitValue,
                  value: CurrencyFormatter.compact(chit.chitValue),
                  color: AppColors.primary,
                ),
                (
                  label: AppStrings.membersCountLabel,
                  value: '${chit.totalMembers}',
                  color: AppColors.textPrimary,
                ),
                (
                  label: AppStrings.baseInstallment,
                  value: CurrencyFormatter.compact(chit.monthlyInstallment),
                  color: AppColors.success,
                ),
                (
                  label: AppStrings.durationLabel,
                  value: AppStrings.durationValue(chit.durationMonths as int),
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                const Icon(Icons.percent,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  AppStrings.commissionPercentLabel(
                      chit.foremanCommissionPercent.toInt()),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people_outline,
                    size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  AppStrings.durationScheme(chit.durationMonths as int),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

