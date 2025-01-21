import "dart:convert";

import "package:mapiah/src/definitions/th_definitions.dart";
import "package:mapiah/src/elements/th_element.dart";

class THComment extends THElement {
  final String content;

  THComment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.content,
  }) : super.forCWJM();

  THComment({
    required super.parentMapiahID,
    required this.content,
  }) : super.addToParent();

  @override
  String get elementType => thCommentID;

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'content': content,
    };
  }

  factory THComment.fromMap(Map<String, dynamic> map) {
    return THComment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      content: map['content'],
    );
  }

  factory THComment.fromJson(String jsonString) {
    return THComment.fromMap(jsonDecode(jsonString));
  }

  @override
  THComment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    String? content,
    bool makeSameLineCommentNull = false,
  }) {
    return THComment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(covariant THComment other) {
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
    return object is THComment;
  }
}
