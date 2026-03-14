import '../../dto/blood_sugar_dto.dart';

abstract class IBloodSugarApi {
  Future<void> insertRecord(BloodSugarRecordDto dto);
  Future<List<Map<String, dynamic>>> getRecords();
}