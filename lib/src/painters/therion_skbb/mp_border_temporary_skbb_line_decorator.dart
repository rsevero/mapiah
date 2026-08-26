// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/therion_skbb/mp_evenly_dashed_skbb_line_decorator.dart';

/// Ports `l_border_temporary_SKBB`: `draw Path dashed evenly scaled
/// optical_zoom` — byte-for-byte the same evenly-dashed `PenC` stroke as
/// `l_chimney_SKBB` (`MPChimneySKBBLineDecorator`), just under a
/// different Therion line type.
class MPBorderTemporarySKBBLineDecorator extends MPEvenlyDashedSKBBLineDecorator {
  const MPBorderTemporarySKBBLineDecorator();
}
