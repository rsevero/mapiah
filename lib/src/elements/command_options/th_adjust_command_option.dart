part of 'th_command_option.dart';

/// adjust <horizontal/vertical> - shifts the line point to be aligned
/// horizontally/vertically with the previous point. It can't be set on the
/// first point. The result is a horizontal/vertical line segment. This option
/// is not allowed in the |plan| projection. Default is unset where the line
/// point isn't automatically aligned with the previous line point.
class THAdjustCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesAdjustType choice;

  THAdjustCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THAdjustCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THAdjustCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : choice = _setChoiceFromString(choice),
       super();

  @override
  THCommandOptionType get type => THCommandOptionType.adjust;

  @override
  String specToFile() {
    return choice.name;
  }

  static THOptionChoicesAdjustType _setChoiceFromString(String choice) {
    switch (choice) {
      case 'horiz':
        return THOptionChoicesAdjustType.horizontal;
      case 'vert':
        return THOptionChoicesAdjustType.vertical;
      default:
        return THOptionChoicesAdjustType.values.byName(choice);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'choice': specToFile()});

    return map;
  }

  factory THAdjustCommandOption.fromMap(Map<String, dynamic> map) {
    return THAdjustCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: _setChoiceFromString(map['choice']),
    );
  }

  factory THAdjustCommandOption.fromJson(String jsonString) {
    return THAdjustCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAdjustCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesAdjustType? choice,
  }) {
    return THAdjustCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THAdjustCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
