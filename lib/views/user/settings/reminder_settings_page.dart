import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../viewmodels/reminder_settings_viewmodel.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderSettingsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cài đặt thông báo', style: AppTextStyles.h3),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<ReminderSettingsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                icon: Icons.access_alarm_rounded,
                iconColor: AppColors.primary,
                title: 'Nhắc nhở cố định',
                subtitle: 'Thông báo mỗi ngày đúng giờ bạn chọn, kể cả khi không mở app.',
                switchWidget: Switch(
                  value: vm.fixedEnabled,
                  onChanged: vm.toggleFixed,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withAlpha(80),
                ),
                children: [
                  if (vm.fixedEnabled) ...[
                    const Divider(height: 1),
                    _TimeTile(
                      label: 'Giờ nhắc',
                      time: vm.fixedTime,
                      onTap: () => _pickTime(
                        context,
                        current: vm.fixedTime,
                        onPicked: vm.setFixedTime,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.smart_toy_outlined,
                iconColor: AppColors.warning,
                title: 'Nhắc nhở thông minh',
                subtitle: 'Tự động nhắc nếu bạn chưa ghi chỉ số trước giờ đã đặt.',
                switchWidget: Switch(
                  value: vm.smartEnabled,
                  onChanged: vm.toggleSmart,
                  activeThumbColor: AppColors.warning,
                  activeTrackColor: AppColors.warning.withAlpha(80),
                ),
                children: [
                  if (vm.smartEnabled) ...[
                    const Divider(height: 1),
                    _TimeTile(
                      label: 'Nhắc nếu chưa ghi trước',
                      time: vm.smartDeadline,
                      onTap: () => _pickTime(
                        context,
                        current: vm.smartDeadline,
                        onPicked: vm.setSmartDeadline,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _InfoBox(
                text: 'Nhắc nhở thông minh hoạt động ngay cả khi app đóng. '
                    'Hệ thống kiểm tra định kỳ và gửi thông báo nếu bạn chưa '
                    'ghi chỉ số sức khỏe trước giờ đã đặt.',
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay current,
    required Future<void> Function(TimeOfDay) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null && mounted) await onPicked(picked);
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget switchWidget;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.switchWidget,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                switchWidget,
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ─── Time Tile ────────────────────────────────────────────────────────────────

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
            ),
            Text(
              '$h:$m',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── Info Box ─────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
