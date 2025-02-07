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



import 'package:doneo/Notification/notification.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(); // Initialize notifications
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: NotificationService.showNotification,
              child: Text('Show Instant Notification'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: NotificationService.scheduleNotification,
              child: Text('Schedule Notification (5 sec)'),
            ),
          ],
        ),
      ),
    );
  }
}

