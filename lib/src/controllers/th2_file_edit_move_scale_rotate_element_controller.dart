// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';
import 'package:mapiah/src/auxiliary/mp_image_transform_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_move_scale_rotate_element_controller.g.dart';

/// Centralizes element and image transform workflows such as move, scale, and
/// rotate, keeping those responsibilities outside the generic edit controller.
class TH2FileEditMoveScaleRotateElementController
    extends TH2FileEditMoveScaleRotateElementControllerBase
    with _$TH2FileEditMoveScaleRotateElementController {
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

  bool get isElementTransformsEnabled {
    return mpLocator.mpSettingsController.getBoolWithDefault(
      MPSettingID.TH2Edit_EnableElementTransforms,
    );
  }

  bool get shouldShowElementTransformHandles {
    if (!isElementTransformsEnabled) {
      return false;
    }

    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.length != 1) {
      return true;
    }

    return selectedElements.first.originalElementClone.elementType !=
        THElementType.point;
  }

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

    final MPImageInsertConfig convertedImage =
        _th2File.imageByMPID(imageMPID) as MPImageInsertConfig;

    image.copyRuntimeImageCacheTo(
      targetImage: convertedImage,
      th2FileEditController: _th2FileEditController,
    );

    return convertedImage;
  }

  MPRuntimeImageInsertConfigMixin prepareImageMoveState(int imageMPID) {
    final MPRuntimeImageInsertConfigMixin image = _th2File.imageByMPID(
      imageMPID,
    );

    _th2FileEditController.stateController.setImageOperationState(
      type: MPTH2FileEditStateType.imageMoveScale,
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

  MPRuntimeImageInsertConfigMixin prepareImageScaleState(int imageMPID) {
    return prepareImageMoveState(imageMPID);
  }

  void flipImageHorizontally(int imageMPID) {
    _flipImage(imageMPID: imageMPID, flipX: true, flipY: false);
  }

  void flipImageVertically(int imageMPID) {
    _flipImage(imageMPID: imageMPID, flipX: false, flipY: true);
  }

  void resetImageTransform(int imageMPID) {
    final MPRuntimeImageInsertConfigMixin image = _th2File.imageByMPID(
      imageMPID,
    );
    final THIsParentMixin parent = image.parent(th2File: _th2File);
    final int imagePositionInParent = parent.getChildPosition(image);
    final THElement resetImage = _buildResetImageInsertConfig(image);
    final MPCommand removeImageCommand =
        MPCommandFactory.removeImageInsertConfigFromExisting(
          existingImageInsertConfigMPID: imageMPID,
          th2File: _th2File,
        );
    final MPCommand addImageCommand =
        MPCommandFactory.addImageInsertConfigFromExisting(
          existingImageInsertConfig: resetImage,
          th2File: _th2File,
          imageInsertConfigPositionInParent: imagePositionInParent,
        );
    final MPCommand resetImageCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: <MPCommand>[removeImageCommand, addImageCommand],
          descriptionType: removeImageCommand.descriptionType,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsListChanged,
        );

    _th2FileEditController.stateController.clearImageOperationState();
    _th2FileEditController.execute(resetImageCommand);
    _th2FileEditController.triggerImagesRedraw();
  }

  THElement _buildResetImageInsertConfig(
    MPRuntimeImageInsertConfigMixin image,
  ) {
    final MPSVGImageInsertConfig? svgImage = (image is MPSVGImageInsertConfig)
        ? image
        : null;

    if (svgImage != null) {
      final MPSVGImageInsertConfig resetImage = MPSVGImageInsertConfig(
        parentMPID: image.parentMPID,
        filename: image.filename,
        xx: 0.0,
        yy: 0.0,
        isVisible: true,
        intrinsicSizeInfo: svgImage.intrinsicSizeInfo,
        originalLineInTH2File: '',
      ).copyWith(mpID: image.mpID, sameLineComment: image.sameLineComment);

      image.copyRuntimeImageCacheTo(
        targetImage: resetImage,
        th2FileEditController: _th2FileEditController,
      );

      return resetImage;
    }

    final THXTherionImageInsertConfig resetImage =
        THXTherionImageInsertConfig(
          parentMPID: image.parentMPID,
          filename: image.filename,
          xx: THDoublePart(value: 0.0),
          yy: THDoublePart(value: 0.0),
          isVisible: true,
          isGridVisible: true,
          xviRoot: image.asXVIImage?.xviRoot ?? '',
          originalLineInTH2File: '',
        ).copyWith(
          mpID: image.mpID,
          sameLineComment: image.sameLineComment,
          iidx: (image is THXTherionImageInsertConfig) ? image.iidx : 0,
          imgx: (image is THXTherionImageInsertConfig) ? image.imgx : '',
          xData: (image is THXTherionImageInsertConfig) ? image.xData : '',
          xImage: (image is THXTherionImageInsertConfig) ? image.xImage : false,
          igamma: (image is THXTherionImageInsertConfig) ? image.igamma : null,
        );

    image.copyRuntimeImageCacheTo(
      targetImage: resetImage,
      th2FileEditController: _th2FileEditController,
    );

    return resetImage;
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

  void _flipImage({
    required int imageMPID,
    required bool flipX,
    required bool flipY,
  }) {
    assert(flipX != flipY, 'Exactly one flip axis must be enabled.');

    final MPImageInsertConfig image = prepareImageForMPOnlyTransformActions(
      imageMPID,
    );
    final Rect? localBounds = image.getLocalBounds(_th2FileEditController);

    if (localBounds == null) {
      return;
    }

    final Offset anchorLocal = localBounds.center;
    final Offset anchorCanvas = image.transformLocalPoint(anchorLocal);
    final THDoublePart toXScale = image.xScale.copyWith(
      value: flipX ? -image.xScale.value : image.xScale.value,
      decimalPositions: _th2FileEditController.currentDecimalPositions,
    );
    final THDoublePart toYScale = image.yScale.copyWith(
      value: flipY ? -image.yScale.value : image.yScale.value,
      decimalPositions: _th2FileEditController.currentDecimalPositions,
    );
    final Offset translation = _translationForAnchor(
      startImage: image,
      anchorLocal: anchorLocal,
      anchorCanvas: anchorCanvas,
      xScale: toXScale.value,
      yScale: toYScale.value,
    );
    final THDoublePart toXX = image.xx.copyWith(
      value: translation.dx,
      decimalPositions: _th2FileEditController.currentDecimalPositions,
    );
    final THDoublePart toYY = image.yy.copyWith(
      value: translation.dy,
      decimalPositions: _th2FileEditController.currentDecimalPositions,
    );
    final MPScaleImageInsertConfigCommand flipCommand =
        MPCommandFactory.scaleImageInsertConfig(
          imageMPID: imageMPID,
          toXX: toXX,
          toYY: toYY,
          toXScale: toXScale,
          toYScale: toYScale,
          th2File: _th2File,
        );

    _th2FileEditController.execute(flipCommand);
  }

  Offset _translationForAnchor({
    required MPImageInsertConfig startImage,
    required Offset anchorLocal,
    required Offset anchorCanvas,
    required double xScale,
    required double yScale,
  }) {
    final Offset scaledAnchor = Offset(
      anchorLocal.dx * xScale,
      anchorLocal.dy * yScale,
    );
    final Offset localPivot = startImage.localRotationCenter;
    final Offset scaledPivot = Offset(
      localPivot.dx * xScale,
      localPivot.dy * yScale,
    );
    final Offset rotatedDelta = _rotateOffset(
      scaledAnchor - scaledPivot,
      startImage.rotationDeg.value * mp1DegreeInRads,
    );

    return anchorCanvas - rotatedDelta - scaledPivot;
  }

  Offset _rotateOffset(Offset offset, double angleInRad) {
    final double cosValue = cos(angleInRad);
    final double sinValue = sin(angleInRad);

    return Offset(
      offset.dx * cosValue - offset.dy * sinValue,
      offset.dx * sinValue + offset.dy * cosValue,
    );
  }

  MPSelectionHandleType? getSelectionHandleAtScreenPosition(
    Offset screenPosition,
  ) {
    final Map<MPSelectionHandleType, Offset> handleCenters =
        _selectionController.getSelectionHandleCenters();
    final double hitRadius =
        _th2FileEditController.selectionHandleSizeOnCanvas * 2.0;
    final Offset canvasPosition = _th2FileEditController.offsetScreenToCanvas(
      screenPosition,
    );

    for (final MapEntry<MPSelectionHandleType, Offset> entry
        in handleCenters.entries) {
      if ((entry.value - canvasPosition).distance <= hitRadius) {
        return entry.key;
      }
    }

    return null;
  }

  Offset selectionHandlePointOnBounds(
    Rect bounds,
    MPSelectionHandleType handleType,
  ) {
    switch (handleType) {
      case MPSelectionHandleType.topLeft:
        return bounds.topLeft;
      case MPSelectionHandleType.topRight:
        return bounds.topRight;
      case MPSelectionHandleType.bottomLeft:
        return bounds.bottomLeft;
      case MPSelectionHandleType.bottomRight:
        return bounds.bottomRight;
      case MPSelectionHandleType.leftCenter:
        return bounds.centerLeft;
      case MPSelectionHandleType.rightCenter:
        return bounds.centerRight;
      case MPSelectionHandleType.topCenter:
        return bounds.topCenter;
      case MPSelectionHandleType.bottomCenter:
        return bounds.bottomCenter;
    }
  }

  MPSelectionHandleType oppositeSelectionHandleType(
    MPSelectionHandleType handleType,
  ) {
    switch (handleType) {
      case MPSelectionHandleType.topLeft:
        return MPSelectionHandleType.bottomRight;
      case MPSelectionHandleType.topRight:
        return MPSelectionHandleType.bottomLeft;
      case MPSelectionHandleType.bottomLeft:
        return MPSelectionHandleType.topRight;
      case MPSelectionHandleType.bottomRight:
        return MPSelectionHandleType.topLeft;
      case MPSelectionHandleType.leftCenter:
        return MPSelectionHandleType.rightCenter;
      case MPSelectionHandleType.rightCenter:
        return MPSelectionHandleType.leftCenter;
      case MPSelectionHandleType.topCenter:
        return MPSelectionHandleType.bottomCenter;
      case MPSelectionHandleType.bottomCenter:
        return MPSelectionHandleType.topCenter;
    }
  }

  MPImageTransformHandleType toImageTransformHandleType(
    MPSelectionHandleType handleType,
  ) {
    switch (handleType) {
      case MPSelectionHandleType.topLeft:
        return MPImageTransformHandleType.topLeft;
      case MPSelectionHandleType.topRight:
        return MPImageTransformHandleType.topRight;
      case MPSelectionHandleType.bottomLeft:
        return MPImageTransformHandleType.bottomLeft;
      case MPSelectionHandleType.bottomRight:
        return MPImageTransformHandleType.bottomRight;
      case MPSelectionHandleType.leftCenter:
        return MPImageTransformHandleType.centerLeft;
      case MPSelectionHandleType.rightCenter:
        return MPImageTransformHandleType.centerRight;
      case MPSelectionHandleType.topCenter:
        return MPImageTransformHandleType.topCenter;
      case MPSelectionHandleType.bottomCenter:
        return MPImageTransformHandleType.bottomCenter;
    }
  }

  double avoidZeroScale(double value) {
    if (value.abs() >= mpDoubleComparisonEpsilon) {
      return value;
    }

    return value.isNegative
        ? -mpDoubleComparisonEpsilon
        : mpDoubleComparisonEpsilon;
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

  void scaleSelectedElements({
    required Offset anchorCanvas,
    required double xScaleFactor,
    required double yScaleFactor,
  }) {
    _transformSelectedElements(
      transformPoint: (Offset point) {
        return Offset(
          anchorCanvas.dx + ((point.dx - anchorCanvas.dx) * xScaleFactor),
          anchorCanvas.dy + ((point.dy - anchorCanvas.dy) * yScaleFactor),
        );
      },
    );
  }

  void rotateSelectedElements({
    required Offset pivotCanvas,
    required double angleInDeg,
  }) {
    final double angleInRad = angleInDeg * mp1DegreeInRads;

    _transformSelectedElements(
      transformPoint: (Offset point) {
        return pivotCanvas + _rotateOffset(point - pivotCanvas, angleInRad);
      },
    );
  }

  void flipSelectedElementsHorizontally() {
    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.isEmpty) {
      return;
    }

    final Rect startBounds = _selectionController.selectedElementsBoundingBox;

    scaleSelectedElements(
      anchorCanvas: startBounds.center,
      xScaleFactor: -1.0,
      yScaleFactor: 1.0,
    );
    finalizeSelectedElementsTransform();
  }

  void flipSelectedElementsVertically() {
    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.isEmpty) {
      return;
    }

    final Rect startBounds = _selectionController.selectedElementsBoundingBox;

    scaleSelectedElements(
      anchorCanvas: startBounds.center,
      xScaleFactor: 1.0,
      yScaleFactor: -1.0,
    );
    finalizeSelectedElementsTransform();
  }

  void restoreSelectedElementsFromClones({bool updateRedraw = true}) {
    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      switch (selectedElement) {
        case MPSelectedPoint _:
          _th2FileEditController.elementEditController
              .substituteElementWithoutAddSelectableElement(
                selectedElement.originalPointClone,
              );
        case MPSelectedLine _:
          _th2FileEditController.elementEditController.substituteLineSegments(
            selectedElement.originalLineSegmentsMapClone,
          );
        case MPSelectedArea _:
          for (final MPSelectedLine originalLine
              in selectedElement.originalLines) {
            _th2FileEditController.elementEditController.substituteLineSegments(
              originalLine.originalLineSegmentsMapClone,
            );
          }

          _th2File.areaByMPID(selectedElement.mpID).clearBoundingBox();
      }
    }

    _selectionController.updateAllSelectedElementsClones();

    if (updateRedraw) {
      _th2FileEditController.triggerSelectedElementsRedraw();
    }
  }

  void finalizeSelectedElementsTransform({
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveElements,
  }) {
    final List<MPCommand> commandsList = <MPCommand>[];
    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      switch (selectedElement) {
        case MPSelectedPoint _:
          final THPoint currentPoint = _th2File.pointByMPID(
            selectedElement.mpID,
          );
          final THPoint originalPoint = selectedElement.originalPointClone;

          if (currentPoint.position == originalPoint.position) {
            continue;
          }

          commandsList.add(
            MPMovePointCommand(
              pointMPID: currentPoint.mpID,
              fromPosition: originalPoint.position,
              toPosition: currentPoint.position,
              fromOriginalLineInTH2File: originalPoint.originalLineInTH2File,
              toOriginalLineInTH2File: '',
              descriptionType: descriptionType,
            ),
          );
        case MPSelectedLine _:
          final THLine currentLine = _th2File.lineByMPID(selectedElement.mpID);
          final LinkedHashMap<int, THLineSegment> currentLineSegmentsMap =
              _th2FileEditController.elementEditController.getLineSegmentsMap(
                currentLine,
              );

          if (_lineSegmentMapsMatch(
            selectedElement.originalLineSegmentsMapClone,
            currentLineSegmentsMap,
          )) {
            continue;
          }

          commandsList.add(
            MPMoveLineCommand(
              lineMPID: currentLine.mpID,
              fromLineSegmentsMap: selectedElement.originalLineSegmentsMapClone,
              toLineSegmentsMap: currentLineSegmentsMap,
              descriptionType: descriptionType,
            ),
          );
        case MPSelectedArea _:
          final MPCommand? areaCommand = _buildAreaTransformCommand(
            selectedArea: selectedElement,
            descriptionType: descriptionType,
          );

          if (areaCommand != null) {
            commandsList.add(areaCommand);
          }
      }
    }

    restoreSelectedElementsFromClones(updateRedraw: false);

    if (commandsList.isEmpty) {
      _th2FileEditController.triggerSelectedElementsRedraw();

      return;
    }

    final MPCommand transformCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: commandsList,
          descriptionType: descriptionType,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsEdited,
        );

    _th2FileEditController.execute(transformCommand);
    _selectionController.updateAllSelectedElementsClones();
    _th2FileEditController.triggerSelectedElementsRedraw(setState: true);
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

  void finalizeSelectedEndControlPointsMove() {
    final MPSelectedLine mpSelectedLine = _selectionController
        .getMPSelectedLine();
    final THLine selectedLine = _selectionController.getSelectedLine();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        mpSelectedLine.originalLineSegmentsMapClone;
    final List<int> lineLineSegmentsMPIDs = _selectionController
        .getSelectedLineLineSegmentsMPIDs();
    final List<int> selectedLineSegmentMPIDs = _selectionController
        .selectedEndControlPoints
        .keys
        .toList();
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int selectedLineSegmentMPID in selectedLineSegmentMPIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMPID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMPID] = _th2File
            .lineSegmentByMPID(selectedLineSegmentMPID);
        originalLineSegmentsMap[selectedLineSegmentMPID] =
            originalLineSegmentsMapClone[selectedLineSegmentMPID]!;
      }

      final int? nextLineSegmentMPID = _selectionController
          .getNextLineSegmentMPID(
            selectedLineSegmentMPID,
            lineLineSegmentsMPIDs,
          );

      if ((nextLineSegmentMPID != null) &&
          !modifiedLineSegmentsMap.containsKey(nextLineSegmentMPID)) {
        final THLineSegment nextLineSegment = _th2File.lineSegmentByMPID(
          nextLineSegmentMPID,
        );

        if (nextLineSegment is THBezierCurveLineSegment) {
          modifiedLineSegmentsMap[nextLineSegmentMPID] = nextLineSegment;
          originalLineSegmentsMap[nextLineSegmentMPID] =
              originalLineSegmentsMapClone[nextLineSegmentMPID]!;
        }
      }
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMPID: selectedLine.mpID,
      fromLineSegmentsMap: originalLineSegmentsMap,
      toLineSegmentsMap: modifiedLineSegmentsMap,
      descriptionType: MPCommandDescriptionType.editLine,
    );

    _th2FileEditController.execute(lineEditCommand);
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditPartial();
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditFinal();
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

  void finalizeSelectedControlPointMove() {
    final MPSelectedLine mpSelectedLine = _selectionController
        .getMPSelectedLine();
    final THLine selectedLine = _selectionController.getSelectedLine();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
        mpSelectedLine.originalLineSegmentsMapClone;
    final Iterable<int> selectedControlPointLineSegmentMPIDs =
        _selectionController.selectedEndControlPoints.keys;
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();
    final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final int selectedLineSegmentMPID
        in selectedControlPointLineSegmentMPIDs) {
      if (!modifiedLineSegmentsMap.containsKey(selectedLineSegmentMPID)) {
        modifiedLineSegmentsMap[selectedLineSegmentMPID] = _th2File
            .lineSegmentByMPID(selectedLineSegmentMPID);
        originalLineSegmentsMap[selectedLineSegmentMPID] =
            originalLineSegmentsMapClone[selectedLineSegmentMPID]!;
      }
    }

    final MPMoveControlPointSmoothInfo smoothInfo = moveControlPointSmoothInfo;

    if (smoothInfo.shouldSmooth && !smoothInfo.isAdjacentStraight!) {
      final int smoothedLineSegmentMPID = smoothInfo.adjacentLineSegment!.mpID;

      modifiedLineSegmentsMap[smoothedLineSegmentMPID] = _th2File
          .lineSegmentByMPID(smoothedLineSegmentMPID);
      originalLineSegmentsMap[smoothedLineSegmentMPID] =
          originalLineSegmentsMapClone[smoothedLineSegmentMPID]!;
    }

    final MPCommand lineEditCommand = MPMoveLineCommand(
      lineMPID: selectedLine.mpID,
      fromLineSegmentsMap: originalLineSegmentsMap,
      toLineSegmentsMap: modifiedLineSegmentsMap,
      descriptionType: MPCommandDescriptionType.editBezierCurve,
    );

    _th2FileEditController.execute(lineEditCommand);
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditPartial();
    _th2FileEditController.elementEditController
        .updateControllersAfterElementEditFinal();
  }

  void nudgeSelectedLinePointByDeltaOnCanvas(Offset deltaOnCanvas) {
    switch (_selectionController.getCurrentSelectedEndControlPointPointType()) {
      case MPSelectedEndControlPointPointType.endPoint:
        final THLineSegment selectedSegment = _selectionController
            .selectedEndControlPoints
            .values
            .first
            .originalLineSegmentClone;
        final Offset startCanvasPosition = selectedSegment.endPoint.coordinates;

        _selectionController.setDragStartCoordinatesFromCanvasCoordinates(
          startCanvasPosition,
        );
        moveSelectedEndControlPointsToCanvasCoordinates(
          startCanvasPosition + deltaOnCanvas,
        );
        finalizeSelectedEndControlPointsMove();
      case MPSelectedEndControlPointPointType.controlPoint:
        final MPSelectedEndControlPoint selectedControlPoint =
            _selectionController.selectedEndControlPoints.values.first;
        final Offset startCanvasPosition = _selectedControlPointCanvasPosition(
          selectedControlPoint,
        );

        updateControlPointSmoothInfo();
        _selectionController.setDragStartCoordinatesFromCanvasCoordinates(
          startCanvasPosition,
        );
        moveSelectedControlPointToCanvasCoordinates(
          startCanvasPosition + deltaOnCanvas,
        );
        finalizeSelectedControlPointMove();
      case MPSelectedEndControlPointPointType.none:
        return;
    }
  }

  Offset _selectedControlPointCanvasPosition(
    MPSelectedEndControlPoint selectedControlPoint,
  ) {
    final THBezierCurveLineSegment lineSegment =
        selectedControlPoint.originalLineSegmentClone
            as THBezierCurveLineSegment;

    switch (selectedControlPoint.type) {
      case MPEndControlPointType.controlPoint1:
        return lineSegment.controlPoint1.coordinates;
      case MPEndControlPointType.controlPoint2:
        return lineSegment.controlPoint2.coordinates;
      default:
        throw Exception(
          'Unsupported selected control point type ${selectedControlPoint.type} in TH2FileEditMoveScaleRotateElementControllerBase._selectedControlPointCanvasPosition().',
        );
    }
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

  void _transformSelectedElements({
    required Offset Function(Offset point) transformPoint,
  }) {
    final Iterable<MPSelectedElement> selectedElements =
        _selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      switch (selectedElement) {
        case MPSelectedPoint _:
          final THPoint originalPoint = selectedElement.originalPointClone;
          final THPoint modifiedPoint = originalPoint.copyWith(
            position: originalPoint.position.copyWith(
              coordinates: transformPoint(originalPoint.position.coordinates),
              decimalPositions: _th2FileEditController.currentDecimalPositions,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );

          _th2FileEditController.elementEditController
              .substituteElementWithoutAddSelectableElement(modifiedPoint);
        case MPSelectedLine _:
          _transformSelectedLine(
            selectedLine: selectedElement,
            transformPoint: transformPoint,
          );
        case MPSelectedArea _:
          for (final MPSelectedLine areaLine in selectedElement.originalLines) {
            _transformSelectedLine(
              selectedLine: areaLine,
              transformPoint: transformPoint,
            );
          }

          _th2File.areaByMPID(selectedElement.mpID).clearBoundingBox();
      }
    }

    _th2FileEditController.triggerSelectedElementsRedraw();
  }

  void _transformSelectedLine({
    required MPSelectedLine selectedLine,
    required Offset Function(Offset point) transformPoint,
  }) {
    final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap =
        LinkedHashMap<int, THLineSegment>();

    for (final MapEntry<int, THLineSegment> entry
        in selectedLine.originalLineSegmentsMapClone.entries) {
      final THLineSegment lineSegment = entry.value;

      switch (lineSegment) {
        case THStraightLineSegment _:
          modifiedLineSegmentsMap[entry.key] = lineSegment.copyWith(
            endPoint: lineSegment.endPoint.copyWith(
              coordinates: transformPoint(lineSegment.endPoint.coordinates),
              decimalPositions: _th2FileEditController.currentDecimalPositions,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );
        case THBezierCurveLineSegment _:
          modifiedLineSegmentsMap[entry.key] = lineSegment.copyWith(
            endPoint: lineSegment.endPoint.copyWith(
              coordinates: transformPoint(lineSegment.endPoint.coordinates),
              decimalPositions: _th2FileEditController.currentDecimalPositions,
            ),
            controlPoint1: lineSegment.controlPoint1.copyWith(
              coordinates: transformPoint(
                lineSegment.controlPoint1.coordinates,
              ),
              decimalPositions: _th2FileEditController.currentDecimalPositions,
            ),
            controlPoint2: lineSegment.controlPoint2.copyWith(
              coordinates: transformPoint(
                lineSegment.controlPoint2.coordinates,
              ),
              decimalPositions: _th2FileEditController.currentDecimalPositions,
            ),
            originalLineInTH2File: '',
            makeSameLineCommentNull: true,
          );
      }
    }

    _th2FileEditController.elementEditController.substituteLineSegments(
      modifiedLineSegmentsMap,
    );
  }

  MPCommand? _buildAreaTransformCommand({
    required MPSelectedArea selectedArea,
    required MPCommandDescriptionType descriptionType,
  }) {
    final List<MPCommand> areaLineCommands = <MPCommand>[];

    for (final MPSelectedLine originalLine in selectedArea.originalLines) {
      final THLine currentLine = _th2File.lineByMPID(originalLine.mpID);
      final LinkedHashMap<int, THLineSegment> currentLineSegmentsMap =
          _th2FileEditController.elementEditController.getLineSegmentsMap(
            currentLine,
          );

      if (_lineSegmentMapsMatch(
        originalLine.originalLineSegmentsMapClone,
        currentLineSegmentsMap,
      )) {
        continue;
      }

      areaLineCommands.add(
        MPMoveLineCommand(
          lineMPID: currentLine.mpID,
          fromLineSegmentsMap: originalLine.originalLineSegmentsMapClone,
          toLineSegmentsMap: currentLineSegmentsMap,
          descriptionType: descriptionType,
        ),
      );
    }

    if (areaLineCommands.isEmpty) {
      return null;
    }

    final MPCommand linesMoveCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: areaLineCommands,
          descriptionType: descriptionType,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsEdited,
        );

    return MPMoveAreaCommand.forCWJM(
      areaMPID: selectedArea.mpID,
      linesMoveCommand: linesMoveCommand,
      originalLineInTH2File:
          selectedArea.originalAreaClone.originalLineInTH2File,
      descriptionType: descriptionType,
    );
  }

  bool _lineSegmentMapsMatch(
    Map<int, THLineSegment> originalMap,
    Map<int, THLineSegment> currentMap,
  ) {
    if (originalMap.length != currentMap.length) {
      return false;
    }

    for (final MapEntry<int, THLineSegment> entry in originalMap.entries) {
      if (currentMap[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}
