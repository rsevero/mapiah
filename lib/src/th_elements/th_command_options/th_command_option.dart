import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';

abstract class THCommandOption {
  final List<dynamic> value;
  final THHasOptions parent;
  int index = -2;

  THCommandOption(this.parent, this.value) {
    parent.addUpdateOption(this);
  }

  String type();

  String valueToString() {
    return value.toString();
  }

  @override
  String toString() {
    return "-${type()} ${valueToString()}";
  }
}
