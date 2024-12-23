class THCreateObjectWithoutListException implements Exception {
  String objectType;
  dynamic originalInfo;

  THCreateObjectWithoutListException(this.objectType, this.originalInfo);

  @override
  String toString() {
    return "Can´t create object of type '$objectType' from '$originalInfo.";
  }
}
