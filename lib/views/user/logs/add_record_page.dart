import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  int _selectedType = 0;
  final List<String> _types = ['BP', 'Sugar', 'Weight', 'SpO2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Save logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline),
                SizedBox(width: 8),
                Text('Save Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildInputRow(),
            const SizedBox(height: 24),
            _buildPulseInput(),
            const SizedBox(height: 24),
            _buildDateTimeSelector(),
            const SizedBox(height: 32),
            _buildAIHealthTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_types.length, (index) {
          final isSelected = _selectedType == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _types[index],
                    style: AppTextStyles.subtitle.copyWith(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYSTOLIC', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildInputField('120', 'mmHg', false),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DIASTOLIC', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildInputField('95', 'mmHg', true), // Shows slight error
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 12),
                  const SizedBox(width: 4),
                  Text('Slightly high', style: AppTextStyles.bodySmall.copyWith(color: Colors.red, fontSize: 10)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPulseInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PULSE', style: AppTextStyles.label),
        const SizedBox(height: 8),
        _buildInputField('72', 'bpm', false),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATE & TIME', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withAlpha(30)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Today, 10:45 AM', style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87, fontWeight: FontWeight.w500))),
              const Icon(Icons.expand_more, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String hint, String unit, bool hasError) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red.withAlpha(80) : Colors.grey.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: AppTextStyles.h2.copyWith(color: hasError ? Colors.red : AppColors.textPrimary),
            ),
          ),
          Text(unit, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAIHealthTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI HEALTH TIP', style: AppTextStyles.label.copyWith(color: AppColors.success)),
                const SizedBox(height: 4),
                Text(
                  "Your diastolic reading is higher than your usual average. Ensure you've been resting for 5 minutes before recording.",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
