// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/therion_uis/mp_ceiling_meander_line_decorator.dart';

/// Ports `l_ceilingmeander_SKBB`, whose radial ticks span `0.1u..0.2u` from
/// the line instead of `l_ceilingmeander_UIS`'s `0.2u..0.3u`.
class MPCeilingMeanderSKBBLineDecorator extends MPCeilingMeanderLineDecorator {
  const MPCeilingMeanderSKBBLineDecorator() : super(nearUnits: 0.1);
}
