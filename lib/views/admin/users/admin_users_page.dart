import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name, ID...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.textSecondary),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Users', isSelected: true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Inactive'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Flagged'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECENTLY ACTIVE', style: AppTextStyles.label),
              Row(
                children: [
                  const Icon(Icons.sort, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Sort', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildUserCard('John Doe', '#83921', 'BP Monitoring', '25 mins ago', 'Active', AppColors.success),
              _buildUserCard('Sarah Miller', '#19204', 'Blood Sugar', '1 hour ago', 'Alert', AppColors.error),
              _buildUserCard('Michael Chen', '#99482', 'SpO2 Tracking', '3 months ago', 'Inactive', AppColors.textSecondary),
              _buildUserCard('Elara Keye', '#77213', 'Weight Control', '5 hours ago', 'Active', AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.withAlpha(50),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildUserCard(String name, String id, String tracking, String lastLogin, String status, Color statusColor) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(name[0], style: const TextStyle(color: AppColors.primary)),
        ),
        title: Row(
          children: [
            Expanded(child: Text(name, style: AppTextStyles.subtitle)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: AppTextStyles.label.copyWith(color: statusColor, fontSize: 10),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: $id • $tracking', style: AppTextStyles.bodySmall),
            const SizedBox(height: 2),
            Text('Last login: $lastLogin', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
          ],
        ),
        trailing: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      ),
    );
  }
}
