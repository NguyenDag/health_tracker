import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:health_tracker/data/interfaces/repositories/i_health_repository.dart';
import 'package:health_tracker/domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';

class HealthRepository implements IHealthRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<HealthRecord>> fetchRecords() async {
    final userId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('blood_pressure_records')
        .select()
        .eq('user_id', userId ?? '')
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapToHealthRecord(json, HealthType.BP)).toList();
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
      measuredAt: DateTime.parse(json['created_at']),
      systolic: json['systolic'],
      diastolic: json['diastolic'],
      pulse: json['pulse'],
      glucose: json['glucose_value']?.toDouble(),
      glucoseUnit: json['sugar_unit'],
      weight: json['weight']?.toDouble(),
      spo2: json['spo2'],
    );
  }
}