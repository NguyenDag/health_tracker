import 'package:health_tracker/data/dto/spo2_condition_dto.dart';
import 'package:health_tracker/data/interfaces/api/i_spo2_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Spo2Api implements ISpo2Api{
  final SupabaseClient supabase;

  Spo2Api({required this.supabase});

  @override
  Future<void> insertRecord(Spo2RecordDTO dto) async {
    await supabase
        .from("spo2_condition_records")
        .insert(dto.toJson());
  }

}