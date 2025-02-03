part of 'mp_selectable.dart';

class MPSelectableLine extends MPSelectable {
  final List<THLineSegment> _selectedElements = [];
  final List<MPSelectableLineSegment> _seleactableLineSegments = [];

  MPSelectableLine({required THLine line, required super.th2fileEditStore})
      : super(element: line) {
    final List<int> lineSegmentMapiahIDs = line.childrenMapiahID;
    final THFile thFile = th2fileEditStore.thFile;
    Offset? startPoint;

    for (final int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is! THLineSegment) {
        continue;
      }

      if (startPoint == null) {
        startPoint = lineSegment.endPoint.coordinates;
        continue;
      }

      switch (lineSegment) {
        case THBezierCurveLineSegment _:
          _seleactableLineSegments.add(MPSelectableBezierCurveLineSegment(
            bezierCurveLineSegment: lineSegment,
            startPoint: startPoint,
            th2fileEditStore: th2fileEditStore,
          ));
          break;
        case THStraightLineSegment _:
          _seleactableLineSegments.add(MPSelectableStraightLineSegment(
            straightLineSegment: lineSegment,
            startPoint: startPoint,
            th2fileEditStore: th2fileEditStore,
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
        (element as THLine).getBoundingBox(th2fileEditStore);

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
