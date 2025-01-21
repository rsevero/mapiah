import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/th_element.dart';

class THXTherionConfig extends THElement {
  String name;
  String value;

  THXTherionConfig.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.name,
    required this.value,
  }) : super.forCWJM();

  THXTherionConfig({
    required super.parentMapiahID,
    required this.name,
    required this.value,
  }) : super.addToParent();

  @override
  String get elementType => thXTherionConfigID;

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'name': name,
      'value': value,
    };
  }

  factory THXTherionConfig.fromMap(Map<String, dynamic> map) {
    return THXTherionConfig.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      name: map['name'],
      value: map['value'],
    );
  }

  factory THXTherionConfig.fromJson(String jsonString) {
    return THXTherionConfig.fromMap(jsonDecode(jsonString));
  }

  @override
  THXTherionConfig copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    String? name,
    String? value,
    bool makeSameLineCommentNull = false,
  }) {
    return THXTherionConfig.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(covariant THXTherionConfig other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.name == name &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        name,
        value,
      );

  @override
  bool isSameClass(Object object) {
    return object is THXTherionConfig;
  }
}
