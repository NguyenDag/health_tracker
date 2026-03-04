import 'package:health_tracker/data/interfaces/repositories/ihealth_repository.dart';
import 'package:health_tracker/domain/entities/health_record.dart';

import '../../../domain/enums/health_type.dart';

class HealthRepository implements IHealthRepository{
  @override
  Future<List<HealthRecord>> fetchRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      HealthRecord(
        id: "1",
        type: HealthType.BP,
        measuredAt: DateTime.now(),
        systolic: 118,
        diastolic: 76,
      ),
      HealthRecord(
        id: "2",
        type: HealthType.Sugar,
        measuredAt: DateTime.now().subtract(const Duration(hours: 2)),
        glucose: 142,
        glucoseUnit: "mg/dL",
      ),
      HealthRecord(
        id: "3",
        type: HealthType.Weight,
        measuredAt: DateTime.now().subtract(const Duration(days: 1)),
        weight: 74.2,
      ),
      HealthRecord(
        id: "4",
        type: HealthType.Spo2,
        measuredAt: DateTime.now().subtract(const Duration(days: 1)),
        spo2: 98,
      ),
    ];
  }
}