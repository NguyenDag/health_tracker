
import 'package:health_tracker/data/implementations/api/blood_pressure_api.dart';
import 'package:health_tracker/data/implementations/api/blood_sugar_api.dart';
import 'package:health_tracker/data/implementations/api/spo2_api.dart';
import 'package:health_tracker/data/implementations/api/weight_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:health_tracker/data/interfaces/repositories/ihealth_repository.dart';
import 'package:health_tracker/domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';

class HealthRepository implements IHealthRepository {
  final BloodPressureApi bloodPressureApi;
  final BloodSugarApi bloodSugarApi;
  final Spo2Api spo2Api;
  final WeightApi weightApi;

  final _supabase = Supabase.instance.client;

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
          result: item['result'],
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
          result: item['result'],
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
          result: item['result'],
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
          result: item['result'],
          createdAt: DateTime.parse(item['created_at']),
        ),
      );
    }

    /// sort newest first
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return records;
  }

  @override
  Future<List<HealthRecord>> fetchRecordsByType(HealthType type, {int limit = 30, DateTime? startDate}) async {
    final tableName = _getTableName(type);
    final userId = _supabase.auth.currentUser?.id;
    
    var query = _supabase
        .from(tableName)
        .select()
        .eq('user_id', userId ?? '');

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List).map((json) => _mapToHealthRecord(json, type)).toList();
  }

  @override
  Future<HealthRecord?> fetchLatestRecord(HealthType type) async {
    final tableName = _getTableName(type);
    final userId = _supabase.auth.currentUser?.id;
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', userId ?? '')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return _mapToHealthRecord(response, type);
    } catch (e) {
      rethrow;
    }
  }

  String _getTableName(HealthType type) {
    switch (type) {
      case HealthType.BP:
        return 'blood_pressure_records';
      case HealthType.Sugar:
        return 'blood_sugar_records';
      case HealthType.Weight:
        return 'weight_records';
      case HealthType.Spo2:
        return 'spo2_condition_records';
    }
  }

  HealthRecord _mapToHealthRecord(Map<String, dynamic> json, HealthType type) {
    return HealthRecord(
      id: json['id'].toString(),
      type: type,
      createdAt: DateTime.parse(json['created_at']),
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      pulse: json['pulse'],
      glucoseValue: json['glucose_value']?.toDouble(),
      glucoseUnit: json['sugar_unit'],
      weight: json['weight']?.toDouble(),
      spo2: json['spo2'],
    );
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
