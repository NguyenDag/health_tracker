import '../../../domain/entities/health_record.dart';

abstract class IHealthRepository {
  Future<List<HealthRecord>> fetchRecords();

}