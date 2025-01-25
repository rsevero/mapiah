import 'dart:collection';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/th_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_controller.dart';
import 'package:mobx/mobx.dart';

part 'th_file_edit_store.g.dart';

class THFileEditStore = THFileEditStoreBase with _$THFileEditStore;

abstract class THFileEditStoreBase with Store {
  @readonly
  bool _isLoading = false;

  @readonly
  late THFile _thFile;

  @readonly
  late int _thFileMapiahID;

  /// These triggers are used to notify the drawable widgets that they should
  /// redraw. There area triggers specific to each point and line (the actual
  /// drawable elements), to each scrap and the THFile itself:
  ///
  /// 1. THFile: triggers the whole file to redraw when some setting that
  ///  affects the whole file changes like zoom or pan.
  /// 2. THScrap: triggers the scrap to redraw when some setting that affects
  /// the scrap changes like changing the isSelected property of the scrap.
  /// 3. THPoint and THLine: triggers the point or line to redraw when this
  /// particular element has been edit: moved, changed type etc.
  @readonly
  Map<int, Observable<bool>> _elementRedrawTrigger = <int, Observable<bool>>{};

  /// These triggers are used to notify the widgets that have drawable children,
  /// i.e., THFile and THScraps, that they should redraw themselves because a
  /// child widget has been added or removed.
  @readonly
  Map<int, Observable<bool>> _childrenListLengthChangeTrigger =
      <int, Observable<bool>>{};

  final List<String> errorMessages = <String>[];

  late final MPUndoRedoController _undoRedoController;

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
  static THFileEditStore create(String filename) {
    final THFileEditStore thFileStore = THFileEditStore._create();
    final THFile thFile = THFile();
    thFile.filename = filename;
    thFileStore._basicInitialization(thFile);
    return thFileStore;
  }

  THFileEditStoreBase._create();

  void _basicInitialization(THFile file) {
    _thFile = file;
    _thFileMapiahID = _thFile.mapiahID;
    _undoRedoController = MPUndoRedoController(this as THFileEditStore);
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
    _elementRedrawTrigger.clear();
    _childrenListLengthChangeTrigger.clear();

    _elementRedrawTrigger[_thFileMapiahID] = Observable(false);
    _childrenListLengthChangeTrigger[_thFileMapiahID] = Observable(false);
    parsedFile.elements.forEach((key, value) {
      if (value is THPoint || value is THLine || value is THScrap) {
        _elementRedrawTrigger[key] = Observable(false);
        _childrenListLengthChangeTrigger[key] = Observable(false);
      }
    });

    _isLoading = false;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }
  }

  /// Should be used only when a drawable element (scrap, line or point) is
  /// added or removed directly as child of the THFile. Usually there should
  /// only be one drawable element as child of the THFile: a scrap.
  ///
  /// The THFileWidget itself will redraw.
  @action
  void triggerTHFileLengthChildrenList() {
    _childrenListLengthChangeTrigger[_thFileMapiahID]!.value =
        !_childrenListLengthChangeTrigger[_thFileMapiahID]!.value;
  }

  /// Should be used when some change that potentially affects the whole file
  /// happens. For example a pan or zoom operation.
  ///
  /// All drawable items in the THFile will be triggered.
  void triggerFileRedraw() {
    _substituteStoreElement(_thFileMapiahID);
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
  void _substituteStoreElement(int mapiahID) {
    _elementRedrawTrigger[mapiahID]!.value =
        !_elementRedrawTrigger[mapiahID]!.value;
  }

  void substituteElement(THElement newElement) {
    _thFile.substituteElement(newElement);
    _substituteStoreElement(newElement.mapiahID);
    getIt<MPLog>().finer('Substituted element ${newElement.mapiahID}');
  }

  void execute(MPCommand command) {
    _undoRedoController.execute(command);
  }

  void undo() {
    _undoRedoController.undo();
  }

  void redo() {
    _undoRedoController.redo();
  }

  MPUndoRedoController get undoRedoController => _undoRedoController;

  void updatePointPosition({
    required THPoint originalPoint,
    required THPoint modifiedPoint,
  }) {
    final MPMovePointCommand command = MPMovePointCommand(
      pointMapiahID: originalPoint.mapiahID,
      originalCoordinates: originalPoint.position.coordinates,
      modifiedCoordinates: modifiedPoint.position.coordinates,
    );
    _undoRedoController.execute(command);
  }

  void updateLinePosition({
    required THLine originalLine,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required THLine newLine,
    required LinkedHashMap<int, THLineSegment> newLineSegmentsMap,
  }) {
    final MPMoveLineCommand command = MPMoveLineCommand(
      originalLine: originalLine,
      originalLineSegmentsMap: originalLineSegmentsMap,
      newLine: newLine,
      newLineSegmentsMap: newLineSegmentsMap,
      description: 'Move Line',
    );
    _undoRedoController.execute(command);
  }

  void updateLinePositionPerOffset({
    required THLine originalLine,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required Offset deltaOnCanvas,
  }) {
    final MPMoveLineCommand command = MPMoveLineCommand.fromDelta(
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
