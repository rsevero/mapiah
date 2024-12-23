class THConvertFromListException implements Exception {
  String objectNameToCreate;
  List<dynamic> originalList;

  THConvertFromListException(this.objectNameToCreate, this.originalList);

  @override
  String toString() {
    var stringList = '';

    for (final aString in originalList) {
      stringList += "-> '$aString'\n";
    }

    stringList = '''Creation of a '$objectNameToCreate' from list below failed:

$stringList

''';

    return stringList;
  }
}
