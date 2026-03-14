import '../../../domain/entities/blood_sugar.dart';

abstract class IBloodSugarRepo {
  Future<bool> addRecord(BloodSugar sugar);
}