part of "mp_command.dart";

class MPRemoveLineCommand extends MPCommand
    with MPPreCommandMixin, MPPosCommandMixin {
  final int lineMPID;
  final bool isInteractiveLineCreation;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removeLine;

  MPRemoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    required MPCommand? preCommand,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
    this.posCommand = posCommand;
  }

  MPRemoveLineCommand({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    required MPCommand? preCommand,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
    this.posCommand = posCommand;
  }

  @override
  MPCommandType get type => MPCommandType.removeLine;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THLine line = thFile.lineByMPID(lineMPID);
    final List<THElement> lineChildren = line.getChildren(thFile).toList();
    final THIsParentMixin lineParent = line.parent(thFile);
    final int linePositionInParent = lineParent.getChildPosition(line);

    _undoRedoInfo = {
      'removedLine': line,
      'removedLineChildren': lineChildren,
      'removedLinePositionInParent': linePositionInParent,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeRemoveLine(lineMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddLineCommand.forCWJM(
      newLine: _undoRedoInfo!['removedLine'] as THLine,
      linePositionInParent:
          _undoRedoInfo!['removedLinePositionInParent'] as int,
      lineChildren: _undoRedoInfo!['removedLineChildren'] as List<THElement>,
      preCommand: posCommand
          ?.getUndoRedoCommand(th2FileEditController)
          .undoCommand,
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
  MPRemoveLineCommand copyWith({
    int? lineMPID,
    bool? isInteractiveLineCreation,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      isInteractiveLineCreation:
          isInteractiveLineCreation ?? this.isInteractiveLineCreation,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      isInteractiveLineCreation: map['isInteractiveLineCreation'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveLineCommand.fromJson(String source) {
    return MPRemoveLineCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineMPID': lineMPID,
      'isInteractiveLineCreation': isInteractiveLineCreation,
      'preCommand': preCommand?.toMap(),
      'posCommand': posCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveLineCommand &&
        other.lineMPID == lineMPID &&
        other.isInteractiveLineCreation == isInteractiveLineCreation &&
        other.preCommand == preCommand &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineMPID,
    isInteractiveLineCreation,
    preCommand?.hashCode ?? 0,
    posCommand?.hashCode ?? 0,
  );
}
