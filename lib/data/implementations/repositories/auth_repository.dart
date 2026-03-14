import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_config.dart';
import '../../../domain/entities/user_profile.dart';
import '../../interfaces/repositories/i_auth_repository.dart';

// ══════════════════════════════════════════════════════════════════
// AuthRepository – Supabase Auth + public.users implementation
// ══════════════════════════════════════════════════════════════════

class AuthRepository implements IAuthRepository {
  // ── sign in ──────────────────────────────────────────────────────
  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── sign up + populate profile ────────────────────────────────────
  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required double height,
    required double weight,
  }) async {
    // Pass profile data as user metadata. The Postgres trigger handling the 'insert'
    // event will then securely copy these fields into the `public.users` table.
    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
        'gender': gender.toLowerCase(),
        'height': height,
        'weight': weight,
      },
    );

    final userId = response.user?.id;
    if (userId == null) {
      throw const AuthException('Sign-up failed: no user returned.');
    }
  }

  // ── sign out ─────────────────────────────────────────────────────
  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ── password reset ────────────────────────────────────────────────
  @override
  Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
  }

  // ── fetch profile ─────────────────────────────────────────────────
  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  // ── session check ─────────────────────────────────────────────────
  @override
  bool get isLoggedIn => supabase.auth.currentSession != null;
}
