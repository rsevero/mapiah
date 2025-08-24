part of 'th_element.dart';

class THEndcomment extends THElement {
  THEndcomment.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THEndcomment({required super.parentMPID, super.originalLineInTH2File = ''})
    : super.addToParent();

  @override
  THElementType get elementType => THElementType.endcomment;

  factory THEndcomment.fromMap(Map<String, dynamic> map) {
    return THEndcomment.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  factory THEndcomment.fromJson(String jsonString) {
    return THEndcomment.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndcomment copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
  }) {
    return THEndcomment.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THEndcomment) return false;

    return super.equalsBase(other);
  }

  @override
  bool isSameClass(Object object) {
    return object is THEndcomment;
  }
}
