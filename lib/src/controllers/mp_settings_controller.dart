import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_settings_type.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mp_settings_controller.g.dart';

class MPSettingsController = MPSettingsControllerBase
    with _$MPSettingsController;

abstract class MPSettingsControllerBase with Store {
  Locale get locale {
    final String localIDSetting = getString(MPSettingsType.Main_LocaleID);
    final String localeID = (localIDSetting == mpDefaultLocaleID)
        ? _getSystemLocaleID()
        : localIDSetting;

    return Locale(localeID);
  }

  @readonly
  double _selectionTolerance = thDefaultSelectionTolerance;

  @readonly
  double _pointRadius = thDefaultPointRadius;

  @readonly
  double _lineThickness = thDefaultLineThickness;

  final Map<MPSettingsType, bool> _boolSettings = {};
  final Map<MPSettingsType, double> _doubleSettings = {};
  final Map<MPSettingsType, int> _intSettings = {};
  final Map<MPSettingsType, String> _stringSettings = {};
  final Map<MPSettingsType, List<String>> _stringListSettings = {};

  /// The default default value for bools is mpDefaultDefaultBoolSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSettingsType, bool> _boolDefaultSettings = {};

  /// The default default value for doubles is mpDefaultDefaultDoubleSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSettingsType, double> _doubleDefaultSettings = {};

  /// The default default value for ints is mpDefaultDefaultIntSetting. Only
  /// settings that differ from that should be included here.
  static const Map<MPSettingsType, int> _intDefaultSettings = {};

  /// The default default value for strings is mpDefaultDefaultStringSetting.
  /// Only settings that differ from that should be included here.
  static const Map<MPSettingsType, String> _stringDefaultSettings = {};

  /// The default default value for string lists is
  /// mpDefaultDefaultStringListSetting. Only settings that differ from that
  /// should be included here.
  static const Map<MPSettingsType, List<String>> _stringListDefaultSettings =
      {};

  final Map<MPSettingsType, Observable<int>> _settingsTriggers = {
    for (final MPSettingsType t in MPSettingsType.values)
      t: Observable<int>(mpMinimumInt),
  };

  late final SharedPreferencesWithCache prefs;
  late final Future<void> initialized;

  MPSettingsControllerBase() {
    initialized = _initialize();
  }

  Future<void> _initialize() async {
    // wait for both async readers to complete. With Future.wait they run in
    //parallel, which is more efficient.
    await Future.wait([_readInternalSettingsFile()]);
  }

