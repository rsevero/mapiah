// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Draws a Therion line representation along an already built geometry path.
abstract class MPLineDecorator {
  const MPLineDecorator();

  /// Returns the geometry path that should be passed to [decorate].
  Path buildBasePath({required Path path, required List<Offset> vertices}) {
    return path;
  }

  /// [mpID] seeds procedural randomness (e.g. `l_waterflow_permanent_UIS`'s
  /// meander noise) so a given element's decoration is stable across
  /// repaints; defaults to 0 for decorators that don't need it.
  void decorate({
    required Canvas canvas,
    required Path path,
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  });
}
