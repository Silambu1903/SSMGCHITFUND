class SettlementModel {
  final String id;
  final String memberId;
  final String chitId;
  final double totalPaid;
  final double prizeReceived;
  final double dividendReceived;
  final double outstandingAmount;
  final double settlementAmount;
  final String settlementDate;
  final String? remarks;
  final DateTime? createdAt;
  // View fields
  final String? memberName;
  final String? memberNo;
  final String? chitName;
  final String? branchName;

  const SettlementModel({
    required this.id,
    required this.memberId,
    required this.chitId,
    this.totalPaid = 0.0,
    this.prizeReceived = 0.0,
    this.dividendReceived = 0.0,
    this.outstandingAmount = 0.0,
    this.settlementAmount = 0.0,
    required this.settlementDate,
    this.remarks,
    this.createdAt,
    this.memberName,
    this.memberNo,
    this.chitName,
    this.branchName,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) =>
      SettlementModel(
        id: json['id'] as String,
        memberId: json['member_id'] as String? ?? '',
        chitId: json['chit_id'] as String? ?? '',
        totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
        prizeReceived:
            (json['prize_received'] as num?)?.toDouble() ?? 0.0,
        dividendReceived:
            (json['dividend_received'] as num?)?.toDouble() ?? 0.0,
        outstandingAmount:
            (json['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
        settlementAmount:
            (json['settlement_amount'] as num?)?.toDouble() ?? 0.0,
        settlementDate: json['settlement_date'] as String,
        remarks: json['remarks'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        memberName: json['member_name'] as String?,
        memberNo: json['member_no'] as String?,
        chitName: json['chit_name'] as String?,
        branchName: json['branch_name'] as String?,
      );
}
