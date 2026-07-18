// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

import 'package:mapiah/src/elements/types/th_area_type.dart';

/// Owns generated area pattern tiles and releases replaced images.
class MPPatternCache {
  final Map<THAreaType, ui.Image> _images = <THAreaType, ui.Image>{};

  ui.Image? imageFor(THAreaType areaType) => _images[areaType];

  bool contains(THAreaType areaType) => _images.containsKey(areaType);

  void store(THAreaType areaType, ui.Image image) {
    final ui.Image? oldImage = _images[areaType];

    if (identical(oldImage, image)) {
      return;
    }

    oldImage?.dispose();
    _images[areaType] = image;
  }

  void remove(THAreaType areaType) {
    _images.remove(areaType)?.dispose();
  }

  void clear() {
    for (final ui.Image image in _images.values) {
      image.dispose();
    }

    _images.clear();
  }
}
