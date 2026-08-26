// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

typedef MPPatternCacheKey = (MPTherionSymbolSet?, THAreaType);

/// Owns generated area pattern tiles and releases replaced images. Keyed by
/// symbol set as well as area type, because the same [THAreaType] can
/// produce a different tile under different Therion symbol sets. A null
/// set is `therionDefault`'s cache key, kept distinct from every real set.
class MPPatternCache {
  final Map<MPPatternCacheKey, ui.Image> _images = <MPPatternCacheKey, ui.Image>{};

  ui.Image? imageFor(MPTherionSymbolSet? set, THAreaType areaType) =>
      _images[(set, areaType)];

  bool contains(MPTherionSymbolSet? set, THAreaType areaType) =>
      _images.containsKey((set, areaType));

  void store(MPTherionSymbolSet? set, THAreaType areaType, ui.Image image) {
    final MPPatternCacheKey key = (set, areaType);
    final ui.Image? oldImage = _images[key];

    if (identical(oldImage, image)) {
      return;
    }

    oldImage?.dispose();
    _images[key] = image;
  }

  void remove(MPTherionSymbolSet? set, THAreaType areaType) {
    _images.remove((set, areaType))?.dispose();
  }

  void clear() {
    for (final ui.Image image in _images.values) {
      image.dispose();
    }

    _images.clear();
  }
}
