import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SectionCard extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderLeftColor;

  const SectionCard({
    super.key,
    this.header,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderLeftColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: borderLeftColor != null
              ? BorderSide(color: borderLeftColor!, width: 4)
              : BorderSide.none,
          top: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.bg,
    required this.textColor,
  });

  factory StatusChip.paid() => StatusChip(
        label: AppStrings.paid,
        bg: AppColors.successLight,
        textColor: AppColors.success,
      );

  factory StatusChip.pending() => StatusChip(
        label: AppStrings.pending,
        bg: AppColors.warningLight,
        textColor: AppColors.warning,
      );

  factory StatusChip.overdue() => StatusChip(
        label: AppStrings.overdue,
        bg: AppColors.errorLight,
        textColor: AppColors.error,
      );

  factory StatusChip.partial() => StatusChip(
        label: AppStrings.partial,
        bg: AppColors.chipBlue,
        textColor: AppColors.primary,
      );

  factory StatusChip.active() => StatusChip(
        label: AppStrings.active,
        bg: AppColors.successLight,
        textColor: AppColors.success,
      );

  factory StatusChip.completed() => const StatusChip(
        label: '', // replaced in forStatus
        bg: Color(0xFFEDE9FE),
        textColor: Color(0xFF7C3AED),
      );

  factory StatusChip.forStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return StatusChip.paid();
      case 'overdue':
        return StatusChip.overdue();
      case 'partial':
        return StatusChip.partial();
      case 'active':
        return StatusChip.active();
      case 'completed':
        return StatusChip(
          label: AppStrings.statusCompleted,
          bg: const Color(0xFFEDE9FE),
          textColor: const Color(0xFF7C3AED),
        );
      default:
        return StatusChip.pending();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
