// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_selectable.dart';

class MPSelectablePoint extends MPSelectableElement
    with MPSelectablePointMixin {
  MPSelectablePoint({
    required THPoint point,
    required super.th2fileEditController,
  }) : super(element: point);

  @override
  Rect _calculateBoundingBox() {
    return _calculatePointBoundingBox(
      (element as THPoint).position.coordinates,
    );
  }

  @override
  List<THElement> get selectedElements => List<THPoint>.from([element]);
}
