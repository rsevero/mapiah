import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_element.dart';

class THEndarea extends THElement {
  THEndarea.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super.forCWJM();

  THEndarea({required super.parentMapiahID}) : super.addToParent();

  @override
  String get elementType => thEndareaID;

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THEndarea.fromMap(Map<String, dynamic> map) {
    return THEndarea.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
    );
  }

  factory THEndarea.fromJson(String jsonString) {
    return THEndarea.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndarea copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THEndarea.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
    );
  }

  @override
  bool operator ==(covariant THEndarea other) {
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
    return object is THEndarea;
  }
}
