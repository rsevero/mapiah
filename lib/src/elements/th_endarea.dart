import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'th_endarea.mapper.dart';

@MappableClass()
class THEndarea extends THElement with THEndareaMappable {
  // Used by dart_mappable.
  THEndarea.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
  ) : super.notAddToParent();

  THEndarea(super.parentMapiahID) : super();

  @override
  bool isSameClass(Object object) {
    return object is THEndarea;
  }
}
