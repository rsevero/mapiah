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
  late final THLineScaleCommandOptionType type;
  late final String textSize;

  static const String _scaleMultipleChoiceName = 'point|scale';

  THLineScaleCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.multipleChoiceSize,
    required this.numericSize,
    required this.type,
    required this.textSize,
  }) : super.forCWJM();

  THLineScaleCommandOption.sizeAsMultipleChoice({
    required super.optionParent,
    required String textScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: textScaleSize);
    type = THLineScaleCommandOptionType.multiplechoice;
    numericSize = THDoublePart(value: 0.0, decimalPositions: 0);
    textSize = '';
  }

  THLineScaleCommandOption.sizeAsText({
    required super.optionParent,
    required String textScale,
    super.originalLineInTH2File = '',
  })  : textSize = textScale,
        super() {
    type = THLineScaleCommandOptionType.text;
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
    type = THLineScaleCommandOptionType.numeric;
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
    type = THLineScaleCommandOptionType.numeric;
    multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: '');
    textSize = '';
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.lineScale;

  @override
  String typeToFile() => 'scale';

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'multipleChoiceSize': multipleChoiceSize.toMap(),
      'numericSize': numericSize.toMap(),
      'type': type.toString(),
      'textSize': textSize,
    };
  }

  factory THLineScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineScaleCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      multipleChoiceSize:
          THMultipleChoicePart.fromMap(map['multipleChoiceSize']),
      numericSize: THDoublePart.fromMap(map['numericSize']),
      type: THLineScaleCommandOptionType.values
          .firstWhere((e) => e.toString() == map['type']),
      textSize: map['textSize'],
    );
  }

  factory THLineScaleCommandOption.fromJson(String jsonString) {
    return THLineScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineScaleCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THMultipleChoicePart? multipleChoiceSize,
    THDoublePart? numericSize,
    THLineScaleCommandOptionType? type,
    String? textSize,
  }) {
    return THLineScaleCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      multipleChoiceSize: multipleChoiceSize ?? this.multipleChoiceSize,
      numericSize: numericSize ?? this.numericSize,
      type: type ?? this.type,
      textSize: textSize ?? this.textSize,
    );
  }

  @override
  bool operator ==(covariant THLineScaleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.multipleChoiceSize == multipleChoiceSize &&
        other.numericSize == numericSize &&
        other.type == type &&
        other.textSize == textSize;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        multipleChoiceSize,
        numericSize,
        type,
        textSize,
      );

  THLineScaleCommandOptionType get scaleType {
    return type;
  }

  dynamic get size {
    switch (type) {
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
    switch (type) {
      case THLineScaleCommandOptionType.numeric:
        return numericSize.toString();
      case THLineScaleCommandOptionType.multiplechoice:
        return multipleChoiceSize.toString();
      case THLineScaleCommandOptionType.text:
        return textSize;
    }
  }
}
