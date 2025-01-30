part of 'th_element.dart';

class THComment extends THElement {
  final String content;

  THComment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.content,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THComment({
    required super.parentMapiahID,
    required this.content,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.comment;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'content': content,
    });

    return map;
  }

  factory THComment.fromMap(Map<String, dynamic> map) {
    return THComment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      content: map['content'],
    );
  }

  factory THComment.fromJson(String jsonString) {
    return THComment.fromMap(jsonDecode(jsonString));
  }

  @override
  THComment copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? content,
  }) {
    return THComment.forCWJM(
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
  bool operator ==(covariant THComment other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        content,
      );

  @override
  bool isSameClass(Object object) {
    return object is THComment;
  }
}
