part of 'mp_command.dart';

class MPMoveStraightLineSegmentCommand extends MPCommand {
  late final THStraightLineSegment lineSegment;
  late final Offset endPointOriginalCoordinates;
  late final Offset endPointNewCoordinates;

  MPMoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    required super.oppositeCommand,
    required super.description,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required this.endPointNewCoordinates,
    super.description = mpMoveStraightLineSegmentCommandDescription,
  }) : super();

  MPMoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegment,
    required this.endPointOriginalCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMoveStraightLineSegmentCommandDescription,
  })  : endPointNewCoordinates = endPointOriginalCoordinates + deltaOnCanvas,
        super();

  @override
  MPCommandType get type => MPCommandType.moveStraightLineSegment;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'lineSegment': lineSegment.toMap(),
      'endPointOriginalCoordinates': {
        'dx': endPointOriginalCoordinates.dx,
        'dy': endPointOriginalCoordinates.dy
      },
      'endPointNewCoordinates': {
        'dx': endPointNewCoordinates.dx,
        'dy': endPointNewCoordinates.dy
      },
      'oppositeCommand': oppositeCommand?.toMap(),
      'description': description,
    };
  }

  factory MPMoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegment: THStraightLineSegment.fromMap(map['lineSegment']),
      endPointOriginalCoordinates: Offset(
          map['endPointOriginalCoordinates']['dx'],
          map['endPointOriginalCoordinates']['dy']),
      endPointNewCoordinates: Offset(map['endPointNewCoordinates']['dx'],
          map['endPointNewCoordinates']['dy']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      description: map['description'],
    );
  }

  factory MPMoveStraightLineSegmentCommand.fromJson(String jsonString) {
    return MPMoveStraightLineSegmentCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MPMoveStraightLineSegmentCommand copyWith({
    THStraightLineSegment? lineSegment,
    Offset? endPointOriginalCoordinates,
    Offset? endPointNewCoordinates,
    MPUndoRedoCommand? oppositeCommand,
    String? description,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegment: lineSegment ?? this.lineSegment,
      endPointOriginalCoordinates:
          endPointOriginalCoordinates ?? this.endPointOriginalCoordinates,
      endPointNewCoordinates:
          endPointNewCoordinates ?? this.endPointNewCoordinates,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MPMoveStraightLineSegmentCommand other) {
    if (identical(this, other)) return true;

    return other.lineSegment == lineSegment &&
        other.endPointOriginalCoordinates == endPointOriginalCoordinates &&
        other.endPointNewCoordinates == endPointNewCoordinates &&
        other.oppositeCommand == oppositeCommand &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        lineSegment,
        endPointOriginalCoordinates,
        endPointNewCoordinates,
        oppositeCommand,
        description,
      );

  @override
  void actualExecute(THFileStore thFileStore) {
    final THStraightLineSegment originalLineSegment = lineSegment;
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
        endPoint: originalLineSegment.endPoint
            .copyWith(coordinates: endPointNewCoordinates));

    thFileStore.substituteElement(newLineSegment);
  }

  @override
  MPUndoRedoCommand createOppositeCommand() {
    final MPMoveStraightLineSegmentCommand oppositeCommand =
        MPMoveStraightLineSegmentCommand(
      lineSegment: lineSegment,
      endPointOriginalCoordinates: endPointNewCoordinates,
      endPointNewCoordinates: endPointOriginalCoordinates,
      description: description,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        description: description,
        map: oppositeCommand.toMap());
  }
}
