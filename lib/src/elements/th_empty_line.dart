import "dart:convert";

import "package:mapiah/src/definitions/th_definitions.dart";
import "package:mapiah/src/elements/th_element.dart";

class THEmptyLine extends THElement {
  THEmptyLine.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super.forCWJM();

  THEmptyLine({required super.parentMapiahID}) : super.addToParent();

  @override
  String get elementType => thEmptyLineID;

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THEmptyLine.fromMap(Map<String, dynamic> map) {
    return THEmptyLine.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
    );
  }

  factory THEmptyLine.fromJson(String jsonString) {
    return THEmptyLine.fromMap(jsonDecode(jsonString));
  }

  @override
  THEmptyLine copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THEmptyLine.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
    );
  }

  @override
  bool operator ==(covariant THEmptyLine other) {
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
    return object is THEmptyLine;
  }
}
