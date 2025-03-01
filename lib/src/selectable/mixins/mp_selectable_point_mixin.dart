part of '../mp_selectable.dart';

mixin MPSeleactablePointMixin on MPSelectable {
  Rect _calculatePointBoundingBox(Offset position) {
    return MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: th2fileEditController.selectionToleranceOnCanvas,
      halfWidth: th2fileEditController.selectionToleranceOnCanvas,
    );
  }

  @override
  bool contains(Offset point) {
    return boundingBox.contains(point);
  }
}
