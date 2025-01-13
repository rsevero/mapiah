import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_endscrap.mapper.dart';

@MappableClass()
class THEndscrap extends THElement with THEndscrapMappable {
  THEndscrap(super.parent) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THEndscrap;
  }
}
