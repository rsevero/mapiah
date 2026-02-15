import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THCreateObjectFromListWithWrongLengthException extends THBaseException {
  final List<dynamic> aList;
  final String exceptedLength;

  THCreateObjectFromListWithWrongLengthException(
    this.exceptedLength,
    this.aList,
  ) : super(_buildMessage(exceptedLength, aList));

  static String _buildMessage(String exceptedLength, List<dynamic> aList) {
    String message =
        """Can´t create object from list with length '${aList.length}'.
Expecting $exceptedLength elements. List received:

""";

    for (final element in aList) {
      message += "$element\n";
    }

    message += '\n';

    return message;
  }
}
