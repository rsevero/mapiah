part of 'mp_command.dart';

class MPMoveLineCommand extends MPCommand {
  final int lineMPID;
  late final MPCommand lineSegmentsMoveCommand;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveLine;

  MPMoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.lineSegmentsMoveCommand,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveLineCommand({
    required this.lineMPID,
    required LinkedHashMap<int, THLineSegment> originalLineSegmentsMap,
    required LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap,
    super.descriptionType = _defaultDescriptionType,
  }) : originalLineInTH2File = '',
       super() {
    lineSegmentsMoveCommand = MPCommandFactory.moveLineSegments(
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
  }) : originalLineInTH2File = '',
       super() {
    lineSegmentsMoveCommand =
        MPCommandFactory.moveLineSegmentsFromDeltaOnCanvas(
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
      th2FileEditController.thFile
          .elementByMPID(lineMPID)
          .copyWith(originalLineInTH2File: keepOriginalLineTH2File ? null : ''),
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
      originalLineInTH2File: th2FileEditController.thFile
          .elementByMPID(lineMPID)
          .originalLineInTH2File,
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
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  factory MPMoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      lineSegmentsMoveCommand: MPMultipleElementsCommand.fromMap(
        map['lineSegmentsMoveCommand'],
      ),
      originalLineInTH2File: map['originalLineInTH2File'],
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
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      lineSegmentsMoveCommand:
          lineSegmentsMoveCommand ?? this.lineSegmentsMoveCommand,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPMoveLineCommand &&
        other.lineMPID == lineMPID &&
        const DeepCollectionEquality().equals(
          other.lineSegmentsMoveCommand,
          lineSegmentsMoveCommand,
        ) &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineMPID,
    lineSegmentsMoveCommand,
    originalLineInTH2File,
  );
}
