class BloodSugarRecordDto {

  final String? id;
  final double glucoseValue;
  final String sugarUnit;
  final String measurementType;
  final String? note;
  final String? result;
  final String userId;
  final DateTime createdAt;

  BloodSugarRecordDto({
    this.id,
    required this.glucoseValue,
    required this.sugarUnit,
    required this.measurementType,
    this.note,
    this.result,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "glucose_value": glucoseValue,
      "sugar_unit": sugarUnit,
      "sugar_measurement_type": measurementType,
      "note": note,
      "user_id": userId,
      "created_at": createdAt.toIso8601String(),
    };
  }

  factory BloodSugarRecordDto.fromJson(Map<String, dynamic> json) {
    return BloodSugarRecordDto(
      id: json["id"],
      glucoseValue: (json["glucose_value"] as num).toDouble(),
      sugarUnit: json["sugar_unit"],
      measurementType: json["sugar_measurement_type"],
      note: json["note"],
      result: json["result"],
      userId: json["user_id"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}