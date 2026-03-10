import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_therion_runner.dart';
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
  @readonly
  bool _isTherionAvailable = true;

  Locale get locale {
    final String localIDSetting = getStringWithDefault(
      MPSettingID.Main_LocaleID,
    );
    final String localeID = (localIDSetting == mpDefaultLocaleID)
        ? _getSystemLocaleID()
        : localIDSetting;

    return Locale(localeID);
  }

  final Map<MPSettingID, bool> _boolSettings = {};
  final Map<MPSettingID, double> _doubleSettings = {};
  final Map<MPSettingID, int> _intSettings = {};
  final Map<MPSettingID, String> _stringSettings = {};
  final Map<MPSettingID, List<String>> _stringListSettings = {};

  /// The default default value for bools is mpDefaultDefaultBoolSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSettingID, bool> _boolDefaultSettings = {};

  /// The default default value for doubles is mpDefaultDefaultDoubleSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSettingID, double> _doubleDefaultSettings = {
    MPSettingID.TH2Edit_LineThickness: mpDefaultLineThickness,
    MPSettingID.TH2Edit_PointRadius: mpDefaultPointRadius,
    MPSettingID.TH2Edit_SelectionTolerance: mpDefaultSelectionTolerance,
  };

  /// The default default value for ints is mpDefaultDefaultIntSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSettingID, int> _intDefaultSettings = {};

  /// The default default value for strings is mpDefaultDefaultStringSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSettingID, String> _stringDefaultSettings = {
    MPSettingID.Main_LocaleID: mpDefaultLocaleID,
  };

  /// The default default value for string lists is
  /// mpDefaultDefaultStringListSetting. Only settings that differ from that
  /// should be included here.
  static const Map<MPSettingID, List<String>> _stringListDefaultSettings = {};

  final Map<MPSettingID, Observable<int>> _settingsTriggers = {
    for (final MPSettingID t in MPSettingID.values)
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
    // Update Therion availability after settings load.
    try {
      _updateTherionAvailability();
    } on Object {
      // ignore
    }
  }

  Future<void> _updateTherionAvailability() async {
    try {
      final bool available = await MPTherionRunner.isTherionAvailable();

      _isTherionAvailable = available;
    } on Object {
      _isTherionAvailable = false;
    }
  }

  Future<void> _readInternalSettingsFile() async {
    SharedPreferencesAsyncPlatform.instance ??=
        InMemorySharedPreferencesAsync.empty();
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: MPSettingID.values.map((e) => e.name).toSet(),
      ),
    );
    for (final MPSettingID id in MPSettingID.values) {
      switch (id.type()) {
        case MPSettingType.bool:
          final bool? value = prefs.getBool(id.name);

          if (value != null) {
            setBool(id, value);
          }
        case MPSettingType.double:
          final double? value = prefs.getDouble(id.name);

          if (value != null) {
            setDouble(id, value);
          }
        case MPSettingType.int:
          final int? value = prefs.getInt(id.name);

          if (value != null) {
            setInt(id, value);
          }
        case MPSettingType.string:
          final String? value = prefs.getString(id.name);

          if (value != null) {
            setString(id, value);
          }
        case MPSettingType.stringList:
          final List<String>? value = prefs.getStringList(id.name);

          if (value != null) {
            setStringList(id, value);
          }
        case MPSettingType.filePickerExec:
          final String? value = prefs.getString(id.name);

          if (value != null) {
            setString(id, value);
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

  bool? getBoolIfSet(MPSettingID id) {
    if (id.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingID $id is not of type bool at getBoolIfSet',
      );
    }

    if (_boolSettings.containsKey(id)) {
      return _boolSettings[id]!;
    }

    return null;
  }

  bool getBoolWithDefault(MPSettingID id) {
    if (id.type() != MPSettingType.bool) {
      throw ArgumentError('MPSettingID $id is not of type bool at getBool');
    }

    // Prefer an explicitly stored value, then fall back to the default map,
    // and finally return a safe default of `false`.
    if (_boolSettings.containsKey(id)) {
      return _boolSettings[id]!;
    }

    return getDefaultBool(id);
  }

  bool getDefaultBool(MPSettingID id) {
    if (id.type() != MPSettingType.bool) {
      throw ArgumentError(
        'MPSettingID $id is not of type bool at getDefaultBool',
      );
    }

    if (_boolDefaultSettings.containsKey(id)) {
      return _boolDefaultSettings[id]!;
    }

    return mpDefaultDefaultBoolSetting;
  }

  double? getDoubleIfSet(MPSettingID id) {
    if (id.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingID $id is not of type double at getDoubleIfSet',
      );
    }

    if (_doubleSettings.containsKey(id)) {
      return _doubleSettings[id]!;
    }

    return null;
  }

  double getDoubleWithDefault(MPSettingID id) {
    if (id.type() != MPSettingType.double) {
      throw ArgumentError('MPSettingID $id is not of type double at getDouble');
    }

    if (_doubleSettings.containsKey(id)) {
      return _doubleSettings[id]!;
    }

    return getDefaultDouble(id);
  }

  double getDefaultDouble(MPSettingID id) {
    if (id.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingID $id is not of type double at getDefaultDouble',
      );
    }

    if (_doubleDefaultSettings.containsKey(id)) {
      return _doubleDefaultSettings[id]!;
    }

    return mpDefaultDefaultDoubleSetting;
  }

  int? getIntIfSet(MPSettingID id) {
    if (id.type() != MPSettingType.int) {
      throw ArgumentError('MPSettingID $id is not of type int at getIntIfSet');
    }

    if (_intSettings.containsKey(id)) {
      return _intSettings[id]!;
    }

    return null;
  }

  int getIntWithDefault(MPSettingID id) {
    if (id.type() != MPSettingType.int) {
      throw ArgumentError('MPSettingID $id is not of type int at getInt');
    }

    if (_intSettings.containsKey(id)) {
      return _intSettings[id]!;
    }

    return getDefaultInt(id);
  }

  int getDefaultInt(MPSettingID id) {
    if (id.type() != MPSettingType.int) {
      throw ArgumentError(
        'MPSettingID $id is not of type int at getDefaultInt',
      );
    }

    if (_intDefaultSettings.containsKey(id)) {
      return _intDefaultSettings[id]!;
    }

    return mpDefaultDefaultIntSetting;
  }

  String? getStringIfSet(MPSettingID id) {
    if (!_isStringBackedType(id.type())) {
      throw ArgumentError(
        'MPSettingID $id is not of type string/filePickerExec at getStringIfSet',
      );
    }

    if (_stringSettings.containsKey(id)) {
      return _stringSettings[id]!;
    }

    return null;
  }

  String getStringWithDefault(MPSettingID id) {
    if (!_isStringBackedType(id.type())) {
      throw ArgumentError(
        'MPSettingID $id is not of type string/filePickerExec at getString',
      );
    }

    if (_stringSettings.containsKey(id)) {
      return _stringSettings[id]!;
    }

    return getDefaultString(id);
  }

  String getDefaultString(MPSettingID id) {
    if (!_isStringBackedType(id.type())) {
      throw ArgumentError(
        'MPSettingID $id is not of type string/filePickerExec at getDefaultString',
      );
    }

    if (id.type() == MPSettingType.filePickerExec) {
      return id.filePickerExecName();
    }

    if (_stringDefaultSettings.containsKey(id)) {
      return _stringDefaultSettings[id]!;
    }

    return mpDefaultDefaultStringSetting;
  }

  List<String>? getStringListIfSet(MPSettingID id) {
    if (id.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingID $id is not of type stringList at getStringListIfSet',
      );
    }

    if (_stringListSettings.containsKey(id)) {
      return _stringListSettings[id]!.toList();
    }

    return null;
  }

  List<String> getStringListWithDefault(MPSettingID id) {
    if (id.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingID $id is not of type stringList at getStringList',
      );
    }

    if (_stringListSettings.containsKey(id)) {
      return _stringListSettings[id]!.toList();
    }

    return getDefaultStringList(id);
  }

  List<String> getDefaultStringList(MPSettingID id) {
    if (id.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingID $id is not of type stringList at getDefaultStringList',
      );
    }

    if (_stringListDefaultSettings.containsKey(id)) {
      return _stringListDefaultSettings[id]!.toList();
    }

    return mpDefaultDefaultStringListSetting.toList();
  }

  void reset() {
    for (final MPSettingID id in MPSettingID.values) {
      switch (id.type()) {
        case MPSettingType.bool:
          resetBool(id);
        case MPSettingType.double:
          resetDouble(id);
        case MPSettingType.int:
          resetInt(id);
        case MPSettingType.string:
        case MPSettingType.filePickerExec:
          resetString(id);
        case MPSettingType.stringList:
          resetStringList(id);
      }
    }
  }

  bool setBool(MPSettingID id, bool value) {
    if (id.type() != MPSettingType.bool) {
      throw ArgumentError('MPSettingID $id is not of type bool at setBool');
    }

    final bool oldValue = getBoolWithDefault(id);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _boolSettings[id] = value;
      prefs.setBool(id.name, value);
      trigger(id);
    }

    return isChanged;
  }

  bool isBoolSet(MPSettingID id) {
    if (id.type() != MPSettingType.bool) {
      throw ArgumentError('MPSettingID $id is not of type bool at isBoolSet');
    }

    return _boolSettings.containsKey(id);
  }

  void resetBool(MPSettingID id) {
    if (id.type() != MPSettingType.bool) {
      throw ArgumentError('MPSettingID $id is not of type bool at resetBool');
    }

    if (_boolSettings.containsKey(id)) {
      _boolSettings.remove(id);
      prefs.remove(id.name);
      trigger(id);
    }
  }

  bool setDouble(MPSettingID id, double value) {
    if (id.type() != MPSettingType.double) {
      throw ArgumentError('MPSettingID $id is not of type double at setDouble');
    }

    final double oldValue = getDoubleWithDefault(id);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _doubleSettings[id] = value;
      prefs.setDouble(id.name, value);
      trigger(id);
    }

    return isChanged;
  }

  bool isDoubleSet(MPSettingID id) {
    if (id.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingID $id is not of type double at isDoubleSet',
      );
    }

    return _doubleSettings.containsKey(id);
  }

  void resetDouble(MPSettingID id) {
    if (id.type() != MPSettingType.double) {
      throw ArgumentError(
        'MPSettingID $id is not of type double at resetDouble',
      );
    }

    if (_doubleSettings.containsKey(id)) {
      _doubleSettings.remove(id);
      prefs.remove(id.name);
      trigger(id);
    }
  }

  bool setInt(MPSettingID id, int value) {
    if (id.type() != MPSettingType.int) {
      throw ArgumentError('MPSettingID $id is not of type int at setInt');
    }

    final int oldValue = getIntWithDefault(id);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _intSettings[id] = value;
      prefs.setInt(id.name, value);
      trigger(id);
    }

    return isChanged;
  }

  bool isIntSet(MPSettingID id) {
    if (id.type() != MPSettingType.int) {
      throw ArgumentError('MPSettingID $id is not of type int at isIntSet');
    }

    return _intSettings.containsKey(id);
  }

  void resetInt(MPSettingID id) {
    if (id.type() != MPSettingType.int) {
      throw ArgumentError('MPSettingID $id is not of type int at resetInt');
    }

    if (_intSettings.containsKey(id)) {
      _intSettings.remove(id);
      prefs.remove(id.name);
      trigger(id);
    }
  }

  bool setString(MPSettingID id, String value) {
    if (!_isStringBackedType(id.type())) {
      throw ArgumentError(
        'MPSettingID $id is not of type string/filePickerExec at setString',
      );
    }

    final String oldValue = getStringWithDefault(id);
    final bool isChanged = (oldValue != value);

    if (isChanged) {
      _stringSettings[id] = value;
      prefs.setString(id.name, value);
      trigger(id);
      if (id == MPSettingID.Main_TherionExecutablePath) {
        // Clear cached probe and re-check availability asynchronously.
        MPTherionRunner.clearSearchedTherionExecutablePathCache();
        _updateTherionAvailability();
      }
    }

    return isChanged;
  }

  bool isStringSet(MPSettingID id) {
    if (!_isStringBackedType(id.type())) {
      throw ArgumentError(
        'MPSettingID $id is not of type string/filePickerExec at isStringSet',
      );
    }

    return _stringSettings.containsKey(id);
  }

  void resetString(MPSettingID id) {
    if (!_isStringBackedType(id.type())) {
      throw ArgumentError(
        'MPSettingID $id is not of type string/filePickerExec at resetString',
      );
    }

    if (_stringSettings.containsKey(id)) {
      _stringSettings.remove(id);
      prefs.remove(id.name);
      trigger(id);
    }
  }

  bool setStringList(MPSettingID id, List<String> value) {
    if (id.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingID $id is not of type stringList at setStringList',
      );
    }

    final List<String> oldValue = getStringListWithDefault(id);
    final bool isChanged = !listEquals(oldValue, value);

    if (isChanged) {
      _stringListSettings[id] = value;
      prefs.setStringList(id.name, value);
      trigger(id);
    }

    return isChanged;
  }

  bool isStringListSet(MPSettingID id) {
    if (id.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingID $id is not of type stringList at isStringListSet',
      );
    }

    return _stringListSettings.containsKey(id);
  }

  void resetStringList(MPSettingID id) {
    if (id.type() != MPSettingType.stringList) {
      throw ArgumentError(
        'MPSettingID $id is not of type stringList at resetStringList',
      );
    }

    if (_stringListSettings.containsKey(id)) {
      _stringListSettings.remove(id);
      prefs.remove(id.name);
      trigger(id);
    }
  }

  int getTrigger(MPSettingID id) => _settingsTriggers[id]!.value;

  @action
  void trigger(MPSettingID id) {
    _settingsTriggers[id]!.value++;
  }
}
