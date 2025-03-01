part of 'mp_selectable.dart';

abstract class MPSelectableElement extends MPSelectable {
  MPSelectableElement({
    required super.element,
    required super.th2fileEditController,
  }) : super();

  List<THElement> get selectedElements;
}
