part of 'th_element.dart';

class THUnrecognizedCommand extends THElement {
  final List<dynamic> value;

  THUnrecognizedCommand.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.value,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THUnrecognizedCommand({
    required super.parentMPID,
    required this.value,
    super.originalLineInTH2File = '',
  }) : super.addToParent();

  @override
  THElementType get elementType => THElementType.unrecognizedCommand;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'value': value,
    });

    return map;
  }

  factory THUnrecognizedCommand.fromMap(Map<String, dynamic> map) {
    return THUnrecognizedCommand.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
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
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? originalLineInTH2File,
    List<dynamic>? value,
  }) {
    return THUnrecognizedCommand.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THUnrecognizedCommand) return false;
    if (!super.equalsBase(other)) return false;

    return other.value == value;
  }

  @override
  int get hashCode => super.hashCode ^ value.hashCode;

  @override
  bool isSameClass(Object object) {
    return object is THUnrecognizedCommand;
  }
}
