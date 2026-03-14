import '../../../domain/entities/blood_sugar.dart';
import '../../dto/blood_sugar_dto.dart';

class BloodSugarMapper {

  BloodSugarRecordDto toDto(
      BloodSugar sugar,
      String userId,
      DateTime createdAt,
      ) {

    return BloodSugarRecordDto(
      glucoseValue: sugar.glucoseValue,
      sugarUnit: sugar.unit.name,
      measurementType: sugar.measurementType.name,
      note: sugar.note,
      userId: userId,
      createdAt: createdAt,
    );
  }
}