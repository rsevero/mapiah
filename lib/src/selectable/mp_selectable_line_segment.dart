part of 'mp_selectable.dart';

abstract class MPSelectableLineSegment extends MPSelectable {
  final Offset startPoint;

  MPSelectableLineSegment({
    required THLineSegment lineSegment,
    required this.startPoint,
    required super.th2fileEditStore,
  }) : super(element: lineSegment);

  @override
  Rect _calculateBoundingBox() {
    final Rect lineBoundingBox =
        (element as THLineSegment).getBoundingBox(startPoint);

    return MPNumericAux.orderedRectExpanded(
      rect: lineBoundingBox,
      delta: th2fileEditStore.selectionToleranceOnCanvas,
    );
  }

  @override
  bool contains(Offset point) {
    if (!boundingBox.contains(point)) {
      return false;
    }

    return _isPointOnLine(point);
  }

  bool _isPointOnLine(Offset point);
}
