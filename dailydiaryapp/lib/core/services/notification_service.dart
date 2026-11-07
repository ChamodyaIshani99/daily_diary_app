import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotification() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // 1. User තෝරාගත් Time එකට Reminder එක Schedule කිරීම
  static Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    // කලින් තිබූ Schedule එක Cancel කිරීම
    await _notificationsPlugin.cancelAll();

    await _notificationsPlugin.zonedSchedule(
      1,
      "Time to write your diary! 📖",
      "How was your day? Take a moment to record your thoughts.",
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_diary_channel',
          'Daily Diary Reminders',
          channelDescription: 'Reminder to write daily diary entries',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Save Selected Time to Storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);
  }

  // 2. Saved කර ඇති Time එක Storage එකෙන් ගැනීම
  static Future<TimeOfDay> getSavedNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 20; // Default 8:00 PM
    final minute = prefs.getInt('notification_minute') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // 3. Notification Cancel කිරීම
  static Future<void> cancelNotifications() async {
    await _notificationsPlugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_hour');
    await prefs.remove('notification_minute');
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}