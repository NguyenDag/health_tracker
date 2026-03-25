import 'package:health_tracker/data/dto/spo2_condition_dto.dart';
import 'package:health_tracker/domain/entities/spo2_record.dart';

class Spo2Mapper {
  Spo2RecordDTO toDto(Spo2Record sugar, String userId, DateTime createdAt) {
    return Spo2RecordDTO(
      note: sugar.note,
      userId: userId,
      createdAt: createdAt,
      spo2: sugar.spo2,
      condition: sugar.condition.name,
    );
  }
}
