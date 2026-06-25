import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../providers/auction_provider.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/language_provider.dart';

/// Member × month payment matrix for one chit.
class ChitMemberPaymentTable extends ConsumerWidget {
  final String chitId;
  final int totalMembers;
  final int durationMonths;
  final double baseInstallment;

  const ChitMemberPaymentTable({
    super.key,
    required this.chitId,
    required this.totalMembers,
    required this.durationMonths,
    required this.baseInstallment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final membersAsync = ref.watch(chitMembersProvider(chitId));
    final paymentsAsync = ref.watch(chitPaymentsProvider(chitId));
    final auctionsAsync = ref.watch(auctionsProvider(chitId));

    final monthCount = durationMonths.clamp(1, 120);
    final memberSlots = totalMembers.clamp(1, 200);

    final memberRows = membersAsync.valueOrNull;
    final auctions = auctionsAsync.valueOrNull;
    final payments = paymentsAsync.valueOrNull;
    final enrolled =
        memberRows != null ? _parseMembers(memberRows) : <_MemberRow>[];
    final auctionsHeld = auctions != null
        ? {for (final a in auctions) a.auctionMonth: a}.length
        : null;

    final isLoading = membersAsync.isLoading ||
        auctionsAsync.isLoading ||
        paymentsAsync.isLoading;
    final loadError = membersAsync.hasError
        ? membersAsync.error
        : auctionsAsync.hasError
            ? auctionsAsync.error
            : paymentsAsync.hasError
                ? paymentsAsync.error
                : null;

    return Container(
      decoration: AppColors.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PaymentScheduleHeader(
            memberSlots: memberSlots,
            monthCount: monthCount,
            enrolledCount:
                memberRows != null ? enrolled.length : null,
            auctionsHeld: auctionsHeld,
            showExports: payments != null && enrolled.isNotEmpty,
            onExportPdf: () => _showExportMessage(context, 'PDF'),
            onExportExcel: () => _showExportMessage(context, 'Excel'),
          ),
          const Divider(height: 1),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (loadError != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.errorLoadingPaymentSchedule('$loadError'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (paymentsAsync.hasError) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(chitPaymentsProvider(chitId)),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(AppStrings.retry),
                    ),
                  ],
                ],
              ),
            )
          else if (memberRows != null &&
              auctions != null &&
              payments != null)
            Builder(
              builder: (context) {
                final enrolledList = _parseMembers(memberRows);
                if (enrolledList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        AppStrings.assignMembersForGrid,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                final members = _buildMemberSlots(enrolledList, memberSlots);
                final paymentMap = _buildPaymentMap(payments);
                final auctionByMonth = {
                  for (final a in auctions) a.auctionMonth: a,
                };
                final months = List.generate(monthCount, (i) => i + 1);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: _PaymentMatrixTable(
                    members: members,
                    months: months,
                    paymentMap: paymentMap,
                    auctionByMonth: auctionByMonth,
                    baseInstallment: baseInstallment,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showExportMessage(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type export coming soon')),
    );
  }

  List<_MemberRow> _parseMembers(List<Map<String, dynamic>> rows) {
    final list = rows.map((row) {
      final memberJson = row['members'] as Map<String, dynamic>?;
      final member = memberJson != null
          ? MemberModel.fromJson({...memberJson, 'branch_id': ''})
          : MemberModel(
              id: row['member_id'] as String,
              memberNo: '-',
              branchId: '',
              name: AppStrings.unknown,
              mobile: '',
              joiningDate: '',
            );
      return _MemberRow(
        member: member,
        ticketNo: (row['ticket_no'] as num?)?.toInt() ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.ticketNo.compareTo(b.ticketNo));
    return list;
  }

  List<_MemberRow> _buildMemberSlots(
    List<_MemberRow> enrolled,
    int slots,
  ) {
    final byTicket = {for (final e in enrolled) e.ticketNo: e};
    return List.generate(slots, (i) {
      final ticket = i + 1;
      return byTicket[ticket] ??
          _MemberRow(ticketNo: ticket, unassigned: true);
    });
  }

  Map<String, Map<int, PaymentModel>> _buildPaymentMap(
      List<PaymentModel> payments) {
    final map = <String, Map<int, PaymentModel>>{};
    for (final p in payments) {
      map.putIfAbsent(p.memberId, () => {})[p.paymentMonth] = p;
    }
    return map;
  }
}

class _PaymentScheduleHeader extends StatelessWidget {
  final int memberSlots;
  final int monthCount;
  final int? enrolledCount;
  final int? auctionsHeld;
  final bool showExports;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;

  const _PaymentScheduleHeader({
    required this.memberSlots,
    required this.monthCount,
    required this.enrolledCount,
    required this.auctionsHeld,
    required this.showExports,
    required this.onExportPdf,
    required this.onExportExcel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;

        final titleBlock = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.paymentScheduleTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.paymentScheduleSubtitle(
                        memberSlots, monthCount),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final badges = enrolledCount != null && auctionsHeld != null
            ? Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _HeaderBadge(
                    text: AppStrings.membersBadge(
                        enrolledCount!, memberSlots),
                    bg: AppColors.chipBlue,
                    color: AppColors.primary,
                  ),
                  _HeaderBadge(
                    text: AppStrings.auctionsHeldBadge(
                        auctionsHeld!, monthCount),
                    bg: AppColors.successLight,
                    color: AppColors.success,
                  ),
                ],
              )
            : const SizedBox.shrink();

        final exports = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExportButton(
              icon: Icons.picture_as_pdf_outlined,
              label: AppStrings.exportPdf,
              onPressed: showExports ? onExportPdf : null,
            ),
            const SizedBox(height: 6),
            _ExportButton(
              icon: Icons.table_chart_outlined,
              label: AppStrings.exportExcel,
              onPressed: showExports ? onExportExcel : null,
            ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: titleBlock),
                    Expanded(flex: 3, child: badges),
                    const SizedBox(width: 12),
                    SizedBox(width: 220, child: exports),
                  ],
                )
              else ...[
                titleBlock,
                if (enrolledCount != null) ...[
                  const SizedBox(height: 12),
                  badges,
                ],
                const SizedBox(height: 12),
                exports,
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _LegendDot(
                      color: AppColors.success,
                      label: AppStrings.paidLegend),
                  _LegendDot(
                      color: AppColors.error,
                      label: AppStrings.notPaidLegend),
                  _LegendDot(
                      color: AppColors.primary,
                      label: AppStrings.partialLegend),
                  _LegendDot(
                      color: AppColors.textMuted,
                      label: AppStrings.noAuctionLegend),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color color;

  const _HeaderBadge({
    required this.text,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ExportButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14, color: AppColors.textSecondary),
      label: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        alignment: Alignment.centerLeft,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _MemberRow {
  final MemberModel? member;
  final int ticketNo;
  final bool unassigned;

  const _MemberRow({
    this.member,
    required this.ticketNo,
    this.unassigned = false,
  });
}

class _MonthCellData {
  final double? dueAmount;
  final String statusLabel;
  final bool showData;

  const _MonthCellData({
    this.dueAmount,
    this.statusLabel = '—',
    this.showData = false,
  });
}

_MonthCellData _resolveCell({
  required PaymentModel? payment,
  required AuctionModel? auction,
  required double baseInstallment,
  required bool unassignedMember,
}) {
  if (unassignedMember) return const _MonthCellData();

  if (payment != null) {
    final due = payment.dueAmount;
    final paid = payment.paidAmount;
    String label;
    if (paid >= due && due > 0) {
      label = AppStrings.paid;
    } else if (paid > 0) {
      label = AppStrings.partial;
    } else {
      label = AppStrings.notPaid;
    }
    return _MonthCellData(
      dueAmount: due,
      statusLabel: label,
      showData: true,
    );
  }

  if (auction != null) {
    final due = auction.nextMonthPayable ?? baseInstallment;
    return _MonthCellData(
      dueAmount: due,
      statusLabel: AppStrings.notPaid,
      showData: true,
    );
  }

  return const _MonthCellData();
}

class _PaymentMatrixTable extends StatelessWidget {
  final List<_MemberRow> members;
  final List<int> months;
  final Map<String, Map<int, PaymentModel>> paymentMap;
  final Map<int, AuctionModel> auctionByMonth;
  final double baseInstallment;

  const _PaymentMatrixTable({
    required this.members,
    required this.months,
    required this.paymentMap,
    required this.auctionByMonth,
    required this.baseInstallment,
  });

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const _rowH = 48.0;
  static const _headerH = 36.0;
  static const _ticketW = 36.0;
  static const _memberW = 148.0;
  static const _monthW = 76.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFixedColumns(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildMonthColumns(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedColumns() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: const BorderSide(color: AppColors.border),
          verticalInside: BorderSide.none,
          top: BorderSide.none,
          bottom: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
        ),
        columnWidths: const {
          0: FixedColumnWidth(_ticketW),
          1: FixedColumnWidth(_memberW),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: AppColors.surfaceVariant),
            children: [
              _headerCell('#', align: Alignment.center),
              _headerCell(AppStrings.member, align: Alignment.centerLeft),
            ],
          ),
          ...members.map(_fixedRow),
        ],
      ),
    );
  }

  TableRow _fixedRow(_MemberRow row) {
    return TableRow(
      decoration: row.unassigned
          ? BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.35),
            )
          : null,
      children: [
        _bodyCell(
          align: Alignment.center,
          child: Text(
            '${row.ticketNo}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: row.unassigned
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
        ),
        _bodyCell(
          align: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 10, right: 6),
          child: row.unassigned
              ?  Text(
                  AppStrings.unassigned,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.member!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      row.member!.memberNo,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMonthColumns() {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: const BorderSide(color: AppColors.border),
        verticalInside: const BorderSide(color: AppColors.border),
        top: BorderSide.none,
        bottom: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none,
      ),
      columnWidths: {
        for (int i = 0; i < months.length; i++)
          i: const FixedColumnWidth(_monthW),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surfaceVariant),
          children: months.map((m) => _headerCell(AppStrings.monthLabel(m))).toList(),
        ),
        ...members.map((row) {
          final memberPayments =
              row.member != null ? paymentMap[row.member!.id] ?? {} : {};
          return TableRow(
            decoration: row.unassigned
                ? BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.35),
                  )
                : null,
            children: months.map((m) {
              final cell = _resolveCell(
                payment: memberPayments[m],
                auction: auctionByMonth[m],
                baseInstallment: baseInstallment,
                unassignedMember: row.unassigned,
              );
              return _bodyCell(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _MonthPaymentCell(data: cell),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _headerCell(String text, {Alignment align = Alignment.center}) {
    return SizedBox(
      height: _headerH,
      child: Align(
        alignment: align,
        child: Padding(
          padding: align == Alignment.centerLeft
              ? const EdgeInsets.only(left: 10)
              : EdgeInsets.zero,
          child: Text(
            text,
            style: _headerStyle,
            textAlign: align == Alignment.centerLeft
                ? TextAlign.left
                : TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _bodyCell({
    required Widget child,
    Alignment align = Alignment.center,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return SizedBox(
      height: _rowH,
      child: Align(
        alignment: align,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _MonthPaymentCell extends StatelessWidget {
  final _MonthCellData data;
  const _MonthPaymentCell({required this.data});

  Color? get _textColor => switch (data.statusLabel) {
        'Paid' => AppColors.success,
        'Partial' => AppColors.primary,
        'Not Paid' => AppColors.error,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (!data.showData) {
      return const Text(
        '—',
        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      CurrencyFormatter.format(data.dueAmount ?? 0),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _textColor,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
