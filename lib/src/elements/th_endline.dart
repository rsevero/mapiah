import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'th_endline.mapper.dart';

@MappableClass()
class THEndline extends THElement with THEndlineMappable {
  // Used by dart_mappable.
  THEndline.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
  ) : super.notAddToParent();

  THEndline(super.parentMapiahID) : super.addToParent();

  @override
  bool isSameClass(Object object) {
    return object is THEndline;
  }
}
