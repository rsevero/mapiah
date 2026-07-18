// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/constants/mp_constants.dart';

/// Converts the Therion symbol unit from logical pixels to canvas units.
class MPSymbolUnit {
  final double canvasScale;
  final double devicePixelRatio;

  const MPSymbolUnit({
    required this.canvasScale,
    required this.devicePixelRatio,
  }) : assert(canvasScale > 0),
       assert(devicePixelRatio > 0);

  /// One Therion-compatible symbol unit expressed in canvas coordinates.
  double get canvasValue {
    return mpSymbolUnitOnScreen / (canvasScale * devicePixelRatio);
  }
}
