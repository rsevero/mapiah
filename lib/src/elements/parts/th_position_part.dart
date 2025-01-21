import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/th_numeric_helper.dart';
import 'package:mapiah/src/auxiliary/th_serializeable.dart';
import 'package:mapiah/src/exceptions/th_convert_from_list_exception.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

@serializable
class THPositionPart with Dataclass<THPositionPart> implements THSerializable {
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

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THPositionPart>(this);
  }

  factory THPositionPart.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THPositionPart>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THPositionPart>(this);
  }

  factory THPositionPart.fromJson(String jsonString) {
    return dogs.fromJson<THPositionPart>(jsonString);
  }

  @override
  THPositionPart copyWith({
    Offset? coordinates,
    int? decimalPositions,
  }) {
    return THPositionPart(
      coordinates: coordinates ?? this.coordinates,
      decimalPositions: decimalPositions ?? this.decimalPositions,
    );
  }

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
