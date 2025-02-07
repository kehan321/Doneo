// // To-Do Controller using GetX
// import 'dart:convert';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart';

// class TodoController extends GetxController {
//   final String apiUrl = "https://jsonplaceholder.typicode.com/todos";
//   var todos = <Map<String, dynamic>>[].obs;
//   var isLoading = true.obs;
//   TextEditingController taskController = TextEditingController();
//   final SpeechToText _speechToText = SpeechToText();


//   @override
//   void onInit() {
//     fetchTodos();
//     super.onInit();
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

//   // Add Todo
//   Future<void> addTodo(String title) async {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"title": title, "completed": false}),
//     );
//     if (response.statusCode == 201) {
//       todos.insert(0, jsonDecode(response.body));
//       taskController.clear();
//     }
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
//   todos.clear();
//   update();
// }

//   void _startListeningForEdit(TextEditingController controller) async {
//     bool available = await _speechToText.initialize();
//     if (available) {
//       _speechToText.listen(onResult: (result) {
//         controller.text = result.recognizedWords;
//       });
//     }
//   }


// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart';

// class TodoController extends GetxController {
//   final String apiUrl = "https://jsonplaceholder.typicode.com/todos";
//   var todos = <Map<String, dynamic>>[].obs;
//   var isLoading = true.obs;
//   TextEditingController taskController = TextEditingController();
//   final SpeechToText _speechToText = SpeechToText();

//   @override
//   void onInit() {
//     fetchTodos();
//     super.onInit();
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

//   // Add Todo with startTime and endTime
//   void addTodoWithTimes(String title, TimeOfDay start, TimeOfDay end) async {
//     final response = await http.post(Uri.parse(apiUrl),
//         body: jsonEncode({
//           "title": title,
//           "completed": false,
//           "startTime": start.format(Get.context!),
//           "endTime": end.format(Get.context!),
//         }));
//     if (response.statusCode == 201) {
//       fetchTodos();
//     }
//   }

//   // Update Todo
//   void updateTodo(int id, String title, bool completed) async {
//     final response = await http.put(Uri.parse("$apiUrl/$id"),
//         body: jsonEncode({
//           "title": title,
//           "completed": completed,
//         }));
//     if (response.statusCode == 200) {
//       fetchTodos();
//     }
//   }

//   // Delete Todo
//   void deleteTodo(int id) async {
//     final response = await http.delete(Uri.parse("$apiUrl/$id"));
//     if (response.statusCode == 200) {
//       fetchTodos();
//     }
//   }

//   // Delete All Todos
//   void deleteAllTodos() async {
//     final response = await http.delete(Uri.parse("$apiUrl"));
//     if (response.statusCode == 200) {
//       fetchTodos();
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var todos = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  TextEditingController taskController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  /// Fetch Todos from Firestore
  Future<void> fetchTodos() async {
    isLoading(true);
    try {
      QuerySnapshot snapshot = await _firestore.collection('todos').orderBy('createdAt').get();
      todos.assignAll(snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList());
    } catch (e, stackTrace) {
      _handleError('fetching todos', e, stackTrace);
    } finally {
      isLoading(false);
    }
  }

  /// Add Todo with startTime and endTime
  Future<void> addTodoWithTimes(String title, TimeOfDay start, TimeOfDay end) async {
    try {
      await _firestore.collection('todos').add({
        "title": title,
        "completed": false,
        "startTime": start.format(Get.context!),
        "endTime": end.format(Get.context!),
        "createdAt": FieldValue.serverTimestamp(),
      });
      fetchTodos();
    } catch (e, stackTrace) {
      _handleError('adding todo', e, stackTrace);
    }
  }

void updateTodo(
  String id,
  String title,
  bool completed, {
  String? startTime,
  String? endTime,
}) async {
  // Find the task locally
  var todo = todos.firstWhere((todo) => todo['id'] == id);

  // Update the local task data
  if (startTime != null) todo['startTime'] = startTime;
  if (endTime != null) todo['endTime'] = endTime;

  // Recalculate completed status based on the new end time
  DateTime now = DateTime.now();
  DateFormat timeFormat = DateFormat("h:mm a");
  DateTime endDateTime = timeFormat.parse(todo['endTime']);
  endDateTime = DateTime(now.year, now.month, now.day, endDateTime.hour, endDateTime.minute);

  // If the current time is after the end time, mark it as completed
  // If current time is before the end time, mark it as incomplete
  if (now.isAfter(endDateTime)) {
    todo['completed'] = true;  // Task is completed
  } else {
    todo['completed'] = false;  // Task is not completed yet
  }

  // Update the todo list locally (reactive update)
  update(); // This will trigger a UI update in the GetX controller

  try {
    // Now update the task on the Firestore (backend)
    await _firestore.collection('todos').doc(id).update({
      'title': todo['title'],
      'completed': todo['completed'],
      'startTime': todo['startTime'],
      'endTime': todo['endTime'],
    });
  } catch (e, stackTrace) {
    _handleError('updating todo in Firestore', e, stackTrace);
  }
}



/// Delete a single Todo
  Future<void> deleteTodo(String id) async {
    try {
      await _firestore.collection('todos').doc(id).delete();
      fetchTodos();
    } catch (e, stackTrace) {
      _handleError('deleting todo', e, stackTrace);
    }
  }

  /// Delete all Todos
  Future<void> deleteAllTodos() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('todos').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      fetchTodos();
    } catch (e, stackTrace) {
      _handleError('deleting all todos', e, stackTrace);
    }
  }

  /// Handles errors by logging and showing a snackbar
  void _handleError(String action, dynamic error, StackTrace stackTrace) {
    print('Error while $action: $error');
    print('StackTrace: $stackTrace');
    Get.snackbar('Error', 'Failed to $action: $error', snackPosition: SnackPosition.BOTTOM);
  }
}
