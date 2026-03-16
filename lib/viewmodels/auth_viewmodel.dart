import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/implementations/repositories/auth_repository.dart';
import '../data/interfaces/repositories/i_auth_repository.dart';
import '../domain/entities/user_profile.dart';

// ══════════════════════════════════════════════════════════════════
// AuthState – describes the loading/result state of an auth action
// ══════════════════════════════════════════════════════════════════

enum AuthState { idle, loading, success, error }

// ══════════════════════════════════════════════════════════════════
// AuthViewModel – ChangeNotifier consumed by all auth screens
// ══════════════════════════════════════════════════════════════════

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({IAuthRepository? repository})
      : _repo = repository ?? AuthRepository();

  final IAuthRepository _repo;

  AuthState _state = AuthState.idle;
  String? _errorMessage;
  UserProfile? _currentUser;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _repo.isLoggedIn;
  bool get isLoading => _state == AuthState.loading;

  // ── Sign In ───────────────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _repo.signIn(email: email, password: password);
      _currentUser = await _repo.getCurrentUserProfile();
      _setState(AuthState.success);
      return true;
    } on AuthException catch (e) {
      _setError(_translateAuthError(e));
      return false;
    } catch (e) {
      _setError('Đăng nhập thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────
  Future<bool> signUp({
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
    _setLoading();
    try {
      await _repo.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        gender: gender,
        height: height,
        weight: weight,
        dob: dob,
      );
      _currentUser = await _repo.getCurrentUserProfile();
      _setState(AuthState.success);
      return true;
    } on AuthException catch (e) {
      _setError(_translateAuthError(e));
      return false;
    } catch (e) {
      _setError('Đăng ký thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  // ── Reset Password ────────────────────────────────────────────────
  Future<bool> resetPassword({required String email}) async {
    _setLoading();
    try {
      await _repo.resetPassword(email: email);
      _setState(AuthState.success);
      return true;
    } on AuthException catch (e) {
      _setError(_translateAuthError(e));
      return false;
    } catch (e) {
      _setError('Không thể gửi email khôi phục. Vui lòng thử lại.');
      return false;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────
  Future<void> signOut() async {
    _setLoading();
    try {
      await _repo.signOut();
      _currentUser = null;
      _setState(AuthState.idle);
    } catch (_) {
      _setState(AuthState.idle);
    }
  }

  // ── Load current user profile ──────────────────────────────────────
  Future<UserProfile?> loadCurrentUser() async {
    _currentUser = await _repo.getCurrentUserProfile();
    notifyListeners();
    return _currentUser;
  }

  // ── Update profile ────────────────────────────────────────────────
  Future<bool> updateProfile(UserProfile profile) async {
    _setLoading();
    try {
      await _repo.updateUserProfile(profile);
      _currentUser = profile;
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError('Cập nhật hồ sơ thất bại: $e');
      return false;
    }
  }

  // ── Update password ──────────────────────────────────────────────
  Future<bool> updatePassword(String newPassword) async {
    _setLoading();
    try {
      await _repo.updatePassword(newPassword);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _setError('Cập nhật mật khẩu thất bại: $e');
      return false;
    }
  }

  // ── Verify current password ──────────────────────────────────────
  Future<bool> verifyCurrentPassword(String password) async {
    _setLoading();
    final isValid = await _repo.verifyPassword(password);
    if (isValid) {
      _setState(AuthState.idle); // Allow next step
      return true;
    } else {
      _setError('Mật khẩu hiện tại không chính xác');
      return false;
    }
  }

  // ── Reset to idle (e.g. when leaving error state) ─────────────────
  void resetState() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────
  void _setLoading() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AuthState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _state = AuthState.error;
    _errorMessage = msg;
    notifyListeners();
  }

  String _translateAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu không chính xác.';
    } else if (msg.contains('email not confirmed')) {
      return 'Tài khoản chưa được xác nhận. Vui lòng kiểm tra email của bạn.';
    } else if (msg.contains('already registered') || msg.contains('user already exists')) {
      return 'Email này đã được đăng ký.';
    } else if (msg.contains('invalid email')) {
      return 'Định dạng email không hợp lệ.';
    } else if (msg.contains('rate limit exceeded')) {
      return 'Bạn thao tác quá giới hạn. Vui lòng thử lại sau ít phút.';
    } else if (msg.contains('password should be at least')) {
      return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn (ít nhất 6 ký tự).';
    } else if (msg.contains('signup requires a valid password')) {
      return 'Vui lòng nhập một mật khẩu hợp lệ.';
    } else if (msg.contains('error sending recovery email')) {
      return 'Hệ thống gửi email lỗi. Vui lòng liên hệ Admin hoặc cấu hình SMTP trong Supabase Dashboard.';
    }
    // Default fallback
    return 'Lỗi: ${e.message}';
  }
}
