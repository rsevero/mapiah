import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
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

  final List<String> errorMessages = <String>[];

  late final UndoRedoController _undoRedoController;

  late final THFileDisplayStore _thFileDisplayStore;

  /// This is a factory constructor that creates a new instance of THFileStore.
  /// It is a static method that returns a Future that contains a tuple of
  /// THFileStore, a boolean, and a list of strings.
  ///
  /// @param filename The name of the file to be parsed.
  /// @return A Future that contains a tuple of THFileStore, a boolean, and a
  /// list of strings.
  ///
  /// The THFileStore instance is created and initialized with the parsed file.
  /// The boolean indicates whether the file was parsed successfully.
  /// The list of strings contains any error messages that were generated during
  /// parsing.
  static Future<THFileStoreCreateResult> create(
    String filename,
  ) async {
    final THFileStore thFileStore = THFileStore._create();

    thFileStore._preParseInitialize();

    final THFileParser parser = THFileParser();

    final (parsedFile, isSuccessful, errors) = await parser.parse(filename);

    thFileStore._postParseInitialize(parsedFile, isSuccessful, errors);

    return THFileStoreCreateResult(thFileStore, isSuccessful, errors);
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

    if (isSuccessful) {
      _thFile = parsedFile;
      _undoRedoController = UndoRedoController(_thFile);
      _thFileDisplayStore = getIt<THFileDisplayStore>();
    } else {
      errorMessages.addAll(errors);
    }
  }

  THFileStoreBase._create();

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
  void updatePointPosition(
    THPoint originalPoint,
    THPoint newPoint,
  ) {
    final MovePointCommand command = MovePointCommand(
        pointMapiahID: originalPoint.mapiahID,
        originalPosition: originalPoint.position,
        newPosition: newPoint.position);
    _undoRedoController.execute(command);
    _thFileDisplayStore.setShouldRepaint(true);
  }
}

class THFileStoreCreateResult {
  final THFileStore thFileStore;
  final bool isSuccessful;
  final List<String> errors;

  THFileStoreCreateResult(
    this.thFileStore,
    this.isSuccessful,
    this.errors,
  );
}
