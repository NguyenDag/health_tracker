import 'package:health_tracker/data/dto/spo2_condition_dto.dart';

abstract class ISpo2Api {
  Future<void> insertRecord(Spo2RecordDTO dto);
  Future<List<Map<String, dynamic>>> getRecords();
}