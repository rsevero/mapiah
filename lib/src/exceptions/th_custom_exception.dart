class THCustomException implements Exception {
  String message;

  THCustomException(this.message);

  @override
  String toString() {
    return message;
  }
}
