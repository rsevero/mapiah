class THNoElementByMPIDException implements Exception {
  String filename;
  int index;

  THNoElementByMPIDException(this.filename, this.index);

  @override
  String toString() {
    return "No element with index '$index' in file '$filename'.";
  }
}
