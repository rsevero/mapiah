import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_multiline_comment_content.mapper.dart';

@MappableClass()
class THMultilineCommentContent extends THElement
    with THMultilineCommentContentMappable {
  String content;

  THMultilineCommentContent(super.parent, this.content) : super.withParent();
}
