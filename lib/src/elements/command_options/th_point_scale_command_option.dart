import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_multiple_choice_part.dart';

/// Therion Book says for points:
/// scale . symbol scale, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0.
class THPointScaleCommandOption extends THCommandOption {
  static const String _thisOptionType = 'scale';
  late final THMultipleChoicePart _multipleChoiceSize;
  late final THDoublePart _numericSize;
  late final bool _isNumeric;

  static const _scaleMultipleChoiceName = 'point|scale';

  THPointScaleCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required THMultipleChoicePart multipleChoiceSize,
    required THDoublePart numericSize,
    required bool isNumeric,
  })  : _multipleChoiceSize = multipleChoiceSize,
        _numericSize = numericSize,
        _isNumeric = isNumeric,
        super();

  THPointScaleCommandOption.sizeAsMultipleChoice({
    required super.optionParent,
    required String textScaleSize,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    _multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: textScaleSize);
    _isNumeric = false;
  }

  THPointScaleCommandOption.sizeAsNumber({
    required super.optionParent,
    required THDoublePart numericScaleSize,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    _numericSize = numericScaleSize;
    _isNumeric = true;
  }

  THPointScaleCommandOption.sizeAsNumberFromString({
    required super.optionParent,
    required String numericScaleSize,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    _numericSize = THDoublePart.fromString(valueString: numericScaleSize);
    _isNumeric = true;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'multipleChoiceSize': _multipleChoiceSize.toMap(),
      'numericSize': _numericSize.toMap(),
      'isNumeric': _isNumeric,
    };
  }

  factory THPointScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THPointScaleCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
      multipleChoiceSize:
          THMultipleChoicePart.fromMap(map['multipleChoiceSize']),
      numericSize: THDoublePart.fromMap(map['numericSize']),
      isNumeric: map['isNumeric'],
    );
  }

  factory THPointScaleCommandOption.fromJson(String jsonString) {
    return THPointScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPointScaleCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THMultipleChoicePart? multipleChoiceSize,
    THDoublePart? numericSize,
    bool? isNumeric,
  }) {
    return THPointScaleCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      multipleChoiceSize: multipleChoiceSize ?? this._multipleChoiceSize,
      numericSize: numericSize ?? this._numericSize,
      isNumeric: isNumeric ?? this._isNumeric,
    );
  }

  @override
  bool operator ==(covariant THPointScaleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other._multipleChoiceSize == _multipleChoiceSize &&
        other._numericSize == _numericSize &&
        other._isNumeric == _isNumeric;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        _multipleChoiceSize,
        _numericSize,
        _isNumeric,
      );

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
  String specToFile() {
    if (isNumeric) {
      return _numericSize.toString();
    } else {
      return _multipleChoiceSize.toString();
    }
  }
}
