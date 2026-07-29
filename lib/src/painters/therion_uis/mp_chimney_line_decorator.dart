// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/therion_uis/mp_small_t_line_decorator.dart';

/// Ports `l_chimney_UIS`, measuring small-T positions from the path end.
class MPChimneyLineDecorator extends MPSmallTLineDecorator {
  const MPChimneyLineDecorator() : super(reverseOrigin: true);
}
