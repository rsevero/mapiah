part of 'th_element.dart';

class THEndscrap extends THElement {
  THEndscrap.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THEndscrap({
    required super.parentMPID,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.endscrap;

  factory THEndscrap.fromMap(Map<String, dynamic> map) {
    return THEndscrap.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  factory THEndscrap.fromJson(String jsonString) {
    return THEndscrap.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndscrap copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
  }) {
    return THEndscrap.forCWJM(
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
  bool isSameClass(Object object) {
    return object is THEndscrap;
  }
}
