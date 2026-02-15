import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THConvertFromListException extends THBaseException {
  final String objectNameToCreate;
  final List<dynamic> originalList;

  THConvertFromListException(this.objectNameToCreate, this.originalList)
    : super(_buildMessage(objectNameToCreate, originalList));

  static String _buildMessage(
    String objectNameToCreate,
    List<dynamic> originalList,
  ) {
    String stringList = '';

    for (final String aString in originalList) {
      stringList += "-> '$aString'\n";
    }

    return '''Creation of a '$objectNameToCreate' from list below failed:

$stringList

''';
  }
}
