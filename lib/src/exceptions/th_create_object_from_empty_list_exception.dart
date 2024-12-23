class THCreateObjectFromListWithWrongLengthException implements Exception {
  List<dynamic> aList;
  String exceptedLength;

  THCreateObjectFromListWithWrongLengthException(
      this.exceptedLength, this.aList);

  @override
  String toString() {
    var message =
        '''Can´t create object from list with length '${aList.length}'.
Expecting $exceptedLength elements. List received:

''';

    for (final element in aList) {
      message += "$element\n";
    }

    message += '\n';

    return message;
  }
}
