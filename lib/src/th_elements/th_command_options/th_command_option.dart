import 'package:mapiah/src/th_elements/th_element.dart';

class THCommandOption {
  final List<dynamic> value;
  final THElement parent;
  int index = -2;

  THCommandOption(this.parent, this.value);

  String type() {
    return runtimeType.toString().substring(2);
  }
}
