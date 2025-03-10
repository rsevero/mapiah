import 'dart:collection';

import 'package:flutter/animation.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
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

  @readonly
  THPointType _lastAddedPointType = thDefaultPointType;

  @readonly
  THLineType _lastAddedLineType = thDefaultLineType;

  @readonly
  THAreaType _lastAddedAreaType = thDefaultAreaType;

  @readonly
  Offset? _lineStartScreenPosition;

  @readonly
  THLine? _newLine;

  int _missingStepsPreserveStraightToBezierConversionUndoRedo = 2;

  List<THLineSegment> getLineSegmentsList({
    required THLine line,
    required bool clone,
  }) {
    final List<THLineSegment> lineSegments = <THLineSegment>[];
    final Set<int> lineSegmentMapiahIDs = line.childrenMapiahID;

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          _thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is THLineSegment) {
        lineSegments.add(clone ? lineSegment.copyWith() : lineSegment);
      }
    }

    return lineSegments;
  }

  LinkedHashMap<int, THLineSegment> getLineSegmentsMap(THLine line) {
    final LinkedHashMap<int, THLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final Set<int> lineSegmentMapiahIDs = line.childrenMapiahID;

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          _thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is THLineSegment) {
        lineSegmentsMap[lineSegment.mapiahID] = lineSegment;
      }
    }

    return lineSegmentsMap;
  }

  void substituteElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    _th2FileEditController.selectionController
        .addSelectableElement(modifiedElement);
    mpLocator.mpLog.finer('Substituted element ${modifiedElement.mapiahID}');
  }

  void substituteElements(List<THElement> modifiedElements) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    for (final THElement modifiedElement in modifiedElements) {
      _thFile.substituteElement(modifiedElement);
      selectionController.addSelectableElement(modifiedElement);
      mpLocator.mpLog
          .finer('Substituted element ${modifiedElement.mapiahID} from list');
    }
  }

  void substituteElementWithoutAddSelectableElement(THElement modifiedElement) {
    _thFile.substituteElement(modifiedElement);
    mpLocator.mpLog.finer(
        'Substituted element without add selectable element ${modifiedElement.mapiahID}');
  }

  void substituteLineSegments(
    LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
  ) {
    for (final THLineSegment lineSegment in modifiedLineSegmentsMap.values) {
      _thFile.substituteElement(lineSegment);
    }

    final THLine line = _thFile.elementByMapiahID(
        modifiedLineSegmentsMap.values.first.parentMapiahID) as THLine;
    line.clearBoundingBox();
  }

  @action
  void addElement({required THElement newElement}) {
    _thFile.addElement(newElement);

    final int parentMapiahID = newElement.parentMapiahID;

    if (parentMapiahID < 0) {
      _thFile.addElementToParent(newElement);
    } else {
      final THIsParentMixin parent =
          _thFile.elementByMapiahID(parentMapiahID) as THIsParentMixin;

      parent.addElementToParent(newElement);
    }

    _th2FileEditController.selectionController.addSelectableElement(newElement);
  }

  void addElementWithParentMapiahIDWithoutSelectableElement({
    required THElement newElement,
    required int parentMapiahID,
  }) {
    addElementWithParentWithoutSelectableElement(
      newElement: newElement,
      parent: _thFile.elementByMapiahID(parentMapiahID) as THIsParentMixin,
    );
  }

  @action
  void addElementWithParentWithoutSelectableElement({
    required THElement newElement,
    required THIsParentMixin parent,
  }) {
    _thFile.addElement(newElement);
    parent.addElementToParent(newElement);
  }

  @action
  void deleteElement(THElement element) {
    final TH2FileEditSelectionController selectionController =
        _th2FileEditController.selectionController;

    _thFile.deleteElement(element);
    selectionController.removeSelectableElement(element.mapiahID);
    selectionController.removeSelectedElement(element);
  }

  void deleteElementByMapiahID(int mapiahID) {
    final THElement element = _thFile.elementByMapiahID(mapiahID);

    deleteElement(element);
  }

  @action
  void deleteElementByTHID(String thID) {
    final THElement element = _thFile.elementByTHID(thID);

    deleteElement(element);
  }

  @action
  void deleteElements(List<int> mapiahIDs) {
    for (final int mapiahID in mapiahIDs) {
      deleteElementByMapiahID(mapiahID);
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
      parentMapiahID: _th2FileEditController.activeScrapID,
      lineType: _lastAddedLineType,
    );

    _th2FileEditController.elementEditController
        .addElementWithParentMapiahIDWithoutSelectableElement(
      newElement: newLine,
      parentMapiahID: _th2FileEditController.activeScrapID,
    );

    return newLine;
  }

  @action
  void setNewLine(THLine newLine) {
    _newLine = newLine;
  }

  @action
  void setLastAddedPointType(THPointType pointType) {
    _lastAddedPointType = pointType;
  }

  @action
  void setLastAddedLineType(THLineType lineType) {
    _lastAddedLineType = lineType;
  }

  @action
  void setLastAddedAreaType(THAreaType areaType) {
    _lastAddedAreaType = areaType;
  }

  @action
  void updateBezierLineSegment(
    Offset quadraticControlPointPositionScreenCoordinates,
  ) {
    if ((_newLine == null) || (_newLine!.childrenMapiahID.length < 2)) {
      return;
    }

    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    final THLineSegment lastLineSegment = _thFile
        .elementByMapiahID(_newLine!.childrenMapiahID.last) as THLineSegment;
    final THLineSegment secondToLastLineSegment = _thFile.elementByMapiahID(
      _newLine!.childrenMapiahID
          .elementAt(_newLine!.childrenMapiahID.length - 2),
    ) as THLineSegment;

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
        mapiahID: lastLineSegment.mapiahID,
        parentMapiahID: _newLine!.mapiahID,
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
    int lineMapiahID,
  ) {
    final Offset endPointCanvasCoordinates =
        _th2FileEditController.offsetScreenToCanvas(endpoint);

    final THStraightLineSegment lineSegment = THStraightLineSegment(
      parentMapiahID: lineMapiahID,
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
        final int lineMapiahID = newLine.mapiahID;
        final List<THElement> lineSegments = <THElement>[];

        lineSegments.add(_createStraightLineSegment(
          _lineStartScreenPosition!,
          lineMapiahID,
        ));
        lineSegments.add(_createStraightLineSegment(
          enPointScreenCoordinates,
          lineMapiahID,
        ));

        final MPAddLineCommand command = MPAddLineCommand(
          newLine: newLine,
          lineChildren: lineSegments,
          lineStartScreenPosition: _lineStartScreenPosition,
        );

        _th2FileEditController.execute(command);
      }
    } else {
      final int lineMapiahID = getNewLine().mapiahID;
      final THStraightLineSegment newLineSegment = _createStraightLineSegment(
        enPointScreenCoordinates,
        lineMapiahID,
      );
      final MPAddLineSegmentCommand command = MPAddLineSegmentCommand(
        newLineSegment: newLineSegment,
      );

      _th2FileEditController.execute(command);
    }

    _th2FileEditController.triggerNewLineRedraw();
  }

  @action
  void addLine({
    required THLine newLine,
    required List<THElement> lineChildren,
    Offset? lineStartScreenPosition,
  }) {
    final TH2FileEditElementEditController elementEditController =
        _th2FileEditController.elementEditController;
    final THLine newLineCopy = newLine.copyWith(childrenMapiahID: {});

    elementEditController.addElement(newElement: newLineCopy);

    for (final THElement child in lineChildren) {
      elementEditController.addElement(newElement: child);
    }

    if (lineStartScreenPosition != null) {
      setNewLine(newLineCopy);
      setNewLineStartScreenPosition(lineStartScreenPosition);
    }

    _th2FileEditController.selectionController
        .addSelectableElement(newLineCopy);
  }

  @action
  void deleteLine(int lineMapiahID) {
    if ((_newLine != null) && (_newLine!.mapiahID == lineMapiahID)) {
      clearNewLine();
    }
    _th2FileEditController.elementEditController
        .deleteElementByMapiahID(lineMapiahID);
  }

  @action
  void finalizeNewLineCreation() {
    clearNewLine();
    _th2FileEditController.triggerNonSelectedElementsRedraw();
  }
}
