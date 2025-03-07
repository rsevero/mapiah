part of 'mp_selectable.dart';

enum MPSelectableControlPointType {
  controlPoint1,
  controlPoint2,
}

class MPSelectableControlPoint extends MPSelectableEndControlPoint {
  final MPSelectableControlPointType type;

  MPSelectableControlPoint({
    required super.lineSegment,
    required super.th2fileEditController,
    required super.position,
    required this.type,
  }) : super();
}
