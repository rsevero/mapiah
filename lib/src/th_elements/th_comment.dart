import "package:mapiah/src/th_elements/th_element.dart";

class THComment extends THElement {
  String content;
  bool _isSameLine;

  THComment(super.parent, this.content, this._isSameLine) : super.withParent();

  @override
  String toString() {
    return content;
  }

  get isSameLine {
    return _isSameLine;
  }

  @override
  String type() {
    final type = isSameLine ? 'samelinecomment' : 'fulllinecomment';

    return type;
  }
}
