import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_area.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_area_border_thid.mapper.dart';

@MappableClass()
class THAreaBorderTHID extends THElement with THAreaBorderTHIDMappable {
  late String id;

  // Used by dart_mappable.
  THAreaBorderTHID.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    this.id,
  ) : super.notAddToParent();

  THAreaBorderTHID(super.parentMapiahID, this.id) : super() {
    if (parent is! THArea) {
      throw THCustomException(
          'THAreaBorder parent must be THArea, but it is ${parent.runtimeType}');
    }
  }

  @override
  bool isSameClass(Object object) {
    return object is THAreaBorderTHID;
  }
}
