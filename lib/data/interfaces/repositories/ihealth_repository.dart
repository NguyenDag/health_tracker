import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';

abstract class IHealthRepository {
  Future<List<HealthRecord>> fetchRecords();
  Future<void> deleteRecord(HealthRecord record);
  Future<List<HealthRecord>> fetchRecordsByType(HealthType type, {int limit = 30, DateTime? startDate});
  Future<HealthRecord?> fetchLatestRecord(HealthType type);
}