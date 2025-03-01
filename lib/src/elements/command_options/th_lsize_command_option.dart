part of 'th_command_option.dart';

// l-size <number> . Size of the line (to the left). Only valid on and required for slope
// type.
//
// size <number> . synonym of l-size
class THLSizeCommandOption extends THCommandOption {
  late final THDoublePart number;

  THLSizeCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.number,
  }) : super.forCWJM();

  THLSizeCommandOption.fromString({
    required super.optionParent,
    required String number,
    super.originalLineInTH2File = '',
  }) : super() {
    this.number = THDoublePart.fromString(valueString: number);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.lSize;

  @override
  String typeToFile() => 'l-size';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'number': number.toMap(),
    });

    return map;
  }

  factory THLSizeCommandOption.fromMap(Map<String, dynamic> map) {
    return THLSizeCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      number: THDoublePart.fromMap(map['number']),
    );
  }

  factory THLSizeCommandOption.fromJson(String jsonString) {
    return THLSizeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLSizeCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THDoublePart? number,
  }) {
    return THLSizeCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      number: number ?? this.number,
    );
  }

  @override
  bool operator ==(covariant THLSizeCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.number == number;
  }

  @override
  int get hashCode => super.hashCode ^ number.hashCode;

  @override
  String specToFile() {
    return number.toString();
  }
}
