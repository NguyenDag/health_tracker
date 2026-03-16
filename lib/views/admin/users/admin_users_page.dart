import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../viewmodels/admin_users_viewmodel.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const _filters = ['All', 'Active', 'Inactive'];

  static const List<Color> _avatarPalette = [
    Color(0xFF00695C),
    Color(0xFF37474F),
    Color(0xFF4527A0),
    Color(0xFF1565C0),
    Color(0xFF558B2F),
    Color(0xFF6A1B9A),
    Color(0xFF2E7D32),
    Color(0xFF0277BD),
  ];

  Color _colorFor(String id) =>
      _avatarPalette[id.hashCode.abs() % _avatarPalette.length];

  String _initialsOf(UserProfile u) {
    final f = u.firstName?.isNotEmpty == true ? u.firstName![0] : '';
    final l = u.lastName?.isNotEmpty == true ? u.lastName![0] : '';
    final combined = (f + l).toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }

  List<UserProfile> _filtered(List<UserProfile> all) {
    final q = _searchQuery.toLowerCase();
    return all.where((u) {
      if (u.role == 'admin') return false;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersViewModel>().loadUsers();
    });
  }

  // ── Actions ────────────────────────────────────────────────────────

  void _showUserDetail(UserProfile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(
        user: user,
        avatarColor: _colorFor(user.id),
        initials: _initialsOf(user),
        onToggleActive: () {
          Navigator.pop(context);
          _confirmToggle(user);
        },
      ),
    );
  }

  void _confirmToggle(UserProfile user) {
    final isActive = user.status == 'active';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isActive ? 'Deactivate User' : 'Reactivate User',
          style: AppTextStyles.h3,
        ),
        content: Text(
          isActive
              ? 'Deactivate ${_displayName(user)}? They will no longer be able to log in.'
              : 'Reactivate ${_displayName(user)}? They will regain access.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.warning : AppColors.success,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final newStatus = isActive ? 'inactive' : 'active';
              await context
                  .read<AdminUsersViewModel>()
                  .updateUserStatus(user.id, newStatus);
              if (mounted) {
                final vm = context.read<AdminUsersViewModel>();
                if (vm.error != null) {
                  _showSnackBar(
                      'Failed to update status: ${vm.error}', AppColors.error);
                } else {
                  _showSnackBar(
                    isActive
                        ? '${_displayName(user)} has been deactivated.'
                        : '${_displayName(user)} has been reactivated.',
                    isActive ? AppColors.warning : AppColors.success,
                  );
                }
              }
            },
            child: Text(
              isActive ? 'Deactivate' : 'Reactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  String _displayName(UserProfile u) =>
      u.fullName.isNotEmpty ? u.fullName : 'User ${u.id.substring(0, 6)}';

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off,
                      size: 52, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('Failed to load users',
                      style: AppTextStyles.subtitle),
                  const SizedBox(height: 6),
                  Text(vm.error!,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: vm.loadUsers,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final filtered = _filtered(vm.users);

        return Column(
          children: [
            _SearchBar(
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            _FilterChips(
              filters: _filters,
              selected: _selectedFilter,
              onSelect: (f) => setState(() => _selectedFilter = f),
            ),
            _ListHeader(
              count: filtered.length,
              total: vm.users.length,
              onRefresh: vm.loadUsers,
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(query: _searchQuery)
                  : RefreshIndicator(
                      onRefresh: vm.loadUsers,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _UserCard(
                          user: filtered[i],
                          color: _colorFor(filtered[i].id),
                          initials: _initialsOf(filtered[i]),
                          displayName: _displayName(filtered[i]),
                          onTap: () => _showUserDetail(filtered[i]),
                          onToggle: () => _confirmToggle(filtered[i]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, ID...',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(Icons.search,
              color: AppColors.textSecondary, size: 20),
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
}

class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSel = selected == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel
                          ? AppColors.primary
                          : Colors.grey.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    f,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isSel ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isSel ? FontWeight.w600 : FontWeight.normal,
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
}

class _ListHeader extends StatelessWidget {
  final int count;
  final int total;
  final VoidCallback onRefresh;

  const _ListHeader({
    required this.count,
    required this.total,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            count == total
                ? '$count USER${count == 1 ? '' : 'S'}'
                : '$count of $total USER${total == 1 ? '' : 'S'}',
            style: AppTextStyles.label.copyWith(letterSpacing: 0.5),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: Row(children: [
              const Icon(Icons.refresh, size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('Refresh',
                  style: AppTextStyles.subtitle
                      .copyWith(color: AppColors.primary, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            query.isNotEmpty ? Icons.search_off : Icons.people_outline,
            size: 52,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            query.isNotEmpty ? 'No users match "$query"' : 'No users found',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfile user;
  final Color color;
  final String initials;
  final String displayName;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _UserCard({
    required this.user,
    required this.color,
    required this.initials,
    required this.displayName,
    required this.onTap,
    required this.onToggle,
  });

  bool get _isActive => user.status == 'active';
  bool get _isAdmin => user.role == 'admin';

  Color get _statusColor =>
      _isActive ? AppColors.success : AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  Positioned(
                    bottom: 1,
                    left: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Admin badge
                        if (_isAdmin) ...[
                          const SizedBox(width: 6),
                          _Badge(
                            label: 'Admin',
                            color: AppColors.primary,
                          ),
                        ],
                        const SizedBox(width: 4),
                        // Status badge
                        _Badge(
                          label: _isActive ? 'Active' : 'Inactive',
                          color: _statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Email
                    Text(
                      user.email ?? 'No email',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: user.email != null
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withAlpha(120),
                        fontStyle: user.email != null
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Last sign in or joined date
                    Text(
                      user.lastSignInAt != null
                          ? 'Last seen ${_timeAgo(user.lastSignInAt!)}'
                          : user.createdAt != null
                              ? 'Joined ${_fmtDate(user.createdAt!)}'
                              : '',
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary, size: 20),
                onSelected: (v) {
                  if (v == 'view') onTap();
                  if (v == 'toggle') onToggle();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'view', child: Text('View Details')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(_isActive ? 'Deactivate' : 'Reactivate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return _fmtDate(dt);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label,
          style: AppTextStyles.label.copyWith(color: color, fontSize: 10)),
    );
  }
}

// ─── User Detail Sheet ────────────────────────────────────────────────────────

class _UserDetailSheet extends StatelessWidget {
  final UserProfile user;
  final Color avatarColor;
  final String initials;
  final VoidCallback onToggleActive;

  const _UserDetailSheet({
    required this.user,
    required this.avatarColor,
    required this.initials,
    required this.onToggleActive,
  });

  bool get _isActive => user.status == 'active';
  Color get _statusColor =>
      _isActive ? AppColors.success : AppColors.textSecondary;
  String get _statusLabel => _isActive ? 'Active' : 'Inactive';

  String get _displayName =>
      user.fullName.isNotEmpty ? user.fullName : 'User ${user.id.substring(0, 8)}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: avatarColor,
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_displayName, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Row(children: [
                        _Badge(label: _statusLabel, color: _statusColor),
                        if (user.role == 'admin') ...[
                          const SizedBox(width: 6),
                          _Badge(
                              label: 'Admin',
                              color: AppColors.primary),
                        ],
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Account info section
            _SectionLabel('Account'),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'First name',
              value: user.firstName,
            ),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Last name',
              value: user.lastName,
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone,
            ),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Role',
              value: user.role,
            ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: user.createdAt != null ? _fmtDate(user.createdAt!) : null,
            ),
            _InfoRow(
              icon: Icons.access_time_outlined,
              label: 'Last seen',
              value: user.lastSignInAt != null
                  ? _fmtDate(user.lastSignInAt!)
                  : null,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Health profile section
            _SectionLabel('Health Profile'),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Gender',
              value: user.gender?.isNotEmpty == true
                  ? _capitalize(user.gender!)
                  : null,
            ),
            _InfoRow(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: user.dob != null ? _fmtDate(user.dob!) : null,
            ),
            _InfoRow(
              icon: Icons.height,
              label: 'Height',
              value: user.height != null
                  ? '${user.height!.toStringAsFixed(1)} cm'
                  : null,
            ),
            _InfoRow(
              icon: Icons.monitor_weight_outlined,
              label: 'Weight',
              value: user.weight != null
                  ? '${user.weight!.toStringAsFixed(1)} kg'
                  : null,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onToggleActive,
                icon: Icon(
                  _isActive ? Icons.block : Icons.check_circle_outline,
                  size: 18,
                  color: _isActive ? AppColors.warning : AppColors.success,
                ),
                label: Text(
                  _isActive ? 'Deactivate' : 'Reactivate',
                  style: TextStyle(
                      color: _isActive ? AppColors.warning : AppColors.success),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: _isActive ? AppColors.warning : AppColors.success),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime dt) {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.subtitle.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isNA = value == null || value!.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isNA ? 'N/A' : value!,
              style: isNA
                  ? AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    )
                  : AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
