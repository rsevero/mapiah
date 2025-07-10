import 'package:mapiah/src/elements/parts/th_position_part.dart';

class XVIShot {
  final THPositionPart start;
  final THPositionPart end;

  XVIShot({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XVIShot && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
