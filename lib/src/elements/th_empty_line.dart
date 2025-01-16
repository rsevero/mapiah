import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_empty_line.mapper.dart';

@MappableClass()
class THEmptyLine extends THElement with THEmptyLineMappable {
  // Used by dart_mappable.
  THEmptyLine.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
  ) : super.notAddToParent();

  THEmptyLine(super.parent) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THEmptyLine;
  }
}
