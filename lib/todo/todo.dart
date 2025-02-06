import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doneo/todo/todo_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TodoScreen extends StatelessWidget {
  final TodoController controller = Get.put(TodoController());
  final SpeechToText _speechToText = SpeechToText();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Doneo",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800],
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: controller.deleteAllTodos,
            color: Colors.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTaskInputField(),
            SizedBox(height: 20),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.taskController,
              decoration: InputDecoration(
                hintText: "Add a new task...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Colors.blueGrey[800]),
            onPressed: _startListening,
          ),
          GestureDetector(
            onTap: () {
              if (controller.taskController.text.isNotEmpty) {
                controller.addTodo(controller.taskController.text);
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey[800],
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(onResult: (result) {
        controller.taskController.text = result.recognizedWords;
      });
    } else {
      Get.snackbar("Error", "Speech recognition is not available.");
    }
  }

  Widget _buildTaskList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.todos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/logo.png', height: 200),
              SizedBox(height: 10),
              Text("No tasks yet! Add some.",
                  style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.todos.length,
        itemBuilder: (context, index) {
          final todo = controller.todos[index];
          return _buildTaskCard(todo);
        },
      );
    });
  }

  Widget _buildTaskCard(Map<String, dynamic> todo) {
    return Dismissible(
        key: Key(todo['id'].toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.deleteTodo(todo['id']),
        background: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              todo['title'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
                decoration: todo['completed']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            leading: Checkbox(
              value: todo['completed'],
              onChanged: (value) =>
                  controller.updateTodo(todo['id'], todo['title'], value!),
              activeColor: Colors.blueGrey[800],
              side: BorderSide(color: Colors.blueGrey[800]!, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueGrey[800], size: 20),
                  onPressed: () => _showEditDialog(
                      todo['id'], todo['title'], todo['completed']),
                  padding: EdgeInsets.all(4),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => controller.deleteTodo(todo['id']),
                  padding: EdgeInsets.all(4),
                ),
              ],
            ),
          ),
        ));
  }

  void _showEditDialog(int id, String oldTitle, bool completed) {
    TextEditingController editController =
        TextEditingController(text: oldTitle);
    Get.defaultDialog(
      title: "Edit Task",
      backgroundColor: Colors.white,
      titleStyle: GoogleFonts.poppins(
          color: Colors.blueGrey[800], fontWeight: FontWeight.bold),
      content: Column(
        children: [
          TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: "Task Title",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: Icon(Icons.mic, color: Colors.blueGrey[800]),
                onPressed: () => _startListeningForEdit(editController),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.updateTodo(id, editController.text, completed);
                  Get.back();
                },
                child: Text("Update"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    foregroundColor: Colors.white),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text("Cancel"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
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


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:doneo/todo/todo_controller.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class TodoScreen extends StatelessWidget {
//   final TodoController controller = Get.put(TodoController());
//   final SpeechToText _speechToText = SpeechToText();
//   TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
//   TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: Text(
//           "Doneo",
//           style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w600, color: Colors.white),
//         ),
//         backgroundColor: Colors.blueGrey[800],
//         elevation: 5,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.delete_sweep),
//             onPressed: controller.deleteAllTodos,
//             color: Colors.white,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildTaskInputField(),
//             SizedBox(height: 20),
//             Expanded(child: _buildTaskList()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskInputField() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: controller.taskController,
//               decoration: InputDecoration(
//                 hintText: "Add a new task...",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.mic, color: Colors.blueGrey[800]),
//             onPressed: _startListening,
//           ),
//           GestureDetector(
//             onTap: () {
//               if (controller.taskController.text.isNotEmpty) {
//                 _showTimePickerDialog();
//               }
//             },
//             child: CircleAvatar(
//               backgroundColor: Colors.blueGrey[800],
//               child: Icon(Icons.add, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _startListening() async {
//     bool available = await _speechToText.initialize();
//     if (available) {
//       _speechToText.listen(onResult: (result) {
//         controller.taskController.text = result.recognizedWords;
//       });
//     } else {
//       Get.snackbar("Error", "Speech recognition is not available.");
//     }
//   }

//   void _showTimePickerDialog() async {
//     final TimeOfDay? startPicked = await showTimePicker(
//       context: Get.context!,
//       initialTime: _startTime,
//     );
//     final TimeOfDay? endPicked = await showTimePicker(
//       context: Get.context!,
//       initialTime: _endTime,
//     );

//     if (startPicked != null && endPicked != null) {
//       _startTime = startPicked;
//       _endTime = endPicked;

//       // Now add the task with startTime and endTime
//       controller.addTodoWithTimes(
//         controller.taskController.text, 
//         _startTime, 
//         _endTime
//       );
//     }
//   }

//   Widget _buildTaskList() {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
//       }
//       if (controller.todos.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/logo.png', height: 200),
//               SizedBox(height: 10),
//               Text("No tasks yet! Add some.",
//                   style: GoogleFonts.poppins(fontSize: 16)),
//             ],
//           ),
//         );
//       }
//       return ListView.builder(
//         itemCount: controller.todos.length,
//         itemBuilder: (context, index) {
//           final todo = controller.todos[index];
//           return _buildTaskCard(todo);
//         },
//       );
//     });
//   }

//   Widget _buildTaskCard(Map<String, dynamic> todo) {
//     return Dismissible(
//       key: Key(todo['id'].toString()),
//       direction: DismissDirection.endToStart,
//       onDismissed: (_) => controller.deleteTodo(todo['id']),
//       background: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20),
//         alignment: Alignment.centerRight,
//         decoration: BoxDecoration(
//             color: Colors.red, borderRadius: BorderRadius.circular(12)),
//         child: Icon(Icons.delete, color: Colors.white),
//       ),
//       child: Card(
//         elevation: 2,
//         shadowColor: Colors.black.withOpacity(0.1),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         child: ListTile(
//           contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           title: Text(
//             todo['title'],
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//               color: Colors.black87,
//               decoration: todo['completed']
//                   ? TextDecoration.lineThrough
//                   : TextDecoration.none,
//             ),
//           ),
//           leading: Checkbox(
//             value: todo['completed'],
//             onChanged: (value) =>
//                 controller.updateTodo(todo['id'], todo['title'], value!),
//             activeColor: Colors.blueGrey[800],
//             side: BorderSide(color: Colors.blueGrey[800]!, width: 1.5),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5)),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.blueGrey[800], size: 20),
//                 onPressed: () => _showEditDialog(
//                     todo['id'], todo['title'], todo['completed']),
//                 padding: EdgeInsets.all(4),
//               ),
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.red, size: 20),
//                 onPressed: () => controller.deleteTodo(todo['id']),
//                 padding: EdgeInsets.all(4),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showEditDialog(int id, String oldTitle, bool completed) {
//     TextEditingController editController =
//         TextEditingController(text: oldTitle);
//     Get.defaultDialog(
//       title: "Edit Task",
//       backgroundColor: Colors.white,
//       titleStyle: GoogleFonts.poppins(
//           color: Colors.blueGrey[800], fontWeight: FontWeight.bold),
//       content: Column(
//         children: [
//           TextField(
//             controller: editController,
//             decoration: InputDecoration(
//               labelText: "Task Title",
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.mic, color: Colors.blueGrey[800]),
//                 onPressed: () => _startListeningForEdit(editController),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   controller.updateTodo(id, editController.text, completed);
//                   Get.back();
//                 },
//                 child: Text("Update"),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[800],
//                     foregroundColor: Colors.white),
//               ),
//               SizedBox(width: 10),
//               ElevatedButton(
//                 onPressed: () => Get.back(),
//                 child: Text("Cancel"),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey,
//                     foregroundColor: Colors.white),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _startListeningForEdit(TextEditingController controller) async {
//     bool available = await _speechToText.initialize();
//     if (available) {
//       _speechToText.listen(onResult: (result) {
//         controller.text = result.recognizedWords;
//       });
//     }
//   }
// }
