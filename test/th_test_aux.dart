import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

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
}

// Initialize shared prefs for tests on import to avoid per-test boilerplate.
// ignore: unused_element
final bool _thTestAuxInit = THTestAux.ensureTestEnvironment();
