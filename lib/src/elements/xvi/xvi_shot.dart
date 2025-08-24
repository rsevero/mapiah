import 'dart:convert';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

class XVIShot {
  final THPositionPart start;
  final THPositionPart end;

  XVIShot({required this.start, required this.end});

  /// Returns a map representation of this XVIShot instance
  Map<String, dynamic> toMap() {
    return {'start': start.toMap(), 'end': end.toMap()};
  }

  /// Creates an XVIShot instance from a map
  static XVIShot fromMap(Map<String, dynamic> map) {
    return XVIShot(
      start: THPositionPart.fromMap(map['start']),
      end: THPositionPart.fromMap(map['end']),
    );
  }

  /// Creates an XVIShot instance from a JSON string
  static XVIShot fromJson(String source) => fromMap(jsonDecode(source));

  /// Returns a JSON string representation of this XVIShot instance
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of this XVIShot with the given fields replaced with new values
  XVIShot copyWith({THPositionPart? start, THPositionPart? end}) {
    return XVIShot(start: start ?? this.start, end: end ?? this.end);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XVIShot && (start == other.start) && (end == other.end));

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
