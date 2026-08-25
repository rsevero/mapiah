// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';

/// Ports `l_ropeladder_SKBB`. As of this Therion source tree, that macro
/// is a stub — `pickup PenD; draw P withcolor red;`, the same
/// "unimplemented"-style red line Therion itself uses for e.g. `l_u`
/// (undefined line symbol) and `l_steps_SKBB`'s invalid-input branches —
/// with no dedicated UIS macro to fall back to instead (`l_ropeladder` is
/// aliased straight to this SKBB definition in `thTrans.mp`). Ported
/// faithfully rather than designed as a real symbol, since a real
/// Therion run currently produces exactly this plain red line too; see
/// [mpTherionLineColors] for the literal-red color paired with this
/// decorator.
class MPRopeLadderSKBBLineDecorator extends MPLineDecorator {
  const MPRopeLadderSKBBLineDecorator();

  @override
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
  }) {
    final double u = symbolUnit.canvasValue;

    canvas.drawPath(
      path,
      Paint.from(color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = mpTherionPenD * u,
    );
  }
}
