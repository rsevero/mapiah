class THNoElementByIndexException implements Exception {
  String filename;
  int index;

  THNoElementByIndexException(this.filename, this.index);

  @override
  String toString() {
    return "No element with index '$index' in file '$filename'.";
  }
}
