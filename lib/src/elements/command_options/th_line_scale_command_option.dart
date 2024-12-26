import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_multiple_choice_part.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_line_scale_command_option.mapper.dart';

@MappableEnum()
enum THLineScaleCommandOptionType { multiplechoice, text, numeric }

/// scale . scale for labels, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0. Absolute font sizes (in points) can be
/// assigned to named sizes using fonts-setup in the layout configuration section.
@MappableClass()
class THLineScaleCommandOption extends THCommandOption
    with THLineScaleCommandOptionMappable {
  late THMultipleChoicePart _multipleChoiceSize;
  late THDoublePart _numericSize;
  late THLineScaleCommandOptionType _type;
  late String _textSize;

  static const _scaleMultipleChoiceName = 'point|scale';

  THLineScaleCommandOption(
    super.optionParent,
    THMultipleChoicePart multipleChoiceSize,
    THDoublePart numericSize,
    THLineScaleCommandOptionType type,
    String textSize,
  ) {
    _checkOptionParent();
    _multipleChoiceSize = multipleChoiceSize;
    _type = type;
    _numericSize = numericSize;
    _textSize = textSize;
  }

  THLineScaleCommandOption.sizeAsMultipleChoice(
      super.optionParent, String aTextScaleSize) {
    _checkOptionParent();
    _multipleChoiceSize =
        THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _type = THLineScaleCommandOptionType.multiplechoice;
  }

  THLineScaleCommandOption.sizeAsText(super.optionParent, String aTextScale) {
    _checkOptionParent();
    _textSize = aTextScale;
    _type = THLineScaleCommandOptionType.text;
  }

  THLineScaleCommandOption.sizeAsNumber(
      super.optionParent, THDoublePart aNumericScaleSize) {
    _checkOptionParent();
    _numericSize = aNumericScaleSize;
    _type = THLineScaleCommandOptionType.numeric;
  }

  THLineScaleCommandOption.sizeAsNumberFromString(
      super.optionParent, String aNumericScaleSize) {
    _checkOptionParent();
    _numericSize = THDoublePart.fromString(aNumericScaleSize);
    _type = THLineScaleCommandOptionType.numeric;
  }

  void _checkOptionParent() {
    if ((optionParent is! THLine) ||
        ((optionParent as THLine).plaType != 'label')) {
      throw THCustomException("Only available for 'label' lines.");
    }
  }

  set sizeAsText(String aTextScaleSize) {
    _multipleChoiceSize =
        THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _type = THLineScaleCommandOptionType.multiplechoice;
  }

  set sizeAsNumber(THDoublePart aNumericScaleSize) {
    _numericSize = aNumericScaleSize;
    _type = THLineScaleCommandOptionType.numeric;
  }

  set sizeAsNumberFromString(String aNumericScaleSize) {
    _numericSize = THDoublePart.fromString(aNumericScaleSize);
    _type = THLineScaleCommandOptionType.numeric;
  }

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
  String get optionType => 'scale';

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
