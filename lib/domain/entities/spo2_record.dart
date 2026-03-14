enum Spo2Condition { resting, afterExercise }

class Spo2Record {
  final int spo2;
  final Spo2Condition condition;
  final String? note;

  Spo2Record({
    required this.spo2,
    required this.condition,
    this.note,
  });
}