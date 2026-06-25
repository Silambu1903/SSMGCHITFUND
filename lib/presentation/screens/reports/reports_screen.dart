import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/language_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final reports = [
      _ReportItem(
        title: AppStrings.dailyCollection,
        subtitle: AppStrings.dailyCollectionSubtitle,
        icon: Icons.today_outlined,
        color: AppColors.primary,
        bg: AppColors.chipBlue,
      ),
      _ReportItem(
        title: AppStrings.monthlyReport,
        subtitle: AppStrings.monthlyReportSubtitle,
        icon: Icons.calendar_month_outlined,
        color: AppColors.success,
        bg: AppColors.chipGreen,
      ),
      _ReportItem(
        title: AppStrings.memberReport,
        subtitle: AppStrings.memberReportSubtitle,
        icon: Icons.people_alt_outlined,
        color: AppColors.primary,
        bg: AppColors.chipBlue,
      ),
      _ReportItem(
        title: AppStrings.auctionReport,
        subtitle: AppStrings.auctionReportSubtitle,
        icon: Icons.gavel_outlined,
        color: AppColors.warning,
        bg: AppColors.chipAmber,
      ),
      _ReportItem(
        title: AppStrings.outstandingReport,
        subtitle: AppStrings.outstandingReportSubtitle,
        icon: Icons.pending_actions_outlined,
        color: AppColors.error,
        bg: AppColors.chipRed,
      ),
      _ReportItem(
        title: AppStrings.incomeReport,
        subtitle: AppStrings.incomeReportSubtitle,
        icon: Icons.trending_up_outlined,
        color: AppColors.success,
        bg: AppColors.chipGreen,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.reports,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(AppStrings.reportsSubtitle,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              itemCount: reports.length,
              itemBuilder: (_, i) => _ReportCard(item: reports[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;
  const _ReportItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

class _ReportCard extends StatelessWidget {
  final _ReportItem item;
  const _ReportCard({required this.item});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              Row(
                children: [
                  _ActionBtn(
                    icon: Icons.download_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(width: 4),
                  _ActionBtn(
                    icon: Icons.print_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
