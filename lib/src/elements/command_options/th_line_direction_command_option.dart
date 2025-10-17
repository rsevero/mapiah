part of 'th_command_option.dart';

/// direction <begin/end/both/none/point> . can be used only with the section
/// type. It indicates where to put a direction arrow on the section line.
/// Default is |none|. The point option must be used inside [LINE DATA]. The
/// others can (and should) be used as a line option.
class THLineDirectionCommandOption extends THArrowPositionCommandOption {
  THLineDirectionCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THLineDirectionCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THLineDirectionCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesArrowPositionType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.lineDirection;

  @override
  String typeToFile() {
    return 'direction';
  }

  factory THLineDirectionCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineDirectionCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesArrowPositionType.values.byName(map['choice']),
    );
  }

  factory THLineDirectionCommandOption.fromJson(String jsonString) {
    return THLineDirectionCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineDirectionCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesArrowPositionType? choice,
  }) {
    return THLineDirectionCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      choice: choice ?? this.choice,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THLineDirectionCommandOption) return false;

    return super.equalsBase(other);
  }
}
