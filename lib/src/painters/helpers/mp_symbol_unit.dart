// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';

/// Converts the Therion symbol unit from logical pixels to canvas units.
class MPSymbolUnit {
  final double canvasScale;
  final double devicePixelRatio;

  /// The active scrap's `-scale` option, in [scrapLengthUnitType] real-world
  /// units per drawing (`.th2` file coordinate) unit — Mapiah's own
  /// `TH2FileEditController.scrapLengthUnitsPerPoint`/`scrapLengthUnitType`
  /// (`1.0`/meter with no `-scale` option, matching Therion's own
  /// unscaled-coordinates default).
  final double scrapLengthUnitsPerPoint;
  final THLengthUnitType scrapLengthUnitType;

  const MPSymbolUnit({
    required this.canvasScale,
    required this.devicePixelRatio,
    required this.scrapLengthUnitsPerPoint,
    required this.scrapLengthUnitType,
  }) : assert(canvasScale > 0),
       assert(devicePixelRatio > 0),
       assert(scrapLengthUnitsPerPoint > 0);

  /// One Therion-compatible symbol unit expressed in canvas coordinates.
  double get canvasValue {
    final double symbolUnitOnScreen = mpLocator.mpSettingsController
        .getDoubleWithDefault(MPSettingID.TH2Edit_SymbolUnit);

    return symbolUnitOnScreen / (canvasScale * devicePixelRatio);
  }

  /// The drawing-coordinate length of one real-world meter at the active
  /// scrap's declared scale — `p_handrail_SKBB`'s `tmph` (`1/Scale*72/2.54`,
  /// its own comment reads "1 m height"), re-derived from Mapiah's
  /// `-scale`-option plumbing instead of Therion's `Scale`/paper-point
  /// globals. Independent of [canvasValue]: real Therion's symbol unit `u`
  /// is a fixed physical print size unrelated to a scrap's survey scale, so
  /// this and `u` intentionally live in different scales of "bigness".
  double get oneMeterInLocalUnits {
    final double oneMeterInScrapUnits = (scrapLengthUnitType ==
            THLengthUnitType.meter)
        ? 1.0
        : lengthConversionFactors[THLengthUnitType.meter]![scrapLengthUnitType]!;

    return oneMeterInScrapUnits / scrapLengthUnitsPerPoint;
  }
}
