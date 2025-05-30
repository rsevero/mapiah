part of 'th_element.dart';

class THEmptyLine extends THElement {
  THEmptyLine.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THEmptyLine({
    required super.parentMPID,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.emptyLine;

  factory THEmptyLine.fromMap(Map<String, dynamic> map) {
    return THEmptyLine.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  factory THEmptyLine.fromJson(String jsonString) {
    return THEmptyLine.fromMap(jsonDecode(jsonString));
  }

  @override
  THEmptyLine copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
  }) {
    return THEmptyLine.forCWJM(
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
    if (other is! THEmptyLine) return false;

    return equalsBase(other);
  }

  @override
  bool isSameClass(Object object) {
    return object is THEmptyLine;
  }
}
