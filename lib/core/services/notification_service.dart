import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const int _fixedId = 101;
  static const int _smartId = 102;
  static const String _channelId = 'health_reminder';
  static const String _channelName = 'Nhắc nhở sức khỏe';
  static const String _keyLastSubmit = 'health_last_submit_date';

  // Badge dùng để phân biệt loại reminder trong DB
  static const String _badgeFixed = 'fixed_reminder';
  static const String _badgeSmart = 'smart_reminder';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  // ── Fixed Reminder ────────────────────────────────────────────────────────

  Future<void> scheduleFixedReminder(TimeOfDay time) async {
    final scheduled = _nextOccurrence(time);
    await _plugin.cancel(_fixedId);
    await _plugin.zonedSchedule(
      _fixedId,
      'Nhắc nhở sức khỏe 💪',
      'Đừng quên ghi lại chỉ số sức khỏe hôm nay nhé!',
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    // Lưu vào lịch sử thông báo trong app
    await _upsertHistory(
      badge: _badgeFixed,
      title: 'Nhắc nhở sức khỏe 💪',
      body: 'Đừng quên ghi lại chỉ số sức khỏe hôm nay nhé!',
      triggeredAt: scheduled,
    );
  }

  Future<void> cancelFixedReminder() => _plugin.cancel(_fixedId);

  // ── Smart Reminder ────────────────────────────────────────────────────────

  Future<void> scheduleSmartReminder(TimeOfDay deadline) async {
    final scheduled = _nextOccurrence(deadline);
    await _plugin.cancel(_smartId);
    await _plugin.zonedSchedule(
      _smartId,
      'Bạn chưa ghi chỉ số hôm nay 📋',
      'Hãy ghi lại để theo dõi sức khỏe tốt hơn!',
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    await _upsertHistory(
      badge: _badgeSmart,
      title: 'Bạn chưa ghi chỉ số hôm nay 📋',
      body: 'Hãy ghi lại để theo dõi sức khỏe tốt hơn!',
      triggeredAt: scheduled,
    );
  }

  Future<void> cancelSmartReminder() => _plugin.cancel(_smartId);

  /// Reschedule smart reminder cho ngày MAI sau khi user submit data.
  Future<void> _rescheduleSmartForTomorrow(TimeOfDay deadline) async {
    await _plugin.cancel(_smartId);
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day + 1,
      deadline.hour, deadline.minute,
    );
    await _plugin.zonedSchedule(
      _smartId,
      'Bạn chưa ghi chỉ số hôm nay 📋',
      'Hãy ghi lại để theo dõi sức khỏe tốt hơn!',
      tomorrow,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    await _upsertHistory(
      badge: _badgeSmart,
      title: 'Bạn chưa ghi chỉ số hôm nay 📋',
      body: 'Hãy ghi lại để theo dõi sức khỏe tốt hơn!',
      triggeredAt: tomorrow,
    );
  }

  /// Gọi sau mỗi lần user lưu record thành công.
  static Future<void> markSubmittedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSubmit, _todayKey());

    final smartEnabled = prefs.getBool('smart_reminder_enabled') ?? false;
    if (smartEnabled) {
      final hour = prefs.getInt('smart_reminder_hour') ?? 20;
      final minute = prefs.getInt('smart_reminder_minute') ?? 0;
      await instance._rescheduleSmartForTomorrow(
          TimeOfDay(hour: hour, minute: minute));
    }
  }

  // ── Supabase History ──────────────────────────────────────────────────────

  /// Xóa các record tương lai cùng badge, sau đó insert record mới.
  /// Nếu không có user đăng nhập hoặc lỗi mạng → bỏ qua, không crash.
  Future<void> _upsertHistory({
    required String badge,
    required String title,
    required String body,
    required tz.TZDateTime triggeredAt,
  }) async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now().toIso8601String();

      // Xóa record tương lai cùng loại của user này
      await client
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('badge', badge)
          .gte('triggered_at', now);

      // Insert record mới
      await client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': 'reminder',
        'badge': badge,
        'is_read': false,
        'triggered_at': triggeredAt.toIso8601String(),
      });
    } catch (_) {
      // Lỗi mạng / chưa đăng nhập → không làm gián đoạn lên lịch thông báo
    }
  }


  // ── Helpers ───────────────────────────────────────────────────────────────

  tz.TZDateTime _nextOccurrence(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      time.hour, time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Nhắc nhở ghi chỉ số sức khỏe hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );
}
