class WeightRecordDto {
  final String? id;
  final double weight;
  final double? bodyFat;
  final String? result;
  final String? note;
  final String userId;
  final DateTime createdAt;

  WeightRecordDto({
    required this.weight,
    this.bodyFat,
    this.note,
    required this.userId,
    required this.createdAt,
    this.id,
    this.result,
  });

  Map<String, dynamic> toJson() {
    return {
      "weight": weight,
      "body_fat": bodyFat,
      "note": note,
      "user_id": userId,
      "created_at": createdAt.toIso8601String(),
    };
  }

  factory WeightRecordDto.fromJson(Map<String, dynamic> json) {
    return WeightRecordDto(
      id: json["id"],
      weight: json["weight"],
      bodyFat: json["body_fat"],
      note: json["note"],
      result: json["result"],
      userId: json["user_id"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
