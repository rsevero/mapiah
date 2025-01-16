import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_comment.mapper.dart';

@MappableClass()
class THComment extends THElement with THCommentMappable {
  String content;

  // Used by dart_mappable.
  THComment.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    this.content,
  ) : super.notAddToParent();

  THComment(super.parent, this.content) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THComment;
  }
}
