import 'package:doneo/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() {
  Get.put(CardController()); // Initialize Controller
  Get.put(DialogController()); // Initialize Dialog Controller
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  final CardController cardController = Get.find();
  final DialogController dialogController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GetX Card Component")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => CustomCard(
                title: "l.p",
                subtitle: cardController.subtitle.value,  // Display updated subtitle here
                icon: cardController.icon.value,
                onTap: () {
                  dialogController.showTextInputDialog(context);
                },
              )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  dialogController.showTextInputDialog(context);
                },
                child: Text("Open Dialog"),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogController extends GetxController {
  var highValue = ''.obs;
  var lowValue = ''.obs;
  var setValue = ''.obs;

  // Show the dialog to get the input values
  showTextInputDialog(BuildContext context) {
    TextEditingController highController = TextEditingController();
    TextEditingController lowController = TextEditingController();
    TextEditingController setController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Enter Values'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: highController,
              decoration: InputDecoration(labelText: 'High'),
            ),
            TextField(
              controller: lowController,
              decoration: InputDecoration(labelText: 'Low'),
            ),
            TextField(
              controller: setController,
              decoration: InputDecoration(labelText: 'Set'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              highValue.value = highController.text;
              lowValue.value = lowController.text;
              setValue.value = setController.text;

              // After getting the set value, update the CardController
              Get.find<CardController>().updateCard(
                'Updated Title',
                setValue.value,  // Use setValue as subtitle
                Icons.check_circle,
              );

              Get.back(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  CustomCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),  // Display the updated subtitle (setValue here)
        onTap: () => onTap(),
      ),
    );
  }
}

class CardController extends GetxController {
  var title = 'Card Title'.obs;
  var subtitle = 'Card Subtitle'.obs;  // This will hold the setValue from the dialog
  var icon = Icons.check_circle.obs;

  // Update method for updating the card
  updateCard(String newTitle, String newSubtitle, IconData newIcon) {
    title.value = newTitle;
    subtitle.value = newSubtitle;  // This will now display the updated setValue
    icon.value = newIcon;
  }
}
