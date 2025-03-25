part of 'mp_command.dart';

class MPMovePointCommand extends MPCommand {
  late final int pointMPID;
  late final Offset originalCoordinates;
  late final Offset modifiedCoordinates;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.movePoint;

  MPMovePointCommand.forCWJM({
    required this.pointMPID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMovePointCommand({
    required this.pointMPID,
    required this.originalCoordinates,
    required this.modifiedCoordinates,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMovePointCommand.fromDeltaOnCanvas({
    required this.pointMPID,
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
    final THPoint originalPoint =
        th2FileEditController.thFile.elementByMPID(pointMPID) as THPoint;
    final THPoint modifiedPoint = originalPoint.copyWith(
        position:
            originalPoint.position.copyWith(coordinates: modifiedCoordinates));

    th2FileEditController.elementEditController
        .applySubstituteElement(modifiedPoint);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MPMovePointCommand oppositeCommand = MPMovePointCommand(
      pointMPID: pointMPID,
      originalCoordinates: modifiedCoordinates,
      modifiedCoordinates: originalCoordinates,
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
      'pointMPID': pointMPID,
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
      pointMPID: map['pointMPID'],
      originalCoordinates: Offset(
        map['originalCoordinates']['dx'],
        map['originalCoordinates']['dy'],
      ),
      modifiedCoordinates: Offset(
        map['modifiedCoordinates']['dx'],
        map['modifiedCoordinates']['dy'],
      ),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMovePointCommand.fromJson(String source) {
    return MPMovePointCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMovePointCommand copyWith({
    int? pointMPID,
    Offset? originalCoordinates,
    Offset? modifiedCoordinates,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMovePointCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      originalCoordinates: originalCoordinates ?? this.originalCoordinates,
      modifiedCoordinates: modifiedCoordinates ?? this.modifiedCoordinates,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMovePointCommand &&
        other.pointMPID == pointMPID &&
        other.originalCoordinates == originalCoordinates &&
        other.modifiedCoordinates == modifiedCoordinates &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        pointMPID,
        originalCoordinates,
        modifiedCoordinates,
      );
}
