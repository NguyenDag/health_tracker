import 'package:flutter/material.dart';
import '../data/interfaces/repositories/i_health_repository.dart';
import '../domain/entities/health_record.dart';
import '../domain/enums/health_type.dart';

class HomeViewModel extends ChangeNotifier {
  final IHealthRepository _healthRepo;

  HomeViewModel(this._healthRepo);

  HealthRecord? _latestBP;
  HealthRecord? _latestSugar;
  HealthRecord? _latestWeight;
  HealthRecord? _latestSpo2;

  bool _isLoading = false;
  String? _error;

  HealthRecord? get latestBP => _latestBP;
  HealthRecord? get latestSugar => _latestSugar;
  HealthRecord? get latestWeight => _latestWeight;
  HealthRecord? get latestSpo2 => _latestSpo2;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLatestVitals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _healthRepo.fetchLatestRecord(HealthType.BP),
        _healthRepo.fetchLatestRecord(HealthType.Sugar),
        _healthRepo.fetchLatestRecord(HealthType.Weight),
        _healthRepo.fetchLatestRecord(HealthType.Spo2),
      ]);

      _latestBP = results[0];
      _latestSugar = results[1];
      _latestWeight = results[2];
      _latestSpo2 = results[3];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
