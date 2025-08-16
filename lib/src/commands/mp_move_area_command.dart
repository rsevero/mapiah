part of 'mp_command.dart';

class MPMoveAreaCommand extends MPCommand {
  final int areaMPID;
  late final MPCommand linesMoveCommand;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveArea;

  MPMoveAreaCommand.forCWJM({
    required this.areaMPID,
    required this.linesMoveCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveAreaCommand.fromDeltaOnCanvas({
    required this.areaMPID,
    required Iterable<MPSelectedLine> originalLines,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    linesMoveCommand = MPMultipleElementsCommand.moveLinesFromDeltaOnCanvas(
      lines: originalLines,
      deltaOnCanvas: deltaOnCanvas,
      decimalPositions: decimalPositions,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.moveArea;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    linesMoveCommand.execute(
      th2FileEditController,
      keepOriginalLineTH2File: keepOriginalLineTH2File,
    );
    th2FileEditController.thFile.areaByMPID(areaMPID).clearBoundingBox();
    th2FileEditController.triggerNewLineRedraw();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeLinesMoveCommand = linesMoveCommand
        .getUndoRedoCommand(th2FileEditController)
        .undoCommand;
    final MPCommand oppositeCommand = MPMoveAreaCommand.forCWJM(
      areaMPID: areaMPID,
      linesMoveCommand: oppositeLinesMoveCommand,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaMPID': areaMPID,
      'linesMoveCommand': linesMoveCommand.toMap(),
    });

    return map;
  }

  factory MPMoveAreaCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveAreaCommand.forCWJM(
      areaMPID: map['areaMPID'],
      linesMoveCommand: MPMultipleElementsCommand.fromMap(
        map['linesMoveCommand'],
      ),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMoveAreaCommand.fromJson(String source) {
    return MPMoveAreaCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveAreaCommand copyWith({
    int? areaBorderTHIDMPID,
    MPMultipleElementsCommand? linesMoveCommand,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveAreaCommand.forCWJM(
      areaMPID: areaBorderTHIDMPID ?? this.areaMPID,
      linesMoveCommand: linesMoveCommand ?? this.linesMoveCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveAreaCommand &&
        other.areaMPID == areaMPID &&
        const DeepCollectionEquality().equals(
          other.linesMoveCommand,
          linesMoveCommand,
        ) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ Object.hash(areaMPID, linesMoveCommand);
}
