import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mapiah/src/th_file_aux/th_file_parser.dart';
import 'package:open_file/open_file.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapiah'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_open),
            onPressed: () => _pickTh2File(context),
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // TODO: Implement "about" action
              print('About action triggered');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Mapiah!'),
      ),
    );
  }

  void _pickTh2File(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select a TH2 file',
        type: FileType.custom,
        allowedExtensions: ['th2'],
      );

      if (result != null) {
        // Use the file
        String? pickedFilePath = result.files.single.path;
        print("Picked file path: $pickedFilePath'");
        if (pickedFilePath == null) {
          return;
        }
        final parser = THFileParser();
        final (file, isSuccessful, errors) = await parser.parse(pickedFilePath);
        if (isSuccessful) {
          print('File parsed successfully');
        }
      } else {
        // User canceled the picker
        print('No file selected.');
      }
    } catch (e) {
      print('Error picking file: $e');
      // Optionally, handle the error for the user
    }
  }
}
