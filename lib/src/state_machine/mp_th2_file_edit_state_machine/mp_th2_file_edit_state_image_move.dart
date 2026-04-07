// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateImageMove extends MPTH2FileEditStateImageOperation {
  Offset? _dragStartCanvasPosition;
  Offset? _dragStartImageTopLeft;
  Offset _previewOffset = Offset.zero;
  bool _isDraggingImage = false;

  MPTH2FileEditStateImageMove({
    required super.th2FileEditController,
    required super.imageMPID,
  });

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.grab);
  }

  @override
  String get statusBarMessage =>
      mpLocator.appLocalizations.th2FileEditPageImageMoveStatusBarMessage;

  @override
  String get overlayLabel =>
      mpLocator.appLocalizations.th2FileEditPageImageMoveOverlayLabel;

  @override
  Offset get previewOffset => _previewOffset;

  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    final MPRuntimeImageInsertConfigMixin currentImage = imageConfig;
    final Rect? imageBoundingBox = currentImage.getBoundingBox(
      th2FileEditController,
    );

    if (imageBoundingBox == null) {
      _resetDragPreview();

      return;
    }

    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      event.localPosition,
    );

    if (!imageBoundingBox.contains(canvasPosition)) {
      _resetDragPreview();

      return;
    }

    _dragStartCanvasPosition = canvasPosition;
    _dragStartImageTopLeft = imageBoundingBox.topLeft;
    _isDraggingImage = true;
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    if (!_isDraggingImage ||
        (_dragStartCanvasPosition == null) ||
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

    _previewOffset = snappedTopLeft.coordinates - _dragStartImageTopLeft!;
    th2FileEditController.setMovingMousePosition(snappedTopLeft.coordinates);
    th2FileEditController.triggerImagesRedraw();
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    if (!_isDraggingImage) {
      _resetDragPreview();

      return;
    }

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

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    _resetDragPreview(updateRedraw: false);
    th2FileEditController.setMovingMousePosition(null);
    super.onStateExit(nextState);
  }

  void _resetDragPreview({bool updateRedraw = true}) {
    _dragStartCanvasPosition = null;
    _dragStartImageTopLeft = null;
    _previewOffset = Offset.zero;
    _isDraggingImage = false;

    if (updateRedraw) {
      th2FileEditController.triggerImagesRedraw();
    }
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.imageMove;
}
