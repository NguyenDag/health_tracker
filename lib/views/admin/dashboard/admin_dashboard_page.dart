import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../viewmodels/admin_thresholds_viewmodel.dart';
import '../../../viewmodels/admin_users_viewmodel.dart';
import '../thresholds/admin_thresholds_page.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _metrics = [
  'blood_pressure_systolic',
  'blood_pressure_diastolic',
  'blood_pressure_pulse',
  'blood_sugar',
  'spo2',
];

const _metricLabels = {
  'blood_pressure_systolic': 'Systolic',
  'blood_pressure_diastolic': 'Diastolic',
  'blood_pressure_pulse': 'Pulse',
  'blood_sugar': 'Blood Sugar',
  'spo2': 'SpO2',
};

const _metricIcons = {
  'blood_pressure_systolic': Icons.favorite,
  'blood_pressure_diastolic': Icons.favorite_border,
  'blood_pressure_pulse': Icons.monitor_heart_outlined,
  'blood_sugar': Icons.water_drop_outlined,
  'spo2': Icons.air,
};

const _metricColors = {
  'blood_pressure_systolic': AppColors.error,
  'blood_pressure_diastolic': Color(0xFFE53935),
  'blood_pressure_pulse': Color(0xFFFF7043),
  'blood_sugar': Color(0xFFF57C00),
  'spo2': AppColors.success,
};

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersViewModel>().loadUsers();
      context.read<AdminThresholdsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminUsersViewModel, AdminThresholdsViewModel>(
      builder: (context, usersVM, thresholdsVM, _) {
        final totalUsers = usersVM.totalUsers;
        final newSignups = usersVM.newSignupsThisMonth;

        final grouped = thresholdsVM.grouped;

        return RefreshIndicator(
          onRefresh: () async {
            final usersVM = context.read<AdminUsersViewModel>();
            final thresholdsVM = context.read<AdminThresholdsViewModel>();
            await usersVM.loadUsers();
            await thresholdsVM.load();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ── Header ────────────────────────────────────────────
              Text('Overview', style: AppTextStyles.h1.copyWith(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                _monthLabel(DateTime.now()),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // ── Stats row ─────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_outline,
                    color: AppColors.primary,
                    label: 'Total Users',
                    value: usersVM.isLoading ? '—' : '$totalUsers',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.person_add_outlined,
                    color: const Color(0xFF7B1FA2),
                    label: 'New This Month',
                    value: usersVM.isLoading ? '—' : '$newSignups',
                  ),
                ),
              ]),
              const SizedBox(height: 28),

              // ── Threshold summary ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Threshold Config', style: AppTextStyles.h3),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminThresholdsPage()),
                    ),
                    child: Text(
                      'View all',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              thresholdsVM.isLoading
                  ? const _ThresholdSkeleton()
                  : _ThresholdSummaryCard(grouped: grouped),
            ],
          ),
        );
      },
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 14),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(fontSize: 28, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ]),
    );
  }
}

// ─── Threshold Summary Card ───────────────────────────────────────────────────

class _ThresholdSummaryCard extends StatelessWidget {
  final Map<String, List<dynamic>> grouped;
  const _ThresholdSummaryCard({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: _metrics.asMap().entries.map((entry) {
          final idx = entry.key;
          final m = entry.value;
          final rules = grouped[m] ?? [];
          final count = rules.length;
          final color = _metricColors[m] ?? AppColors.primary;
          final icon = _metricIcons[m] ?? Icons.monitor_heart_outlined;
          final label = _metricLabels[m] ?? m;
          final isLast = idx == _metrics.length - 1;

          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: AppTextStyles.subtitle
                          .copyWith(color: AppColors.textPrimary)),
                ),
                if (count == 0)
                  Text('No rules',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary))
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count ${count == 1 ? 'rule' : 'rules'}',
                      style: AppTextStyles.label
                          .copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
              ]),
            ),
            if (!isLast)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }).toList(),
      ),
    );
  }
}

// ─── Threshold Skeleton ───────────────────────────────────────────────────────

class _ThresholdSkeleton extends StatelessWidget {
  const _ThresholdSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
