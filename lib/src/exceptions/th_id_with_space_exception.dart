class THIDWithSpaceException implements Exception {
  String id;
  String elementType;

  THIDWithSpaceException(this.elementType, this.id);

  @override
  String toString() {
    return "Spaces not allowed in IDs: '$id'. Element type: '$elementType'";
  }
}
