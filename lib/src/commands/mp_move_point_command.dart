part of 'mp_command.dart';

class MPMovePointCommand extends MPCommand {
  late final int pointMapiahID;
  late final Offset originalCoordinates;
  late final Offset modifiedCoordinates;

  MPMovePointCommand.forCWJM({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    required super.oppositeCommand,
    super.description = mpMovePointCommandDescription,
  }) : super.forCWJM();

  MPMovePointCommand({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    super.description = mpMovePointCommandDescription,
  }) : super();

  MPMovePointCommand.fromDelta({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required Offset deltaOnCanvas,
    super.description = mpMovePointCommandDescription,
  }) : super() {
    modifiedCoordinates = originalCoordinates + deltaOnCanvas;
  }

  @override
  MPCommandType get type => MPCommandType.movePoint;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'pointMapiahID': pointMapiahID,
      'originalCoordinates': {
        'dx': originalCoordinates.dx,
        'dy': originalCoordinates.dy
      },
      'modifiedCoordinates': {
        'dx': modifiedCoordinates.dx,
        'dy': modifiedCoordinates.dy
      },
      'oppositeCommand': oppositeCommand?.toMap(),
      'description': description,
    };
  }

  factory MPMovePointCommand.fromMap(Map<String, dynamic> map) {
    return MPMovePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
      originalCoordinates: Offset(
          map['originalCoordinates']['dx'], map['originalCoordinates']['dy']),
      modifiedCoordinates: Offset(
          map['modifiedCoordinates']['dx'], map['modifiedCoordinates']['dy']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      description: map['description'],
    );
  }

  factory MPMovePointCommand.fromJson(String jsonString) {
    return MPMovePointCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MPMovePointCommand copyWith({
    int? pointMapiahID,
    Offset? originalCoordinates,
    Offset? modifiedCoordinates,
    MPUndoRedoCommand? oppositeCommand,
    String? description,
  }) {
    return MPMovePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      originalCoordinates: originalCoordinates ?? this.originalCoordinates,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MPMovePointCommand other) {
    if (identical(this, other)) return true;

    return other.pointMapiahID == pointMapiahID &&
        other.originalCoordinates == originalCoordinates &&
        other.modifiedCoordinates == modifiedCoordinates &&
        other.oppositeCommand == oppositeCommand &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        pointMapiahID,
        originalCoordinates,
        modifiedCoordinates,
        oppositeCommand,
        description,
      );

  @override
  MPUndoRedoCommand _createOppositeCommand() {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MPMovePointCommand oppositeCommand = MPMovePointCommand(
      pointMapiahID: pointMapiahID,
      originalCoordinates: modifiedCoordinates,
      modifiedCoordinates: originalCoordinates,
      description: description,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        description: description,
        map: oppositeCommand.toMap());
  }

  @override
  void _actualExecute(TH2FileEditStore th2FileEditStore) {
    final THPoint originalPoint =
        th2FileEditStore.thFile.elementByMapiahID(pointMapiahID) as THPoint;
    final THPoint modifiedPoint = originalPoint.copyWith(
        position:
            originalPoint.position.copyWith(coordinates: modifiedCoordinates));

    th2FileEditStore.substituteElement(modifiedPoint);
  }
}
