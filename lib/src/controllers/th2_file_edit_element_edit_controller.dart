import 'dart:collection';

import 'package:flutter/animation.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mobx/mobx.dart';

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

  int _missingStepsPreserveStraightToBezierConversionUndoRedo = 2;

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
    final List<MapEntry<String, MPTypeUsed>> entries =
        mostUsedTypesMap.entries.toList();

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
    final Set<int> lineSegmentMPIDs = line.childrenMPID;

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
    final Set<int> lineSegmentMPIDs = line.childrenMPID;

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
    _th2FileEditController.selectionController
        .addSelectableElement(modifiedElement);
    _th2FileEditController.selectionController
        .updateSelectedElementClone(modifiedElement.mpID);
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

    final THLine line =
        _thFile.lineByMPID(modifiedLineSegmentsMap.values.first.parentMPID);
    line.clearBoundingBox();
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
    _th2FileEditController.updateHasMultipleScraps();
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
    parent.addElementToParent(newElement);
    _th2FileEditController.updateHasMultipleScraps();
  }

  @action
  void removeElement(THElement element) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    _thFile.removeElement(element);
    selectionController.removeSelectableElement(element.mpID);
    selectionController.removeSelectedElement(element);
    _th2FileEditController.updateHasMultipleScraps();
  }

  void applyRemoveElementByMPID(int mpID) {
    final THElement element = _thFile.elementByMPID(mpID);

    removeElement(element);
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
  void setNewLineStartScreenPosition(Offset lineStartScreenPosition) {
    _lineStartScreenPosition = lineStartScreenPosition;
  }

  @action
  void clearNewLine() {
    _newLine = null;
    _lineStartScreenPosition = null;
  }

  THLine _createNewLine() {
    final THLine newLine = THLine(
      parentMPID: _th2FileEditController.activeScrapID,
      lineType: lastUsedLineType,
    );

    _th2FileEditController.elementEditController
        .addElementWithParentMPIDWithoutSelectableElement(
      newElement: newLine,
      parentMPID: _th2FileEditController.activeScrapID,
    );

    return newLine;
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

    final THLineSegment lastLineSegment =
        _thFile.lineSegmentByMPID(_newLine!.childrenMPID.last);
    final THLineSegment secondToLastLineSegment = _thFile.lineSegmentByMPID(
      _newLine!.childrenMPID.elementAt(_newLine!.childrenMPID.length - 2),
    );

    final Offset startPoint = secondToLastLineSegment.endPoint.coordinates;
    final Offset endPoint = lastLineSegment.endPoint.coordinates;

    final Offset quadraticControlPointPositionCanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(
            quadraticControlPointPositionScreenCoordinates);
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
        originalLineInTH2File: '',
        sameLineComment: '',
      );
      final THSmoothCommandOption smoothOn = THSmoothCommandOption(
        optionParent: bezierCurveLineSegment,
        choice: THOptionChoicesOnOffAutoType.on,
      );

      bezierCurveLineSegment.addUpdateOption(smoothOn);

      final MPEditLineSegmentCommand command = MPEditLineSegmentCommand(
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
      );
      final MPEditLineSegmentCommand command = MPEditLineSegmentCommand(
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
    final Offset endPointCanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(endpoint);

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

        lineSegments.add(_createStraightLineSegment(
          _lineStartScreenPosition!,
          lineMPID,
        ));
        lineSegments.add(_createStraightLineSegment(
          enPointScreenCoordinates,
          lineMPID,
        ));

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
    final THLine newLineCopy = newLine.copyWith(childrenMPID: {});

    elementEditController.applyAddElement(newElement: newLineCopy);

    for (final THElement child in lineChildren) {
      elementEditController.applyAddElement(newElement: child);
    }

    if (lineStartScreenPosition != null) {
      setNewLine(newLineCopy);
      setNewLineStartScreenPosition(lineStartScreenPosition);
    }

    _th2FileEditController.selectionController
        .addSelectableElement(newLineCopy);
  }

  @action
  void applyRemoveLine(int lineMPID) {
    if ((_newLine != null) && (_newLine!.mpID == lineMPID)) {
      clearNewLine();
    }
    _th2FileEditController.elementEditController
        .applyRemoveElementByMPID(lineMPID);
  }

  @action
  void finalizeNewLineCreation() {
    if (_newLine != null) {
      _th2FileEditController.selectionController
          .addSelectableElement(_newLine!);
    }

    clearNewLine();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
    _th2FileEditController.triggerNewLineRedraw();
    _th2FileEditController.updateUndoRedoStatus();
  }

  void updateOptionEdited() {
    _th2FileEditController.optionEditController.clearCurrentOptionType();
    _th2FileEditController.selectionController.updateSelectedElementsClones();
    _th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
    _th2FileEditController.optionEditController.updateOptionStateMap();
  }

  @action
  void applySetOptionToElement(THCommandOption option) {
    option.optionParent(_thFile).addUpdateOption(option);

    if (option is THIDCommandOption) {
      _thFile.registerMPIDWithTHID(option.parentMPID, option.thID);
    }

    updateOptionEdited();
  }

  @action
  void applyRemoveOptionFromElement({
    required THCommandOptionType optionType,
    required int parentMPID,
  }) {
    final THHasOptionsMixin parentElement =
        _th2FileEditController.thFile.hasOptionByMPID(parentMPID);

    if (optionType is THIDCommandOption) {
      _thFile.unregisterElementTHIDByMPID(parentMPID);
    }

    parentElement.removeOption(optionType);
    updateOptionEdited();
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
