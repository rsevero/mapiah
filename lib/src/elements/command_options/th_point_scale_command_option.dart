part of 'th_command_option.dart';

/// Therion Book says for points:
/// scale . symbol scale, can be: tiny (xs), small (s), normal (m), large (l), huge (xl)
/// or a numeric value. Normal is default. Named sizes scale by √2, so that xs ≡ 0.5,
/// s ≡ 0.707, m ≡ 1.0, l ≡ 1.414 and xl ≡ 2.0.
class THPointScaleCommandOption extends THCommandOption {
  late final THMultipleChoicePart _multipleChoiceSize;
  late final THDoublePart _numericSize;
  late final bool _isNumeric;

  static const _scaleMultipleChoiceName = 'point|scale';

  THPointScaleCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required THMultipleChoicePart multipleChoiceSize,
    required THDoublePart numericSize,
    required bool isNumeric,
  })  : _multipleChoiceSize = multipleChoiceSize,
        _numericSize = numericSize,
        _isNumeric = isNumeric,
        super.forCWJM();

  THPointScaleCommandOption.sizeAsMultipleChoice({
    required super.optionParent,
    required String textScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    _multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: textScaleSize);
    _numericSize = THDoublePart(value: 0.0, decimalPositions: 0);
    _isNumeric = false;
  }

  THPointScaleCommandOption.sizeAsNumber({
    required super.optionParent,
    required THDoublePart numericScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    _multipleChoiceSize = THMultipleChoicePart(
        multipleChoiceName: _scaleMultipleChoiceName, choice: '');
    _numericSize = numericScaleSize;
    _isNumeric = true;
  }

  THPointScaleCommandOption.sizeAsNumberFromString({
    required super.optionParent,
    required String numericScaleSize,
    super.originalLineInTH2File = '',
  }) : super() {
    _numericSize = THDoublePart.fromString(valueString: numericScaleSize);
    _isNumeric = true;
  }

  @override
  THCommandOptionType get type => THCommandOptionType.pointScale;

  @override
  String typeToFile() => 'scale';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'multipleChoiceSize': _multipleChoiceSize.toMap(),
      'numericSize': _numericSize.toMap(),
      'isNumeric': _isNumeric,
    });

    return map;
  }

  factory THPointScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THPointScaleCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
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
    String? originalLineInTH2File,
    THMultipleChoicePart? multipleChoiceSize,
    THDoublePart? numericSize,
    bool? isNumeric,
  }) {
    return THPointScaleCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      multipleChoiceSize: multipleChoiceSize ?? _multipleChoiceSize,
      numericSize: numericSize ?? _numericSize,
      isNumeric: isNumeric ?? _isNumeric,
    );
  }

  @override
  bool operator ==(covariant THPointScaleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other._multipleChoiceSize == _multipleChoiceSize &&
        other._numericSize == _numericSize &&
        other._isNumeric == _isNumeric;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
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
