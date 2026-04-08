// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

enum _MPImageTransformDragMode { none, move, scale }

class MPTH2FileEditStateImageMoveScale
    extends MPTH2FileEditStateImageOperation {
  _MPImageTransformDragMode _dragMode = _MPImageTransformDragMode.none;
  Offset? _dragStartCanvasPosition;
  Offset? _dragStartImageTopLeft;
  Offset? _scaleStartScreenHandleCenter;
  MPRuntimeImageInsertConfigMixin? _previewImage;
  Offset _previewOffset = Offset.zero;
  MPImageInsertConfig? _scaleStartImage;
  Rect? _scaleStartLocalBounds;
  MPImageTransformHandleType? _scaleHandleType;

  MPTH2FileEditStateImageMoveScale({
    required super.th2FileEditController,
    required super.imageMPID,
  });

  @override
  void setCursor() {
    switch (_dragMode) {
      case _MPImageTransformDragMode.move:
        th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);
        return;
      case _MPImageTransformDragMode.scale:
        th2FileEditController.setCanvasCursor(
          _cursorForScaleHandle(_scaleHandleType) ?? SystemMouseCursors.grab,
        );
        return;
      case _MPImageTransformDragMode.none:
        break;
    }

    final MPImageTransformGeometry? geometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: imageConfig,
        );

    if (geometry == null) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);

      return;
    }

    final Offset screenPosition = th2FileEditController.mousePosition;
    final MPImageTransformHandleType? hoveredHandle = geometry.hitTestHandle(
      screenPosition,
    );

    if (hoveredHandle != null) {
      th2FileEditController.setCanvasCursor(
        _cursorForScaleHandle(hoveredHandle) ?? SystemMouseCursors.basic,
      );

      return;
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      screenPosition,
    );

    if (geometry.containsCanvasPosition(canvasPosition)) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.grab);
    } else {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);
    }
  }

  @override
  String get statusBarMessage =>
      mpLocator.appLocalizations.th2FileEditPageImageMoveStatusBarMessage;

  @override
  String get overlayLabel => '';

  @override
  Offset get previewOffset => _previewOffset;

  @override
  MPRuntimeImageInsertConfigMixin? get renderedImageConfig => _previewImage;

  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    final MPImageTransformGeometry? initialGeometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: imageConfig,
        );

    if (initialGeometry == null) {
      _resetDragPreview();

      return;
    }

    final MPImageTransformHandleType? handleType = initialGeometry
        .hitTestHandle(event.localPosition);

    if (handleType != null) {
      _startScaleDrag(handleType: handleType);

      return;
    }

    if (!initialGeometry.containsCanvasPosition(canvasPosition)) {
      _resetDragPreview();

      return;
    }

    final Rect? imageBoundingBox = imageConfig.getBoundingBox(
      th2FileEditController,
    );

    if (imageBoundingBox == null) {
      _resetDragPreview();

      return;
    }

    _dragMode = _MPImageTransformDragMode.move;
    _dragStartCanvasPosition = canvasPosition;
    _dragStartImageTopLeft = imageBoundingBox.topLeft;
    setCursor();
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    switch (_dragMode) {
      case _MPImageTransformDragMode.move:
        _updateMovePreview(event);
      case _MPImageTransformDragMode.scale:
        _updateScalePreview(event);
      case _MPImageTransformDragMode.none:
        return;
    }
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    switch (_dragMode) {
      case _MPImageTransformDragMode.move:
        _commitMovePreview();
      case _MPImageTransformDragMode.scale:
        _commitScalePreview();
      case _MPImageTransformDragMode.none:
        _resetDragPreview();
    }
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    final MPImageTransformGeometry? geometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: imageConfig,
        );

    if (geometry == null) {
      return Future.value();
    }

    if (geometry.hitTestHandle(event.localPosition) != null) {
      return Future.value();
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );

    if (!geometry.containsCanvasPosition(canvasPosition)) {
      return Future.value();
    }

    th2FileEditController.moveScaleRotateElementController
        .prepareImageRotateState(imageMPID);

    return Future.value();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    _resetDragPreview(updateRedraw: false);
    th2FileEditController.setMovingMousePosition(null);
    super.onStateExit(nextState);
  }

  void _startScaleDrag({required MPImageTransformHandleType handleType}) {
    final MPRuntimeImageInsertConfigMixin currentImage = imageConfig;
    final MPImageInsertConfig editableImage =
        (currentImage is MPImageInsertConfig)
        ? currentImage
        : th2FileEditController.moveScaleRotateElementController
              .prepareImageForMPOnlyTransformActions(imageMPID);
    final MPImageTransformGeometry? geometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: editableImage,
        );

    if (geometry == null) {
      _resetDragPreview();

      return;
    }

    _dragMode = _MPImageTransformDragMode.scale;
    _scaleStartImage = editableImage;
    _scaleStartLocalBounds = geometry.localBounds;
    _scaleHandleType = handleType;
    _dragStartCanvasPosition = editableImage.transformLocalPoint(
      geometry.handleLocalPoint(handleType),
    );
    _scaleStartScreenHandleCenter = geometry.screenHandleCenters[handleType];
    setCursor();
  }

  void _updateMovePreview(PointerMoveEvent event) {
    if ((_dragStartCanvasPosition == null) ||
        (_dragStartImageTopLeft == null)) {
      return;
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    final Offset unsnappedTopLeft =
        _dragStartImageTopLeft! + (canvasPosition - _dragStartCanvasPosition!);
    final THPositionPart snappedTopLeft =
        snapController.getCanvasSnapedPositionFromCanvasOffset(
          unsnappedTopLeft,
        ) ??
        THPositionPart(
          coordinates: unsnappedTopLeft,
          decimalPositions: th2FileEditController.currentDecimalPositions,
        );
    final Offset previewOffset =
        snappedTopLeft.coordinates - _dragStartImageTopLeft!;
    final THDoublePart previewXX = imageConfig.xx.copyWith(
      value: imageConfig.xx.value + previewOffset.dx,
      decimalPositions: th2FileEditController.currentDecimalPositions,
    );
    final THDoublePart previewYY = imageConfig.yy.copyWith(
      value: imageConfig.yy.value + previewOffset.dy,
      decimalPositions: th2FileEditController.currentDecimalPositions,
    );

    _previewOffset = previewOffset;
    _previewImage = _buildPreviewImage(
      sourceImage: imageConfig,
      xx: previewXX,
      yy: previewYY,
    );
    th2FileEditController.setMovingMousePosition(snappedTopLeft.coordinates);
    th2FileEditController.triggerImagesRedraw();
  }

  void _updateScalePreview(PointerMoveEvent event) {
    final MPImageInsertConfig? startImage = _scaleStartImage;
    final Rect? startLocalBounds = _scaleStartLocalBounds;
    final MPImageTransformHandleType? handleType = _scaleHandleType;
    final Offset? dragStartCanvasPosition = _dragStartCanvasPosition;
    final Offset? scaleStartScreenHandleCenter = _scaleStartScreenHandleCenter;

    if ((startImage == null) ||
        (startLocalBounds == null) ||
        (handleType == null) ||
        (dragStartCanvasPosition == null) ||
        (scaleStartScreenHandleCenter == null)) {
      return;
    }

    final bool isCtrlOrMetaPressed =
        MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final Offset dragDeltaOnScreen =
        event.localPosition - scaleStartScreenHandleCenter;
    final Offset rawCanvasPosition =
        dragStartCanvasPosition +
        (th2FileEditController.offsetScreenToCanvas(dragDeltaOnScreen) -
            th2FileEditController.offsetScreenToCanvas(Offset.zero));
    final Offset canvasPosition = isAltPressed
        ? dragStartCanvasPosition +
              ((rawCanvasPosition - dragStartCanvasPosition) *
                  mpCanvasMovementFactor)
        : rawCanvasPosition;
    final Offset anchorLocal = isShiftPressed
        ? startLocalBounds.center
        : _oppositeHandleLocalPoint(startLocalBounds, handleType);
    final Offset handleLocal = _handleLocalPoint(startLocalBounds, handleType);
    final Offset anchorCanvas = startImage.transformLocalPoint(anchorLocal);
    final Offset rotatedDelta = _rotateOffset(
      canvasPosition - anchorCanvas,
      -startImage.rotationDeg.value * mp1DegreeInRad,
    );
    final ({double xScale, double yScale}) resolvedScales = _resolveScales(
      startImage: startImage,
      handleType: handleType,
      anchorLocal: anchorLocal,
      handleLocal: handleLocal,
      rotatedDelta: rotatedDelta,
      preserveAspectRatio: isCtrlOrMetaPressed,
    );
    final Offset translation = _translationForAnchor(
      startImage: startImage,
      anchorLocal: anchorLocal,
      anchorCanvas: anchorCanvas,
      xScale: resolvedScales.xScale,
      yScale: resolvedScales.yScale,
    );
    final THDoublePart previewXX = startImage.xx.copyWith(
      value: translation.dx,
      decimalPositions: th2FileEditController.currentDecimalPositions,
    );
    final THDoublePart previewYY = startImage.yy.copyWith(
      value: translation.dy,
      decimalPositions: th2FileEditController.currentDecimalPositions,
    );
    final THDoublePart previewXScale = startImage.xScale.copyWith(
      value: resolvedScales.xScale,
      decimalPositions: th2FileEditController.currentDecimalPositions,
    );
    final THDoublePart previewYScale = startImage.yScale.copyWith(
      value: resolvedScales.yScale,
      decimalPositions: th2FileEditController.currentDecimalPositions,
    );

    _previewImage = _buildPreviewImage(
      sourceImage: startImage,
      xx: previewXX,
      yy: previewYY,
      xScale: previewXScale,
      yScale: previewYScale,
    );
    _previewOffset = Offset(
      previewXX.value - startImage.xx.value,
      previewYY.value - startImage.yy.value,
    );
    th2FileEditController.triggerImagesRedraw();
  }

  void _commitMovePreview() {
    final Offset deltaOnCanvas = _previewOffset;

    _resetDragPreview(updateRedraw: false);
    th2FileEditController.setMovingMousePosition(null);

    if (deltaOnCanvas == Offset.zero) {
      th2FileEditController.triggerImagesRedraw();

      return;
    }

    final MPMoveImageInsertConfigCommand moveCommand =
        MPCommandFactory.moveImageInsertConfig(
          imageMPID: imageMPID,
          deltaOnCanvas: deltaOnCanvas,
          th2File: th2File,
          decimalPositions: th2FileEditController.currentDecimalPositions,
        );

    th2FileEditController.execute(moveCommand);
  }

  void _commitScalePreview() {
    final MPRuntimeImageInsertConfigMixin? previewImage = _previewImage;
    final MPImageInsertConfig? startImage = _scaleStartImage;

    _resetDragPreview(updateRedraw: false);

    if ((previewImage is! MPImageInsertConfig) || (startImage == null)) {
      th2FileEditController.triggerImagesRedraw();

      return;
    }

    if ((previewImage.xx == startImage.xx) &&
        (previewImage.yy == startImage.yy) &&
        (previewImage.xScale == startImage.xScale) &&
        (previewImage.yScale == startImage.yScale)) {
      th2FileEditController.triggerImagesRedraw();

      return;
    }

    final MPScaleImageInsertConfigCommand scaleCommand =
        MPCommandFactory.scaleImageInsertConfig(
          imageMPID: imageMPID,
          toXX: previewImage.xx,
          toYY: previewImage.yy,
          toXScale: previewImage.xScale,
          toYScale: previewImage.yScale,
          th2File: th2File,
        );

    th2FileEditController.execute(scaleCommand);
  }

  ({double xScale, double yScale}) _resolveScales({
    required MPImageInsertConfig startImage,
    required MPImageTransformHandleType handleType,
    required Offset anchorLocal,
    required Offset handleLocal,
    required Offset rotatedDelta,
    required bool preserveAspectRatio,
  }) {
    final double startXScale = startImage.xScale.value;
    final double startYScale = startImage.yScale.value;
    double xScale = startXScale;
    double yScale = startYScale;

    if (handleType.affectsX) {
      final double denominator = handleLocal.dx - anchorLocal.dx;

      if (denominator.abs() >= mpDoubleComparisonEpsilon) {
        xScale = _avoidZeroScale(rotatedDelta.dx / denominator);
      }
    }

    if (handleType.affectsY) {
      final double denominator = handleLocal.dy - anchorLocal.dy;

      if (denominator.abs() >= mpDoubleComparisonEpsilon) {
        yScale = _avoidZeroScale(rotatedDelta.dy / denominator);
      }
    }

    if (!preserveAspectRatio) {
      return (xScale: xScale, yScale: yScale);
    }

    final double ratio = _resolvedAspectRatio(
      handleType: handleType,
      startXScale: startXScale,
      startYScale: startYScale,
      xScale: xScale,
      yScale: yScale,
    );

    return (
      xScale: _avoidZeroScale(startXScale * ratio),
      yScale: _avoidZeroScale(startYScale * ratio),
    );
  }

  double _resolvedAspectRatio({
    required MPImageTransformHandleType handleType,
    required double startXScale,
    required double startYScale,
    required double xScale,
    required double yScale,
  }) {
    if (handleType.affectsX && !handleType.affectsY) {
      return xScale / startXScale;
    }

    if (handleType.affectsY && !handleType.affectsX) {
      return yScale / startYScale;
    }

    final double xRatio = xScale / startXScale;
    final double yRatio = yScale / startYScale;

    return ((xRatio - 1.0).abs() >= (yRatio - 1.0).abs()) ? xRatio : yRatio;
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
    final Offset scaledPivot = Offset(
      startImage.rotationCenterDx.value * xScale,
      startImage.rotationCenterDy.value * yScale,
    );
    final Offset rotatedDelta = _rotateOffset(
      scaledAnchor - scaledPivot,
      startImage.rotationDeg.value * mp1DegreeInRad,
    );

    return anchorCanvas - rotatedDelta - scaledPivot;
  }

  MPRuntimeImageInsertConfigMixin _buildPreviewImage({
    required MPRuntimeImageInsertConfigMixin sourceImage,
    required THDoublePart xx,
    required THDoublePart yy,
    THDoublePart? xScale,
    THDoublePart? yScale,
  }) {
    late final MPRuntimeImageInsertConfigMixin previewImage;

    switch (sourceImage) {
      case THXTherionImageInsertConfig image:
        previewImage = image.copyWithImageInsertConfigBase(
          xx: xx,
          yy: yy,
          originalLineInTH2File: '',
        );
      case MPImageInsertConfig image:
        previewImage = image.copyWithImageTransform(
          xx: xx,
          yy: yy,
          xScale: xScale,
          yScale: yScale,
          originalLineInTH2File: '',
        );
      default:
        throw ArgumentError(
          'Unsupported image preview type: ${sourceImage.runtimeType}',
        );
    }

    sourceImage.copyRuntimeImageCacheTo(
      targetImage: previewImage,
      th2FileEditController: th2FileEditController,
    );

    return previewImage;
  }

  Offset _oppositeHandleLocalPoint(
    Rect localBounds,
    MPImageTransformHandleType handleType,
  ) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
        return localBounds.bottomRight;
      case MPImageTransformHandleType.topCenter:
        return localBounds.bottomCenter;
      case MPImageTransformHandleType.topRight:
        return localBounds.bottomLeft;
      case MPImageTransformHandleType.centerLeft:
        return localBounds.centerRight;
      case MPImageTransformHandleType.centerRight:
        return localBounds.centerLeft;
      case MPImageTransformHandleType.bottomLeft:
        return localBounds.topRight;
      case MPImageTransformHandleType.bottomCenter:
        return localBounds.topCenter;
      case MPImageTransformHandleType.bottomRight:
        return localBounds.topLeft;
    }
  }

  Offset _handleLocalPoint(
    Rect localBounds,
    MPImageTransformHandleType handleType,
  ) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
        return localBounds.topLeft;
      case MPImageTransformHandleType.topCenter:
        return localBounds.topCenter;
      case MPImageTransformHandleType.topRight:
        return localBounds.topRight;
      case MPImageTransformHandleType.centerLeft:
        return localBounds.centerLeft;
      case MPImageTransformHandleType.centerRight:
        return localBounds.centerRight;
      case MPImageTransformHandleType.bottomLeft:
        return localBounds.bottomLeft;
      case MPImageTransformHandleType.bottomCenter:
        return localBounds.bottomCenter;
      case MPImageTransformHandleType.bottomRight:
        return localBounds.bottomRight;
    }
  }

  Offset _rotateOffset(Offset offset, double angleInRad) {
    final double cosValue = cos(angleInRad);
    final double sinValue = sin(angleInRad);

    return Offset(
      offset.dx * cosValue - offset.dy * sinValue,
      offset.dx * sinValue + offset.dy * cosValue,
    );
  }

  double _avoidZeroScale(double scale) {
    if (scale.abs() >= mpDoubleMinNormalized) {
      return scale;
    }

    return (scale.isNegative ? -1.0 : 1.0) * mpDoubleMinNormalized;
  }

  void _resetDragPreview({bool updateRedraw = true}) {
    _dragMode = _MPImageTransformDragMode.none;
    _dragStartCanvasPosition = null;
    _dragStartImageTopLeft = null;
    _scaleStartScreenHandleCenter = null;
    _previewImage = null;
    _previewOffset = Offset.zero;
    _scaleStartImage = null;
    _scaleStartLocalBounds = null;
    _scaleHandleType = null;

    if (updateRedraw) {
      th2FileEditController.triggerImagesRedraw();
    }

    setCursor();
  }

  MouseCursor? _cursorForScaleHandle(MPImageTransformHandleType? handleType) {
    switch (handleType) {
      case MPImageTransformHandleType.topLeft:
      case MPImageTransformHandleType.bottomRight:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case MPImageTransformHandleType.topRight:
      case MPImageTransformHandleType.bottomLeft:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case MPImageTransformHandleType.topCenter:
      case MPImageTransformHandleType.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case MPImageTransformHandleType.centerLeft:
      case MPImageTransformHandleType.centerRight:
        return SystemMouseCursors.resizeLeftRight;
      case null:
        return null;
    }
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.imageMoveScale;
}
