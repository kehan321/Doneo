// import 'package:doneo/splash/splash_screen.dart';
// import 'package:doneo/todo/todo.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';

// import 'package:firebase_core/firebase_core.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Ensures bindings are initialized
//   await Firebase.initializeApp(); // Initialize Firebase

//   runApp(GetMaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: TodoScreen(),
//   ));
// }

// import 'package:doneo/Notification/notification.dart';
// import 'package:flutter/material.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.init(); // Initialize notifications
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Flutter Notifications')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: NotificationService.showNotification,
//               child: Text('Show Instant Notification'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: NotificationService.scheduleNotification,
//               child: Text('Schedule Notification (5 sec)'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification Clicked: ${response.payload}");
      },
    );
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'General Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Hello!',
      'This is a local notification.',
      notificationDetails,
      payload: 'Notification Clicked',
    );
  }


Future<void> _scheduleNotification() async {
  tz.initializeTimeZones();

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Scheduled Notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await _flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    'Scheduled Notification',
    'This will appear after 5 seconds!',
    tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
    notificationDetails,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter Local Notifications")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showNotification,
                child: Text("Show Notification"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scheduleNotification,
                child: Text("Schedule Notification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
