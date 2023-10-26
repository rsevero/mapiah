import "package:mapiah/src/th_elements/th_element.dart";

class THUnknownCommand extends THElement {
  late final List<dynamic> _value;

  THUnknownCommand(super.parent, this._value) : super.withParent();

  get value {
    return _value;
  }
}
