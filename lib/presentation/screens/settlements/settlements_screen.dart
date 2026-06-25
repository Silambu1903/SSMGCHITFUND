import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/common/responsive_layout.dart';
import '../../../data/repositories/settlement_repository.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';
import '../../../providers/language_provider.dart';

final _settlementsProvider =
    FutureProvider<List<dynamic>>((ref) async {
  return SettlementRepository().getSettlements();
});

class SettlementsScreen extends ConsumerWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final settlements = ref.watch(_settlementsProvider);

    return Padding(
      padding: Responsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: AppStrings.settlement,
            subtitle: AppStrings.finalChitSettlementsSubtitle,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: settlements.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorWidget2(message: e.toString()),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    message: AppStrings.noSettlementsYet,
                    icon: Icons.handshake_outlined,
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _SettlementCard(s: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final dynamic s;
  const _SettlementCard({required this.s});

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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.chipGreen,
                child: const Icon(Icons.handshake_outlined,
                    color: AppColors.success, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.memberName ?? '-',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${s.chitName ?? ''} • ${DateFormatter.toDisplay(DateFormatter.fromApi(s.settlementDate))}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(s.settlementAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _SettleStat(
                label: AppStrings.totalPaid,
                value: CurrencyFormatter.compact(s.totalPaid),
              ),
              _SettleStat(
                label: AppStrings.prizeReceived,
                value: CurrencyFormatter.compact(s.prizeReceived),
                color: AppColors.success,
              ),
              _SettleStat(
                label: AppStrings.dividendReceived,
                value: CurrencyFormatter.compact(s.dividendReceived),
                color: AppColors.primary,
              ),
              _SettleStat(
                label: AppStrings.outstanding,
                value: CurrencyFormatter.compact(s.outstandingAmount),
                color: s.outstandingAmount > 0
                    ? AppColors.error
                    : AppColors.success,
              ),
            ],
          ),
          if (s.remarks != null) ...[
            const SizedBox(height: 8),
            Text(
              s.remarks!,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _SettleStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SettleStat({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
