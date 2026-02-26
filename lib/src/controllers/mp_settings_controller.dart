import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mp_settings_controller.g.dart';

class MPSettingsController = MPSettingsControllerBase
    with _$MPSettingsController;

abstract class MPSettingsControllerBase with Store {
  Locale get locale {
    final String localIDSetting = getString(MPSettingType.Main_LocaleID);
    final String localeID = (localIDSetting == mpDefaultLocaleID)
        ? _getSystemLocaleID()
        : localIDSetting;

    return Locale(localeID);
  }

  final Map<MPSettingType, bool> _boolSettings = {};
  final Map<MPSettingType, double> _doubleSettings = {};
  final Map<MPSettingType, int> _intSettings = {};
  final Map<MPSettingType, String> _stringSettings = {};
  final Map<MPSettingType, List<String>> _stringListSettings = {};

  /// The default default value for bools is mpDefaultDefaultBoolSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSettingType, bool> _boolDefaultSettings = {};

  /// The default default value for doubles is mpDefaultDefaultDoubleSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSettingType, double> _doubleDefaultSettings = {
    MPSettingType.TH2Edit_LineThickness: mpDefaultLineThickness,
    MPSettingType.TH2Edit_PointRadius: mpDefaultPointRadius,
    MPSettingType.TH2Edit_SelectionTolerance: mpDefaultSelectionTolerance,
  };

  /// The default default value for ints is mpDefaultDefaultIntSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSettingType, int> _intDefaultSettings = {};

  /// The default default value for strings is mpDefaultDefaultStringSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSettingType, String> _stringDefaultSettings = {
    MPSettingType.Main_LocaleID: mpDefaultLocaleID,
  };

  /// The default default value for string lists is
  /// mpDefaultDefaultStringListSetting. Only settings that differ from that
  /// should be included here.
  static const Map<MPSettingType, List<String>> _stringListDefaultSettings = {};

  final Map<MPSettingType, Observable<int>> _settingsTriggers = {
    for (final MPSettingType t in MPSettingType.values)
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
        allowList: MPSettingType.values.map((e) => e.name).toSet(),
      ),
    );
    for (final MPSettingType type in MPSettingType.values) {
      switch (type.type()) {
        case MPSettingTypeType.bool:
          final bool? value = prefs.getBool(type.name);

          if (value != null) {
            setBool(type, value);
          }
        case MPSettingTypeType.double:
          final double? value = prefs.getDouble(type.name);

          if (value != null) {
            setDouble(type, value);
          }
        case MPSettingTypeType.int:
          final int? value = prefs.getInt(type.name);

          if (value != null) {
            setInt(type, value);
          }
        case MPSettingTypeType.string:
          final String? value = prefs.getString(type.name);

          if (value != null) {
            setString(type, value);
          }
        case MPSettingTypeType.stringList:
          final List<String>? value = prefs.getStringList(type.name);

          if (value != null) {
            setStringList(type, value);
          }
        case MPSettingTypeType.filePickerExec:
          final String? value = prefs.getString(type.name);

          if (value != null) {
            setString(type, value);
          }
      }
    }
  }

  bool _isStringBackedType(MPSettingTypeType type) {
    return ((type == MPSettingTypeType.string) ||
        (type == MPSettingTypeType.filePickerExec));
  }

  String _getSystemLocaleID() {
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;

    return systemLocale.languageCode;
  }

  bool getBool(MPSettingType type) {
    if (type.type() != MPSettingTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at getBool',
      );
    }

    // Prefer an explicitly stored value, then fall back to the default map,
    // and finally return a safe default of `false`.
    if (_boolSettings.containsKey(type)) {
      return _boolSettings[type]!;
    }

    return getDefaultBool(type);
  }

  bool getDefaultBool(MPSettingType type) {
    if (type.type() != MPSettingTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at getDefaultBool',
      );
    }

    if (_boolDefaultSettings.containsKey(type)) {
      return _boolDefaultSettings[type]!;
    }

    return mpDefaultDefaultBoolSetting;
  }

  double getDouble(MPSettingType type) {
    if (type.type() != MPSettingTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at getDouble',
      );
    }

    if (_doubleSettings.containsKey(type)) {
      return _doubleSettings[type]!;
    }

    return getDefaultDouble(type);
  }

  double getDefaultDouble(MPSettingType type) {
    if (type.type() != MPSettingTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at getDefaultDouble',
      );
    }

    if (_doubleDefaultSettings.containsKey(type)) {
      return _doubleDefaultSettings[type]!;
    }

    return mpDefaultDefaultDoubleSetting;
  }

  int getInt(MPSettingType type) {
    if (type.type() != MPSettingTypeType.int) {
      throw ArgumentError('MPSettingsType $type is not of type int at getInt');
    }

    if (_intSettings.containsKey(type)) {
      return _intSettings[type]!;
    }

    return getDefaultInt(type);
  }

  int getDefaultInt(MPSettingType type) {
    if (type.type() != MPSettingTypeType.int) {
      throw ArgumentError(
        'MPSettingsType $type is not of type int at getDefaultInt',
      );
    }

    if (_intDefaultSettings.containsKey(type)) {
      return _intDefaultSettings[type]!;
    }

    return mpDefaultDefaultIntSetting;
  }

  String getString(MPSettingType type) {
    if (!_isStringBackedType(type.type())) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string/filePickerExec at getString',
      );
    }

    if (_stringSettings.containsKey(type)) {
      return _stringSettings[type]!;
    }

    return getDefaultString(type);
  }

  String getDefaultString(MPSettingType type) {
    if (!_isStringBackedType(type.type())) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string/filePickerExec at getDefaultString',
      );
    }

    if (type.type() == MPSettingTypeType.filePickerExec) {
      return type.filePickerExecName();
    }

    if (_stringDefaultSettings.containsKey(type)) {
      return _stringDefaultSettings[type]!;
    }

    return mpDefaultDefaultStringSetting;
  }

  List<String> getStringList(MPSettingType type) {
    if (type.type() != MPSettingTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at getStringList',
      );
    }

    if (_stringListSettings.containsKey(type)) {
      return _stringListSettings[type]!.toList();
    }

    return getDefaultStringList(type);
  }

  List<String> getDefaultStringList(MPSettingType type) {
    if (type.type() != MPSettingTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at getDefaultStringList',
      );
    }

    if (_stringListDefaultSettings.containsKey(type)) {
      return _stringListDefaultSettings[type]!.toList();
    }

    return mpDefaultDefaultStringListSetting.toList();
  }

  bool setBool(MPSettingType type, bool value) {
    if (type.type() != MPSettingTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at setBool',
      );
    }

    final bool oldValue = getBool(type);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _boolSettings[type] = value;
      prefs.setBool(type.name, value);
      trigger(type);
    }

    return isChanged;
  }

  bool isBoolSet(MPSettingType type) {
    if (type.type() != MPSettingTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at isBoolSet',
      );
    }

    return _boolSettings.containsKey(type);
  }

  void resetBool(MPSettingType type) {
    if (type.type() != MPSettingTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at resetBool',
      );
    }

    if (_boolSettings.containsKey(type)) {
      _boolSettings.remove(type);
      prefs.remove(type.name);
      trigger(type);
    }
  }

  bool setDouble(MPSettingType type, double value) {
    if (type.type() != MPSettingTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at setDouble',
      );
    }

    final double oldValue = getDouble(type);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _doubleSettings[type] = value;
      prefs.setDouble(type.name, value);
      trigger(type);
    }

    return isChanged;
  }

  bool isDoubleSet(MPSettingType type) {
    if (type.type() != MPSettingTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at isDoubleSet',
      );
    }

    return _doubleSettings.containsKey(type);
  }

  void resetDouble(MPSettingType type) {
    if (type.type() != MPSettingTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at resetDouble',
      );
    }

    if (_doubleSettings.containsKey(type)) {
      _doubleSettings.remove(type);
      prefs.remove(type.name);
      trigger(type);
    }
  }

  bool setInt(MPSettingType type, int value) {
    if (type.type() != MPSettingTypeType.int) {
      throw ArgumentError('MPSettingsType $type is not of type int at setInt');
    }

    final int oldValue = getInt(type);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _intSettings[type] = value;
      prefs.setInt(type.name, value);
      trigger(type);
    }

    return isChanged;
  }

  bool isIntSet(MPSettingType type) {
    if (type.type() != MPSettingTypeType.int) {
      throw ArgumentError(
        'MPSettingsType $type is not of type int at isIntSet',
      );
    }

    return _intSettings.containsKey(type);
  }

  void resetInt(MPSettingType type) {
    if (type.type() != MPSettingTypeType.int) {
      throw ArgumentError(
        'MPSettingsType $type is not of type int at resetInt',
      );
    }

    if (_intSettings.containsKey(type)) {
      _intSettings.remove(type);
      prefs.remove(type.name);
      trigger(type);
    }
  }

  bool setString(MPSettingType type, String value) {
    if (!_isStringBackedType(type.type())) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string/filePickerExec at setString',
      );
    }

    final String oldValue = getString(type);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _stringSettings[type] = value;
      prefs.setString(type.name, value);
      trigger(type);
    }

    return isChanged;
  }

  bool isStringSet(MPSettingType type) {
    if (!_isStringBackedType(type.type())) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string/filePickerExec at isStringSet',
      );
    }

    return _stringSettings.containsKey(type);
  }

  void resetString(MPSettingType type) {
    if (!_isStringBackedType(type.type())) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string/filePickerExec at resetString',
      );
    }

    if (_stringSettings.containsKey(type)) {
      _stringSettings.remove(type);
      prefs.remove(type.name);
      trigger(type);
    }
  }

  bool setStringList(MPSettingType type, List<String> value) {
    if (type.type() != MPSettingTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at setStringList',
      );
    }

    final List<String> oldValue = getStringList(type);
    final bool isChanged = !listEquals(oldValue, value);

    if (isChanged) {
      _stringListSettings[type] = value;
      prefs.setStringList(type.name, value);
      trigger(type);
    }

    return isChanged;
  }

  bool isStringListSet(MPSettingType type) {
    if (type.type() != MPSettingTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at isStringListSet',
      );
    }

    return _stringListSettings.containsKey(type);
  }

  void resetStringList(MPSettingType type) {
    if (type.type() != MPSettingTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at resetStringList',
      );
    }

    if (_stringListSettings.containsKey(type)) {
      _stringListSettings.remove(type);
      prefs.remove(type.name);
      trigger(type);
    }
  }

  int getTrigger(MPSettingType type) => _settingsTriggers[type]!.value;

  @action
  void trigger(MPSettingType type) {
    _settingsTriggers[type]!.value++;
  }
}
