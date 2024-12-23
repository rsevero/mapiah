class THNoElementByMapiahIDException implements Exception {
  String filename;
  int index;

  THNoElementByMapiahIDException(this.filename, this.index);

  @override
  String toString() {
    return "No element with index '$index' in file '$filename'.";
  }
}
