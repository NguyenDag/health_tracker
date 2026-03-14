import 'package:health_tracker/data/dto/weight_dto.dart';
import 'package:health_tracker/data/interfaces/api/i_weight_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WeightApi implements IWegihtApi{
  final SupabaseClient supabase;

  WeightApi({required this.supabase});

  @override
  Future<void> insertRecord(WeightRecordDto dto) async {
    await supabase
        .from("weight_records")
        .insert(dto.toJson());
  }
}