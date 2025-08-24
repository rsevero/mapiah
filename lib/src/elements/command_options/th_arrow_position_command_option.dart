part of 'th_command_option.dart';

abstract class THArrowPositionCommandOption
    extends THMultipleChoiceCommandOption {
  @override
  final THOptionChoicesArrowPositionType choice;

  THArrowPositionCommandOption.forCWJM({
    required super.parentMPID,
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
  }) : choice = THOptionChoicesArrowPositionType.values.byName(choice),
       super();

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

    return other is THArrowPositionCommandOption && other.choice == choice;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return equalsBase(other);
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
