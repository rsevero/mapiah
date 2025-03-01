part of 'th_command_option.dart';

/// align - alignment of the symbol or text. The following values are accepted:
/// center, c, top, t, bottom, b, left, l, right, r, top-left, tl, top-right,
/// tr, bottom-left, bl, bottom-right, br. Default is center.
class THAlignCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesAlignType choice;

  THAlignCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THAlignCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THAlignCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = _setChoiceFromString(choice),
        super();

  @override
  THCommandOptionType get type => THCommandOptionType.align;

  THOptionChoicesAlignType get defaultChoice => THOptionChoicesAlignType.center;

  @override
  String specToFile() {
    return MPTypeAux.convertCamelCaseToHyphenated(choice.name);
  }

  static THOptionChoicesAlignType _setChoiceFromString(String choice) {
    switch (choice) {
      case 'c':
        return THOptionChoicesAlignType.center;
      case 't':
        return THOptionChoicesAlignType.top;
      case 'b':
        return THOptionChoicesAlignType.bottom;
      case 'l':
        return THOptionChoicesAlignType.left;
      case 'r':
        return THOptionChoicesAlignType.right;
      case 'tl':
        return THOptionChoicesAlignType.topLeft;
      case 'tr':
        return THOptionChoicesAlignType.topRight;
      case 'bl':
        return THOptionChoicesAlignType.bottomLeft;
      case 'br':
        return THOptionChoicesAlignType.bottomRight;
      default:
        choice = MPTypeAux.convertHyphenatedToCamelCase(choice);

        return THOptionChoicesAlignType.values.byName(choice);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'choice': specToFile(),
    });

    return map;
  }

  factory THAlignCommandOption.fromMap(Map<String, dynamic> map) {
    return THAlignCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: _setChoiceFromString(map['choice']),
    );
  }

  factory THAlignCommandOption.fromJson(String jsonString) {
    return THAlignCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAlignCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesAlignType? choice,
  }) {
    return THAlignCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THAlignCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
