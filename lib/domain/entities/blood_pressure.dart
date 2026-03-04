class BloodPressure {
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime measuredAt;
  final String? note;

  BloodPressure({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.measuredAt,
    this.note,
  });
}