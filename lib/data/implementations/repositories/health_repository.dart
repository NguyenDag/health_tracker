import 'package:health_tracker/data/implementations/api/blood_pressure_api.dart';
import 'package:health_tracker/data/implementations/api/blood_sugar_api.dart';
import 'package:health_tracker/data/implementations/api/spo2_api.dart';
import 'package:health_tracker/data/implementations/api/weight_api.dart';
import 'package:health_tracker/data/interfaces/repositories/ihealth_repository.dart';
import 'package:health_tracker/domain/entities/health_record.dart';

import '../../../domain/enums/health_type.dart';

class HealthRepository implements IHealthRepository {
  final BloodPressureApi bloodPressureApi;
  final BloodSugarApi bloodSugarApi;
  final Spo2Api spo2Api;
  final WeightApi weightApi;

  HealthRepository({
    required this.bloodPressureApi,
    required this.bloodSugarApi,
    required this.spo2Api,
    required this.weightApi,
  });

  @override
  Future<List<HealthRecord>> fetchRecords() async {
    List<HealthRecord> records = [];
    final bp = await bloodPressureApi.getRecords();
    final sugar = await bloodSugarApi.getRecords();
    final weight = await weightApi.getRecords();
    final spo2 = await spo2Api.getRecords();

    /// Blood Pressure
    for (var item in bp) {
      records.add(
        HealthRecord(
          id : item['id'],
          type: HealthType.BP,
          systolic: item['systolic'],
          diastolic: item['diastolic'],
          pulse: item['pulse'],
          note: item['note'],
          createdAt: DateTime.parse(item['created_at']),
        ),
      );
    }

    /// Sugar
    for (var item in sugar) {
      records.add(
        HealthRecord(
          id : item['id'],
          type: HealthType.Sugar,
          glucoseValue: (item['glucose_value'] as num?)?.toDouble(),
          glucoseUnit: item['sugar_unit'],
          note: item['note'],
          createdAt: DateTime.parse(item['created_at']),
        ),
      );
    }

    /// Weight
    for (var item in weight) {
      records.add(
        HealthRecord(
          id : item['id'],
          type: HealthType.Weight,
          weight: (item['weight'] as num).toDouble(),
          note: item['note'],
          createdAt: DateTime.parse(item['created_at']),
        ),
      );
    }

    /// SpO2
    for (var item in spo2) {
      records.add(
        HealthRecord(
          id : item['id'],
          type: HealthType.Spo2,
          spo2: item['spo2'],
          note: item['note'],
          createdAt: DateTime.parse(item['created_at']),
        ),
      );
    }

    /// sort newest first
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return records;
  }

  @override
  Future<void> deleteRecord(HealthRecord record) async{
    switch (record.type) {
      case HealthType.BP:
        await bloodPressureApi.delete(record.id!);
        break;

      case HealthType.Sugar:
        await bloodSugarApi.delete(record.id!);
        break;

      case HealthType.Weight:
        await weightApi.delete(record.id!);
        break;

      case HealthType.Spo2:
        await spo2Api.delete(record.id!);
        break;
    }
  }
}
