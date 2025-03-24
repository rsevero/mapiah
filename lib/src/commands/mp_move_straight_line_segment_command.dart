part of 'mp_command.dart';

class MPMoveStraightLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  final Offset originalEndPointCoordinates;
  late final Offset modifiedEndPointCoordinates;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveStraightLineSegment;

  MPMoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegmentMPID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegmentMPID,
    required this.originalEndPointCoordinates,
    required Offset deltaOnCanvas,
    super.descriptionType = _defaultDescriptionType,
  })  : modifiedEndPointCoordinates =
            originalEndPointCoordinates + deltaOnCanvas,
        super();

  @override
  MPCommandType get type => MPCommandType.moveStraightLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THStraightLineSegment originalLineSegment =
        th2FileEditController.thFile.elementByMPID(lineSegmentMPID)
            as THStraightLineSegment;
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
        endPoint: originalLineSegment.endPoint
            .copyWith(coordinates: modifiedEndPointCoordinates));

    th2FileEditController.elementEditController
        .applySubstituteElementWithoutAddSelectableElement(newLineSegment);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPMoveStraightLineSegmentCommand oppositeCommand =
        MPMoveStraightLineSegmentCommand(
      lineSegmentMPID: lineSegmentMPID,
      originalEndPointCoordinates: modifiedEndPointCoordinates,
      modifiedEndPointCoordinates: originalEndPointCoordinates,
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
      'originalEndPointCoordinates': {
        'dx': originalEndPointCoordinates.dx,
        'dy': originalEndPointCoordinates.dy,
      },
      'modifiedEndPointCoordinates': {
        'dx': modifiedEndPointCoordinates.dx,
        'dy': modifiedEndPointCoordinates.dy,
      },
    });

    return map;
  }

  factory MPMoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      originalEndPointCoordinates: Offset(
        map['originalEndPointCoordinates']['dx'],
        map['originalEndPointCoordinates']['dy'],
      ),
      modifiedEndPointCoordinates: Offset(
        map['modifiedEndPointCoordinates']['dx'],
        map['modifiedEndPointCoordinates']['dy'],
      ),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMoveStraightLineSegmentCommand.fromJson(String source) {
    return MPMoveStraightLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveStraightLineSegmentCommand copyWith({
    int? lineSegmentMPID,
    Offset? originalEndPointCoordinates,
    Offset? modifiedEndPointCoordinates,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      originalEndPointCoordinates:
          originalEndPointCoordinates ?? this.originalEndPointCoordinates,
      modifiedEndPointCoordinates:
          modifiedEndPointCoordinates ?? this.modifiedEndPointCoordinates,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveStraightLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.originalEndPointCoordinates == originalEndPointCoordinates &&
        other.modifiedEndPointCoordinates == modifiedEndPointCoordinates &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineSegmentMPID,
        originalEndPointCoordinates,
        modifiedEndPointCoordinates,
      );
}
