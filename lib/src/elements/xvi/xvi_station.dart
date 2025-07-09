import 'package:mapiah/src/elements/parts/th_position_part.dart';

class XVIStation {
  final THPositionPart position;
  final String name;

  XVIStation({
    required this.position,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XVIStation && position == other.position && name == other.name;

  @override
  int get hashCode => Object.hash(position, name);
}
