import '../datasources/supabase_datasource.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final SupabaseDatasource _ds = SupabaseDatasource();

  Future<DashboardMetrics> getMetrics({String? branchId}) async {
    final result = await _ds.rpc(
      'dashboard_metrics',
      params: branchId != null ? {'p_branch_id': branchId} : {},
    );
    if (result is Map<String, dynamic>) {
      return DashboardMetrics.fromJson(result);
    }
    return DashboardMetrics.empty;
  }

  Future<List<Map<String, dynamic>>> getRecentPayments({
    int limit = 10,
  }) async {
    return await _ds.fetchList(
      'payment_summary',
      orderBy: 'payment_date',
      ascending: false,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getUpcomingAuctions({
    int limit = 5,
  }) async {
    return await _ds.fetchList(
      'auction_summary',
      orderBy: 'auction_date',
      ascending: true,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getDefaulterSummary({
    int limit = 10,
  }) async {
    return await _ds.fetchList(
      'defaulter_summary',
      orderBy: 'total_overdue',
      ascending: false,
      limit: limit,
    );
  }
}
