import '../../dto/blood_pressure_dto.dart';

abstract class IBloodPressureApi {
  Future<void> insertBloodPressure(BloodPressureRecordDto dto);
  Future<List<Map<String, dynamic>>> getRecords();
}
