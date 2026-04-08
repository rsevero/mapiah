// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mobx/mobx.dart';

/// Centralizes element and image transform workflows such as move, scale, and
/// rotate, keeping those responsibilities outside the generic edit controller.
class TH2FileEditMoveScaleRotateElementController
    extends TH2FileEditMoveScaleRotateElementControllerBase {
  TH2FileEditMoveScaleRotateElementController(super.th2FileEditController);
}

abstract class TH2FileEditMoveScaleRotateElementControllerBase with Store {
  final TH2FileEditController _th2FileEditController;
  final TH2File _th2File;

  TH2FileEditMoveScaleRotateElementControllerBase(
    TH2FileEditController th2FileEditController,
  ) : _th2FileEditController = th2FileEditController,
      _th2File = th2FileEditController.th2File;

  late MPMoveControlPointSmoothInfo moveControlPointSmoothInfo;

  TH2FileEditSelectionController get _selectionController =>
      _th2FileEditController.selectionController;

  MPImageInsertConfig prepareImageForMPOnlyTransformActions(int imageMPID) {
    final MPRuntimeImageInsertConfigMixin image = _th2File.imageByMPID(
      imageMPID,
    );

    if (image is MPImageInsertConfig) {
      return image;
    }

    final MPCommand convertImageCommand =
        MPCommandFactory.convertXTherionImageInsertConfigToMapiahImageInsertConfig(
          existingXTherionImageInsertConfigMPID: imageMPID,
          th2FileEditController: _th2FileEditController,
        );

    _th2FileEditController.execute(convertImageCommand);
    _th2FileEditController.triggerImagesRedraw();

    return _th2File.imageByMPID(imageMPID) as MPImageInsertConfig;
  }

  MPRuntimeImageInsertConfigMixin prepareImageMoveState(int imageMPID) {
    final MPRuntimeImageInsertConfigMixin image = _th2File.imageByMPID(
      imageMPID,
    );

    _th2FileEditController.stateController.setImageOperationState(
      type: MPTH2FileEditStateType.imageMove,
      imageMPID: image.mpID,
    );

    return image;
  }

  MPImageInsertConfig prepareImageRotateState(int imageMPID) {
    return _prepareImageOperationState(
      imageMPID: imageMPID,
      stateType: MPTH2FileEditStateType.imageRotate,
    );
  }

  MPImageInsertConfig prepareImageScaleState(int imageMPID) {
    return _prepareImageOperationState(
      imageMPID: imageMPID,
      stateType: MPTH2FileEditStateType.imageScale,
    );
  }

  MPImageInsertConfig _prepareImageOperationState({
    required int imageMPID,
    required MPTH2FileEditStateType stateType,
  }) {
    final MPImageInsertConfig image = prepareImageForMPOnlyTransformActions(
      imageMPID,
    );

    _th2FileEditController.stateController.setImageOperationState(
      type: stateType,
      imageMPID: image.mpID,
    );

    return image;
  }

