part of 'mp_command.dart';

class MPRemoveAttrOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final String attrName;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveAttrOptionFromElementCommand.forCWJM({
    required this.attrName,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveAttrOptionFromElementCommand({
    required this.attrName,
    required this.parentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeAttrOptionFromElement;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THHasOptionsMixin parentElement = th2FileEditController.thFile
        .hasOptionByMPID(parentMPID);
    final THAttrCommandOption? option = parentElement.attrOptionByName(
      attrName,
    );

    if (option == null) {
      throw StateError(
        'Parent element does not have attr option with name $attrName',
      );
    }

    _undoRedoInfo = {
      'toOption': option,
      'toOriginalLineInTH2File': option.originalLineInTH2File,
      'toPLAOriginalLineInTH2File': parentElement.originalLineInTH2File,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController
        .applyRemoveAttrOptionFromElement(
          attrName: attrName,
          parentMPID: parentMPID,
        );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPSetAttrOptionToElementCommand.forCWJM(
      toOption: _undoRedoInfo!['toOption'] as THAttrCommandOption,
      toOriginalLineInTH2File:
          _undoRedoInfo!['toOriginalLineInTH2File'] as String,
      toPLAOriginalLineInTH2File:
          _undoRedoInfo!['toPLAOriginalLineInTH2File'] as String,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveAttrOptionFromElementCommand copyWith({
    String? attrName,
    int? parentMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAttrOptionFromElementCommand.forCWJM(
      attrName: attrName ?? this.attrName,
      parentMPID: parentMPID ?? this.parentMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAttrOptionFromElementCommand.fromMap(
    Map<String, dynamic> map,
  ) {
    return MPRemoveAttrOptionFromElementCommand.forCWJM(
      attrName: map['attrName'],
      parentMPID: map['parentMPID'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveAttrOptionFromElementCommand.fromJson(String jsonString) {
    return MPRemoveAttrOptionFromElementCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'attrName': attrName, 'parentMPID': parentMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAttrOptionFromElementCommand &&
        other.attrName == attrName &&
        other.parentMPID == parentMPID;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, attrName, parentMPID);
}
