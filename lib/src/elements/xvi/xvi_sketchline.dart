import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

class XVISketchLine {
  String color;
  THPositionPart start;
  List<THPositionPart> points;

  XVISketchLine({
    required this.color,
    required this.start,
    required this.points,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is XVISketchLine &&
        color == other.color &&
        start == other.start &&
        const ListEquality().equals(points, other.points);
  }

  @override
  int get hashCode => Object.hash(
        color,
        start,
        const ListEquality().hash(points),
      );
}
