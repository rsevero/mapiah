part of 'th_command_option.dart';

abstract class THOnOffAutoCommandOption extends THMultipleChoiceCommandOption {
  final THOptionChoicesOnOffAutoType choice;

  THOnOffAutoCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required super.parentElementType,
    required this.choice,
  }) : super.forCWJM();

  THOnOffAutoCommandOption({
    required super.optionParent,
    required this.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THOnOffAutoCommandOption.fromString({
    required super.optionParent,
    required String choice,
    super.originalLineInTH2File = '',
  })  : choice = THOptionChoicesOnOffAutoType.values.byName(choice),
        super();

  @override
  THCommandOptionType get type => THCommandOptionType.close;

  THOptionChoicesOnOffAutoType get defaultChoice =>
      THOptionChoicesOnOffAutoType.auto;

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
  bool operator ==(covariant THOnOffAutoCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.parentElementType == parentElementType &&
        other.choice == choice;
  }

  @override
  int get hashCode => super.hashCode ^ choice.hashCode;
}
