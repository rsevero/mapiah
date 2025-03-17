part of 'th_command_option.dart';

// height <value> . height of pit or wall:pit; available in METAPOST as a numeric
// variable ATTR__height.
class THLineHeightCommandOption extends THCommandOption {
  late final THDoublePart height;

  THLineHeightCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.height,
  }) : super.forCWJM();

  THLineHeightCommandOption.fromString({
    required super.optionParent,
    required String height,
    super.originalLineInTH2File = '',
  }) : super() {
    this.height = THDoublePart.fromString(valueString: height);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.lineHeight;

  @override
  String typeToFile() => 'height';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'height': height.toMap(),
    });

    return map;
  }

  factory THLineHeightCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineHeightCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      height: THDoublePart.fromMap(map['height']),
    );
  }

  factory THLineHeightCommandOption.fromJson(String jsonString) {
    return THLineHeightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineHeightCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? height,
  }) {
    return THLineHeightCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(covariant THLineHeightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.height == height;
  }

  @override
  int get hashCode => super.hashCode ^ height.hashCode;

  @override
  String specToFile() {
    return height.toString();
  }
}
