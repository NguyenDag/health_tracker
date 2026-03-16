import 'package:health_tracker/data/dto/blood_sugar_dto.dart';
import 'package:health_tracker/data/interfaces/api/i_blood_sugar_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BloodSugarApi implements IBloodSugarApi{
  final SupabaseClient supabase;

  BloodSugarApi({required this.supabase});

  @override
  Future<void> insertRecord(BloodSugarRecordDto dto) async {
    await supabase
        .from("blood_sugar_records")
        .insert(dto.toJson());
  }

  @override
  Future<List<Map<String, dynamic>>> getRecords() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final data = await supabase
        .from("blood_sugar_records")
        .select()
        .eq("user_id", user.id)
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> delete(String id) async {
    await supabase
        .from('blood_sugar_records')
        .delete()
        .eq('id', id);
  }
}