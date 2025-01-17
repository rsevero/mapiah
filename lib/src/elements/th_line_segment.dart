import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_point_interface.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

// [LINE DATA] specify the coordinates of a line segment <x> <y>.
abstract class THLineSegment extends THElement
    implements THPointInterface, THHasOptions {
  late final THPositionPart endPoint;

  THLineSegment({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
    required LinkedHashMap<String, THCommandOption> optionsMap,
  }) : super() {
    addOptionsMap(optionsMap);
  }

  THLineSegment.withEndPoint({
    required super.parentMapiahID,
    super.sameLineComment,
    required this.endPoint,
  }) : super.addToParent();

  THLineSegment.withoutEndPoint({
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super.addToParent();

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'endPoint': endPoint.toMap(),
      'optionsMap':
          optionsMap.map((key, value) => MapEntry(key, value.toMap())),
    });
    return map;
  }

  @override
  bool operator ==(covariant THLineSegment other) {
    if (identical(this, other)) return true;

    return super == other &&
        endPoint == other.endPoint &&
        const MapEquality<String, THCommandOption>()
            .equals(optionsMap, other.optionsMap);
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        endPoint,
        Object.hashAll(optionsMap.entries),
      );

  @override
  String get elementType {
    return 'linesegment';
  }

  @override
  double get x {
    return endPoint.coordinates.dx;
  }

  @override
  double get y {
    return endPoint.coordinates.dy;
  }

  int get endPointDecimalPositions {
    return endPoint.decimalPositions;
  }
}
