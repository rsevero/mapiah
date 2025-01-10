import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

part 'th_point_position_part.mapper.dart';

@MappableClass()
class THPointPositionPart with THPointPositionPartMappable {
  late final THDoublePart xDoublePart;
  late final THDoublePart yDoublePart;

  THPointPositionPart.fromTHDoubleParts(this.xDoublePart, this.yDoublePart);

  THPointPositionPart(
      double aX, double aY, int aXDecimalPositions, int aYDecimalPositions) {
    xDoublePart = THDoublePart(aX, aXDecimalPositions);
    yDoublePart = THDoublePart(aY, aYDecimalPositions);
  }

  THPointPositionPart.fromStrings(String aXAsString, String aYAsString) {
    xDoublePart = THDoublePart.fromString(aXAsString);
    yDoublePart = THDoublePart.fromString(aYAsString);
  }

  THPointPositionPart.fromStringList(List<dynamic> aList) {
    if (aList.length != 2) {
      throw THConvertFromListException('THPointPart', aList);
    }

    xDoublePart = THDoublePart.fromString(aList[0].toString());
    yDoublePart = THDoublePart.fromString(aList[1].toString());
  }

  @override
  String toString() {
    return "${xDoublePart.toString()} ${yDoublePart.toString()}";
  }

  double get x => xDoublePart.value;

  double get y => yDoublePart.value;

  set x(double newX) {
    xDoublePart.value = newX;
  }

  set y(double newY) {
    yDoublePart.value = newY;
  }
}
