class THElementByIndexMissingException implements Exception {
  String filename;
  int index;

  THElementByIndexMissingException(this.filename, this.index);

  @override
  String toString() {
    return "No element with index '$index' in file '$filename'.";
  }
}
