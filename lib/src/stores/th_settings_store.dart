import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_directory_helper.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mobx/mobx.dart';
import 'package:toml/toml.dart';

part 'th_settings_store.g.dart';

class THSettingsStore = THSettingsStoreBase with _$THSettingsStore;

abstract class THSettingsStoreBase with Store {
  bool _readingConfigFile = false;

  @readonly
  String _localeID = thDefaultLocaleID;

  @readonly
  Locale _locale = Locale('en');

  @readonly
  double _selectionTolerance = thDefaultSelectionTolerance;

  @readonly
  double _selectionToleranceSquared =
      thDefaultSelectionTolerance * thDefaultSelectionTolerance;

  THSettingsStoreBase() {
    _initialize();
  }

  void _initialize() {
    _readConfigFile();
  }

  Future<void> _readConfigFile() async {
    try {
      _readingConfigFile = true;

      final Directory configDirectory = await ThDirectoryHelper.config();
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
      }

      setLocaleID(localeID);
      setSelectionTolerance(selectionTolerance);

      _readingConfigFile = false;
    } catch (e) {
      print('Error reading config file: $e');
    }
  }

  String _getSystemLocaleID() {
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    return systemLocale.languageCode;
  }

  @action
  void setLocaleID(String aLocaleID) {
    final bool saveConfigFile = _localeID != aLocaleID;

    _localeID = aLocaleID;
    if (aLocaleID == 'sys') {
      aLocaleID = _getSystemLocaleID();
    }
    _locale = Locale(aLocaleID);

    if (saveConfigFile) {
      _saveConfigFile();
    }
  }

  void setSelectionTolerance(double aSelectionTolerance) {
    _selectionTolerance = aSelectionTolerance;
    _selectionToleranceSquared = aSelectionTolerance * aSelectionTolerance;
  }

  void _saveConfigFile() async {
    if (_readingConfigFile) {
      return;
    }

    try {
      final Map<String, dynamic> config = {
        thMainConfigSection: {thMainConfigLocale: _localeID}
      };
      final String contents = TomlDocument.fromMap(config).toString();

      final Directory configDirectory = await ThDirectoryHelper.config();
      final File file = File(configDirectory.path + thMainConfigFilename);

      await file.writeAsString(contents);
    } catch (e) {
      print('Error saving config file: $e');
    }
  }
}
