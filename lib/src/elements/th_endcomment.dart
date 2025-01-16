import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_endcomment.mapper.dart';

@MappableClass()
class THEndcomment extends THElement with THEndcommentMappable {
  // Used by dart_mappable.
  THEndcomment.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
  ) : super.notAddToParent();

  THEndcomment(super.parent) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THEndcomment;
  }
}
