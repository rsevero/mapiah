class MPTherionCache {
  static String? _cachedSearchedTherionExecutablePath;

  static String? get cachedSearchedTherionExecutablePath =>
      _cachedSearchedTherionExecutablePath;

  static void clearSearchedTherionExecutablePathCache() {
    _cachedSearchedTherionExecutablePath = null;
  }

  static void cacheSearchedTherionExecutablePath(String executablePath) {
    final String trimmed = executablePath.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _cachedSearchedTherionExecutablePath = trimmed;
  }
}
