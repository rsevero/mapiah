part of 'mp_command.dart';

class MPMoveBezierLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  final THPositionPart originalEndPointPosition;
  final THPositionPart originalControlPoint1Position;
  final THPositionPart originalControlPoint2Position;
  late final THPositionPart modifiedEndPointPosition;
  late final THPositionPart modifiedControlPoint1Position;
  late final THPositionPart modifiedControlPoint2Position;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveBezierLineSegment;

  MPMoveBezierLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.modifiedEndPointPosition,
    required this.originalControlPoint1Position,
    required this.modifiedControlPoint1Position,
    required this.originalControlPoint2Position,
    required this.modifiedControlPoint2Position,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveBezierLineSegmentCommand({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.modifiedEndPointPosition,
    required this.originalControlPoint1Position,
    required this.modifiedControlPoint1Position,
    required this.originalControlPoint2Position,
    required this.modifiedControlPoint2Position,
    super.descriptionType = _defaultDescriptionType,
  }) : originalLineInTH2File = '',
       super();

  MPMoveBezierLineSegmentCommand.fromLineSegments({
    required THBezierCurveLineSegment originalLineSegment,
    required THBezierCurveLineSegment modifiedLineSegment,
    super.descriptionType = _defaultDescriptionType,
  }) : lineSegmentMPID = originalLineSegment.mpID,
       originalEndPointPosition = originalLineSegment.endPoint,
       modifiedEndPointPosition = modifiedLineSegment.endPoint,
       originalControlPoint1Position = originalLineSegment.controlPoint1,
       modifiedControlPoint1Position = modifiedLineSegment.controlPoint1,
       originalControlPoint2Position = originalLineSegment.controlPoint2,
       modifiedControlPoint2Position = modifiedLineSegment.controlPoint2,
       originalLineInTH2File = '',
       super();

  MPMoveBezierLineSegmentCommand.fromDelta({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.originalControlPoint1Position,
    required this.originalControlPoint2Position,
    required Offset deltaOnCanvas,
    int? decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : modifiedEndPointPosition = THPositionPart(
         coordinates: originalEndPointPosition.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       modifiedControlPoint1Position = THPositionPart(
         coordinates: originalControlPoint1Position.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       modifiedControlPoint2Position = THPositionPart(
         coordinates: originalControlPoint2Position.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       originalLineInTH2File = '',
       super();

  MPMoveBezierLineSegmentCommand.fromEndPointExactPosition({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.originalControlPoint1Position,
    required this.originalControlPoint2Position,
    required THPositionPart lineSegmentFinalPosition,
    int? decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : originalLineInTH2File = '',
       super() {
    final Offset deltaOnCanvas =
        lineSegmentFinalPosition.coordinates -
        originalEndPointPosition.coordinates;

    modifiedEndPointPosition = lineSegmentFinalPosition;
    modifiedControlPoint1Position = THPositionPart(
      coordinates: originalControlPoint1Position.coordinates + deltaOnCanvas,
      decimalPositions: decimalPositions,
    );
    modifiedControlPoint2Position = THPositionPart(
      coordinates: originalControlPoint2Position.coordinates + deltaOnCanvas,
      decimalPositions: decimalPositions,
    );
  }

  @override
  MPCommandType get type => MPCommandType.moveBezierLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

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
          endPoint: modifiedEndPointPosition,
          controlPoint1: modifiedControlPoint1Position,
          controlPoint2: modifiedControlPoint2Position,
          originalLineInTH2File: keepOriginalLineTH2File ? null : '',
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
      originalEndPointPosition: modifiedEndPointPosition,
      modifiedEndPointPosition: originalEndPointPosition,
      originalControlPoint1Position: modifiedControlPoint1Position,
      modifiedControlPoint1Position: originalControlPoint1Position,
      originalControlPoint2Position: modifiedControlPoint2Position,
      modifiedControlPoint2Position: originalControlPoint2Position,
      originalLineInTH2File: th2FileEditController.thFile
          .elementByMPID(lineSegmentMPID)
          .originalLineInTH2File,
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
      'originalEndPointPosition': originalEndPointPosition.toMap(),
      'modifiedEndPointPosition': modifiedEndPointPosition.toMap(),
      'originalControlPoint1Position': originalControlPoint1Position.toMap(),
      'modifiedControlPoint1Position': modifiedControlPoint1Position.toMap(),
      'originalControlPoint2Position': originalControlPoint2Position.toMap(),
      'modifiedControlPoint2Position': modifiedControlPoint2Position.toMap(),
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  factory MPMoveBezierLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      originalEndPointPosition: THPositionPart.fromMap(
        map['originalEndPointPosition'],
      ),
      modifiedEndPointPosition: THPositionPart.fromMap(
        map['modifiedEndPointPosition'],
      ),
      originalControlPoint1Position: THPositionPart.fromMap(
        map['originalControlPoint1Position'],
      ),
      modifiedControlPoint1Position: THPositionPart.fromMap(
        map['modifiedControlPoint1Position'],
      ),
      originalControlPoint2Position: THPositionPart.fromMap(
        map['originalControlPoint2Position'],
      ),
      modifiedControlPoint2Position: THPositionPart.fromMap(
        map['modifiedControlPoint2Position'],
      ),
      originalLineInTH2File: map['originalLineInTH2File'],
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
    THPositionPart? originalEndPointPosition,
    THPositionPart? modifiedEndPointPosition,
    THPositionPart? originalControlPoint1Position,
    THPositionPart? modifiedControlPoint1Position,
    THPositionPart? originalControlPoint2Position,
    THPositionPart? modifiedControlPoint2Position,
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      originalEndPointPosition:
          originalEndPointPosition ?? this.originalEndPointPosition,
      modifiedEndPointPosition:
          modifiedEndPointPosition ?? this.modifiedEndPointPosition,
      originalControlPoint1Position:
          originalControlPoint1Position ?? this.originalControlPoint1Position,
      modifiedControlPoint1Position:
          modifiedControlPoint1Position ?? this.modifiedControlPoint1Position,
      originalControlPoint2Position:
          originalControlPoint2Position ?? this.originalControlPoint2Position,
      modifiedControlPoint2Position:
          modifiedControlPoint2Position ?? this.modifiedControlPoint2Position,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPMoveBezierLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.originalEndPointPosition == originalEndPointPosition &&
        other.modifiedEndPointPosition == modifiedEndPointPosition &&
        other.originalControlPoint1Position == originalControlPoint1Position &&
        other.modifiedControlPoint1Position == modifiedControlPoint1Position &&
        other.originalControlPoint2Position == originalControlPoint2Position &&
        other.modifiedControlPoint2Position == modifiedControlPoint2Position &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineSegmentMPID,
    originalEndPointPosition,
    modifiedEndPointPosition,
    originalControlPoint1Position,
    modifiedControlPoint1Position,
    originalControlPoint2Position,
    modifiedControlPoint2Position,
    originalLineInTH2File,
  );
}
