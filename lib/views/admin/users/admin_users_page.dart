import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum _UserStatus { active, alert, inactive, pending }

class _UserData {
  final String name;
  final String id;
  final String tracking;
  final String timeInfo; // "Last login: X" or "Created: X"
  final _UserStatus status;
  final String email;
  final String phone;
  final String joinDate;
  final Color avatarColor;
  bool isActive;

  _UserData({
    required this.name,
    required this.id,
    required this.tracking,
    required this.timeInfo,
    required this.status,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.avatarColor,
    required this.isActive,
  });

  String get statusLabel => switch (status) {
    _UserStatus.active => 'Active',
    _UserStatus.alert => 'Alert',
    _UserStatus.inactive => 'Inactive',
    _UserStatus.pending => 'Pending',
  };

  Color get statusColor => switch (status) {
    _UserStatus.active => AppColors.success,
    _UserStatus.alert => AppColors.error,
    _UserStatus.inactive => AppColors.textSecondary,
    _UserStatus.pending => AppColors.warning,
  };

  // initials: up to 2 chars
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedFilter = 'All Users';
  String _searchQuery = '';

  final List<_UserData> _allUsers = [
    _UserData(
      name: 'John Doe',
      id: '#83921',
      tracking: 'BP Monitoring',
      timeInfo: 'Last login: 25 mins ago',
      status: _UserStatus.active,
      email: 'john.doe@email.com',
      phone: '+1 (555) 012-3456',
      joinDate: 'Jan 15, 2024',
      avatarColor: const Color(0xFF37474F),
      isActive: true,
    ),
    _UserData(
      name: 'Sarah Miller',
      id: '#19204',
      tracking: 'Blood Sugar',
      timeInfo: 'Last login: 1 hour ago',
      status: _UserStatus.alert,
      email: 'sarah.miller@email.com',
      phone: '+1 (555) 234-5678',
      joinDate: 'Mar 02, 2024',
      avatarColor: const Color(0xFF4A235A),
      isActive: true,
    ),
    _UserData(
      name: 'Michael Chen',
      id: '#99482',
      tracking: 'SpO2 Tracking',
      timeInfo: 'Last login: 3 months ago',
      status: _UserStatus.inactive,
      email: 'michael.chen@email.com',
      phone: '+1 (555) 345-6789',
      joinDate: 'Nov 10, 2023',
      avatarColor: const Color(0xFF1A3A4A),
      isActive: false,
    ),
    _UserData(
      name: 'Elara Keye',
      id: '#77213',
      tracking: 'Weight Control',
      timeInfo: 'Last login: 5 hours ago',
      status: _UserStatus.active,
      email: 'elara.keye@email.com',
      phone: '+1 (555) 456-7890',
      joinDate: 'Feb 20, 2024',
      avatarColor: AppColors.primary,
      isActive: true,
    ),
    _UserData(
      name: 'David Kim',
      id: '#33491',
      tracking: 'General Health',
      timeInfo: 'Created: 2 days ago',
      status: _UserStatus.pending,
      email: 'david.kim@email.com',
      phone: '+1 (555) 678-9012',
      joinDate: 'Mar 03, 2026',
      avatarColor: const Color(0xFF2C3E50),
      isActive: false,
    ),
  ];

  static const _filters = ['All Users', 'Active', 'Inactive', 'Flagged'];

  List<_UserData> get _filteredUsers => _allUsers.where((u) {
    final matchSearch =
        _searchQuery.isEmpty ||
        u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        u.id.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchFilter =
        _selectedFilter == 'All Users' ||
        (_selectedFilter == 'Active' && u.status == _UserStatus.active) ||
        (_selectedFilter == 'Inactive' && u.status == _UserStatus.inactive) ||
        (_selectedFilter == 'Flagged' &&
            (u.status == _UserStatus.alert || u.status == _UserStatus.pending));
    return matchSearch && matchFilter;
  }).toList();

  void _showUserDetail(_UserData user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(
        user: user,
        onToggleActive: () {
          setState(() => user.isActive = !user.isActive);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user.isActive
                    ? '${user.name} has been reactivated.'
                    : '${user.name} has been deactivated.',
              ),
              backgroundColor: user.isActive
                  ? AppColors.success
                  : AppColors.warning,
            ),
          );
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(user);
        },
      ),
    );
  }

  void _confirmDelete(_UserData user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete User', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.subtitle),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _allUsers.remove(user));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been deleted.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        _buildListHeader(users.length),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text('No users found', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: users.length,
                  itemBuilder: (_, i) => _buildUserCard(users[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search by name, ID...',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final isSelected = _selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    f,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RECENTLY ACTIVE',
            style: AppTextStyles.label.copyWith(letterSpacing: 0.5),
          ),
          Row(
            children: [
              const Icon(Icons.sort, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Sort',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(_UserData user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            _buildAvatar(user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _buildStatusBadge(user),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ID: ${user.id} • ${user.tracking}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.timeInfo,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'view') _showUserDetail(user);
                if (value == 'toggle') {
                  setState(() => user.isActive = !user.isActive);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        user.isActive
                            ? '${user.name} reactivated.'
                            : '${user.name} deactivated.',
                      ),
                      backgroundColor: user.isActive
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  );
                }
                if (value == 'delete') _confirmDelete(user);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(user.isActive ? 'Deactivate' : 'Reactivate'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(_UserData user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: user.avatarColor,
          child: Text(
            user.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Positioned(
          bottom: 1,
          left: 1,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: user.statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(_UserData user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: user.statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: user.statusColor.withAlpha(60)),
      ),
      child: Text(
        user.statusLabel,
        style: AppTextStyles.label.copyWith(
          color: user.statusColor,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── User Detail Bottom Sheet ────────────────────────────────────────────────

class _UserDetailSheet extends StatelessWidget {
  final _UserData user;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _UserDetailSheet({
    required this.user,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: user.avatarColor,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text('ID: ${user.id}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: user.statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: user.statusColor.withAlpha(60)),
                  ),
                  child: Text(
                    user.statusLabel,
                    style: AppTextStyles.label.copyWith(
                      color: user.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Contact Information',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.email_outlined, user.email),
            const SizedBox(height: 8),
            _infoRow(Icons.phone_outlined, user.phone),
            const SizedBox(height: 8),
            _infoRow(Icons.calendar_today_outlined, 'Joined: ${user.joinDate}'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Health Tracking',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.monitor_heart_outlined, user.tracking),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time_outlined, user.timeInfo),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleActive,
                    icon: Icon(
                      user.isActive ? Icons.block : Icons.check_circle_outline,
                      color: user.isActive
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    label: Text(
                      user.isActive ? 'Deactivate' : 'Reactivate',
                      style: TextStyle(
                        color: user.isActive
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: user.isActive
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}
