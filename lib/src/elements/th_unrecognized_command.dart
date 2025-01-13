import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_unrecognized_command.mapper.dart';

@MappableClass()
class THUnrecognizedCommand extends THElement
    with THUnrecognizedCommandMappable {
  late final List<dynamic> _value;

  THUnrecognizedCommand(super.parent, List<dynamic> value)
      : _value = value,
        super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THUnrecognizedCommand;
  }

  get value {
    return _value;
  }
}
