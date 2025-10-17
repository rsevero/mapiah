import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/auxiliary/mp_line_simplification_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_bezier_to_bezier.dart';
import 'package:mapiah/src/auxiliary/mp_simplify_straight_to_bezier.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mp_add_scrap_dialog_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
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
    final Iterable<THElement> elements = _thFile.elements.values;

    for (final THElement element in elements) {
      switch (element) {
        case THArea _:
          _setMostUsedAreaType(element.plaType);
        case THLine _:
          _setMostUsedLineType(element.plaType);
        case THPoint _:
          _setMostUsedPointType(element.plaType);
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

  @readonly
  THScrap? _newScrap;

  @readonly
  List<MPSelectedLine>? _originalSimplifiedLines;

  @readonly
  double _straightLineSimplifyEpsilonOnCanvas =
      mpStraightLineSimplifyEpsilonOnScreen;

  @readonly
  MPLineSimplificationMethod _lineSimplificationMethod =
      MPLineSimplificationMethod.keepOriginalTypes;

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

  String get lastUsedAreaType {
    if (_lastUsedAreaTypes.isEmpty) {
      return thDefaultAreaType.name;
    }

    final String lastUsedAreaType = _lastUsedAreaTypes.first;

    return lastUsedAreaType;
  }

  String get lastUsedLineType {
    if (_lastUsedLineTypes.isEmpty) {
      return thDefaultLineType.name;
    }

    final String lastUsedLineType = _lastUsedLineTypes.first;

    return lastUsedLineType;
  }

  String get lastUsedPointType {
    if (_lastUsedPointTypes.isEmpty) {
      return thDefaultPointType.name;
    }

    final String lastUsedPointType = _lastUsedPointTypes.first;

    return lastUsedPointType;
  }

  List<THLineSegment> getLineSegmentsList({
    required THLine line,
    required bool clone,
  }) {
    final List<THLineSegment> lineSegments = <THLineSegment>[];
    final List<int> lineSegmentMPIDs = line.childrenMPIDs;

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
    final List<int> lineSegmentMPIDs = line.childrenMPIDs;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final THElement lineSegment = _thFile.elementByMPID(lineSegmentMPID);

      if (lineSegment is THLineSegment) {
        lineSegmentsMap[lineSegment.mpID] = lineSegment;
      }
    }

    return lineSegmentsMap;
  }

  void substituteElement(THElement modifiedElement) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    _thFile.substituteElement(modifiedElement);
    selectionController.addSelectableElement(modifiedElement);
    selectionController.updateSelectedElementClone(modifiedElement.mpID);
    if (modifiedElement is THLineSegment) {
      selectionController.updateSelectedLineSegment(modifiedElement);
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

  void replaceLineLineSegments(
    int lineMPID,
    List<({int lineSegmentPosition, THLineSegment lineSegment})>
    newLineSegments,
  ) {
    final THLine line = _thFile.lineByMPID(lineMPID);
    final List<int> originalLineSegmentMPIDs = line
        .getLineSegmentMPIDs(_thFile)
        .toList();

    for (final int originalLineSegmentMPID in originalLineSegmentMPIDs) {
      final THLineSegment originalLineSegment = _thFile.lineSegmentByMPID(
        originalLineSegmentMPID,
      );

      _thFile.removeElement(originalLineSegment);
    }

    for (final ({int lineSegmentPosition, THLineSegment lineSegment})
        newLineSegment
        in newLineSegments) {
      _thFile.addElement(newLineSegment.lineSegment);
      line.addElementToParent(
        newLineSegment.lineSegment,
        elementPositionInParent: newLineSegment.lineSegmentPosition,
      );
    }
  }

  @action
  void applyAddLineSegment({
    required THLineSegment newLineSegment,
    required int lineSegmentPositionInParent,
  }) {
    applyAddElement(
      newElement: newLineSegment,
      childPositionInParent: lineSegmentPositionInParent,
    );
  }

  @action
  void afterAddLineSegment(THLineSegment newLineSegment) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    selectionController.updateSelectedElementClone(newLineSegment.mpID);
    selectionController.updateSelectedElementClone(newLineSegment.parentMPID);
    selectionController.resetSelectableElements();
    (newLineSegment.parent(_thFile) as THLine).clearBoundingBox();
  }

  @action
  void applyAddElement({
    required THElement newElement,
    THIsParentMixin? parent,
    int childPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final int parentMPID;
    final THIsParentMixin parentElement;

    if (parent == null) {
      parentMPID = newElement.parentMPID;
      parentElement = (parentMPID < 0)
          ? _thFile
          : _thFile.parentByMPID(parentMPID);
    } else {
      parentMPID = parent.mpID;
      parentElement = parent;
    }

    _thFile.addElement(newElement);

    parentElement.addElementToParent(
      newElement,
      elementPositionInParent: childPositionInParent,
    );
  }

  @action
  void afterAddPoint(THPoint newPoint) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    _th2FileEditController.setActiveScrapByChildElement(newPoint);
    selectionController.addSelectableElement(newPoint);
    selectionController.updateSelectedElementClone(newPoint.mpID);
    _th2FileEditController.triggerAllElementsRedraw();
  }

  @action
  void removeElement(THElement element, {bool setState = false}) {
    _removeElement(element, setState: setState);
  }

  void _removeElement(THElement element, {bool setState = false}) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    if (element is THIsParentMixin) {
      final List<int> childrenMPIDList = (element as THIsParentMixin)
          .childrenMPIDs
          .toList();

      for (final int childMPID in childrenMPIDList) {
        final THElement child = _thFile.elementByMPID(childMPID);

        _removeElement(child);
      }
    }

    _thFile.removeElement(element);
    selectionController.removeElementFromSelectable(element.mpID);
    selectionController.removeElementFromSelected(element, setState: setState);

    if (element is THLineSegment) {
      selectionController.removeSelectedLineSegment(element);
    } else if (element is THScrap) {
      _th2FileEditController.updateHasMultipleScraps();
    } else if (element is THArea) {
      if ((_newArea != null) && (_newArea!.mpID == element.mpID)) {
        clearNewArea();
      }
    }

    final int parentMPID = element.parentMPID;

    if (parentMPID > 0) {
      final THIsParentMixin parent = _thFile.parentByMPID(parentMPID);

      if (parent is THElement) {
        selectionController.updateSelectedElementClone(parentMPID);
      }
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
    if (_newLine == null) {
      throw Exception(
        'At TH2FileEditElementController.getNewLine(): new line has not been created',
      );
    }

    return _newLine!;
  }

  @action
  THArea getNewArea() {
    _newArea ??= _createNewArea();

    return _newArea!;
  }

  @action
  void createScrap({
    required String thID,
    List<THElement>? scrapChildren,
    List<THCommandOption>? scrapOptions,
  }) {
    final MPCommand addScrapCommand = MPCommandFactory.addScrap(
      thID: thID,
      thFile: _thFile,
      scrapChildren: scrapChildren,
      scrapOptions: scrapOptions,
    );

    _th2FileEditController.execute(addScrapCommand);
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

  THArea _createNewArea() {
    final THArea newArea = THArea.fromString(
      parentMPID: _th2FileEditController.activeScrapID,
      areaTypeString: lastUsedAreaType,
    );
    final THEndarea endarea = THEndarea(parentMPID: newArea.mpID);

    applyAddArea(newArea: newArea, areaChildren: [endarea]);

    return newArea;
  }

  void addAutomaticTHIDOption({
    required THHasOptionsMixin element,
    String prefix = '',
  }) {
    final String newTHID = _thFile.getNewTHID(element: element, prefix: prefix);

    THIDCommandOption(parentMPID: element.mpID, thID: newTHID);

    registerElementWithTHID(element, newTHID);
  }

  @action
  void setNewLine(THLine newLine) {
    _newLine = newLine;
  }

  @action
  void updateBezierLineSegment(
    Offset quadraticControlPointPositionScreenCoordinates,
  ) {
    if ((_newLine == null) || (_newLine!.childrenMPIDs.length < 2)) {
      return;
    }

    final List<int> lineSegmentMPIDs = _newLine!.getLineSegmentMPIDs(_thFile);
    final THLineSegment lastLineSegment = _thFile.lineSegmentByMPID(
      lineSegmentMPIDs.last,
    );
    final THLineSegment secondToLastLineSegment = _thFile.lineSegmentByMPID(
      lineSegmentMPIDs.elementAt(lineSegmentMPIDs.length - 2),
    );

    final THPositionPart startPoint = secondToLastLineSegment.endPoint;
    final THPositionPart endPoint = lastLineSegment.endPoint;
    final Offset startPointCoordinates = startPoint.coordinates;
    final Offset endPointCoordinates = endPoint.coordinates;

    final Offset quadraticControlPointPositionCanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(
          quadraticControlPointPositionScreenCoordinates,
        );
    final Offset twoThirdsControlPoint =
        quadraticControlPointPositionCanvasCoordinates * (2 / 3);

    /// Based on https://pomax.github.io/bezierinfo/#reordering
    final Offset controlPoint1 =
        (startPointCoordinates / 3) + twoThirdsControlPoint;
    final Offset controlPoint2 =
        (endPointCoordinates / 3) + twoThirdsControlPoint;

    if (lastLineSegment is THStraightLineSegment) {
      final THBezierCurveLineSegment bezierCurveLineSegment =
          THBezierCurveLineSegment.forCWJM(
            mpID: lastLineSegment.mpID,
            parentMPID: _newLine!.mpID,
            endPoint: endPoint,
            controlPoint1: THPositionPart(coordinates: controlPoint1),
            controlPoint2: THPositionPart(coordinates: controlPoint2),
            optionsMap: lastLineSegment.optionsMap,
            attrOptionsMap: lastLineSegment.attrOptionsMap,
            originalLineInTH2File: '',
            sameLineComment: lastLineSegment.sameLineComment,
          );
      final THSmoothCommandOption smoothOn = THSmoothCommandOption(
        parentMPID: bezierCurveLineSegment.mpID,
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
            controlPoint1: THPositionPart(coordinates: controlPoint1),
            controlPoint2: THPositionPart(coordinates: controlPoint2),
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
  void addNewLineLineSegment(Offset endPointScreenCoordinates) {
    if (_newLine == null) {
      if (_lineStartScreenPosition == null) {
        _lineStartScreenPosition = endPointScreenCoordinates;
      } else {
        _newLine = THLine.fromString(
          parentMPID: _th2FileEditController.activeScrapID,
          lineTypeString: lastUsedLineType,
        );

        final int newLineMPID = _newLine!.mpID;
        final List<THElement> lineChildren = [];

        /// The initial lineChildren list is created "by hand" instead of using
        /// parent.addToParent so the line created by the MPAddLineCommand
        /// below already includes initial line segments. Otherwise, to include
        /// these line segments, it would be necessary to add an empty line to
        /// the file at before creating a strange undo/redo command that would
        /// deal with an empty line which makes no sense for the user.
        lineChildren.add(
          _createStraightLineSegment(_lineStartScreenPosition!, newLineMPID),
        );
        lineChildren.add(
          _createStraightLineSegment(endPointScreenCoordinates, newLineMPID),
        );
        lineChildren.add(THEndline(parentMPID: newLineMPID));

        final MPAddLineCommand command = MPAddLineCommand(
          newLine: _newLine!,
          lineChildren: lineChildren,
          lineStartScreenPosition: _lineStartScreenPosition,
        );

        _th2FileEditController.execute(command);
      }
    } else {
      final int lineMPID = getNewLine().mpID;
      final THStraightLineSegment newLineSegment = _createStraightLineSegment(
        endPointScreenCoordinates,
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
  void applyAddScrap({
    required THScrap newScrap,
    required List<Object> scrapChildren,
    int scrapPositionAtParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    /// The childrenMPIDs list of the scrap will be the one resultant of
    /// scrapChildren.
    newScrap.childrenMPIDs.clear();
    applyAddElement(
      newElement: newScrap,
      childPositionInParent: scrapPositionAtParent,
    );

    for (final Object child in scrapChildren) {
      if (child is THElement) {
        applyAddElement(
          newElement: child,
          childPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
      } else if (child is MPCommand) {
        child.execute(_th2FileEditController);
      } else {
        throw Exception(
          'At TH2FileEditElementEditController.applyAddScrap: invalid scrap child type: ${child.runtimeType}',
        );
      }
    }
  }

  void afterAddScrap(THScrap newScrap) {
    newScrap.clearBoundingBox();
    _th2FileEditController.setActiveScrap(newScrap.mpID);
    _th2FileEditController.updateHasMultipleScraps();
    afterAddElement(newScrap);
  }

  @action
  void applyAddLine({
    required THLine newLine,
    required List<THElement> lineChildren,
    int linePositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    Offset? lineStartScreenPosition,
  }) {
    /// The childrenMPIDs list of the line will be the one resultant of
    /// lineChildren.
    newLine.childrenMPIDs.clear();
    applyAddElement(
      newElement: newLine,
      childPositionInParent: linePositionInParent,
    );

    for (final THElement child in lineChildren) {
      if (child is THLineSegment) {
        applyAddLineSegment(
          newLineSegment: child,
          lineSegmentPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
      } else {
        applyAddElement(
          newElement: child,
          childPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
      }
    }

    newLine.clearBoundingBox();
    afterAddElement(newLine);
  }

  void afterAddElement(THElement newElement) {
    _th2FileEditController.setActiveScrapByChildElement(newElement);
    _th2FileEditController.selectionController.updateAfterAddElement(
      newElement,
    );
    _th2FileEditController.triggerAllElementsRedraw();
  }

  @action
  void applyAddArea({
    required THArea newArea,
    required List<THElement> areaChildren,
    int areaPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    /// The childrenMPIDs list of the area will be the one resultant of
    /// areaChildren.
    newArea.childrenMPIDs.clear();
    applyAddElement(
      newElement: newArea,
      childPositionInParent: areaPositionInParent,
    );
    for (final THElement child in areaChildren) {
      applyAddElement(
        newElement: child,
        childPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );
    }
  }

  @action
  void afterAddArea(THArea newArea) {
    newArea.clearBoundingBox();
    afterAddElement(newArea);
  }

  @action
  void applyRemoveArea(int areaMPID) {
    applyRemoveElementByMPID(areaMPID);
  }

  @action
  void applyRemoveLine(int lineMPID) {
    if ((_newLine != null) && (_newLine!.mpID == lineMPID)) {
      clearNewLine();
    }
    applyRemoveElementByMPID(lineMPID);
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
      final TH2FileEditSelectionController selectionController =
          _th2FileEditController.selectionController;

      selectionController.addSelectableElement(_newArea!);
    }

    clearNewArea();
    _th2FileEditController.triggerAllElementsRedraw();
    _th2FileEditController.updateUndoRedoStatus();
  }

  void updateOptionEdited({bool attrOptionEdited = true}) {
    final TH2FileEditOptionEditController optionEditController =
        _th2FileEditController.optionEditController;
    final TH2FileEditOverlayWindowController overlayWindowController =
        _th2FileEditController.overlayWindowController;

    optionEditController.clearCurrentOptionType();
    _th2FileEditController.selectionController.updateSelectedElementsClones();

    if (attrOptionEdited) {
      overlayWindowController.setShowOverlayWindow(
        MPWindowType.optionChoices,
        false,
      );
    }

    switch (optionEditController.currentOptionElementsType) {
      case MPOptionElementType.lineSegment:
        optionEditController.updateElementOptionMapForLineSegments();
      case MPOptionElementType.pla:
      case MPOptionElementType.scrap:
        optionEditController.updateOptionStateMap();
    }
  }

  @action
  void applySetOptionToElement({
    required THCommandOption option,
    String plaOriginalLineInTH2File = '',
  }) {
    option.optionParent(_thFile).addUpdateOption(option);

    if (option is THIDCommandOption) {
      _thFile.registerMPIDWithTHID(option.parentMPID, option.thID);
    }

    if (option.parentMPID >= 0) {
      final THElement parentElement = _thFile.elementByMPID(option.parentMPID);

      _thFile.substituteElement(
        parentElement.copyWith(originalLineInTH2File: plaOriginalLineInTH2File),
      );
    }

    updateOptionEdited(attrOptionEdited: false);
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
  void applySetAttrOptionToElement({
    required THAttrCommandOption attrOption,
    required String plaOriginalLineInTH2File,
  }) {
    final int parentMPID = attrOption.parentMPID;

    if (parentMPID <= 0) {
      throw Exception(
        'Error: parentMPID is not valid at TH2FileEditElementEditController.applySetAttrOptionToElement().',
      );
    }

    final THHasOptionsMixin parentElement = _thFile.hasOptionByMPID(parentMPID);

    MPEditElementAux.addOptionToElement(
      option: attrOption,
      element: parentElement,
    );

    final THElement newElement =
        parentElement.originalLineInTH2File == plaOriginalLineInTH2File
        ? parentElement
        : parentElement.copyWith(
            originalLineInTH2File: plaOriginalLineInTH2File,
          );

    _thFile.substituteElement(newElement);

    updateOptionEdited(attrOptionEdited: true);
  }

  @action
  void applyRemoveAttrOptionFromElement({
    required String attrName,
    required int parentMPID,
    required String plaOriginalLineInTH2File,
  }) {
    final THHasOptionsMixin parentElement = _th2FileEditController.thFile
        .hasOptionByMPID(parentMPID);

    parentElement.removeAttrOption(attrName);

    final THElement newElement =
        parentElement.originalLineInTH2File == plaOriginalLineInTH2File
        ? parentElement
        : parentElement.copyWith(
            originalLineInTH2File: plaOriginalLineInTH2File,
          );

    _thFile.substituteElement(newElement);
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
        final THLineSegment? previousLineSegment = line.getPreviousLineSegment(
          lineSegment,
          _thFile,
        );

        if (previousLineSegment == null) {
          throw Exception(
            'Error: previousLineSegment is null at TH2FileEditElementEditController.getRemoveLineSegmentCommand().',
          );
        }

        final THBezierCurveLineSegment deletedLineSegmentBezier =
            deletedLineSegmentIsStraight
            ? MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: previousLineSegment.endPoint.coordinates,
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

        return MPCommandFactory.removeLineSegmentWithSubstitution(
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

    final THLine line = _thFile.lineByMPID(
      selectedEndControlPoints.values.first.originalLineSegmentClone.parentMPID,
    );
    final MPCommand addLineSegmentsCommand = getAddLineSegmentsCommand(
      line: line,
      selectedEndControlPoints: selectedEndControlPoints.values,
    );

    _th2FileEditController.execute(addLineSegmentsCommand);
    _th2FileEditController.selectionController
        .updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerEditLineRedraw();
  }

  MPCommand getAddLineSegmentsCommand({
    required THLine line,
    required Iterable<MPSelectedEndControlPoint> selectedEndControlPoints,
  }) {
    final List<int> lineSegmentMPIDs = line.getLineSegmentMPIDs(_thFile);
    final SplayTreeMap<int, THLineSegment> selectedLineSegmentsPosMap =
        SplayTreeMap();
    final List<MPCommand> addLineSegmentsCommands = [];

    for (final MPSelectedEndControlPoint endControlPoint
        in selectedEndControlPoints) {
      final THLineSegment lineSegment =
          endControlPoint.originalLineSegmentClone;
      final int lineSegmentPos = lineSegmentMPIDs.indexOf(lineSegment.mpID);

      selectedLineSegmentsPosMap[lineSegmentPos] = lineSegment;
    }

    final Iterable<int> selectedLineSegmentsPos =
        selectedLineSegmentsPosMap.keys;

    int? previousLineSegmentPos;

    for (final int lineSegmentPos in selectedLineSegmentsPos) {
      if ((previousLineSegmentPos != null) &&
          (lineSegmentPos == previousLineSegmentPos + 1)) {
        final THLineSegment lineSegment =
            selectedLineSegmentsPosMap[lineSegmentPos]!;
        final int lineSegmentPositionInParent = line.getChildPosition(
          lineSegment,
        );
        final THLineSegment previousLineSegment =
            selectedLineSegmentsPosMap[previousLineSegmentPos]!;

        if (lineSegment is THStraightLineSegment) {
          final Offset newLineSegmentEndPoint =
              (previousLineSegment.endPoint.coordinates +
                  lineSegment.endPoint.coordinates) /
              2;
          final THStraightLineSegment newLineSegment = THStraightLineSegment(
            parentMPID: lineSegment.parentMPID,
            endPoint: THPositionPart(coordinates: newLineSegmentEndPoint),
          );

          addLineSegmentsCommands.add(
            MPAddLineSegmentCommand(
              newLineSegment: newLineSegment,
              lineSegmentPositionInParent: lineSegmentPositionInParent,
            ),
          );
        } else {
          final newLineSegments = MPNumericAux.splitBezierCurveAtPart(
            startPoint: previousLineSegment.endPoint.coordinates,
            lineSegment: lineSegment as THBezierCurveLineSegment,
            part: mpHalfBezierArcPart,
          );

          if (newLineSegments.length != 2) {
            throw Exception(
              'Error: newLineSegments.length != 2 at TH2FileEditElementEditController.applyAddLineSegmentsBetweenSelectedLineSegments(). Length: ${newLineSegments.length}',
            );
          }

          addLineSegmentsCommands.add(
            MPAddLineSegmentCommand(
              newLineSegment: newLineSegments[0],
              lineSegmentPositionInParent: lineSegmentPositionInParent,
            ),
          );
          addLineSegmentsCommands.add(
            MPEditLineSegmentCommand(
              originalLineSegment: lineSegment,
              newLineSegment: newLineSegments[1],
            ),
          );
        }
      }

      previousLineSegmentPos = lineSegmentPos;
    }

    final MPCommand addLineSegmentsCommand =
        (addLineSegmentsCommands.length == 1)
        ? addLineSegmentsCommands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: addLineSegmentsCommands.reversed.toList(),
            completionType:
                MPMultipleElementsCommandCompletionType.lineSegmentsAdded,
          );

    return addLineSegmentsCommand;
  }

  void addScrap() {
    final BuildContext? currentContext =
        _th2FileEditController.thFileWidgetKey.currentContext;

    if (currentContext == null) {
      return;
    }

    final String filename = MPEditElementAux.getFilenameFromPath(
      _thFile.filename,
    );
    final String normalizedFilename = MPEditElementAux.normalizeToTHID(
      filename,
    );
    final String thIDPrefix = '$normalizedFilename-scrap';
    final String initialScrapTHID = _thFile.getNewTHID(prefix: thIDPrefix);

    MPModalOverlayWidget.show(
      context: currentContext,
      childBuilder: (onPressedClose) => MPAddScrapDialogOverlayWindowWidget(
        initialScrapTHID: initialScrapTHID,
        onPressedClose: onPressedClose,
        th2FileEditController: _th2FileEditController,
      ),
    );
  }

  Future<void> addImage() async {
    final BuildContext? currentContext = _th2FileEditController
        .overlayWindowController
        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeImageButton]!
        .currentContext;

    if (currentContext == null) {
      return;
    }

    final PickImageFileReturn imageResult = await MPDialogAux.pickImageFile(
      currentContext,
    );

    if (imageResult.type == PickImageFileReturnType.empty) {
      return;
    }

    final MPCommand addImageCommand =
        MPCommandFactory.addXTherionInsertImageConfig(
          imageFilename: imageResult.filename!,
          th2FileEditController: _th2FileEditController,
        );

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

  @action
  void removeScrap(int scrapID) {
    final MPRemoveScrapCommand removeScrapCommand = MPRemoveScrapCommand(
      scrapMPID: scrapID,
    );

    _th2FileEditController.setActiveScrapForScrapRemoval(scrapID);
    _th2FileEditController.execute(removeScrapCommand);
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
    final THLine line = _thFile.lineByMPID(controlPointLineSegment.parentMPID);

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        final THLineSegment? originalPreviousLineSegment = line
            .getPreviousLineSegment(controlPointLineSegment, _thFile);

        if ((originalPreviousLineSegment != null) &&
            MPCommandOptionAux.isSmooth(originalPreviousLineSegment) &&
            !line.isFirstLineSegment(originalPreviousLineSegment, _thFile)) {
          final Offset junction =
              originalPreviousLineSegment.endPoint.coordinates;

          if (originalPreviousLineSegment is THStraightLineSegment) {
            final THLineSegment? originalSecondPreviousLineSegment = line
                .getPreviousLineSegment(originalPreviousLineSegment, _thFile);

            if (originalSecondPreviousLineSegment == null) {
              moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
                shouldSmooth: false,
                lineSegment: originalControlPointLineSegment,
                controlPointType: MPEndControlPointType.controlPoint1,
              );
            } else {
              final Offset segmentStart =
                  originalSecondPreviousLineSegment.endPoint.coordinates;
              final Offset segment = junction - segmentStart;

              moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
                shouldSmooth: true,
                isAdjacentStraight: true,
                lineSegment: originalControlPointLineSegment,
                controlPointType: MPEndControlPointType.controlPoint1,
                straightStart: segmentStart,
                junction: junction,
                straightLine: segment,
              );
            }
          } else if (originalPreviousLineSegment is THBezierCurveLineSegment) {
            final double currentLengthMirrorControlPoint =
                (originalPreviousLineSegment.controlPoint2.coordinates -
                        junction)
                    .distance;

            if (currentLengthMirrorControlPoint == 0) {
              moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
                shouldSmooth: false,
                lineSegment: originalControlPointLineSegment,
                controlPointType: MPEndControlPointType.controlPoint1,
              );
            } else {
              moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
                shouldSmooth: true,
                isAdjacentStraight: false,
                lineSegment: originalControlPointLineSegment,
                controlPointType: MPEndControlPointType.controlPoint1,
                adjacentLineSegment: originalPreviousLineSegment,
                adjacentControlPointLength: currentLengthMirrorControlPoint,
                junction: junction,
              );
            }
          }
        } else {
          moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
            shouldSmooth: false,
            lineSegment: originalControlPointLineSegment,
            controlPointType: MPEndControlPointType.controlPoint1,
          );
        }
      case MPEndControlPointType.controlPoint2:
        if (MPCommandOptionAux.isSmooth(controlPointLineSegment) &&
            !line.isLastLineSegment(controlPointLineSegment, _thFile)) {
          final THLineSegment? originalNextLineSegment = line
              .getNextLineSegment(controlPointLineSegment, _thFile);
          final Offset junction = controlPointLineSegment.endPoint.coordinates;

          if (originalNextLineSegment is THStraightLineSegment) {
            final Offset segmentStart =
                originalNextLineSegment.endPoint.coordinates;
            final Offset segment = junction - segmentStart;

            moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
              shouldSmooth: true,
              isAdjacentStraight: true,
              lineSegment: originalControlPointLineSegment,
              controlPointType: MPEndControlPointType.controlPoint2,
              straightStart: segmentStart,
              junction: junction,
              straightLine: segment,
            );
          } else if (originalNextLineSegment is THBezierCurveLineSegment) {
            final double currentLengthMirrorControlPoint =
                (originalNextLineSegment.controlPoint1.coordinates - junction)
                    .distance;

            if (currentLengthMirrorControlPoint == 0) {
              moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
                shouldSmooth: false,
                lineSegment: originalControlPointLineSegment,
                controlPointType: MPEndControlPointType.controlPoint2,
              );
            } else {
              moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
                shouldSmooth: true,
                isAdjacentStraight: false,
                lineSegment: originalControlPointLineSegment,
                controlPointType: MPEndControlPointType.controlPoint2,
                adjacentLineSegment: originalNextLineSegment,
                adjacentControlPointLength: currentLengthMirrorControlPoint,
                junction: junction,
              );
            }
          }
        } else {
          moveControlPointSmoothInfo = MPMoveControlPointSmoothInfo(
            shouldSmooth: false,
            lineSegment: originalControlPointLineSegment,
            controlPointType: MPEndControlPointType.controlPoint2,
          );
        }
      default:
    }
  }

  MPCommand? getSmoothLineSegmentsCommand(THLineSegment lineSegment) {
    final bool isLineSegmentBezier =
        lineSegment.elementType == THElementType.bezierCurveLineSegment;
    final THFile thFile = _th2FileEditController.thFile;
    final THLine line = thFile.lineByMPID(lineSegment.parentMPID);
    final THLineSegment? nextLineSegment = line.getNextLineSegment(
      lineSegment,
      thFile,
    );
    final bool isNextLineSegmentBezier =
        nextLineSegment?.elementType == THElementType.bezierCurveLineSegment;

    if ((isLineSegmentBezier || isNextLineSegmentBezier) &&
        (nextLineSegment != null) &&
        (!line.isFirstLineSegment(lineSegment, thFile))) {
      if (isLineSegmentBezier && isNextLineSegmentBezier) {
        final List<THBezierCurveLineSegment> smoothedBezierSegments =
            MPEditElementAux.getSmoothedBezierLineSegments(
              lineSegment: lineSegment as THBezierCurveLineSegment,
              nextLineSegment: nextLineSegment as THBezierCurveLineSegment,
              thFile: thFile,
            );

        if (smoothedBezierSegments.isNotEmpty) {
          final Map<int, THLineSegment> fromLineSegmentsMap = {
            lineSegment.mpID: lineSegment,
            nextLineSegment.mpID: nextLineSegment,
          };
          final Map<int, THLineSegment> smoothedSegmentsMap = {
            for (final segment in smoothedBezierSegments) segment.mpID: segment,
          };

          return MPMoveLineCommand(
            lineMPID: line.mpID,
            fromLineSegmentsMap: fromLineSegmentsMap,
            toLineSegmentsMap: smoothedSegmentsMap,
          );
        }
      } else {
        final THBezierCurveLineSegment unalignedBezierLineSegment;
        final THBezierCurveLineSegment alignedBezierLineSegment;

        if (isLineSegmentBezier) {
          unalignedBezierLineSegment = lineSegment as THBezierCurveLineSegment;

          final Offset? alignedControlPoint =
              MPEditElementAux.getControlPointAlignedToStraight(
                controlPoint: lineSegment.controlPoint2.coordinates,
                junction: lineSegment.endPoint.coordinates,
                startStraightLineSegment: nextLineSegment.endPoint.coordinates,
                thFile: thFile,
              );

          if (alignedControlPoint == null) {
            return null;
          }
          alignedBezierLineSegment = lineSegment.copyWith(
            controlPoint2: THPositionPart(coordinates: alignedControlPoint),
            originalLineInTH2File: '',
          );
        } else {
          final THLineSegment? previousLineSegment = line
              .getPreviousLineSegment(lineSegment, thFile);

          if (previousLineSegment == null) {
            return null;
          }

          unalignedBezierLineSegment =
              nextLineSegment as THBezierCurveLineSegment;

          final Offset? alignedControlPoint =
              MPEditElementAux.getControlPointAlignedToStraight(
                controlPoint: nextLineSegment.controlPoint1.coordinates,
                junction: lineSegment.endPoint.coordinates,
                startStraightLineSegment:
                    previousLineSegment.endPoint.coordinates,
                thFile: thFile,
              );

          if (alignedControlPoint == null) {
            return null;
          }
          alignedBezierLineSegment = nextLineSegment.copyWith(
            controlPoint1: THPositionPart(coordinates: alignedControlPoint),
            originalLineInTH2File: '',
          );
        }

        return MPMoveBezierLineSegmentCommand.fromLineSegments(
          fromLineSegment: unalignedBezierLineSegment,
          toLineSegment: alignedBezierLineSegment,
        );
      }
    }

    return null;
  }

  @action
  void toggleSelectedLinesReverseOption() {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;
    final List<MPCommand> toggleCommands = [];

    for (final MPSelectedElement selectedElement
        in selectionController.mpSelectedElementsLogical.values) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }
      final THLine originalLine =
          selectedElement.originalElementClone as THLine;
      final THReverseCommandOption? reverseOption =
          MPCommandOptionAux.isReverse(originalLine)
          ? null
          : THReverseCommandOption(
              parentMPID: originalLine.mpID,
              choice: THOptionChoicesOnOffType.on,
            );
      final MPCommand toggleCommand = (reverseOption == null)
          ? MPRemoveOptionFromElementCommand(
              optionType: THCommandOptionType.reverse,
              parentMPID: originalLine.mpID,
              descriptionType: MPCommandDescriptionType.toggleReverseOption,
            )
          : MPSetOptionToElementCommand(
              option: reverseOption,
              descriptionType: MPCommandDescriptionType.toggleReverseOption,
            );

      toggleCommands.add(toggleCommand);
    }

    if (toggleCommands.isEmpty) {
      return;
    }

    final MPCommand toggleAllCommand = (toggleCommands.length == 1)
        ? toggleCommands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: toggleCommands,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: MPCommandDescriptionType.toggleReverseOption,
          );

    _th2FileEditController.execute(toggleAllCommand);
    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  @action
  void simplifySelectedLines() {
    final List<MPCommand> simplifyCommands = [];

    int lineCount = 0;

    updateStraightLineSimplificationTolerance();
    updateOriginalSimplifiedLines();

    for (final MPSelectedElement selectedElement in _originalSimplifiedLines!) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }

      lineCount++;

      final THLine originalLine =
          selectedElement.originalElementClone as THLine;
      final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
          originalLine.getLineSegmentsMap(_thFile);
      final MPLineTypePerLineSegmentType lineTypePerLineSegmentType =
          getLineTypePerLineSegmentType(originalLine);

      switch (lineTypePerLineSegmentType) {
        case MPLineTypePerLineSegmentType.bezierCurve:
          if (_lineSimplificationMethod ==
              MPLineSimplificationMethod.forceStraight) {
            /// TODO convert Bèzier curve to straight and them simplify
          } else {
            final List<THLineSegment> originalLineSegmentsList =
                originalLineSegmentsMap.values.toList();
            final List<THLineSegment> simplifiedLineSegmentsList =
                mpSimplifyTHBezierCurveLineSegmentsToTHBezierCurveLineSegments(
                  originalLineSegmentsList,
                );

            print(
              'Original line segments count: ${originalLineSegmentsList.length}, simplified line segments count: ${simplifiedLineSegmentsList.length}',
            );

            if (simplifiedLineSegmentsList.length ==
                originalLineSegmentsList.length) {
              // No simplification was possible.
              continue;
            }

            final List<({THLineSegment lineSegment, int lineSegmentPosition})>
            originalLineSegments = originalLine.getLineSegmentsPositionList(
              _thFile,
            );
            final List<({THLineSegment lineSegment, int lineSegmentPosition})>
            newLineSegments =
                convertTHLineSegmentListToLineSegmentWithPositionList(
                  simplifiedLineSegmentsList,
                );
            final MPCommand simplifyCommand = MPReplaceLineSegmentsCommand(
              lineMPID: originalLine.mpID,
              originalLineSegments: originalLineSegments,
              newLineSegments: newLineSegments,
            );

            simplifyCommands.add(simplifyCommand);
          }
        case MPLineTypePerLineSegmentType.mixed:

          /// TODO separate each line in it's per type parts and them treat each
          /// part as a separate line.
          break;
        case MPLineTypePerLineSegmentType.straight:
          if (_lineSimplificationMethod ==
              MPLineSimplificationMethod.forceBezier) {
            final List<THLineSegment> originalLineSegmentsList =
                originalLineSegmentsMap.values.toList();
            final List<THLineSegment> bezierLineSegments =
                convertTHStraightLinesToTHBezierCurveLineSegments(
                  originalStraightLineSegmentsList: originalLineSegmentsList,
                );
            final List<({THLineSegment lineSegment, int lineSegmentPosition})>
            newLineSegments =
                convertTHLineSegmentListToLineSegmentWithPositionList(
                  bezierLineSegments,
                );
            final List<({THLineSegment lineSegment, int lineSegmentPosition})>
            originalLineSegments = originalLine.getLineSegmentsPositionList(
              _thFile,
            );
            final MPCommand simplifyCommand = MPReplaceLineSegmentsCommand(
              lineMPID: originalLine.mpID,
              originalLineSegments: originalLineSegments,
              newLineSegments: newLineSegments,
            );

            simplifyCommands.add(simplifyCommand);
          } else {
            final List<THLineSegment> originalLineSegmentsList =
                originalLineSegmentsMap.values.toList();
            final List<THLineSegment> removedLineSegments =
                MPLineSimplificationAux.raumerDouglasPeuckerIterative(
                  originalStraightLineSegments: originalLineSegmentsList,
                  epsilon: _straightLineSimplifyEpsilonOnCanvas,
                );

            print(
              'Original line segments count: ${originalLineSegmentsList.length}, simplified line segments count: ${removedLineSegments.length}',
            );

            if (removedLineSegments.isEmpty) {
              /// No simplification found.
              return;
            }

            for (final THLineSegment removedLineSegment
                in removedLineSegments) {
              final MPCommand removeLineSegmentCommand =
                  MPRemoveLineSegmentCommand(
                    lineSegment: removedLineSegment,
                    descriptionType: MPCommandDescriptionType.simplifyLine,
                  );

              simplifyCommands.add(removeLineSegmentCommand);
            }
          }
      }
    }

    if (simplifyCommands.isEmpty) {
      return;
    } else {
      final MPCommand simplifyCommand = (simplifyCommands.length == 1)
          ? simplifyCommands.first
          : MPMultipleElementsCommand.forCWJM(
              commandsList: simplifyCommands,
              completionType:
                  MPMultipleElementsCommandCompletionType.lineSegmentsRemoved,
              descriptionType: lineCount == 1
                  ? MPCommandDescriptionType.simplifyLine
                  : MPCommandDescriptionType.simplifyLines,
            );

      _th2FileEditController.execute(simplifyCommand);
      _th2FileEditController.selectionController
          .updateSelectableEndAndControlPoints();
      _th2FileEditController.triggerSelectedElementsRedraw();
      _th2FileEditController.triggerEditLineRedraw();
    }
  }

  MPLineTypePerLineSegmentType getLineTypePerLineSegmentType(THLine line) {
    final List<THLineSegment> lineSegments = line.getLineSegments(_thFile);

    if (lineSegments.length < 2) {
      throw Exception(
        'Error: line has less than 2 line segments at TH2FileEditElementEditController.getLineTypePerLineSegmentType(). Length: ${lineSegments.length}',
      );
    }

    bool hasBezierCurve = false;
    bool hasStraight = false;

    /// Skipping the first line segment because the first one only provides the
    /// starting point of the line. It doesn't matter if it's straight or
    /// bezier curve.
    for (final THLineSegment lineSegment in lineSegments.skip(1)) {
      if (lineSegment is THBezierCurveLineSegment) {
        hasBezierCurve = true;
      } else if (lineSegment is THStraightLineSegment) {
        hasStraight = true;
      }
    }

    if (hasBezierCurve && hasStraight) {
      return MPLineTypePerLineSegmentType.mixed;
    } else if (hasBezierCurve) {
      return MPLineTypePerLineSegmentType.bezierCurve;
    } else if (hasStraight) {
      return MPLineTypePerLineSegmentType.straight;
    } else {
      throw Exception(
        'Error: line has no line segments at TH2FileEditElementEditController.getLineTypePerLineSegmentType().',
      );
    }
  }

  void setOriginalSimplifiedLines(List<MPSelectedLine>? lines) {
    _originalSimplifiedLines = lines;
  }

  void updateStraightLineSimplificationTolerance() {
    final double straightLineSimplifyEpsilonOnCanvasIncrease =
        mpStraightLineSimplifyEpsilonOnScreen /
        _th2FileEditController.canvasScale;

    if (_originalSimplifiedLines == null) {
      _straightLineSimplifyEpsilonOnCanvas =
          straightLineSimplifyEpsilonOnCanvasIncrease;
    } else {
      _straightLineSimplifyEpsilonOnCanvas +=
          straightLineSimplifyEpsilonOnCanvasIncrease;
    }
  }

  void updateOriginalSimplifiedLines() {
    if (_originalSimplifiedLines != null) {
      return;
    }

    final List<MPSelectedLine> simplifiedLines = [];
    final Iterable<MPSelectedElement> mpSelectedElements =
        _th2FileEditController
            .selectionController
            .mpSelectedElementsLogical
            .values;

    for (final MPSelectedElement selectedElement in mpSelectedElements) {
      if (selectedElement is! MPSelectedLine) {
        continue;
      }

      simplifiedLines.add(selectedElement);
    }

    _originalSimplifiedLines = simplifiedLines;
  }

  void setLineSimplificationMethod(MPLineSimplificationMethod newMethod) {
    if (_lineSimplificationMethod == newMethod) {
      return;
    }

    _lineSimplificationMethod = newMethod;
    setOriginalSimplifiedLines(null);
  }

  List<({THLineSegment lineSegment, int lineSegmentPosition})>
  convertTHLineSegmentListToLineSegmentWithPositionList(
    List<THLineSegment> lineSegmentsList,
  ) {
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    lineSegmentsWithPosition = lineSegmentsList
        .map<({THLineSegment lineSegment, int lineSegmentPosition})>(
          (s) => (
            lineSegment: s,
            lineSegmentPosition: mpAddChildAtEndMinusOneOfParentChildrenList,
          ),
        )
        .toList();

    return lineSegmentsWithPosition;
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

enum MPLineTypePerLineSegmentType { bezierCurve, mixed, straight }

enum MPLineSimplificationMethod {
  forceStraight,
  forceBezier,
  keepOriginalTypes,
}
