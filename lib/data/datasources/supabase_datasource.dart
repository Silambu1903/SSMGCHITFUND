import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatasource {
  static SupabaseClient get client => Supabase.instance.client;

  // Generic fetch list
  Future<List<Map<String, dynamic>>> fetchList(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    dynamic query = client.from(table).select(select ?? '*');

    if (filters != null) {
      for (final entry in filters.entries) {
        if (entry.value != null) {
          query = (query as dynamic).eq(entry.key, entry.value);
        }
      }
    }

    if (orderBy != null) {
      query = (query as dynamic).order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = (query as dynamic).limit(limit);
    }

    final result = await (query as dynamic);
    return List<Map<String, dynamic>>.from(result as List);
  }

  // Fetch single row
  Future<Map<String, dynamic>?> fetchOne(
    String table,
    String id, {
    String? select,
  }) async {
    final result = await client
        .from(table)
        .select(select ?? '*')
        .eq('id', id)
        .maybeSingle();
    return result;
  }

  // Insert
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final result =
        await client.from(table).insert(data).select().single();
    return result;
  }

  // Update
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final result = await client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return result;
  }

  // Delete
  Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  /// Delete all rows where [column] equals [value].
  Future<void> deleteWhere(String table, String column, dynamic value) async {
    await client.from(table).delete().eq(column, value);
  }

  /// Delete all rows (requires a filter — matches every non-zero UUID).
  Future<void> deleteAll(String table) async {
    await client
        .from(table)
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');
  }

  /// Set [column] to null on all rows where it is currently set.
  Future<void> nullifyColumn(String table, String column) async {
    await client.from(table).update({column: null}).not(column, 'is', null);
  }

  // Full-text search
  Future<List<Map<String, dynamic>>> search(
    String table,
    String column,
    String query, {
    String? select,
    int limit = 20,
  }) async {
    final result = await client
        .from(table)
        .select(select ?? '*')
        .ilike(column, '%$query%')
        .limit(limit);
    return List<Map<String, dynamic>>.from(result);
  }

  // RPC call
  Future<dynamic> rpc(
    String function, {
    Map<String, dynamic>? params,
  }) async {
    return await client.rpc(function, params: params);
  }
}
