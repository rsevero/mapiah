import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

// [[LINE DATA] specify the coordinates of a Bézier curve arc:
// <c1x> <c1y> <c2x> <c2y> <x> <y>, where c indicates the control point.
@serializable
class THBezierCurveLineSegment extends THLineSegment
    with Dataclass<THBezierCurveLineSegment>, THHasOptions {
  late final THPositionPart controlPoint1;
  late final THPositionPart controlPoint2;

  // Used by dart_mappable.
  THBezierCurveLineSegment({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.controlPoint1,
    required this.controlPoint2,
    required super.endPoint,
    required super.optionsMap,
  }) : super();

  THBezierCurveLineSegment.addToParent({
    required super.parentMapiahID,
    super.sameLineComment,
    required this.controlPoint1,
    required this.controlPoint2,
    required super.endPoint,
  }) : super.withEndPoint();

  THBezierCurveLineSegment.fromString({
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> controlPoint1,
    required List<dynamic> controlPoint2,
    required List<dynamic> endPoint,
  }) : super.withoutEndPoint() {
    this.controlPoint1 = THPositionPart.fromStringList(list: controlPoint1);
    this.controlPoint2 = THPositionPart.fromStringList(list: controlPoint2);
    this.endPoint = THPositionPart.fromStringList(list: endPoint);
  }

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THBezierCurveLineSegment>(this);
  }

  factory THBezierCurveLineSegment.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THBezierCurveLineSegment>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THBezierCurveLineSegment>(this);
  }

  factory THBezierCurveLineSegment.fromJson(String jsonString) {
    return dogs.fromJson<THBezierCurveLineSegment>(jsonString);
  }

  @override
  THBezierCurveLineSegment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    THPositionPart? endPoint,
    THPositionPart? controlPoint1,
    THPositionPart? controlPoint2,
    LinkedHashMap<String, THCommandOption>? optionsMap,
  }) {
    return THBezierCurveLineSegment(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: sameLineComment ?? this.sameLineComment,
      endPoint: endPoint ?? this.endPoint,
      controlPoint1: controlPoint1 ?? this.controlPoint1,
      controlPoint2: controlPoint2 ?? this.controlPoint2,
      optionsMap: optionsMap ??
          LinkedHashMap<String, THCommandOption>.from(this.optionsMap),
    );
  }

  @override
  bool isSameClass(Object object) {
    return object is THBezierCurveLineSegment;
  }

  double get controlPoint1X {
    return controlPoint1.coordinates.dx;
  }

  double get controlPoint1Y {
    return controlPoint1.coordinates.dy;
  }

  int get controlPoint1DecimalPositions {
    return controlPoint1.decimalPositions;
  }

  set controlPoint1DecimalPositions(int decimalPositions) {
    controlPoint1.decimalPositions = decimalPositions;
  }

  double get controlPoint2X {
    return controlPoint2.coordinates.dx;
  }

  double get controlPoint2Y {
    return controlPoint2.coordinates.dy;
  }

  int get controlPoint2DecimalPositions {
    return controlPoint2.decimalPositions;
  }

  set controlPoint2DecimalPositions(int decimalPositions) {
    controlPoint2.decimalPositions = decimalPositions;
  }
}
