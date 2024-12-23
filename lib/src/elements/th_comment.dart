import "package:mapiah/src/elements/th_element.dart";

class THComment extends THElement {
  String content;

  THComment(super.parent, this.content) : super.withParent();
}
