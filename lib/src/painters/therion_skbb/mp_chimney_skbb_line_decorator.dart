// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/therion_skbb/mp_evenly_dashed_skbb_line_decorator.dart';

/// Ports `l_chimney_SKBB`: `thdraw P dashed evenly scaled optical_zoom` —
/// a plain, evenly-dashed `PenC` stroke of the path, with **no** tick
/// marks at all. This is a distinct macro from `l_chimney_UIS` (which
/// delegates to `l_ceilingstep_SKBB`'s tick-marked rendering, still used
/// by [MPChimneyLineDecorator]); confirmed against the SKBB showcase's
/// own legend, whose `chimney` sample is a plain dashed oval with no
/// ticks.
class MPChimneySKBBLineDecorator extends MPEvenlyDashedSKBBLineDecorator {
  const MPChimneySKBBLineDecorator();
}
