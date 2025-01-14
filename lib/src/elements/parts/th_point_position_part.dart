import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_numeric_helper.dart';
import 'package:mapiah/src/exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

part 'th_point_position_part.mapper.dart';

@MappableClass()
class THPointPositionPart with THPointPositionPartMappable {
  late final Offset _position;
  late final int decimalPositions;

  THPointPositionPart(Offset position, this.decimalPositions) {
    _position = position;
  }

  THPointPositionPart.fromStrings(String xAsString, String yAsString) {
    _fromStrings(xAsString, yAsString);
  }

  THPointPositionPart.fromStringList(List<dynamic> list) {
    if (list.length != 2) {
      throw THConvertFromListException('THPointPart', list);
    }

    _fromStrings(list[0].toString(), list[1].toString());
  }

  void _fromStrings(String xAsString, String yAsString) {
    final THDoublePart xDoublePart = THDoublePart.fromString(xAsString);
    final THDoublePart yDoublePart = THDoublePart.fromString(yAsString);

    _position = Offset(xDoublePart.value, yDoublePart.value);
    decimalPositions =
        (xDoublePart.decimalPositions > yDoublePart.decimalPositions)
            ? xDoublePart.decimalPositions
            : yDoublePart.decimalPositions;
  }

  @override
  String toString() {
    return "${THNumericHelper.doubleToString(_position.dx, decimalPositions)} ${THNumericHelper.doubleToString(_position.dy, decimalPositions)}";
  }

  Offset get position => _position;

  double get x => _position.dx;

  double get y => _position.dy;
}
