part of 'th_element.dart';

class THEndline extends THElement {
  THEndline.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THEndline({required super.parentMPID, super.originalLineInTH2File = ''})
    : super.addToParent();

  @override
  THElementType get elementType => THElementType.endline;

  factory THEndline.fromMap(Map<String, dynamic> map) {
    return THEndline.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  factory THEndline.fromJson(String jsonString) {
    return THEndline.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndline copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
  }) {
    return THEndline.forCWJM(
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
    if (other is! THEndline) return false;

    return super.equalsBase(other);
  }

  @override
  bool isSameClass(Object object) {
    return object is THEndline;
  }
}
