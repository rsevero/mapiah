part of 'th_element.dart';

class THAreaBorderTHID extends THElement {
  late final String id;

  THAreaBorderTHID.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.id,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THAreaBorderTHID({
    required super.parentMPID,
    required this.id,
    super.originalLineInTH2File = '',
  }) : super.addToParent();
  //  {
  //   if (parent is! THArea) {
  //     throw THCustomException(
  //         'THAreaBorder parent must be THArea, but it is ${parent.runtimeType}');
  //   }
  // }

  @override
  THElementType get elementType => THElementType.areaBorderTHID;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'id': id,
    });

    return map;
  }

  factory THAreaBorderTHID.fromMap(Map<String, dynamic> map) {
    return THAreaBorderTHID.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      id: map['id'],
    );
  }

  factory THAreaBorderTHID.fromJson(String jsonString) {
    return THAreaBorderTHID.fromMap(jsonDecode(jsonString));
  }

  @override
  THAreaBorderTHID copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? id,
  }) {
    return THAreaBorderTHID.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(covariant THAreaBorderTHID other) {
    if (identical(this, other)) return true;

    return other.mpID == mpID &&
        other.parentMPID == parentMPID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.id == id;
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THAreaBorderTHID;
  }
}
