import 'package:mapiah/src/th_exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/th_elements/parts/th_double_part.dart';

class THPointPart {
  late final THDoublePart x;
  late final THDoublePart y;

  THPointPart(aX, aY, aXDecimalPositions, aYDecimalPositions) {
    x = THDoublePart(aX, aXDecimalPositions);
    y = THDoublePart(aY, aYDecimalPositions);
  }

  THPointPart.fromStrings(String aXAsString, String aYAsString) {
    x = THDoublePart.fromString(aXAsString);
    y = THDoublePart.fromString(aYAsString);
  }

  THPointPart.fromStringList(List<dynamic> aList) {
    if (aList.length != 2) {
      throw THConvertFromListException('THPointPart', aList);
    }

    x = THDoublePart.fromString(aList[0].toString());
    y = THDoublePart.fromString(aList[1].toString());
  }

  @override
  String toString() {
    return "${x.toString()} ${y.toString()}";
  }
}
