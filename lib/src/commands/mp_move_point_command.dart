part of 'mp_command.dart';

class MPMovePointCommand extends MPCommand {
  late final int pointMapiahID;
  late final Offset originalCoordinates;
  late final Offset modifiedCoordinates;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.movePoint;

  MPMovePointCommand.forCWJM({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    required super.oppositeCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMovePointCommand({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMovePointCommand.fromDelta({
    required this.pointMapiahID,
    required this.originalCoordinates,
    required Offset deltaOnCanvas,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    modifiedCoordinates = originalCoordinates + deltaOnCanvas;
  }

  @override
  MPCommandType get type => MPCommandType.movePoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final THPoint originalPoint = th2FileEditController.thFile
        .elementByMapiahID(pointMapiahID) as THPoint;
    final THPoint modifiedPoint = originalPoint.copyWith(
        position:
            originalPoint.position.copyWith(coordinates: modifiedCoordinates));

    th2FileEditController.elementEditController
        .substituteElement(modifiedPoint);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MPMovePointCommand oppositeCommand = MPMovePointCommand(
      pointMapiahID: pointMapiahID,
      originalCoordinates: modifiedCoordinates,
      modifiedCoordinates: originalCoordinates,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'pointMapiahID': pointMapiahID,
      'originalCoordinates': {
        'dx': originalCoordinates.dx,
        'dy': originalCoordinates.dy,
      },
      'modifiedCoordinates': {
        'dx': modifiedCoordinates.dx,
        'dy': modifiedCoordinates.dy,
      },
    });

    return map;
  }

  factory MPMovePointCommand.fromMap(Map<String, dynamic> map) {
    return MPMovePointCommand.forCWJM(
      pointMapiahID: map['pointMapiahID'],
      originalCoordinates: Offset(
        map['originalCoordinates']['dx'],
        map['originalCoordinates']['dy'],
      ),
      modifiedCoordinates: Offset(
        map['modifiedCoordinates']['dx'],
        map['modifiedCoordinates']['dy'],
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMovePointCommand.fromJson(String source) {
    return MPMovePointCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMovePointCommand copyWith({
    int? pointMapiahID,
    Offset? originalCoordinates,
    Offset? modifiedCoordinates,
    MPUndoRedoCommand? oppositeCommand,
    bool makeOppositeCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMovePointCommand.forCWJM(
      pointMapiahID: pointMapiahID ?? this.pointMapiahID,
      originalCoordinates: originalCoordinates ?? this.originalCoordinates,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
      oppositeCommand: makeOppositeCommandNull
          ? null
          : (oppositeCommand ?? this.oppositeCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMovePointCommand &&
        other.pointMapiahID == pointMapiahID &&
        other.originalCoordinates == originalCoordinates &&
        other.modifiedCoordinates == modifiedCoordinates &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        pointMapiahID,
        originalCoordinates,
        modifiedCoordinates,
      );
}
