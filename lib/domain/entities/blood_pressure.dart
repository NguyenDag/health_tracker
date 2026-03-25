class BloodPressure {
  final int systolic;
  final int diastolic;
  final int pulse;
  final String? note;

  BloodPressure({
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.note,
  });
}