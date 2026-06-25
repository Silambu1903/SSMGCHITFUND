import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/auction_model.dart';
import '../../../core/services/auction_pdf_export_helper.dart';
import '../../../providers/auction_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/common/loading_states.dart';
import '../../widgets/common/confirm_delete_dialog.dart';
import '../../widgets/common/responsive_layout.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  bool _marking = false;
  bool _exporting = false;

  Future<void> _exportPdf(AuctionModel auction) async {
    setState(() => _exporting = true);
    try {
      await AuctionPdfExporter.exportAuctionReceipt(auction: auction);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.pdfExportFailed('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _deleteAuction() async {
    final ok = await showConfirmDelete(
      context,
      title: AppStrings.deleteAuctionTitle,
      message: AppStrings.deleteAuctionMessage,
    );
    if (!ok || !mounted) return;
    try {
      final chitId =
          ref.read(auctionDetailProvider(widget.auctionId)).valueOrNull?.chitId;
      await ref
          .read(auctionRepositoryProvider)
          .deleteAuction(widget.auctionId);
      refreshDashboardData(ref, chitId: chitId);
      if (mounted) context.go('/auctions');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppStrings.errorMessage('$e')),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _markPrizePaid() async {
    final noteCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.success),
            const SizedBox(width: 8),
            Text(AppStrings.markPrizeAsPaid),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.confirmPaidNote,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.noteOptional,
                hintText: AppStrings.noteHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check, size: 16),
            label: Text(AppStrings.confirmPaid),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _marking = true);
    try {
      final chitId =
          ref.read(auctionDetailProvider(widget.auctionId)).valueOrNull?.chitId;
      await ref
          .read(auctionRepositoryProvider)
          .markPrizePaid(widget.auctionId, note: noteCtrl.text);
      ref.invalidate(auctionDetailProvider(widget.auctionId));
      refreshDashboardData(ref, chitId: chitId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.prizeMarkedPaid),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppStrings.errorMessage('$e')),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final auction = ref.watch(auctionDetailProvider(widget.auctionId));
    final bids    = ref.watch(auctionBidsProvider(widget.auctionId));

    return auction.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorWidget2(message: e.toString()),
      data: (a) {
        if (a == null) {
          return ErrorWidget2(message: AppStrings.auctionNotFound);
        }
        return SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/auctions'),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                  Expanded(
                    child: Text(AppStrings.monthAuction(a.auctionMonth),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  if (_exporting)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _exportPdf(a),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: Text(AppStrings.exportPdf,
                          style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  const SizedBox(width: 8),
                  EditDeleteMenu(
                    onEdit: () =>
                        context.go('/auctions/${widget.auctionId}/edit'),
                    onDelete: _deleteAuction,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Prize Payment Status Banner ──────────────────────────────
              if (a.prizeAmount != null && a.prizeAmount! > 0)
                _PrizeStatusBanner(
                  prizePaid: a.prizePaid,
                  prizeAmount: a.prizeAmount!,
                  prizePaidAt: a.prizePaidAt,
                  prizePaidNote: a.prizePaidNote,
                  winnerName: a.winnerName,
                  onMarkPaid: _marking ? null : _markPrizePaid,
                  marking: _marking,
                ),

              const SizedBox(height: 16),

              // Calculation breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.auctionCalculation,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Responsive.isWide(context)
                        ? Column(
                            children: [
                              _CalcRow(
                                label: AppStrings.chitTotal,
                                value: CurrencyFormatter.format(a.chitAmount),
                              ),
                              _CalcRow(
                                label: AppStrings.discountAmount,
                                value: CurrencyFormatter.format(
                                    a.winningDiscountAmount ?? 0),
                                valueColor: AppColors.error,
                              ),
                              const Divider(),
                              _CalcRow(
                                label: AppStrings.prizeAmount,
                                value: CurrencyFormatter.format(
                                    a.prizeAmount ?? 0),
                                valueColor: AppColors.success,
                                bold: true,
                              ),
                              _CalcRow(
                                label: AppStrings.commissionAmount,
                                value: CurrencyFormatter.format(
                                    a.commissionAmount ?? 0),
                                valueColor: AppColors.warning,
                              ),
                              _CalcRow(
                                label: AppStrings.dividendPool,
                                value: CurrencyFormatter.format(
                                    a.dividendPool ?? 0),
                              ),
                              _CalcRow(
                                label: AppStrings.dividendPerMember,
                                value: CurrencyFormatter.format(
                                    a.dividendPerMember ?? 0),
                                valueColor: AppColors.primary,
                                bold: true,
                              ),
                              const Divider(),
                              _CalcRow(
                                label: AppStrings.nextMonthPayable,
                                value: CurrencyFormatter.format(
                                    a.nextMonthPayable ?? 0),
                                valueColor: AppColors.primary,
                                bold: true,
                              ),
                            ],
                          )
                        : ResponsiveLabelGrid(
                            mobileColumns: 2,
                            wideColumns: 3,
                            items: [
                              (
                                label: AppStrings.chitTotal,
                                value: CurrencyFormatter.format(a.chitAmount),
                                color: null,
                              ),
                              (
                                label: AppStrings.discountAmount,
                                value: CurrencyFormatter.format(
                                    a.winningDiscountAmount ?? 0),
                                color: AppColors.error,
                              ),
                              (
                                label: AppStrings.prizeAmount,
                                value: CurrencyFormatter.format(
                                    a.prizeAmount ?? 0),
                                color: AppColors.success,
                              ),
                              (
                                label: AppStrings.commissionAmount,
                                value: CurrencyFormatter.format(
                                    a.commissionAmount ?? 0),
                                color: AppColors.warning,
                              ),
                              (
                                label: AppStrings.dividendPool,
                                value: CurrencyFormatter.format(
                                    a.dividendPool ?? 0),
                                color: null,
                              ),
                              (
                                label: AppStrings.dividendPerMember,
                                value: CurrencyFormatter.format(
                                    a.dividendPerMember ?? 0),
                                color: AppColors.primary,
                              ),
                              (
                                label: AppStrings.nextMonthPayable,
                                value: CurrencyFormatter.format(
                                    a.nextMonthPayable ?? 0),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                    if (a.winnerName != null) ...[
                      const Divider(),
                      _CalcRow(
                        label: AppStrings.winnerName,
                        value: '${a.winnerName} (${a.winnerMemberNo})',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bids table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Text(AppStrings.auctionBids,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    const Divider(height: 1),
                    bids.when(
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
                              child: Text(AppStrings.noBidsRecorded,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                            ),
                          );
                        }
                        return Column(
                          children: list
                              .map((b) => ListTile(
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.chipAmber,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.gavel,
                                          size: 14,
                                          color: AppColors.warning),
                                    ),
                                    title: Text(b.memberId,
                                        style: const TextStyle(
                                            fontSize: 13)),
                                    subtitle: Text(
                                        AppStrings.bidDiscountPercent(
                                            b.bidPercent),
                                        style: const TextStyle(
                                            fontSize: 11)),
                                    trailing: Text(
                                      CurrencyFormatter.format(
                                          b.bidAmount),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Prize Status Banner ───────────────────────────────────────────────────────

class _PrizeStatusBanner extends StatelessWidget {
  final bool prizePaid;
  final double prizeAmount;
  final DateTime? prizePaidAt;
  final String? prizePaidNote;
  final String? winnerName;
  final VoidCallback? onMarkPaid;
  final bool marking;

  const _PrizeStatusBanner({
    required this.prizePaid,
    required this.prizeAmount,
    this.prizePaidAt,
    this.prizePaidNote,
    this.winnerName,
    this.onMarkPaid,
    required this.marking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: prizePaid ? AppColors.chipGreen : AppColors.chipAmber,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: prizePaid
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: prizePaid
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              prizePaid ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: prizePaid ? AppColors.success : AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prizePaid
                      ? '${AppStrings.prizePaidLabel} ✓'
                      : AppStrings.prizePendingPayment,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: prizePaid ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(prizeAmount) +
                      (winnerName != null ? '  →  $winnerName' : ''),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (prizePaid && prizePaidAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.prizePaidOn(
                      DateFormatter.toDisplay(prizePaidAt),
                      note: prizePaidNote != null && prizePaidNote!.isNotEmpty
                          ? prizePaidNote
                          : null,
                    ),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (!prizePaid)
            marking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : ElevatedButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check, size: 14),
                    label: Text(AppStrings.markPaid,
                        style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
        ],
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _CalcRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      bold ? FontWeight.w600 : FontWeight.w400,
                )),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
