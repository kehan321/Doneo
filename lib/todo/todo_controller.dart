// To-Do Controller using GetX
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';

class TodoController extends GetxController {
  final String apiUrl = "https://jsonplaceholder.typicode.com/todos";
  var todos = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  TextEditingController taskController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();


  @override
  void onInit() {
    fetchTodos();
    super.onInit();
  }

  // Fetch Todos
  Future<void> fetchTodos() async {
    isLoading(true);
    final response = await http.get(Uri.parse("$apiUrl?_limit=5"));
    if (response.statusCode == 200) {
      todos.assignAll(
          List<Map<String, dynamic>>.from(jsonDecode(response.body)));
    }
    isLoading(false);
  }

  // Add Todo
  Future<void> addTodo(String title) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "completed": false}),
    );
    if (response.statusCode == 201) {
      todos.insert(0, jsonDecode(response.body));
      taskController.clear();
    }
  }

  // Delete Todo
  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse("$apiUrl/$id"));
    if (response.statusCode == 200) {
      todos.removeWhere((todo) => todo['id'] == id);
    }
  }

  // Update Todo (Title + Completed Status)
  Future<void> updateTodo(int id, String newTitle, bool completed) async {
    final response = await http.put(
      Uri.parse("$apiUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": newTitle, "completed": completed}),
    );

    if (response.statusCode == 200) {
      int index = todos.indexWhere((todo) => todo['id'] == id);
      if (index != -1) {
        todos[index] = {"id": id, "title": newTitle, "completed": completed};
        todos.refresh(); // Update UI
      }
    }
  }

  void deleteAllTodos() {
  todos.clear();
  update();
}

  void _startListeningForEdit(TextEditingController controller) async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(onResult: (result) {
        controller.text = result.recognizedWords;
      });
    }
  }


}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Notification package
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class TodoController extends GetxController {
//   final String apiUrl = "https://jsonplaceholder.typicode.com/todos";
//   var todos = <Map<String, dynamic>>[].obs;
//   var isLoading = true.obs;
//   TextEditingController taskController = TextEditingController();
//   final SpeechToText _speechToText = SpeechToText();
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void onInit() {
//     fetchTodos();
//     _initializeNotifications();
//     super.onInit();
//   }

//   // Initialize local notifications
//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   // Fetch Todos
//   Future<void> fetchTodos() async {
//     isLoading(true);
//     final response = await http.get(Uri.parse("$apiUrl?_limit=5"));
//     if (response.statusCode == 200) {
//       todos.assignAll(
//           List<Map<String, dynamic>>.from(jsonDecode(response.body)));
//     }
//     isLoading(false);
//   }

//   // Add Todo with start and end time
//   Future<void> addTodoWithTimes(String title, TimeOfDay startTime, TimeOfDay endTime) async {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "title": title,
//         "completed": false,
//         "startTime": startTime.format(Get.context!),
//         "endTime": endTime.format(Get.context!)
//       }),
//     );
//     if (response.statusCode == 201) {
//       todos.insert(0, jsonDecode(response.body));
//       taskController.clear();
//       _scheduleEndTimeNotification(endTime, title);
//     }
//   }

//   // Schedule notification at end time
//   void _scheduleEndTimeNotification(TimeOfDay endTime, String taskTitle) async {
//     tz.initializeTimeZones();
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledTime = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       endTime.hour,
//       endTime.minute,
//     );

//     if (scheduledTime.isBefore(now)) {
//       scheduledTime = scheduledTime.add(Duration(days: 1));
//     }

//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'task_channel',
//       'Task Notifications',
//       channelDescription: 'Notification channel for task completion',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Task Completed!',
//       'Your task "$taskTitle" is completed.',
//       scheduledTime,
//       platformChannelSpecifics,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   // Delete Todo
//   Future<void> deleteTodo(int id) async {
//     final response = await http.delete(Uri.parse("$apiUrl/$id"));
//     if (response.statusCode == 200) {
//       todos.removeWhere((todo) => todo['id'] == id);
//     }
//   }

//   // Update Todo (Title + Completed Status)
//   Future<void> updateTodo(int id, String newTitle, bool completed) async {
//     final response = await http.put(
//       Uri.parse("$apiUrl/$id"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"title": newTitle, "completed": completed}),
//     );

//     if (response.statusCode == 200) {
//       int index = todos.indexWhere((todo) => todo['id'] == id);
//       if (index != -1) {
//         todos[index] = {"id": id, "title": newTitle, "completed": completed};
//         todos.refresh(); // Update UI
//       }
//     }
//   }

//   void deleteAllTodos() {
//     todos.clear();
//     update();
//   }

//   void _startListeningForEdit(TextEditingController controller) async {
//     bool available = await _speechToText.initialize();
//     if (available) {
//       _speechToText.listen(onResult: (result) {
//         controller.text = result.recognizedWords;
//       });
//     }
//   }

//   // Periodically check if any task is completed
//   void checkForCompletedTasks() {
//     final now = DateTime.now();
//     for (var todo in todos) {
//       if (todo['completed'] == false) {
//         final endTime = _parseTime(todo['endTime']);
//         if (now.isAfter(endTime)) {
//           updateTodo(todo['id'], todo['title'], true); // Mark task as completed
//           _scheduleEndTimeNotification(endTime as TimeOfDay, todo['title']);
//         }
//       }
//     }
//   }

//   // Parse time string to DateTime
//   DateTime _parseTime(String time) {
//     final parts = time.split(':');
//     final hour = int.parse(parts[0]);
//     final minute = int.parse(parts[1]);
//     final now = DateTime.now();
//     return DateTime(now.year, now.month, now.day, hour, minute);
//   }
// }
