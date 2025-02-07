import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mobx/mobx.dart';
import 'package:toml/toml.dart';

part 'mp_settings_controller.g.dart';

class MPSettingsController = MPSettingsControllerBase
    with _$MPSettingsController;

abstract class MPSettingsControllerBase with Store {
  bool _readingConfigFile = false;

  @readonly
  String _localeID = thDefaultLocaleID;

  @readonly
  Locale _locale = Locale(thEnglishLocaleID);

  @readonly
  double _selectionTolerance = thDefaultSelectionTolerance;

  @readonly
  double _pointRadius = thDefaultPointRadius;

  @readonly
  double _lineThickness = thDefaultLineThickness;

  THSettingsControllerBase() {
    _initialize();
  }

  void _initialize() {
    _readConfigFile();
  }

  Future<void> _readConfigFile() async {
    try {
      _readingConfigFile = true;

      final Directory configDirectory = await MPDirectoryAux.config();
      final File file = File(configDirectory.path + thMainConfigFilename);
      final String contents = await file.readAsString();
      final Map<String, dynamic> config = TomlDocument.parse(contents).toMap();

      final Map<String, dynamic> mainConfig =
          config.containsKey(thMainConfigSection)
              ? config[thMainConfigSection] as Map<String, dynamic>
              : {};
      final Map<String, dynamic> fileEditConfig =
          config.containsKey(thFileEditConfigSection)
              ? config[thFileEditConfigSection] as Map<String, dynamic>
              : {};

      String localeID = thDefaultLocaleID;
      double selectionTolerance = thDefaultSelectionTolerance;
      double pointRadius = thDefaultPointRadius;
      double lineThickness = thDefaultLineThickness;

      if (mainConfig.isNotEmpty) {
        if (mainConfig.containsKey(thMainConfigLocale)) {
          localeID = mainConfig[thMainConfigLocale];
        }
      }

      if (fileEditConfig.isNotEmpty) {
        if (fileEditConfig.containsKey(thFileEditConfigSelectionTolerance)) {
          selectionTolerance =
              fileEditConfig[thFileEditConfigSelectionTolerance];
        }
        if (fileEditConfig.containsKey(thFileEditConfigPointRadius)) {
          pointRadius = fileEditConfig[thFileEditConfigPointRadius];
        }
        if (fileEditConfig.containsKey(thFileEditConfigLineThickness)) {
          lineThickness = fileEditConfig[thFileEditConfigLineThickness];
        }
      }

      setLocaleID(localeID);
      setSelectionTolerance(selectionTolerance);
      setPointRadius(pointRadius);
      setLineThickness(lineThickness);

      _readingConfigFile = false;
    } catch (e) {
      mpLocator.mpLog.e('Error reading config file.', error: e);
    }
  }

  String _getSystemLocaleID() {
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    return systemLocale.languageCode;
  }

  @action
  void setLocaleID(String localeID) {
    final bool saveConfigFile = _localeID != localeID;

    _localeID = localeID;
    if (localeID == thDefaultLocaleID) {
      localeID = _getSystemLocaleID();
    }
    _locale = Locale(localeID);

    if (saveConfigFile) {
      _saveConfigFile();
    }
  }

  @action
  void setSelectionTolerance(double selectionTolerance) {
    final bool saveConfigFile = _selectionTolerance != selectionTolerance;

    _selectionTolerance = selectionTolerance;

    if (saveConfigFile) {
      _saveConfigFile();
    }
  }

  @action
  void setPointRadius(double pointRadius) {
    final bool saveConfigFile = _pointRadius != pointRadius;

    _pointRadius = pointRadius;

    if (saveConfigFile) {
      _saveConfigFile();
    }
  }

  @action
  void setLineThickness(double lineThickness) {
    final bool saveConfigFile = _lineThickness != lineThickness;

    _lineThickness = lineThickness;

    if (saveConfigFile) {
      _saveConfigFile();
    }
  }

  void _saveConfigFile() async {
    if (_readingConfigFile) {
      return;
    }

    try {
      final Map<String, dynamic> config = {
        thMainConfigSection: {thMainConfigLocale: _localeID},
        thFileEditConfigSection: {
          thFileEditConfigLineThickness: _lineThickness,
          thFileEditConfigPointRadius: _pointRadius,
          thFileEditConfigSelectionTolerance: _selectionTolerance,
        },
      };
      final String contents = TomlDocument.fromMap(config).toString();

      final Directory configDirectory = await MPDirectoryAux.config();
      final File file = File(configDirectory.path + thMainConfigFilename);

      await file.writeAsString(contents);
    } catch (e) {
      mpLocator.mpLog.e('Error saving config file.', error: e);
    }
  }
}
