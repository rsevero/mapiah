part of 'mp_command.dart';

class MPMoveLineCommand extends MPCommand {
  final int lineMPID;
  late final MPCommand lineSegmentsMoveCommand;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveLine;

  MPMoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.lineSegmentsMoveCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveLineCommand({
    required this.lineMPID,
    required Map<int, THLineSegment> fromLineSegmentsMap,
    required Map<int, THLineSegment> toLineSegmentsMap,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    lineSegmentsMoveCommand = MPCommandFactory.moveLineSegments(
      fromLineSegmentsMap: fromLineSegmentsMap,
      toLineSegmentsMap: toLineSegmentsMap,
      descriptionType: descriptionType,
    );
  }

  MPMoveLineCommand.fromDeltaOnCanvas({
    required this.lineMPID,
    required LinkedHashMap<int, THLineSegment> fromLineSegmentsMap,
    required Offset deltaOnCanvas,
    int? decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    lineSegmentsMoveCommand =
        MPCommandFactory.moveLineSegmentsFromDeltaOnCanvas(
          fromElementsMap: fromLineSegmentsMap,
          deltaOnCanvas: deltaOnCanvas,
          decimalPositions: decimalPositions,
          descriptionType: descriptionType,
        );
  }

  MPMoveLineCommand.fromLineSegmentExactPosition({
    required this.lineMPID,
    required LinkedHashMap<int, THLineSegment> fromLineSegmentsMap,
    required THLineSegment referenceLineSegment,
    required THPositionPart referenceLineSegmentFinalPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    lineSegmentsMoveCommand =
        MPCommandFactory.moveLineSegmentsFromLineSegmentExactPosition(
          fromElementsMap: fromLineSegmentsMap,
          referenceLineSegmentFinalPosition: referenceLineSegmentFinalPosition,
          referenceLineSegment: referenceLineSegment,
          descriptionType: descriptionType,
        );
  }

  @override
  MPCommandType get type => MPCommandType.moveLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    lineSegmentsMoveCommand._prepareUndoRedoInfo(th2FileEditController);
    _undoRedoInfo = {};
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    lineSegmentsMoveCommand.execute(th2FileEditController);
    th2FileEditController.elementEditController.substituteElement(
      th2FileEditController.thFile.elementByMPID(lineMPID),
    );
    th2FileEditController.triggerNewLineRedraw();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeLineSegmentsMoveCommand = lineSegmentsMoveCommand
        .getUndoRedoCommand(th2FileEditController)
        .undoCommand;
    final MPCommand oppositeCommand = MPMoveLineCommand.forCWJM(
      lineMPID: lineMPID,
      lineSegmentsMoveCommand: oppositeLineSegmentsMoveCommand,
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
      'lineMPID': lineMPID,
      'lineSegmentsMoveCommand': lineSegmentsMoveCommand.toMap(),
    });

    return map;
  }

  factory MPMoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      lineSegmentsMoveCommand: MPCommand.fromMap(
        map['lineSegmentsMoveCommand'],
      ),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMoveLineCommand.fromJson(String source) {
    return MPMoveLineCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveLineCommand copyWith({
    int? lineMPID,
    MPMultipleElementsCommand? lineSegmentsMoveCommand,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      lineSegmentsMoveCommand:
          lineSegmentsMoveCommand ?? this.lineSegmentsMoveCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPMoveLineCommand &&
        other.lineMPID == lineMPID &&
        other.lineSegmentsMoveCommand == lineSegmentsMoveCommand;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, lineMPID, lineSegmentsMoveCommand);
}
