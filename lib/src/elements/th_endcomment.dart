import "dart:convert";

import "package:mapiah/src/elements/th_element.dart";

class THEndcomment extends THElement {
  THEndcomment({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super();

  THEndcomment.addToParent({required super.parentMapiahID})
      : super.addToParent();

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THEndcomment.fromMap(Map<String, dynamic> map) {
    return THEndcomment(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
    );
  }

  factory THEndcomment.fromJson(String jsonString) {
    return THEndcomment.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndcomment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THEndcomment(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
    );
  }

  @override
  bool operator ==(covariant THEndcomment other) {
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
    return object is THEndcomment;
  }
}
