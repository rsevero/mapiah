import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_internal_settings_type.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
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

  late final SharedPreferencesWithCache prefs;
  late final Future<void> initialized;

  MPSettingsControllerBase() {
    initialized = _initialize();
  }

  Future<void> _initialize() async {
    // wait for both async readers to complete. With Future.wait they run in
    //parallel, which is more efficient.
    await Future.wait([_readConfigFile(), _readInternalSettingsFile()]);
  }

  Future<void> _readInternalSettingsFile() async {
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: MPInternalSettingsType.values.map((e) => e.name).toSet(),
      ),
    );
  }

  Future<void> _readConfigFile() async {
    if (_readingConfigFile) {
      return;
    }

    try {
      _readingConfigFile = true;

      final Directory configDirectory = await MPDirectoryAux.config();
      final File file = File(
        p.join(configDirectory.path, mpMainConfigFilename),
      );

      if (!await file.exists()) {
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
    } catch (e) {
      mpLocator.mpLog.e('Error reading config file.', error: e);
    } finally {
      _readingConfigFile = false;
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
    final File file = File(p.join(configDirectory.path, mpMainConfigFilename));

    await file.writeAsString(contents, flush: true);
  }
}
