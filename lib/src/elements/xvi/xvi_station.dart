import 'dart:convert';
import 'package:mapiah/src/elements/parts/th_position_part.dart';

class XVIStation {
  final THPositionPart position;
  final String name;

  XVIStation({required this.position, required this.name});

  /// Returns a map representation of this XVIStation instance
  Map<String, dynamic> toMap() {
    return {'position': position.toMap(), 'name': name};
  }

  /// Creates an XVIStation instance from a map
  static XVIStation fromMap(Map<String, dynamic> map) {
    return XVIStation(
      position: THPositionPart.fromMap(map['position']),
      name: map['name'] ?? '',
    );
  }

  /// Creates an XVIStation instance from a JSON string
  static XVIStation fromJson(String source) => fromMap(jsonDecode(source));

  /// Returns a JSON string representation of this XVIStation instance
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of this XVIStation with the given fields replaced with new values
  XVIStation copyWith({THPositionPart? position, String? name}) {
    return XVIStation(
      position: position ?? this.position,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XVIStation &&
          (position == other.position) &&
          (name == other.name));

  @override
  int get hashCode => Object.hash(position, name);
}
