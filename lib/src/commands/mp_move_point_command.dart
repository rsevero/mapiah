part of 'mp_command.dart';

class MPMovePointCommand extends MPCommand {
  late final int pointMPID;
  late final THPositionPart fromPosition;
  late final THPositionPart toPosition;
  final String fromOriginalLineInTH2File;
  final String toOriginalLineInTH2File;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.movePoint;

  MPMovePointCommand.forCWJM({
    required this.pointMPID,
    required this.fromPosition,
    required this.toPosition,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPMovePointCommand({
    required this.pointMPID,
    required this.fromPosition,
    required this.toPosition,
    required this.fromOriginalLineInTH2File,
    required this.toOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  MPMovePointCommand.fromDeltaOnCanvas({
    required this.pointMPID,
    required this.fromPosition,
    required Offset deltaOnCanvas,
    int? decimalPositions,
    required this.fromOriginalLineInTH2File,
    super.descriptionType = defaultDescriptionType,
  }) : toOriginalLineInTH2File = '',
       super() {
    toPosition = THPositionPart(
      coordinates: fromPosition.coordinates + deltaOnCanvas,
      decimalPositions: decimalPositions,
    );
  }

  @override
  MPCommandType get type => MPCommandType.movePoint;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;
    final THPoint originalPoint = th2FileEditController.thFile.pointByMPID(
      pointMPID,
    );
    final THPoint modifiedPoint = originalPoint.copyWith(
      position: toPosition,
      originalLineInTH2File: toOriginalLineInTH2File,
    );

    elementEditController.substituteElement(modifiedPoint);
    elementEditController.addOutdatedCloneMPID(pointMPID);
    elementEditController.updateControllersAfterElementEditPartial();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    /// The original description is kept for the undo/redo command so the
    /// message on undo and redo are the same.
    final MPCommand oppositeCommand = MPMovePointCommand.forCWJM(
      pointMPID: pointMPID,
      fromPosition: toPosition,
      toPosition: fromPosition,
      fromOriginalLineInTH2File: toOriginalLineInTH2File,
      toOriginalLineInTH2File: fromOriginalLineInTH2File,
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
      'fromPosition': fromPosition.toMap(),
      'toPosition': toPosition.toMap(),
      'fromOriginalLineInTH2File': fromOriginalLineInTH2File,
      'toOriginalLineInTH2File': toOriginalLineInTH2File,
    });

    return map;
  }

  factory MPMovePointCommand.fromMap(Map<String, dynamic> map) {
    return MPMovePointCommand.forCWJM(
      pointMPID: map['pointMPID'],
      fromPosition: THPositionPart.fromMap(map['fromPosition']),
      toPosition: THPositionPart.fromMap(map['toPosition']),
      fromOriginalLineInTH2File: map['fromOriginalLineInTH2File'],
      toOriginalLineInTH2File: map['toOriginalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPMovePointCommand.fromJson(String source) {
    return MPMovePointCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMovePointCommand copyWith({
    int? pointMPID,
    THPositionPart? fromPosition,
    THPositionPart? toPosition,
    String? fromOriginalLineInTH2File,
    String? toOriginalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMovePointCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      fromPosition: fromPosition ?? this.fromPosition,
      toPosition: toPosition ?? this.toPosition,
      fromOriginalLineInTH2File:
          fromOriginalLineInTH2File ?? this.fromOriginalLineInTH2File,
      toOriginalLineInTH2File:
          toOriginalLineInTH2File ?? this.toOriginalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPMovePointCommand &&
        other.pointMPID == pointMPID &&
        other.fromPosition == fromPosition &&
        other.toPosition == toPosition &&
        other.fromOriginalLineInTH2File == fromOriginalLineInTH2File &&
        other.toOriginalLineInTH2File == toOriginalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    pointMPID,
    fromPosition,
    toPosition,
    fromOriginalLineInTH2File,
    toOriginalLineInTH2File,
  );
}
