part of 'th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  String? value;

  THUnrecognizedCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.value,
  }) : super.forCWJM();

  THUnrecognizedCommandOption({
    required super.optionParent,
    required this.value,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get type => THCommandOptionType.unrecognizedCommandOption;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'value': value,
    });

    return map;
  }

  factory THUnrecognizedCommandOption.fromMap(Map<String, dynamic> map) {
    return THUnrecognizedCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      value: map['value'],
    );
  }

  factory THUnrecognizedCommandOption.fromJson(String jsonString) {
    return THUnrecognizedCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THUnrecognizedCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? value,
  }) {
    return THUnrecognizedCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(covariant THUnrecognizedCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.value == value;
  }

  @override
  int get hashCode => super.hashCode ^ value.hashCode;

  @override
  String specToFile() {
    return value ?? thNullValueAsString;
  }
}
