// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:material_ui/material_ui.dart';

/// A resolved Therion line decorator plus the color it draws with, keyed by
/// `(MPTherionSymbolSet, THLineType, subtype)` via
/// `getTherionLineDefinition`. Different symbol sets can use different
/// colors for the same [MPLineDecorator], so the color travels with the
/// resolved definition rather than being looked up separately.
class MPTherionLineDefinition {
  const MPTherionLineDefinition({required this.decorator, required this.color});

  final MPLineDecorator decorator;
  final Paint color;
}
