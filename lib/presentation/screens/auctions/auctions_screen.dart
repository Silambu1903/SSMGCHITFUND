import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/auction_model.dart';
import '../../../providers/auction_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';
import '../chits/chits_screen.dart' show auctionScheduleLabel, AuctionDayFilter;

class AuctionsScreen extends ConsumerStatefulWidget {
  const AuctionsScreen({super.key});
  @override
  ConsumerState<AuctionsScreen> createState() => _AuctionsScreenState();
}

class _AuctionsScreenState extends ConsumerState<AuctionsScreen> {
  int? _dayFilter;

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final auctions = ref.watch(auctionsProvider(null));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.auctions,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(AppStrings.auctionCalculation,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/auctions/new'),
                icon: const Icon(Icons.gavel, size: 16),
                label: Text(AppStrings.newEntry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AuctionDayFilter(
            selected: _dayFilter,
            onChanged: (v) => setState(() => _dayFilter = v),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: auctions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorWidget2(message: e.toString()),
              data: (list) {
                final filtered = _dayFilter == null
                    ? list
                    : list
                        .where((a) => a.auctionDay == _dayFilter)
                        .toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    message: _dayFilter == null
                        ? AppStrings.noAuctionsFound
                        : AppStrings.noAuctionsOnDay(_dayFilter!),
                    icon: Icons.gavel_outlined,
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _AuctionCard(auction: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionCard extends ConsumerWidget {
  final AuctionModel auction;
  const _AuctionCard({required this.auction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedLabel = auctionScheduleLabel(
      auction.auctionDay ?? 1,
      auction.auctionTime,
    );
    return GestureDetector(
      onTap: () => context.go('/auctions/${auction.id}'),
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.chipBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.monthShort,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.primary)),
                        Text(
                          '${auction.auctionMonth}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auction.chitName ?? AppStrings.chitAuctionFallback,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Auction schedule pill
                      Row(
                        children: [
                          const Icon(Icons.gavel,
                              size: 11, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            schedLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today_outlined,
                              size: 11, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            DateFormatter.toDisplay(
                                DateFormatter.fromApi(auction.auctionDate)),
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
                auction.winnerName != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(AppStrings.statusCompleted,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            )),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipAmber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(AppStrings.pending,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Calculation grid
            Row(
              children: [
                _CalcTile(
                  label: AppStrings.chitTotal,
                  value: CurrencyFormatter.compact(auction.chitAmount),
                ),
                _CalcTile(
                  label: AppStrings.discountAmount,
                  value: CurrencyFormatter.compact(
                      auction.winningDiscountAmount ?? 0),
                ),
                _CalcTile(
                  label: AppStrings.prizeAmount,
                  value: CurrencyFormatter.compact(auction.prizeAmount ?? 0),
                  color: AppColors.success,
                ),
                _CalcTile(
                  label: AppStrings.commissionAmount,
                  value: CurrencyFormatter.compact(
                      auction.commissionAmount ?? 0),
                ),
                _CalcTile(
                  label: AppStrings.dividendPerMember,
                  value: CurrencyFormatter.compact(
                      auction.dividendPerMember ?? 0),
                  color: AppColors.primary,
                ),
                _CalcTile(
                  label: AppStrings.nextMonthPayable,
                  value: CurrencyFormatter.compact(
                      auction.nextMonthPayable ?? 0),
                ),
              ],
            ),

            if (auction.winnerName != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${AppStrings.winnerName}: ${auction.winnerName} (${auction.winnerMemberNo})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Prize paid status badge + quick action
                  if (auction.prizePaid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.chipGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 11, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(AppStrings.prizePaidLabel,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => context.go('/auctions/${auction.id}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipAmber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pending_outlined,
                                size: 11, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(AppStrings.payWinner,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalcTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CalcTile({
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
