part of 'mp_command.dart';

class MPSetAttrOptionToElementCommand extends MPCommand {
  final THAttrCommandOption option;
  final String newOriginalLineInTH2File;
  final String currentOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.setOptionToElement;

  MPSetAttrOptionToElementCommand.forCWJM({
    required this.option,
    required this.newOriginalLineInTH2File,
    required this.currentOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPSetAttrOptionToElementCommand({
    required this.option,
    super.descriptionType = _defaultDescriptionType,
    this.newOriginalLineInTH2File = '',
    this.currentOriginalLineInTH2File = '',
  }) : super();

  @override
  MPCommandType get type => MPCommandType.setAttrOptionToElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applySetOptionToElement(option);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THHasOptionsMixin parentElement = option.optionParent(
      th2FileEditController.thFile,
    );

    MPCommand oppositeCommand;

    if (parentElement.hasAttrOption(option.name.content)) {
      final THAttrCommandOption currentOption = parentElement.getAttrOption(
        option.name.content,
      )!;

      oppositeCommand = MPSetAttrOptionToElementCommand.forCWJM(
        option: currentOption,
        newOriginalLineInTH2File: currentOriginalLineInTH2File,
        currentOriginalLineInTH2File: newOriginalLineInTH2File,
        descriptionType: descriptionType,
      );
    } else {
      oppositeCommand = MPRemoveAttrOptionFromElementCommand(
        attrName: option.name.content,
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
  MPSetAttrOptionToElementCommand copyWith({
    THAttrCommandOption? option,
    String? newOriginalLineInTH2File,
    String? currentOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetAttrOptionToElementCommand.forCWJM(
      option: option ?? this.option,
      newOriginalLineInTH2File:
          newOriginalLineInTH2File ?? this.newOriginalLineInTH2File,
      currentOriginalLineInTH2File:
          currentOriginalLineInTH2File ?? this.currentOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetAttrOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPSetAttrOptionToElementCommand.forCWJM(
      option: THAttrCommandOption.fromMap(map['option']),
      newOriginalLineInTH2File: map['newOriginalLineInTH2File'],
      currentOriginalLineInTH2File: map['currentOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPSetAttrOptionToElementCommand.fromJson(String jsonString) {
    return MPSetAttrOptionToElementCommand.fromMap(jsonDecode(jsonString));
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
    if (!super.equalsBase(other)) return false;

    return other is MPSetAttrOptionToElementCommand &&
        other.option == option &&
        other.newOriginalLineInTH2File == newOriginalLineInTH2File &&
        other.currentOriginalLineInTH2File == currentOriginalLineInTH2File;
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
