import 'package:health_tracker/data/dto/weight_dto.dart';

abstract class IWegihtApi {
  Future<void> insertRecord(WeightRecordDto dto);
}