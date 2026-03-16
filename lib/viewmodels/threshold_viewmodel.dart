import 'package:flutter/material.dart';

import '../data/implementations/repositories/threshold_repository.dart';
import '../domain/entities/threshold.dart';

class ThresholdViewModel extends ChangeNotifier {

  final ThresholdRepository repository = ThresholdRepository();

  HealthThreshold? bloodSugar;
  HealthThreshold? spo2;

  HealthThreshold? systolic;
  HealthThreshold? diastolic;
  HealthThreshold? pulse;

  bool loading = true;

  Future<void> loadThresholds() async {

    loading = true;
    notifyListeners();

    final thresholds = await repository.getUserThresholds();

    bloodSugar = _find(thresholds, "blood_sugar");
    spo2 = _find(thresholds, "spo2");

    systolic = _find(thresholds, "blood_pressure_systolic");
    diastolic = _find(thresholds, "blood_pressure_diastolic");
    pulse = _find(thresholds, "blood_pressure_pulse");

    loading = false;
    notifyListeners();
  }

  HealthThreshold? _find(List<HealthThreshold> list, String type) {
    try {
      return list.firstWhere((t) => t.metricType == type);
    } catch (e) {
      return null;
    }
  }
}