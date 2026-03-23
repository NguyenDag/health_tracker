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

  String _searchQuery = '';
  String _selectedFilter = 'Tất Cả';

  static const filters = ['Tất Cả', 'Hoạt Động', 'Không Hoạt Động'];

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  List<UserProfile> get users =>
      _users.where((u) => u.role != 'admin').toList();

  List<UserProfile> get filteredUsers {
    final q = _searchQuery.toLowerCase();
    return users.where((u) {
      final name = u.fullName.toLowerCase();
      final matchSearch = q.isEmpty ||
          name.contains(q) ||
          (u.email ?? '').toLowerCase().contains(q) ||
          (u.phone ?? '').contains(q) ||
          u.id.toLowerCase().contains(q);
      final matchFilter = switch (_selectedFilter) {
        'Active' => u.status == 'active',
        'Inactive' => u.status != 'active',
        _ => true,
      };
      return matchSearch && matchFilter;
    }).toList();
  }

  int get totalUsers => users.length;

  int get newSignupsThisMonth {
    final now = DateTime.now();
    return users
        .where((u) =>
            u.createdAt != null &&
            u.createdAt!.year == now.year &&
            u.createdAt!.month == now.month)
        .length;
  }

  // ── Commands ───────────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

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
