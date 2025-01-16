import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_unrecognized_command.mapper.dart';

@MappableClass()
class THUnrecognizedCommand extends THElement
    with THUnrecognizedCommandMappable {
  late final List<dynamic> _value;

  // Used by dart_mappable.
  THUnrecognizedCommand.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    List<dynamic> value,
  ) : super.notAddToParent() {
    _value = value;
  }

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
