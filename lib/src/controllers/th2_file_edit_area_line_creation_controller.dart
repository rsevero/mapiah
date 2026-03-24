// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_new_line_creation_method.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_area_line_creation_controller.g.dart';

class TH2FileEditAreaLineCreationController = TH2FileEditAreaLineCreationControllerBase
    with _$TH2FileEditAreaLineCreationController;

abstract class TH2FileEditAreaLineCreationControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditAreaLineCreationControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  @readonly
  Offset? _lineStartScreenPosition;

  @readonly
  THLine? _newLine;

  Offset? _newLinePendingControlPoint1CanvasCoordinates;

  Offset? get newLinePendingControlPoint1CanvasCoordinates =>
      _newLinePendingControlPoint1CanvasCoordinates;

  bool _isNewLineDragging = false;

  bool get isNewLineDragging => _isNewLineDragging;

  @readonly
  THArea? _newArea;

  int _missingStepsPreserveStraightToBezierConversionUndoRedo = 2;

  @action
  THLine getNewLine() {
    if (_newLine == null) {
      throw Exception(
        'At TH2FileEditAreaLineCreationController.getNewLine(): new line has not been created',
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
  void createMapConnectionLines() {
    final ObservableMap<int, MPSelectedElement> selectedElements =
        _th2FileEditController.selectionController.mpSelectedElementsLogical;

    if (selectedElements.isEmpty) {
      return;
    }

    Map<String, THPoint>? stationPointsByStationName;

    final Map<THPoint, MPStationPointNameRecord> sectionPointsToConnect = {};

    for (final MPSelectedElement mpSelectedElement in selectedElements.values) {
      final THElement selectedElement = mpSelectedElement.originalElementClone;

      if ((selectedElement is! THPoint) ||
          (selectedElement.pointType != THPointType.section)) {
        continue;
      }

      stationPointsByStationName ??=
          MPCommandOptionAux.getStationPointsByStationName(
            _th2FileEditController,
          );

      final String? stationName =
          MPCommandOptionAux.getStationNameFromScrapOption(selectedElement);

      if ((stationName != null) &&
          (stationName.isNotEmpty) &&
          stationPointsByStationName.containsKey(stationName)) {
        sectionPointsToConnect[selectedElement] = MPStationPointNameRecord(
          stationName: stationName,
          stationPoint: stationPointsByStationName[stationName]!,
        );
      }
    }

    if (sectionPointsToConnect.isEmpty) {
      return;
    }

    final List<MPCommand> addLineCommands = [];

    for (final sectionPointToConnect in sectionPointsToConnect.entries) {
      final THPoint sectionPoint = sectionPointToConnect.key;
      final MPStationPointNameRecord stationPointNameRecord =
          sectionPointToConnect.value;
      final ({Offset end, Offset start}) coordinates =
          MPNumericAux.getConnectionLineCoordinates(
            from: sectionPoint.position.coordinates,
            to: stationPointNameRecord.stationPoint.position.coordinates,
          );
      final String lineTypeString = THLineType.mapConnection.name;
      final THLine line = THLine.fromString(
        parentMPID: _th2FileEditController.activeScrapID,
        lineTypeString: lineTypeString,
      );
      final String prefix =
          "$mpAutomaticMapConnectionPrefix${stationPointNameRecord.stationName}-";
      final String mapConnectionTHID = _th2File.getNewTHID(
        element: line,
        prefix: prefix,
      );
      final MPCommand addLineTHIDCommand = MPCommandFactory.addTHIDToElement(
        element: line,
        th2File: _th2File,
        newTHID: mapConnectionTHID,
      );
      final MPAddLineCommand addLinecommand =
          MPCommandFactory.addLineFromStartEnd(
            line: line,
            start: coordinates.start,
            end: coordinates.end,
            type: lineTypeString,
            subtype: '',
            posCommands: [addLineTHIDCommand],
            th2FileEditController: _th2FileEditController,
          );

      addLineCommands.add(addLinecommand);
    }

    if (addLineCommands.isEmpty) {
      return;
    }

    final MPCommand addLinesCommand = MPCommandFactory.multipleCommandsFromList(
      commandsList: addLineCommands,
      descriptionType: MPCommandDescriptionType.addLines,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
    );

    _th2FileEditController.execute(addLinesCommand);
  }

  @action
  void setNewLineStartScreenPosition(Offset lineStartScreenPosition) {
    _lineStartScreenPosition = lineStartScreenPosition;
  }

  @action
  void clearNewLine() {
    _newLine = null;
    _lineStartScreenPosition = null;
    _newLinePendingControlPoint1CanvasCoordinates = null;
    _isNewLineDragging = false;
  }

  @action
  void endNewLineDrag() {
    _isNewLineDragging = false;
    _th2FileEditController.triggerNewLineRedraw();
  }

  @action
  void clearNewArea() {
    _newArea = null;
  }

  THArea _createNewArea() {
    final ({String subtype, String type}) typeSubtype =
        MPCommandOptionAux.getPLATypeSubtypeRecord(
          _th2FileEditController.elementEditController.lastUsedAreaType,
        );
    final THArea newArea = THArea.fromString(
      parentMPID: _th2FileEditController.activeScrapID,
      areaTypeString: typeSubtype.type,
    );
    final THEndarea endarea = THEndarea(parentMPID: newArea.mpID);

    executeAddArea(newArea: newArea, areaChildren: [endarea]);

    _th2FileEditController.elementEditController.setUsedAreaType(
      areaType: typeSubtype.type,
      areaSubtype: typeSubtype.subtype,
    );

    return newArea;
  }

  @action
  void updateBezierLineSegment(Offset mousePositionScreenCoordinates) {
    _isNewLineDragging = true;
    switch (_getNewLineCreationMethod()) {
      case MPNewLineCreationMethod.mapiahQuadratic:
        _newLinePendingControlPoint1CanvasCoordinates = null;
        _updateBezierLineSegmentMapiahQuadratic(mousePositionScreenCoordinates);
      case MPNewLineCreationMethod.xTherionCubicSmooth:
        _updateBezierLineSegmentXTherionCubicSmooth(
          mousePositionScreenCoordinates,
        );
    }
  }

  void _updateBezierLineSegmentMapiahQuadratic(
    Offset quadraticControlPointPositionScreenCoordinates,
  ) {
    if ((_newLine == null) || (_newLine!.childrenMPIDs.length < 2)) {
      return;
    }

    final List<int> lineSegmentMPIDs = _newLine!.getLineSegmentMPIDs(_th2File);
    final THLineSegment lastLineSegment = _th2File.lineSegmentByMPID(
      lineSegmentMPIDs.last,
    );
    final THLineSegment secondToLastLineSegment = _th2File.lineSegmentByMPID(
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

    _replaceNewLineLastSegmentWithBezier(
      lastLineSegment: lastLineSegment,
      controlPoint1Coordinates: controlPoint1,
      controlPoint2Coordinates: controlPoint2,
    );

    _th2FileEditController.triggerNewLineRedraw();
  }

  void _updateBezierLineSegmentXTherionCubicSmooth(
    Offset nextLineSegmentControlPoint1ScreenCoordinates,
  ) {
    if ((_newLine == null) || (_newLine!.childrenMPIDs.length < 2)) {
      return;
    }

    final List<int> lineSegmentMPIDs = _newLine!.getLineSegmentMPIDs(_th2File);
    final THLineSegment lastLineSegment = _th2File.lineSegmentByMPID(
      lineSegmentMPIDs.last,
    );
    final THLineSegment secondToLastLineSegment = _th2File.lineSegmentByMPID(
      lineSegmentMPIDs.elementAt(lineSegmentMPIDs.length - 2),
    );
    final THPositionPart startPoint = secondToLastLineSegment.endPoint;
    final THPositionPart endPoint = lastLineSegment.endPoint;
    final Offset startPointCoordinates = startPoint.coordinates;
    final Offset endPointCoordinates = endPoint.coordinates;
    final Offset nextLineSegmentControlPoint1CanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(
          nextLineSegmentControlPoint1ScreenCoordinates,
        );
    final Offset mirroredDirectionControlPoint2 =
        (endPointCoordinates * 2) -
        nextLineSegmentControlPoint1CanvasCoordinates;
    Offset controlPoint2Coordinates = mirroredDirectionControlPoint2;

    if (MPInteractionAux.isCtrlPressed() &&
        (lastLineSegment is THBezierCurveLineSegment)) {
      final Offset previousControlPoint2Coordinates =
          lastLineSegment.controlPoint2.coordinates;
      final Offset previousControlPoint2Vector =
          previousControlPoint2Coordinates - endPointCoordinates;
      final double previousControlPoint2Distance =
          previousControlPoint2Vector.distance;
      final Offset mirroredDirectionVector =
          mirroredDirectionControlPoint2 - endPointCoordinates;
      final double mirroredDirectionDistance = mirroredDirectionVector.distance;

      if ((previousControlPoint2Distance > 0) &&
          (mirroredDirectionDistance > 0)) {
        final Offset mirroredUnitDirection = Offset(
          mirroredDirectionVector.dx / mirroredDirectionDistance,
          mirroredDirectionVector.dy / mirroredDirectionDistance,
        );

        controlPoint2Coordinates =
            endPointCoordinates +
            (mirroredUnitDirection * previousControlPoint2Distance);
      }
    }

    final Offset controlPoint1Coordinates =
        _getXTherionCurrentSegmentControlPoint1Coordinates(
          lastLineSegment: lastLineSegment,
          startPointCoordinates: startPointCoordinates,
          endPointCoordinates: endPointCoordinates,
        );

    _newLinePendingControlPoint1CanvasCoordinates =
        nextLineSegmentControlPoint1CanvasCoordinates;

    _replaceNewLineLastSegmentWithBezier(
      lastLineSegment: lastLineSegment,
      controlPoint1Coordinates: controlPoint1Coordinates,
      controlPoint2Coordinates: controlPoint2Coordinates,
    );

    _th2FileEditController.triggerNewLineRedraw();
  }

  Offset _getXTherionCurrentSegmentControlPoint1Coordinates({
    required THLineSegment lastLineSegment,
    required Offset startPointCoordinates,
    required Offset endPointCoordinates,
  }) {
    if (lastLineSegment is THBezierCurveLineSegment) {
      return lastLineSegment.controlPoint1.coordinates;
    }

    final Offset oneThirdChord =
        (endPointCoordinates - startPointCoordinates) / 3;

    return startPointCoordinates + oneThirdChord;
  }

  void _replaceNewLineLastSegmentWithBezier({
    required THLineSegment lastLineSegment,
    required Offset controlPoint1Coordinates,
    required Offset controlPoint2Coordinates,
  }) {
    final THPositionPart endPoint = lastLineSegment.endPoint;

    if (lastLineSegment is THStraightLineSegment) {
      final THBezierCurveLineSegment
      bezierCurveLineSegment = THBezierCurveLineSegment.forCWJM(
        mpID: lastLineSegment.mpID,
        parentMPID: _newLine!.mpID,
        endPoint: endPoint,
        controlPoint1: THPositionPart(coordinates: controlPoint1Coordinates),
        controlPoint2: THPositionPart(coordinates: controlPoint2Coordinates),
        optionsMap: lastLineSegment.optionsMap,
        attrOptionsMap: lastLineSegment.attrOptionsMap,
        originalLineInTH2File: '',
        sameLineComment: lastLineSegment.sameLineComment,
      );

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
              coordinates: controlPoint1Coordinates,
            ),
            controlPoint2: THPositionPart(
              coordinates: controlPoint2Coordinates,
            ),
            originalLineInTH2File: '',
          );
      final MPEditLineSegmentCommand command = MPEditLineSegmentCommand(
        originalLineSegment: lastLineSegment,
        newLineSegment: bezierCurveLineSegment,
      );

      if (_missingStepsPreserveStraightToBezierConversionUndoRedo == 0) {
        _th2FileEditController.executeSubstitutingLastUndo(command);
      } else {
        _th2FileEditController.execute(command);
        _missingStepsPreserveStraightToBezierConversionUndoRedo--;
      }
    }
  }

  @action
  void addNewLineLineSegment(Offset endPointScreenCoordinates) {
    if (_newLine == null) {
      if (_lineStartScreenPosition == null) {
        _lineStartScreenPosition = endPointScreenCoordinates;
      } else {
        final ({String subtype, String type}) typeSubtype =
            MPCommandOptionAux.getPLATypeSubtypeRecord(
              _th2FileEditController.elementEditController.lastUsedLineType,
            );

        _newLine = THLine.fromString(
          parentMPID: _th2FileEditController.activeScrapID,
          lineTypeString: typeSubtype.type,
        );

        final int newLineMPID = _newLine!.mpID;
        final List<THElement> lineChildren = [];

        /// The initial lineChildren list is created "by hand" instead of using
        /// parent.addToParent so the line created by the MPAddLineCommand
        /// below already includes initial line segments. Otherwise, to include
        /// these line segments, it would be necessary to add an empty line to
        /// the file before creating a strange undo/redo command that would deal
        /// with an empty line which makes no sense for the user.
        lineChildren.add(
          MPEditElementAux.createStraightLineSegmentFromScreenCoordinates(
            endPointScreenCoordinates: _lineStartScreenPosition!,
            lineMPID: newLineMPID,
            th2FileEditController: _th2FileEditController,
          ),
        );
        lineChildren.add(
          MPEditElementAux.createStraightLineSegmentFromScreenCoordinates(
            endPointScreenCoordinates: endPointScreenCoordinates,
            lineMPID: newLineMPID,
            th2FileEditController: _th2FileEditController,
          ),
        );
        lineChildren.add(THEndline(parentMPID: newLineMPID));

        final List<MPCommand> posCommands = [];

        if (typeSubtype.subtype.isNotEmpty) {
          final THCommandOption lineSubtypeOption = THSubtypeCommandOption(
            parentMPID: _newLine!.mpID,
            subtype: typeSubtype.subtype,
          );

          posCommands.add(
            MPCommandFactory.setOptionOnElements(
              elements: [_newLine!],
              th2File: _th2File,
              toOption: lineSubtypeOption,
            ),
          );
        }

        final List<THCommandOption> defaultOptions = _th2FileEditController
            .defaultOptionsController
            .getApplicableDefaults(
              elementType: THElementType.line,
              typeString: typeSubtype.type,
            );

        for (final THCommandOption defaultOption in defaultOptions) {
          if (defaultOption.type == THCommandOptionType.subtype) {
            continue;
          }
          posCommands.add(
            MPCommandFactory.setOptionOnElements(
              elements: [_newLine!],
              th2File: _th2File,
              toOption: defaultOption.copyWith(
                parentMPID: _newLine!.mpID,
                originalLineInTH2File: '',
              ),
            ),
          );
        }

        final MPCommand? posCommand = posCommands.isEmpty
            ? null
            : MPCommandFactory.multipleCommandsFromList(
                commandsList: posCommands,
                descriptionType: MPCommandDescriptionType.addLine,
                completionType:
                    MPMultipleElementsCommandCompletionType.elementsListChanged,
              );

        final MPAddLineCommand addLineCommand = MPAddLineCommand(
          newLine: _newLine!,
          lineChildren: lineChildren,
          lineStartScreenPosition: _lineStartScreenPosition,
          preCommand: null,
          posCommand: posCommand,
        );

        _th2FileEditController.elementEditController.setUsedLineType(
          lineType: typeSubtype.type,
          lineSubtype: typeSubtype.subtype,
        );

        _th2FileEditController.execute(addLineCommand);
      }
    } else {
      final int lineMPID = getNewLine().mpID;
      final THLineSegment newLineSegment =
          _createNewLineSegmentFromScreenCoordinates(
            endPointScreenCoordinates: endPointScreenCoordinates,
            lineMPID: lineMPID,
          );
      final MPAddLineSegmentCommand command = MPAddLineSegmentCommand(
        newLineSegment: newLineSegment,
        posCommand: null,
      );

      _th2FileEditController.execute(command);
    }

    _th2FileEditController.triggerNewLineRedraw();
  }

  THLineSegment _createNewLineSegmentFromScreenCoordinates({
    required Offset endPointScreenCoordinates,
    required int lineMPID,
  }) {
    final THStraightLineSegment straightLineSegment =
        MPEditElementAux.createStraightLineSegmentFromScreenCoordinates(
          endPointScreenCoordinates: endPointScreenCoordinates,
          lineMPID: lineMPID,
          th2FileEditController: _th2FileEditController,
        );

    if ((_getNewLineCreationMethod() !=
            MPNewLineCreationMethod.xTherionCubicSmooth) ||
        (_newLinePendingControlPoint1CanvasCoordinates == null)) {
      return straightLineSegment;
    }

    final THBezierCurveLineSegment bezierCurveLineSegment =
        THBezierCurveLineSegment(
          parentMPID: lineMPID,
          controlPoint1: THPositionPart(
            coordinates: _newLinePendingControlPoint1CanvasCoordinates!,
            decimalPositions: _th2FileEditController.currentDecimalPositions,
          ),
          controlPoint2: straightLineSegment.endPoint.copyWith(),
          endPoint: straightLineSegment.endPoint.copyWith(),
        );

    _missingStepsPreserveStraightToBezierConversionUndoRedo = 1;
    _newLinePendingControlPoint1CanvasCoordinates = null;

    return bezierCurveLineSegment;
  }

  MPNewLineCreationMethod _getNewLineCreationMethod() {
    final Enum settingValue = mpLocator.mpSettingsController.getEnumWithDefault(
      MPSettingID.TH2Edit_NewLineCreationMethod,
    );

    return settingValue as MPNewLineCreationMethod;
  }

  @action
  void executeAddLine({
    required THLine newLine,
    required List<THElement> lineChildren,
    int linePositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
    Offset? lineStartScreenPosition,
  }) {
    /// The childrenMPIDs list of the line will be the one resultant of
    /// lineChildren.
    newLine.childrenMPIDs.clear();
    _th2FileEditController.elementEditController.executeAddElement(
      newElement: newLine,
      childPositionInParent: linePositionInParent,
    );

    for (final THElement child in lineChildren) {
      if (child is THLineSegment) {
        _th2FileEditController.elementEditController.executeAddLineSegment(
          newLineSegment: child,
          lineSegmentPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
      } else {
        _th2FileEditController.elementEditController.executeAddElement(
          newElement: child,
          childPositionInParent: mpAddChildAtEndOfParentChildrenList,
        );
      }
    }

    newLine.clearBoundingBox();
    _th2FileEditController.elementEditController.afterAddElement(newLine);
  }

  @action
  void executeAddArea({
    required THArea newArea,
    required List<THElement> areaChildren,
    int areaPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    /// The childrenMPIDs list of the area will be the one resultant of
    /// areaChildren.
    newArea.childrenMPIDs.clear();
    _th2FileEditController.elementEditController.executeAddElement(
      newElement: newArea,
      childPositionInParent: areaPositionInParent,
    );
    for (final THElement child in areaChildren) {
      _th2FileEditController.elementEditController.executeAddElement(
        newElement: child,
        childPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );
    }
  }

  @action
  void afterAddArea(THArea newArea) {
    newArea.clearBoundingBox();
    _th2FileEditController.elementEditController.afterAddElement(newArea);
  }

  @action
  void applyRemoveArea(int areaMPID) {
    _th2FileEditController.elementEditController.executeRemoveElementByMPID(
      areaMPID,
    );
  }

  @action
  void executeRemoveLine(int lineMPID) {
    if ((_newLine != null) && (_newLine!.mpID == lineMPID)) {
      clearNewLine();
    }
    _th2FileEditController.elementEditController.executeRemoveElementByMPID(
      lineMPID,
    );
  }

  @action
  void finalizeNewLineCreation() {
    if (_newLine != null) {
      _th2FileEditController.elementEditController.addOutdatedCloneMPID(
        _newLine!.mpID,
      );
    }

    clearNewLine();
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditPartial();
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditFinal();

    _th2FileEditController.updateUndoRedoStatus();
  }

  @action
  void finalizeNewAreaCreation() {
    if (_newArea != null) {
      _th2FileEditController.elementEditController.addOutdatedCloneMPID(
        _newArea!.mpID,
      );
    }

    clearNewArea();
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditPartial();
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditFinal();
    _th2FileEditController.triggerAllElementsRedraw();
    _th2FileEditController.updateUndoRedoStatus();
  }
}

class MPStationPointNameRecord {
  final String stationName;
  final THPoint stationPoint;

  MPStationPointNameRecord({
    required this.stationName,
    required this.stationPoint,
  });
}
