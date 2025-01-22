import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_multiple_choice_part.dart';

enum THLineScaleCommandOptionType { multiplechoice, text, numeric }

/// scale . scale for labels, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0. Absolute font sizes (in points) can be
/// assigned to named sizes using fonts-setup in the layout configuration section.
class THLineScaleCommandOption extends THCommandOption {
  late final THMultipleChoicePart _multipleChoiceSize;
  late final THDoublePart _numericSize;
  late final THLineScaleCommandOptionType _type;
  late final String _textSize;

  static const String _scaleMultipleChoiceName = 'point|scale';

  THLineScaleCommandOption.forCWJM({
    required super.parentMapiahID,
    required THMultipleChoicePart multipleChoiceSize,
    required THDoublePart numericSize,
    required THLineScaleCommandOptionType type,
    required String textSize,
  }) : super.forCWJM() {
    _multipleChoiceSize = multipleChoiceSize;
    _type = type;
    _numericSize = numericSize;
    _textSize = textSize;
  }

  THLineScaleCommandOption.sizeAsMultipleChoice({
    required super.optionParent,
    required String textScaleSize,
  }) : super() {
    _multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: textScaleSize);
    _type = THLineScaleCommandOptionType.multiplechoice;
  }

  THLineScaleCommandOption.sizeAsText({
    required super.optionParent,
    required String textScale,
  }) : super() {
    _textSize = textScale;
    _type = THLineScaleCommandOptionType.text;
  }

  THLineScaleCommandOption.sizeAsNumber({
    required super.optionParent,
    required THDoublePart numericScaleSize,
  }) : super() {
    _numericSize = numericScaleSize;
    _type = THLineScaleCommandOptionType.numeric;
  }

  THLineScaleCommandOption.sizeAsNumberFromString({
    required super.optionParent,
    required String numericScaleSize,
  }) : super() {
    _numericSize = THDoublePart.fromString(valueString: numericScaleSize);
    _type = THLineScaleCommandOptionType.numeric;
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
    THMultipleChoicePart? multipleChoiceSize,
    THDoublePart? numericSize,
    THLineScaleCommandOptionType? type,
    String? textSize,
  }) {
    return THLineScaleCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
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
    return _type;
  }

  dynamic get size {
    switch (_type) {
      case THLineScaleCommandOptionType.numeric:
        return _numericSize;
      case THLineScaleCommandOptionType.multiplechoice:
        return _multipleChoiceSize;
      case THLineScaleCommandOptionType.text:
        return _textSize;
    }
  }

  @override
  String specToFile() {
    switch (_type) {
      case THLineScaleCommandOptionType.numeric:
        return _numericSize.toString();
      case THLineScaleCommandOptionType.multiplechoice:
        return _multipleChoiceSize.toString();
      case THLineScaleCommandOptionType.text:
        return _textSize;
    }
  }

  THMultipleChoicePart get multipleChoiceSize => _multipleChoiceSize;

  THDoublePart get numericSize => _numericSize;

  THLineScaleCommandOptionType get type => _type;

  String get textSize => _textSize;
}
