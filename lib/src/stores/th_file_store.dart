import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/move_line_command.dart';
import 'package:mapiah/src/commands/move_point_command.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
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
  late THFile _thFile;

  final List<String> errorMessages = <String>[];

  late final UndoRedoController _undoRedoController;

  Future<THFileStoreCreateResult> load() async {
    _preParseInitialize();

    final THFileParser parser = THFileParser();

    final (parsedFile, isSuccessful, errors) =
        await parser.parse(_thFile.filename);

    _postParseInitialize(parsedFile, isSuccessful, errors);

    return THFileStoreCreateResult(isSuccessful, errors);
  }

  /// This is a factory constructor that creates a new instance of THFileStore
  /// with an empty THFile.
  static THFileStore create(String filename) {
    final THFileStore thFileStore = THFileStore._create();
    final THFile thFile = THFile();
    thFile.filename = filename;
    thFileStore._basicInitialization(thFile);
    return thFileStore;
  }

  THFileStoreBase._create();

  void _basicInitialization(THFile file) {
    _thFile = file;
    _undoRedoController = UndoRedoController(_thFile);
  }

  void _preParseInitialize() {
    _isLoading = true;
    errorMessages.clear();
  }

  void _postParseInitialize(
    THFile parsedFile,
    bool isSuccessful,
    List<String> errors,
  ) {
    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  Future<File?> saveTH2File() async {
    final File file = await _localFile();
    final List<int> encodedContent = await _encodedFileContents();
    return await file.writeAsBytes(encodedContent, flush: true);
  }

  Future<List<int>> _encodedFileContents() async {
    final THFileWriter thFileWriter = THFileWriter();
    return await thFileWriter.toBytes(_thFile);
  }

  Future<File?> saveAsTH2File() async {
    String? filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: _thFile.filename,
    );

    if (filePath != null) {
      final File file = File(filePath);
      final List<int> encodedContent = await _encodedFileContents();
      return await file.writeAsBytes(encodedContent, flush: true);
    }

    return null;
  }

  Future<File> _localFile() async {
    final String filename = _thFile.filename;

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
  void updatePointPosition({
    required THPoint originalPoint,
    required THPoint newPoint,
  }) {
    final MovePointCommand command = MovePointCommand(
      pointMapiahID: originalPoint.mapiahID,
      originalCoordinates: originalPoint.position.coordinates,
      newCoordinates: newPoint.position.coordinates,
    );
    _undoRedoController.execute(command);
  }

  @action
  void updateLinePosition({
    required THLine originalLine,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required THLine newLine,
    required LinkedHashMap<int, THLineSegment> newLineSegmentsMap,
  }) {
    final MoveLineCommand command = MoveLineCommand(
      originalLine: originalLine,
      originalLineSegmentsMap: originalLineSegmentsMap,
      newLine: newLine,
      newLineSegmentsMap: newLineSegmentsMap,
      description: 'Move Line',
    );
    _undoRedoController.execute(command);
  }

  @action
  void updateLinePositionPerOffset({
    required THLine originalLine,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required Offset deltaOnCanvas,
  }) {
    final MoveLineCommand command = MoveLineCommand.fromDelta(
      originalLine: originalLine,
      originalLineSegmentsMap: originalLineSegmentsMap,
      deltaOnCanvas: deltaOnCanvas,
    );
    _undoRedoController.execute(command);
  }

  @action
  void addElement(THElement element) {
    _thFile.addElement(element);
    _thFile.addElementToParent(element);
  }

  @action
  void addElementWithParent(THElement element, THParent parent) {
    _thFile.addElement(element);
    parent.addElementToParent(element);
  }

  @action
  void deleteElement(THElement element) {
    _thFile.deleteElement(element);
  }

  @action
  void deleteElementByMapiahID(int mapiahID) {
    final THElement element = _thFile.elementByMapiahID(mapiahID);
    _thFile.deleteElement(element);
  }

  @action
  void deleteElementByTHID(String thID) {
    final THElement element = _thFile.elementByTHID(thID);
    _thFile.deleteElement(element);
  }

  @action
  void registerElementWithTHID(THElement element, String thID) {
    _thFile.registerElementWithTHID(element, thID);
  }
}

class THFileStoreCreateResult {
  final bool isSuccessful;
  final List<String> errors;

  THFileStoreCreateResult(
    this.isSuccessful,
    this.errors,
  );
}
