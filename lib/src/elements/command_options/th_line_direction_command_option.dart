part of 'th_command_option.dart';

/// direction <begin/end/both/none/point> . can be used only with the section
/// type. It indicates where to put a direction arrow on the section line.
/// Default is |none|. The point option must be used inside [LINE DATA]. The
/// others can (and should) be used as a line option.
class THLineDirectionCommandOption extends THArrowPositionCommandOption {
  THLineDirectionCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THLineDirectionCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THLineDirectionCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesArrowPositionType.values.byName(choice));

  @override
  THCommandOptionType get optionType => THCommandOptionType.lineDirection;

  @override
  String typeToFile() {
    return 'direction';
  }

  factory THLineDirectionCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineDirectionCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesArrowPositionType.values.byName(map['choice']),
    );
  }

  factory THLineDirectionCommandOption.fromJson(String jsonString) {
    return THLineDirectionCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineDirectionCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesArrowPositionType? choice,
  }) {
    return THLineDirectionCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
