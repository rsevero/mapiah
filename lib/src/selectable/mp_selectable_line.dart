part of 'mp_selectable.dart';

class MPSelectableLine extends MPSelectableElement {
  final List<THLineSegment> _selectedElements = [];
  final List<MPSelectableLineSegment> _seleactableLineSegments = [];

  MPSelectableLine({required THLine line, required super.th2fileEditController})
      : super(element: line) {
    final List<THLineSegment> lineSegments =
        th2fileEditController.getLineSegments(
      line: line,
      clone: false,
    );
    Offset? startPoint;

    for (final THLineSegment lineSegment in lineSegments) {
      if (startPoint == null) {
        startPoint = lineSegment.endPoint.coordinates;
        continue;
      }

      switch (lineSegment) {
        case THBezierCurveLineSegment _:
          _seleactableLineSegments.add(MPSelectableBezierCurveLineSegment(
            bezierCurveLineSegment: lineSegment,
            startPoint: startPoint,
            th2fileEditController: th2fileEditController,
          ));
          break;
        case THStraightLineSegment _:
          _seleactableLineSegments.add(MPSelectableStraightLineSegment(
            straightLineSegment: lineSegment,
            startPoint: startPoint,
            th2fileEditController: th2fileEditController,
          ));
          break;
        default:
          throw Exception(
              'Unknown line segment type: ${lineSegment.elementType}');
      }
      startPoint = lineSegment.endPoint.coordinates;
    }
  }

  @override
  Rect _calculateBoundingBox() {
    final Rect lineBoundingBox =
        (element as THLine).getBoundingBox(th2fileEditController);

    return MPNumericAux.orderedRectExpanded(
      rect: lineBoundingBox,
      delta: th2fileEditController.selectionToleranceOnCanvas,
    );
  }

  @override
  bool contains(Offset point) {
    if (!boundingBox.contains(point)) {
      return false;
    }

    _selectedElements.clear();
    bool isPointOnLine = false;

    for (final MPSelectableLineSegment selectableLineSegment
        in _seleactableLineSegments) {
      if (selectableLineSegment.contains(point)) {
        _selectedElements.add(selectableLineSegment.element as THLineSegment);
        isPointOnLine = true;
      }
    }

    return isPointOnLine;
  }

  @override
  List<THElement> get selectedElements => _selectedElements;
}
