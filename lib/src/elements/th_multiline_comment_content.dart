import "dart:convert";

import "package:mapiah/src/elements/th_element.dart";

class THMultilineCommentContent extends THElement {
  String content;

  THMultilineCommentContent.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.content,
  }) : super.forCWJM();

  THMultilineCommentContent({
    required super.parentMapiahID,
    required this.content,
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.multilineCommentContent;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'content': content,
    };
  }

  factory THMultilineCommentContent.fromMap(Map<String, dynamic> map) {
    return THMultilineCommentContent.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      content: map['content'],
    );
  }

  factory THMultilineCommentContent.fromJson(String jsonString) {
    return THMultilineCommentContent.fromMap(jsonDecode(jsonString));
  }

  @override
  THMultilineCommentContent copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    String? content,
    bool makeSameLineCommentNull = false,
  }) {
    return THMultilineCommentContent.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(covariant THMultilineCommentContent other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        content,
      );

  @override
  bool isSameClass(Object object) {
    return object is THMultilineCommentContent;
  }
}
