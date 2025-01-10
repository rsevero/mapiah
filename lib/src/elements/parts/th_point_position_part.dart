import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

part 'th_point_position_part.mapper.dart';

@MappableClass()
class THPointPositionPart with THPointPositionPartMappable {
  late final THDoublePart xDoublePart;
  late final THDoublePart yDoublePart;

  THPointPositionPart(
      double x, double y, int xDecimalPositions, int yDecimalPositions) {
    xDoublePart = THDoublePart(x, xDecimalPositions);
    yDoublePart = THDoublePart(y, yDecimalPositions);
  }

  THPointPositionPart.fromStrings(String xAsString, String yAsString) {
    xDoublePart = THDoublePart.fromString(xAsString);
    yDoublePart = THDoublePart.fromString(yAsString);
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

  int get xDecimalPositions => xDoublePart.decimalPositions;

  int get yDecimalPositions => yDoublePart.decimalPositions;

  set x(double x) {
    xDoublePart.value = x;
  }

  set y(double y) {
    yDoublePart.value = y;
  }
}
