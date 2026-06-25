import '../datasources/supabase_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final SupabaseDatasource _ds = SupabaseDatasource();

  Future<List<PaymentModel>> getPayments({
    String? memberId,
    String? chitId,
    String? status,
    int? paymentMonth,
    int page = 0,
    int pageSize = 30,
  }) async {
    final filters = <String, dynamic>{};
    if (memberId != null) filters['member_id'] = memberId;
    if (chitId != null) filters['chit_id'] = chitId;
    if (status != null) filters['status'] = status;
    if (paymentMonth != null) filters['payment_month'] = paymentMonth;

    // payment_summary has no member_id/chit_id columns — query payments when filtered
    final table = (memberId != null || chitId != null) ? 'payments' : 'payment_summary';

    final data = await _ds.fetchList(
      table,
      filters: filters.isEmpty ? null : filters,
      orderBy: 'payment_month',
      ascending: false,
      limit: pageSize,
      offset: page * pageSize,
    );
    return data.map(_mapPaymentRow).toList();
  }

  PaymentModel _mapPaymentRow(Map<String, dynamic> row) {
    final mapped = {
      'id': row['payment_id'] ?? row['id'],
      'member_id': row['member_id'] ?? '',
      'chit_id': row['chit_id'] ?? '',
      'auction_id': row['auction_id'],
      'payment_month': row['payment_month'],
      'due_amount': row['due_amount'],
      'paid_amount': row['paid_amount'] ?? 0.0,
      'balance_amount': row['balance_amount'] ?? 0.0,
      'penalty_amount': row['penalty_amount'] ?? 0.0,
      'payment_date': row['payment_date'],
      'payment_mode': row['payment_mode'] ?? 'cash',
      'receipt_number': row['receipt_number'],
      'status': row['status'] ?? 'Pending',
      'created_at': row['created_at'],
      'updated_at': row['updated_at'],
      'member_name': row['member_name'],
      'member_no': row['member_no'],
      'chit_name': row['chit_name'],
      'chit_code': row['chit_code'],
      'branch_name': row['branch_name'],
    };
    return PaymentModel.fromJson(mapped);
  }

  Future<PaymentModel?> getPaymentById(String id) async {
    final data = await _ds.fetchOne('payments', id);
    return data != null ? PaymentModel.fromJson(data) : null;
  }

  Future<PaymentModel> recordPayment(Map<String, dynamic> data) async {
    final result = await _ds.insert('payments', data);
    return PaymentModel.fromJson(result);
  }

  Future<PaymentModel> updatePayment(
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await _ds.update('payments', id, data);
    return PaymentModel.fromJson(result);
  }

  Future<List<PaymentModel>> getDefaulters({String? branchId}) async {
    final data = await _ds.fetchList(
      'defaulter_summary',
      orderBy: 'total_overdue',
      ascending: false,
    );
    return data.map((row) {
      return PaymentModel(
        id: row['member_id'],
        memberId: row['member_id'],
        chitId: row['chit_id'] ?? '',
        paymentMonth: 0,
        dueAmount: (row['total_overdue'] as num?)?.toDouble() ?? 0.0,
        memberName: row['member_name'],
        memberNo: row['member_no'],
        chitName: row['chit_name'],
        branchName: row['branch_name'],
        status: 'Overdue',
      );
    }).toList();
  }

  Future<int> generateMonthlyDues({
    required String chitId,
    required String auctionId,
    required int paymentMonth,
    required double dueAmount,
  }) async {
    final result = await _ds.rpc('generate_monthly_dues', params: {
      'p_chit_id': chitId,
      'p_auction_id': auctionId,
      'p_payment_month': paymentMonth,
      'p_due_amount': dueAmount,
    });
    return (result as num?)?.toInt() ?? 0;
  }

  /// All payment rows for one chit (member × month matrix).
  Future<List<PaymentModel>> getPaymentsForChit(String chitId) async {
    final data = await _ds.fetchList(
      'payments',
      filters: {'chit_id': chitId},
      orderBy: 'payment_month',
      ascending: true,
      limit: 5000,
    );
    return data.map(PaymentModel.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> getMemberOutstanding(
    String memberId, {
    String? chitId,
  }) async {
    final result = await _ds.rpc('get_member_outstanding', params: {
      'p_member_id': memberId,
      if (chitId != null) 'p_chit_id': chitId,
    });
    return List<Map<String, dynamic>>.from(result ?? []);
  }
}
