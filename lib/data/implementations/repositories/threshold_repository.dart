import '../../../core/network/supabase_config.dart';
import '../../../domain/entities/threshold.dart';
import '../../interfaces/repositories/i_threshold_repository.dart';
import '../api/api_sample.dart';

class ThresholdRepository implements IThresholdRepository {
  final ApiSample _api = ApiSample();
  @override
  Future<List<HealthThreshold>> getAll() async {
    final data = await supabase
        .from('thresholds')
        .select()
        .order('metric_type')
        .order('from_age');
    return (data as List)
        .map((r) => HealthThreshold.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> add(HealthThreshold threshold) async {
    await supabase.from('thresholds').insert(threshold.toMap());
  }

  @override
  Future<void> update(HealthThreshold threshold) async {
    await supabase
        .from('thresholds')
        .update(threshold.toMap())
        .eq('id', threshold.id);
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('thresholds').delete().eq('id', id);
  }

  @override
  Future<List<HealthThreshold>> getUserThresholds() async{
    final profile = await _api.getUserProfile();
    if (profile == null) {
      throw Exception("User profile not found");
    }

    DateTime birthDate = DateTime.parse(profile['dob']);

    int age = _calculateAge(birthDate);

    return _api.getThresholdsByAge(age);

  }

  int _calculateAge(DateTime birthDate) {

    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
