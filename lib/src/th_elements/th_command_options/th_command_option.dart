import 'package:mapiah/src/th_elements/th_element.dart';

abstract class THCommandOption {
  final List<dynamic> value;
  final THElement parent;
  int index = -2;

  THCommandOption(this.parent, this.value);

  String type();

  @override
  String toString() {
    return "-${type()} ${value.toString()}";
  }
}
