import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_endscrap.mapper.dart';

@MappableClass()
class THEndscrap extends THElement with THEndscrapMappable {
  // Used by dart_mappable.
  THEndscrap.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
  ) : super.notAddToParent();

  THEndscrap(super.parentMapiahID) : super();

  @override
  bool isSameClass(Object object) {
    return object is THEndscrap;
  }
}
