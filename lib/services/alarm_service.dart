import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'storage_service.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._();
  factory AlarmService() => _instance;
  AlarmService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_resolveTimeZone()));

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(initSettings);

    // Re-schedule alarm if it was enabled before app restart
    final storage = StorageService();
    await storage.init();
    if (storage.isAlarmEnabled()) {
      await scheduleAlarm(storage.getAlarmHour(), storage.getAlarmMinute());
    }

    _initialized = true;
  }

  String _resolveTimeZone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      // Try common timezones matching offset
      final hours = offset.inHours;
      final knownZones = {
        3: 'Europe/Moscow',
        5: 'Asia/Yekaterinburg',
        6: 'Asia/Almaty',
        2: 'Europe/Helsinki',
        1: 'Europe/Berlin',
        0: 'Europe/London',
        -5: 'America/New_York',
        -6: 'America/Chicago',
        -7: 'America/Denver',
        -8: 'America/Los_Angeles',
        4: 'Asia/Dubai',
        9: 'Asia/Tokyo',
        10: 'Australia/Sydney',
      };
      return knownZones[hours] ?? 'UTC';
    } catch (_) {
      return 'UTC';
    }
  }

  Future<bool> requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleAlarm(int hour, int minute) async {
    await cancelAlarm();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(iOS: iosDetails);

    await _plugin.zonedSchedule(
      0,
      '⏰ Wake Up!',
      'Time to rise and build your tower! 🏰',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Alarm scheduled for: $scheduledDate');

    // Verify it was scheduled
    final pending = await _plugin.pendingNotificationRequests();
    debugPrint('Pending notifications: ${pending.length}');
  }

  Future<void> cancelAlarm() async {
    await _plugin.cancel(0);
  }

  /// Call when alarm settings change while alarm is enabled
  Future<void> updateAlarmIfEnabled() async {
    final storage = StorageService();
    await storage.init();
    if (storage.isAlarmEnabled()) {
      await scheduleAlarm(storage.getAlarmHour(), storage.getAlarmMinute());
    }
  }

  /// Send a test notification after 5 seconds
  Future<void> sendTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(iOS: iosDetails);

    await _plugin.zonedSchedule(
      99,
      '🧪 Test Notification',
      'If you see this, notifications work! 🏰',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Test notification scheduled for: $scheduledDate');
  }
}
