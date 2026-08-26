// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/therion_skbb/mp_evenly_dashed_skbb_line_decorator.dart';

/// Ports `l_border_presumed_SKBB`: `draw Path dashed evenly scaled (0.25 *
/// optical_zoom)` — the same evenly-dashed `PenC` stroke as
/// `l_chimney_SKBB`/`l_border_temporary_SKBB`, but with a quarter their
/// dash pitch, for a denser dashed line.
class MPBorderPresumedSKBBLineDecorator extends MPEvenlyDashedSKBBLineDecorator {
  const MPBorderPresumedSKBBLineDecorator() : super(dashScaleFactor: 0.25);
}
