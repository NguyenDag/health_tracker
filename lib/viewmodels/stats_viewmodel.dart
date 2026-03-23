import 'package:flutter/material.dart';
import '../data/implementations/repositories/threshold_repository.dart';
import '../data/interfaces/repositories/i_health_repository.dart';
import '../domain/entities/health_record.dart';
import '../domain/entities/threshold.dart';
import '../domain/enums/health_type.dart';

class StatsViewModel extends ChangeNotifier {
  final IHealthRepository _healthRepo;
  final ThresholdRepository _thresholdRepo = ThresholdRepository();

  StatsViewModel(this._healthRepo);

  List<HealthRecord> _records = [];
  bool _isLoading = false;
  String? _error;
  HealthType _activeType = HealthType.BP;
  int _selectedSegment = 2; // 0: Day, 1: Week, 2: Month, 3: Year

  HealthThreshold? thresholdSystolic;
  HealthThreshold? thresholdSugar;
  HealthThreshold? thresholdSpo2;

  List<HealthRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  HealthType get activeType => _activeType;
  int get selectedSegment => _selectedSegment;

  void setActiveType(HealthType type, {bool force = false}) {
    if (_activeType == type && !force && _records.isNotEmpty) return;
    _activeType = type;
    fetchRecords();
  }

  void setSegment(int index) {
    if (_selectedSegment == index) return;
    _selectedSegment = index;
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      DateTime? startDate;
      int limit = 100;

      switch (_selectedSegment) {
        case 0: // Day
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 1: // Week
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 2: // Month
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 3: // Year
          startDate = now.subtract(const Duration(days: 365));
          break;
      }

      _records = await _healthRepo.fetchRecordsByType(_activeType, limit: limit, startDate: startDate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    try {
      final list = await _thresholdRepo.getUserThresholds();
      thresholdSystolic = _find(list, 'blood_pressure_systolic');
      thresholdSugar = _find(list, 'blood_sugar');
      thresholdSpo2 = _find(list, 'spo2');
      notifyListeners();
    } catch (_) {}
  }

  HealthThreshold? _find(List<HealthThreshold> list, String type) {
    try {
      return list.firstWhere((t) => t.metricType == type);
    } catch (_) {
      return null;
    }
  }
}
