import "package:mapiah/src/th_elements/th_element.dart";

class THSameLineComment extends THElement {
  String content;
  THSameLineComment(super.parent, this.content) : super.withParent();

  @override
  String toString() {
    return content;
  }
}
