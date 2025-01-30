part of 'th_element.dart';

class THUnrecognizedCommand extends THElement {
  late final List<dynamic> _value;

  THUnrecognizedCommand.forCWJM({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> value,
    required super.originalLineInTH2File,
  }) : super.forCWJM() {
    _value = value;
  }

  THUnrecognizedCommand({
    required super.parentMapiahID,
    required List<dynamic> value,
    super.originalLineInTH2File = '',
  })  : _value = value,
        super.addToParent();

  @override
  THElementType get elementType => THElementType.unrecognizedCommand;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'value': _value,
    });

    return map;
  }

  factory THUnrecognizedCommand.fromMap(Map<String, dynamic> map) {
    return THUnrecognizedCommand.forCWJM(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
      originalLineInTH2File: map['originalLineInTH2File'],
      value: List<dynamic>.from(map['value']),
    );
  }

  factory THUnrecognizedCommand.fromJson(String jsonString) {
    return THUnrecognizedCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  THUnrecognizedCommand copyWith({
    int? mapiahID,
    int? parentMapiahID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    List<dynamic>? value,
  }) {
    return THUnrecognizedCommand.forCWJM(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      value: value ?? _value,
    );
  }

  @override
  bool operator ==(covariant THUnrecognizedCommand other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other._value == _value;
  }

  @override
  int get hashCode => super.hashCode ^ _value.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THUnrecognizedCommand;
  }

  get value {
    return _value;
  }
}
