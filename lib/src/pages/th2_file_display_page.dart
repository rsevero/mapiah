import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_widgets/th_file_widget.dart';

class THFileDisplayPage extends StatelessWidget {
  final String filename;
  final FileLoadingController controller = Get.put(FileLoadingController());

  THFileDisplayPage({required this.filename});

  @override
  Widget build(BuildContext context) {
    controller.loadFile(filename);
    return Scaffold(
      appBar: AppBar(
        title: Text('File Display'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: THFileWidget(controller.parsedFile),
          );
        }
      }),
    );
  }
}

class FileLoadingController extends GetxController {
  var isLoading = false.obs;
  RxList<String> errorMessages = RxList<String>();
  final parser = THFileParser();
  THFile parsedFile = THFile();

  void loadFile(String aFilename) async {
    isLoading.value = true;
    errorMessages.clear();

    final (file, isSuccessful, errors) = await parser.parse(aFilename);
    isLoading.value = false;

    if (isSuccessful) {
      parsedFile = file;
    } else {
      errorMessages.addAll(errors);
      await Get.dialog(
        ErrorDialog(errorMessages: errorMessages),
      );
      Get.back(); // Close the file display page
    }
  }
}

class ErrorDialog extends StatelessWidget {
  final List<String> errorMessages;

  ErrorDialog({required this.errorMessages});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Parsing errors'),
      content: SingleChildScrollView(
        child: ListBody(
          children: errorMessages.map((message) => Text(message)).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Get.back(); // Close the dialog
          },
        ),
      ],
    );
  }
}
