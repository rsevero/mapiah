part of 'mp_command.dart';

class MPSetOptionToElementCommand extends MPCommand {
  final THCommandOption option;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.setOptionToElement;

  MPSetOptionToElementCommand.forCWJM({
    required this.option,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPSetOptionToElementCommand({
    required this.option,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.setOptionToElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applySetOptionToElement(
      option,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THHasOptionsMixin parentElement =
        option.optionParent(th2FileEditController.thFile);
    MPCommand oppositeCommand;

    if (parentElement.hasOption(option.type)) {
      final THCommandOption currentOption =
          parentElement.optionByType(option.type)!;

      oppositeCommand = MPSetOptionToElementCommand(
        option: currentOption,
        descriptionType: descriptionType,
      );
    } else {
      oppositeCommand = MPRemoveOptionFromElementCommand(
        optionType: option.type,
        parentMPID: option.parentMPID,
        descriptionType: descriptionType,
      );
    }

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THCommandOption? option,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetOptionToElementCommand.forCWJM(
      option: option ?? this.option,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPSetOptionToElementCommand.forCWJM(
      option: THCommandOption.fromMap(map['option']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPSetOptionToElementCommand.fromJson(String jsonString) {
    return MPSetOptionToElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'option': option.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPSetOptionToElementCommand &&
        other.option == option &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ option.hashCode;
}
