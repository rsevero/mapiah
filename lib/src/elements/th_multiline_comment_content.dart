import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_multiline_comment_content.mapper.dart';

@MappableClass()
class THMultilineCommentContent extends THElement
    with THMultilineCommentContentMappable {
  String content;

  // Used by dart_mappable.
  THMultilineCommentContent.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    this.content,
  ) : super.notAddToParent();

  THMultilineCommentContent(super.parentMapiahID, this.content) : super();

  @override
  bool isSameClass(Object object) {
    return object is THMultilineCommentContent;
  }
}
