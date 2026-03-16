import '../../domain/entities/spo2_record.dart';

class Spo2RecordDTO {
  final String? id;
  final int spo2;
  final String condition;
  final String? result;
  final String? note;
  final String userId;
  final DateTime createdAt;

  Spo2RecordDTO({
    required this.spo2,
    required this.condition,
    this.note,
    this.id,
    this.result,
    required this.userId,
    required this.createdAt,
  });

  factory Spo2RecordDTO.fromJson(Map<String, dynamic> json) {
    return Spo2RecordDTO(
      id: json["id"],
      spo2: (json["spo2"] as num).toInt(),
      condition: json["condition"],
      note: json["note"],
      result: json["result"],
      userId: json["user_id"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "spo2": spo2,
      "condition": condition,
      "note": note,
      "user_id": userId,
      "created_at": createdAt.toIso8601String(),
    };
  }

}
