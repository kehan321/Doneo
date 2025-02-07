import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();


static Future<void> init() async {
  tz.initializeTimeZones(); // Ensure time zones are initialized

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await _notificationsPlugin.initialize(settings);

  // Request notification permission (Android 13+)
  if (await Permission.notification.request().isDenied) {
    debugPrint('Notification permission denied');
  }

  // Request exact alarm permission (Android 12+)
  if (Platform.isAndroid && await Permission.scheduleExactAlarm.request().isDenied) {
    debugPrint('Exact alarm permission denied. Go to Settings -> Apps -> Your App -> Allow Alarms.');
  }
}

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Simple kehan helo',
      'This notification appears even when the app is closed!',
      details,
    );
  }

  // static Future<void> scheduleNotification() async {
  //   await _notificationsPlugin.zonedSchedule(
  //     1,
  //     'Scheduled Notification',
  //     'This will appear in 5 seconds!',
  //     tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'scheduled_channel',
  //         'Scheduled Notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   );
  // }

static Future<void> scheduleNotification() async {
  try {
    tz.initializeTimeZones(); // Ensure time zones are initialized
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: 5));

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,  // Enable sound
      enableVibration: true, // Ensure vibration is allowed
      ongoing: false, // Prevent sticky notifications
      fullScreenIntent: true, // Ensure notification is shown in fullscreen mode
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      1,
      'Scheduled Notification',
      'This will appear in 5 seconds!',
      scheduledTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('✅ Notification scheduled successfully for: $scheduledTime');
  } catch (e) {
    debugPrint('❌ Error scheduling notification: $e');
  }
}


}
