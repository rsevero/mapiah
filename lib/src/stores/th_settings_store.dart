import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_directory_helper.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mobx/mobx.dart';
import 'package:toml/toml.dart';

part 'th_settings_store.g.dart';

class THSettingsStore = THSettingsStoreBase with _$THSettingsStore;

abstract class THSettingsStoreBase with Store {
  @readonly
  String _localeID = thDefaultLocaleID;

  @readonly
  Locale _locale = Locale('en');

  THSettingsStoreBase() {
    _initialize();
  }

  void _initialize() {
    _readConfigFile();
  }

  Future<void> _readConfigFile() async {
    try {
      final Directory configDirectory = await ThDirectoryHelper.config();
      final File file = File(configDirectory.path + thMainConfigFilename);
      final String contents = await file.readAsString();
      final Map<String, dynamic> config = TomlDocument.parse(contents).toMap();

      final Map<String, dynamic> mainConfig = config.containsKey('Main')
          ? config['Main'] as Map<String, dynamic>
          : {};

      String localeID = '';

      if (mainConfig.isEmpty) {
        localeID = thDefaultLocaleID;
      } else {
        localeID = mainConfig.containsKey('Locale')
            ? mainConfig['Locale']
            : thDefaultLocaleID;
      }

      setLocaleID(localeID);
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

  void _saveConfigFile() async {
    try {
      final Map<String, dynamic> config = {
        'Main': {'Locale': _localeID}
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
