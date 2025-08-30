part of 'mp_selectable.dart';

class MPSelectableScrap extends MPSelectableElement {
  MPSelectableScrap({
    required THScrap scrap,
    required super.th2fileEditController,
  }) : super(element: scrap);

  @override
  Rect _calculateBoundingBox() {
    final Rect scrapBoundingBox = (element as THScrap).getBoundingBox(
      th2fileEditController,
    );

    return MPNumericAux.orderedRectExpandedByDelta(
      rect: scrapBoundingBox,
      delta: th2fileEditController.selectionToleranceOnCanvas,
    );
  }

  @override
  List<THElement> get selectedElements => List<THScrap>.from([element]);

  @override
  bool contains(Offset point) {
    return boundingBox.contains(point);
  }
}
