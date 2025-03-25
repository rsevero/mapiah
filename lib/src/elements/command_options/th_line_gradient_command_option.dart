part of 'th_command_option.dart';

/// gradient <none/center/point> . can be used only with the contour type and in-
/// dicates where to put a gradient mark on the contour line. If there is no gradient
/// specification, behaviour is symbol-set dependent (e.g. no tick in UIS, tick in the mid-
/// dle in SKBB). The point option must be used inside [LINE DATA]. The others can
/// (and should) be used as a line option. Default is none.
class THLineGradientCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesLineGradientType choice;

  THLineGradientCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THLineGradientCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THLineGradientCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesLineGradientType.values.byName(choice),
        super();

  @override
  THCommandOptionType get type => THCommandOptionType.lineGradient;

  @override
  String specToFile() {
    return choice.name;
  }

  @override
  String typeToFile() {
    return 'gradient';
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'choice': specToFile(),
    });

    return map;
  }

  factory THLineGradientCommandOption.fromMap(Map<String, dynamic> map) {
    return THLineGradientCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesLineGradientType.values.byName(map['choice']),
    );
  }

  factory THLineGradientCommandOption.fromJson(String jsonString) {
    return THLineGradientCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLineGradientCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesLineGradientType? choice,
  }) {
    return THLineGradientCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THLineGradientCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
