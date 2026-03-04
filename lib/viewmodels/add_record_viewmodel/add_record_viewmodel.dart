import 'package:flutter/material.dart';

import '../../domain/entities/blood_sugar.dart';
import '../../domain/entities/spo2_record.dart';
import '../../domain/enums/health_type.dart';

class AddRecordViewModel extends ChangeNotifier {
  HealthType selectedType = HealthType.BP;
  SugarUnit _sugarUnit = SugarUnit.mgDl;
  SugarUnit get sugarUnit => _sugarUnit;

  DateTime measuredAt = DateTime.now();

  // BP
  int systolic = 120;
  int diastolic = 80;
  int pulse = 70;
  String? bpNote;

  // Sugar
  double glucoseValue = 5.5;
  // SugarUnit sugarUnit = SugarUnit.mmolL;
  // SugarMeasurementType sugarType = SugarMeasurementType.fasting;

  // Weight
  double weight = 60;
  double? bodyFat;
  String? weightNote;

  // SpO2
  int spo2 = 98;
  // Spo2Condition spo2Condition = Spo2Condition.resting;
  String? spo2Note;

  set sugarUnit(SugarUnit value) {
    _sugarUnit = value;
    notifyListeners(); // 🔥 CÁI NÀY BẮT BUỘC
  }

  SugarMeasurementType _sugarType = SugarMeasurementType.fasting;
  SugarMeasurementType get sugarType => _sugarType;

  set sugarType(SugarMeasurementType value) {
    _sugarType = value;
    notifyListeners();
  }

  Spo2Condition _spo2Condition = Spo2Condition.resting;
  Spo2Condition get spo2Condition => _spo2Condition;

  set spo2Condition(Spo2Condition value) {
    _spo2Condition = value;
    notifyListeners();
  }


  void changeType(HealthType type) {
    selectedType = type;
    notifyListeners();
  }

  void saveMock() {
    debugPrint("Saving ${selectedType.name}");
  }
}