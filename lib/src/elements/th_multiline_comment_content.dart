part of 'th_element.dart';

class THMultilineCommentContent extends THElement {
  String content;

  THMultilineCommentContent.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.content,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THMultilineCommentContent({
    required super.parentMapiahID,
    required this.content,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.multilineCommentContent;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'content': content,
    });

    return map;
  }

  factory THMultilineCommentContent.fromMap(Map<String, dynamic> map) {
    return THMultilineCommentContent.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      content: map['content'],
    );
  }

  factory THMultilineCommentContent.fromJson(String jsonString) {
    return THMultilineCommentContent.fromMap(jsonDecode(jsonString));
  }

  @override
  THMultilineCommentContent copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? content,
  }) {
    return THMultilineCommentContent.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(covariant THMultilineCommentContent other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.content == content;
  }

  @override
  int get hashCode => super.hashCode ^ content.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THMultilineCommentContent;
  }
}
