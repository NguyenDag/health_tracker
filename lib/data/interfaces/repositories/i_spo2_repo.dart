import 'package:health_tracker/domain/entities/spo2_record.dart';

abstract class ISpo2Repo {
  Future<bool> addRecord(Spo2Record spo2);
}