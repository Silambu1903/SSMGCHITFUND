import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/models/chit_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../core/services/auction_pdf_export_helper.dart';
import '../../../providers/auction_provider.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/payment_provider.dart';
import '../chits/chits_screen.dart' show auctionScheduleLabel, AuctionDayFilter;

// ─── Providers ────────────────────────────────────────────────────────────────

final _memberSearchProvider =
    FutureProvider.family<List<MemberModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  return MemberRepository().searchMembers(query.trim());
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class RecordAuctionScreen extends ConsumerStatefulWidget {
  final String? editId; // non-null → edit mode
  final String? initialChitId;
  const RecordAuctionScreen({super.key, this.editId, this.initialChitId});

  @override
  ConsumerState<RecordAuctionScreen> createState() =>
      _RecordAuctionScreenState();
}

class _RecordAuctionScreenState extends ConsumerState<RecordAuctionScreen> {
  ChitModel? _selectedChit;
  int? _chitDayFilter;
  int   _nextMonth    = 1;
  bool  _loadingMonth = false;
  bool  _prefilling   = false;

  bool get _isEdit => widget.editId != null;
  final _discountCtrl    = TextEditingController();
  final _collectionCtrl  = TextEditingController();
  final _dividendPoolCtrl = TextEditingController();
  final _monthCtrl       = TextEditingController();
  final _dateCtrl        = TextEditingController();
  final _searchCtrl      = TextEditingController();
  final _remarksCtrl     = TextEditingController();

  MemberModel? _winner;
  bool _saving = false;
  String? _error;
  String _searchQuery = '';

