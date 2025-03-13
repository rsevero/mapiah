part of 'mp_command.dart';

class MPMoveBezierLineSegmentCommand extends MPCommand {
  final int lineSegmentMapiahID;
  final Offset originalEndPointCoordinates;
  final Offset originalControlPoint1Coordinates;
  final Offset originalControlPoint2Coordinates;
  late final Offset modifiedEndPointCoordinates;
  late final Offset modifiedControlPoint1Coordinates;
  late final Offset modifiedControlPoint2Coordinates;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveBezierLineSegment;

  MPMoveBezierLineSegmentCommand.forCWJM({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    required this.originalControlPoint1Coordinates,
    required this.modifiedControlPoint1Coordinates,
    required this.originalControlPoint2Coordinates,
    required this.modifiedControlPoint2Coordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveBezierLineSegmentCommand({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    required this.originalControlPoint1Coordinates,
    required this.modifiedControlPoint1Coordinates,
    required this.originalControlPoint2Coordinates,
    required this.modifiedControlPoint2Coordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMoveBezierLineSegmentCommand.fromDelta({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required this.originalControlPoint1Coordinates,
    required this.originalControlPoint2Coordinates,
    required Offset deltaOnCanvas,
    super.descriptionType = _defaultDescriptionType,
  })  : modifiedEndPointCoordinates =
            originalEndPointCoordinates + deltaOnCanvas,
        modifiedControlPoint1Coordinates =
            originalControlPoint1Coordinates + deltaOnCanvas,
        modifiedControlPoint2Coordinates =
            originalControlPoint2Coordinates + deltaOnCanvas,
        super();

  @override
  MPCommandType get type => MPCommandType.moveBezierLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THBezierCurveLineSegment originalLineSegment =
        th2FileEditController.thFile.elementByMapiahID(lineSegmentMapiahID)
            as THBezierCurveLineSegment;
    final THBezierCurveLineSegment newLineSegment =
        originalLineSegment.copyWith(
            endPoint: originalLineSegment.endPoint
                .copyWith(coordinates: modifiedEndPointCoordinates),
            controlPoint1: originalLineSegment.controlPoint1
                .copyWith(coordinates: modifiedControlPoint1Coordinates),
            controlPoint2: originalLineSegment.controlPoint2
                .copyWith(coordinates: modifiedControlPoint2Coordinates));

    th2FileEditController.elementEditController
        .substituteElementWithoutAddSelectableElement(newLineSegment);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPMoveBezierLineSegmentCommand oppositeCommand =
        MPMoveBezierLineSegmentCommand(
      lineSegmentMapiahID: lineSegmentMapiahID,
      originalEndPointCoordinates: modifiedEndPointCoordinates,
      modifiedEndPointCoordinates: originalEndPointCoordinates,
      originalControlPoint1Coordinates: modifiedControlPoint1Coordinates,
      modifiedControlPoint1Coordinates: originalControlPoint1Coordinates,
      originalControlPoint2Coordinates: modifiedControlPoint2Coordinates,
      modifiedControlPoint2Coordinates: originalControlPoint2Coordinates,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      mapUndo: oppositeCommand.toMap(),
      mapRedo: toMap(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineSegmentMapiahID': lineSegmentMapiahID,
      'originalEndPointCoordinates': {
        'dx': originalEndPointCoordinates.dx,
        'dy': originalEndPointCoordinates.dy,
      },
      'modifiedEndPointCoordinates': {
        'dx': modifiedEndPointCoordinates.dx,
        'dy': modifiedEndPointCoordinates.dy,
      },
      'originalControlPoint1Coordinates': {
        'dx': originalControlPoint1Coordinates.dx,
        'dy': originalControlPoint1Coordinates.dy,
      },
      'modifiedControlPoint1Coordinates': {
        'dx': modifiedControlPoint1Coordinates.dx,
        'dy': modifiedControlPoint1Coordinates.dy,
      },
      'originalControlPoint2Coordinates': {
        'dx': originalControlPoint2Coordinates.dx,
        'dy': originalControlPoint2Coordinates.dy,
      },
      'modifiedControlPoint2Coordinates': {
        'dx': modifiedControlPoint2Coordinates.dx,
        'dy': modifiedControlPoint2Coordinates.dy,
      },
    });

    return map;
  }

  factory MPMoveBezierLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: map['lineSegmentMapiahID'],
      originalEndPointCoordinates: Offset(
        map['originalEndPointCoordinates']['dx'],
        map['originalEndPointCoordinates']['dy'],
      ),
      modifiedEndPointCoordinates: Offset(
        map['modifiedEndPointCoordinates']['dx'],
        map['modifiedEndPointCoordinates']['dy'],
      ),
      originalControlPoint1Coordinates: Offset(
        map['originalControlPoint1Coordinates']['dx'],
        map['originalControlPoint1Coordinates']['dy'],
      ),
      modifiedControlPoint1Coordinates: Offset(
        map['modifiedControlPoint1Coordinates']['dx'],
        map['modifiedControlPoint1Coordinates']['dy'],
      ),
      originalControlPoint2Coordinates: Offset(
        map['originalControlPoint2Coordinates']['dx'],
        map['originalControlPoint2Coordinates']['dy'],
      ),
      modifiedControlPoint2Coordinates: Offset(
        map['modifiedControlPoint2Coordinates']['dx'],
        map['modifiedControlPoint2Coordinates']['dy'],
      ),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMoveBezierLineSegmentCommand.fromJson(String source) {
    return MPMoveBezierLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveBezierLineSegmentCommand copyWith({
    int? lineSegmentMapiahID,
    Offset? originalEndPointCoordinates,
    Offset? modifiedEndPointCoordinates,
    Offset? originalControlPoint1Coordinates,
    Offset? modifiedControlPoint1Coordinates,
    Offset? originalControlPoint2Coordinates,
    Offset? modifiedControlPoint2Coordinates,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveBezierLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: lineSegmentMapiahID ?? this.lineSegmentMapiahID,
      originalEndPointCoordinates:
          originalEndPointCoordinates ?? this.originalEndPointCoordinates,
      modifiedEndPointCoordinates:
          modifiedEndPointCoordinates ?? this.modifiedEndPointCoordinates,
      originalControlPoint1Coordinates: originalControlPoint1Coordinates ??
          this.originalControlPoint1Coordinates,
      modifiedControlPoint1Coordinates: modifiedControlPoint1Coordinates ??
          this.modifiedControlPoint1Coordinates,
      originalControlPoint2Coordinates: originalControlPoint2Coordinates ??
          this.originalControlPoint2Coordinates,
      modifiedControlPoint2Coordinates: modifiedControlPoint2Coordinates ??
          this.modifiedControlPoint2Coordinates,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveBezierLineSegmentCommand &&
        other.lineSegmentMapiahID == lineSegmentMapiahID &&
        other.originalEndPointCoordinates == originalEndPointCoordinates &&
        other.modifiedEndPointCoordinates == modifiedEndPointCoordinates &&
        other.originalControlPoint1Coordinates ==
            originalControlPoint1Coordinates &&
        other.modifiedControlPoint1Coordinates ==
            modifiedControlPoint1Coordinates &&
        other.originalControlPoint2Coordinates ==
            originalControlPoint2Coordinates &&
        other.modifiedControlPoint2Coordinates ==
            modifiedControlPoint2Coordinates &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineSegmentMapiahID,
        originalEndPointCoordinates,
        modifiedEndPointCoordinates,
        originalControlPoint1Coordinates,
        modifiedControlPoint1Coordinates,
        originalControlPoint2Coordinates,
        modifiedControlPoint2Coordinates,
      );
}