  Future<void> _readInternalSettingsFile() async {
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: MPSettingsType.values.map((e) => e.name).toSet(),
      ),
    );
    for (final MPSettingsType type in MPSettingsType.values) {
      switch (type.type()) {
        case MPSettingsTypeType.bool:
          final bool? value = prefs.getBool(type.name);

          if (value != null) {
            setBool(type, value);
          }
        case MPSettingsTypeType.double:
          final double? value = prefs.getDouble(type.name);

          if (value != null) {
            setDouble(type, value);
          }
        case MPSettingsTypeType.int:
          final int? value = prefs.getInt(type.name);

          if (value != null) {
            setInt(type, value);
          }
        case MPSettingsTypeType.string:
          final String? value = prefs.getString(type.name);

          if (value != null) {
            setString(type, value);
          }
        case MPSettingsTypeType.stringList:
          final List<String>? value = prefs.getStringList(type.name);

          if (value != null) {
            setStringList(type, value);
          }
      }
    }
  }

  String _getSystemLocaleID() {
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;

    return systemLocale.languageCode;
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
    // if (_readingConfigFile) {
    //   throw StateError(
    //     '_saveConfigFile called while reading config file at MPSettingsController.',
    //   );
    // }

    // final Map<String, dynamic> config = {
    //   mpMainConfigSection: {mpMainConfigLocale: _localeID},
    //   mpFileEditConfigSection: {
    //     mpFileEditConfigLineThickness: _lineThickness,
    //     mpFileEditConfigPointRadius: _pointRadius,
    //     mpFileEditConfigSelectionTolerance: _selectionTolerance,
    //   },
    // };
    // final String contents = TomlDocument.fromMap(config).toString();
    // final Directory configDirectory = await MPDirectoryAux.config();
    // final File file = File(p.join(configDirectory.path, mpMainConfigFilename));

    // await file.writeAsString(contents, flush: true);
  }

  bool getBool(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.bool) {
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

  bool getDefaultBool(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at getDefaultBool',
      );
    }

    if (_boolDefaultSettings.containsKey(type)) {
      return _boolDefaultSettings[type]!;
    }

    return mpDefaultDefaultBoolSetting;
  }

  double getDouble(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at getDouble',
      );
    }

    if (_doubleSettings.containsKey(type)) {
      return _doubleSettings[type]!;
    }

    return getDefaultDouble(type);
  }

  double getDefaultDouble(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at getDefaultDouble',
      );
    }

    if (_doubleDefaultSettings.containsKey(type)) {
      return _doubleDefaultSettings[type]!;
    }

    return mpDefaultDefaultDoubleSetting;
  }

  int getInt(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.int) {
      throw ArgumentError('MPSettingsType $type is not of type int at getInt');
    }

    if (_intSettings.containsKey(type)) {
      return _intSettings[type]!;
    }

    return getDefaultInt(type);
  }

  int getDefaultInt(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.int) {
      throw ArgumentError(
        'MPSettingsType $type is not of type int at getDefaultInt',
      );
    }

    if (_intDefaultSettings.containsKey(type)) {
      return _intDefaultSettings[type]!;
    }

    return mpDefaultDefaultIntSetting;
  }

  String getString(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.string) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string at getString',
      );
    }

    if (_stringSettings.containsKey(type)) {
      return _stringSettings[type]!;
    }

    return getDefaultString(type);
  }

  String getDefaultString(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.string) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string at getDefaultString',
      );
    }

    if (_stringDefaultSettings.containsKey(type)) {
      return _stringDefaultSettings[type]!;
    }

    return mpDefaultDefaultStringSetting;
  }

  List<String> getStringList(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at getStringList',
      );
    }

    if (_stringListSettings.containsKey(type)) {
      return _stringListSettings[type]!.toList();
    }

    return getDefaultStringList(type);
  }

  List<String> getDefaultStringList(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at getDefaultStringList',
      );
    }

    if (_stringListDefaultSettings.containsKey(type)) {
      return _stringListDefaultSettings[type]!.toList();
    }

    return mpDefaultDefaultStringListSetting.toList();
  }

  bool setBool(MPSettingsType type, bool value) {
    if (type.type() != MPSettingsTypeType.bool) {
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

  bool isBoolSet(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.bool) {
      throw ArgumentError(
        'MPSettingsType $type is not of type bool at isBoolSet',
      );
    }

    return _boolSettings.containsKey(type);
  }

  void resetBool(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.bool) {
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

  bool setDouble(MPSettingsType type, double value) {
    if (type.type() != MPSettingsTypeType.double) {
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

  bool isDoubleSet(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.double) {
      throw ArgumentError(
        'MPSettingsType $type is not of type double at isDoubleSet',
      );
    }

    return _doubleSettings.containsKey(type);
  }

  void resetDouble(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.double) {
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

  bool setInt(MPSettingsType type, int value) {
    if (type.type() != MPSettingsTypeType.int) {
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

  bool isIntSet(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.int) {
      throw ArgumentError(
        'MPSettingsType $type is not of type int at isIntSet',
      );
    }

    return _intSettings.containsKey(type);
  }

  void resetInt(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.int) {
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

  bool setString(MPSettingsType type, String value) {
    if (type.type() != MPSettingsTypeType.string) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string at setString',
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

  bool isStringSet(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.string) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string at isStringSet',
      );
    }

    return _stringSettings.containsKey(type);
  }

  void resetString(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.string) {
      throw ArgumentError(
        'MPSettingsType $type is not of type string at resetString',
      );
    }

    if (_stringSettings.containsKey(type)) {
      _stringSettings.remove(type);
      prefs.remove(type.name);
      trigger(type);
    }
  }

  bool setStringList(MPSettingsType type, List<String> value) {
    if (type.type() != MPSettingsTypeType.stringList) {
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

  bool isStringListSet(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.stringList) {
      throw ArgumentError(
        'MPSettingsType $type is not of type stringList at isStringListSet',
      );
    }

    return _stringListSettings.containsKey(type);
  }

  void resetStringList(MPSettingsType type) {
    if (type.type() != MPSettingsTypeType.stringList) {
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

  int getTrigger(MPSettingsType type) => _settingsTriggers[type]!.value;

  @action
  void trigger(MPSettingsType type) {
    _settingsTriggers[type]!.value++;
  }
}
