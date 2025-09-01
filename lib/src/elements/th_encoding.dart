part of 'th_element.dart';

class THEncoding extends THElement {
  final String encoding;

  THEncoding.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required String encoding,
    required super.originalLineInTH2File,
  }) : encoding = encoding.trim().toUpperCase(),
       super.forCWJM() {
    mpLocator.mpGeneralController.addAvailableEncoding(encoding);
  }

  THEncoding({
    required super.parentMPID,
    required String encoding,
    super.originalLineInTH2File = '',
  }) : encoding = encoding.trim().toUpperCase(),
       super.getMPID() {
    mpLocator.mpGeneralController.addAvailableEncoding(encoding);
  }

  @override
  THElementType get elementType => THElementType.encoding;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'encoding': encoding});

    return map;
  }

  factory THEncoding.fromMap(Map<String, dynamic> map) {
    return THEncoding.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
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
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? encoding,
  }) {
    return THEncoding.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      encoding: encoding ?? this.encoding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THEncoding) return false;
    if (!super.equalsBase(other)) return false;

    return other.encoding == encoding;
  }

  @override
  int get hashCode => super.hashCode ^ encoding.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THEncoding;
  }
}
