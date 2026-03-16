import 'package:health_tracker/data/interfaces/repositories/i_blood_sugar_repo.dart';

import '../../../domain/entities/blood_sugar.dart';
import '../api/blood_sugar_api.dart';
import '../mapper/blood_sugar_mapper.dart';

class BloodSugarRepo implements IBloodSugarRepo{
  final BloodSugarApi api;
  final BloodSugarMapper mapper;

  BloodSugarRepo({required this.api, required this.mapper});

  Future<bool> addRecord(BloodSugar sugar) async {
    try {
      final user = api.supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final dto = mapper.toDto(sugar, user.id, DateTime.now());

      await api.insertRecord(dto);

      return true;
    } catch (e) {
      print("Add Sugar Error: $e");
      return false;
    }
  }
}
