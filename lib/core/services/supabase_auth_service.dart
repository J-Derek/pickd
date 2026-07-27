import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hive_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value?.session?.user;
});

class SupabaseAuthService {
  final SupabaseClient _supabase;

  SupabaseAuthService(this._supabase);

  // For users who just want to swipe immediately without creating an account
  Future<AuthResponse> signInAnonymously() async {
    return await _supabase.auth.signInAnonymously();
  }

  // Upgrade anonymous account or sign in new user
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    final user = _supabase.auth.currentUser;
    if (user != null && user.isAnonymous) {
      final res = await _supabase.auth.updateUser(UserAttributes(
        email: email,
        password: password,
      ));
      return AuthResponse(
        session: _supabase.auth.currentSession,
        user: res.user,
      );
    }
    
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.pickd://reset-password',
    );
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(UserAttributes(
      password: newPassword,
    ));
  }

  Future<void> signOut() async {
    await HiveService.clearAllUserData();
    await _supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService(ref.read(supabaseClientProvider));
});
