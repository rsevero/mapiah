import "dart:convert";

import "package:mapiah/src/elements/th_element.dart";

class THMultiLineComment extends THElement with THParent {
  THMultiLineComment({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super();

  THMultiLineComment.addToParent({required super.parentMapiahID})
      : super.addToParent();

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THMultiLineComment.fromMap(Map<String, dynamic> map) {
    return THMultiLineComment(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
    );
  }

  factory THMultiLineComment.fromJson(String jsonString) {
    return THMultiLineComment.fromMap(jsonDecode(jsonString));
  }

  @override
  THMultiLineComment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THMultiLineComment(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
    );
  }

  @override
  bool operator ==(covariant THMultiLineComment other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
      );

  @override
  bool isSameClass(Object object) {
    return object is THMultiLineComment;
  }
}
