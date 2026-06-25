import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../providers/chit_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/language_provider.dart';
import '../../widgets/chits/chit_member_assign_card.dart';
import '../../widgets/chits/chit_members_section.dart';

class CreateChitScreen extends ConsumerStatefulWidget {
  final String? editId; // non-null → edit mode
  const CreateChitScreen({super.key, this.editId});

  @override
  ConsumerState<CreateChitScreen> createState() => _CreateChitScreenState();
}

class _CreateChitScreenState extends ConsumerState<CreateChitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _auctionDay = 10;
  late TimeOfDay _auctionTime;
  final _days = [10, 20];
  bool _prefilling = false;

  bool get _isEdit => widget.editId != null;

  bool _nameManuallyEdited = false;
  bool _codeManuallyEdited = false;

  // Optional member enrollment (with assignable ticket numbers)
  final List<EnrolledMemberEntry> _enrolledMembers = [];
  final _memberSearchCtrl = TextEditingController();
  List<MemberModel> _memberSearchResults = [];
  bool _searchingMembers = false;

  static const _monthAbbr = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  String _autoName(double amount, int members, DateTime date, {int? durationMonths}) {
    String amtLabel;
    if (amount >= 100000) {
      final lakhs = amount / 100000;
      amtLabel = AppStrings.lakhLabel(lakhs);
    } else if (amount >= 1000) {
      final thousands = amount / 1000;
      amtLabel = AppStrings.thousandLabel(thousands);
    } else {
      amtLabel = '₹${amount.toInt()}';
    }
    return '${AppStrings.brandFullName} $amtLabel ${AppStrings.schemeWord}';
  }

  String _autoCode(int auctionDay, DateTime startDate, TimeOfDay time) {
    final suffix = auctionDay == 1
        ? 'st'
        : auctionDay == 2
            ? 'nd'
            : auctionDay == 3
                ? 'rd'
                : 'th';
    final mon =
        '${_monthAbbr[startDate.month - 1]}${startDate.year.toString().substring(2)}';
    final hour12 = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final ampm = time.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = '$hour12:${time.minute.toString().padLeft(2, '0')}$ampm';
    return '${AppStrings.brandPrefix}-${auctionDay}$suffix-$mon-$timeStr';
  }

  void _syncAutoCode() {
    if (_codeManuallyEdited) return;
    final generated = _autoCode(_auctionDay, _startDate, _auctionTime);
    if (_codeCtrl.text != generated) {
      _codeCtrl.text = generated;
      _codeCtrl.selection =
          TextSelection.collapsed(offset: generated.length);
    }
  }

  void _syncAutoName(ChitFormState form) {
    if (_nameManuallyEdited) return;
    final generated = _autoName(form.chitAmount, form.totalMembers, _startDate,
        durationMonths: form.durationMonths);
    if (_nameCtrl.text != generated) {
      _nameCtrl.text = generated;
      _nameCtrl.selection =
          TextSelection.collapsed(offset: generated.length);
    }
  }

  @override
  void initState() {
    super.initState();
    _auctionTime = const TimeOfDay(hour: 10, minute: 0);

    if (_isEdit) {
      // Pre-fill later after fetch; keep auto-sync disabled until then
      _nameManuallyEdited = true;
      _codeManuallyEdited = true;
      _prefillChit();
    } else {
      final form = ref.read(chitFormStateProvider);
      _nameCtrl.text = _autoName(form.chitAmount, form.totalMembers, _startDate,
          durationMonths: form.durationMonths);
      _codeCtrl.text = _autoCode(_auctionDay, _startDate, _auctionTime);
    }

    _nameCtrl.addListener(() {
      if (!_isEdit) {
        final f = ref.read(chitFormStateProvider);
        final expected = _autoName(f.chitAmount, f.totalMembers, _startDate,
            durationMonths: f.durationMonths);
        if (_nameCtrl.text != expected) _nameManuallyEdited = true;
      }
    });
    _codeCtrl.addListener(() {
      if (!_isEdit &&
          _codeCtrl.text != _autoCode(_auctionDay, _startDate, _auctionTime)) {
        _codeManuallyEdited = true;
      }
    });
  }

  Future<void> _prefillChit() async {
    setState(() => _prefilling = true);
    try {
      final chit = await ref
          .read(chitRepositoryProvider)
          .getChitById(widget.editId!);
      if (chit != null && mounted) {
        _nameCtrl.text = chit.chitName;
        _codeCtrl.text = chit.chitCode;
        _startDate = DateTime.tryParse(chit.startDate) ?? DateTime.now();
        _auctionDay = chit.auctionDay;
        if (chit.auctionTime != null) {
          final parts = chit.auctionTime!.split(':');
          if (parts.length >= 2) {
            _auctionTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 10,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
        // Update ChitFormState notifier with existing values
        ref.read(chitFormStateProvider.notifier)
          ..updateChitAmount(chit.chitValue)
          ..updateTotalMembers(chit.totalMembers)
          ..updateDuration(chit.durationMonths)
          ..updateCommission(chit.foremanCommissionPercent);
      }
    } finally {
      if (mounted) setState(() => _prefilling = false);
    }
  }

  Future<void> _searchMembers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _memberSearchResults = []);
      return;
    }
    setState(() => _searchingMembers = true);
    try {
      final results = await MemberRepository().searchMembers(query.trim());
      setState(() => _memberSearchResults = results
          .where((m) => !_enrolledMembers.any((e) => e.member.id == m.id))
          .toList());
    } finally {
      setState(() => _searchingMembers = false);
    }
  }

  Future<void> _addMember(MemberModel m) async {
    final form = ref.read(chitFormStateProvider);
    if (_enrolledMembers.length >= form.totalMembers) return;
    final ticketNo = suggestNextTicketNo(
      _enrolledMembers.map((e) => e.ticketNo),
      form.totalMembers,
    );
    if (!mounted) return;
    setState(() {
      _enrolledMembers
          .add(EnrolledMemberEntry(member: m, ticketNo: ticketNo));
      _memberSearchResults.removeWhere((r) => r.id == m.id);
      _memberSearchCtrl.clear();
      _memberSearchResults = [];
    });
  }

  void _removeMember(String id) {
    setState(() => _enrolledMembers.removeWhere((e) => e.member.id == id));
  }

  void _updateTicket(String memberId, int ticketNo) {
    setState(() {
      final idx =
          _enrolledMembers.indexWhere((e) => e.member.id == memberId);
      if (idx >= 0) {
        _enrolledMembers[idx].ticketNo = ticketNo;
      }
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _memberSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final form = ref.read(chitFormStateProvider);
    final auctionTimeStr =
        '${_auctionTime.hour.toString().padLeft(2, '0')}:${_auctionTime.minute.toString().padLeft(2, '0')}:00';

    if (_isEdit) {
      // ── Update mode ──────────────────────────────────────────────────────
      try {
        await ref.read(chitRepositoryProvider).updateChit(widget.editId!, {
          'chit_name': _nameCtrl.text.trim(),
          'chit_code': _codeCtrl.text.trim(),
          'chit_value': form.chitAmount,
          'total_members': form.totalMembers,
          'duration_months': form.durationMonths,
          'monthly_installment': form.monthlyInstallment,
          'foreman_commission_percent': form.commissionPercent,
          'auction_day': _auctionDay,
          'auction_time': auctionTimeStr,
          'start_date': _startDate.toIso8601String().substring(0, 10),
        });
        ref.invalidate(chitDetailProvider(widget.editId!));
        ref.invalidate(chitsProvider(null));
        refreshDashboardData(ref, chitId: widget.editId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.chitUpdatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/chits/${widget.editId}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.errorMessage('$e')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      return;
    }

    // ── Create mode ──────────────────────────────────────────────────────
    if (_enrolledMembers.isNotEmpty) {
      final ticketErr =
          validateTicketAssignments(_enrolledMembers, form.totalMembers);
      if (ticketErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketErr),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final data = {
      'branch_id': 'a1000000-0000-0000-0000-000000000001',
      'chit_code': _codeCtrl.text.trim().isNotEmpty
          ? _codeCtrl.text.trim()
          : '${AppStrings.brandPrefix}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'chit_name': _nameCtrl.text.trim(),
      'chit_value': form.chitAmount,
      'total_members': form.totalMembers,
      'duration_months': form.durationMonths,
      'monthly_installment': form.monthlyInstallment,
      'foreman_commission_percent': form.commissionPercent,
      'auction_day': _auctionDay,
      'auction_time': auctionTimeStr,
      'start_date': _startDate.toIso8601String().substring(0, 10),
      'status': 'active',
    };
    final chit = await ref.read(chitCreateProvider.notifier).create(data);
    if (chit != null && mounted) {
      if (_enrolledMembers.isNotEmpty) {
        final repo = ref.read(chitRepositoryProvider);
        for (final entry in _enrolledMembers) {
          try {
            await repo.enrollMember({
              'chit_id': chit.id,
              'member_id': entry.member.id,
              'ticket_no': entry.ticketNo,
              'joining_date': _startDate.toIso8601String().substring(0, 10),
              'status': 'active',
            });
          } catch (_) {}
        }
      }
      ref.invalidate(chitsProvider(null));
      ref.invalidate(chitDetailProvider(chit.id));
      refreshDashboardData(ref, chitId: chit.id);
      if (_enrolledMembers.isNotEmpty) {
        ref.invalidate(chitMembersProvider(chit.id));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _enrolledMembers.isEmpty
                ? AppStrings.chitCreated(chit.chitName)
                : AppStrings.chitCreatedWithMembers(
                    chit.chitName, _enrolledMembers.length),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/chits/${chit.id}');
    }
  }

  Widget _buildMembersPanel(ChitFormState form) {
    if (_isEdit && widget.editId != null) {
      return ChitMembersSection(
        chitId: widget.editId!,
        totalMembers: form.totalMembers,
        startDate: _startDate.toIso8601String().substring(0, 10),
      );
    }
    return ChitMemberAssignCard(
      enrolledMembers: _enrolledMembers,
      searchCtrl: _memberSearchCtrl,
      searchResults: _memberSearchResults,
      isSearching: _searchingMembers,
      maxMembers: form.totalMembers,
      onSearch: _searchMembers,
      onAdd: _addMember,
      onRemove: _removeMember,
      onTicketChanged: _updateTicket,
      onAddNewMember: () async {
        await context.push('/members/add');
        if (mounted) _searchMembers(_memberSearchCtrl.text);
      },
      onEditMember: (id) => context.push('/members/$id/edit'),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final form = ref.watch(chitFormStateProvider);
    final createState = ref.watch(chitCreateProvider);
    final isWide = MediaQuery.of(context).size.width > 900;

    if (!_isEdit) {
      _syncAutoName(form);
      _syncAutoCode();
    }

    if (_prefilling) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _BasicDetailsCard(
                          form: form,
                          nameCtrl: _nameCtrl,
                          codeCtrl: _codeCtrl,
                          startDate: _startDate,
                          onStartDateChanged: (d) {
                            setState(() => _startDate = d);
                            if (!_nameManuallyEdited) {
                              _nameCtrl.text = _autoName(
                                  form.chitAmount, form.totalMembers, d,
                                  durationMonths: form.durationMonths);
                            }
                          },
                          onResetName: () => setState(() {
                            _nameManuallyEdited = false;
                            _nameCtrl.text = _autoName(
                                form.chitAmount, form.totalMembers, _startDate,
                                durationMonths: form.durationMonths);
                          }),
                          isNameAutoGenerated: !_nameManuallyEdited,
                          onResetCode: () => setState(() {
                            _codeManuallyEdited = false;
                            _codeCtrl.text = _autoCode(_auctionDay, _startDate, _auctionTime);
                          }),
                          isCodeAutoGenerated: !_codeManuallyEdited,
                        ),
                        const SizedBox(height: 16),
                        _FinancialRulesCard(
                          form: form,
                          auctionDay: _auctionDay,
                          auctionTime: _auctionTime,
                          days: _days,
                          onAuctionDayChanged: (d) => setState(() {
                            _auctionDay = d;
                            if (!_codeManuallyEdited) {
                              _codeCtrl.text = _autoCode(d, _startDate, _auctionTime);
                            }
                          }),
                          onAuctionTimeChanged: (t) => setState(() {
                            _auctionTime = t;
                            if (!_codeManuallyEdited) {
                              _codeCtrl.text = _autoCode(_auctionDay, _startDate, t);
                            }
                          }),
                        ),
                        const SizedBox(height: 16),
                        _buildMembersPanel(form),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/chits'),
                              child: Text(AppStrings.cancel),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: createState.isLoading ? null : _submit,
                              icon: createState.isLoading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.add_circle_outline, size: 16),
                              label: Text(_isEdit
                                  ? AppStrings.updateChit
                                  : AppStrings.createChit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 300,
                    child: _LiveSummaryPanel(form: form),
                  ),
                ],
              )
            : Column(
                children: [
                  _BasicDetailsCard(
                    form: form,
                    nameCtrl: _nameCtrl,
                    codeCtrl: _codeCtrl,
                    startDate: _startDate,
                    onStartDateChanged: (d) {
                      setState(() => _startDate = d);
                      if (!_nameManuallyEdited) {
                        _nameCtrl.text = _autoName(
                            form.chitAmount, form.totalMembers, d,
                            durationMonths: form.durationMonths);
                      }
                    },
                    onResetName: () => setState(() {
                      _nameManuallyEdited = false;
                      _nameCtrl.text = _autoName(
                          form.chitAmount, form.totalMembers, _startDate,
                          durationMonths: form.durationMonths);
                    }),
                    isNameAutoGenerated: !_nameManuallyEdited,
                    onResetCode: () => setState(() {
                      _codeManuallyEdited = false;
                      _codeCtrl.text = _autoCode(_auctionDay, _startDate, _auctionTime);
                    }),
                    isCodeAutoGenerated: !_codeManuallyEdited,
                  ),
                  const SizedBox(height: 16),
                  _LiveSummaryPanel(form: form),
                  const SizedBox(height: 16),
                  _FinancialRulesCard(
                    form: form,
                    auctionDay: _auctionDay,
                    auctionTime: _auctionTime,
                    days: _days,
                    onAuctionDayChanged: (d) => setState(() {
                      _auctionDay = d;
                      if (!_codeManuallyEdited) {
                        _codeCtrl.text = _autoCode(d, _startDate, _auctionTime);
                      }
                    }),
                    onAuctionTimeChanged: (t) => setState(() {
                      _auctionTime = t;
                      if (!_codeManuallyEdited) {
                        _codeCtrl.text = _autoCode(_auctionDay, _startDate, t);
                      }
                    }),
                  ),
                  const SizedBox(height: 16),
                  _buildMembersPanel(form),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go('/chits'),
                        child: Text(AppStrings.cancel),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: createState.isLoading ? null : _submit,
                        icon: Icon(_isEdit
                            ? Icons.save_outlined
                            : Icons.add_circle_outline,
                            size: 16),
                        label: Text(_isEdit
                            ? AppStrings.updateChit
                            : AppStrings.createChit),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Accent-border card helper ─────────────────────────────────────────────────
// Flutter forbids mixing non-uniform Border with borderRadius.
// We solve this using ClipRRect + an inner colored Container strip.
Widget _accentCard({
  required Color accentColor,
  required Widget child,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Basic Details Card ────────────────────────────────────────────────────────

class _BasicDetailsCard extends ConsumerWidget {
  final ChitFormState form;
  final TextEditingController nameCtrl;
  final TextEditingController codeCtrl;
  final DateTime startDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final VoidCallback onResetName;
  final bool isNameAutoGenerated;
  final VoidCallback onResetCode;
  final bool isCodeAutoGenerated;

  const _BasicDetailsCard({
    required this.form,
    required this.nameCtrl,
    required this.codeCtrl,
    required this.startDate,
    required this.onStartDateChanged,
    required this.onResetName,
    required this.isNameAutoGenerated,
    required this.onResetCode,
    required this.isCodeAutoGenerated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final notifier = ref.read(chitFormStateProvider.notifier);

    return _accentCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.basicDetails,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(AppStrings.basicDetails,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: AppStrings.chitAmount,
                  child: TextFormField(
                    initialValue: form.chitAmount.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(prefixText: '₹ '),
                    onChanged: (v) => notifier.updateChitAmount(
                        double.tryParse(v) ?? form.chitAmount),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? AppStrings.required : null,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _LabeledField(
                  label: AppStrings.totalMembersLabel,
                  child: TextFormField(
                    initialValue: form.totalMembers.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.people_alt_outlined, size: 16),
                    ),
                    onChanged: (v) => notifier.updateTotalMembers(
                        int.tryParse(v) ?? form.totalMembers),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? AppStrings.required : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: AppStrings.chitName,
                  child: TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.label_outline, size: 16),
                      suffixIcon: isNameAutoGenerated
                          ? Tooltip(
                              message: AppStrings.autoGeneratedHint,
                              child: const Icon(Icons.auto_awesome,
                                  size: 16, color: AppColors.primary),
                            )
                          : IconButton(
                              tooltip: AppStrings.resetAutoName,
                              icon: const Icon(Icons.refresh,
                                  size: 16, color: AppColors.textSecondary),
                              onPressed: onResetName,
                            ),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? AppStrings.required : null,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _LabeledField(
                  label: AppStrings.chitCode,
                  child: TextFormField(
                    controller: codeCtrl,
                    decoration: InputDecoration(
                      hintText: AppStrings.chitCodeExampleHint,
                      prefixIcon: const Icon(Icons.gavel_outlined, size: 16),
                      suffixIcon: isCodeAutoGenerated
                          ? Tooltip(
                              message: AppStrings.autoCodeHint,
                              child: const Icon(Icons.schedule,
                                  size: 16, color: AppColors.success),
                            )
                          : IconButton(
                              tooltip: AppStrings.resetAutoCode,
                              icon: const Icon(Icons.refresh,
                                  size: 16, color: AppColors.textSecondary),
                              onPressed: onResetCode,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: AppStrings.startDate,
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2040),
                      );
                      if (d != null) onStartDateChanged(d);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _LabeledField(
                  label: AppStrings.duration,
                  child: TextFormField(
                    initialValue: form.durationMonths.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.access_time_outlined, size: 16),
                    ),
                    onChanged: (v) => notifier.updateDuration(
                        int.tryParse(v) ?? form.durationMonths),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Financial Rules Card ──────────────────────────────────────────────────────

class _FinancialRulesCard extends ConsumerWidget {
  final ChitFormState form;
  final int auctionDay;
  final TimeOfDay auctionTime;
  final List<int> days;
  final ValueChanged<int> onAuctionDayChanged;
  final ValueChanged<TimeOfDay> onAuctionTimeChanged;

  const _FinancialRulesCard({
    required this.form,
    required this.auctionDay,
    required this.auctionTime,
    required this.days,
    required this.onAuctionDayChanged,
    required this.onAuctionTimeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageProvider);
    final notifier = ref.read(chitFormStateProvider.notifier);

    return _accentCard(
      accentColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.chipGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.success, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.financialRules,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(AppStrings.financialRules,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: AppStrings.biddingDate,
                              child: DropdownButtonFormField<int>(
                                value: auctionDay,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.event_outlined, size: 16),
                                ),
                                items: days
                                    .map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(AppStrings.everyNth(d)),
                                        ))
                                    .toList(),
                                onChanged: (v) => v != null ? onAuctionDayChanged(v) : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _LabeledField(
                              label: AppStrings.bidStartTime,
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: auctionTime,
                                    builder: (ctx, child) => MediaQuery(
                                      data: MediaQuery.of(ctx).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) onAuctionTimeChanged(picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColors.surface,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 16, color: AppColors.success),
                                      const SizedBox(width: 8),
                                      Text(
                                        () {
                                          final h = auctionTime.hour == 0
                                              ? 12
                                              : auctionTime.hour > 12
                                                  ? auctionTime.hour - 12
                                                  : auctionTime.hour;
                                          final ampm = auctionTime.period ==
                                                  DayPeriod.am
                                              ? 'AM'
                                              : 'PM';
                                          return '$h:${auctionTime.minute.toString().padLeft(2, '0')} $ampm';
                                        }(),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 18,
                                          color: AppColors.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _LabeledField(
                        label: AppStrings.commissionPercent,
                        child: TextFormField(
                          initialValue: form.commissionPercent.toInt().toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(prefixText: '% '),
                          onChanged: (v) => notifier.updateCommission(
                              double.tryParse(v) ?? form.commissionPercent),
                        ),
                      ),
        ],
      ),
    );
  }
}

// ── Live Summary Panel ────────────────────────────────────────────────────────

class _LiveSummaryPanel extends StatelessWidget {
  final ChitFormState form;
  const _LiveSummaryPanel({required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.liveSummary,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _SummaryRow(
                label: AppStrings.chitValue,
                value: CurrencyFormatter.format(form.chitAmount),
              ),
              _SummaryRow(
                label: AppStrings.membersLabel,
                value: form.totalMembers.toString(),
                valueBold: true,
              ),
              _SummaryRow(
                label: AppStrings.commissionFee,
                value: CurrencyFormatter.format(form.commissionAmount),
              ),
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.chipBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.baseInstallment,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${CurrencyFormatter.format(form.monthlyInstallment)}${AppStrings.perMonth}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.subjectToDividends,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.trustFactorInsight,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.trustFactorMessage(
                    form.durationMonths, form.totalMembers),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
              color: valueBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}
