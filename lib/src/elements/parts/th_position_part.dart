import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/offset_mapper.dart';
import 'package:mapiah/src/auxiliary/th_numeric_helper.dart';
import 'package:mapiah/src/exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

part 'th_position_part.mapper.dart';

@MappableClass(includeCustomMappers: [OffsetMapper()])
class THPositionPart with THPositionPartMappable {
  late final Offset _coordinates;
  late final int decimalPositions;

  THPositionPart(Offset coordinates, this.decimalPositions) {
    _coordinates = coordinates;
  }

  THPositionPart.fromStrings(String xAsString, String yAsString) {
    _fromStrings(xAsString, yAsString);
  }

  THPositionPart.fromStringList(List<dynamic> list) {
    if (list.length != 2) {
      throw THConvertFromListException('THPointPart', list);
    }

    _fromStrings(list[0].toString(), list[1].toString());
  }

  void _fromStrings(String xAsString, String yAsString) {
    final THDoublePart xDoublePart = THDoublePart.fromString(xAsString);
    final THDoublePart yDoublePart = THDoublePart.fromString(yAsString);

    _coordinates = Offset(xDoublePart.value, yDoublePart.value);
    decimalPositions =
        (xDoublePart.decimalPositions > yDoublePart.decimalPositions)
            ? xDoublePart.decimalPositions
            : yDoublePart.decimalPositions;
  }

  @override
  String toString() {
    return "${THNumericHelper.doubleToString(_coordinates.dx, decimalPositions)} ${THNumericHelper.doubleToString(_coordinates.dy, decimalPositions)}";
  }

  Offset get coordinates => _coordinates;

  double get x => _coordinates.dx;

  double get y => _coordinates.dy;
}
