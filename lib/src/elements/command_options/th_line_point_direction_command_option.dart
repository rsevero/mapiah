part of 'th_command_option.dart';

/// direction <begin/end/both/none/point> . can be used only with the section
/// type. It indicates where to put a direction arrow on the section line.
/// Default is |none|. The point option must be used inside [LINE DATA]. The
/// others can (and should) be used as a line option.
class THLinePointDirectionCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesLinePointDirectionType choice;

  THLinePointDirectionCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THLinePointDirectionCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THLinePointDirectionCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesLinePointDirectionType.values.byName(choice),
        super();

  @override
  THCommandOptionType get type => THCommandOptionType.linePointDirection;

  @override
  String specToFile() {
    return choice.name;
  }

  @override
  String typeToFile() {
    return 'direction';
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'choice': specToFile(),
    });

    return map;
  }

  factory THLinePointDirectionCommandOption.fromMap(Map<String, dynamic> map) {
    return THLinePointDirectionCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice:
          THOptionChoicesLinePointDirectionType.values.byName(map['choice']),
    );
  }

  factory THLinePointDirectionCommandOption.fromJson(String jsonString) {
    return THLinePointDirectionCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLinePointDirectionCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesLinePointDirectionType? choice,
  }) {
    return THLinePointDirectionCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THLinePointDirectionCommandOption) return false;

    return super.equalsBase(other);
  }
}
