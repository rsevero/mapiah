part of 'th_command_option.dart';

// Objects survey, centreline, scrap, point, line, area, map and surface can
// contain user-defined attributes in a form -attr <name> <value>. <name> may
// contain alphanumeric characters, <value> is a string.
class THAttrCommandOption extends THCommandOption {
  final THStringPart name;
  final THStringPart value;

  THAttrCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.name,
    required this.value,
  }) : super.forCWJM();

  THAttrCommandOption({
    required super.parentMPID,
    required String attrName,
    required String attrValue,
    super.originalLineInTH2File = '',
  }) : name = THStringPart(content: attrName),
       value = THStringPart(content: attrValue),
       super();

  @override
  THCommandOptionType get type => THCommandOptionType.attr;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'name': name.toMap(), 'value': value.toMap()});

    return map;
  }

  factory THAttrCommandOption.fromMap(Map<String, dynamic> map) {
    return THAttrCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      name: THStringPart.fromMap(map['name']),
      value: THStringPart.fromMap(map['value']),
    );
  }

  factory THAttrCommandOption.fromJson(String jsonString) {
    return THAttrCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAttrCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THStringPart? name,
    THStringPart? value,
  }) {
    return THAttrCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THAttrCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.name == name && other.value == value;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(name, value);

  @override
  String specToFile() {
    return "${name.toString()} ${value.toString()}";
  }
}
