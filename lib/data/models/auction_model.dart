class AuctionModel {
  final String id;
  final String chitId;
  final int auctionMonth;
  final String auctionDate;
  final double chitAmount;
  final int totalMembers;
  final double totalCollection;
  final String? winningMemberId;
  final double? winningDiscountPercent;
  final double? winningDiscountAmount;
  final double? prizeAmount;
  final double? commissionAmount;
  final double? dividendPool;
  final double? dividendPerMember;
  final double? nextMonthPayable;
  final String? remarks;
  final bool prizePaid;
  final DateTime? prizePaidAt;
  final String? prizePaidNote;
  final DateTime? createdAt;
  // From chit
  final int? auctionDay;
  final String? auctionTime;
  final double? foremanCommissionPercent;
  // View join fields
  final String? chitName;
  final String? chitCode;
  final String? winnerName;
  final String? winnerMemberNo;

  const AuctionModel({
    required this.id,
    required this.chitId,
    required this.auctionMonth,
    required this.auctionDate,
    required this.chitAmount,
    required this.totalMembers,
    this.totalCollection = 0.0,
    this.winningMemberId,
    this.winningDiscountPercent,
    this.winningDiscountAmount,
    this.prizeAmount,
    this.commissionAmount,
    this.dividendPool,
    this.dividendPerMember,
    this.nextMonthPayable,
    this.remarks,
    this.prizePaid = false,
    this.prizePaidAt,
    this.prizePaidNote,
    this.createdAt,
    this.auctionDay,
    this.auctionTime,
    this.foremanCommissionPercent,
    this.chitName,
    this.chitCode,
    this.winnerName,
    this.winnerMemberNo,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) => AuctionModel(
        id: json['id'] as String,
        chitId: json['chit_id'] as String,
        auctionMonth: (json['auction_month'] as num).toInt(),
        auctionDate: json['auction_date'] as String,
        chitAmount: (json['chit_amount'] as num).toDouble(),
        totalMembers: (json['total_members'] as num).toInt(),
        totalCollection:
            (json['total_collection'] as num?)?.toDouble() ?? 0.0,
        winningMemberId: json['winning_member_id'] as String?,
        winningDiscountPercent:
            (json['winning_discount_percent'] as num?)?.toDouble(),
        winningDiscountAmount:
            (json['winning_discount_amount'] as num?)?.toDouble(),
        prizeAmount: (json['prize_amount'] as num?)?.toDouble(),
        commissionAmount:
            (json['commission_amount'] as num?)?.toDouble(),
        dividendPool: (json['dividend_pool'] as num?)?.toDouble(),
        dividendPerMember:
            (json['dividend_per_member'] as num?)?.toDouble(),
        nextMonthPayable:
            (json['next_month_payable'] as num?)?.toDouble(),
        remarks: json['remarks'] as String?,
        prizePaid: (json['prize_paid'] as bool?) ?? false,
        prizePaidAt: json['prize_paid_at'] != null
            ? DateTime.tryParse(json['prize_paid_at'] as String)
            : null,
        prizePaidNote: json['prize_paid_note'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        auctionDay: (json['auction_day'] as num?)?.toInt(),
        auctionTime: json['auction_time'] as String?,
        foremanCommissionPercent:
            (json['foreman_commission_percent'] as num?)?.toDouble(),
        chitName: json['chit_name'] as String?,
        chitCode: json['chit_code'] as String?,
        winnerName: json['winner_name'] as String?,
        winnerMemberNo: json['winner_member_no'] as String?,
      );
}

class AuctionBidModel {
  final String id;
  final String auctionId;
  final String memberId;
  final double bidPercent;
  final double bidAmount;
  final DateTime? createdAt;

  const AuctionBidModel({
    required this.id,
    required this.auctionId,
    required this.memberId,
    required this.bidPercent,
    required this.bidAmount,
    this.createdAt,
  });

  factory AuctionBidModel.fromJson(Map<String, dynamic> json) =>
      AuctionBidModel(
        id: json['id'] as String,
        auctionId: json['auction_id'] as String,
        memberId: json['member_id'] as String,
        bidPercent: (json['bid_percent'] as num).toDouble(),
        bidAmount: (json['bid_amount'] as num).toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}
