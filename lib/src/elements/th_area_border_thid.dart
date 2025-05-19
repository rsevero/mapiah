part of 'th_element.dart';

class THAreaBorderTHID extends THElement {
  late final String thID;

  THAreaBorderTHID.forCWJM({
    required super.mpID,
    required super.parentMPID,
    required super.sameLineComment,
    required this.thID,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THAreaBorderTHID({
    required super.parentMPID,
    required this.thID,
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
      'thID': thID,
    });

    return map;
  }

  factory THAreaBorderTHID.fromMap(Map<String, dynamic> map) {
    return THAreaBorderTHID.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      thID: map['thID'],
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
    String? thID,
  }) {
    return THAreaBorderTHID.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      thID: thID ?? this.thID,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THAreaBorderTHID) return false;
    if (!super.equalsBase(other)) return false;

    return other.thID == thID;
  }

  @override
  int get hashCode => super.hashCode ^ thID.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THAreaBorderTHID;
  }
}
