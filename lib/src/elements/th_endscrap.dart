import "dart:convert";

import "package:mapiah/src/elements/th_element.dart";

class THEndscrap extends THElement {
  THEndscrap({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super();

  THEndscrap.addToParent({required super.parentMapiahID}) : super.addToParent();

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THEndscrap.fromMap(Map<String, dynamic> map) {
    return THEndscrap(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
    );
  }

  factory THEndscrap.fromJson(String jsonString) {
    return THEndscrap.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndscrap copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THEndscrap(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
    );
  }

  @override
  bool operator ==(covariant THEndscrap other) {
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
    return object is THEndscrap;
  }
}
