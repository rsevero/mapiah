class THCreateObjectFromNullValueException implements Exception {
  String objectType;

  THCreateObjectFromNullValueException(this.objectType);

  @override
  String toString() {
    return "Can´t create object of type '$objectType' from null.";
  }
}
