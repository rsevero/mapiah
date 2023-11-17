import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_controllers/th_file_controller.dart';
import 'package:mapiah/src/th_controllers/th_file_loading_controller.dart';
import 'package:mapiah/src/th_widgets/th_file_widget.dart';

class THFileDisplayPage extends StatelessWidget {
  final String filename;
  final THFileLoadingController thFileLoadingController =
      Get.put(THFileLoadingController());
  final THFileController thFileController = Get.put(THFileController());

  THFileDisplayPage({required this.filename});

  @override
  Widget build(BuildContext context) {
    thFileLoadingController.loadFile(filename);
    return Scaffold(
      appBar: AppBar(
        title: Text('File Display'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (thFileLoadingController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: Stack(children: [
              THFileWidget(thFileLoadingController.parsedFile),
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
