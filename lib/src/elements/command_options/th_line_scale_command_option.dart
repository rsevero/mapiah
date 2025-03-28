part of 'th_command_option.dart';

enum THLineScaleCommandOptionType {
  multiplechoice,
  text,
  numeric,
}

/// scale . scale for labels, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0. Absolute font sizes (in points) can be
/// assigned to named sizes using fonts-setup in the layout configuration section.
class THLineScaleCommandOption extends THCommandOption {
  late final THMultipleChoicePart multipleChoiceSize;
  late final THDoublePart numericSize;
  late final THLineScaleCommandOptionType scaleType;
  late final String textSize;

  static const String _scaleMultipleChoiceName = 'point|scale';

  THLineScaleCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.multipleChoiceSize,
    required this.numericSize,
    required this.scaleType,
    required this.textSize,
  }) : super.forCWJM();

  THLineScaleCommandOption.sizeAsMultipleChoice({
    required super.optionParent,
    required String textScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: textScaleSize);
    scaleType = THLineScaleCommandOptionType.multiplechoice;
    numericSize = THDoublePart(value: 0.0, decimalPositions: 0);
    textSize = '';
  }

  THLineScaleCommandOption.sizeAsText({
    required super.optionParent,
    required String textScale,
    super.originalLineInTH2File = '',
  })  : textSize = textScale,
        super() {
    scaleType = THLineScaleCommandOptionType.text;
    multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: '');
    numericSize = THDoublePart(value: 0.0, decimalPositions: 0);
  }

  THLineScaleCommandOption.sizeAsNumber({
    required super.optionParent,
    required THDoublePart numericScaleSize,
    super.originalLineInTH2File = '',
  })  : numericSize = numericScaleSize,
        super() {
    scaleType = THLineScaleCommandOptionType.numeric;
    multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: '');
    textSize = '';
  }

  THLineScaleCommandOption.sizeAsNumberFromString({
    required super.optionParent,
    required String numericScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    numericSize = THDoublePart.fromString(valueString: numericScaleSize);
    scaleType = THLineScaleCommandOptionType.numeric;
    multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: '');
    textSize = '';
  }

  @override
  THCommandOptionType get type => THCommandOptionType.lineScale;

  @override
  String typeToFile() => 'scale';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'multipleChoiceSize': multipleChoiceSize.toMap(),
      'numericSize': numericSize.toMap(),
      'scaleType': scaleType.name,
      'textSize': textSize,
    });

    return map;
  }

  factory THLineScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineScaleCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      multipleChoiceSize:
          THMultipleChoicePart.fromMap(map['multipleChoiceSize']),
      numericSize: THDoublePart.fromMap(map['numericSize']),
      scaleType: THLineScaleCommandOptionType.values.byName(map['scaleType']),
      textSize: map['textSize'],
    );
  }

  factory THLineScaleCommandOption.fromJson(String jsonString) {
    return THLineScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineScaleCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THMultipleChoicePart? multipleChoiceSize,
    THDoublePart? numericSize,
    THLineScaleCommandOptionType? scaleType,
    String? textSize,
  }) {
    return THLineScaleCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      multipleChoiceSize: multipleChoiceSize ?? this.multipleChoiceSize,
      numericSize: numericSize ?? this.numericSize,
      scaleType: scaleType ?? this.scaleType,
      textSize: textSize ?? this.textSize,
    );
  }

  @override
  bool operator ==(covariant THLineScaleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.multipleChoiceSize == multipleChoiceSize &&
        other.numericSize == numericSize &&
        other.scaleType == scaleType &&
        other.textSize == textSize;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        multipleChoiceSize,
        numericSize,
        scaleType,
        textSize,
      );

  dynamic get size {
    switch (scaleType) {
      case THLineScaleCommandOptionType.numeric:
        return numericSize;
      case THLineScaleCommandOptionType.multiplechoice:
        return multipleChoiceSize;
      case THLineScaleCommandOptionType.text:
        return textSize;
    }
  }

  @override
  String specToFile() {
    switch (scaleType) {
      case THLineScaleCommandOptionType.numeric:
        return numericSize.toString();
      case THLineScaleCommandOptionType.multiplechoice:
        return multipleChoiceSize.toString();
      case THLineScaleCommandOptionType.text:
        return textSize;
    }
  }
}
