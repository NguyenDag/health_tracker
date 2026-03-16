import '../../../domain/entities/blood_pressure.dart';

abstract class IBloodPressureRepo {
  Future<bool> addBloodPressure(
      BloodPressure bloodPressure,
      );
}