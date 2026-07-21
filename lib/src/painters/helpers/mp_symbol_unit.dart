// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';

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
    final double symbolUnitOnScreen = mpLocator.mpSettingsController
        .getDoubleWithDefault(MPSettingID.TH2Edit_SymbolUnit);

    return symbolUnitOnScreen / (canvasScale * devicePixelRatio);
  }
}
