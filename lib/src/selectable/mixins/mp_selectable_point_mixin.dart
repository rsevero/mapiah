// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_selectable.dart';

mixin MPSelectablePointMixin on MPSelectable {
  Rect _calculatePointBoundingBox(
    Offset position, {
    double? halfLength,
  }) {
    final double resolvedHalfLength =
        halfLength ?? th2fileEditController.selectionToleranceOnCanvas;

    return MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: resolvedHalfLength,
      halfWidth: resolvedHalfLength,
    );
  }

  @override
  bool contains(Offset point) {
    return boundingBox.contains(point);
  }
}
