import 'dart:convert';

import 'package:mapiah/src/elements/th_element.dart';

class THEndline extends THElement {
  THEndline({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super();

  THEndline.addToParent({required super.parentMapiahID}) : super.addToParent();

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THEndline.fromMap(Map<String, dynamic> map) {
    return THEndline(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
    );
  }

  factory THEndline.fromJson(String jsonString) {
    return THEndline.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndline copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THEndline(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
    );
  }

  @override
  bool operator ==(covariant THEndline other) {
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
    return object is THEndline;
  }
}
