part of 'mp_command.dart';

class MPMoveStraightLineSegmentCommand extends MPCommand {
  final int lineSegmentMapiahID;
  final Offset originalEndPointCoordinates;
  late final Offset modifiedEndPointCoordinates;

  MPMoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.moveStraightLineSegment,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    super.descriptionType = MPCommandDescriptionType.moveStraightLineSegment,
  }) : super();

  MPMoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required Offset deltaOnCanvas,
    super.descriptionType = MPCommandDescriptionType.moveStraightLineSegment,
  })  : modifiedEndPointCoordinates =
            originalEndPointCoordinates + deltaOnCanvas,
        super();

  @override
  MPCommandType get type => MPCommandType.moveStraightLineSegment;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THStraightLineSegment originalLineSegment =
        th2FileEditController.thFile.elementByMapiahID(lineSegmentMapiahID)
            as THStraightLineSegment;
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
        endPoint: originalLineSegment.endPoint
            .copyWith(coordinates: modifiedEndPointCoordinates));

    th2FileEditController
        .substituteElementWithoutAddSelectableElement(newLineSegment);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPMoveStraightLineSegmentCommand oppositeCommand =
        MPMoveStraightLineSegmentCommand(
      lineSegmentMapiahID: lineSegmentMapiahID,
      originalEndPointCoordinates: modifiedEndPointCoordinates,
      modifiedEndPointCoordinates: originalEndPointCoordinates,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      descriptionType: descriptionType,
      map: oppositeCommand.toMap(),
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
    });

    return map;
  }

  factory MPMoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: map['lineSegmentMapiahID'],
      originalEndPointCoordinates: Offset(
        map['originalEndPointCoordinates']['dx'],
        map['originalEndPointCoordinates']['dy'],
      ),
      modifiedEndPointCoordinates: Offset(
        map['modifiedEndPointCoordinates']['dx'],
        map['modifiedEndPointCoordinates']['dy'],
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMoveStraightLineSegmentCommand.fromJson(String source) {
    return MPMoveStraightLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveStraightLineSegmentCommand copyWith({
    int? lineSegmentMapiahID,
    Offset? originalEndPointCoordinates,
    Offset? modifiedEndPointCoordinates,
    MPUndoRedoCommand? oppositeCommand,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: lineSegmentMapiahID ?? this.lineSegmentMapiahID,
      originalEndPointCoordinates:
          originalEndPointCoordinates ?? this.originalEndPointCoordinates,
      modifiedEndPointCoordinates:
          modifiedEndPointCoordinates ?? this.modifiedEndPointCoordinates,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveStraightLineSegmentCommand &&
        other.lineSegmentMapiahID == lineSegmentMapiahID &&
        other.originalEndPointCoordinates == originalEndPointCoordinates &&
        other.modifiedEndPointCoordinates == modifiedEndPointCoordinates &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineSegmentMapiahID,
        originalEndPointCoordinates,
        modifiedEndPointCoordinates,
      );
}
