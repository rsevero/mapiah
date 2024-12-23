import "package:mapiah/src/elements/th_element.dart";

class THUnrecognizedCommand extends THElement {
  late final List<dynamic> _value;

  THUnrecognizedCommand(super.parent, this._value) : super.withParent();

  get value {
    return _value;
  }
}
