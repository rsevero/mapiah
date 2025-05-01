part of 'th_command_option.dart';

enum THPLScaleCommandOptionType {
  named,
  numeric,
}

/// Therion Book says for lines:
/// scale . scale for labels, can be: tiny (xs), small (s), normal (m), large
/// (l), huge (xl) or a numeric value. Normal is default. Named sizes scale by
/// √2, so that xs ≡ 0.5, s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0. Absolute
/// font sizes (in points) can be assigned to named sizes using fonts-setup in
/// the layout configuration section.
///
/// Therion Book says for points:
/// scale . symbol scale, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0.
class THPLScaleCommandOption extends THCommandOption {
  late final THScaleMultipleChoicePart namedSize;
  late final THDoublePart numericSize;
  late final THPLScaleCommandOptionType scaleType;

  THPLScaleCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.namedSize,
    required this.numericSize,
    required this.scaleType,
  }) : super.forCWJM();

  THPLScaleCommandOption.sizeAsNamed({
    required super.optionParent,
    required String textScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    namedSize = THScaleMultipleChoicePart(
      choice: textScaleSize,
    );
    scaleType = THPLScaleCommandOptionType.named;
    numericSize = THDoublePart(value: 0.0, decimalPositions: 0);
  }

  THPLScaleCommandOption.sizeAsNamedWithParentMPID({
    required super.parentMPID,
    required String textScaleSize,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    namedSize = THScaleMultipleChoicePart(
      choice: textScaleSize,
    );
    scaleType = THPLScaleCommandOptionType.named;
    numericSize = THDoublePart(value: 0.0, decimalPositions: 0);
  }

  THPLScaleCommandOption.sizeAsNumber({
    required super.optionParent,
    required THDoublePart numericScaleSize,
    super.originalLineInTH2File = '',
  })  : numericSize = numericScaleSize,
        super() {
    scaleType = THPLScaleCommandOptionType.numeric;
    namedSize = THScaleMultipleChoicePart(choice: '');
  }

  THPLScaleCommandOption.sizeAsNumberFromString({
    required super.optionParent,
    required String numericScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    numericSize = THDoublePart.fromString(valueString: numericScaleSize);
    scaleType = THPLScaleCommandOptionType.numeric;
    namedSize = THScaleMultipleChoicePart(choice: '');
  }

  THPLScaleCommandOption.sizeAsNumberFromStringWithParentMPID({
    required super.parentMPID,
    required String numericScaleSize,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    numericSize = THDoublePart.fromString(valueString: numericScaleSize);
    scaleType = THPLScaleCommandOptionType.numeric;
    namedSize = THScaleMultipleChoicePart(choice: '');
  }

  @override
  THCommandOptionType get type => THCommandOptionType.plScale;

  @override
  String typeToFile() => 'scale';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'namedSize': namedSize.toMap(),
      'numericSize': numericSize.toMap(),
      'scaleType': scaleType.name,
    });

    return map;
  }

  factory THPLScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THPLScaleCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      namedSize: THScaleMultipleChoicePart.fromMap(map['namedSize']),
      numericSize: THDoublePart.fromMap(map['numericSize']),
      scaleType: THPLScaleCommandOptionType.values.byName(map['scaleType']),
    );
  }

  factory THPLScaleCommandOption.fromJson(String jsonString) {
    return THPLScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPLScaleCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THScaleMultipleChoicePart? namedSize,
    THDoublePart? numericSize,
    THPLScaleCommandOptionType? scaleType,
  }) {
    return THPLScaleCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      namedSize: namedSize ?? this.namedSize,
      numericSize: numericSize ?? this.numericSize,
      scaleType: scaleType ?? this.scaleType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THPLScaleCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.namedSize == namedSize &&
        other.numericSize == numericSize &&
        other.scaleType == scaleType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        namedSize,
        numericSize,
        scaleType,
      );

  dynamic get size {
    switch (scaleType) {
      case THPLScaleCommandOptionType.numeric:
        return numericSize;
      case THPLScaleCommandOptionType.named:
        return namedSize;
    }
  }

  @override
  String specToFile() {
    switch (scaleType) {
      case THPLScaleCommandOptionType.named:
        return namedSize.toString();
      case THPLScaleCommandOptionType.numeric:
        return numericSize.toString();
    }
  }
}
