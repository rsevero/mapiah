// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Adds Therion decorations such as ticks or curls to an already built line.
abstract class MPLineDecorator {
  const MPLineDecorator();

  void decorate({
    required Canvas canvas,
    required Path path,
    required THLinePaint linePaint,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
  });
}
