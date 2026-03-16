import '../../../core/network/supabase_config.dart';
import '../../../domain/entities/threshold.dart';
import '../../interfaces/repositories/i_threshold_repository.dart';

class ThresholdRepository implements IThresholdRepository {
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
}
