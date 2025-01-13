import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_multilinecomment.mapper.dart';

@MappableClass()
class THMultiLineComment extends THElement
    with THMultiLineCommentMappable, THParent {
  THMultiLineComment(super.parent) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THMultiLineComment;
  }
}
