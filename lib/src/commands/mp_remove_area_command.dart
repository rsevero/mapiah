part of "mp_command.dart";

class MPRemoveAreaCommand extends MPCommand with MPPreCommandMixin {
  final int areaMPID;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removeArea;

  MPRemoveAreaCommand.forCWJM({
    required this.areaMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveAreaCommand({
    required this.areaMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  @override
  MPCommandType get type => MPCommandType.removeArea;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THArea area = thFile.areaByMPID(areaMPID);
    final List<THElement> areaChildren = area.getChildren(thFile).toList();
    final THIsParentMixin areaParent = area.parent(thFile: thFile);
    final int areaPositionInParent = areaParent.getChildPosition(area);

    _undoRedoInfo = {
      'removedArea': area,
      'removedAreaChildren': areaChildren,
      'removedAreaPositionInParent': areaPositionInParent,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeRemoveElementByMPID(
      areaMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddAreaCommand.forCWJM(
      newArea: _undoRedoInfo!['removedArea'],
      areaChildren: _undoRedoInfo!['removedAreaChildren'],
      areaPositionInParent: _undoRedoInfo!['removedAreaPositionInParent'],
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
  MPRemoveAreaCommand copyWith({
    int? areaMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAreaCommand.forCWJM(
      areaMPID: areaMPID ?? this.areaMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAreaCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveAreaCommand.forCWJM(
      areaMPID: map['areaMPID'],
      preCommand: (map.containsKey('preCommand') && (map['preCommand'] != null))
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveAreaCommand.fromJson(String source) {
    return MPRemoveAreaCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'areaMPID': areaMPID, 'preCommand': preCommand?.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAreaCommand &&
        other.areaMPID == areaMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, areaMPID, preCommand?.hashCode ?? 0);
}
