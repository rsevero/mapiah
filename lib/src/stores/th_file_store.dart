import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_error_dialog.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/elements/parts/th_point_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/undo_redo/undo_redo_controller.dart';
import 'package:mobx/mobx.dart';

part 'th_file_store.g.dart';

class THFileStore = THFileStoreBase with _$THFileStore;

abstract class THFileStoreBase with Store {
  @readonly
  bool _isLoading = false;

  @readonly
  THFile _thFile = THFile();

  List<String> errorMessages = <String>[];

  late final UndoRedoController _undoRedoController;

  @action
  Future<void> loadFile(BuildContext context, String aFilename) async {
    final parser = THFileParser();

    _isLoading = true;
    errorMessages.clear();

    final (parsedFile, isSuccessful, errors) = await parser.parse(aFilename);
    _isLoading = false;

    if (isSuccessful) {
      _thFile = parsedFile;
      _undoRedoController = UndoRedoController(_thFile);
    } else {
      errorMessages.addAll(errors);
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return THErrorDialog(errorMessages: errorMessages);
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

  @action
  void execute(Command command) {
    _undoRedoController.execute(command);
  }

  @action
  void undo() {
    _undoRedoController.undo();
  }

  @action
  void redo() {
    _undoRedoController.redo();
  }

  UndoRedoController get undoRedoController => _undoRedoController;

  @action
  void updatePointPosition(THPoint point, Offset delta) {
    final THPointPositionPart newPosition = point.position.copyWith(
      x: point.x + delta.dx,
      y: point.y + delta.dy,
    );
    final MovePointCommand command =
        MovePointCommand(point.mapiahID, newPosition);
    _undoRedoController.execute(command);
  }
}
