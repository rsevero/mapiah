import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_controllers/th_file_controller.dart';

import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_widgets/th_file_widget.dart';

class THFileDisplayPage extends StatelessWidget {
  final String filename;
  final FileLoadingController fileLoadingController =
      Get.put(FileLoadingController());
  final THFileController thFileController = Get.put(THFileController());

  THFileDisplayPage({required this.filename});

  @override
  Widget build(BuildContext context) {
    fileLoadingController.loadFile(filename);
    return Scaffold(
      appBar: AppBar(
        title: Text('File Display'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (fileLoadingController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: Stack(children: [
              THFileWidget(fileLoadingController.parsedFile),
              _buildFloatingActionButtons(),
            ]),
          );
        }
      }),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      right: 16.0,
      bottom: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _zoomButton(Icons.zoom_in, () {
            thFileController.zoomIn();
          }),
          SizedBox(height: 8.0),
          _zoomButton(Icons.zoom_out_map, () {
            thFileController.zoomShowAll();
          }),
          SizedBox(height: 8.0),
          _zoomButton(Icons.zoom_out, () {
            thFileController.zoomOut();
          }),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      mini: true,
      child: Icon(icon),
      onPressed: onPressed,
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
