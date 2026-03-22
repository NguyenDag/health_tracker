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
    required DateTime dob,
  }) async {
    // Map gender to English for database check constraint
    final mappedGender = {
      'nam': 'male',
      'nữ': 'female',
      'khác': 'other',
    }[gender.toLowerCase()] ?? gender.toLowerCase();

    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
        'gender': mappedGender,
        'height': height,
        'weight': weight,
        'dob': dob.toIso8601String(),
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

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await supabase
        .from('users')
        .update(profile.toMap())
        .eq('id', profile.id);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword.trim()),
    );
  }

  @override
  Future<bool> verifyPassword(String password) async {
    final email = supabase.auth.currentUser?.email;
    if (email == null) return false;

    try {
      // Re-sign in to verify the password
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── session check ─────────────────────────────────────────────────
  @override
  bool get isLoggedIn => supabase.auth.currentSession != null;

  // ── resend email ──────────────────────────────────────────────────
  @override
  Future<void> resendVerificationEmail(String email) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
  }

  // ── check email exists ────────────────────────────────────────────
  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final data = await supabase
          .from('users')
          .select('id')
          .eq('email', email.trim())
          .maybeSingle();
      return data != null; // True if a user document exists
    } catch (e) {
      return false; // Safely fail in case RLS or network issue
    }
  }
}
