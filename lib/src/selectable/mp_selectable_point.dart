part of 'mp_selectable.dart';

class MPSelectablePoint extends MPSelectableElement
    with MPSeleactablePointMixin {
  MPSelectablePoint({
    required THPoint point,
    required super.th2fileEditController,
  }) : super(element: point);

  @override
  Rect _calculateBoundingBox() {
    return _calculatePointBoundingBox(
      (element as THPoint).position.coordinates,
    );
  }

  @override
  List<THElement> get selectedElements => List<THPoint>.from([element]);
}
