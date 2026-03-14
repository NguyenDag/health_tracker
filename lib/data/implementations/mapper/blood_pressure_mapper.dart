import 'package:health_tracker/data/dto/blood_pressure_dto.dart';
import 'package:health_tracker/domain/entities/blood_pressure.dart';

class BloodPressureMapper {
  BloodPressureRecordDto toDto(
    BloodPressure bp,
    String userId,
    DateTime createdAt,
  ) {
    return BloodPressureRecordDto(
      systolic: bp.systolic,
      diastolic: bp.diastolic,
      pulse: bp.pulse,
      note: bp.note,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
