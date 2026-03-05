import '../enums/health_type.dart';

class HealthRecord {
  final String id;
  final HealthType type;
  final DateTime measuredAt;

  final int? systolic;
  final int? diastolic;
  final int? pulse;

  final double? glucose;
  final String? glucoseUnit;

  final double? weight;

  final int? spo2;

  HealthRecord({
    required this.id,
    required this.type,
    required this.measuredAt,
    this.systolic,
    this.diastolic,
    this.pulse,
    this.glucose,
    this.glucoseUnit,
    this.weight,
    this.spo2,
  });
}