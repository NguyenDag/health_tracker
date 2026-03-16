import 'package:health_tracker/core/network/supabase_config.dart';

import '../../../domain/entities/threshold.dart';

class ApiSample {
  // =====================================================
  // AUTH
  // =====================================================

  /// Đăng ký tài khoản mới
  Future<void> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Đăng nhập
  Future<void> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Lấy user hiện tại
  String? get currentUserId => supabase.auth.currentUser?.id;

  // =====================================================
  // CRUD - BLOOD PRESSURE RECORDS
  // =====================================================

  /// SELECT - lấy danh sách theo user
  Future<List<Map<String, dynamic>>> getBloodPressureRecords() async {
    final data = await supabase
        .from('blood_pressure_records')
        .select()
        .eq('user_id', currentUserId!)
        .order('measured_at', ascending: false);
    return data;
  }

  /// INSERT - thêm record mới
  Future<void> addBloodPressureRecord({
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime measuredAt,
    String? note,
    String? result,
  }) async {
    await supabase.from('blood_pressure_records').insert({
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'measured_at': measuredAt.toIso8601String(),
      'note': note,
      'result': result,
      'user_id': currentUserId,
    });
  }

  /// UPDATE - cập nhật record
  Future<void> updateBloodPressureRecord(
    String id,
    Map<String, dynamic> data,
  ) async {
    await supabase
        .from('blood_pressure_records')
        .update(data)
        .eq('id', id);
  }

  /// DELETE - xóa record
  Future<void> deleteBloodPressureRecord(String id) async {
    await supabase
        .from('blood_pressure_records')
        .delete()
        .eq('id', id);
  }

  // =====================================================
  // CRUD - USER PROFILE
  // =====================================================

  /// Lấy profile user hiện tại
  Future<Map<String, dynamic>?> getUserProfile() async {
    final data = await supabase
        .from('users')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    return data;
  }

  /// Cập nhật profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? gender,
    double? height,
    double? weight,
    String? phone,
    DateTime? dob,
  }) async {
    final updates = <String, dynamic>{};
    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (gender != null) updates['gender'] = gender;
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;
    if (phone != null) updates['phone'] = phone;
    if (dob != null) updates['dob'] = dob.toIso8601String();

    await supabase.from('users').update(updates).eq('id', currentUserId!);
  }

  // =====================================================
  // CRUD - BLOOD SUGAR RECORDS
  // =====================================================

  Future<List<Map<String, dynamic>>> getBloodSugarRecords() async {
    final data = await supabase
        .from('blood_sugar_records')
        .select()
        .eq('user_id', currentUserId!)
        .order('measured_at', ascending: false);
    return data;
  }

  Future<void> addBloodSugarRecord({
    required double glucoseValue,
    required DateTime measuredAt,
    String? sugarUnit,
    String? sugarMeasurementType,
    String? note,
    String? result,
  }) async {
    await supabase.from('blood_sugar_records').insert({
      'glucose_value': glucoseValue,
      'measured_at': measuredAt.toIso8601String(),
      'sugar_unit': sugarUnit,
      'sugar_measurement_type': sugarMeasurementType,
      'note': note,
      'result': result,
      'user_id': currentUserId,
    });
  }

  // =====================================================
  // CRUD - SPO2 RECORDS
  // =====================================================

  Future<List<Map<String, dynamic>>> getSpo2Records() async {
    final data = await supabase
        .from('spo2_condition_records')
        .select()
        .eq('user_id', currentUserId!)
        .order('measured_at', ascending: false);
    return data;
  }

  Future<void> addSpo2Record({
    required int spo2,
    String? condition,
    required DateTime measuredAt,
    String? note,
    String? result,
  }) async {
    await supabase.from('spo2_condition_records').insert({
      'spo2': spo2,
      'condition': condition,
      'measured_at': measuredAt.toIso8601String(),
      'note': note,
      'result': result,
      'user_id': currentUserId,
    });
  }

  // =====================================================
  // CRUD - WEIGHT RECORDS
  // =====================================================

  Future<List<Map<String, dynamic>>> getWeightRecords() async {
    final data = await supabase
        .from('weight_records')
        .select()
        .eq('user_id', currentUserId!)
        .order('measured_at', ascending: false);
    return data;
  }

  Future<void> addWeightRecord({
    required double weight,
    double? bodyFat,
    required DateTime measuredAt,
    String? note,
    String? result,
  }) async {
    await supabase.from('weight_records').insert({
      'weight': weight,
      'body_fat': bodyFat,
      'measured_at': measuredAt.toIso8601String(),
      'note': note,
      'result': result,
      'user_id': currentUserId,
    });
  }

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  Future<List<Map<String, dynamic>>> getNotifications() async {
    print("id $currentUserId");
    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', currentUserId!)
        .order('triggered_at', ascending: false);
    return data;
  }

  /// Đánh dấu đã đọc
  Future<void> markNotificationAsRead(String id) async {
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }


  Future<List<HealthThreshold>> getThresholdsByAge(int age) async {

    final data = await supabase
        .from('thresholds')
        .select()
        .lte('from_age', age)
        .gte('to_age', age);

    return (data as List)
        .map((e) => HealthThreshold.fromMap(e))
        .toList();
  }
}
