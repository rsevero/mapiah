part of 'th_element.dart';

class THEncoding extends THElement {
  late final String encoding;

  THEncoding.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.encoding,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THEncoding({
    required super.parentMapiahID,
    required this.encoding,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.encoding;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'encoding': encoding,
    };
  }

  factory THEncoding.fromMap(Map<String, dynamic> map) {
    return THEncoding.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      encoding: map['encoding'],
    );
  }

  factory THEncoding.fromJson(String jsonString) {
    return THEncoding.fromMap(jsonDecode(jsonString));
  }

  @override
  THEncoding copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? encoding,
  }) {
    return THEncoding.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      encoding: encoding ?? this.encoding,
    );
  }

  @override
  bool operator ==(covariant THEncoding other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.encoding == encoding;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        encoding,
      );

  @override
  bool isSameClass(Object object) {
    return object is THEncoding;
  }
}
