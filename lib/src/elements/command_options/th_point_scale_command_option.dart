import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_multiple_choice_part.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_point_scale_command_option.mapper.dart';

/// Therion Book says for points:
/// scale . symbol scale, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0.
@MappableClass()
class THPointScaleCommandOption extends THCommandOption
    with THPointScaleCommandOptionMappable {
  late THMultipleChoicePart _multipleChoiceSize;
  late THDoublePart _numericSize;
  late bool _isNumeric;

  static const _scaleMultipleChoiceName = 'point|scale';

  THPointScaleCommandOption(
      super.optionParent,
      THMultipleChoicePart multipleChoiceSize,
      THDoublePart numericSize,
      bool isNumeric)
      : _multipleChoiceSize = multipleChoiceSize,
        _numericSize = numericSize,
        _isNumeric = isNumeric {
    _checkoptionParent();
  }

  THPointScaleCommandOption.sizeAsMultipleChoice(
      super.optionParent, String aTextScaleSize) {
    _checkoptionParent();
    _multipleChoiceSize =
        THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
    _isNumeric = false;
  }

  THPointScaleCommandOption.sizeAsNumber(
      super.optionParent, THDoublePart aNumericScaleSize) {
    _checkoptionParent();
    _numericSize = aNumericScaleSize;
    _isNumeric = true;
  }

  THPointScaleCommandOption.sizeAsNumberFromString(
      super.optionParent, String aNumericScaleSize) {
    _checkoptionParent();
    _numericSize = THDoublePart.fromString(aNumericScaleSize);
    _isNumeric = true;
  }

  void _checkoptionParent() {
    if (optionParent is! THPoint) {
      throw THCustomException("Only available for 'point'.");
    }
  }

  set sizeAsText(String aTextScaleSize) {
    _multipleChoiceSize =
        THMultipleChoicePart(_scaleMultipleChoiceName, aTextScaleSize);
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
      return _multipleChoiceSize;
    }
  }

  @override
  String get optionType => 'scale';

  @override
  String specToFile() {
    if (isNumeric) {
      return _numericSize.toString();
    } else {
      return _multipleChoiceSize.toString();
    }
  }
}
