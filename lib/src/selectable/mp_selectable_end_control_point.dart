part of 'mp_selectable.dart';

class MPSelectableEndControlPoint extends MPSelectable
    with MPSeleactablePointMixin {
  final Offset position;
  final MPEndControlPointType type;

  MPSelectableEndControlPoint({
    required THLineSegment lineSegment,
    required super.th2fileEditController,
    required this.position,
    required this.type,
  }) : super(element: lineSegment);

  @override
  Rect _calculateBoundingBox() {
    return _calculatePointBoundingBox(position);
  }

  THLineSegment get lineSegment => element as THLineSegment;
}
