import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_settings.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mp_settings_controller.g.dart';

class MPSettingsController = MPSettingsControllerBase
    with _$MPSettingsController;

abstract class MPSettingsControllerBase with Store {
  Locale get locale {
    final String localIDSetting = getString(MPSetting.Main_LocaleID);
    final String localeID = (localIDSetting == mpDefaultLocaleID)
        ? _getSystemLocaleID()
        : localIDSetting;

    return Locale(localeID);
  }

  final Map<MPSetting, bool> _boolSettings = {};
  final Map<MPSetting, double> _doubleSettings = {};
  final Map<MPSetting, int> _intSettings = {};
  final Map<MPSetting, String> _stringSettings = {};
  final Map<MPSetting, List<String>> _stringListSettings = {};

  /// The default default value for bools is mpDefaultDefaultBoolSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSetting, bool> _boolDefaultSettings = {};

  /// The default default value for doubles is mpDefaultDefaultDoubleSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSetting, double> _doubleDefaultSettings = {
    MPSetting.TH2Edit_LineThickness: mpDefaultLineThickness,
    MPSetting.TH2Edit_PointRadius: mpDefaultPointRadius,
    MPSetting.TH2Edit_SelectionTolerance: mpDefaultSelectionTolerance,
  };

  /// The default default value for ints is mpDefaultDefaultIntSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSetting, int> _intDefaultSettings = {};

  /// The default default value for strings is mpDefaultDefaultStringSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSetting, String> _stringDefaultSettings = {
    MPSetting.Main_LocaleID: mpDefaultLocaleID,
  };

  /// The default default value for string lists is
  /// mpDefaultDefaultStringListSetting. Only settings that differ from that
  /// should be included here.
  static const Map<MPSetting, List<String>> _stringListDefaultSettings = {};

  final Map<MPSetting, Observable<int>> _settingsTriggers = {
    for (final MPSetting t in MPSetting.values)
      t: Observable<int>(mpMinimumInt),
  };

  late final SharedPreferencesWithCache prefs;
  late final Future<void> initialized;

  MPSettingsControllerBase() {
    initialized = _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    // wait for both async readers to complete. With Future.wait they run in
    //parallel, which is more efficient.
    await Future.wait([_readInternalSettingsFile()]);
  }

  Future<void> _readInternalSettingsFile() async {
    SharedPreferencesAsyncPlatform.instance ??=
        InMemorySharedPreferencesAsync.empty();
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: MPSetting.values.map((e) => e.name).toSet(),
      ),
    );
    for (final MPSetting type in MPSetting.values) {
      switch (type.type()) {
        case MPSettingType.bool:
          final bool? value = prefs.getBool(type.name);

          if (value != null) {
            setBool(type, value);
          }
        case MPSettingType.double:
          final double? value = prefs.getDouble(type.name);

          if (value != null) {
            setDouble(type, value);
          }
        case MPSettingType.int:
          final int? value = prefs.getInt(type.name);

          if (value != null) {
            setInt(type, value);
          }
        case MPSettingType.string:
          final String? value = prefs.getString(type.name);

          if (value != null) {
            setString(type, value);
          }
        case MPSettingType.stringList:
          final List<String>? value = prefs.getStringList(type.name);

          if (value != null) {
            setStringList(type, value);
          }
        case MPSettingType.filePickerExec:
          final String? value = prefs.getString(type.name);

          if (value != null) {
            setString(type, value);
          }
      }
    }
  }

  bool _isStringBackedType(MPSettingType type) {
    return ((type == MPSettingType.string) ||
        (type == MPSettingType.filePickerExec));
  }

  String _getSystemLocaleID() {
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;

    return systemLocale.languageCode;
  }

  bool getBool(MPSetting setting) {
    if (setting.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type bool at getBool',
      );
    }

    // Prefer an explicitly stored value, then fall back to the default map,
    // and finally return a safe default of `false`.
    if (_boolSettings.containsKey(setting)) {
      return _boolSettings[setting]!;
    }

    return getDefaultBool(setting);
  }

  bool getDefaultBool(MPSetting setting) {
    if (setting.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type bool at getDefaultBool',
      );
    }

    if (_boolDefaultSettings.containsKey(setting)) {
      return _boolDefaultSettings[setting]!;
    }

    return mpDefaultDefaultBoolSetting;
  }

  double getDouble(MPSetting setting) {
    if (setting.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type double at getDouble',
      );
    }

    if (_doubleSettings.containsKey(setting)) {
      return _doubleSettings[setting]!;
    }

    return getDefaultDouble(setting);
  }

  double getDefaultDouble(MPSetting setting) {
    if (setting.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type double at getDefaultDouble',
      );
    }

    if (_doubleDefaultSettings.containsKey(setting)) {
      return _doubleDefaultSettings[setting]!;
    }

    return mpDefaultDefaultDoubleSetting;
  }

  int getInt(MPSetting setting) {
    if (setting.type() != MPSettingType.int) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type int at getInt',
      );
    }

    if (_intSettings.containsKey(setting)) {
      return _intSettings[setting]!;
    }

    return getDefaultInt(setting);
  }

  int getDefaultInt(MPSetting setting) {
    if (setting.type() != MPSettingType.int) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type int at getDefaultInt',
      );
    }

    if (_intDefaultSettings.containsKey(setting)) {
      return _intDefaultSettings[setting]!;
    }

    return mpDefaultDefaultIntSetting;
  }

  String getString(MPSetting setting) {
    if (!_isStringBackedType(setting.type())) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type string/filePickerExec at getString',
      );
    }

    if (_stringSettings.containsKey(setting)) {
      return _stringSettings[setting]!;
    }

    return getDefaultString(setting);
  }

  String getDefaultString(MPSetting setting) {
    if (!_isStringBackedType(setting.type())) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type string/filePickerExec at getDefaultString',
      );
    }

    if (setting.type() == MPSettingType.filePickerExec) {
      return setting.filePickerExecName();
    }

    if (_stringDefaultSettings.containsKey(setting)) {
      return _stringDefaultSettings[setting]!;
    }

    return mpDefaultDefaultStringSetting;
  }

  List<String> getStringList(MPSetting setting) {
    if (setting.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type stringList at getStringList',
      );
    }

    if (_stringListSettings.containsKey(setting)) {
      return _stringListSettings[setting]!.toList();
    }

    return getDefaultStringList(setting);
  }

  List<String> getDefaultStringList(MPSetting setting) {
    if (setting.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type stringList at getDefaultStringList',
      );
    }

    if (_stringListDefaultSettings.containsKey(setting)) {
      return _stringListDefaultSettings[setting]!.toList();
    }

    return mpDefaultDefaultStringListSetting.toList();
  }

  bool setBool(MPSetting setting, bool value) {
    if (setting.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type bool at setBool',
      );
    }

    final bool oldValue = getBool(setting);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _boolSettings[setting] = value;
      prefs.setBool(setting.name, value);
      trigger(setting);
    }

    return isChanged;
  }

  bool isBoolSet(MPSetting setting) {
    if (setting.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type bool at isBoolSet',
      );
    }

    return _boolSettings.containsKey(setting);
  }

  void resetBool(MPSetting setting) {
    if (setting.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type bool at resetBool',
      );
    }

    if (_boolSettings.containsKey(setting)) {
      _boolSettings.remove(setting);
      prefs.remove(setting.name);
      trigger(setting);
    }
  }

  bool setDouble(MPSetting setting, double value) {
    if (setting.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type double at setDouble',
      );
    }

    final double oldValue = getDouble(setting);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _doubleSettings[setting] = value;
      prefs.setDouble(setting.name, value);
      trigger(setting);
    }

    return isChanged;
  }

  bool isDoubleSet(MPSetting setting) {
    if (setting.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type double at isDoubleSet',
      );
    }

    return _doubleSettings.containsKey(setting);
  }

  void resetDouble(MPSetting setting) {
    if (setting.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type double at resetDouble',
      );
    }

    if (_doubleSettings.containsKey(setting)) {
      _doubleSettings.remove(setting);
      prefs.remove(setting.name);
      trigger(setting);
    }
  }

  bool setInt(MPSetting setting, int value) {
    if (setting.type() != MPSettingType.int) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type int at setInt',
      );
    }

    final int oldValue = getInt(setting);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _intSettings[setting] = value;
      prefs.setInt(setting.name, value);
      trigger(setting);
    }

    return isChanged;
  }

  bool isIntSet(MPSetting setting) {
    if (setting.type() != MPSettingType.int) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type int at isIntSet',
      );
    }

    return _intSettings.containsKey(setting);
  }

  void resetInt(MPSetting setting) {
    if (setting.type() != MPSettingType.int) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type int at resetInt',
      );
    }

    if (_intSettings.containsKey(setting)) {
      _intSettings.remove(setting);
      prefs.remove(setting.name);
      trigger(setting);
    }
  }

  bool setString(MPSetting setting, String value) {
    if (!_isStringBackedType(setting.type())) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type string/filePickerExec at setString',
      );
    }

    final String oldValue = getString(setting);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _stringSettings[setting] = value;
      prefs.setString(setting.name, value);
      trigger(setting);
    }

    return isChanged;
  }

  bool isStringSet(MPSetting setting) {
    if (!_isStringBackedType(setting.type())) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type string/filePickerExec at isStringSet',
      );
    }

    return _stringSettings.containsKey(setting);
  }

  void resetString(MPSetting setting) {
    if (!_isStringBackedType(setting.type())) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type string/filePickerExec at resetString',
      );
    }

    if (_stringSettings.containsKey(setting)) {
      _stringSettings.remove(setting);
      prefs.remove(setting.name);
      trigger(setting);
    }
  }

  bool setStringList(MPSetting setting, List<String> value) {
    if (setting.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type stringList at setStringList',
      );
    }

    final List<String> oldValue = getStringList(setting);
    final bool isChanged = !listEquals(oldValue, value);

    if (isChanged) {
      _stringListSettings[setting] = value;
      prefs.setStringList(setting.name, value);
      trigger(setting);
    }

    return isChanged;
  }

  bool isStringListSet(MPSetting setting) {
    if (setting.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type stringList at isStringListSet',
      );
    }

    return _stringListSettings.containsKey(setting);
  }

  void resetStringList(MPSetting setting) {
    if (setting.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingsType $setting is not of type stringList at resetStringList',
      );
    }

    if (_stringListSettings.containsKey(setting)) {
      _stringListSettings.remove(setting);
      prefs.remove(setting.name);
      trigger(setting);
    }
  }

  int getTrigger(MPSetting setting) => _settingsTriggers[setting]!.value;

  @action
  void trigger(MPSetting setting) {
    _settingsTriggers[setting]!.value++;
  }
}
