import "package:mapiah/src/elements/th_element.dart";

class THMultilineCommentContent extends THElement {
  String content;

  THMultilineCommentContent(super.parent, this.content) : super.withParent();
}
