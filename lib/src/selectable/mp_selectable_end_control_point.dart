part of 'mp_selectable.dart';

abstract class MPSelectableEndControlPoint extends MPSelectable
    with MPSeleactablePointMixin {
  final Offset position;

  MPSelectableEndControlPoint({
    required THLineSegment lineSegment,
    required super.th2fileEditController,
    required this.position,
  }) : super(element: lineSegment);

  @override
  Rect _calculateBoundingBox() {
    return _calculatePointBoundingBox(position);
  }
}
