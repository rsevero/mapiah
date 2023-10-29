import "package:mapiah/src/th_elements/th_element.dart";

class THMultilineCommentContent extends THElement {
  String content;

  THMultilineCommentContent(super.parent, this.content) : super.withParent();
}
