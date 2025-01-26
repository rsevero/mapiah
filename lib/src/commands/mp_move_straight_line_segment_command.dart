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
    required super.description,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required this.modifiedEndPointCoordinates,
    super.description = mpMoveStraightLineSegmentCommandDescription,
  }) : super();

  MPMoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegmentMapiahID,
    required this.originalEndPointCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMoveStraightLineSegmentCommandDescription,
  })  : modifiedEndPointCoordinates =
            originalEndPointCoordinates + deltaOnCanvas,
        super();

  @override
  MPCommandType get type => MPCommandType.moveStraightLineSegment;

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    final THStraightLineSegment originalLineSegment = th2FileEditStore.thFile
        .elementByMapiahID(lineSegmentMapiahID) as THStraightLineSegment;
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
        endPoint: originalLineSegment.endPoint
            .copyWith(coordinates: modifiedEndPointCoordinates));

    th2FileEditStore.substituteElementWithoutRedrawTrigger(newLineSegment);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand() {
    final MPMoveStraightLineSegmentCommand oppositeCommand =
        MPMoveStraightLineSegmentCommand(
      lineSegmentMapiahID: lineSegmentMapiahID,
      originalEndPointCoordinates: modifiedEndPointCoordinates,
      modifiedEndPointCoordinates: originalEndPointCoordinates,
      description: description,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        description: description,
        map: oppositeCommand.toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'lineSegmentMapiahID': lineSegmentMapiahID,
      'originalEndPointCoordinates': {
        'dx': originalEndPointCoordinates.dx,
        'dy': originalEndPointCoordinates.dy,
      },
      'modifiedEndPointCoordinates': {
        'dx': modifiedEndPointCoordinates.dx,
        'dy': modifiedEndPointCoordinates.dy,
      },
      'oppositeCommand': oppositeCommand?.toMap(),
      'description': description,
    };
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
      description: map['description'],
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
    String? description,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: lineSegmentMapiahID ?? this.lineSegmentMapiahID,
      originalEndPointCoordinates:
          originalEndPointCoordinates ?? this.originalEndPointCoordinates,
      modifiedEndPointCoordinates:
          modifiedEndPointCoordinates ?? this.modifiedEndPointCoordinates,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      description: description ?? this.description,
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
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        lineSegmentMapiahID,
        originalEndPointCoordinates,
        modifiedEndPointCoordinates,
        oppositeCommand,
        description,
      );
}
