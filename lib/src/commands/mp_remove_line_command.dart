part of "mp_command.dart";

class MPRemoveLineCommand extends MPCommand {
  final int lineMPID;
  final bool isInteractiveLineCreation;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeLine;

  MPRemoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveLineCommand({
    required this.lineMPID,
    required this.isInteractiveLineCreation,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

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
  }

  @override
  MPCommandType get type => MPCommandType.removeLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THLine originalLine = thFile.lineByMPID(lineMPID);
    final MPCommand addLineCommand = MPAddLineCommand.fromExisting(
      existingLine: originalLine,
      thFile: thFile,
    );

    _undoRedoInfo = {'addLineCommand': addLineCommand};
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
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

        removeAreaTHIDCommand.execute(
          th2FileEditController,
          keepOriginalLineTH2File: keepOriginalLineTH2File,
        );
      }
    }

    th2FileEditController.elementEditController.applyRemoveLine(lineMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['addLineCommand'] as MPCommand;

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveLineCommand copyWith({
    int? lineMPID,
    bool? isInteractiveLineCreation,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      isInteractiveLineCreation:
          isInteractiveLineCreation ?? this.isInteractiveLineCreation,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      isInteractiveLineCreation: map['isInteractiveLineCreation'],
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
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveLineCommand &&
        other.lineMPID == lineMPID &&
        other.isInteractiveLineCreation == isInteractiveLineCreation;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, lineMPID, isInteractiveLineCreation);
}
