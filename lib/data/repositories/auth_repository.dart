import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exception.dart' as app_ex;
import '../../core/utils/login_util.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String identifier,
    required String password,
  }) async {
    final parsed = parseLoginIdentifier(identifier);
    try {
      if (parsed.isPhone) {
        return await _client.auth.signInWithPassword(
          phone: parsed.value,
          password: password,
        );
      }
      return await _client.auth.signInWithPassword(
        email: parsed.value,
        password: password,
      );
    } on AuthException catch (e) {
      throw app_ex.AuthException(e.message);
    } catch (e) {
      throw const app_ex.AuthException('Login failed. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw const app_ex.AuthException('Logout failed.');
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    return await _client
        .from('profiles')
        .select()
        .eq('auth_user_id', uid)
        .maybeSingle();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw app_ex.AuthException(e.message);
    }
  }
}
