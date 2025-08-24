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
  }) : choice = THOptionChoicesOnOffType.values.byName(choice),
       super();

  THOptionChoicesOnOffType get defaultChoice => THOptionChoicesOnOffType.on;

  @override
  String specToFile() {
    return choice.name;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'choice': specToFile()});

    return map;
  }

  @override
  bool equalsBase(Object other) {
    if (!super.equalsBase(other)) return false;

    return (other is THOnOffCommandOption && other.choice == choice);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return equalsBase(other);
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
