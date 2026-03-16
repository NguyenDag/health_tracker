import '../../../domain/entities/threshold.dart';

abstract class IThresholdRepository {
  Future<List<HealthThreshold>> getAll();
  Future<void> add(HealthThreshold threshold);
  Future<void> update(HealthThreshold threshold);
  Future<void> delete(String id);
}
