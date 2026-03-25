import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/notification_service.dart';

class ReminderSettingsViewModel extends ChangeNotifier {
  static const _keyFixedEnabled = 'fixed_reminder_enabled';
  static const _keyFixedHour = 'fixed_reminder_hour';
  static const _keyFixedMinute = 'fixed_reminder_minute';
  static const _keySmartEnabled = 'smart_reminder_enabled';
  static const _keySmartHour = 'smart_reminder_hour';
  static const _keySmartMinute = 'smart_reminder_minute';

  bool _fixedEnabled = false;
  TimeOfDay _fixedTime = const TimeOfDay(hour: 8, minute: 0);

  bool _smartEnabled = false;
  TimeOfDay _smartDeadline = const TimeOfDay(hour: 20, minute: 0);

  bool _loading = false;

  bool get fixedEnabled => _fixedEnabled;
  TimeOfDay get fixedTime => _fixedTime;
  bool get smartEnabled => _smartEnabled;
  TimeOfDay get smartDeadline => _smartDeadline;
  bool get loading => _loading;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _fixedEnabled = prefs.getBool(_keyFixedEnabled) ?? false;
    _fixedTime = TimeOfDay(
      hour: prefs.getInt(_keyFixedHour) ?? 8,
      minute: prefs.getInt(_keyFixedMinute) ?? 0,
    );
    _smartEnabled = prefs.getBool(_keySmartEnabled) ?? false;
    _smartDeadline = TimeOfDay(
      hour: prefs.getInt(_keySmartHour) ?? 20,
      minute: prefs.getInt(_keySmartMinute) ?? 0,
    );

    _loading = false;
    notifyListeners();
  }

  // ── Fixed Reminder ────────────────────────────────────────────────────────

  Future<void> toggleFixed(bool enabled) async {
    _fixedEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFixedEnabled, enabled);

    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        await NotificationService.instance.scheduleFixedReminder(_fixedTime);
      } else {
        _fixedEnabled = false;
        await prefs.setBool(_keyFixedEnabled, false);
        notifyListeners();
      }
    } else {
      await NotificationService.instance.cancelFixedReminder();
    }
  }

  Future<void> setFixedTime(TimeOfDay time) async {
    _fixedTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFixedHour, time.hour);
    await prefs.setInt(_keyFixedMinute, time.minute);

    if (_fixedEnabled) {
      await NotificationService.instance.scheduleFixedReminder(time);
    }
  }

  // ── Smart Reminder ────────────────────────────────────────────────────────

  Future<void> toggleSmart(bool enabled) async {
    _smartEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySmartEnabled, enabled);

    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        await NotificationService.instance
            .scheduleSmartReminder(_smartDeadline);
      } else {
        _smartEnabled = false;
        await prefs.setBool(_keySmartEnabled, false);
        notifyListeners();
      }
    } else {
      await NotificationService.instance.cancelSmartReminder();
    }
  }

  Future<void> setSmartDeadline(TimeOfDay time) async {
    _smartDeadline = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySmartHour, time.hour);
    await prefs.setInt(_keySmartMinute, time.minute);

    if (_smartEnabled) {
      await NotificationService.instance.scheduleSmartReminder(time);
    }
  }
}
