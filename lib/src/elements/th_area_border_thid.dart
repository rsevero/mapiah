import 'dart:convert';

import 'package:mapiah/src/elements/th_element.dart';

class THAreaBorderTHID extends THElement {
  late final String id;

  THAreaBorderTHID.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    required super.sameLineComment,
    required this.id,
  }) : super.forCWJM();

  THAreaBorderTHID({
    required super.parentMapiahID,
    required this.id,
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
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'id': id,
      'elementType': elementType.name,
    };
  }

  factory THAreaBorderTHID.fromMap(Map<String, dynamic> map) {
    return THAreaBorderTHID.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      id: map['id'],
    );
  }

  factory THAreaBorderTHID.fromJson(String jsonString) {
    return THAreaBorderTHID.fromMap(jsonDecode(jsonString));
  }

  @override
  THAreaBorderTHID copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    String? id,
  }) {
    return THAreaBorderTHID.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: sameLineComment ?? this.sameLineComment,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(covariant THAreaBorderTHID other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        id,
      );

  @override
  bool isSameClass(Object object) {
    return object is THAreaBorderTHID;
  }
}
