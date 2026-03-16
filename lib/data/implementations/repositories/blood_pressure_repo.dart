import 'package:health_tracker/data/implementations/api/blood_pressure_api.dart';
import 'package:health_tracker/data/interfaces/repositories/i_blood_pressure_repo.dart';
import 'package:health_tracker/domain/entities/blood_pressure.dart';

import '../mapper/blood_pressure_mapper.dart';

class BloodPressureRepo implements IBloodPressureRepo {
  final BloodPressureMapper mapper;
  final BloodPressureApi api;

  BloodPressureRepo({required this.mapper, required this.api});

  @override
  Future<bool> addBloodPressure(BloodPressure record) async {
    try {
      final user = api.supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final dto = mapper.toDto(record, user.id, DateTime.now());

      await api.insertBloodPressure(dto);

      return true;
    } catch (e) {
      print("Add BP Error: $e");
      return false;
    }
  }
}
