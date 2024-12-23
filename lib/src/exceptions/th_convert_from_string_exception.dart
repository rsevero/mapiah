class THConvertFromStringException implements Exception {
  String objectNameToCreate;
  String originalString;

  THConvertFromStringException(this.objectNameToCreate, this.originalString);

  @override
  String toString() {
    return "Creation of a '$objectNameToCreate' from string '$originalString' failed.";
  }
}
