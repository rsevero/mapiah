import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_multiple_choice_part.dart';

/// Therion Book says for points:
/// scale . symbol scale, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0.
///
/// And for lines:
/// scale . scale for labels, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0. Absolute font sizes (in points) can be
/// assigned to named sizes using fonts-setup in the layout configuration section.
///
/// Does the final part of the 'lines' definition means that scale for lines
/// should accept random keywords?
class THPLScaleCommandOption extends THCommandOption {
  late THMultipleChoicePart _textSize;
  late THDoublePart _numericSize;
  late bool _isNumeric;

  static const _scaleMultipleChoiceName = 'point|scale';

  THPLScaleCommandOption._(super.parentOption);

  THPLScaleCommandOption.sizeAsText(super.parentOption, String aTextScaleSize) {
    _textSize = THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _isNumeric = false;
  }

  THPLScaleCommandOption.sizeAsNumber(
      super.parentOption, THDoublePart aNumericScaleSize) {
    _numericSize = aNumericScaleSize;
    _isNumeric = true;
  }

  THPLScaleCommandOption.sizeAsNumberFromString(
      super.parentOption, String aNumericScaleSize) {
    _numericSize = THDoublePart.fromString(aNumericScaleSize);
    _isNumeric = true;
  }

  set sizeAsText(String aTextScaleSize) {
    _textSize = THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _isNumeric = false;
  }

  set sizeAsNumber(THDoublePart aNumericScaleSize) {
    _numericSize = aNumericScaleSize;
    _isNumeric = true;
  }

  set sizeAsNumberFromString(String aNumericScaleSize) {
    _numericSize = THDoublePart.fromString(aNumericScaleSize);
    _isNumeric = true;
  }

  bool get isNumeric {
    return _isNumeric;
  }

  dynamic get size {
    if (isNumeric) {
      return _numericSize;
    } else {
      return _textSize;
    }
  }

  @override
  String get optionType => 'scale';

  @override
  String specToFile() {
    if (isNumeric) {
      return _numericSize.toString();
    } else {
      return _textSize.toString();
    }
  }
}
