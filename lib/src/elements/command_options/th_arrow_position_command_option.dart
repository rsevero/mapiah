part of 'th_command_option.dart';

/// direction <begin/end/both/none/point> . can be used only with the section
/// type. It indicates where to put a direction arrow on the section line.
/// Default is |none|. The point option must be used inside [LINE DATA]. The
/// others can (and should) be used as a line option.
class THArrowPositionCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesArrowPositionType choice;

  THArrowPositionCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THArrowPositionCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THArrowPositionCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesArrowPositionType.values.byName(choice),
        super();

  THOptionChoicesArrowPositionType get defaultChoice =>
      THOptionChoicesArrowPositionType.none;

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

  factory THArrowPositionCommandOption.fromMap(Map<String, dynamic> map) {
    return THArrowPositionCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesArrowPositionType.values.byName(map['choice']),
    );
  }

  factory THArrowPositionCommandOption.fromJson(String jsonString) {
    return THArrowPositionCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THArrowPositionCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesArrowPositionType? choice,
  }) {
    return THArrowPositionCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THArrowPositionCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
