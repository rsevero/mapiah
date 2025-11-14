part of 'mp_command.dart';

class MPSetOptionToElementCommand extends MPCommand {
  final THCommandOption toOption;
  final String toPLAOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.setOptionToElement;

  MPSetOptionToElementCommand.forCWJM({
    required this.toOption,
    required this.toPLAOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPSetOptionToElementCommand({
    required this.toOption,
    super.descriptionType = _defaultDescriptionType,
    this.toPLAOriginalLineInTH2File = '',
  }) : super();

  @override
  MPCommandType get type => MPCommandType.setOptionToElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final int parentMPID = toOption.parentMPID;
    final THHasOptionsMixin parentElement =
        th2FileEditController.thFile.elementByMPID(parentMPID)
            as THHasOptionsMixin;
    final THCommandOptionType optionType = toOption.type;
    final THCommandOption? fromOption = parentElement.getOption(optionType);

    if (fromOption == null) {
      _undoRedoInfo = {
        'alreadyHasAttrOption': false,
        'parentMPID': parentMPID,
        'optionType': optionType,
        'fromPLAOriginalLineInTH2File': parentElement.originalLineInTH2File,
      };
    } else {
      _undoRedoInfo = {
        'alreadyHasAttrOption': true,
        'fromOption': fromOption,
        'fromPLAOriginalLineInTH2File': parentElement.originalLineInTH2File,
      };
    }
  }

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
    final MPCommand oppositeCommand = _undoRedoInfo!['alreadyHasAttrOption']
        ? MPSetOptionToElementCommand.forCWJM(
            toOption: _undoRedoInfo!['fromOption'],
            toPLAOriginalLineInTH2File:
                _undoRedoInfo!['fromPLAOriginalLineInTH2File'],
            descriptionType: descriptionType,
          )
        : MPRemoveOptionFromElementCommand(
            optionType: toOption.type,
            parentMPID: toOption.parentMPID,
            plaOriginalLineInTH2File:
                _undoRedoInfo!['fromPLAOriginalLineInTH2File'],
            descriptionType: descriptionType,
          );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPSetOptionToElementCommand copyWith({
    THCommandOption? toOption,
    String? toPLAOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetOptionToElementCommand.forCWJM(
      toOption: toOption ?? this.toOption,
      toPLAOriginalLineInTH2File:
          toPLAOriginalLineInTH2File ?? this.toPLAOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPSetOptionToElementCommand.forCWJM(
      toOption: THCommandOption.fromMap(map['toOption']),
      toPLAOriginalLineInTH2File: map['toPLAOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPSetOptionToElementCommand.fromJson(String jsonString) {
    return MPSetOptionToElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'toOption': toOption.toMap(),
      'toPLAOriginalLineInTH2File': toPLAOriginalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPSetOptionToElementCommand &&
        other.toOption == toOption &&
        other.toPLAOriginalLineInTH2File == toPLAOriginalLineInTH2File;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, toOption, toPLAOriginalLineInTH2File);
}
