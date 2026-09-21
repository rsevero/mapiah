// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/therion_uis/mp_small_t_line_decorator.dart';

/// Ports `l_ceilingstep_SKBB`, whose `mark_(P,t,0.2u)` tick offset is the
/// opposite sign of `l_ceilingstep_UIS`'s `mark_(P,t,-0.2u)`.
class MPCeilingStepSKBBLineDecorator extends MPSmallTLineDecorator {
  const MPCeilingStepSKBBLineDecorator()
    : super(reverseOrigin: false, sideSign: -1.0);
}
