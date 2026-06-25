import '../datasources/supabase_datasource.dart';
import '../models/settlement_model.dart';

class SettlementRepository {
  final SupabaseDatasource _ds = SupabaseDatasource();

  Future<List<SettlementModel>> getSettlements({
    String? memberId,
    String? chitId,
  }) async {
    final filters = <String, dynamic>{};
    if (memberId != null) filters['member_id'] = memberId;
    if (chitId != null) filters['chit_id'] = chitId;

    final data = await _ds.fetchList(
      'settlement_summary',
      filters: filters.isEmpty ? null : filters,
      orderBy: 'settlement_date',
      ascending: false,
    );
    return data.map((row) {
      final mapped = {
        'id': row['settlement_id'] ?? row['id'],
        'member_id': row['member_id'] ?? '',
        'chit_id': row['chit_id'] ?? '',
        'total_paid': row['total_paid'] ?? 0.0,
        'prize_received': row['prize_received'] ?? 0.0,
        'dividend_received': row['dividend_received'] ?? 0.0,
        'outstanding_amount': row['outstanding_amount'] ?? 0.0,
        'settlement_amount': row['settlement_amount'] ?? 0.0,
        'settlement_date': row['settlement_date'],
        'remarks': row['remarks'],
        'created_at': row['created_at'],
        'member_name': row['member_name'],
        'member_no': row['member_no'],
        'chit_name': row['chit_name'],
        'branch_name': row['branch_name'],
      };
      return SettlementModel.fromJson(mapped);
    }).toList();
  }

  Future<SettlementModel> createSettlement(
    Map<String, dynamic> data,
  ) async {
    final result = await _ds.insert('settlements', data);
    return SettlementModel.fromJson(result);
  }
}
