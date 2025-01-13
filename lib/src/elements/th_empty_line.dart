import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_empty_line.mapper.dart';

@MappableClass()
class THEmptyLine extends THElement with THEmptyLineMappable {
  THEmptyLine(super.parent) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THEmptyLine;
  }
}
