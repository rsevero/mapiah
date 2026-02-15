class THBaseException implements Exception {
  final String message;
  final StackTrace stackTrace;

  THBaseException(this.message, [StackTrace? stackTrace])
    : stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() => '$message\nStackTrace: $stackTrace';
}
