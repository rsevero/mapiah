import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class THTestAux {
  static bool _isInitialized = false;

  static bool ensureTestEnvironment() {
    if (_isInitialized) {
      return true;
    }

    _isInitialized = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    return true;
  }

  static String testPath(String filename) {
    return "./test/auxiliary/$filename";
  }

  static bool areCommandOptionsMapsEquivalent({
    required SplayTreeMap<THCommandOptionType, THCommandOption> firstOptionsMap,
    required SplayTreeMap<THCommandOptionType, THCommandOption>
    secondOptionsMap,
    int parentMPID = 1,
    String originalLineInTH2File = '',
  }) {
    final int firstLength = firstOptionsMap.length;
    final int secondLength = secondOptionsMap.length;

    if (firstLength != secondLength) {
      return false;
    }

    for (final MapEntry<THCommandOptionType, THCommandOption> firstEntry
        in firstOptionsMap.entries) {
      final THCommandOptionType optionType = firstEntry.key;

      if (!secondOptionsMap.containsKey(optionType)) {
        return false;
      }

      final THCommandOption firstOption = firstEntry.value;
      final THCommandOption secondOption = secondOptionsMap[optionType]!;

      final THCommandOption normalizedFirstOption = firstOption.copyWith(
        parentMPID: parentMPID,
        originalLineInTH2File: originalLineInTH2File,
      );
      final THCommandOption normalizedSecondOption = secondOption.copyWith(
        parentMPID: parentMPID,
        originalLineInTH2File: originalLineInTH2File,
      );

      if (normalizedFirstOption != normalizedSecondOption) {
        return false;
      }
    }

    return true;
  }

  static bool areAttrCommandOptionsMapsEquivalent({
    required SplayTreeMap<String, THAttrCommandOption> firstAttrOptionsMap,
    required SplayTreeMap<String, THAttrCommandOption> secondAttrOptionsMap,
    int parentMPID = 1,
    String originalLineInTH2File = '',
  }) {
    final int firstLength = firstAttrOptionsMap.length;
    final int secondLength = secondAttrOptionsMap.length;

    if (firstLength != secondLength) {
      return false;
    }

    for (final MapEntry<String, THAttrCommandOption> firstEntry
        in firstAttrOptionsMap.entries) {
      final String attrName = firstEntry.key;

      if (!secondAttrOptionsMap.containsKey(attrName)) {
        return false;
      }

      final THAttrCommandOption firstAttrOption = firstEntry.value;
      final THAttrCommandOption secondAttrOption =
          secondAttrOptionsMap[attrName]!;

      final THAttrCommandOption normalizedFirstAttrOption = firstAttrOption
          .copyWith(
            parentMPID: parentMPID,
            originalLineInTH2File: originalLineInTH2File,
          );
      final THAttrCommandOption normalizedSecondAttrOption = secondAttrOption
          .copyWith(
            parentMPID: parentMPID,
            originalLineInTH2File: originalLineInTH2File,
          );

      if (normalizedFirstAttrOption != normalizedSecondAttrOption) {
        return false;
      }
    }

    return true;
  }
}

// Initialize shared prefs for tests on import to avoid per-test boilerplate.
// ignore: unused_element
final bool _thTestAuxInit = THTestAux.ensureTestEnvironment();
