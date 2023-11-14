import 'package:mapiah/src/th_elements/th_area.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THAreaBorder extends THElement {
  late String id;

  THAreaBorder(THParent parent, this.id) : super.withParent(parent) {
    if (parent is! THArea) {
      throw THCustomException(
          'THAreaBorder parent must be THArea, but it is ${parent.runtimeType}');
    }
  }
}
