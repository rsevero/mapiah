import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/factories/mp_multiple_elements_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th2_file_edit_element_edit_controller.g.dart';

class TH2FileEditElementEditController = TH2FileEditElementEditControllerBase
    with _$TH2FileEditElementEditController;

abstract class TH2FileEditElementEditControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditElementEditControllerBase(this._th2FileEditController)
    : _thFile = _th2FileEditController.thFile;

  void initializeMostUsedTypes() {
    final elements = _thFile.elements.values;

    for (final element in elements) {
      switch (element) {
        case THArea _:
          _setMostUsedAreaType(element.areaType.name);
        case THLine _:
          _setMostUsedLineType(element.lineType.name);
        case THPoint _:
          _setMostUsedPointType(element.pointType.name);
        default:
      }
    }

    setUsedAreaType(thDefaultAreaType.name);
    setUsedLineType(thDefaultLineType.name);
    setUsedPointType(thDefaultPointType.name);
  }

  @readonly
  Offset? _lineStartScreenPosition;

  @readonly
  THLine? _newLine;

  @readonly
  THArea? _newArea;

  int _missingStepsPreserveStraightToBezierConversionUndoRedo = 2;

  late MPMoveControlPointSmoothInfo moveControlPointSmoothInfo;

  final List<String> _lastUsedAreaTypes = [];
  final List<String> _lastUsedLineTypes = [];
  final List<String> _lastUsedPointTypes = [];
  final Map<String, MPTypeUsed> _mostUsedAreaTypes = {};
  final Map<String, MPTypeUsed> _mostUsedLineTypes = {};
  final Map<String, MPTypeUsed> _mostUsedPointTypes = {};

  List<String> get lastUsedAreaTypes => _lastUsedAreaTypes;

  List<String> get lastUsedLineTypes => _lastUsedLineTypes;

  List<String> get lastUsedPointTypes => _lastUsedPointTypes;

  List<String> get mostUsedAreaTypes {
    return _getMostUsedTypes(_mostUsedAreaTypes);
  }

  List<String> get mostUsedLineTypes {
    return _getMostUsedTypes(_mostUsedLineTypes);
  }

  List<String> get mostUsedPointTypes {
    return _getMostUsedTypes(_mostUsedPointTypes);
  }

  List<String> _getMostUsedTypes(Map<String, MPTypeUsed> mostUsedTypesMap) {
    final List<String> mostUsedTypes = [];
    final List<MapEntry<String, MPTypeUsed>> entries = mostUsedTypesMap.entries
        .toList();

    entries.sort((a, b) {
      final int countComparison = b.value.count.compareTo(a.value.count);

      if (countComparison != 0) {
        return countComparison;
      }

      return b.value.lastUsed.compareTo(a.value.lastUsed);
    });

    for (final MapEntry<String, MPTypeUsed> entry in entries) {
      mostUsedTypes.add(entry.key);
    }

    return mostUsedTypes;
  }

  void setUsedAreaType(String areaType) {
    if (_lastUsedAreaTypes.contains(areaType)) {
      _lastUsedAreaTypes.remove(areaType);
    }

    _lastUsedAreaTypes.insert(0, areaType);

    _setMostUsedAreaType(areaType);
  }

  void _setMostUsedAreaType(String areaType) {
    if (_mostUsedAreaTypes.containsKey(areaType)) {
      _mostUsedAreaTypes[areaType]!.incrementUse();
    } else {
      _mostUsedAreaTypes[areaType] = MPTypeUsed(areaType);
    }
  }

  void setUsedLineType(String lineType) {
    if (_lastUsedLineTypes.contains(lineType)) {
      _lastUsedLineTypes.remove(lineType);
    }

    _lastUsedLineTypes.insert(0, lineType);

    _setMostUsedLineType(lineType);
  }

  void _setMostUsedLineType(String lineType) {
    if (_mostUsedLineTypes.containsKey(lineType)) {
      _mostUsedLineTypes[lineType]!.incrementUse();
    } else {
      _mostUsedLineTypes[lineType] = MPTypeUsed(lineType);
    }
  }

  void setUsedPointType(String pointType) {
    if (_lastUsedPointTypes.contains(pointType)) {
      _lastUsedPointTypes.remove(pointType);
    }

    _lastUsedPointTypes.insert(0, pointType);

    _setMostUsedPointType(pointType);
  }

  void _setMostUsedPointType(String pointType) {
    if (_mostUsedPointTypes.containsKey(pointType)) {
      _mostUsedPointTypes[pointType]!.incrementUse();
    } else {
      _mostUsedPointTypes[pointType] = MPTypeUsed(pointType);
    }
  }

  THAreaType get lastUsedAreaType {
    if (_lastUsedAreaTypes.isEmpty) {
      return thDefaultAreaType;
    }

    final String lastUsedAreaType = _lastUsedAreaTypes.first;

    return THAreaType.values.byName(lastUsedAreaType);
  }

  THLineType get lastUsedLineType {
    if (_lastUsedLineTypes.isEmpty) {
      return thDefaultLineType;
    }

    final String lastUsedLineType = _lastUsedLineTypes.first;

    return THLineType.values.byName(lastUsedLineType);
  }

  THPointType get lastUsedPointType {
    if (_lastUsedPointTypes.isEmpty) {
      return thDefaultPointType;
    }

    final String lastUsedPointType = _lastUsedPointTypes.first;

    return THPointType.values.byName(lastUsedPointType);
  }

  List<THLineSegment> getLineSegmentsList({
    required THLine line,
    required bool clone,
  }) {
    final List<THLineSegment> lineSegments = <THLineSegment>[];
    final List<int> lineSegmentMPIDs = line.childrenMPID;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THElement lineSegment = _thFile.elementByMPID(lineSegmentMPID);

      if (lineSegment is THLineSegment) {
        lineSegments.add(clone ? lineSegment.copyWith() : lineSegment);
      }
    }

    return lineSegments;
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(THLine line) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final List<int> lineSegmentMPIDs = line.childrenMPID;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THElement lineSegment = _thFile.elementByMPID(lineSegmentMPID);

      if (lineSegment is THLineSegment) {
        lineSegmentsMap[lineSegment.mpID] = lineSegment;
      }
    }

    return lineSegmentsMap;
  }

  void substituteElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    _th2FileEditController.selectionController.addSelectableElement(
      modifiedElement,
    );
    _th2FileEditController.selectionController.updateSelectedElementClone(
      modifiedElement.mpID,
    );
    if (modifiedElement is THLineSegment) {
      _th2FileEditController.selectionController.updateSelectedLineSegment(
        modifiedElement,
      );
    }
  }

  void substituteElementWithoutAddSelectableElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
  }

  void substituteLineSegments(
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    for (final THLineSegment lineSegment in modifiedLineSegmentsMap.values) {
      _thFile.substituteElement(lineSegment);
    }

    final THLine line = _thFile.lineByMPID(
      modifiedLineSegmentsMap.values.first.parentMPID,
    );
    line.clearBoundingBox();
  }

  @action
  void applyInsertLineSegment({
    required THLineSegment newLineSegment,
    required int beforeLineSegmentMPID,
  }) {
    final THLine line = _thFile.lineByMPID(newLineSegment.parentMPID);

    line.insertLineSegmentBefore(newLineSegment, beforeLineSegmentMPID);
    _thFile.addElement(newLineSegment);
    _thFile.substituteElement(line);
    _th2FileEditController.selectionController.addSelectableElement(
      newLineSegment,
    );
    _th2FileEditController.selectionController.updateSelectedElementClone(
      newLineSegment.mpID,
    );
    _th2FileEditController.selectionController.updateSelectedElementClone(
      newLineSegment.parentMPID,
    );
    _th2FileEditController.selectionController.resetSelectableElements();
  }

  @action
  void applyAddElement({required THElement newElement}) {
    _thFile.addElement(newElement);

    final int parentMPID = newElement.parentMPID;

    if (parentMPID < 0) {
      _thFile.addElementToParent(newElement);
    } else {
      final THIsParentMixin parent = _thFile.parentByMPID(parentMPID);

      parent.addElementToParent(newElement);
    }

    _th2FileEditController.selectionController.addSelectableElement(newElement);
    _th2FileEditController.selectionController.updateSelectedElementClone(
      newElement.parentMPID,
    );
    _th2FileEditController.selectionController.resetSelectableElements();

    if (newElement is THScrap) {
      _th2FileEditController.updateHasMultipleScraps();
    }
  }

  void addElementWithParentMPIDWithoutSelectableElement({
    required THElement newElement,
    required int parentMPID,
  }) {
    addElementWithParentWithoutSelectableElement(
      newElement: newElement,
      parent: _thFile.parentByMPID(parentMPID),
    );
  }

  @action
  void addElementWithParentWithoutSelectableElement({
    required THElement newElement,
    required THIsParentMixin parent,
  }) {
    _thFile.addElement(newElement);
    parent.addElementToParent(newElement, positionInsideParent: false);

    if (newElement is THScrap) {
      _th2FileEditController.updateHasMultipleScraps();
    }
  }

  @action
  void removeElement(THElement element, {bool setState = false}) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    _thFile.removeElement(element);
    selectionController.removeSelectableElement(element.mpID);
    selectionController.removeSelectedElement(element, setState: setState);

    if (element is THLineSegment) {
      selectionController.removeSelectedLineSegment(element);
      selectionController.resetSelectableElements();
    }

    if (element is THScrap) {
      _th2FileEditController.updateHasMultipleScraps();
    }
  }

  void applyRemoveElementByMPID(int mpID, {bool setState = false}) {
    final THElement element = _thFile.elementByMPID(mpID);

    removeElement(element, setState: setState);
  }

  @action
  void removeElementByTHID(String thID) {
    final THElement element = _thFile.elementByTHID(thID);

    removeElement(element);
  }

  @action
  void applyRemoveElements(List<int> mpIDs) {
    for (final int mpID in mpIDs) {
      applyRemoveElementByMPID(mpID);
    }
  }

  @action
  void registerElementWithTHID(THElement element, String thID) {
    _thFile.registerElementWithTHID(element, thID);
  }

  @action
  THLine getNewLine() {
    _newLine ??= _createNewLine();

    return _newLine!;
  }

  @action
  THArea getNewArea() {
    _newArea ??= _createNewArea();

    return _newArea!;
  }

  @action
  void setNewLineStartScreenPosition(Offset lineStartScreenPosition) {
    _lineStartScreenPosition = lineStartScreenPosition;
  }

  @action
  void clearNewLine() {
    _newLine = null;
    _lineStartScreenPosition = null;
  }

  @action
  void clearNewArea() {
    _newArea = null;
  }

  THLine _createNewLine() {
    final THLine newLine = THLine(
      parentMPID: _th2FileEditController.activeScrapID,
      lineType: lastUsedLineType,
    );
    final THEndline endline = THEndline(parentMPID: newLine.mpID);

    _thFile.addElement(endline);
    newLine.addElementToParent(endline, positionInsideParent: false);

    return newLine;
  }

  THArea _createNewArea() {
    final THArea newArea = THArea(
      parentMPID: _th2FileEditController.activeScrapID,
      areaType: lastUsedAreaType,
    );
    final THEndarea endarea = THEndarea(parentMPID: newArea.mpID);

    _thFile.addElement(newArea);
    _thFile.addElementToParent(newArea);
    addAutomaticTHIDOption(parent: newArea, prefix: mpAreaTHIDPrefix);
    _thFile.addElement(endarea);
    newArea.addElementToParent(endarea, positionInsideParent: false);

    return newArea;
  }

  void addAutomaticTHIDOption({
    required THHasOptionsMixin parent,
    String prefix = '',
  }) {
    final String newTHID = _thFile.getNewTHID(element: parent, prefix: prefix);

    THIDCommandOption(optionParent: parent, thID: newTHID);
    registerElementWithTHID(parent, newTHID);
  }

  @action
  void setNewLine(THLine newLine) {
    _newLine = newLine;
  }

  @action
  void updateBezierLineSegment(
    Offset quadraticControlPointPositionScreenCoordinates,
  ) {
    if ((_newLine == null) || (_newLine!.childrenMPID.length < 2)) {
      return;
    }

    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    final THLineSegment lastLineSegment = _thFile.lineSegmentByMPID(
      _newLine!.lineSegmentMPIDs.last,
    );
    final THLineSegment secondToLastLineSegment = _thFile.lineSegmentByMPID(
      _newLine!.lineSegmentMPIDs.elementAt(
        _newLine!.lineSegmentMPIDs.length - 2,
      ),
    );

    final Offset startPoint = secondToLastLineSegment.endPoint.coordinates;
    final Offset endPoint = lastLineSegment.endPoint.coordinates;

    final Offset quadraticControlPointPositionCanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(
          quadraticControlPointPositionScreenCoordinates,
        );
    final Offset twoThirdsControlPoint =
        quadraticControlPointPositionCanvasCoordinates * (2 / 3);

    /// Based on https://pomax.github.io/bezierinfo/#reordering
    final Offset controlPoint1 = (startPoint / 3) + twoThirdsControlPoint;
    final Offset controlPoint2 = (endPoint / 3) + twoThirdsControlPoint;

    if (lastLineSegment is THStraightLineSegment) {
      final THBezierCurveLineSegment bezierCurveLineSegment =
          THBezierCurveLineSegment.forCWJM(
            mpID: lastLineSegment.mpID,
            parentMPID: _newLine!.mpID,
            endPoint: THPositionPart(
              coordinates: endPoint,
              decimalPositions: currentDecimalPositions,
            ),
            controlPoint1: THPositionPart(
              coordinates: controlPoint1,
              decimalPositions: currentDecimalPositions,
            ),
            controlPoint2: THPositionPart(
              coordinates: controlPoint2,
              decimalPositions: currentDecimalPositions,
            ),
            optionsMap: LinkedHashMap<THCommandOptionType, THCommandOption>(),
            attrOptionsMap: LinkedHashMap<String, THAttrCommandOption>(),
            originalLineInTH2File: '',
            sameLineComment: '',
          );
      final THSmoothCommandOption smoothOn = THSmoothCommandOption(
        optionParent: bezierCurveLineSegment,
        choice: THOptionChoicesOnOffAutoType.on,
      );

      bezierCurveLineSegment.addUpdateOption(smoothOn);

      final MPEditLineSegmentCommand command = MPEditLineSegmentCommand(
        originalLineSegment: lastLineSegment,
        newLineSegment: bezierCurveLineSegment,
      );

      _th2FileEditController.execute(command);
      _missingStepsPreserveStraightToBezierConversionUndoRedo = 2;
    } else {
      final THBezierCurveLineSegment bezierCurveLineSegment =
          (lastLineSegment as THBezierCurveLineSegment).copyWith(
            controlPoint1: THPositionPart(
              coordinates: controlPoint1,
              decimalPositions: currentDecimalPositions,
            ),
            controlPoint2: THPositionPart(
              coordinates: controlPoint2,
              decimalPositions: currentDecimalPositions,
            ),
            originalLineInTH2File: '',
          );
      final MPEditLineSegmentCommand command = MPEditLineSegmentCommand(
        originalLineSegment: lastLineSegment,
        newLineSegment: bezierCurveLineSegment,
      );

      if (_missingStepsPreserveStraightToBezierConversionUndoRedo == 0) {
        _th2FileEditController.executeAndSubstituteLastUndo(command);
      } else {
        _th2FileEditController.execute(command);
        _missingStepsPreserveStraightToBezierConversionUndoRedo--;
      }
    }

    _th2FileEditController.triggerNewLineRedraw();
  }

  THStraightLineSegment _createStraightLineSegment(
    Offset endpoint,
    int lineMPID,
  ) {
    final Offset endPointCanvasCoordinates = _th2FileEditController
        .offsetScreenToCanvas(endpoint);

    final THStraightLineSegment lineSegment = THStraightLineSegment(
      parentMPID: lineMPID,
      endPoint: THPositionPart(
        coordinates: endPointCanvasCoordinates,
        decimalPositions: _th2FileEditController.currentDecimalPositions,
      ),
    );

    return lineSegment;
  }

  @action
  void addNewLineLineSegment(Offset enPointScreenCoordinates) {
    if (_newLine == null) {
      if (_lineStartScreenPosition == null) {
        _lineStartScreenPosition = enPointScreenCoordinates;
      } else {
        final THLine newLine = getNewLine();
        final int lineMPID = newLine.mpID;
        final List<THElement> lineSegments = <THElement>[];

        lineSegments.add(
          _createStraightLineSegment(_lineStartScreenPosition!, lineMPID),
        );
        lineSegments.add(
          _createStraightLineSegment(enPointScreenCoordinates, lineMPID),
        );

        final MPAddLineCommand command = MPAddLineCommand(
          newLine: newLine,
          lineChildren: lineSegments,
          lineStartScreenPosition: _lineStartScreenPosition,
        );

        _th2FileEditController.execute(command);
      }
    } else {
      final int lineMPID = getNewLine().mpID;
      final THStraightLineSegment newLineSegment = _createStraightLineSegment(
        enPointScreenCoordinates,
        lineMPID,
      );
      final MPAddLineSegmentCommand command = MPAddLineSegmentCommand(
        newLineSegment: newLineSegment,
      );

      _th2FileEditController.execute(command);
    }

    _th2FileEditController.triggerNewLineRedraw();
  }

  @action
  void applyAddLine({
    required THLine newLine,
    required List<THElement> lineChildren,
    Offset? lineStartScreenPosition,
  }) {
    final TH2FileEditElementEditController elementEditController =
        _th2FileEditController.elementEditController;

    elementEditController.applyAddElement(newElement: newLine);

    for (final THElement child in lineChildren) {
      elementEditController.applyAddElement(newElement: child);
    }

    if (lineStartScreenPosition != null) {
      setNewLine(newLine);
      setNewLineStartScreenPosition(lineStartScreenPosition);
    }

    _th2FileEditController.selectionController.addSelectableElement(newLine);
  }

  @action
  void applyRemoveArea(int areaMPID) {
    _th2FileEditController.elementEditController.applyRemoveElementByMPID(
      areaMPID,
    );
  }

  @action
  void applyRemoveLine(int lineMPID) {
    if ((_newLine != null) && (_newLine!.mpID == lineMPID)) {
      clearNewLine();
    }
    _th2FileEditController.elementEditController.applyRemoveElementByMPID(
      lineMPID,
    );
  }

  @action
  void finalizeNewLineCreation() {
    if (_newLine != null) {
      _th2FileEditController.selectionController.addSelectableElement(
        _newLine!,
      );
    }

    clearNewLine();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
    _th2FileEditController.triggerNewLineRedraw();
    _th2FileEditController.updateUndoRedoStatus();
  }

  @action
  void finalizeNewAreaCreation() {
    if (_newArea != null) {
      _th2FileEditController.selectionController.addSelectableElement(
        _newArea!,
      );
    }

    clearNewArea();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
    _th2FileEditController.triggerNewLineRedraw();
    _th2FileEditController.updateUndoRedoStatus();
  }

  void updateOptionEdited({bool attrOptionEdited = true}) {
    _th2FileEditController.optionEditController.clearCurrentOptionType();
    _th2FileEditController.selectionController.updateSelectedElementsClones();

    if (attrOptionEdited) {
      _th2FileEditController.overlayWindowController.setShowOverlayWindow(
        MPWindowType.optionChoices,
        false,
      );
    }

    if (_th2FileEditController
        .optionEditController
        .optionsEditForLineSegments) {
      _th2FileEditController.optionEditController
          .updateElementOptionMapForLineSegments();
    } else {
      _th2FileEditController.optionEditController.updateOptionStateMap();
    }
  }

  @action
  void applySetOptionToElement(THCommandOption option) {
    option.optionParent(_thFile).addUpdateOption(option);

    if (option is THIDCommandOption) {
      _thFile.registerMPIDWithTHID(option.parentMPID, option.thID);
    }

    if (option.parentMPID >= 0) {
      final THElement parentElement = _thFile.elementByMPID(option.parentMPID);

      _thFile.substituteElement(
        parentElement.copyWith(originalLineInTH2File: ''),
      );
    }

    updateOptionEdited(
      attrOptionEdited: option.type != THCommandOptionType.attr,
    );
  }

  @action
  void applyRemoveOptionFromElement({
    required THCommandOptionType optionType,
    required int parentMPID,
    required String newOriginalLineInTH2File,
  }) {
    final THHasOptionsMixin parentElement = _th2FileEditController.thFile
        .hasOptionByMPID(parentMPID);

    if (optionType == THCommandOptionType.id) {
      _thFile.unregisterElementTHIDByMPID(parentMPID);
    }

    parentElement.removeOption(optionType);
    _thFile.substituteElement(
      parentElement.copyWith(originalLineInTH2File: newOriginalLineInTH2File),
    );
    updateOptionEdited();
  }

  @action
  void applyRemoveAttrOptionFromElement({
    required String attrName,
    required int parentMPID,
    required String newOriginalLineInTH2File,
  }) {
    final THHasOptionsMixin parentElement = _th2FileEditController.thFile
        .hasOptionByMPID(parentMPID);

    parentElement.removeAttrOption(attrName);
    _thFile.substituteElement(
      parentElement.copyWith(originalLineInTH2File: newOriginalLineInTH2File),
    );
    updateOptionEdited(attrOptionEdited: false);
  }

  @action
  void applyRemoveSelectedLineSegments() {
    final Iterable<int> selectedLineSegmentMPIDs = _th2FileEditController
        .selectionController
        .selectedEndControlPoints
        .keys
        .toList();

    if (selectedLineSegmentMPIDs.isEmpty) {
      return;
    } else if (selectedLineSegmentMPIDs.length == 1) {
      final MPCommand removeCommand = getRemoveLineSegmentCommand(
        selectedLineSegmentMPIDs.first,
      );

      _th2FileEditController.execute(removeCommand);
    } else {
      final List<MPCommand> removeLineSegmentCommands = [];

      for (final int lineSegmentMPID in selectedLineSegmentMPIDs) {
        final MPCommand removeLineSegmentCommand = getRemoveLineSegmentCommand(
          lineSegmentMPID,
        );

        removeLineSegmentCommand.execute(_th2FileEditController);
        removeLineSegmentCommands.add(removeLineSegmentCommand);
      }

      final MPCommand removeCommand = MPMultipleElementsCommand.forCWJM(
        commandsList: removeLineSegmentCommands,
        completionType:
            MPMultipleElementsCommandCompletionType.lineSegmentsRemoved,
        descriptionType: MPCommandDescriptionType.removeLineSegment,
      );

      _th2FileEditController.undoRedoController.add(removeCommand);
    }

    _th2FileEditController.updateUndoRedoStatus();
    _th2FileEditController.selectionController
        .updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  MPCommand getRemoveLineSegmentCommand(int lineSegmentMPID) {
    final THLineSegment lineSegment = _thFile.lineSegmentByMPID(
      lineSegmentMPID,
    );
    final THLine line = _thFile.lineByMPID(lineSegment.parentMPID);
    final List<THLineSegment> lineSegments = line.getLineSegments(_thFile);
    final int lineSegmentIndex = lineSegments.indexOf(lineSegment);

    if ((lineSegmentIndex == 0) ||
        (lineSegmentIndex == lineSegments.length - 1)) {
      return MPRemoveLineSegmentCommand(lineSegment: lineSegment);
    } else {
      final THLineSegment nextLineSegment = lineSegments[lineSegmentIndex + 1];
      final bool deletedLineSegmentIsStraight =
          lineSegment is THStraightLineSegment;
      final bool nextLineSegmentIsStraight =
          nextLineSegment is THStraightLineSegment;

      if (deletedLineSegmentIsStraight && nextLineSegmentIsStraight) {
        return MPRemoveLineSegmentCommand(lineSegment: lineSegment);
      } else {
        final THBezierCurveLineSegment deletedLineSegmentBezier =
            deletedLineSegmentIsStraight
            ? MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: line
                    .getPreviousLineSegment(lineSegment, _thFile)
                    .endPoint
                    .coordinates,
                straightLineSegment: lineSegment,
                decimalPositions:
                    _th2FileEditController.currentDecimalPositions,
              )
            : lineSegment as THBezierCurveLineSegment;
        final THBezierCurveLineSegment nextLineSegmentBezier =
            nextLineSegmentIsStraight
            ? MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: lineSegment.endPoint.coordinates,
                straightLineSegment: nextLineSegment,
                decimalPositions:
                    _th2FileEditController.currentDecimalPositions,
              )
            : nextLineSegment as THBezierCurveLineSegment;
        final THBezierCurveLineSegment lineSegmentSubstitution =
            THBezierCurveLineSegment.forCWJM(
              mpID: nextLineSegmentBezier.mpID,
              parentMPID: nextLineSegmentBezier.parentMPID,
              controlPoint1: deletedLineSegmentBezier.controlPoint1,
              controlPoint2: nextLineSegmentBezier.controlPoint2,
              endPoint: nextLineSegmentBezier.endPoint,
              optionsMap: nextLineSegmentBezier.optionsMap,
              attrOptionsMap: nextLineSegmentBezier.attrOptionsMap,
              originalLineInTH2File: '',
            );

        return MPMultipleElementsCommandFactory.removeLineSegmentWithSubstitution(
          lineSegmentMPID: lineSegmentMPID,
          lineSegmentSubstitution: lineSegmentSubstitution,
          thFile: _th2FileEditController.thFile,
        );
      }
    }
  }

  @action
  void applyAddLineSegmentsBetweenSelectedLineSegments() {
    final Map<int, MPSelectedEndControlPoint> selectedEndControlPoints =
        _th2FileEditController.selectionController.selectedEndControlPoints;

    if (selectedEndControlPoints.length < 2) {
      return;
    }

    final Map<int, THLineSegment> selectedLineSegmentsPosMap = {};
    final THLine line = _thFile.lineByMPID(
      selectedEndControlPoints.values.first.originalLineSegmentClone.parentMPID,
    );
    final List<int> lineSegmentMPIDs = line.lineSegmentMPIDs;

    for (final MPSelectedEndControlPoint endControlPoint
        in selectedEndControlPoints.values) {
      final THLineSegment lineSegment =
          endControlPoint.originalLineSegmentClone;

      selectedLineSegmentsPosMap[lineSegmentMPIDs.indexOf(
            endControlPoint.mpID,
          )] =
          lineSegment;
    }

    final List<int> orderedSelectedLineSegmentMPIDs =
        selectedLineSegmentsPosMap.keys.toList()
          ..sort((a, b) => a.compareTo(b));
    final int decimalPositions = _th2FileEditController.currentDecimalPositions;
    final List<MPCommand> addLineSegmentsCommands = [];

    int? previousLineSegmentPos;

    for (final int lineSegmentPos in orderedSelectedLineSegmentMPIDs) {
      if (previousLineSegmentPos == null) {
        previousLineSegmentPos = lineSegmentPos;
        continue;
      }

      if (lineSegmentPos == previousLineSegmentPos + 1) {
        final THLineSegment lineSegment =
            selectedLineSegmentsPosMap[lineSegmentPos]!;
        final THLineSegment previousLineSegment =
            selectedLineSegmentsPosMap[previousLineSegmentPos]!;

        if (lineSegment is THStraightLineSegment) {
          final Offset newLineSegmentendPoint =
              (previousLineSegment.endPoint.coordinates +
                  lineSegment.endPoint.coordinates) /
              2;
          final THStraightLineSegment newLineSegment = THStraightLineSegment(
            parentMPID: lineSegment.parentMPID,
            endPoint: THPositionPart(
              coordinates: newLineSegmentendPoint,
              decimalPositions: decimalPositions,
            ),
          );

          addLineSegmentsCommands.add(
            MPAddLineSegmentCommand(
              newLineSegment: newLineSegment,
              beforeLineSegmentMPID: lineSegment.mpID,
            ),
          );
        } else {
          final newLineSegments = MPNumericAux.splitBezierCurveAtHalfLength(
            startPoint: previousLineSegment.endPoint.coordinates,
            lineSegment: lineSegment as THBezierCurveLineSegment,
            decimalPositions: decimalPositions,
          );

          if (newLineSegments.length != 2) {
            throw Exception(
              'Error: newLineSegments.length != 2 at TH2FileEditElementEditController.applyAddLineSegmentsBetweenSelectedLineSegments(). Length: ${newLineSegments.length}',
            );
          }

          addLineSegmentsCommands.add(
            MPAddLineSegmentCommand(
              newLineSegment: newLineSegments[0],
              beforeLineSegmentMPID: lineSegment.mpID,
            ),
          );
          addLineSegmentsCommands.add(
            MPEditLineSegmentCommand(
              originalLineSegment: lineSegment,
              newLineSegment: lineSegment.copyWith(
                controlPoint1: newLineSegments[1].controlPoint1,
                controlPoint2: newLineSegments[1].controlPoint2,
              ),
            ),
          );
        }
      }

      previousLineSegmentPos = lineSegmentPos;
    }

    final MPCommand addLineSegmentsCommand = MPMultipleElementsCommand.forCWJM(
      commandsList: addLineSegmentsCommands,
      completionType: MPMultipleElementsCommandCompletionType.lineSegmentsAdded,
      descriptionType: MPCommandDescriptionType.addLineSegment,
    );

    _th2FileEditController.execute(addLineSegmentsCommand);
    _th2FileEditController.selectionController
        .updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  void addImage() async {
    final BuildContext? currentContext = _th2FileEditController
        .overlayWindowController
        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeImageButton]!
        .currentContext;

    if (currentContext == null) {
      return;
    }

    final String imagePath = await MPDialogAux.pickImageFile(currentContext);

    final String relativeImagePath = p.relative(
      imagePath,
      from: p.dirname(_thFile.filename),
    );
    final Rect fileBoundingBox = _thFile.getBoundingBox(_th2FileEditController);
    final THXTherionImageInsertConfig
    newImage = THXTherionImageInsertConfig.adjustPosition(
      parentMPID: _thFile.mpID,
      filename: relativeImagePath,
      xx: THDoublePart(value: fileBoundingBox.left),
      // For Flutter's canvas, the top is 0 and positive values of Y go down but
      // in the TH2 format, the top is the maximum Y value.
      // That's why Flutter calls the maximum Y value "bottom" and despite being
      // called *bottom*, we use it to align the new image to the *top* left
      // point of the current drawing.
      yy: THDoublePart(value: fileBoundingBox.bottom),
      th2FileEditController: _th2FileEditController,
    );
    final MPAddXTherionImageInsertConfigCommand addImageCommand =
        MPAddXTherionImageInsertConfigCommand(newImageInsertConfig: newImage);

    _th2FileEditController.execute(addImageCommand);
    _th2FileEditController.triggerImagesRedraw();
  }

  void removeImage(int mpID) {
    final MPRemoveXTherionImageInsertConfigCommand removeImageCommand =
        MPRemoveXTherionImageInsertConfigCommand(
          xtherionImageInsertConfigMPID: mpID,
        );

    _th2FileEditController.execute(removeImageCommand);
    _th2FileEditController.triggerImagesRedraw();
  }

  void updateControlPointSmoothInfo() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (selectionController.mpSelectedElementsLogical.values.first
                as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final MPSelectedEndControlPoint selectedControlPoint =
        selectionController.selectedEndControlPoints.values.first;
    final THBezierCurveLineSegment controlPointLineSegment =
        selectedControlPoint.originalElementClone as THBezierCurveLineSegment;
    final int controlPointLineSegmentMPID = controlPointLineSegment.mpID;
    final THBezierCurveLineSegment originalControlPointLineSegment =
        originalLineSegments[controlPointLineSegmentMPID]
            as THBezierCurveLineSegment;

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        final THLine line = _thFile.lineByMPID(
          controlPointLineSegment.parentMPID,
        );
        final THLineSegment originalPreviousLineSegment = line
            .getPreviousLineSegment(controlPointLineSegment, _thFile);

        if (MPCommandOptionAux.isSmooth(originalPreviousLineSegment)) {
          if (originalPreviousLineSegment is THStraightLineSegment) {
            final THLineSegment originalSecondPreviousLineSegment = line
                .getPreviousLineSegment(originalPreviousLineSegment, _thFile);
            final Offset segmentStart =
                originalSecondPreviousLineSegment.endPoint.coordinates;
            final Offset segmentEnd =
                originalPreviousLineSegment.endPoint.coordinates;
            final Offset segment = segmentEnd - segmentStart;

            moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
              isSmooth: true,
              isAdjacentStraight: true,
              lineSegment: originalControlPointLineSegment,
              controlPointType: MPEndControlPointType.controlPoint1,
              straightStart: segmentStart,
              straightEnd: segmentEnd,
              straightLine: segment,
            );
          } else {
            moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
              isSmooth: true,
              isAdjacentStraight: false,
              lineSegment: originalControlPointLineSegment,
              controlPointType: MPEndControlPointType.controlPoint1,
              adjacentLineSegment:
                  originalPreviousLineSegment as THBezierCurveLineSegment,
            );
          }
        } else {
          moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
            isSmooth: false,
            lineSegment: originalControlPointLineSegment,
            controlPointType: MPEndControlPointType.controlPoint1,
          );
        }
      default:
    }
  }
}

class MPTypeUsed {
  final String type;
  int count = 1;
  DateTime lastUsed = DateTime.now();

  MPTypeUsed(this.type);

  void incrementUse() {
    count++;
    lastUsed = DateTime.now();
  }
}
