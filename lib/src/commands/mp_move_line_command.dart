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
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    lineSegmentsMoveCommand = MPMultipleElementsCommand.moveLineSegments(
      originalElementsMap: originalLineSegmentsMap,
      modifiedElementsMap: modifiedLineSegmentsMap,
      descriptionType: descriptionType,
    );
  }

  MPMoveLineCommand.fromDeltaOnCanvas({
    required this.lineMPID,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    lineSegmentsMoveCommand =
        MPMultipleElementsCommand.moveLineSegmentsFromDeltaOnCanvas(
      originalElementsMap: originalLineSegmentsMap,
      deltaOnCanvas: deltaOnCanvas,
      decimalPositions: decimalPositions,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.moveLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    lineSegmentsMoveCommand.execute(
      th2FileEditController,
      keepOriginalLineTH2File: keepOriginalLineTH2File,
    );
    th2FileEditController.elementEditController.substituteElement(
      th2FileEditController.thFile.elementByMPID(lineMPID).copyWith(
            originalLineInTH2File: keepOriginalLineTH2File ? null : '',
          ),
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
    final MPMoveLineCommand oppositeCommand = MPMoveLineCommand.forCWJM(
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
      lineSegmentsMoveCommand: MPMultipleElementsCommand.fromMap(
        map['lineSegmentsMoveCommand'],
      ),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
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

    return other is MPMoveLineCommand &&
        other.lineMPID == lineMPID &&
        const DeepCollectionEquality()
            .equals(other.lineSegmentsMoveCommand, lineSegmentsMoveCommand) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineMPID,
        lineSegmentsMoveCommand,
      );
}
