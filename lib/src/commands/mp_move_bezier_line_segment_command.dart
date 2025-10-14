part of 'mp_command.dart';

class MPMoveBezierLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  final THPositionPart fromEndPointPosition;
  final THPositionPart fromControlPoint1Position;
  final THPositionPart fromControlPoint2Position;
  late final THPositionPart toEndPointPosition;
  late final THPositionPart toControlPoint1Position;
  late final THPositionPart toControlPoint2Position;
  final String fromOriginalLineInTH2File;
  final String toOriginalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveBezierLineSegment;

  MPMoveBezierLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required this.toEndPointPosition,
    required this.fromControlPoint1Position,
    required this.toControlPoint1Position,
    required this.fromControlPoint2Position,
    required this.toControlPoint2Position,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveBezierLineSegmentCommand({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required this.toEndPointPosition,
    required this.fromControlPoint1Position,
    required this.toControlPoint1Position,
    required this.fromControlPoint2Position,
    required this.toControlPoint2Position,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMoveBezierLineSegmentCommand.fromLineSegments({
    required THBezierCurveLineSegment fromLineSegment,
    required THBezierCurveLineSegment toLineSegment,
    super.descriptionType = _defaultDescriptionType,
  }) : lineSegmentMPID = fromLineSegment.mpID,
       fromEndPointPosition = fromLineSegment.endPoint,
       toEndPointPosition = toLineSegment.endPoint,
       fromControlPoint1Position = fromLineSegment.controlPoint1,
       toControlPoint1Position = toLineSegment.controlPoint1,
       fromControlPoint2Position = fromLineSegment.controlPoint2,
       toControlPoint2Position = toLineSegment.controlPoint2,
       fromOriginalLineInTH2File = fromLineSegment.originalLineInTH2File,
       toOriginalLineInTH2File = '',
       super();

  MPMoveBezierLineSegmentCommand.fromDeltaOnCanvas({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required this.fromControlPoint1Position,
    required this.fromControlPoint2Position,
    required Offset deltaOnCanvas,
    int? decimalPositions,
    required this.fromOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : toEndPointPosition = THPositionPart(
         coordinates: fromEndPointPosition.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       toControlPoint1Position = THPositionPart(
         coordinates: fromControlPoint1Position.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       toControlPoint2Position = THPositionPart(
         coordinates: fromControlPoint2Position.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       toOriginalLineInTH2File = '',
       super();

  MPMoveBezierLineSegmentCommand.fromEndPointExactPosition({
    required this.lineSegmentMPID,
    required this.fromEndPointPosition,
    required this.fromControlPoint1Position,
    required this.fromControlPoint2Position,
    required THPositionPart lineSegmentFinalPosition,
    int? decimalPositions,
    required this.fromOriginalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : toOriginalLineInTH2File = '',
       super() {
    final Offset deltaOnCanvas =
        lineSegmentFinalPosition.coordinates - fromEndPointPosition.coordinates;

    toEndPointPosition = lineSegmentFinalPosition;
    toControlPoint1Position = THPositionPart(
      coordinates: fromControlPoint1Position.coordinates + deltaOnCanvas,
      decimalPositions: decimalPositions,
    );
    toControlPoint2Position = THPositionPart(
      coordinates: fromControlPoint2Position.coordinates + deltaOnCanvas,
      decimalPositions: decimalPositions,
    );
  }

  @override
  MPCommandType get type => MPCommandType.moveBezierLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final THBezierCurveLineSegment originalLineSegment = th2FileEditController
        .thFile
        .bezierCurveLineSegmentByMPID(lineSegmentMPID);
    final THBezierCurveLineSegment newLineSegment = originalLineSegment
        .copyWith(
          endPoint: toEndPointPosition,
          controlPoint1: toControlPoint1Position,
          controlPoint2: toControlPoint2Position,
          originalLineInTH2File: toOriginalLineInTH2File,
        );

    th2FileEditController.elementEditController
        .substituteElementWithoutAddSelectableElement(newLineSegment);
    th2FileEditController.triggerSelectedElementsRedraw();
    th2FileEditController.triggerNewLineRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID,
      fromEndPointPosition: toEndPointPosition,
      toEndPointPosition: fromEndPointPosition,
      fromControlPoint1Position: toControlPoint1Position,
      toControlPoint1Position: fromControlPoint1Position,
      fromControlPoint2Position: toControlPoint2Position,
      toControlPoint2Position: fromControlPoint2Position,
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
      'originalEndPointPosition': fromEndPointPosition.toMap(),
      'modifiedEndPointPosition': toEndPointPosition.toMap(),
      'originalControlPoint1Position': fromControlPoint1Position.toMap(),
      'modifiedControlPoint1Position': toControlPoint1Position.toMap(),
      'originalControlPoint2Position': fromControlPoint2Position.toMap(),
      'modifiedControlPoint2Position': toControlPoint2Position.toMap(),
      'fromOriginalLineInTH2File': fromOriginalLineInTH2File,
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
    });

    return map;
  }

  factory MPMoveBezierLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      fromEndPointPosition: THPositionPart.fromMap(
        map['originalEndPointPosition'],
      ),
      toEndPointPosition: THPositionPart.fromMap(
        map['modifiedEndPointPosition'],
      ),
      fromControlPoint1Position: THPositionPart.fromMap(
        map['originalControlPoint1Position'],
      ),
      toControlPoint1Position: THPositionPart.fromMap(
        map['modifiedControlPoint1Position'],
      ),
      fromControlPoint2Position: THPositionPart.fromMap(
        map['originalControlPoint2Position'],
      ),
      toControlPoint2Position: THPositionPart.fromMap(
        map['modifiedControlPoint2Position'],
      ),
      fromOriginalLineInTH2File: map['fromOriginalLineInTH2File'],
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMoveBezierLineSegmentCommand.fromJson(String source) {
    return MPMoveBezierLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveBezierLineSegmentCommand copyWith({
    int? lineSegmentMPID,
    THPositionPart? fromEndPointPosition,
    THPositionPart? toEndPointPosition,
    THPositionPart? fromControlPoint1Position,
    THPositionPart? toControlPoint1Position,
    THPositionPart? fromControlPoint2Position,
    THPositionPart? toControlPoint2Position,
    String? fromOriginalLineInTH2File,
    String? toOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      fromEndPointPosition: fromEndPointPosition ?? this.fromEndPointPosition,
      toEndPointPosition: toEndPointPosition ?? this.toEndPointPosition,
      fromControlPoint1Position:
          fromControlPoint1Position ?? this.fromControlPoint1Position,
      toControlPoint1Position:
          toControlPoint1Position ?? this.toControlPoint1Position,
      fromControlPoint2Position:
          fromControlPoint2Position ?? this.fromControlPoint2Position,
      toControlPoint2Position:
          toControlPoint2Position ?? this.toControlPoint2Position,
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

    return other is MPMoveBezierLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.fromEndPointPosition == fromEndPointPosition &&
        other.toEndPointPosition == toEndPointPosition &&
        other.fromControlPoint1Position == fromControlPoint1Position &&
        other.toControlPoint1Position == toControlPoint1Position &&
        other.fromControlPoint2Position == fromControlPoint2Position &&
        other.toControlPoint2Position == toControlPoint2Position &&
        other.fromOriginalLineInTH2File == fromOriginalLineInTH2File &&
        other.toOriginalLineInTH2File == toOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineSegmentMPID,
    fromEndPointPosition,
    toEndPointPosition,
    fromControlPoint1Position,
    toControlPoint1Position,
    fromControlPoint2Position,
    toControlPoint2Position,
    fromOriginalLineInTH2File,
    toOriginalLineInTH2File,
  );
}