  /// True when the selected chit has already used all auction months
  bool get _chitCompleted =>
      _selectedChit != null &&
      _nextMonth > _selectedChit!.durationMonths;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtrl.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _monthCtrl.text = '1';
    _discountCtrl.addListener(_syncDividendPoolFromDiscount);
    _dividendPoolCtrl.addListener(() => setState(() {}));
    _collectionCtrl.addListener(() => setState(() {}));
    if (_isEdit) {
      _prefillAuction();
    } else if (widget.initialChitId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialChit());
    }
  }

  Future<void> _loadInitialChit() async {
    try {
      final chits = await ref.read(chitsProvider(null).future);
      final matched = chits.cast<ChitModel?>().firstWhere(
            (c) => c?.id == widget.initialChitId,
            orElse: () => null,
          );
      if (matched != null && mounted) await _onChitSelected(matched);
    } catch (_) {}
  }

  void _syncDividendPoolFromDiscount() {
    if (_discount <= 0) {
      _dividendPoolCtrl.clear();
    } else {
      final pool = (_discount - _commission).clamp(0, double.infinity);
      _dividendPoolCtrl.text = pool.toStringAsFixed(0);
    }
    setState(() {});
  }

  Future<void> _prefillAuction() async {
    setState(() => _prefilling = true);
    try {
      final a = await ref
          .read(auctionRepositoryProvider)
          .getAuctionById(widget.editId!);
      if (a == null || !mounted) return;

      // Populate month + date
      _monthCtrl.text = a.auctionMonth.toString();
      _nextMonth = a.auctionMonth;
      _dateCtrl.text = a.auctionDate;
      _discountCtrl.removeListener(_syncDividendPoolFromDiscount);
      _discountCtrl.text =
          (a.winningDiscountAmount ?? 0).toStringAsFixed(0);
      _dividendPoolCtrl.text =
          (a.dividendPool ?? 0).toStringAsFixed(0);
      _discountCtrl.addListener(_syncDividendPoolFromDiscount);
      _collectionCtrl.text = a.totalCollection.toStringAsFixed(0);
      _remarksCtrl.text = a.remarks ?? '';

      // Load chit list then match selected chit
      final chits = await ref.read(chitsProvider(null).future);
      final matchedChit = chits.cast<ChitModel?>().firstWhere(
            (c) => c?.id == a.chitId,
            orElse: () => null,
          );
      if (matchedChit != null) {
        setState(() => _selectedChit = matchedChit);
      }

      // Load winner member
      if (a.winningMemberId != null) {
        final m = await MemberRepository().getMemberById(a.winningMemberId!);
        if (m != null && mounted) setState(() => _winner = m);
      }
    } finally {
      if (mounted) setState(() => _prefilling = false);
    }
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _collectionCtrl.dispose();
    _dividendPoolCtrl.dispose();
    _monthCtrl.dispose();
    _dateCtrl.dispose();
    _searchCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _onChitSelected(ChitModel? c) async {
    setState(() {
      _selectedChit = c;
      _discountCtrl.clear();
      _dividendPoolCtrl.clear();
      _winner = null;
      _nextMonth = 1;
      _monthCtrl.text = '1';
      if (c != null) {
        final defaultCollection = c.monthlyInstallment * c.totalMembers;
        _collectionCtrl.text = defaultCollection.toInt().toString();
        _loadingMonth = true;
      } else {
        _collectionCtrl.clear();
      }
    });

    if (c == null) return;

    try {
      final next = await ref
          .read(auctionRepositoryProvider)
          .getNextAuctionMonth(c.id);
      if (mounted) {
        setState(() {
          _nextMonth = next;
          _monthCtrl.text = next.toString();
          _loadingMonth = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMonth = false);
    }
  }

  // ── Calculations ────────────────────────────────────────────────────────────
  double get _chitAmount    => _selectedChit?.chitValue ?? 0;
  double get _commissionPct => _selectedChit?.foremanCommissionPercent ?? 5;
  int    get _totalMembers  => _selectedChit?.totalMembers ?? 1;
  double get _installment   => _selectedChit?.monthlyInstallment ?? 0;

  double get _collection =>
      double.tryParse(_collectionCtrl.text.replaceAll(',', '')) ??
      (_installment * _totalMembers);

  double get _discount =>
      double.tryParse(_discountCtrl.text.replaceAll(',', '')) ?? 0;
  double get _prizeAmount =>
      (_chitAmount - _discount).clamp(0, double.infinity);
  double get _commission => (_chitAmount * _commissionPct) / 100;
  double get _dividendPool {
    final manual =
        double.tryParse(_dividendPoolCtrl.text.replaceAll(',', ''));
    if (manual != null) return manual.clamp(0, double.infinity);
    return (_discount - _commission).clamp(0, double.infinity);
  }
  double get _dividendPerMember =>
      _totalMembers > 0 ? _dividendPool / _totalMembers : 0;
  double get _nextPayable =>
      (_installment - _dividendPerMember).clamp(0, double.infinity);
  double get _discountPct =>
      _chitAmount > 0 ? (_discount / _chitAmount) * 100 : 0;

  // ── Save ────────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_selectedChit == null) {
      setState(() => _error = AppStrings.pleaseSelectChit);
      return;
    }
    if (_chitCompleted) {
      setState(() => _error =
          AppStrings.chitMonthsCompleted(_selectedChit!.durationMonths));
      return;
    }
    if (_discount <= 0) {
      setState(() => _error = AppStrings.enterValidDiscount);
      return;
    }
    if (_dividendPool <= 0) {
      setState(() => _error = AppStrings.enterValidDividend);
      return;
    }
    if (_winner == null) {
      setState(() => _error = AppStrings.selectWinnerMember);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final payload = {
        'chit_id': _selectedChit!.id,
        'auction_month': _nextMonth,
        'auction_date': _dateCtrl.text,
        'chit_amount': _chitAmount,
        'total_members': _totalMembers,
        'winning_member_id': _winner!.id,
        'winning_discount_percent': _discountPct,
        'winning_discount_amount': _discount,
        'prize_amount': _prizeAmount,
        'commission_amount': _commission,
        'dividend_pool': _dividendPool,
        'dividend_per_member': _dividendPerMember,
        'next_month_payable': _nextPayable,
        'total_collection': _collection,
        if (_remarksCtrl.text.isNotEmpty) 'remarks': _remarksCtrl.text,
      };

      AuctionModel? savedAuction;

      if (_isEdit) {
        await ref
            .read(auctionRepositoryProvider)
            .updateAuction(widget.editId!, payload);
        ref.invalidate(auctionDetailProvider(widget.editId!));
        savedAuction = await ref
            .read(auctionRepositoryProvider)
            .getAuctionById(widget.editId!);
      } else {
        final created = await ref
            .read(auctionRepositoryProvider)
            .createAuction(payload);
        savedAuction = created;
        // Generate due rows for all enrolled members after auction
        await ref.read(paymentRepositoryProvider).generateMonthlyDues(
              chitId: _selectedChit!.id,
              auctionId: created.id,
              paymentMonth: _nextMonth,
              dueAmount: _nextPayable,
            );
        ref.invalidate(chitPaymentsProvider(_selectedChit!.id));
      }

      ref.invalidate(nextAuctionMonthProvider(_selectedChit!.id));
      refreshDashboardData(ref, chitId: _selectedChit!.id);
      if (!mounted) return;

      final savedId = savedAuction?.id ?? widget.editId;

      final exportNow = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(AppStrings.exportAuctionReceipt),
            ],
          ),
          content: Text(
            AppStrings.auctionSavedExportPrompt,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.later),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.download, size: 16),
              label: Text(AppStrings.exportPdf),
            ),
          ],
        ),
      );

      if (exportNow == true && savedAuction != null && mounted) {
        try {
          await AuctionPdfExporter.exportAuctionReceipt(
            auction: savedAuction,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.pdfExportFailed('$e')),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      if (mounted) {
        context.go(
            savedId != null ? '/auctions/$savedId' : '/auctions');
      }
    } catch (e) {
      setState(() => _error = AppStrings.errorMessage('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final chitsAsync = ref.watch(chitsProvider(null));
    final isWide = Responsive.isWide(context);

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────────────────────────────────
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/auctions'),
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _isEdit
                          ? AppStrings.editAuctionEntry
                          : AppStrings.monthlyAuctionEntry,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(
                    _selectedChit != null
                        ? AppStrings.chitMonthLine(
                            _selectedChit!.chitName, _monthCtrl.text)
                        : AppStrings.selectChitToBegin,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.error))),
                ],
              ),
            ),

          // ── Main layout ──────────────────────────────────────────────────
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _leftPanel(chitsAsync)),
                    const SizedBox(width: 20),
                    SizedBox(
                        width: 280,
                        child: _LiveSummaryPanel(
                          chitAmount: _chitAmount,
                          discount: _discount,
                          prizeAmount: _prizeAmount,
                          commission: _commission,
                          dividendPool: _dividendPool,
                          dividendPerMember: _dividendPerMember,
                          nextPayable: _nextPayable,
                          discountPct: _discountPct,
                          commissionPct: _commissionPct,
                          saving: _saving,
                          isEdit: _isEdit,
                          onSave: _save,
                          onDiscard: () => context.go('/auctions'),
                        )),
                  ],
                )
              : Column(
                  children: [
                    _leftPanel(chitsAsync),
                    const SizedBox(height: 16),
                    _LiveSummaryPanel(
                      chitAmount: _chitAmount,
                      discount: _discount,
                      prizeAmount: _prizeAmount,
                      commission: _commission,
                      dividendPool: _dividendPool,
                      dividendPerMember: _dividendPerMember,
                      nextPayable: _nextPayable,
                      discountPct: _discountPct,
                      commissionPct: _commissionPct,
                      saving: _saving,
                      isEdit: _isEdit,
                      onSave: _save,
                      onDiscard: () => context.go('/auctions'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // ── Left panel (3 cards) ──────────────────────────────────────────────────
  Widget _leftPanel(AsyncValue<List<ChitModel>> chitsAsync) {
    return Column(
      children: [
        _AuctionDetailsCard(
          chitsAsync: chitsAsync,
          selectedChit: _selectedChit,
          chitDayFilter: _chitDayFilter,
          onChitDayFilterChanged: (v) => setState(() => _chitDayFilter = v),
          nextMonth: _nextMonth,
          loadingMonth: _loadingMonth,
          chitCompleted: _chitCompleted,
          monthCtrl: _monthCtrl,
          dateCtrl: _dateCtrl,
          onChitSelected: _onChitSelected,
          onDateTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _dateCtrl.text =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              });
            }
          },
        ),
        const SizedBox(height: 16),
        _FinancialLedgerCard(
          chitAmount: _chitAmount,
          discount: _discount,
          collection: _collection,
          prizeAmount: _prizeAmount,
          commission: _commission,
          dividendPool: _dividendPool,
          dividendPerMember: _dividendPerMember,
          nextPayable: _nextPayable,
          installment: _installment,
          totalMembers: _totalMembers,
          discountCtrl: _discountCtrl,
          collectionCtrl: _collectionCtrl,
          dividendPoolCtrl: _dividendPoolCtrl,
          commissionPct: _commissionPct,
        ),
        const SizedBox(height: 16),
        _WinnerDetailsCard(
          searchCtrl: _searchCtrl,
          selectedWinner: _winner,
          searchQuery: _searchQuery,
          remarksCtrl: _remarksCtrl,
          onQueryChanged: (q) => setState(() => _searchQuery = q),
          onWinnerSelected: (m) =>
              setState(() => _winner = m),
          onClearWinner: () => setState(() => _winner = null),
        ),
      ],
    );
  }
}

