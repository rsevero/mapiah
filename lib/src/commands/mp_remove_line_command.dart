part of "mp_command.dart";

class MPRemoveLineCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPreCommandMixin {
  final int lineMPID;
  final bool isInteractiveLineCreation;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeLine;

  MPRemoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveLineCommand({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  MPRemoveLineCommand.fromExisting({
    required int existingLineMPID,
    required this.isInteractiveLineCreation,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : lineMPID = existingLineMPID,
       super() {
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(lineMPID);

    if (areaMPID != null) {
      final THArea area = thFile.areaByMPID(areaMPID);
      final THAreaBorderTHID? areaTHID = area.areaBorderByLineMPID(
        lineMPID,
        thFile,
      );

      if (areaTHID != null) {
        // removeAreaTHIDCommand = MPRemoveAreaBorderTHIDCommand.fromExisting(
        //   existingAreaBorderTHIDMPID: areaTHID.mpID,
        //   thFile: thFile,
        //   descriptionType: descriptionType,
        // );
      }
    }

    preCommand = getRemoveEmptyLinesAfterCommand(
      elementMPID: existingLineMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removeLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

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
    final THFile thFile = th2FileEditController.thFile;
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(lineMPID);

    if (areaMPID != null) {
      final THArea area = thFile.areaByMPID(areaMPID);
      final THAreaBorderTHID? areaTHID = area.areaBorderByLineMPID(
        lineMPID,
        thFile,
      );

      if (areaTHID != null) {
        final MPCommand removeAreaTHIDCommand =
            MPRemoveAreaBorderTHIDCommand.fromExisting(
              existingAreaBorderTHIDMPID: areaTHID.mpID,
              thFile: thFile,
              descriptionType: descriptionType,
            );

        removeAreaTHIDCommand.execute(th2FileEditController);
      }
    }

    th2FileEditController.elementEditController.applyRemoveLine(lineMPID);
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
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      isInteractiveLineCreation:
          isInteractiveLineCreation ?? this.isInteractiveLineCreation,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
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
        other.preCommand == preCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineMPID,
    isInteractiveLineCreation,
    preCommand?.hashCode ?? 0,
  );
}
