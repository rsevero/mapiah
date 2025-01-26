part of 'th_command_option.dart';

// l-size <number> . Size of the line (to the left). Only valid on and required for slope
// type.
//
// size <number> . synonym of l-size
class THLSizeCommandOption extends THCommandOption {
  late final THDoublePart number;

  THLSizeCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.number,
  }) : super.forCWJM();

  THLSizeCommandOption.fromString({
    required super.optionParent,
    required String number,
  }) : super() {
    this.number = THDoublePart.fromString(valueString: number);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.lSize;

  @override
  String typeToFile() => 'l-size';

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'number': number.toMap(),
    };
  }

  factory THLSizeCommandOption.fromMap(Map<String, dynamic> map) {
    return THLSizeCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      number: THDoublePart.fromMap(map['number']),
    );
  }

  factory THLSizeCommandOption.fromJson(String jsonString) {
    return THLSizeCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLSizeCommandOption copyWith({
    int? parentMapiahID,
    THDoublePart? number,
  }) {
    return THLSizeCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      number: number ?? this.number,
    );
  }

  @override
  bool operator ==(covariant THLSizeCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.number == number;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        number,
      );

  @override
  String specToFile() {
    return number.toString();
  }
}
