import 'package:flutter/material.dart';

import '../data/implementations/repositories/user_repository.dart';
import '../data/interfaces/repositories/i_user_repository.dart';
import '../domain/entities/user_profile.dart';

class AdminUsersViewModel extends ChangeNotifier {
  AdminUsersViewModel({IUserRepository? repository})
      : _repo = repository ?? UserRepository();

  final IUserRepository _repo;

  List<UserProfile> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserProfile> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _repo.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _repo.updateUserStatus(userId, status);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
