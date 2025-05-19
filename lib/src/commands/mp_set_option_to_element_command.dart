part of 'mp_command.dart';

class MPSetOptionToElementCommand extends MPCommand {
  final THCommandOption option;
  final String newOriginalLineInTH2File;
  final String currentOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.setOptionToElement;

  MPSetOptionToElementCommand.forCWJM({
    required this.option,
    required this.newOriginalLineInTH2File,
    required this.currentOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPSetOptionToElementCommand({
    required this.option,
    super.descriptionType = _defaultDescriptionType,
    this.newOriginalLineInTH2File = '',
    this.currentOriginalLineInTH2File = '',
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

      oppositeCommand = MPSetOptionToElementCommand.forCWJM(
        option: currentOption,
        newOriginalLineInTH2File: currentOriginalLineInTH2File,
        currentOriginalLineInTH2File: newOriginalLineInTH2File,
        descriptionType: descriptionType,
      );
    } else {
      oppositeCommand = MPRemoveOptionFromElementCommand(
        optionType: option.type,
        parentMPID: option.parentMPID,
        newOriginalLineInTH2File: currentOriginalLineInTH2File,
        currentOriginalLineInTH2File: newOriginalLineInTH2File,
        descriptionType: descriptionType,
      );
    }

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPSetOptionToElementCommand copyWith({
    THCommandOption? option,
    String? newOriginalLineInTH2File,
    String? currentOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetOptionToElementCommand.forCWJM(
      option: option ?? this.option,
      newOriginalLineInTH2File:
          newOriginalLineInTH2File ?? this.newOriginalLineInTH2File,
      currentOriginalLineInTH2File:
          currentOriginalLineInTH2File ?? this.currentOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPSetOptionToElementCommand.forCWJM(
      option: THCommandOption.fromMap(map['option']),
      newOriginalLineInTH2File: map['newOriginalLineInTH2File'],
      currentOriginalLineInTH2File: map['currentOriginalLineInTH2File'],
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
      'newOriginalLineInTH2File': newOriginalLineInTH2File,
      'currentOriginalLineInTH2File': currentOriginalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPSetOptionToElementCommand &&
        other.option == option &&
        other.newOriginalLineInTH2File == newOriginalLineInTH2File &&
        other.currentOriginalLineInTH2File == currentOriginalLineInTH2File &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        option,
        newOriginalLineInTH2File,
        currentOriginalLineInTH2File,
      );
}
