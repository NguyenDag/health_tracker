import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/implementations/repositories/blood_pressure_repo.dart';
import '../../data/implementations/repositories/blood_sugar_repo.dart';
import '../../data/implementations/repositories/spo2_repo.dart';
import '../../data/implementations/repositories/weight_repo.dart';
import '../../domain/entities/blood_pressure.dart';
import '../../domain/entities/blood_sugar.dart';
import '../../domain/entities/spo2_record.dart';
import '../../domain/entities/weight_record.dart';
import '../../domain/enums/health_type.dart';
import '../../viewmodels/notification_viewmodel.dart'; // 👈 thêm
import '../../core/services/notification_service.dart';

class AddRecordViewModel extends ChangeNotifier {
  final BloodPressureRepo bpRepository;
  final BloodSugarRepo sugarRepository;
  final Spo2Repo spo2Repository;
  final WeightRepo weightRepository;
  final NotificationViewModel notificationViewModel; // 👈 thêm

  AddRecordViewModel({
    required this.bpRepository,
    required this.sugarRepository,
    required this.spo2Repository,
    required this.weightRepository,
    required this.notificationViewModel, // 👈 thêm
  });

  HealthType selectedType = HealthType.BP;
  DateTime measuredAt = DateTime.now();

  // BP
  int systolic = 120;
  int diastolic = 80;
  int pulse = 70;
  String? bpNote;

  // Sugar
  double glucoseValue = 5.5;
  SugarUnit _sugarUnit = SugarUnit.mgDl;
  SugarUnit get sugarUnit => _sugarUnit;
  set sugarUnit(SugarUnit value) {
    _sugarUnit = value;
    notifyListeners();
  }

  SugarMeasurementType _sugarType = SugarMeasurementType.fasting;
  SugarMeasurementType get sugarType => _sugarType;
  set sugarType(SugarMeasurementType value) {
    _sugarType = value;
    notifyListeners();
  }

  String? sugarNote;

  // Weight
  double weight = 60;
  double? bodyFat;
  String? weightNote;

  // SpO2
  int spo2 = 98;
  Spo2Condition _spo2Condition = Spo2Condition.resting;
  Spo2Condition get spo2Condition => _spo2Condition;
  set spo2Condition(Spo2Condition value) {
    _spo2Condition = value;
    notifyListeners();
  }

  String? spo2Note;

  void changeType(HealthType type) {
    selectedType = type;
    notifyListeners();
  }

  Future<bool> save() async {
    bool result = false;

    if (selectedType == HealthType.BP) {
      final record = BloodPressure(
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        note: bpNote,
      );
      result = await bpRepository.addBloodPressure(record);
    } else if (selectedType == HealthType.Sugar) {
      final record = BloodSugar(
        glucoseValue: glucoseValue,
        unit: sugarUnit,
        measurementType: sugarType,
        note: sugarNote,
      );
      result = await sugarRepository.addRecord(record);
    } else if (selectedType == HealthType.Spo2) {
      final record = Spo2Record(
        spo2: spo2,
        condition: spo2Condition,
        note: spo2Note,
      );
      result = await spo2Repository.addRecord(record);
    } else if (selectedType == HealthType.Weight) {
      final record = WeightRecord(
        weight: weight,
        bodyFat: bodyFat,
        note: weightNote,
      );
      result = await weightRepository.addRecord(record);
    }

    if (result) {
      // Reload notification và đánh dấu đã ghi chỉ số hôm nay
      await notificationViewModel.loadNotifications();
      await NotificationService.markSubmittedToday();
    }

    return result;
  }
}