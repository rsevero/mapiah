part of 'mp_command.dart';

class MPMoveStraightLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  final THPositionPart originalEndPointPosition;
  late final THPositionPart modifiedEndPointPosition;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveStraightLineSegment;

  MPMoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.modifiedEndPointPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.modifiedEndPointPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  })  : modifiedEndPointPosition = originalEndPointPosition.copyWith(
          coordinates: originalEndPointPosition.coordinates + deltaOnCanvas,
          decimalPositions: decimalPositions,
        ),
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
      endPoint: modifiedEndPointPosition,
    );

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
      originalEndPointPosition: modifiedEndPointPosition,
      modifiedEndPointPosition: originalEndPointPosition,
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
      'originalEndPointPosition': originalEndPointPosition.toMap(),
      'modifiedEndPointPosition': modifiedEndPointPosition.toMap(),
    });

    return map;
  }

  factory MPMoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      originalEndPointPosition:
          THPositionPart.fromMap(map['originalEndPointPosition']),
      modifiedEndPointPosition:
          THPositionPart.fromMap(map['modifiedEndPointPosition']),
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
    THPositionPart? originalEndPointPosition,
    THPositionPart? modifiedEndPointPosition,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      originalEndPointPosition:
          originalEndPointPosition ?? this.originalEndPointPosition,
      modifiedEndPointPosition:
          modifiedEndPointPosition ?? this.modifiedEndPointPosition,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveStraightLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.originalEndPointPosition == originalEndPointPosition &&
        other.modifiedEndPointPosition == modifiedEndPointPosition &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineSegmentMPID,
        originalEndPointPosition,
        modifiedEndPointPosition,
      );
}
