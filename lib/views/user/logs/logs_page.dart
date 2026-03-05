import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/logs/input_record_page.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'add_record_page.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search records',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background, // Match search bar background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', isSelected: true),
                      const SizedBox(width: 8),
                      _buildFilterChip('BP', showDropdown: true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sugar', showDropdown: true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Weight', showDropdown: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80), // Space for fab navigation
              children: [
                _buildDateHeader('TODAY'),
                _buildLogItem('118/76', 'mmHg', 'Blood Pressure', '09:15 AM', Icons.favorite_border, AppColors.primary, AppColors.bloodPressureBg, null),
                const Divider(),
                _buildLogItem('142', 'mg/dL', 'Blood Sugar', '07:30 AM', Icons.water_drop_outlined, Colors.red[300]!, Colors.red[50]!, 'HIGH'),
                const Divider(),
                
                _buildDateHeader('YESTERDAY'),
                _buildLogItem('74.2', 'kg', 'Weight', '08:00 PM', Icons.monitor_weight_outlined, Colors.blue[600]!, AppColors.spo2Bg, null),
                const Divider(),
                _buildLogItem('98', '%', 'SpO2', '02:45 PM', Icons.air, Colors.blue, AppColors.spo2Bg, null),
                const Divider(),
                _buildLogItem('122/82', 'mmHg', 'Blood Pressure', '08:30 AM', Icons.favorite_border, AppColors.primary, AppColors.bloodPressureBg, null),
                const Divider(),
                
                _buildDateHeader('OCT 24, 2023'),
                _buildLogItem('105', 'mg/dL', 'Blood Sugar', '10:15 PM', Icons.water_drop_outlined, Colors.red[300]!, Colors.red[50]!, null),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, bool showDropdown = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (showDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textPrimary)
          ]
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        date,
        style: AppTextStyles.label.copyWith(letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildLogItem(
    String value,
    String unit,
    String subtitle,
    String time,
    IconData icon,
    Color iconColor,
    Color bgColor,
    String? statusBadge,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value, style: AppTextStyles.h2),
          const SizedBox(width: 4),
          Text(unit, style: AppTextStyles.bodySmall),
        ],
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMedium),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: AppTextStyles.bodySmall),
          if (statusBadge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusBadge,
                style: AppTextStyles.label.copyWith(color: Colors.red[700], fontSize: 10),
              ),
            ),
          ] else
            const SizedBox(height: 18), // Spacer to push the arrow down
        ],
      ),
    );
  }
}
