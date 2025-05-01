part of 'th_element.dart';

class THComment extends THElement {
  final String content;

  THComment.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.content,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THComment({
    required super.parentMPID,
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
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
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
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? content,
  }) {
    return THComment.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THComment) return false;
    if (!super.equalsBase(other)) return false;

    return other.content == content;
  }

  @override
  int get hashCode => super.hashCode ^ content.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THComment;
  }
}
