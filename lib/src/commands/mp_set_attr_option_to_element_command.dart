part of 'mp_command.dart';

class MPSetAttrOptionToElementCommand extends MPCommand {
  final THAttrCommandOption toOption;
  final String toPLAOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.setOptionToElement;

  MPSetAttrOptionToElementCommand.forCWJM({
    required this.toOption,
    required this.toPLAOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPSetAttrOptionToElementCommand({
    required this.toOption,
    this.toPLAOriginalLineInTH2File = '',
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.setAttrOptionToElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final int parentMPID = toOption.parentMPID;
    final THHasOptionsMixin parentElement =
        th2FileEditController.thFile.elementByMPID(parentMPID)
            as THHasOptionsMixin;
    final String attrName = toOption.name.content;
    final THAttrCommandOption? fromOption = parentElement.getAttrOption(
      attrName,
    );

    if (fromOption == null) {
      _undoRedoInfo = {
        'alreadyHasAttrOption': false,
        'parentMPID': parentMPID,
        'attrName': attrName,
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
    th2FileEditController.elementEditController.applySetAttrOptionToElement(
      attrOption: toOption,
      plaOriginalLineInTH2File: toPLAOriginalLineInTH2File,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['alreadyHasAttrOption'] as bool
        ? MPSetAttrOptionToElementCommand.forCWJM(
            toOption: _undoRedoInfo!['fromOption'] as THAttrCommandOption,
            toPLAOriginalLineInTH2File:
                _undoRedoInfo!['fromPLAOriginalLineInTH2File'] as String,
            descriptionType: descriptionType,
          )
        : MPRemoveAttrOptionFromElementCommand(
            parentMPID: _undoRedoInfo!['parentMPID'] as int,
            attrName: _undoRedoInfo!['attrName'] as String,
            plaOriginalTH2FileLine:
                _undoRedoInfo!['fromPLAOriginalLineInTH2File'] as String,
            descriptionType: descriptionType,
          );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPSetAttrOptionToElementCommand copyWith({
    THAttrCommandOption? toOption,
    String? toPLAOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetAttrOptionToElementCommand.forCWJM(
      toOption: toOption ?? this.toOption,
      toPLAOriginalLineInTH2File:
          toPLAOriginalLineInTH2File ?? this.toPLAOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetAttrOptionToElementCommand.fromMap(Map<String, dynamic> map) {
    return MPSetAttrOptionToElementCommand.forCWJM(
      toOption: THAttrCommandOption.fromMap(map['toOption']),
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
        other.toPLAOriginalLineInTH2File == toPLAOriginalLineInTH2File;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, toOption, toPLAOriginalLineInTH2File);
}
