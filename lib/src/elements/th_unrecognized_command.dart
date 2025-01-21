import "dart:convert";

import "package:mapiah/src/elements/th_element.dart";

class THUnrecognizedCommand extends THElement {
  late final List<dynamic> _value;

  THUnrecognizedCommand({
    required super.mapiahID,
    required super.parentMapiahID,
    super.sameLineComment,
    required List<dynamic> value,
  }) : super() {
    _value = value;
  }

  THUnrecognizedCommand.addToParent({
    required super.parentMapiahID,
    required List<dynamic> value,
  })  : _value = value,
        super.addToParent();

  @override
  Map<String, dynamic> toMap() {
    return {
      'mapiahID': mapiahID,
      'parentMapiahID': parentMapiahID,
      'sameLineComment': sameLineComment,
      'value': _value,
    };
  }

  factory THUnrecognizedCommand.fromMap(Map<String, dynamic> map) {
    return THUnrecognizedCommand(
      mapiahID: map['mapiahID'],
      parentMapiahID: map['parentMapiahID'],
      sameLineComment: map['sameLineComment'],
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
    List<dynamic>? value,
    bool makeSameLineCommentNull = false,
  }) {
    return THUnrecognizedCommand(
      mapiahID: mapiahID ?? this.mapiahID,
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      value: value ?? _value,
    );
  }

  @override
  bool operator ==(covariant THUnrecognizedCommand other) {
    if (identical(this, other)) return true;

    return other.mapiahID == mapiahID &&
        other.parentMapiahID == parentMapiahID &&
        other.sameLineComment == sameLineComment &&
        other._value == _value;
  }

  @override
  int get hashCode => Object.hash(
        mapiahID,
        parentMapiahID,
        sameLineComment,
        _value,
      );

  @override
  bool isSameClass(Object object) {
    return object is THUnrecognizedCommand;
  }

  get value {
    return _value;
  }
}
