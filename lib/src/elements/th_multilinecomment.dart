part of 'th_element.dart';

class THMultiLineComment extends THElement with THIsParentMixin {
  THMultiLineComment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    required List<int> childrenMapiahID,
    super.sameLineComment,
  }) : super.forCWJM() {
    this.childrenMapiahID.addAll(childrenMapiahID);
  }

  THMultiLineComment({
    required super.parentMapiahID,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.multilineComment;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'childrenMapiahID': childrenMapiahID.toList(),
      'sameLineComment': sameLineComment,
    };
  }

  factory THMultiLineComment.fromMap(Map<String, dynamic> map) {
    return THMultiLineComment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      childrenMapiahID: List<int>.from(map['childrenMapiahID']),
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
    List<int>? childrenMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
  }) {
    return THMultiLineComment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      childrenMapiahID: childrenMapiahID ?? this.childrenMapiahID,
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
        const DeepCollectionEquality()
            .equals(other.childrenMapiahID, childrenMapiahID) &&
        other.sameLineComment == sameLineComment;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        childrenMapiahID,
        sameLineComment,
      );

  @override
  bool isSameClass(Object object) {
    return object is THMultiLineComment;
  }
}
