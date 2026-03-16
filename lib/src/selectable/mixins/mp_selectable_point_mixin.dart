// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_selectable.dart';

mixin MPSelectablePointMixin on MPSelectable {
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
