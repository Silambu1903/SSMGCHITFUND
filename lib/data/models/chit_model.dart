class ChitModel {
  final String id;
  final String branchId;
  final String chitCode;
  final String chitName;
  final double chitValue;
  final int totalMembers;
  final int durationMonths;
  final double monthlyInstallment;
  final double foremanCommissionPercent;
  final double penaltyAmount;
  final int graceDays;
  final int auctionDay;
  /// Stored as "HH:MM:SS" (PostgreSQL TIME), e.g. "11:00:00"
  final String? auctionTime;
  final String startDate;
  final String? endDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChitModel({
    required this.id,
    required this.branchId,
    required this.chitCode,
    required this.chitName,
    required this.chitValue,
    required this.totalMembers,
    required this.durationMonths,
    required this.monthlyInstallment,
    this.foremanCommissionPercent = 5.0,
    this.penaltyAmount = 0.0,
    this.graceDays = 5,
    this.auctionDay = 1,
    this.auctionTime,
    required this.startDate,
    this.endDate,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  double get commissionAmount =>
      (chitValue * foremanCommissionPercent) / 100;

  factory ChitModel.fromJson(Map<String, dynamic> json) => ChitModel(
        id: json['id'] as String,
        branchId: json['branch_id'] as String? ?? '',
        chitCode: json['chit_code'] as String,
        chitName: json['chit_name'] as String,
        chitValue: (json['chit_value'] as num).toDouble(),
        totalMembers: (json['total_members'] as num).toInt(),
        durationMonths: (json['duration_months'] as num).toInt(),
        monthlyInstallment:
            (json['monthly_installment'] as num).toDouble(),
        foremanCommissionPercent:
            (json['foreman_commission_percent'] as num?)?.toDouble() ?? 5.0,
        penaltyAmount:
            (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
        graceDays: (json['grace_days'] as num?)?.toInt() ?? 5,
        auctionDay: (json['auction_day'] as num?)?.toInt() ?? 1,
        auctionTime: json['auction_time'] as String?,
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String?,
        status: json['status'] as String? ?? 'active',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'branch_id': branchId,
        'chit_code': chitCode,
        'chit_name': chitName,
        'chit_value': chitValue,
        'total_members': totalMembers,
        'duration_months': durationMonths,
        'monthly_installment': monthlyInstallment,
        'foreman_commission_percent': foremanCommissionPercent,
        'penalty_amount': penaltyAmount,
        'grace_days': graceDays,
        'auction_day': auctionDay,
        if (auctionTime != null) 'auction_time': auctionTime,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChitModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
