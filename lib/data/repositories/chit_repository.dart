import '../datasources/supabase_datasource.dart';
import '../models/chit_model.dart';

class ChitRepository {
  final SupabaseDatasource _ds = SupabaseDatasource();

  Future<List<ChitModel>> getChits({
    String? branchId,
    String? status,
  }) async {
    final filters = <String, dynamic>{};
    if (branchId != null) filters['branch_id'] = branchId;
    if (status != null) filters['status'] = status;

    final data = await _ds.fetchList(
      'chit_summary',
      filters: filters.isEmpty ? null : filters,
      orderBy: 'start_date',
      ascending: false,
    );

    // chit_summary returns the same columns as chits
    return data.map((row) {
      final mapped = {
        'id': row['chit_id'] ?? row['id'],
        'branch_id': row['branch_id'] ?? '',
        'chit_code': row['chit_code'],
        'chit_name': row['chit_name'],
        'chit_value': row['chit_value'],
        'total_members': row['total_members'],
        'duration_months': row['duration_months'],
        'monthly_installment': row['monthly_installment'],
        'foreman_commission_percent': row['foreman_commission_percent'],
        'penalty_amount': row['penalty_amount'] ?? 0.0,
        'grace_days': row['grace_days'] ?? 5,
        'auction_day': row['auction_day'] ?? 1,
        'auction_time': row['auction_time'],
        'start_date': row['start_date'],
        'end_date': row['end_date'],
        'status': row['status'] ?? 'active',
        'created_at': row['created_at'],
        'updated_at': row['updated_at'],
      };
      return ChitModel.fromJson(mapped);
    }).toList();
  }

  Future<List<ChitModel>> getChitsRaw({String? branchId}) async {
    final data = await _ds.fetchList(
      'chits',
      filters: branchId != null ? {'branch_id': branchId} : null,
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map(ChitModel.fromJson).toList();
  }

  Future<ChitModel?> getChitById(String id) async {
    final data = await _ds.fetchOne('chits', id);
    return data != null ? ChitModel.fromJson(data) : null;
  }

  Future<ChitModel> createChit(Map<String, dynamic> data) async {
    final result = await _ds.insert('chits', data);
    return ChitModel.fromJson(result);
  }

  Future<ChitModel> updateChit(String id, Map<String, dynamic> data) async {
    final result = await _ds.update('chits', id, data);
    return ChitModel.fromJson(result);
  }

  Future<void> deleteChit(String id) async {
    // Delete dependents first (FK constraints are RESTRICT)
    final payments = await _ds.fetchList(
      'payments',
      filters: {'chit_id': id},
      select: 'id',
    );
    if (payments.isNotEmpty) {
      final paymentIds = payments.map((p) => p['id'] as String).toList();
      for (final paymentId in paymentIds) {
        await _ds.deleteWhere('receipts', 'payment_id', paymentId);
      }
      await _ds.deleteWhere('payments', 'chit_id', id);
    }

    await _ds.deleteWhere('auctions', 'chit_id', id);
    await _ds.deleteWhere('settlements', 'chit_id', id);
    await _ds.deleteWhere('chit_members', 'chit_id', id);
    await _ds.delete('chits', id);
  }

  Future<List<Map<String, dynamic>>> getChitMembers(String chitId) async {
    return await _ds.fetchList(
      'chit_members',
      select:
          '*, members(id, member_no, name, mobile, status)',
      filters: {'chit_id': chitId},
      orderBy: 'ticket_no',
    );
  }

  Future<void> enrollMember(Map<String, dynamic> data) async {
    await _ds.insert('chit_members', data);
  }

  Future<void> updateChitMember(
    String chitMemberId,
    Map<String, dynamic> data,
  ) async {
    await _ds.update('chit_members', chitMemberId, data);
  }

  Future<void> removeChitMember(String chitMemberId) async {
    await _ds.delete('chit_members', chitMemberId);
  }

  Future<bool> memberHasPaymentsInChit(String memberId, String chitId) async {
    final rows = await _ds.fetchList(
      'payments',
      filters: {'member_id': memberId, 'chit_id': chitId},
      select: 'id',
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Map<String, dynamic>> getChitSummary(String chitId) async {
    final data = await SupabaseDatasource().fetchList(
      'chit_summary',
      filters: {'chit_id': chitId},
    );
    return data.isNotEmpty ? data.first : {};
  }
}
