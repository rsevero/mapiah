// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_selectable.dart';

class MPSelectableEndControlPoint extends MPSelectable
    with MPSelectablePointMixin {
  final Offset position;
  final MPEndControlPointType type;

  MPSelectableEndControlPoint({
    required THLineSegment lineSegment,
    required super.th2fileEditController,
    required this.position,
    required this.type,
  }) : super(element: lineSegment);

  @override
  Rect _calculateBoundingBox() {
    final double halfLength =
        (type == MPEndControlPointType.controlPoint1) ||
            (type == MPEndControlPointType.controlPoint2)
        ? th2fileEditController.selectionToleranceOnCanvas *
              mpControlPointSelectionToleranceFactor
        : th2fileEditController.selectionToleranceOnCanvas;

    return _calculatePointBoundingBox(position, halfLength: halfLength);
  }

  THLineSegment get lineSegment => element as THLineSegment;
}
