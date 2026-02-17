import 'package:daily_finance_tracker/core/constants/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _configureLocalTimeZone();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    // Android 14+ can block exact alarms unless user explicitly allows them.
    // Ask once during initialization; scheduling still falls back to inexact.
    try {
      final canExact = await androidPlugin?.canScheduleExactNotifications();
      if (canExact == false) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    } catch (_) {}

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleDailyReminder(String time) async {
    final parts = time.split(':');
    final hour = int.parse(parts.first);
    final minute = int.parse(parts.last);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await androidPlugin?.areNotificationsEnabled();
    if (enabled == false) {
      final requested = await androidPlugin?.requestNotificationsPermission();
      if (requested == false) {
        throw PlatformException(
          code: 'notifications_not_permitted',
          message: 'Notification permission denied.',
        );
      }
    }

    await _notifications.cancel(1);

    try {
      await _notifications.zonedSchedule(
        1,
        AppConstants.appName,
        AppConstants.reminderMessage,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminder',
            channelDescription: 'Daily expense reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') rethrow;

      await _notifications.zonedSchedule(
        1,
        AppConstants.appName,
        AppConstants.reminderMessage,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminder',
            channelDescription: 'Daily expense reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelDailyReminder() => _notifications.cancel(1);

  Future<void> _configureLocalTimeZone() async {
    try {
      final localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      // Keep timezone fallback if local timezone lookup is unavailable.
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
