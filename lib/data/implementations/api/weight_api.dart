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

  @override
  Future<List<Map<String, dynamic>>> getRecords() async {
    // final user = supabase.auth.currentUser;
    //
    // if (user == null) {
    //   throw Exception("User not logged in");
    // }

    final data = await supabase
        .from("weight_records")
        .select()
        // .eq("user_id", user.id)
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}