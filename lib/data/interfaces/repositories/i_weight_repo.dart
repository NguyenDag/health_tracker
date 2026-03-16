import '../../../domain/entities/weight_record.dart';

abstract class IWeightRepo {
  Future<bool> addRecord(WeightRecord record);
}