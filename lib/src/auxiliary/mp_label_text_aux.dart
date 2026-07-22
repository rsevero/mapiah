// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/controllers/auxiliary/mp_label_data.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

/// Resolves the text content of Phase 2.5's label-mode point types
/// (`docs/plans/2026-07-15-therion-symbol-rendering-roadmap.md`, Phase 2.5)
/// from their `THPoint` options. Returns `null` for any point type not
/// handled by this phase, so callers can fall through to the placeholder
/// shape rendering.
///
/// `<br>` is the only Therion text tag parsed here (split into separate
/// lines); every other formatting tag (`<center>`, `<size:N>`, font
/// switches, `<rtl>`, `<lang:XX>`, `<thsp>`) is left as literal text.
abstract final class MPLabelTextAux {
  static const String _lineBreakTag = '<br>';

  static MPLabelData? resolve(THPoint point) {
    switch (point.pointType) {
      case THPointType.altitude:
        return _fromAltitude(point);
      case THPointType.date:
        return _fromDate(point);
      case THPointType.dimensions:
        return _fromDimensions(point);
      case THPointType.height:
        return _fromHeight(point);
      case THPointType.label:
      case THPointType.remark:
        return _fromText(point);
      case THPointType.passageHeight:
        return _fromPassageHeight(point);
      default:
        return null;
    }
  }

  static MPLabelData? _fromText(THPoint point) {
    if (!point.hasOption(THCommandOptionType.text)) {
      return null;
    }

    final THTextCommandOption option =
        point.getOption(THCommandOptionType.text) as THTextCommandOption;
    final List<String> lines = option.text.content
        .split(_lineBreakTag)
        .map((String line) => line.trim())
        .toList();

    return MPLabelData.plain(lines);
  }

  static MPLabelData? _fromDate(THPoint point) {
    if (!point.hasOption(THCommandOptionType.dateValue)) {
      return null;
    }

    final THDateValueCommandOption option =
        point.getOption(THCommandOptionType.dateValue)
            as THDateValueCommandOption;

    return MPLabelData.plain([option.datetime.toString()]);
  }

  static MPLabelData? _fromAltitude(THPoint point) {
    if (!point.hasOption(THCommandOptionType.altitudeValue)) {
      return null;
    }

    final THAltitudeValueCommandOption option =
        point.getOption(THCommandOptionType.altitudeValue)
            as THAltitudeValueCommandOption;

    if (option.isNan) {
      return const MPLabelData.plain(['▲ —']);
    }

    String asString = option.length.toString();

    if (option.isFix) {
      asString = 'fix $asString';
    }

    if (option.unitSet) {
      asString += ' ${option.unit}';
    }

    return MPLabelData.plain(['▲ $asString']);
  }

  static MPLabelData? _fromHeight(THPoint point) {
    if (!point.hasOption(THCommandOptionType.pointHeightValue)) {
      return null;
    }

    final THPointHeightValueCommandOption option =
        point.getOption(THCommandOptionType.pointHeightValue)
            as THPointHeightValueCommandOption;

    String asString;

    switch (option.mode) {
      case THPointHeightValueMode.presumedPlus:
        return const MPLabelData.plain(['+?']);
      case THPointHeightValueMode.presumedMinus:
        return const MPLabelData.plain(['-?']);
      case THPointHeightValueMode.chimney:
        asString = '+${option.length}';
      case THPointHeightValueMode.pit:
        asString = '-${option.length}';
      case THPointHeightValueMode.step:
        asString = option.length.toString();
    }

    if (option.isPresumed) {
      asString += '?';
    }

    if (option.unitSet) {
      asString += ' ${option.unit}';
    }

    return MPLabelData.plain([asString]);
  }

  static MPLabelData? _fromPassageHeight(THPoint point) {
    if (!point.hasOption(THCommandOptionType.passageHeightValue)) {
      return null;
    }

    final THPassageHeightValueCommandOption option =
        point.getOption(THCommandOptionType.passageHeightValue)
            as THPassageHeightValueCommandOption;
    final String unit = option.unit.toString();

    switch (option.mode) {
      case THPassageHeightModes.height:
        return MPLabelData.passageHeight(
          mode: MPLabelMode.passageHeightPos,
          plusText: '${option.plusNumber} $unit',
        );
      case THPassageHeightModes.depth:
        return MPLabelData.passageHeight(
          mode: MPLabelMode.passageHeightNeg,
          minusText: '${option.minusNumber} $unit',
        );
      case THPassageHeightModes.distanceToCeilingAndDistanceToFloor:
        return MPLabelData.passageHeight(
          mode: MPLabelMode.passageHeightPosNeg,
          plusText: '${option.plusNumber} $unit',
          minusText: '${option.minusNumber} $unit',
        );
      case THPassageHeightModes.distanceBetweenFloorAndCeiling:
        return MPLabelData.passageHeight(
          mode: MPLabelMode.passageHeightUnsigned,
          plusText: '${option.plusNumber} $unit',
        );
    }
  }

  static MPLabelData? _fromDimensions(THPoint point) {
    if (!point.hasOption(THCommandOptionType.dimensionsValue)) {
      return null;
    }

    final THDimensionsValueCommandOption option =
        point.getOption(THCommandOptionType.dimensionsValue)
            as THDimensionsValueCommandOption;

    return MPLabelData.plain([
      '${option.above} / ${option.below} ${option.unit}',
    ]);
  }

}
