import 'package:mapiah/src/th_elements/th_element.dart';

class THXTherionConfig extends THElement {
  String name;
  String value;

  THXTherionConfig(super.parent, this.name, this.value) : super.withParent();
}
