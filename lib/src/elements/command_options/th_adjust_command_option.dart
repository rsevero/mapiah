part of 'th_command_option.dart';

/// adjust <horizontal/vertical> - shifts the line point to be aligned
/// horizontally/vertically with the previous point. It can't be set on the
/// first point. The result is a horizontal/vertical line segment. This option
/// is not allowed in the |plan| projection. Default is unset where the line
/// point isn't automatically aligned with the previous line point.
class THAdjustCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesAdjustType choice;

  THAdjustCommandOption.forCWJM({
    required super.parentMapiahID,
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
  })  : choice = THOptionChoicesAdjustType.values.byName(choice),
        super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.adjust;

  @override
  String specToFile() {
    return choice.name;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'choice': specToFile(),
    });

    return map;
  }

  factory THAdjustCommandOption.fromMap(Map<String, dynamic> map) {
    return THAdjustCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesAdjustType.values.byName(map['choice']),
    );
  }

  factory THAdjustCommandOption.fromJson(String jsonString) {
    return THAdjustCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THAdjustCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesAdjustType? choice,
  }) {
    return THAdjustCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THAdjustCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
