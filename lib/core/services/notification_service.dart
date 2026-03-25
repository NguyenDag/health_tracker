import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Lên lịch nhắc cố định mỗi ngày lúc [time].
  Future<void> scheduleFixedReminder(TimeOfDay time) async {
    await cancelFixedReminder();
    await _plugin.zonedSchedule(
      _fixedId,
      'Nhắc nhở sức khỏe 💪',
      'Đừng quên ghi lại chỉ số sức khỏe hôm nay nhé!',
      _nextOccurrence(time),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelFixedReminder() => _plugin.cancel(_fixedId);

  // ── Smart Reminder ────────────────────────────────────────────────────────

  /// Lên lịch smart reminder mỗi ngày lúc [deadline].
  /// Nếu user submit hôm nay trước deadline → notification bị cancel
  /// rồi reschedule cho ngày mai.
  Future<void> scheduleSmartReminder(TimeOfDay deadline) async {
    await cancelSmartReminder();
    await _plugin.zonedSchedule(
      _smartId,
      'Bạn chưa ghi chỉ số hôm nay 📋',
      'Hãy ghi lại để theo dõi sức khỏe tốt hơn!',
      _nextOccurrence(deadline),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelSmartReminder() => _plugin.cancel(_smartId);

  /// Reschedule smart reminder cho ngày MAI (dùng sau khi user submit).
  Future<void> _rescheduleSmartForTomorrow(TimeOfDay deadline) async {
    await cancelSmartReminder();
    final now = tz.TZDateTime.now(tz.local);
    // Tính thời điểm ngày mai cùng giờ
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      deadline.hour,
      deadline.minute,
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
  }

  /// Gọi SAU MỖI LẦN user lưu record thành công.
  /// Lưu ngày hôm nay + reschedule smart reminder cho ngày mai.
  static Future<void> markSubmittedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSubmit, _todayKey());

    // Nếu smart reminder đang bật → skip hôm nay, reschedule cho ngày mai
    final smartEnabled = prefs.getBool('smart_reminder_enabled') ?? false;
    if (smartEnabled) {
      final hour = prefs.getInt('smart_reminder_hour') ?? 20;
      final minute = prefs.getInt('smart_reminder_minute') ?? 0;
      await instance._rescheduleSmartForTomorrow(
          TimeOfDay(hour: hour, minute: minute));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Tính thời điểm tiếp theo của [time] (hôm nay hoặc ngày mai nếu đã qua).
  tz.TZDateTime _nextOccurrence(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
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
