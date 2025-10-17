part of 'th_command_option.dart';

// l-size <number> . Size of the line (to the left). Only valid on and required
// for slope type.
//
// size <number> . synonym of l-size
class THLSizeCommandOption extends THCommandOption {
  late final THDoublePart number;

  THLSizeCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.number,
  }) : super.forCWJM();

  THLSizeCommandOption.fromString({
    required super.parentMPID,
    required String number,
    super.originalLineInTH2File = '',
  }) : super() {
    this.number = THDoublePart.fromString(valueString: number);
  }

  THLSizeCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String number,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    this.number = THDoublePart.fromString(valueString: number);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.lSize;

  @override
  String typeToFile() => 'l-size';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'number': number.toMap()});

    return map;
  }

  factory THLSizeCommandOption.fromMap(Map<String, dynamic> map) {
    return THLSizeCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      number: THDoublePart.fromMap(map['number']),
    );
  }

  factory THLSizeCommandOption.fromJson(String jsonString) {
    return THLSizeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLSizeCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDoublePart? number,
  }) {
    return THLSizeCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      number: number ?? this.number,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THLSizeCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.number == number;
  }

  @override
  int get hashCode => super.hashCode ^ number.hashCode;

  @override
  String specToFile() {
    return number.toString();
  }
}
