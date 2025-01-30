part of 'th_element.dart';

class THEndcomment extends THElement {
  THEndcomment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THEndcomment({
    required super.parentMapiahID,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.endcomment;

  factory THEndcomment.fromMap(Map<String, dynamic> map) {
    return THEndcomment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  factory THEndcomment.fromJson(String jsonString) {
    return THEndcomment.fromMap(jsonDecode(jsonString));
  }

  @override
  THEndcomment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
  }) {
    return THEndcomment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  bool operator ==(covariant THEndcomment other) {
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
    return object is THEndcomment;
  }
}
