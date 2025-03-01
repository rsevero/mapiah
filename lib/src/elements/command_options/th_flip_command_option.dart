part of 'th_command_option.dart';

/// flip none/horizontal/vertical - flips the scrap after scale transformation.
/// Default is none.
class THFlipCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesFlipType choice;

  THFlipCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THFlipCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THFlipCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = _setChoiceFromString(choice),
        super();

  @override
  THCommandOptionType get type => THCommandOptionType.flip;

  THOptionChoicesFlipType get defautChoice => THOptionChoicesFlipType.none;

  @override
  String specToFile() {
    return choice.name;
  }

  static THOptionChoicesFlipType _setChoiceFromString(String choice) {
    switch (choice) {
      case 'horiz':
        return THOptionChoicesFlipType.horizontal;
      case 'vert':
        return THOptionChoicesFlipType.vertical;
      default:
        return THOptionChoicesFlipType.values.byName(choice);
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

  factory THFlipCommandOption.fromMap(Map<String, dynamic> map) {
    return THFlipCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: _setChoiceFromString(map['choice']),
    );
  }

  factory THFlipCommandOption.fromJson(String jsonString) {
    return THFlipCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THFlipCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesFlipType? choice,
  }) {
    return THFlipCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THFlipCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
