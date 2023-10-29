class THCreateObjectFromListWithWrongLengthException implements Exception {
  String objectType;
  List<dynamic> aList;
  String exceptedLength;

  THCreateObjectFromListWithWrongLengthException(
      this.objectType, this.exceptedLength, this.aList);

  @override
  String toString() {
    var message =
        '''Can´t create object of type '$objectType' from list with length '${aList.length}'.
Expecting $exceptedLength elements. List received:

''';

    for (final element in aList) {
      message += "$element\n";
    }

    message += '\n';

    return message;
  }
}
