part of 'mp_command.dart';

class MPSetAttrOptionToElementCommand extends MPCommand {
  final THAttrCommandOption toOption;
  final String toOriginalLineInTH2File;
  final String toPLAOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.setOptionToElement;

  MPSetAttrOptionToElementCommand.forCWJM({
    required this.toOption,
    required this.toOriginalLineInTH2File,
    required this.toPLAOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPSetAttrOptionToElementCommand({
    required this.toOption,
    this.toOriginalLineInTH2File = '',
    this.toPLAOriginalLineInTH2File = '',
    super.descriptionType = _defaultDescriptionType,
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
    th2FileEditController.elementEditController.applySetOptionToElement(
      option: toOption,
      plaOriginalLineInTH2File: toPLAOriginalLineInTH2File,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THHasOptionsMixin parentElement = toOption.optionParent(
      th2FileEditController.thFile,
    );

    MPCommand oppositeCommand;

    if (parentElement.hasAttrOption(toOption.name.content)) {
      final THAttrCommandOption fromOption = parentElement.getAttrOption(
        toOption.name.content,
      )!;

      oppositeCommand = MPSetAttrOptionToElementCommand.forCWJM(
        toOption: fromOption,
        toOriginalLineInTH2File: fromOption.originalLineInTH2File,
        toPLAOriginalLineInTH2File: parentElement.originalLineInTH2File,
        descriptionType: descriptionType,
      );
    } else {
      oppositeCommand = MPRemoveAttrOptionFromElementCommand(
        attrName: toOption.name.content,
        parentMPID: toOption.parentMPID,
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
    THAttrCommandOption? toOption,
    String? toOriginalLineInTH2File,
    String? toPLAOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetAttrOptionToElementCommand.forCWJM(
      toOption: toOption ?? this.toOption,
      toOriginalLineInTH2File:
          toOriginalLineInTH2File ?? this.toOriginalLineInTH2File,
      toPLAOriginalLineInTH2File:
          toPLAOriginalLineInTH2File ?? this.toPLAOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetAttrOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPSetAttrOptionToElementCommand.forCWJM(
      toOption: THAttrCommandOption.fromMap(map['toOption']),
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      toPLAOriginalLineInTH2File: map['toPLAOriginalLineInTH2File'],
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
      'toOption': toOption.toMap(),
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
      'toPLAOriginalLineInTH2File': toPLAOriginalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPSetAttrOptionToElementCommand &&
        other.toOption == toOption &&
        other.toOriginalLineInTH2File == toOriginalLineInTH2File &&
        other.toPLAOriginalLineInTH2File == toPLAOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    toOption,
    toOriginalLineInTH2File,
    toPLAOriginalLineInTH2File,
  );
}
