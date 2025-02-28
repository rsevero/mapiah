part of 'th_command_option.dart';

/// close <on/off/auto> . determines whether a line is closed or not
class THCloseCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesCloseType choice;

  THCloseCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THCloseCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THCloseCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesCloseType.values.byName(choice),
        super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.close;

  THOptionChoicesCloseType get defaultChoice => THOptionChoicesCloseType.auto;

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

  factory THCloseCommandOption.fromMap(Map<String, dynamic> map) {
    return THCloseCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesCloseType.values.byName(map['choice']),
    );
  }

  factory THCloseCommandOption.fromJson(String jsonString) {
    return THCloseCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCloseCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesCloseType? choice,
  }) {
    return THCloseCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THCloseCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
