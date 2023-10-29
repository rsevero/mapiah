class THDuplicateIDException implements Exception {
  String duplicateID;
  String filename;

  THDuplicateIDException(this.duplicateID, this.filename);

  @override
  toString() {
    return "Duplicate ID '$duplicateID' in file '$filename'";
  }
}
