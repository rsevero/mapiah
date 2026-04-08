// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

enum _MPImageRotationDragMode { none, movePivot, rotate }

class MPTH2FileEditStateImageRotate extends MPTH2FileEditStateImageOperation {
  _MPImageRotationDragMode _dragMode = _MPImageRotationDragMode.none;
  MPImageInsertConfig? _startImage;
  MPImageInsertConfig? _previewImage;
  MPImageRotationHandleType? _rotationHandleType;
  Offset? _dragStartCanvasPosition;

  MPTH2FileEditStateImageRotate({
    required super.th2FileEditController,
    required super.imageMPID,
  });

  @override
  String get overlayLabel =>
      mpLocator.appLocalizations.th2FileEditPageImageRotateOverlayLabel;

  @override
  String get statusBarMessage =>
      mpLocator.appLocalizations.th2FileEditPageImageRotateStatusBarMessage;

  @override
  MPRuntimeImageInsertConfigMixin? get renderedImageConfig => _previewImage;

  @override
  void setCursor() {
    if (_dragMode == _MPImageRotationDragMode.movePivot) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.move);

      return;
    }

    if (_dragMode == _MPImageRotationDragMode.rotate) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);

      return;
    }

    final MPImageRotationGeometry? geometry = MPImageRotationGeometry.forImage(
      th2FileEditController: th2FileEditController,
      image: imageConfig,
    );

    if (geometry == null) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);

      return;
    }

    if (geometry.hitTestHandle(th2FileEditController.mousePosition) != null) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.grab);

      return;
    }

    if (geometry.hitTestPivot(th2FileEditController.mousePosition)) {
      th2FileEditController.setCanvasCursor(
        _isPivotDraggable(imageConfig)
            ? SystemMouseCursors.move
            : SystemMouseCursors.forbidden,
      );

      return;
    }

    final MPImageTransformGeometry? transformGeometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: imageConfig,
        );

    if ((transformGeometry != null) &&
        transformGeometry.containsCanvasPosition(
          th2FileEditController.offsetScreenToCanvas(
            th2FileEditController.mousePosition,
          ),
        )) {
      th2FileEditController.setCanvasCursor(SystemMouseCursors.click);
      return;
    }

    th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);
  }

  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final MPImageInsertConfig image = th2FileEditController
        .moveScaleRotateElementController
        .prepareImageForMPOnlyTransformActions(imageMPID);
    final MPImageRotationGeometry? geometry = MPImageRotationGeometry.forImage(
      th2FileEditController: th2FileEditController,
      image: image,
    );

    if (geometry == null) {
      _resetPreview();

      return;
    }

    if (geometry.hitTestPivot(event.localPosition) &&
        _isPivotDraggable(image)) {
      _dragMode = _MPImageRotationDragMode.movePivot;
      _startImage = image;
      _dragStartCanvasPosition = geometry.canvasPivotCenter;
      setCursor();

      return;
    }

    final MPImageRotationHandleType? handleType = geometry.hitTestHandle(
      event.localPosition,
    );

    if (handleType == null) {
      _resetPreview();

      return;
    }

    _dragMode = _MPImageRotationDragMode.rotate;
    _startImage = image;
    _rotationHandleType = handleType;
    _dragStartCanvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    setCursor();
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    switch (_dragMode) {
      case _MPImageRotationDragMode.none:
        return;
      case _MPImageRotationDragMode.movePivot:
        _updatePivotPreview(event);
      case _MPImageRotationDragMode.rotate:
        _updateRotationPreview(event);
    }
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    switch (_dragMode) {
      case _MPImageRotationDragMode.none:
        _resetPreview();
      case _MPImageRotationDragMode.movePivot:
      case _MPImageRotationDragMode.rotate:
        _commitPreview();
    }
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    final MPImageRotationGeometry? geometry = MPImageRotationGeometry.forImage(
      th2FileEditController: th2FileEditController,
      image: imageConfig,
    );
    final MPImageTransformGeometry? transformGeometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: imageConfig,
        );

    if ((geometry == null) || (transformGeometry == null)) {
      return Future.value();
    }

    if ((geometry.hitTestHandle(event.localPosition) != null) ||
        geometry.hitTestPivot(event.localPosition)) {
      return Future.value();
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );

    if (!transformGeometry.containsCanvasPosition(canvasPosition)) {
      return Future.value();
    }

    th2FileEditController.moveScaleRotateElementController
        .prepareImageMoveState(imageMPID);

    return Future.value();
  }

  @override
  bool shouldKeepOverlayOpenOnCanvasPointerUp(
    PointerUpEvent event, {
    required bool wasDragging,
  }) {
    if (wasDragging) {
      return true;
    }

    final MPImageRotationGeometry? geometry = MPImageRotationGeometry.forImage(
      th2FileEditController: th2FileEditController,
      image: imageConfig,
    );

    if ((geometry != null) &&
        ((geometry.hitTestHandle(event.localPosition) != null) ||
            geometry.hitTestPivot(event.localPosition))) {
      return true;
    }

    return super.shouldKeepOverlayOpenOnCanvasPointerUp(
      event,
      wasDragging: wasDragging,
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    _resetPreview(updateRedraw: false);
    super.onStateExit(nextState);
  }

  void _updateRotationPreview(PointerMoveEvent event) {
    final MPImageInsertConfig? startImage = _startImage;
    final Offset? dragStartCanvasPosition = _dragStartCanvasPosition;
    final MPImageRotationHandleType? handleType = _rotationHandleType;

    if ((startImage == null) ||
        (dragStartCanvasPosition == null) ||
        (handleType == null)) {
      return;
    }

    final Offset pivotCanvas = startImage.transformLocalPoint(
      Offset(
        startImage.rotationCenterDx.value,
        startImage.rotationCenterDy.value,
      ),
    );
    final Offset currentCanvasPosition = th2FileEditController
        .offsetScreenToCanvas(event.localPosition);
    final Offset startVector = dragStartCanvasPosition - pivotCanvas;
    final Offset currentVector = currentCanvasPosition - pivotCanvas;

    if ((startVector.distance < mpDoubleComparisonEpsilon) ||
        (currentVector.distance < mpDoubleComparisonEpsilon)) {
      return;
    }

    final double startAngleInRad = atan2(startVector.dy, startVector.dx);
    final double currentAngleInRad = atan2(currentVector.dy, currentVector.dx);
    final double angleDeltaInDeg =
        (currentAngleInRad - startAngleInRad) / mp1DegreeInRad;
    double targetRotationDeg = startImage.rotationDeg.value + angleDeltaInDeg;

    if (MPInteractionAux.isCtrlPressed() || MPInteractionAux.isMetaPressed()) {
      final double snapAngle = mpLocator.mpSettingsController
          .getDoubleWithDefault(MPSettingID.TH2Edit_RotationSnapAngle);

      if (snapAngle.abs() >= mpDoubleComparisonEpsilon) {
        targetRotationDeg = (targetRotationDeg / snapAngle).round() * snapAngle;
      }
    }

    THDoublePart previewXX = startImage.xx;
    THDoublePart previewYY = startImage.yy;

    if (MPInteractionAux.isShiftPressed()) {
      final MPImageRotationGeometry? geometry =
          MPImageRotationGeometry.forImage(
            th2FileEditController: th2FileEditController,
            image: startImage,
          );

      if (geometry != null) {
        final Offset anchorLocal = _oppositeCornerLocalPoint(
          geometry.localBounds,
          handleType,
        );
        final Offset anchorCanvas = startImage.transformLocalPoint(anchorLocal);
        final Offset translation = _translationForAnchorAfterRotation(
          startImage: startImage,
          anchorLocal: anchorLocal,
          anchorCanvas: anchorCanvas,
          rotationDeg: targetRotationDeg,
        );

        previewXX = startImage.xx.copyWith(
          value: translation.dx,
          decimalPositions: th2FileEditController.currentDecimalPositions,
        );
        previewYY = startImage.yy.copyWith(
          value: translation.dy,
          decimalPositions: th2FileEditController.currentDecimalPositions,
        );
      }
    }

    _previewImage = _copyImage(
      startImage: startImage,
      xx: previewXX,
      yy: previewYY,
      rotationCenterDx: startImage.rotationCenterDx,
      rotationCenterDy: startImage.rotationCenterDy,
      rotationDeg: startImage.rotationDeg.copyWith(
        value: targetRotationDeg,
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
    );
    th2FileEditController.triggerImagesRedraw();
  }

  void _updatePivotPreview(PointerMoveEvent event) {
    final MPImageInsertConfig? startImage = _startImage;

    if (startImage == null) {
      return;
    }

    final Offset targetPivotCanvas = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );
    final Offset startTranslation = Offset(
      startImage.xx.value,
      startImage.yy.value,
    );
    final double angleInRad = startImage.rotationDeg.value * mp1DegreeInRad;
    final Offset scaledPivot = startImage.scaledRotationCenter;
    final Offset rotatedScaledPivot = _rotateOffset(scaledPivot, angleInRad);
    final Offset rotatedScaledTargetPivot = _rotateOffset(
      targetPivotCanvas - startTranslation - scaledPivot + rotatedScaledPivot,
      -angleInRad,
    );
    final double resolvedXScale = _avoidZeroScale(startImage.xScale.value);
    final double resolvedYScale = _avoidZeroScale(startImage.yScale.value);
    final Offset targetLocalPivot = Offset(
      rotatedScaledTargetPivot.dx / resolvedXScale,
      rotatedScaledTargetPivot.dy / resolvedYScale,
    );
    final Offset translation = _translationForPreservedImageAfterPivotMove(
      startImage: startImage,
      targetLocalPivot: targetLocalPivot,
    );

    _previewImage = _copyImage(
      startImage: startImage,
      xx: startImage.xx.copyWith(
        value: translation.dx,
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
      yy: startImage.yy.copyWith(
        value: translation.dy,
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
      rotationCenterDx: startImage.rotationCenterDx.copyWith(
        value: targetLocalPivot.dx,
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
      rotationCenterDy: startImage.rotationCenterDy.copyWith(
        value: targetLocalPivot.dy,
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
      rotationDeg: startImage.rotationDeg,
    );
    th2FileEditController.triggerImagesRedraw();
  }

  void _commitPreview() {
    final MPImageInsertConfig? startImage = _startImage;
    final MPImageInsertConfig? previewImage = _previewImage;

    _resetPreview(updateRedraw: false);

    if ((startImage == null) || (previewImage == null)) {
      th2FileEditController.triggerImagesRedraw();

      return;
    }

    if ((startImage.xx == previewImage.xx) &&
        (startImage.yy == previewImage.yy) &&
        (startImage.rotationCenterDx == previewImage.rotationCenterDx) &&
        (startImage.rotationCenterDy == previewImage.rotationCenterDy) &&
        (startImage.rotationDeg == previewImage.rotationDeg)) {
      th2FileEditController.triggerImagesRedraw();

      return;
    }

    final MPRotateImageInsertConfigCommand rotateCommand =
        MPCommandFactory.rotateImageInsertConfig(
          imageMPID: imageMPID,
          toXX: previewImage.xx,
          toYY: previewImage.yy,
          toRotationCenterDx: previewImage.rotationCenterDx,
          toRotationCenterDy: previewImage.rotationCenterDy,
          toRotationDeg: previewImage.rotationDeg,
          th2File: th2File,
        );

    th2FileEditController.execute(rotateCommand);
  }

  MPImageInsertConfig _copyImage({
    required MPImageInsertConfig startImage,
    required THDoublePart xx,
    required THDoublePart yy,
    required THDoublePart rotationCenterDx,
    required THDoublePart rotationCenterDy,
    required THDoublePart rotationDeg,
  }) {
    late final MPImageInsertConfig previewImage;

    switch (startImage) {
      case MPXVIImageInsertConfig image:
        previewImage = image.copyWith(
          xx: xx,
          yy: yy,
          rotationCenterDx: rotationCenterDx,
          rotationCenterDy: rotationCenterDy,
          rotationDeg: rotationDeg,
          originalLineInTH2File: '',
        );
      case MPRasterImageInsertConfig image:
        previewImage = image.copyWith(
          xx: xx,
          yy: yy,
          rotationCenterDx: rotationCenterDx,
          rotationCenterDy: rotationCenterDy,
          rotationDeg: rotationDeg,
          originalLineInTH2File: '',
        );
    }

    startImage.copyRuntimeImageCacheTo(
      targetImage: previewImage,
      th2FileEditController: th2FileEditController,
    );

    return previewImage;
  }

  Offset _translationForAnchorAfterRotation({
    required MPImageInsertConfig startImage,
    required Offset anchorLocal,
    required Offset anchorCanvas,
    required double rotationDeg,
  }) {
    final Offset scaledAnchor = Offset(
      anchorLocal.dx * startImage.xScale.value,
      anchorLocal.dy * startImage.yScale.value,
    );
    final Offset scaledPivot = startImage.scaledRotationCenter;
    final Offset rotatedDelta = _rotateOffset(
      scaledAnchor - scaledPivot,
      rotationDeg * mp1DegreeInRad,
    );

    return anchorCanvas - scaledPivot - rotatedDelta;
  }

  Offset _translationForPreservedImageAfterPivotMove({
    required MPImageInsertConfig startImage,
    required Offset targetLocalPivot,
  }) {
    final Offset currentScaledPivot = startImage.scaledRotationCenter;
    final Offset targetScaledPivot = Offset(
      targetLocalPivot.dx * startImage.xScale.value,
      targetLocalPivot.dy * startImage.yScale.value,
    );
    final double angleInRad = startImage.rotationDeg.value * mp1DegreeInRad;
    final Offset rotatedCurrentScaledPivot = _rotateOffset(
      currentScaledPivot,
      angleInRad,
    );
    final Offset rotatedTargetScaledPivot = _rotateOffset(
      targetScaledPivot,
      angleInRad,
    );

    return Offset(startImage.xx.value, startImage.yy.value) +
        currentScaledPivot -
        rotatedCurrentScaledPivot -
        targetScaledPivot +
        rotatedTargetScaledPivot;
  }

  Offset _oppositeCornerLocalPoint(
    Rect localBounds,
    MPImageRotationHandleType handleType,
  ) {
    switch (handleType) {
      case MPImageRotationHandleType.topLeft:
        return localBounds.bottomRight;
      case MPImageRotationHandleType.topRight:
        return localBounds.bottomLeft;
      case MPImageRotationHandleType.bottomLeft:
        return localBounds.topRight;
      case MPImageRotationHandleType.bottomRight:
        return localBounds.topLeft;
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

  bool _isPivotDraggable(MPRuntimeImageInsertConfigMixin runtimeImage) {
    final MPRuntimeXVIImageInsertConfigMixin? xviImage =
        runtimeImage.asXVIImage;

    if (xviImage == null) {
      return true;
    }

    return xviImage.xviRoot.isEmpty;
  }

  void _resetPreview({bool updateRedraw = true}) {
    _dragMode = _MPImageRotationDragMode.none;
    _startImage = null;
    _previewImage = null;
    _rotationHandleType = null;
    _dragStartCanvasPosition = null;

    if (updateRedraw) {
      th2FileEditController.triggerImagesRedraw();
    }

    setCursor();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.imageRotate;
}
