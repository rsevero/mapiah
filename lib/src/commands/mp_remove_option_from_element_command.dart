part of 'mp_command.dart';

class MPRemoveOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final THCommandOptionType optionType;
  final String plaOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveOptionFromElementCommand.forCWJM({
    required this.optionType,
    required this.parentMPID,
    required this.plaOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveOptionFromElementCommand({
    required this.optionType,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
    this.plaOriginalLineInTH2File = '',
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeOptionFromElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THHasOptionsMixin parentElement = th2FileEditController.thFile
        .hasOptionByMPID(parentMPID);
    final THCommandOption? fromOption = parentElement.getOption(optionType);

    if (fromOption == null) {
      throw StateError(
        'Parent element does not have option of type $optionType',
      );
    }
    _undoRedoInfo = {
      'fromOption': fromOption,
      'fromPLAOriginalLineInTH2File': parentElement.originalLineInTH2File,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveOptionFromElement(
      optionType: optionType,
      parentMPID: parentMPID,
      newOriginalLineInTH2File: plaOriginalLineInTH2File,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPSetOptionToElementCommand.forCWJM(
      toOption: _undoRedoInfo!['fromOption'],
      toPLAOriginalLineInTH2File:
          _undoRedoInfo!['fromPLAOriginalLineInTH2File'],
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveOptionFromElementCommand copyWith({
    THCommandOptionType? optionType,
    int? parentMPID,
    String? plaOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: optionType ?? this.optionType,
      parentMPID: parentMPID ?? this.parentMPID,
      plaOriginalLineInTH2File:
          plaOriginalLineInTH2File ?? this.plaOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveOptionFromElementCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveOptionFromElementCommand.forCWJM(
      optionType: THCommandOptionType.values.byName(map['optionType']),
      parentMPID: map['parentMPID'],
      plaOriginalLineInTH2File: map['plaOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveOptionFromElementCommand.fromJson(String jsonString) {
    return MPRemoveOptionFromElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'optionType': optionType.name,
      'parentMPID': parentMPID,
      'plaOriginalLineInTH2File': plaOriginalLineInTH2File,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveOptionFromElementCommand &&
        other.optionType == optionType &&
        other.parentMPID == parentMPID &&
        other.plaOriginalLineInTH2File == plaOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    optionType,
    parentMPID,
    plaOriginalLineInTH2File,
  );
}
