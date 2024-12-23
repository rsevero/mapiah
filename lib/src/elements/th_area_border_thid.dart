import 'package:mapiah/src/elements/th_area.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THAreaBorderTHID extends THElement {
  late String id;

  THAreaBorderTHID(THParent parent, this.id) : super.withParent(parent) {
    if (parent is! THArea) {
      throw THCustomException(
          'THAreaBorder parent must be THArea, but it is ${parent.runtimeType}');
    }
  }
}
