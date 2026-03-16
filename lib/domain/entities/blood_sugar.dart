enum SugarUnit { mgDl, mmolL }

enum SugarMeasurementType { fasting, beforeMeal, afterMeal }

class BloodSugar {
  final double glucoseValue;
  final SugarUnit unit;
  final SugarMeasurementType measurementType;
  final String? note;

  BloodSugar({
    required this.glucoseValue,
    required this.unit,
    required this.measurementType,
    this.note,
  });
}
