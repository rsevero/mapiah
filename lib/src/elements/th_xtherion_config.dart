part of 'th_element.dart';

class THXTherionConfig extends THElement {
  String name;
  String value;

  THXTherionConfig.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required this.name,
    required this.value,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THXTherionConfig({
    required super.parentMapiahID,
    required this.name,
    required this.value,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.xTherionConfig;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'name': name,
      'value': value,
    });

    return map;
  }

  factory THXTherionConfig.fromMap(Map<String, dynamic> map) {
    return THXTherionConfig.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
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
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    String? name,
    String? value,
  }) {
    return THXTherionConfig.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
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
        other.originalLineInTH2File == originalLineInTH2File &&
        other.name == name &&
        other.value == value;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        name,
        value,
      );

  @override
  bool isSameClass(Object object) {
    return object is THXTherionConfig;
  }
}