  void moveSelectedElementsToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedElementsToCanvasCoordinates(canvasCoordinatesFinalPosition);
  }

  @action
  void moveSelectedElementsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.isEmpty || !_th2FileEditController.isSelectMode) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition -
        _selectionController.dragStartCanvasCoordinates;

    for (final MPSelectedElement selectedElement in selectedElements) {
      switch (selectedElement) {
        case MPSelectedPoint _:
          _updateTHPointPosition(selectedElement, localDeltaPositionOnCanvas);
        case MPSelectedLine _:
          _updateTHLinePosition(selectedElement, localDeltaPositionOnCanvas);
        case MPSelectedArea _:
          _updateTHAreaPosition(selectedElement, localDeltaPositionOnCanvas);
      }
    }

    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  void moveSelectedEndControlPointsToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedEndControlPointsToCanvasCoordinates(
      canvasCoordinatesFinalPosition,
    );
  }

  @action
  void moveSelectedEndControlPointsToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if (_selectionController.getCurrentSelectedEndControlPointPointType() !=
        MPSelectedEndControlPointPointType.endPoint) {
      return;
    }

    final Offset localDeltaPositionOnCanvas =
        canvasCoordinatesFinalPosition -
        _selectionController.dragStartCanvasCoordinates;
    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_selectionController.mpSelectedElementsLogical.values.first
                as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final List<int> lineLineSegmentsMPIDs = _selectionController
        .getSelectedLineLineSegmentsMPIDs();
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;
    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        _selectionController.selectedEndControlPoints.values;

    for (final MPSelectedEndControlPoint selectedEndControlPoint
        in selectedEndControlPoints) {
      final THLineSegment selectedLineSegment =
          selectedEndControlPoint.originalLineSegmentClone;
      final int selectedLineSegmentMPID = selectedLineSegment.mpID;
      final THLineSegment originalLineSegment =
          originalLineSegments[selectedLineSegmentMPID]!;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          modifiedLineSegments[selectedLineSegmentMPID] = originalLineSegment
              .copyWith(
                endPoint: THPositionPart(
                  coordinates:
                      originalLineSegment.endPoint.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                originalLineInTH2File: '',
                makeSameLineCommentNull: true,
              );
        case THBezierCurveLineSegment _:
          final THBezierCurveLineSegment referenceLineSegment =
              modifiedLineSegments.containsKey(selectedLineSegmentMPID)
              ? modifiedLineSegments[selectedLineSegmentMPID]
                    as THBezierCurveLineSegment
              : originalLineSegment;

          modifiedLineSegments[selectedLineSegmentMPID] = referenceLineSegment
              .copyWith(
                endPoint: THPositionPart(
                  coordinates:
                      originalLineSegment.endPoint.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                controlPoint2: THPositionPart(
                  coordinates:
                      originalLineSegment.controlPoint2.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                originalLineInTH2File: '',
                makeSameLineCommentNull: true,
              );
      }

      final int? nextLineSegmentMPID = _selectionController
          .getNextLineSegmentMPID(
            selectedLineSegmentMPID,
            lineLineSegmentsMPIDs,
          );

      if (nextLineSegmentMPID != null) {
        final THLineSegment nextLineSegment = _th2File.lineSegmentByMPID(
          nextLineSegmentMPID,
        );

        if (nextLineSegment is THBezierCurveLineSegment) {
          final THBezierCurveLineSegment originalNextLineSegment =
              originalLineSegments[nextLineSegmentMPID]
                  as THBezierCurveLineSegment;
          final THBezierCurveLineSegment referenceNextLineSegment =
              (modifiedLineSegments.containsKey(nextLineSegmentMPID)
                      ? modifiedLineSegments[nextLineSegmentMPID]
                      : originalNextLineSegment)
                  as THBezierCurveLineSegment;

          modifiedLineSegments[nextLineSegmentMPID] = referenceNextLineSegment
              .copyWith(
                controlPoint1: THPositionPart(
                  coordinates:
                      originalNextLineSegment.controlPoint1.coordinates +
                      localDeltaPositionOnCanvas,
                  decimalPositions: currentDecimalPositions,
                ),
                originalLineInTH2File: '',
                makeSameLineCommentNull: true,
              );
        }
      }
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegments,
    );
    _selectionController.updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerEditLineRedraw();
  }

  void moveSelectedControlPointToScreenCoordinates(
    Offset screenCoordinatesFinalPosition,
  ) {
    final Offset canvasCoordinatesFinalPosition = _th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesFinalPosition);

    moveSelectedControlPointToCanvasCoordinates(canvasCoordinatesFinalPosition);
  }

  @action
  void moveSelectedControlPointToCanvasCoordinates(
    Offset canvasCoordinatesFinalPosition,
  ) {
    if (_selectionController.getCurrentSelectedEndControlPointPointType() !=
        MPSelectedEndControlPointPointType.controlPoint) {
      return;
    }

    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_selectionController.mpSelectedElementsLogical.values.first
                as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final MPSelectedEndControlPoint selectedControlPoint =
        _selectionController.selectedEndControlPoints.values.first;
    final THBezierCurveLineSegment controlPointLineSegment =
        selectedControlPoint.originalElementClone as THBezierCurveLineSegment;
    final int controlPointLineSegmentMPID = controlPointLineSegment.mpID;
    final THBezierCurveLineSegment originalControlPointLineSegment =
        originalLineSegments[controlPointLineSegmentMPID]
            as THBezierCurveLineSegment;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegments =
        LinkedHashMap<int, THLineSegment>();
    final int currentDecimalPositions =
        _th2FileEditController.currentDecimalPositions;

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        THBezierCurveLineSegment modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset newPosition = MPElementEditAux.moveControlPointInLine(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint1: THPositionPart(coordinates: newPosition),
            originalLineInTH2File: '',
          );
        } else {
          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint1: THPositionPart(
              coordinates: canvasCoordinatesFinalPosition,
            ),
            originalLineInTH2File: '',
          );
        }

        modifiedLineSegments[controlPointLineSegmentMPID] = modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            !moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset? newPosition = MPElementEditAux.moveMirrorControlPoint(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          if (newPosition != null) {
            final THBezierCurveLineSegment newMirrorLineSegment =
                moveControlPointSmoothInfo.adjacentLineSegment!.copyWith(
                  controlPoint2: THPositionPart(coordinates: newPosition),
                  originalLineInTH2File: '',
                );

            modifiedLineSegments[newMirrorLineSegment.mpID] =
                newMirrorLineSegment;
          }
        }
      case MPEndControlPointType.controlPoint2:
        THBezierCurveLineSegment modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset newPosition = MPElementEditAux.moveControlPointInLine(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint2: THPositionPart(coordinates: newPosition),
            originalLineInTH2File: '',
          );
        } else {
          modifiedLineSegment = originalControlPointLineSegment.copyWith(
            controlPoint2: THPositionPart(
              coordinates: canvasCoordinatesFinalPosition,
              decimalPositions: currentDecimalPositions,
            ),
            originalLineInTH2File: '',
          );
        }

        modifiedLineSegments[controlPointLineSegmentMPID] = modifiedLineSegment;

        if (moveControlPointSmoothInfo.shouldSmooth &&
            !moveControlPointSmoothInfo.isAdjacentStraight!) {
          final Offset? newPosition = MPElementEditAux.moveMirrorControlPoint(
            moveControlPointSmoothInfo,
            canvasCoordinatesFinalPosition,
          );

          if (newPosition != null) {
            final THBezierCurveLineSegment newMirrorLineSegment =
                moveControlPointSmoothInfo.adjacentLineSegment!.copyWith(
                  controlPoint1: THPositionPart(coordinates: newPosition),
                  originalLineInTH2File: '',
                );

            modifiedLineSegments[newMirrorLineSegment.mpID] =
                newMirrorLineSegment;
          }
        }
      default:
        throw Exception(
          'TH2FileEditMoveScaleRotateElementController.moveSelectedControlPointToCanvasCoordinates() called with invalid end/control point type: ${selectedControlPoint.type}',
        );
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegments,
    );
    _selectionController.updateSelectableEndAndControlPoints();
    _th2FileEditController.triggerSelectedElementsRedraw();
    _th2FileEditController.triggerEditLineRedraw();
  }

  void updateControlPointSmoothInfo() {
    final LinkedHashMap<int, THLineSegment> originalLineSegments =
        (_selectionController.mpSelectedElementsLogical.values.first
                as MPSelectedLine)
            .originalLineSegmentsMapClone;
    final MPSelectedEndControlPoint selectedControlPoint =
        _selectionController.selectedEndControlPoints.values.first;
    final THBezierCurveLineSegment controlPointLineSegment =
        selectedControlPoint.originalElementClone as THBezierCurveLineSegment;
    final int controlPointLineSegmentMPID = controlPointLineSegment.mpID;
    final THBezierCurveLineSegment originalControlPointLineSegment =
        originalLineSegments[controlPointLineSegmentMPID]
            as THBezierCurveLineSegment;
    final THLine line = _th2File.lineByMPID(controlPointLineSegment.parentMPID);

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        final THLineSegment? originalPreviousLineSegment = line
            .getPreviousLineSegment(controlPointLineSegment, _th2File);

        if ((originalPreviousLineSegment != null) &&
            MPCommandOptionAux.isSmooth(originalPreviousLineSegment) &&
            !line.isFirstLineSegment(originalPreviousLineSegment, _th2File)) {
          final Offset junction =
              originalPreviousLineSegment.endPoint.coordinates;

          if (originalPreviousLineSegment is THStraightLineSegment) {
            final THLineSegment? originalSecondPreviousLineSegment = line
                .getPreviousLineSegment(originalPreviousLineSegment, _th2File);

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
            !line.isLastLineSegment(controlPointLineSegment, _th2File)) {
          final THLineSegment? originalNextLineSegment = line
              .getNextLineSegment(controlPointLineSegment, _th2File);
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

  void _updateTHPointPosition(
    MPSelectedPoint selectedPoint,
    Offset localDeltaPositionOnCanvas,
  ) {
    final THPoint originalPoint = selectedPoint.originalPointClone;
    final THPoint modifiedPoint = originalPoint.copyWith(
      position: originalPoint.position.copyWith(
        coordinates:
            originalPoint.position.coordinates + localDeltaPositionOnCanvas,
      ),
      originalLineInTH2File: '',
      makeSameLineCommentNull: true,
    );

    _th2FileEditController.elementEditController
        .substituteElementWithoutAddSelectableElement(modifiedPoint);
  }

  void _updateTHLinePosition(
    MPSelectedLine selectedLine,
    Offset localDeltaPositionOnCanvas,
  ) {
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final MapEntry<int, THLineSegment> lineSegmentEntry
        in selectedLine.originalLineSegmentsMapClone.entries) {
      final THElement lineChild = lineSegmentEntry.value;

      late THLineSegment modifiedLineSegment;

      switch (lineChild) {
        case THStraightLineSegment _:
          modifiedLineSegment = lineChild.copyWith(
            endPoint: lineChild.endPoint.copyWith(
              coordinates:
                  lineChild.endPoint.coordinates + localDeltaPositionOnCanvas,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );
        case THBezierCurveLineSegment _:
          modifiedLineSegment = lineChild.copyWith(
            endPoint: lineChild.endPoint.copyWith(
              coordinates:
                  lineChild.endPoint.coordinates + localDeltaPositionOnCanvas,
            ),
            controlPoint1: lineChild.controlPoint1.copyWith(
              coordinates:
                  lineChild.controlPoint1.coordinates +
                  localDeltaPositionOnCanvas,
            ),
            controlPoint2: lineChild.controlPoint2.copyWith(
              coordinates:
                  lineChild.controlPoint2.coordinates +
                  localDeltaPositionOnCanvas,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );
        default:
          throw Exception('Unknown line segment type');
      }

      modifiedLineSegmentsMap[lineChild.mpID] = modifiedLineSegment;
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegmentsMap,
    );
  }

  void _updateTHAreaPosition(
    MPSelectedArea selectedArea,
    Offset localDeltaPositionOnCanvas,
  ) {
    for (final MPSelectedLine mpAreaLine in selectedArea.originalLines) {
      _updateTHLinePosition(mpAreaLine, localDeltaPositionOnCanvas);
    }

    _th2File.areaByMPID(selectedArea.mpID).clearBoundingBox();
  }
}
