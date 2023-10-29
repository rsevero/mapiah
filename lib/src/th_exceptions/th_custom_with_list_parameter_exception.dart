class THCustomWithListParameterException implements Exception {
  String message;
  List<dynamic> aList;

  THCustomWithListParameterException(this.message, this.aList);

  @override
  String toString() {
    var asString = '$message\nList:\n';

    for (final item in aList) {
      asString += "$item\n";
    }

    asString += '\n';

    return asString;
  }
}
