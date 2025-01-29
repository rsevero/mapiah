import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/stores/mp_general_store.dart';
import 'package:mapiah/src/stores/mp_settings_store.dart';

class MPLocator {
  static final MPLocator _instance = MPLocator._internal();

  factory MPLocator() {
    return _instance;
  }

  MPLocator._internal();

  final MPGeneralStore mpGeneralStore = MPGeneralStore();

  final MPSettingsStore mpSettingsStore = MPSettingsStore();

  final MPLog mpLog = MPLog.instance;
}
