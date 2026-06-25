class PaymentModel {
  final String id;
  final String memberId;
  final String chitId;
  final String? auctionId;
  final int paymentMonth;
  final double dueAmount;
  final double paidAmount;
  final double balanceAmount;
  final double penaltyAmount;
  final String? paymentDate;
  final String paymentMode;
  final String? receiptNumber;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // View fields
  final String? memberName;
  final String? memberNo;
  final String? chitName;
  final String? chitCode;
  final String? branchName;

  const PaymentModel({
    required this.id,
    required this.memberId,
    required this.chitId,
    this.auctionId,
    required this.paymentMonth,
    required this.dueAmount,
    this.paidAmount = 0.0,
    this.balanceAmount = 0.0,
    this.penaltyAmount = 0.0,
    this.paymentDate,
    this.paymentMode = 'cash',
    this.receiptNumber,
    this.status = 'Pending',
    this.createdAt,
    this.updatedAt,
    this.memberName,
    this.memberNo,
    this.chitName,
    this.chitCode,
    this.branchName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        memberId: json['member_id'] as String? ?? '',
        chitId: json['chit_id'] as String? ?? '',
        auctionId: json['auction_id'] as String?,
        paymentMonth: (json['payment_month'] as num?)?.toInt() ?? 0,
        dueAmount: (json['due_amount'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
        balanceAmount:
            (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
        penaltyAmount:
            (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
        paymentDate: json['payment_date'] as String?,
        paymentMode: json['payment_mode'] as String? ?? 'cash',
        receiptNumber: json['receipt_number'] as String?,
        status: json['status'] as String? ?? 'Pending',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        memberName: json['member_name'] as String?,
        memberNo: json['member_no'] as String?,
        chitName: json['chit_name'] as String?,
        chitCode: json['chit_code'] as String?,
        branchName: json['branch_name'] as String?,
      );
}
