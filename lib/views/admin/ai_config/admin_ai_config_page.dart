import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../viewmodels/admin_ai_config_viewmodel.dart';

class AdminAiConfigPage extends StatelessWidget {
  const AdminAiConfigPage({super.key});

  static const _accentColor = Color(0xFF7C3AED);

  void _confirmReset(BuildContext context, AdminAiConfigViewModel vm) {
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
              vm.resetToDefaults();
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
    return Consumer<AdminAiConfigViewModel>(
      builder: (context, vm, _) {
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
                onPressed: vm.hasChanges && !vm.isSaving
                    ? () async {
                        await vm.save();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI settings saved.'),
                              backgroundColor: _accentColor,
                            ),
                          );
                        }
                      }
                    : null,
                child: vm.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _accentColor),
                      )
                    : Text(
                        'Save',
                        style: AppTextStyles.subtitle.copyWith(
                          color: vm.hasChanges
                              ? _accentColor
                              : AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── System Instructions ──────────────────────────────
              Text('System Instructions', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Text('Prompt Context', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              _PromptField(
                initialValue: vm.prompt,
                accentColor: _accentColor,
                onChanged: vm.setPrompt,
              ),
              const SizedBox(height: 8),
              Text(
                'This context defines how the AI interprets health data. Be specific about safety limits.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),

              // ── Parameters ───────────────────────────────────────
              Row(children: [
                Expanded(
                  child: _NumberField(
                    label: 'Temperature',
                    initialValue: vm.temperature.toString(),
                    hint: '0.7',
                    isDecimal: true,
                    onChanged: (v) {
                      final d = double.tryParse(v);
                      if (d != null) vm.setTemperature(d);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Max Tokens',
                    initialValue: vm.maxTokens.toString(),
                    hint: '256',
                    onChanged: (v) {
                      final i = int.tryParse(v);
                      if (i != null) vm.setMaxTokens(i);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 28),

              // ── Reset ────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context, vm),
                icon: const Icon(Icons.restart_alt,
                    color: AppColors.error, size: 18),
                label: const Text(
                  'Reset to Default Prompts',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withAlpha(60)),
                  backgroundColor: AppColors.error.withAlpha(10),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ─── Prompt Field ─────────────────────────────────────────────────────────────

class _PromptField extends StatefulWidget {
  final String initialValue;
  final Color accentColor;
  final ValueChanged<String> onChanged;
  const _PromptField({
    required this.initialValue,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  State<_PromptField> createState() => _PromptFieldState();
}

class _PromptFieldState extends State<_PromptField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => widget.onChanged(_ctrl.text));
  }

  @override
  void didUpdateWidget(_PromptField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _ctrl.text != widget.initialValue) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        maxLines: 5,
        style: AppTextStyles.bodyMedium.copyWith(color: widget.accentColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: widget.accentColor.withAlpha(80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: widget.accentColor, width: 1.5),
          ),
        ),
      );
}

// ─── Number Field ─────────────────────────────────────────────────────────────

class _NumberField extends StatefulWidget {
  final String label;
  final String initialValue;
  final String hint;
  final bool isDecimal;
  final ValueChanged<String> onChanged;
  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.hint,
    this.isDecimal = false,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => widget.onChanged(_ctrl.text));
  }

  @override
  void didUpdateWidget(_NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _ctrl.text != widget.initialValue) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.numberWithOptions(
                decimal: widget.isDecimal),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                widget.isDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
              ),
            ],
            style: AppTextStyles.subtitle
                .copyWith(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.grey.withAlpha(80)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF7C3AED)),
              ),
            ),
          ),
        ],
      );
}
