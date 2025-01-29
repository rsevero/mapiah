import 'package:mapiah/src/stores/mp_general_store.dart';

class MPLocator {
  static final MPLocator _instance = MPLocator._internal();

  factory MPLocator() {
    return _instance;
  }

  MPLocator._internal();

  final MPGeneralStore mpGeneralStore = MPGeneralStore();
}
