part of 'th_command_option.dart';

/// gradient <none/center/point> . can be used only with the contour type and in-
/// dicates where to put a gradient mark on the contour line. If there is no gradient
/// specification, behaviour is symbol-set dependent (e.g. no tick in UIS, tick in the mid-
/// dle in SKBB). The point option must be used inside [LINE DATA]. The others can
/// (and should) be used as a line option. Default is none.
class THLinePointGradientCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesLinePointGradientType choice;

  THLinePointGradientCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THLinePointGradientCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THLinePointGradientCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesLinePointGradientType.values.byName(choice),
        super();

  @override
  THCommandOptionType get type => THCommandOptionType.linePointGradient;

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

  factory THLinePointGradientCommandOption.fromMap(Map<String, dynamic> map) {
    return THLinePointGradientCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      parentElementType: THElementType.values.byName(map['parentElementType']),
      choice: THOptionChoicesLinePointGradientType.values.byName(map['choice']),
    );
  }

  factory THLinePointGradientCommandOption.fromJson(String jsonString) {
    return THLinePointGradientCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THLinePointGradientCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THElementType? parentElementType,
    THOptionChoicesLinePointGradientType? choice,
  }) {
    return THLinePointGradientCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      parentElementType: parentElementType ?? this.parentElementType,
      choice: choice ?? this.choice,
    );
  }

  @override
  bool operator ==(covariant THLinePointGradientCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
