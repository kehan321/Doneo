import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doneo/todo/todo_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TodoController controller = Get.put(TodoController());
  final SpeechToText _speechToText = SpeechToText();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCompletionCheckTimer();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _timer?.cancel();
    super.dispose();
    _audioPlayer.dispose();
  }

  // Timer function to check task completion periodically
  void _startCompletionCheckTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkForCompletedTasks();
    });
  }

void _checkForCompletedTasks() {
  DateTime now = DateTime.now();

  for (var todo in controller.todos) {
    DateFormat timeFormat = DateFormat("h:mm a");
    DateTime endDateTime = timeFormat.parse(todo['endTime']);
    endDateTime = DateTime(now.year, now.month, now.day, endDateTime.hour, endDateTime.minute);

    // Check if the current time is within 1 minute of the end time
    if (now.isAfter(endDateTime.subtract(Duration(minutes: 1))) &&
        now.isBefore(endDateTime.add(Duration(minutes: 1)))) {
      // Show the task completion alert
      _showCompletionAlert(todo);

      // If the task is completed, update the task completion status
      controller.updateTodo(todo['id'], todo['title'], true, startTime: todo['startTime'], endTime: todo['endTime']);
      setState(() {});
    }
  }
}

  // Show a completion alert
  void _showCompletionAlert(Map<String, dynamic> todo) async{
    await _audioPlayer.play(AssetSource('beep.mp3'));
    Get.snackbar(
      "Task Completed",
      "The task '${todo['title']}' has been completed.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Doneo",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
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
                _showTimePickerDialog();
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
        setState(() {
          controller.taskController.text = result.recognizedWords;
        });
      });
    } else {
      Get.snackbar("Error", "Speech recognition is not available.");
    }
  }

  void _showTimePickerDialog() async {
    final TimeOfDay? startPicked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    final TimeOfDay? endPicked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (startPicked != null && endPicked != null) {
      setState(() {
        _startTime = startPicked;
        _endTime = endPicked;
      });

      controller.addTodoWithTimes(
        controller.taskController.text,
        _startTime,
        _endTime,
      );
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
              Image.asset('assets/logo.png', height: 150),
              SizedBox(height: 10),
              Text("No tasks yet! Add some.", style: GoogleFonts.poppins(fontSize: 16)),
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
    DateTime now = DateTime.now();

    DateFormat timeFormat = DateFormat("h:mm a");
    DateTime startDateTime = timeFormat.parse(todo['startTime']);
    DateTime endDateTime = timeFormat.parse(todo['endTime']);

    startDateTime = DateTime(now.year, now.month, now.day, startDateTime.hour, startDateTime.minute);
    endDateTime = DateTime(now.year, now.month, now.day, endDateTime.hour, endDateTime.minute);

    BorderSide borderSide;
    if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
      borderSide = BorderSide(color: Colors.green, width: 2);
    } else {
      borderSide = BorderSide(color: Colors.grey, width: 1);
    }

    Color cardColor = todo['completed'] ? Colors.green[100]! : Colors.white;

    return Dismissible(
      key: Key(todo['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteTodo(todo['id']),
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _showUpdateDialog(todo),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: borderSide,
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: cardColor,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              todo['title'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
                decoration: todo['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            leading: Checkbox(
              value: todo['completed'],
              onChanged: (value) {
                controller.updateTodo(
                  todo['id'],
                  todo['title'],
                  value!,
                  startTime: todo['startTime'],
                  endTime: todo['endTime'],
                );
              },
              activeColor: Colors.blueGrey[800],
              side: BorderSide(color: Colors.blueGrey[800]!, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => controller.deleteTodo(todo['id']),
            ),
          ),
        ),
      ),
    );
  }

 void _showUpdateDialog(Map<String, dynamic> todo) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController titleController = TextEditingController(text: todo['title']);
      TextEditingController startTimeController = TextEditingController(text: todo['startTime']);
      TextEditingController endTimeController = TextEditingController(text: todo['endTime']);
      bool isCompleted = todo['completed'];

      return AlertDialog(
        title: Text('Update Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: startTimeController,
              decoration: InputDecoration(labelText: 'Start Time (e.g., 9:00 AM)'),
            ),
            TextField(
              controller: endTimeController,
              decoration: InputDecoration(labelText: 'End Time (e.g., 5:00 PM)'),
            ),
            Row(
              children: [
                Text('Completed:'),
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      isCompleted = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle the update logic with the updated endTime
              controller.updateTodo(
                todo['id'],
                titleController.text,
                isCompleted,  // Keep the completion flag if not changed
                startTime: startTimeController.text,
                endTime: endTimeController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

}
