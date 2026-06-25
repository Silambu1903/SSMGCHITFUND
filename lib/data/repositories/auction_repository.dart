import '../datasources/supabase_datasource.dart';
import '../models/auction_model.dart';

class AuctionRepository {
  final SupabaseDatasource _ds = SupabaseDatasource();

  Future<List<AuctionModel>> getAuctions({
    String? chitId,
    int? limit,
  }) async {
    final data = await _ds.fetchList(
      'auction_summary',
      filters: chitId != null ? {'chit_id': chitId} : null,
      orderBy: 'auction_month',
      ascending: false,
      limit: limit,
    );
    return data.map((row) {
      final mapped = {
        'id': row['auction_id'] ?? row['id'],
        'chit_id': row['chit_id'],
        'auction_month': row['auction_month'],
        'auction_date': row['auction_date'],
        'chit_amount': row['chit_amount'],
        'total_members': row['total_members'],
        'total_collection': row['total_collection'] ?? 0.0,
        'winning_member_id': row['winning_member_id'],
        'winning_discount_percent': row['winning_discount_percent'],
        'winning_discount_amount': row['winning_discount_amount'],
        'prize_amount': row['prize_amount'],
        'commission_amount': row['commission_amount'],
        'dividend_pool': row['dividend_pool'],
        'dividend_per_member': row['dividend_per_member'],
        'next_month_payable': row['next_month_payable'],
        'remarks': row['remarks'],
        'prize_paid': row['prize_paid'],
        'prize_paid_at': row['prize_paid_at'],
        'prize_paid_note': row['prize_paid_note'],
        'created_at': row['created_at'],
        'auction_day': row['auction_day'],
        'auction_time': row['auction_time'],
        'foreman_commission_percent': row['foreman_commission_percent'],
        'chit_name': row['chit_name'],
        'chit_code': row['chit_code'],
        'winner_name': row['winner_name'],
        'winner_member_no': row['winner_member_no'],
      };
      return AuctionModel.fromJson(mapped);
    }).where((a) => chitId == null || a.chitId == chitId).toList();
  }

  Future<AuctionModel?> getAuctionById(String id) async {
    final data = await _ds.fetchOne('auctions', id);
    return data != null ? AuctionModel.fromJson(data) : null;
  }

  Future<AuctionModel> createAuction(Map<String, dynamic> data) async {
    final result = await _ds.insert('auctions', data);
    return AuctionModel.fromJson(result);
  }

  Future<AuctionModel> updateAuction(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await _ds.update('auctions', id, data);
    return AuctionModel.fromJson(result);
  }

  Future<void> deleteAuction(String id) => _ds.delete('auctions', id);

  Future<List<AuctionBidModel>> getBids(String auctionId) async {
    final data = await _ds.fetchList(
      'auction_bids',
      filters: {'auction_id': auctionId},
      orderBy: 'bid_percent',
      ascending: false,
    );
    return data.map(AuctionBidModel.fromJson).toList();
  }

  Future<void> placeBid(Map<String, dynamic> data) async {
    await _ds.insert('auction_bids', data);
  }

  /// Returns the next auction month number for the given chit (existing max + 1).
  Future<int> getNextAuctionMonth(String chitId) async {
    final result = await _ds.rpc(
      'next_auction_month',
      params: {'p_chit_id': chitId},
    );
    return (result as num?)?.toInt() ?? 1;
  }

  /// Mark the prize as paid to the winner.
  Future<void> markPrizePaid(String auctionId, {String? note}) async {
    await _ds.update('auctions', auctionId, {
      'prize_paid': true,
      'prize_paid_at': DateTime.now().toIso8601String(),
      if (note != null && note.isNotEmpty) 'prize_paid_note': note,
    });
  }

  // Calculate fields using DB functions
  Future<Map<String, double>> calculateAuction({
    required double chitAmount,
    required double discountAmount,
    required double commissionPercent,
    required int totalMembers,
    required double monthlyInstallment,
  }) async {
    final commission = chitAmount * commissionPercent / 100;
    final dividendPool = discountAmount - commission;
    final dividendPerMember = dividendPool / totalMembers;
    final prizeAmount = chitAmount - discountAmount;
    final nextPayable = monthlyInstallment - dividendPerMember;

    return {
      'commission': commission,
      'dividend_pool': dividendPool,
      'dividend_per_member': dividendPerMember,
      'prize_amount': prizeAmount,
      'next_month_payable': nextPayable > 0 ? nextPayable : 0,
    };
  }
}