// ─── Auction Details Card ─────────────────────────────────────────────────────

class _AuctionDetailsCard extends StatelessWidget {
  final AsyncValue<List<ChitModel>> chitsAsync;
  final ChitModel? selectedChit;
  final int? chitDayFilter;
  final ValueChanged<int?> onChitDayFilterChanged;
  final int nextMonth;
  final bool loadingMonth;
  final bool chitCompleted;
  final TextEditingController monthCtrl;
  final TextEditingController dateCtrl;
  final ValueChanged<ChitModel?> onChitSelected;
  final VoidCallback onDateTap;

  const _AuctionDetailsCard({
    required this.chitsAsync,
    required this.selectedChit,
    required this.chitDayFilter,
    required this.onChitDayFilterChanged,
    required this.nextMonth,
    required this.loadingMonth,
    required this.chitCompleted,
    required this.monthCtrl,
    required this.dateCtrl,
    required this.onChitSelected,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalMonths = selectedChit?.durationMonths ?? 0;

    return _Card(
      icon: Icons.info_outline,
      title: AppStrings.auctionDetailsTitle,
      child: Column(
        children: [
          // Day filter strip
          Align(
            alignment: Alignment.centerLeft,
            child: AuctionDayFilter(
              selected: chitDayFilter,
              onChanged: (v) {
                onChitDayFilterChanged(v);
                if (v != null &&
                    selectedChit != null &&
                    selectedChit!.auctionDay != v) {
                  onChitSelected(null);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          // Chit selector — use id as value (ChitModel instances differ by reference)
          chitsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text(AppStrings.errorLoadingChits('$e'),
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
            data: (list) {
              final filtered = list
                  .where((c) =>
                      c.status == 'active' &&
                      (chitDayFilter == null ||
                          c.auctionDay == chitDayFilter))
                  .toList();
              // Keep current selection visible in edit mode even if filtered out
              if (selectedChit != null &&
                  !filtered.any((c) => c.id == selectedChit!.id)) {
                filtered.insert(0, selectedChit!);
              }
              final selectedId = selectedChit != null &&
                      filtered.any((c) => c.id == selectedChit!.id)
                  ? selectedChit!.id
                  : null;

              return DropdownButtonFormField<String>(
                value: selectedId,
                decoration: _inputDecor(AppStrings.chitScheme),
                isExpanded: true,
                hint: Text(AppStrings.selectChitScheme),
                items: filtered
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            '${c.chitName}  (${c.chitCode})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: filtered.isEmpty
                    ? null
                    : (id) {
                        if (id == null) {
                          onChitSelected(null);
                          return;
                        }
                        final chit =
                            filtered.firstWhere((c) => c.id == id);
                        onChitSelected(chit);
                      },
              );
            },
          ),
          if (selectedChit != null) ...[
            const SizedBox(height: 8),
            // Schedule pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chipBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel, size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      auctionScheduleLabel(
                          selectedChit!.auctionDay, selectedChit!.auctionTime),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Chit completed warning
            if (chitCompleted)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.chipGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 15, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.chitMonthsCompleted(totalMonths),
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              // Auto-filled month — read-only with progress indicator
              Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    AbsorbPointer(
                      child: TextFormField(
                        controller: monthCtrl,
                        readOnly: true,
                        decoration: _inputDecor(AppStrings.auctionMonthLabel)
                            .copyWith(
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          suffixIcon: loadingMonth
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : totalMonths > 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        '/ $totalMonths',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary),
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onDateTap,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: dateCtrl,
                      decoration: _inputDecor(AppStrings.dateLabel).copyWith(
                        suffixIcon: const Icon(Icons.calendar_today,
                            size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Month progress bar
          if (selectedChit != null && totalMonths > 0 && !loadingMonth) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ((nextMonth - 1) / totalMonths).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  chitCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              chitCompleted
                  ? AppStrings.allAuctionsRecorded(totalMonths)
                  : AppStrings.monthProgress(
                      nextMonth, totalMonths, totalMonths - nextMonth + 1),
              style: TextStyle(
                fontSize: 10,
                color: chitCompleted
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Financial Ledger Card ────────────────────────────────────────────────────

class _FinancialLedgerCard extends StatelessWidget {
  final double chitAmount;
  final double discount;
  final double collection;
  final double prizeAmount;
  final double commission;
  final double dividendPool;
  final double dividendPerMember;
  final double nextPayable;
  final double installment;
  final int totalMembers;
  final double commissionPct;
  final TextEditingController discountCtrl;
  final TextEditingController collectionCtrl;
  final TextEditingController dividendPoolCtrl;

  const _FinancialLedgerCard({
    required this.chitAmount,
    required this.discount,
    required this.collection,
    required this.prizeAmount,
    required this.commission,
    required this.dividendPool,
    required this.dividendPerMember,
    required this.nextPayable,
    required this.installment,
    required this.totalMembers,
    required this.commissionPct,
    required this.discountCtrl,
    required this.collectionCtrl,
    required this.dividendPoolCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      icon: Icons.account_balance_wallet_outlined,
      title: AppStrings.financialLedger,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: AppStrings.chitTotal,
                  value: CurrencyFormatter.format(chitAmount),
                  prefix: '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  ctrl: discountCtrl,
                  label: AppStrings.discountAmount,
                  prefix: '',
                  hint: AppStrings.enterBidDiscount,
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: AppStrings.prizeAmount,
                  value: CurrencyFormatter.format(prizeAmount),
                  prefix: '',
                  valueColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  ctrl: collectionCtrl,
                  label: AppStrings.collectionThisMonth,
                  hint: AppStrings.totalCollectedThisMonth,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: AppStrings.commissionPercentLabel(
                      commissionPct.toInt()),
                  value: CurrencyFormatter.format(commission),
                  prefix: '',
                  valueColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  ctrl: dividendPoolCtrl,
                  label: AppStrings.dividendPool,
                  hint: AppStrings.discountMinusCommission,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: AppStrings.dividendPerMember,
                  value: CurrencyFormatter.format(dividendPerMember),
                  prefix: '',
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadonlyField(
                  label: AppStrings.nextMonthPayable,
                  value: CurrencyFormatter.format(nextPayable),
                  prefix: '',
                  valueColor: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Winner Details Card ──────────────────────────────────────────────────────

class _WinnerDetailsCard extends ConsumerWidget {
  final TextEditingController searchCtrl;
  final TextEditingController remarksCtrl;
  final MemberModel? selectedWinner;
  final String searchQuery;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MemberModel> onWinnerSelected;
  final VoidCallback onClearWinner;

  const _WinnerDetailsCard({
    required this.searchCtrl,
    required this.remarksCtrl,
    required this.selectedWinner,
    required this.searchQuery,
    required this.onQueryChanged,
    required this.onWinnerSelected,
    required this.onClearWinner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final results = ref.watch(_memberSearchProvider(searchQuery));

    return _Card(
      icon: Icons.emoji_events_outlined,
      title: AppStrings.winnerDrawTitle,
      child: Column(
        children: [
          if (selectedWinner == null) ...[
            TextField(
              controller: searchCtrl,
              decoration: _inputDecor(AppStrings.searchMemberHint)
                  .copyWith(
                prefixIcon:
                    const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              ),
              onChanged: onQueryChanged,
            ),
            const SizedBox(height: 8),
            results.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const SizedBox.shrink(),
              data: (list) => list.isEmpty && searchQuery.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(AppStrings.noMembersFound,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    )
                  : Column(
                      children: list
                          .take(5)
                          .map((m) => ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.chipBlue,
                                  child: Text(
                                    m.name.isNotEmpty
                                        ? m.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                title: Text(m.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    '${m.memberNo}  •  ${m.mobile}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                onTap: () {
                                  searchCtrl.clear();
                                  onQueryChanged('');
                                  onWinnerSelected(m);
                                },
                              ))
                          .toList(),
                    ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.success.withOpacity(.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.success,
                    child: Text(
                      selectedWinner!.name.isNotEmpty
                          ? selectedWinner!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(selectedWinner!.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(AppStrings.activeWinner,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        Text(
                          '${selectedWinner!.memberNo}  •  ${selectedWinner!.mobile}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onClearWinner,
                    child: Text(AppStrings.change,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: remarksCtrl,
            decoration: _inputDecor(AppStrings.remarksOptional),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Live Summary Panel ───────────────────────────────────────────────────────

class _LiveSummaryPanel extends StatelessWidget {
  final double chitAmount;
  final double discount;
  final double prizeAmount;
  final double commission;
  final double dividendPool;
  final double dividendPerMember;
  final double nextPayable;
  final double discountPct;
  final double commissionPct;
  final bool saving;
  final bool isEdit;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const _LiveSummaryPanel({
    required this.chitAmount,
    required this.discount,
    required this.prizeAmount,
    required this.commission,
    required this.dividendPool,
    required this.dividendPerMember,
    required this.nextPayable,
    required this.discountPct,
    required this.commissionPct,
    required this.saving,
    this.isEdit = false,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Prize amount hero card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A56DB), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.liveSummary.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.2)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync, size: 10, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(AppStrings.live,
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(AppStrings.finalPrizeAmountLabel,
                  style: const TextStyle(fontSize: 10, color: Colors.white60)),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(prizeAmount),
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              _SummaryRow(
                label: AppStrings.discountLabel,
                value:
                    '${discountPct.toStringAsFixed(1)}%  (${CurrencyFormatter.compact(discount)})',
                valueColor: Colors.white,
              ),
              _SummaryRow(
                label: AppStrings.dividendPerMemberShort,
                value: CurrencyFormatter.format(dividendPerMember),
                valueColor: const Color(0xFF86EFAC),
              ),
              _SummaryRow(
                label: AppStrings.commissionPercentLabel(
                    commissionPct.toInt()),
                value: CurrencyFormatter.compact(commission),
                valueColor: const Color(0xFFFCD34D),
              ),
              _SummaryRow(
                label: AppStrings.nextMonthDue,
                value: CurrencyFormatter.format(nextPayable),
                valueColor: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(saving
                ? AppStrings.saving
                : isEdit
                    ? AppStrings.updateAuction
                    : AppStrings.saveAuctionResult),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDiscard,
            icon:
                const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            label: Text(AppStrings.discardEntry,
                style: const TextStyle(color: AppColors.textSecondary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _SummaryRow(
      {required this.label,
      required this.value,
      this.valueColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.white60)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Card({
    required this.icon,
    required this.title,
    required this.child,
  });

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
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  final String prefix;
  final Color? valueColor;

  const _ReadonlyField({
    required this.label,
    required this.value,
    this.prefix = '',
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '$prefix$value',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String prefix;
  final String hint;
  final bool isHighlighted;

  const _InputField({
    required this.ctrl,
    required this.label,
    this.prefix = '',
    this.hint = '',
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isHighlighted
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: isHighlighted
                    ? FontWeight.w600
                    : FontWeight.w400),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
          ],
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            filled: true,
            fillColor: isHighlighted
                ? AppColors.chipBlue
                : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecor(String label) => InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
