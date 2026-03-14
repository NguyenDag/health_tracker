import 'package:health_tracker/data/implementations/api/spo2_api.dart';
import 'package:health_tracker/data/implementations/mapper/spo2_mapper.dart';
import 'package:health_tracker/data/interfaces/repositories/i_spo2_repo.dart';
import 'package:health_tracker/domain/entities/spo2_record.dart';

class Spo2Repo implements ISpo2Repo{
  final Spo2Api api;
  final Spo2Mapper mapper;

  Spo2Repo({required this.api, required this.mapper});

  @override
  Future<bool> addRecord(Spo2Record spo2) async {
    try {
      // final user = api.supabase.auth.currentUser;
      //
      // if (user == null) {
      //   throw Exception("User not logged in");
      // }

      final dto = mapper.toDto(spo2, "db388042-0ab8-4d25-a121-92d1c625a7de", DateTime.now());

      await api.insertRecord(dto);

      return true;
    } catch (e) {
      print("Add Spo2 Error: $e");
      return false;
    }
  }
}