import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminAiConfigPage extends StatefulWidget {
  const AdminAiConfigPage({super.key});

  @override
  State<AdminAiConfigPage> createState() => _AdminAiConfigPageState();
}

class _AdminAiConfigPageState extends State<AdminAiConfigPage> {
  static const _defaultPrompt =
      'You are a helpful home health assistant. Analyze the user\'s vitals '
      '(Blood pressure, Blood sugar, SpO2) and provide concise, actionable advice...';

  static const _defaultTemperature = '0.7';
  static const _defaultMaxTokens = '256';

  late final TextEditingController _promptCtrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _tokensCtrl;

  bool _vitalsHistory = true;
  bool _medicationLog = true;
  bool _externalMedicalDb = false;
  bool _hasChanges = false;

  static const _accentColor = Color(0xFF7C3AED); // purple

  @override
  void initState() {
    super.initState();
    _promptCtrl = TextEditingController(text: _defaultPrompt);
    _tempCtrl = TextEditingController(text: _defaultTemperature);
    _tokensCtrl = TextEditingController(text: _defaultMaxTokens);

    for (final c in [_promptCtrl, _tempCtrl, _tokensCtrl]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _tempCtrl.dispose();
    _tokensCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI settings saved.'),
        backgroundColor: _accentColor,
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset to Defaults', style: AppTextStyles.h3),
        content: Text(
          'All AI settings will be reset to their default values.',
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
              setState(() {
                _promptCtrl.text = _defaultPrompt;
                _tempCtrl.text = _defaultTemperature;
                _tokensCtrl.text = _defaultMaxTokens;
                _vitalsHistory = true;
                _medicationLog = true;
                _externalMedicalDb = false;
                _hasChanges = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI settings reset to defaults.'),
                  backgroundColor: AppColors.textSecondary,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('AI Advice Settings', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _hasChanges ? _save : null,
            child: Text(
              'Save',
              style: AppTextStyles.subtitle.copyWith(
                color: _hasChanges ? _accentColor : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── System Instructions ──────────────────────────────────────────
          Text('System Instructions', style: AppTextStyles.h2),
          const SizedBox(height: 16),

          Text('Prompt Context', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _promptCtrl,
            maxLines: 5,
            style: AppTextStyles.bodyMedium.copyWith(color: _accentColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _accentColor.withAlpha(80)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This context defines how the AI interprets health data. Be specific about safety limits.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 20),

          // Temperature + Max Tokens
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: 'Temperature',
                  controller: _tempCtrl,
                  hint: '0.7',
                  isDecimal: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  label: 'Max Tokens',
                  controller: _tokensCtrl,
                  hint: '256',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Data Sources ─────────────────────────────────────────────────
          // Text('Data Sources', style: AppTextStyles.h2),
          // const SizedBox(height: 12),

          // _buildDataSourceTile(
          //   icon: Icons.monitor_heart_outlined,
          //   iconColor: _accentColor,
          //   iconBg: _accentColor.withAlpha(20),
          //   title: 'Vitals History',
          //   subtitle: 'Last 30 days of BP & SpO2',
          //   value: _vitalsHistory,
          //   onChanged: (v) => setState(() {
          //     _vitalsHistory = v;
          //     _hasChanges = true;
          //   }),
          // ),
          // const Divider(height: 1, indent: 16, endIndent: 16),
          // _buildDataSourceTile(
          //   icon: Icons.medical_services_outlined,
          //   iconColor: _accentColor,
          //   iconBg: _accentColor.withAlpha(20),
          //   title: 'Medication Log',
          //   subtitle: 'Active prescriptions',
          //   value: _medicationLog,
          //   onChanged: (v) => setState(() {
          //     _medicationLog = v;
          //     _hasChanges = true;
          //   }),
          // ),
          // const Divider(height: 1, indent: 16, endIndent: 16),
          // _buildDataSourceTile(
          //   icon: Icons.storage_outlined,
          //   iconColor: AppColors.textSecondary,
          //   iconBg: AppColors.background,
          //   title: 'External Medical DB',
          //   subtitle: 'Public health guidelines API',
          //   value: _externalMedicalDb,
          //   onChanged: (v) => setState(() {
          //     _externalMedicalDb = v;
          //     _hasChanges = true;
          //   }),
          // ),
          const SizedBox(height: 24),

          // Reset button
          OutlinedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(
              Icons.restart_alt,
              color: AppColors.error,
              size: 18,
            ),
            label: const Text(
              'Reset to Default Prompts',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error.withAlpha(60)),
              backgroundColor: AppColors.error.withAlpha(10),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              isDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
            ),
          ],
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withAlpha(80)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accentColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSourceTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _accentColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withAlpha(80),
          ),
        ],
      ),
    );
  }
}
