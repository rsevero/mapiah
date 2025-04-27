part of 'mp_command.dart';

class MPMovePointCommand extends MPCommand {
  late final int pointMPID;
  late final THPositionPart originalPosition;
  late final THPositionPart modifiedPosition;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.movePoint;

  MPMovePointCommand.forCWJM({
    required this.pointMPID,
    required this.originalPosition,
    required this.modifiedPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMovePointCommand({
    required this.pointMPID,
    required this.originalPosition,
    required this.modifiedPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMovePointCommand.fromDeltaOnCanvas({
    required this.pointMPID,
    required this.originalPosition,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    modifiedPosition = originalPosition.copyWith(
      coordinates: originalPosition.coordinates + deltaOnCanvas,
      decimalPositions: decimalPositions,
    );
  }

  @override
  MPCommandType get type => MPCommandType.movePoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final THPoint originalPoint =
        th2FileEditController.thFile.pointByMPID(pointMPID);
    final THPoint modifiedPoint = originalPoint.copyWith(
      position: modifiedPosition,
      originalLineInTH2File: keepOriginalLineTH2File ? null : '',
    );

    th2FileEditController.elementEditController
        .substituteElement(modifiedPoint);
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MPMovePointCommand oppositeCommand = MPMovePointCommand(
      pointMPID: pointMPID,
      originalPosition: modifiedPosition,
      modifiedPosition: originalPosition,
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
      'originalPosition': originalPosition.toMap(),
      'modifiedPosition': modifiedPosition.toMap(),
    });

    return map;
  }

  factory MPMovePointCommand.fromMap(Map<String, dynamic> map) {
    return MPMovePointCommand.forCWJM(
      pointMPID: map['pointMPID'],
      originalPosition: THPositionPart.fromMap(map['originalPosition']),
      modifiedPosition: THPositionPart.fromMap(map['modifiedPosition']),
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
    THPositionPart? originalPosition,
    THPositionPart? modifiedPosition,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMovePointCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      originalPosition: originalPosition ?? this.originalPosition,
      modifiedPosition: modifiedPosition ?? this.modifiedPosition,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMovePointCommand &&
        other.pointMPID == pointMPID &&
        other.originalPosition == originalPosition &&
        other.modifiedPosition == modifiedPosition &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        pointMPID,
        originalPosition,
        modifiedPosition,
      );
}
