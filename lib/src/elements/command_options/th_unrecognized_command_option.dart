part of 'th_command_option.dart';

class THUnrecognizedCommandOption extends THCommandOption {
  String? value;

  THUnrecognizedCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.value,
  }) : super.forCWJM();

  THUnrecognizedCommandOption({
    required super.optionParent,
    required this.value,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get optionType =>
      THCommandOptionType.unrecognizedCommandOption;

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
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      value: map['value'],
    );
  }

  factory THUnrecognizedCommandOption.fromJson(String jsonString) {
    return THUnrecognizedCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THUnrecognizedCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? value,
  }) {
    return THUnrecognizedCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(covariant THUnrecognizedCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
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
