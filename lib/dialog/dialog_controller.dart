import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogController extends GetxController {
  var highValue = "".obs;
  var lowValue = "".obs;
  var setValue = "".obs;

  void showTextInputDialog(BuildContext context) {
    TextEditingController highController = TextEditingController();
    TextEditingController lowController = TextEditingController();
    TextEditingController setController = TextEditingController();

    Get.defaultDialog(
      title: "Enter Values",
      content: Column(
        children: [
          TextField(
            controller: highController,
            decoration: InputDecoration(labelText: "High"),
          ),
          TextField(
            controller: lowController,
            decoration: InputDecoration(labelText: "Low"),
          ),
          TextField(
            controller: setController,
            decoration: InputDecoration(labelText: "Set"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              highValue.value = highController.text;
              lowValue.value = lowController.text;
              setValue.value = setController.text;

              Get.back(); // Close dialog
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
