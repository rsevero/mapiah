import 'package:mapiah/src/elements/th_element.dart';

class THXTherionConfig extends THElement {
  String name;
  String value;

  THXTherionConfig(super.parent, this.name, this.value) : super.withParent();
}
