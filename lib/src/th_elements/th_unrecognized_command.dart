import "package:mapiah/src/th_elements/th_element.dart";

class THUnrecognizedCommand extends THElement {
  late final List<dynamic> _value;

  THUnrecognizedCommand(super.parent, this._value) : super.withParent();

  get value {
    return _value;
  }

  @override
  String toString() {
    var asString = '';

    for (var item in _value) {
      asString += " $item";
    }

    if (asString.isNotEmpty) {
      asString = asString.substring(1);
    }

    return super.toString();
  }
}
