import '../enums/health_type.dart';

class HealthRecord {
  final String? id;
  final HealthType type;
  final DateTime createdAt;

  final int? systolic;
  final int? diastolic;
  final int? pulse;

  final double? glucoseValue;
  final String? glucoseUnit;
  final String? result;
  final double? weight;
  final double? bodyFat;
  final String? note;
  final int? spo2;

  HealthRecord({
    this.id,
    required this.type,
    required this.createdAt,
    this.systolic,
    this.diastolic,
    this.pulse,
    this.glucoseValue,
    this.glucoseUnit,
    this.weight,
    this.spo2,
    this.result,
    this.note,
    this.bodyFat,
  });
}
