import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/selection/th_selectable.dart';

class THElementSelectable extends THSelectable {
  final THElement element;

  THElementSelectable({
    required this.element,
    required super.position,
  }) : super();

  @override
  Object get selected => element;
}
