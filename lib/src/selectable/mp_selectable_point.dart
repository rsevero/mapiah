part of 'mp_selectable.dart';

class MPSelectablePoint extends MPSelectable {
  MPSelectablePoint({required THPoint point, required super.th2fileEditStore})
      : super(element: point);

  @override
  Rect _calculateBoundingBox() {
    final Rect pointBoundingBox =
        (element as THPoint).getBoundingBox(th2fileEditStore);

    return MPNumericAux.orderedRectExpanded(
      rect: pointBoundingBox,
      delta: th2fileEditStore.selectionToleranceOnCanvas,
    );
  }

  @override
  bool contains(Offset point) {
    return boundingBox.contains(point);
  }

  @override
  List<THElement> get selectedElements => List<THPoint>.from([element]);
}
