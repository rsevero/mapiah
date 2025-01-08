import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/error_dialog.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mobx/mobx.dart';

part 'th_file_store.g.dart';

class THFileStore = THFileStoreBase with _$THFileStore;

abstract class THFileStoreBase with Store {
  @readonly
  bool _isLoading = false;

  @readonly
  THFile _thFile = THFile();

  List<String> errorMessages = <String>[];

  @action
  Future<void> loadFile(BuildContext context, String aFilename) async {
    final parser = THFileParser();
    _isLoading = true;
    errorMessages.clear();

    final (parsedFile, isSuccessful, errors) = await parser.parse(aFilename);
    _isLoading = false;

    if (isSuccessful) {
      _thFile = parsedFile;
    } else {
      errorMessages.addAll(errors);
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(errorMessages: errorMessages);
        },
      );
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

  @action
  void substituteElement(THElement newElement) {
    _thFile.substituteElement(newElement);
  }
}
