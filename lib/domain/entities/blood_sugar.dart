enum SugarUnit { mgDl, mmolL }
enum SugarMeasurementType { fasting, beforeMeal, afterMeal }

class BloodSugar {
  final double glucoseValue;
  final SugarUnit unit;
  final DateTime measuredAt;
  final SugarMeasurementType measurementType;

  BloodSugar({
    required this.glucoseValue,
    required this.unit,
    required this.measuredAt,
    required this.measurementType,
  });
}