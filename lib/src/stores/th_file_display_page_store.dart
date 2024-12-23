import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mobx/mobx.dart';

part 'th_file_display_page_store.g.dart';

class THFileDisplayPageStore = THFileDisplayPageStoreBase
    with _$THFileDisplayPageStore;

abstract class THFileDisplayPageStoreBase with Store {
  @readonly
  bool _isLoading = false;

  @readonly
  THFile _thFile = THFile();

  List<String> errorMessages = <String>[];

  @action
  Future<void> loadFile(String aFilename) async {
    final parser = THFileParser();
    _isLoading = true;
    errorMessages.clear();

    final (parsedFile, isSuccessful, errors) = await parser.parse(aFilename);
    _isLoading = false;

    if (isSuccessful) {
      _thFile = parsedFile;
    } else {
      errorMessages.addAll(errors);
      // await Get.dialog(
      //   ErrorDialog(errorMessages: errorMessages),
      // );
      // Get.back(); // Close the file display page
    }
  }

  Future<File?> saveTH2File() async {
    final file = await _localFile();
    final encodedContent = await _encodedFileContents();
    return await file.writeAsBytes(encodedContent, flush: true);
  }

  Future<List<int>> _encodedFileContents() async {
    final thFileWriter = THFileWriter();
    return await thFileWriter.toBytes(_thFile);
  }

  Future<File?> saveAsTH2File() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: _thFile.filename,
    );

    if (filePath != null) {
      final file = File(filePath);
      final encodedContent = await _encodedFileContents();
      return await file.writeAsBytes(encodedContent, flush: true);
    }

    return null;
  }

  Future<File> _localFile() async {
    final filename = _thFile.filename;
    return File(filename);
  }
}
