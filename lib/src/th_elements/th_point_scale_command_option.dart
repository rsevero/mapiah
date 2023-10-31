import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_parts/th_double_part.dart';
import 'package:mapiah/src/th_elements/th_parts/th_multiple_choice_part.dart';

class THPointScaleCommandOption extends THCommandOption {
  late THMultipleChoicePart _textSize;
  late THDoublePart _numericSize;
  late bool _isNumeric;

  static const _scaleMultipleChoiceName = 'point|scale';

  THPointScaleCommandOption._(super.parentOption);

  THPointScaleCommandOption.sizeAsText(
      super.parentOption, String aTextScaleSize) {
    _textSize = THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _isNumeric = false;
  }

  THPointScaleCommandOption.sizeAsNumber(
      super.parentOption, THDoublePart aNumericScaleSize) {
    _numericSize = aNumericScaleSize;
    _isNumeric = true;
  }

  THPointScaleCommandOption.sizeAsNumberFromString(
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
