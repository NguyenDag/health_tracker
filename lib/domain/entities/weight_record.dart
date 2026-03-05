class WeightRecord {
  final double weight;
  final DateTime measuredAt;
  final double? bodyFat;
  final String? note;

  WeightRecord({
    required this.weight,
    required this.measuredAt,
    this.bodyFat,
    this.note,
  });
}