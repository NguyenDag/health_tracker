import '../../../domain/entities/user_profile.dart';

// ══════════════════════════════════════════════════════════════════
// IAuthRepository – abstract contract for authentication operations
// ══════════════════════════════════════════════════════════════════

abstract class IAuthRepository {
  /// Sign in with email + password.
  /// Throws [AuthException] on failure.
  Future<void> signIn({
    required String email,
    required String password,
  });

  /// Register a new user and populate their public.users profile.
  /// Throws [AuthException] on failure.
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required double height,
    required double weight,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password-reset email via Supabase Auth.
  /// Throws [AuthException] on failure.
  Future<void> resetPassword({required String email});

  /// Fetch the profile row from public.users for the current session user.
  /// Returns null if no session or no row found.
  Future<UserProfile?> getCurrentUserProfile();

  /// True when there is an active Supabase session.
  bool get isLoggedIn;
}
