part of 'th_command_option.dart';

/// smooth <on/off/auto> -> whether the line is smooth at the given point.
/// Default is |auto|. This setting only has any effect if both segments that
/// passes through the  point affected by the smooth setting are Bezier Curves
/// (the one arriving at it and the one leaving it). On means that the line
/// connection at this point will be smoothed, both by therion and by xTherion.
/// Off means that smoothness at the point is not guaranteded. Auto means that,
/// if both segments that passes through the point are Bezier Curves, Therion
/// will automatically detected if they are smooth and, if they are detected as
/// smooth, Therion will keep them smooth in it's transformations. xTherion
/// always creates Bezier Curves as smooth, even if the previous segment was a
/// straight one.
class THSmoothCommandOption extends THOnOffAutoCommandOption {
  THSmoothCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required super.choice,
  }) : super.forCWJM();

  THSmoothCommandOption({
    required super.optionParent,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THSmoothCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffAutoType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.smooth;

  factory THSmoothCommandOption.fromMap(Map<String, dynamic> map) {
    return THSmoothCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesOnOffAutoType.values.byName(map['choice']),
    );
  }

  factory THSmoothCommandOption.fromJson(String jsonString) {
    return THSmoothCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THSmoothCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesOnOffAutoType? choice,
  }) {
    return THSmoothCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }
}
