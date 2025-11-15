part of "mp_command.dart";

class MPRemoveAreaBorderTHIDCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPreCommandMixin {
  final int areaBorderTHIDMPID;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeAreaBorderTHID;

  MPRemoveAreaBorderTHIDCommand.forCWJM({
    required this.areaBorderTHIDMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveAreaBorderTHIDCommand({
    required this.areaBorderTHIDMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  MPRemoveAreaBorderTHIDCommand.fromExisting({
    required int existingAreaBorderTHIDMPID,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : areaBorderTHIDMPID = existingAreaBorderTHIDMPID,
       super() {
    final THAreaBorderTHID areaBorderTHID = thFile.areaBorderTHIDByMPID(
      existingAreaBorderTHIDMPID,
    );
    final THIsParentMixin parent = areaBorderTHID.parent(thFile);

    preCommand = getRemoveEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: parent.getChildPosition(areaBorderTHID),
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removeAreaBorderTHID;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THAreaBorderTHID areaBorderTHID = thFile.areaBorderTHIDByMPID(
      areaBorderTHIDMPID,
    );
    final THIsParentMixin parent = thFile.parentByMPID(
      areaBorderTHID.parentMPID,
    );
    final int positionInParent = parent.getChildPosition(areaBorderTHID);

    _undoRedoInfo = {
      'removedAreaBorderTHID': areaBorderTHID,
      'removedAreaBorderTHIDPositionInParent': positionInParent,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      areaBorderTHIDMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID:
          _undoRedoInfo!['removedAreaBorderTHID'] as THAreaBorderTHID,
      areaBorderTHIDPositionInParent:
          _undoRedoInfo!['removedAreaBorderTHIDPositionInParent'] as int,
      posCommand: preCommand
          ?.getUndoRedoCommand(th2FileEditController)
          .undoCommand,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveAreaBorderTHIDCommand copyWith({
    int? areaBorderTHIDMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAreaBorderTHIDCommand.forCWJM(
      areaBorderTHIDMPID: areaBorderTHIDMPID ?? this.areaBorderTHIDMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveAreaBorderTHIDCommand.forCWJM(
      areaBorderTHIDMPID: map['areaBorderTHIDMPID'],
      preCommand: (map.containsKey('preCommand') && (map['preCommand'] != null))
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveAreaBorderTHIDCommand.fromJson(String source) {
    return MPRemoveAreaBorderTHIDCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaBorderTHIDMPID': areaBorderTHIDMPID,
      'preCommand': preCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAreaBorderTHIDCommand &&
        other.areaBorderTHIDMPID == areaBorderTHIDMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, areaBorderTHIDMPID, preCommand);
}
