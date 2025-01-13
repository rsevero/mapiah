import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'th_endarea.mapper.dart';

@MappableClass()
class THEndarea extends THElement with THEndareaMappable {
  THEndarea(super.parent) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THEndarea;
  }
}
