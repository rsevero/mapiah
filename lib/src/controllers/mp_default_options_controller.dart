// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:convert';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

class MPDefaultOptionsController {
  final Map<THElementType, Map<THCommandOptionType, THCommandOption>>
  _defaultOptionsMap = {
    THElementType.point: {},
    THElementType.line: {},
    THElementType.area: {},
  };

  void loadFromSettings() {
    _loadForType(THElementType.point, MPSettingID.Internal_DefaultPointOptions);
    _loadForType(THElementType.line, MPSettingID.Internal_DefaultLineOptions);
    _loadForType(THElementType.area, MPSettingID.Internal_DefaultAreaOptions);
  }

  void _loadForType(THElementType elementType, MPSettingID settingID) {
    final List<String> jsonList = mpLocator.mpSettingsController
        .getStringListWithDefault(settingID);
    final Map<THCommandOptionType, THCommandOption> optionMap = {};

    for (final String json in jsonList) {
      try {
        final THCommandOption option = THCommandOption.fromMap(
          jsonDecode(json) as Map<String, dynamic>,
        );

        optionMap[option.type] = option;
      } catch (_) {
        // Ignore malformed stored entries.
      }
    }

    _defaultOptionsMap[elementType] = optionMap;
  }

  void _saveForType(THElementType elementType, MPSettingID settingID) {
    final List<String> jsonList = _defaultOptionsMap[elementType]!.values
        .map((option) => option.toJson())
        .toList();

    mpLocator.mpSettingsController.setStringList(settingID, jsonList);
  }

  void setDefault(THElementType elementType, THCommandOption option) {
    _defaultOptionsMap[elementType]![option.type] = option;
    _saveForType(elementType, _settingIDFor(elementType));
  }

  void removeDefault(
    THElementType elementType,
    THCommandOptionType optionType,
  ) {
    _defaultOptionsMap[elementType]!.remove(optionType);
    _saveForType(elementType, _settingIDFor(elementType));
  }

  void clearAll() {
    for (final THElementType type in _defaultOptionsMap.keys) {
      _defaultOptionsMap[type] = {};
      mpLocator.mpSettingsController.setStringList(_settingIDFor(type), []);
    }
  }

  void clearForElementType(THElementType elementType) {
    _defaultOptionsMap[elementType] = {};
    mpLocator.mpSettingsController.setStringList(
      _settingIDFor(elementType),
      [],
    );
  }

  bool get hasAnyDefaults =>
      _defaultOptionsMap.values.any((map) => map.isNotEmpty);

  bool hasDefaultsForType(THElementType elementType) =>
      _defaultOptionsMap[elementType]!.isNotEmpty;

  Map<THCommandOptionType, THCommandOption> getDefaultsForElementType(
    THElementType elementType,
  ) => Map.unmodifiable(_defaultOptionsMap[elementType]!);

  List<THCommandOption> getApplicableDefaults({
    required THElementType elementType,
    required String typeString,
  }) {
    final Map<THCommandOptionType, THCommandOption> stored =
        _defaultOptionsMap[elementType]!;

    if (stored.isEmpty) {
      return const [];
    }

    final List<THCommandOptionType> supportedOptions;

    switch (elementType) {
      case THElementType.point:
        final THPointType pointType = THPointType.values.byName(typeString);

        supportedOptions = MPCommandOptionAux.getSupportedOptionsForPointType(
          pointType,
        );
      case THElementType.line:
        final THLineType lineType = THLineType.values.byName(typeString);

        supportedOptions = MPCommandOptionAux.getSupportedOptionsForLineType(
          lineType,
        );
      case THElementType.area:
        final THAreaType areaType = THAreaType.values.byName(typeString);

        supportedOptions = MPCommandOptionAux.getSupportedOptionsForArea(
          areaType,
        );
      default:
        return const [];
    }

    return supportedOptions
        .where(
          (type) =>
              (type != THCommandOptionType.id) && stored.containsKey(type),
        )
        .map((type) => stored[type]!)
        .toList();
  }

  MPSettingID _settingIDFor(THElementType elementType) {
    switch (elementType) {
      case THElementType.point:
        return MPSettingID.Internal_DefaultPointOptions;
      case THElementType.line:
        return MPSettingID.Internal_DefaultLineOptions;
      case THElementType.area:
        return MPSettingID.Internal_DefaultAreaOptions;
      default:
        throw ArgumentError('Unsupported element type: $elementType');
    }
  }
}
