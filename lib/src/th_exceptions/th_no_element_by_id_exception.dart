class THNoElementByIDException implements Exception {
  String id;
  String elementType;
  String filename;

  THNoElementByIDException(this.elementType, this.id, this.filename);

  @override
  toString() {
    return "No element of type '$elementType' with ID '$id' in file '$filename'";
  }
}
