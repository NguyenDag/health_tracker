import '../../../domain/entities/weight_record.dart';
import '../../dto/weight_dto.dart';

class WeightMapper {
  WeightRecordDto toDto(
    WeightRecord record,
    String userId,
    DateTime createdAt,
  ) {
    return WeightRecordDto(
      weight: record.weight,
      bodyFat: record.bodyFat,
      note: record.note,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
