import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/selection/th_selectable.dart';

class THSelectableElement extends THSelectable {
  THElement element;

  THSelectableElement({
    required this.element,
    required super.position,
  }) : super();

  @override
  Object get selected => element;
}
