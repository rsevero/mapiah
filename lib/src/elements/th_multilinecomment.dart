part of 'th_element.dart';

class THMultiLineComment extends THElement with THIsParentMixin {
  THMultiLineComment.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required Set<int> childrenMPID,
    super.sameLineComment,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    this.childrenMPID.addAll(childrenMPID);
  }

  THMultiLineComment({
    required super.parentMPID,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.multilineComment;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'childrenMPID': childrenMPID.toList(),
    });

    return map;
  }

  factory THMultiLineComment.fromMap(Map<String, dynamic> map) {
    return THMultiLineComment.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      childrenMPID: Set<int>.from(map['childrenMPID']),
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  factory THMultiLineComment.fromJson(String jsonString) {
    return THMultiLineComment.fromMap(jsonDecode(jsonString));
  }

  @override
  THMultiLineComment copyWith({
    int? mpID,
    int? parentMPID,
    Set<int>? childrenMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
  }) {
    return THMultiLineComment.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      childrenMPID: childrenMPID ?? this.childrenMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  bool operator ==(covariant THMultiLineComment other) {
    if (identical(this, other)) return true;

    return other.mpID == mpID &&
        other.parentMPID == parentMPID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        const DeepCollectionEquality().equals(other.childrenMPID, childrenMPID);
  }

  @override
  int get hashCode => super.hashCode ^ childrenMPID.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THMultiLineComment;
  }
}
