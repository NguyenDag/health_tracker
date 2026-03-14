import 'package:health_tracker/data/interfaces/repositories/i_weight_repo.dart';
import 'package:health_tracker/domain/entities/weight_record.dart';

import '../api/weight_api.dart';
import '../mapper/weight_mapper.dart';

class WeightRepo implements IWeightRepo{
  final WeightApi api;
  final WeightMapper mapper;

  WeightRepo({
    required this.api,
    required this.mapper,
  });
  @override
  Future<bool> addRecord(WeightRecord record) async {
    try {
      // final user = api.supabase.auth.currentUser;
      //
      // if (user == null) {
      //   throw Exception("User not logged in");
      // }

      final dto = mapper.toDto(record, "db388042-0ab8-4d25-a121-92d1c625a7de", DateTime.now());

      await api.insertRecord(dto);

      return true;
    } catch (e) {
      print("Add weight error: $e");
      return false;
    }
  }
}