import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

part 'mp_settings_controller.g.dart';

class MPSettingsController = MPSettingsControllerBase
    with _$MPSettingsController;

abstract class MPSettingsControllerBase with Store {
  bool _readingConfigFile = false;

  @readonly
  String _localeID = mpDefaultLocaleID;

  @readonly
  Locale _locale = Locale(mpEnglishLocaleID);

  @readonly
  double _selectionTolerance = thDefaultSelectionTolerance;

  @readonly
  double _pointRadius = thDefaultPointRadius;

  @readonly
  double _lineThickness = thDefaultLineThickness;

  MPSettingsControllerBase() {
    _initialize();
  }

  void _initialize() {
    _readConfigFile();
  }

  Future<void> _readConfigFile() async {
    try {
      _readingConfigFile = true;

      final Directory configDirectory = await MPDirectoryAux.config();
      final File file = File(
        p.join(configDirectory.path, mpMainConfigFilename),
      );

      if (!await file.exists()) {
        _readingConfigFile = false;

        return;
      }

      final String contents = await file.readAsString();
      final Map<String, dynamic> config = TomlDocument.parse(contents).toMap();
      final Map<String, dynamic> mainConfig =
          config.containsKey(mpMainConfigSection)
          ? config[mpMainConfigSection] as Map<String, dynamic>
          : {};
      final Map<String, dynamic> fileEditConfig =
          config.containsKey(mpFileEditConfigSection)
          ? config[mpFileEditConfigSection] as Map<String, dynamic>
          : {};

      String localeID = mpDefaultLocaleID;
      double selectionTolerance = thDefaultSelectionTolerance;
      double pointRadius = thDefaultPointRadius;
      double lineThickness = thDefaultLineThickness;

      if (mainConfig.isNotEmpty) {
        if (mainConfig.containsKey(mpMainConfigLocale)) {
          localeID = mainConfig[mpMainConfigLocale];
        }
      }

      if (fileEditConfig.isNotEmpty) {
        if (fileEditConfig.containsKey(mpFileEditConfigSelectionTolerance)) {
          selectionTolerance =
              fileEditConfig[mpFileEditConfigSelectionTolerance];
        }
        if (fileEditConfig.containsKey(mpFileEditConfigPointRadius)) {
          pointRadius = fileEditConfig[mpFileEditConfigPointRadius];
        }
        if (fileEditConfig.containsKey(mpFileEditConfigLineThickness)) {
          lineThickness = fileEditConfig[mpFileEditConfigLineThickness];
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
    final bool saveConfigFile = (_localeID != localeID);

    _localeID = localeID;

    if (localeID == mpDefaultLocaleID) {
      localeID = _getSystemLocaleID();
    }
    _locale = Locale(localeID);

    if (saveConfigFile) {
      _saveConfigFile();
    }
  }

  @action
  void setSelectionTolerance(double selectionTolerance) {
    final bool saveConfigFile = (_selectionTolerance != selectionTolerance);

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

  Future<void> _saveConfigFile() async {
    if (_readingConfigFile) {
      return;
    }

    try {
      final Map<String, dynamic> config = {
        mpMainConfigSection: {mpMainConfigLocale: _localeID},
        mpFileEditConfigSection: {
          mpFileEditConfigLineThickness: _lineThickness,
          mpFileEditConfigPointRadius: _pointRadius,
          mpFileEditConfigSelectionTolerance: _selectionTolerance,
        },
      };
      final String contents = TomlDocument.fromMap(config).toString();
      final Directory configDirectory = await MPDirectoryAux.config();
      final File file = File(
        p.join(configDirectory.path, mpMainConfigFilename),
      );

      await file.writeAsString(contents);
    } catch (e) {
      mpLocator.mpLog.e('Error saving config file.', error: e);
    }
  }
}
