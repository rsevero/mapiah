import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/selection/mp_selectable.dart';

class MPSelectableElement extends MPSelectable {
  THElement element;

  MPSelectableElement({
    required this.element,
    required super.position,
  }) : super();

  @override
  Object get selected => element;
}
