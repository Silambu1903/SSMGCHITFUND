import '../datasources/supabase_datasource.dart';
import '../models/member_model.dart';
import '../models/guarantor_model.dart';
import '../../core/utils/supabase_payload.dart';

class MemberRepository {
  final SupabaseDatasource _ds = SupabaseDatasource();

  Future<List<MemberModel>> getMembers({
    String? branchId,
    String? status,
    int page = 0,
    int pageSize = 20,
  }) async {
    final filters = <String, dynamic>{};
    if (branchId != null) filters['branch_id'] = branchId;
    if (status != null) filters['status'] = status;

    final data = await _ds.fetchList(
      'members',
      filters: filters.isEmpty ? null : filters,
      orderBy: 'member_no',
      ascending: true,
      limit: pageSize,
      offset: page * pageSize,
    );
    return data.map(MemberModel.fromJson).toList();
  }

  Future<MemberModel?> getMemberById(String id) async {
    final data = await _ds.fetchOne('members', id);
    return data != null ? MemberModel.fromJson(data) : null;
  }

  Future<List<MemberModel>> searchMembers(String query) async {
    final data = await _ds.search('members', 'name', query);
    final mobileData = await _ds.search('members', 'mobile', query);
    final noData = await _ds.search('members', 'member_no', query);

    final ids = <String>{};
    final combined = <MemberModel>[];
    for (final row in [...data, ...mobileData, ...noData]) {
      final m = MemberModel.fromJson(row);
      if (ids.add(m.id)) combined.add(m);
    }
    return combined;
  }

  Future<MemberModel> createMember(Map<String, dynamic> data) async {
    final result =
        await _ds.insert('members', nullifyEmptyStrings(data));
    return MemberModel.fromJson(result);
  }

  Future<MemberModel> updateMember(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result =
        await _ds.update('members', id, nullifyEmptyStrings(data));
    return MemberModel.fromJson(result);
  }

  /// Remove all records that block member deletion (FK RESTRICT).
  Future<void> _purgeMemberDependencies({String? memberId}) async {
    if (memberId != null) {
      await _ds.deleteWhere('auction_bids', 'member_id', memberId);
      final winningAuctions = await _ds.fetchList(
        'auctions',
        filters: {'winning_member_id': memberId},
        select: 'id',
      );
      for (final a in winningAuctions) {
        await _ds.update('auctions', a['id'] as String, {
          'winning_member_id': null,
        });
      }
      await _ds.deleteWhere('receipts', 'member_id', memberId);
      await _ds.deleteWhere('payments', 'member_id', memberId);
      await _ds.deleteWhere('settlements', 'member_id', memberId);
      await _ds.deleteWhere('chit_members', 'member_id', memberId);
    } else {
      await _ds.deleteAll('auction_bids');
      await _ds.nullifyColumn('auctions', 'winning_member_id');
      await _ds.deleteAll('receipts');
      await _ds.deleteAll('payments');
      await _ds.deleteAll('settlements');
      await _ds.deleteAll('chit_members');
    }
  }

  Future<void> deleteMember(String id) async {
    await _purgeMemberDependencies(memberId: id);
    await _ds.delete('members', id);
  }

  /// Delete every member and their dependent records.
  Future<void> deleteAllMembers() async {
    await _purgeMemberDependencies();
    await _ds.deleteAll('members');
  }

  Future<int> getMemberCount({String? branchId}) async {
    final filters = branchId != null ? {'branch_id': branchId} : null;
    final data = await _ds.fetchList(
      'members',
      select: 'id',
      filters: filters,
    );
    return data.length;
  }

  // Guarantors
  Future<List<GuarantorModel>> getGuarantors(String memberId) async {
    final data = await _ds.fetchList(
      'guarantors',
      filters: {'member_id': memberId},
      orderBy: 'created_at',
    );
    return data.map(GuarantorModel.fromJson).toList();
  }

  Future<GuarantorModel> addGuarantor(Map<String, dynamic> data) async {
    final result = await _ds.insert('guarantors', data);
    return GuarantorModel.fromJson(result);
  }

  Future<void> deleteGuarantor(String id) => _ds.delete('guarantors', id);
}
