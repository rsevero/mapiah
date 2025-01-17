import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_numeric_helper.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

class THPositionPart {
  late final Offset coordinates;
  late final int decimalPositions;

  THPositionPart({
    required this.coordinates,
    required this.decimalPositions,
  });

  THPositionPart.fromStrings({
    required String xAsString,
    required String yAsString,
  }) {
    _fromStrings(xAsString, yAsString);
  }

  THPositionPart.fromStringList({required List<dynamic> list}) {
    if (list.length != 2) {
      throw THConvertFromListException('THPointPart', list);
    }

    _fromStrings(list[0].toString(), list[1].toString());
  }

  THPositionPart copyWith({
    Offset? coordinates,
    int? decimalPositions,
  }) {
    return THPositionPart(
      coordinates: coordinates ?? this.coordinates,
      decimalPositions: decimalPositions ?? this.decimalPositions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coordinates': {
        'x': coordinates.dx.toStringAsFixed(thDecimalPositionsForOffsetMapper),
        'y': coordinates.dy.toStringAsFixed(thDecimalPositionsForOffsetMapper),
      },
      'decimalPositions': decimalPositions,
    };
  }

  @override
  bool operator ==(covariant THPositionPart other) {
    if (identical(this, other)) return true;

    return other.coordinates == coordinates &&
        other.decimalPositions == decimalPositions;
  }

  @override
  int get hashCode => Object.hash(coordinates, decimalPositions);

  void _fromStrings(String xAsString, String yAsString) {
    final THDoublePart xDoublePart = THDoublePart.fromString(xAsString);
    final THDoublePart yDoublePart = THDoublePart.fromString(yAsString);

    coordinates = Offset(xDoublePart.value, yDoublePart.value);
    decimalPositions =
        (xDoublePart.decimalPositions > yDoublePart.decimalPositions)
            ? xDoublePart.decimalPositions
            : yDoublePart.decimalPositions;
  }

  @override
  String toString() {
    return "${THNumericHelper.doubleToString(coordinates.dx, decimalPositions)} ${THNumericHelper.doubleToString(coordinates.dy, decimalPositions)}";
  }

  double get x => coordinates.dx;

  double get y => coordinates.dy;
}
