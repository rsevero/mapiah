part of 'th_element.dart';

class THEndcomment extends THElement {
  THEndcomment.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
  }) : super.forCWJM();

  THEndcomment({required super.parentMapiahID}) : super.addToParent();

  @override
  THElementType get elementType => THElementType.endcomment;

  @override
  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
    };
  }

  factory THEndcomment.fromMap(Map<String, dynamic> map) {
    return THEndcomment.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
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
  }) {
    return THEndcomment.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
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
