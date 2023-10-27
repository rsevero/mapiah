import "package:mapiah/src/th_elements/th_element.dart";

class THComment extends THElement {
  String content;

  THComment(super.parent, this.content) : super.withParent();
}
