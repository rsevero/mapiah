part of 'mp_command.dart';

class MPMoveStraightLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  final THPositionPart fromEndPointPosition;
  late final THPositionPart toEndPointPosition;
  final String fromOriginalLineInTH2File;
  final String toOriginalLineInTH2File;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveStraightLineSegment;

  static MPCommandDescriptionType get defaultDescriptionTypeStatic =>
      _defaultDescriptionType;

  MPMoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required this.toEndPointPosition,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required this.toEndPointPosition,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMoveStraightLineSegmentCommand.fromDeltaOnCanvas({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required Offset deltaOnCanvas,
    int? decimalPositions,
    required this.fromOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : toEndPointPosition = THPositionPart(
         coordinates: fromEndPointPosition.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       toOriginalLineInTH2File = '',
       super();

  @override
  MPCommandType get type => MPCommandType.moveStraightLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THStraightLineSegment originalLineSegment = th2FileEditController
        .thFile
        .straightLineSegmentByMPID(lineSegmentMPID);
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
      endPoint: toEndPointPosition,
      originalLineInTH2File: toOriginalLineInTH2File,
    );

    th2FileEditController.elementEditController
        .substituteElementWithoutAddSelectableElement(newLineSegment);
    th2FileEditController.triggerNewLineRedraw();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID,
      fromEndPointPosition: toEndPointPosition,
      toEndPointPosition: fromEndPointPosition,
      fromOriginalLineInTH2File: toOriginalLineInTH2File,
      toOriginalLineInTH2File: fromOriginalLineInTH2File,
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
      'lineSegmentMPID': lineSegmentMPID,
      'fromEndPointPosition': fromEndPointPosition.toMap(),
      'toEndPointPosition': toEndPointPosition.toMap(),
      'fromOriginalLineInTH2File': fromOriginalLineInTH2File,
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
    });

    return map;
  }

  factory MPMoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      fromEndPointPosition: THPositionPart.fromMap(map['fromEndPointPosition']),
      toEndPointPosition: THPositionPart.fromMap(map['toEndPointPosition']),
      fromOriginalLineInTH2File: map['fromOriginalLineInTH2File'],
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMoveStraightLineSegmentCommand.fromJson(String source) {
    return MPMoveStraightLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveStraightLineSegmentCommand copyWith({
    int? lineSegmentMPID,
    THPositionPart? fromEndPointPosition,
    THPositionPart? toEndPointPosition,
    String? fromOriginalLineInTH2File,
    String? toOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      fromEndPointPosition: fromEndPointPosition ?? this.fromEndPointPosition,
      toEndPointPosition: toEndPointPosition ?? this.toEndPointPosition,
      fromOriginalLineInTH2File:
          fromOriginalLineInTH2File ?? this.fromOriginalLineInTH2File,
      toOriginalLineInTH2File:
          toOriginalLineInTH2File ?? this.toOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPMoveStraightLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.fromEndPointPosition == fromEndPointPosition &&
        other.toEndPointPosition == toEndPointPosition &&
        other.fromOriginalLineInTH2File == fromOriginalLineInTH2File &&
        other.toOriginalLineInTH2File == toOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineSegmentMPID,
    fromEndPointPosition,
    toEndPointPosition,
    fromOriginalLineInTH2File,
    toOriginalLineInTH2File,
  );
}
