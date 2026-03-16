import 'package:flutter/material.dart';

class AdminAiConfigViewModel extends ChangeNotifier {
  static const _defaultPrompt =
      'You are a helpful home health assistant. Analyze the user\'s vitals '
      '(Blood pressure, Blood sugar, SpO2) and provide concise, actionable advice...';
  static const double _defaultTemperature = 0.7;
  static const int _defaultMaxTokens = 256;

  String _prompt = _defaultPrompt;
  double _temperature = _defaultTemperature;
  int _maxTokens = _defaultMaxTokens;
  bool _hasChanges = false;
  bool _isSaving = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  String get prompt => _prompt;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  bool get hasChanges => _hasChanges;
  bool get isSaving => _isSaving;

  // ── Commands ───────────────────────────────────────────────────────────────

  void setPrompt(String value) {
    _prompt = value;
    _hasChanges = true;
    notifyListeners();
  }

  void setTemperature(double value) {
    _temperature = value;
    _hasChanges = true;
    notifyListeners();
  }

  void setMaxTokens(int value) {
    _maxTokens = value;
    _hasChanges = true;
    notifyListeners();
  }

  Future<void> save() async {
    _isSaving = true;
    notifyListeners();
    // TODO: persist to Supabase when table is ready
    await Future.delayed(const Duration(milliseconds: 300));
    _hasChanges = false;
    _isSaving = false;
    notifyListeners();
  }

  void resetToDefaults() {
    _prompt = _defaultPrompt;
    _temperature = _defaultTemperature;
    _maxTokens = _defaultMaxTokens;
    _hasChanges = false;
    notifyListeners();
  }
}
