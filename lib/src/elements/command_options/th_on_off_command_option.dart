part of 'th_command_option.dart';

abstract class THOnOffCommandOption extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesOnOffType choice;

  THOnOffCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THOnOffCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THOnOffCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesOnOffType.values.byName(choice),
        super();

  THOptionChoicesOnOffType get defaultChoice => THOptionChoicesOnOffType.on;

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

  @override
  bool operator ==(covariant THOnOffCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
