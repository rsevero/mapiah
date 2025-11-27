part of 'mp_command.dart';

class MPRemoveAttrOptionFromElementCommand extends MPCommand {
  final int parentMPID;
  final String attrName;
  final String plaOriginalTH2FileLine;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removeOptionFromElement;

  MPRemoveAttrOptionFromElementCommand.forCWJM({
    required this.parentMPID,
    required this.attrName,
    required this.plaOriginalTH2FileLine,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveAttrOptionFromElementCommand({
    required this.parentMPID,
    required this.attrName,
    required this.plaOriginalTH2FileLine,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeAttrOptionFromElement;

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
      'fromOption': option,
      'toPLAOriginalLineInTH2File': parentElement.originalLineInTH2File,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController
        .applyRemoveAttrOptionFromElement(
          parentMPID: parentMPID,
          attrName: attrName,
          plaOriginalLineInTH2File: plaOriginalTH2FileLine,
        );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPSetAttrOptionToElementCommand.forCWJM(
      toOption: _undoRedoInfo!['fromOption'] as THAttrCommandOption,
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
    int? parentMPID,
    String? attrName,
    String? plaOriginalTH2FileLine,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAttrOptionFromElementCommand.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      attrName: attrName ?? this.attrName,
      plaOriginalTH2FileLine:
          plaOriginalTH2FileLine ?? this.plaOriginalTH2FileLine,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAttrOptionFromElementCommand.fromMap(
    Map<String, dynamic> map,
  ) {
    return MPRemoveAttrOptionFromElementCommand.forCWJM(
      parentMPID: map['parentMPID'],
      attrName: map['attrName'],
      plaOriginalTH2FileLine: map['plaOriginalTH2FileLine'],
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

    map.addAll({
      'parentMPID': parentMPID,
      'attrName': attrName,
      'plaOriginalTH2FileLine': plaOriginalTH2FileLine,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAttrOptionFromElementCommand &&
        other.parentMPID == parentMPID &&
        other.attrName == attrName &&
        other.plaOriginalTH2FileLine == plaOriginalTH2FileLine;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, parentMPID, attrName, plaOriginalTH2FileLine);
}
