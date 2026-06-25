import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/auction_model.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/auction_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/tamil_action_button.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/confirm_delete_dialog.dart';
import '../../widgets/chits/chit_members_section.dart';
import '../../widgets/chits/chit_member_payment_table.dart';
import 'chits_screen.dart' show auctionScheduleLabel;

class ChitDetailScreen extends ConsumerStatefulWidget {
  final String chitId;
  const ChitDetailScreen({super.key, required this.chitId});

  @override
  ConsumerState<ChitDetailScreen> createState() => _ChitDetailScreenState();
}

class _ChitDetailScreenState extends ConsumerState<ChitDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(auctionsProvider(widget.chitId));
    });
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showConfirmDelete(
      context,
      title: AppStrings.deleteChitTitle,
      message: AppStrings.deleteChitMessage,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(chitRepositoryProvider).deleteChit(widget.chitId);
      ref.invalidate(chitsProvider(null));
      refreshDashboardData(ref, chitId: widget.chitId);
      if (context.mounted) context.go('/chits');
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
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final chitId = widget.chitId;
    final chit = ref.watch(chitDetailProvider(chitId));
    final auctions = ref.watch(auctionsProvider(chitId));
    final members = ref.watch(chitMembersProvider(chitId));

    return chit.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorWidget2(message: e.toString()),
      data: (c) {
        if (c == null) return ErrorWidget2(message: AppStrings.chitNotFound);
        final scheduleLabel =
            auctionScheduleLabel(c.auctionDay, c.auctionTime);
        final enrolledCount = members.valueOrNull?.length ?? 0;
        return SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.go('/chits'),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                c.chitName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _ActiveBadge(status: c.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                scheduleLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  EditDeleteMenu(
                    onEdit: () => context.go('/chits/$chitId/edit'),
                    onDelete: () => _delete(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _ChitStatsGrid(
                enrolledCount: enrolledCount,
                chit: c,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: AppColors.cardDecoration,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        Responsive.isMobile(context) ? 14 : 20,
                        16,
                        Responsive.isMobile(context) ? 14 : 20,
                        14,
                      ),
                      child: Responsive.isMobile(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.border),
                                      ),
                                      child: const Icon(Icons.gavel_outlined,
                                          size: 18, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.recentAuctions,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            AppStrings.recentAuctionsSubtitle,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TamilActionButton(
                                        label: AppStrings.newAuction,
                                        icon: Icons.gavel_rounded,
                                        expand: true,
                                        onPressed: () => context.go(
                                            '/auctions/new?chit=$chitId'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TamilOutlineButton(
                                        label: AppStrings.viewAll,
                                        expand: true,
                                        onPressed: () =>
                                            context.go('/auctions'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(Icons.gavel_outlined,
                                      size: 18, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.recentAuctions,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        AppStrings.recentAuctionsSubtitle,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TamilActionButton(
                                  label: AppStrings.newAuction,
                                  icon: Icons.gavel_rounded,
                                  onPressed: () =>
                                      context.go('/auctions/new?chit=$chitId'),
                                ),
                                const SizedBox(width: 8),
                                TamilOutlineButton(
                                  label: AppStrings.viewAll,
                                  onPressed: () => context.go('/auctions'),
                                ),
                              ],
                            ),
                    ),
                    const Divider(height: 1),
                    auctions.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('$e'),
                      ),
                      data: (list) {
                        if (list.isEmpty) {
                          return Padding(
                            padding: Responsive.pagePadding(context),
                            child: Center(
                              child: Text(
                                AppStrings.noAuctionsYet,
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: list
                              .map((a) => _AuctionRow(auction: a))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ChitMemberPaymentTable(
                chitId: chitId,
                totalMembers: c.totalMembers,
                durationMonths: c.durationMonths,
                baseInstallment: c.monthlyInstallment,
              ),

              const SizedBox(height: 20),
              ChitMembersSection(
                chitId: chitId,
                totalMembers: c.totalMembers,
                startDate: c.startDate,
              ),

            ],
          ),
        );
      },
    );
  }
}

String _compactBidTime(int day, String? time) {
  final suffix = day == 1
      ? 'st'
      : day == 2
          ? 'nd'
          : day == 3
              ? 'rd'
              : 'th';
  if (time == null || time.isEmpty) return '$day$suffix';
  final parts = time.split(':');
  if (parts.length < 2) return '$day$suffix';
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final ampm = hour < 12 ? 'AM' : 'PM';
  final h12 = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
  final timeStr = '$h12:${minute.toString().padLeft(2, '0')} $ampm';
  return '$day$suffix @ $timeStr';
}

class _ChitStatsGrid extends StatelessWidget {
  final int enrolledCount;
  final dynamic chit;
  const _ChitStatsGrid({required this.enrolledCount, required this.chit});

  @override
  Widget build(BuildContext context) {
    final boxes = [
      _StatBox(
        label: AppStrings.totalAmount,
        tamilLabel: AppStrings.chitValue,
        value: CurrencyFormatter.format(chit.chitValue),
        icon: Icons.account_balance_wallet_outlined,
        iconBg: AppColors.statCard1,
        iconColor: AppColors.primary,
      ),
      _StatBox(
        label: AppStrings.installment,
        tamilLabel: AppStrings.baseInstallment,
        value: CurrencyFormatter.format(chit.monthlyInstallment),
        icon: Icons.calendar_month_outlined,
        iconBg: AppColors.statCard2,
        iconColor: AppColors.success,
      ),
      _StatBox(
        label: AppStrings.bidSchedule,
        tamilLabel: AppStrings.biddingDate,
        value: _compactBidTime(
            chit.auctionDay as int, chit.auctionTime as String?),
        subValue: AppStrings.everyMonth,
        icon: Icons.schedule_outlined,
        iconBg: AppColors.statCard1,
        iconColor: AppColors.primary,
      ),
      _StatBox(
        label: AppStrings.commission,
        tamilLabel: AppStrings.commissionFee,
        value:
            '${chit.foremanCommissionPercent.toInt()}% (${CurrencyFormatter.compact(chit.commissionAmount)})',
        icon: Icons.percent,
        iconBg: AppColors.chipRed,
        iconColor: AppColors.error,
      ),
      _StatBox(
        label: AppStrings.membersLabel,
        tamilLabel: AppStrings.members,
        value: '$enrolledCount / ${chit.totalMembers}',
        icon: Icons.people_alt_outlined,
        iconBg: AppColors.statCard1,
        iconColor: AppColors.primary,
      ),
      _StatBox(
        label: AppStrings.durationLabel,
        tamilLabel: AppStrings.duration,
        value: '${chit.durationMonths} ${AppStrings.monthsShort}',
        icon: Icons.timer_outlined,
        iconBg: AppColors.surfaceVariant,
        iconColor: AppColors.textMuted,
      ),
    ];

    if (Responsive.isMobile(context)) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: boxes,
      );
    }

    if (!Responsive.isWide(context)) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: boxes,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < boxes.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: boxes[i]),
          ],
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final String status;
  const _ActiveBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final chip = StatusChip.forStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: chip.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppStrings.chitStatusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: chip.textColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String tamilLabel;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _StatBox({
    required this.label,
    required this.tamilLabel,
    required this.value,
    this.subValue,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: compact ? 24 : 28,
                height: compact ? 24 : 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: compact ? 12 : 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.isTamil ? tamilLabel : label,
                  style: TextStyle(
                    fontSize: compact ? 9 : 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuctionRow extends StatelessWidget {
  final AuctionModel auction;
  const _AuctionRow({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/auctions/${auction.id}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.chipBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    AppStrings.monthLabel(auction.auctionMonth),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.winnerName ?? AppStrings.noWinnerYet,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${DateFormatter.toDisplay(DateFormatter.fromApi(auction.auctionDate))} • ${AppStrings.discountLabel} ${auction.winningDiscountPercent?.toInt() ?? 0}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(auction.prizeAmount ?? 0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    auction.prizePaid
                        ? AppStrings.prizePaid
                        : AppStrings.prize,
                    style: TextStyle(
                      fontSize: 10,
                      color: auction.prizePaid
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
