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
      _setError(e.message);
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
      );
      _setState(AuthState.success);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
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
      _setError(e.message);
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
  Future<void> loadCurrentUser() async {
    _currentUser = await _repo.getCurrentUserProfile();
    notifyListeners();
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
}
