part of "mp_command.dart";

class MPRemoveScrapCommand extends MPCommand
    with MPPreCommandMixin, MPScrapChildrenMixin {
  final int scrapMPID;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removeScrap;

  MPRemoveScrapCommand.forCWJM({
    required this.scrapMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    assert(scrapMPID > 0);
    this.preCommand = preCommand;
  }

  MPRemoveScrapCommand({
    required this.scrapMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    assert(scrapMPID > 0);
    this.preCommand = preCommand;
  }

  @override
  MPCommandType get type => MPCommandType.removeScrap;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THScrap originalScrap = thFile.scrapByMPID(scrapMPID);
    final THIsParentMixin scrapParent = originalScrap.parent(thFile);
    final int scrapPositionInParent = scrapParent.getChildPosition(
      originalScrap,
    );
    final MPCommand addScrapChildrenCommand = getAddScrapChildrenCommand(
      scrap: originalScrap,
      thFile: thFile,
    );

    _undoRedoInfo = {
      'removedScrap': originalScrap,
      'removedScrapPositionInParent': scrapPositionInParent,
      'removedScrapAddScrapChildrenCommand': addScrapChildrenCommand,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.setActiveScrapForScrapRemoval(scrapMPID);
    th2FileEditController.elementEditController.executeRemoveElementByMPID(
      scrapMPID,
    );
    th2FileEditController.triggerAllElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddScrapCommand.forCWJM(
      newScrap: _undoRedoInfo!['removedScrap'] as THScrap,
      scrapPositionInParent:
          _undoRedoInfo!['removedScrapPositionInParent'] as int,
      addScrapChildrenCommand:
          _undoRedoInfo!['removedScrapAddScrapChildrenCommand'] as MPCommand,
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
  MPRemoveScrapCommand copyWith({
    int? scrapMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveScrapCommand.forCWJM(
      scrapMPID: scrapMPID ?? this.scrapMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveScrapCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveScrapCommand.forCWJM(
      scrapMPID: map['scrapMPID'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveScrapCommand.fromJson(String source) {
    return MPRemoveScrapCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'scrapMPID': scrapMPID, 'preCommand': preCommand?.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveScrapCommand &&
        other.scrapMPID == scrapMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, scrapMPID, preCommand?.hashCode ?? 0);
}
