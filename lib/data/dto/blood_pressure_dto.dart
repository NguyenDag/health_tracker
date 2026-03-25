class BloodPressureRecordDto {

  final String? id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String? note;
  final String? result;
  final String userId;
  final DateTime createdAt;

  BloodPressureRecordDto({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.note,
    this.result,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "systolic": systolic,
      "diastolic": diastolic,
      "pulse": pulse,
      "note": note,
      "user_id": userId,
      "created_at": createdAt.toIso8601String(),
    };
  }

  factory BloodPressureRecordDto.fromJson(Map<String, dynamic> json) {
    return BloodPressureRecordDto(
      id: json["id"],
      systolic: json["systolic"],
      diastolic: json["diastolic"],
      pulse: json["pulse"],
      note: json["note"],
      result: json["result"],
      userId: json["user_id"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}