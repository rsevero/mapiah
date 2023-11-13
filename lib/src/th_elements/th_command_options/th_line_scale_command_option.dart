import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_line_segment.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_multiple_choice_part.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

enum THLineScaleCommandOptionType { multiplechoice, text, numeric }

/// scale . scale for labels, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0. Absolute font sizes (in points) can be
/// assigned to named sizes using fonts-setup in the layout configuration section.
class THLineScaleCommandOption extends THCommandOption {
  late THMultipleChoicePart _multipleChoiceSize;
  late THDoublePart _numericSize;
  late THLineScaleCommandOptionType _type;
  late String _textSize;

  static const _scaleMultipleChoiceName = 'point|scale';

  THLineScaleCommandOption.sizeAsMultipleChoice(
      super.optionParent, String aTextScaleSize) {
    if ((optionParent is! THLine) ||
        ((optionParent as THLine).plaType != 'label')) {
      throw THCustomException("Only available for 'label' lines.");
    }
    _multipleChoiceSize =
        THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _type = THLineScaleCommandOptionType.multiplechoice;
  }

  THLineScaleCommandOption.sizeAsText(super.optionParent, String aTextScale) {
    if ((optionParent is! THLine) ||
        ((optionParent as THLine).plaType != 'label')) {
      throw THCustomException("Only available for 'label' lines.");
    }
    _textSize = aTextScale;
    _type = THLineScaleCommandOptionType.text;
  }

  THLineScaleCommandOption.sizeAsNumber(
      super.optionParent, THDoublePart aNumericScaleSize) {
    if ((optionParent is! THLine) ||
        ((optionParent as THLine).plaType != 'label')) {
      throw THCustomException("Only available for 'label' lines.");
    }
    _numericSize = aNumericScaleSize;
    _type = THLineScaleCommandOptionType.numeric;
  }

  THLineScaleCommandOption.sizeAsNumberFromString(
      super.optionParent, String aNumericScaleSize) {
    if ((optionParent is! THLine) ||
        ((optionParent as THLine).plaType != 'label')) {
      throw THCustomException("Only available for 'label' lines.");
    }
    _numericSize = THDoublePart.fromString(aNumericScaleSize);
    _type = THLineScaleCommandOptionType.numeric;
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
}
