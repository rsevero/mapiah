import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/pages/th2_file_display_page.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';

class THFileDisplayPageController extends GetxController {
  var isLoading = false.obs;
  List<String> errorMessages = <String>[];
  THFile thFile = THFile();

  void loadFile(String aFilename) async {
    final parser = THFileParser();
    isLoading.value = true;
    errorMessages.clear();

    final (parsedFile, isSuccessful, errors) = await parser.parse(aFilename);
    isLoading.value = false;

    if (isSuccessful) {
      thFile = parsedFile;
    } else {
      errorMessages.addAll(errors);
      await Get.dialog(
        ErrorDialog(errorMessages: errorMessages),
      );
      Get.back(); // Close the file display page
    }
  }

  Future<File?> saveTH2File() async {
    final file = await _localFile();
    final encodedContent = await _encodedFileContents();
    return await file.writeAsBytes(encodedContent, flush: true);
  }

  Future<List<int>> _encodedFileContents() async {
    final thFileWriter = THFileWriter();
    return await thFileWriter.toBytes(thFile);
  }

  Future<File?> saveAsTH2File() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: thFile.filename,
    );

    if (filePath != null) {
      final file = File(filePath);
      final encodedContent = await _encodedFileContents();
      return await file.writeAsBytes(encodedContent, flush: true);
    }

    return null;
  }

  Future<File> _localFile() async {
    final filename = thFile.filename;
    return File(filename);
  }
}
