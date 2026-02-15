class THBaseException implements Exception {
  final String message;
  final StackTrace stackTrace;
  static void Function(Object error, StackTrace stack)? _unhandledReporter;
  static bool _isReporting = false;

  THBaseException(this.message, [StackTrace? stackTrace])
    : stackTrace = stackTrace ?? StackTrace.current {
    _reportUnhandled();
  }

  static void registerUnhandledReporter(
    void Function(Object error, StackTrace stack)? reporter,
  ) {
    _unhandledReporter = reporter;
  }

  void _reportUnhandled() {
    final Function(Object, StackTrace)? reporter = _unhandledReporter;

    if (reporter == null || _isReporting) {
      return;
    }

    try {
      _isReporting = true;
      reporter(this, stackTrace);
    } finally {
      _isReporting = false;
    }
  }

  @override
  String toString() => message;
}
