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

  @override
  Future<List<Map<String, dynamic>>> getRecords() async {
    // final user = supabase.auth.currentUser;
    //
    // if (user == null) {
    //   throw Exception("User not logged in");
    // }

    final data = await supabase
        .from("spo2_condition_records")
        .select()
        // .eq("user_id", user.id)
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

}