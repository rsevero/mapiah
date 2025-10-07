import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

class XVISketchLine {
  String color;
  THPositionPart start;
  List<THPositionPart> points;

  static const _listEquality = ListEquality();

  XVISketchLine({
    required this.color,
    required this.start,
    required this.points,
  });

  /// Returns a map representation of this XVISketchLine instance
  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'start': start.toMap(),
      'points': points.map((point) => point.toMap()).toList(),
    };
  }

  /// Creates an XVISketchLine instance from a map
  static XVISketchLine fromMap(Map<String, dynamic> map) {
    return XVISketchLine(
      color: map['color'] ?? '',
      start: THPositionPart.fromMap(map['start']),
      points: (map['points'] as List<dynamic>)
          .map((point) => THPositionPart.fromMap(point))
          .toList(),
    );
  }

  /// Creates an XVISketchLine instance from a JSON string
  static XVISketchLine fromJson(String source) => fromMap(jsonDecode(source));

  /// Returns a JSON string representation of this XVISketchLine instance
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of this XVISketchLine with the given fields replaced with new values
  XVISketchLine copyWith({
    String? color,
    THPositionPart? start,
    List<THPositionPart>? points,
  }) {
    return XVISketchLine(
      color: color ?? this.color,
      start: start ?? this.start,
      points: points ?? this.points,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is XVISketchLine &&
        color == other.color &&
        start == other.start &&
        _listEquality.equals(points, other.points);
  }

  @override
  int get hashCode => Object.hash(color, start, _listEquality.hash(points));
}
