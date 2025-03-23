part of 'mp_command.dart';

class MPMoveLineCommand extends MPCommand {
  final int lineMPID;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap;
  late final LinkedHashMap<int, THLineSegment> modifiedLineSegmentsMap;
  final Offset deltaOnCanvas;
  final bool isFromDelta;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveLine;

  MPMoveLineCommand.forCWJM({
    required this.lineMPID,
    required this.originalLineSegmentsMap,
    required this.modifiedLineSegmentsMap,
    this.deltaOnCanvas = Offset.zero,
    this.isFromDelta = false,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveLineCommand({
    required this.lineMPID,
    required this.originalLineSegmentsMap,
    required this.modifiedLineSegmentsMap,
    this.deltaOnCanvas = Offset.zero,
    this.isFromDelta = false,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPMoveLineCommand.fromDelta({
    required this.lineMPID,
    required this.originalLineSegmentsMap,
    required this.deltaOnCanvas,
    super.descriptionType = _defaultDescriptionType,
  })  : isFromDelta = true,
        super() {
    modifiedLineSegmentsMap = LinkedHashMap<int, THLineSegment>();
    for (var entry in originalLineSegmentsMap.entries) {
      final int originalLineSegmentMPID = entry.key;
      final THLineSegment originalLineSegment = entry.value;
      late THLineSegment modifiedLineSegment;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          modifiedLineSegment = originalLineSegment.copyWith(
            endPoint: originalLineSegment.endPoint.copyWith(
              coordinates:
                  originalLineSegment.endPoint.coordinates + deltaOnCanvas,
            ),
          );
          break;
        case THBezierCurveLineSegment _:
          modifiedLineSegment = originalLineSegment.copyWith(
            endPoint: originalLineSegment.endPoint.copyWith(
                coordinates:
                    originalLineSegment.endPoint.coordinates + deltaOnCanvas),
            controlPoint1: originalLineSegment.controlPoint1.copyWith(
                coordinates: originalLineSegment.controlPoint1.coordinates +
                    deltaOnCanvas),
            controlPoint2: originalLineSegment.controlPoint2.copyWith(
                coordinates: originalLineSegment.controlPoint2.coordinates +
                    deltaOnCanvas),
          );
          break;
      }

      modifiedLineSegmentsMap[originalLineSegmentMPID] = modifiedLineSegment;
    }
  }

  @override
  MPCommandType get type => MPCommandType.moveLine;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    for (final entry in originalLineSegmentsMap.entries) {
      final int originalLineSegmentMPID = entry.key;
      final THLineSegment originalLineSegment = entry.value;
      late MPCommand command;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          if (isFromDelta) {
            command = MPMoveStraightLineSegmentCommand.fromDelta(
              lineSegmentMPID: originalLineSegmentMPID,
              originalEndPointCoordinates:
                  originalLineSegment.endPoint.coordinates,
              deltaOnCanvas: deltaOnCanvas,
              descriptionType: descriptionType,
            );
          } else {
            command = MPMoveStraightLineSegmentCommand(
              lineSegmentMPID: originalLineSegmentMPID,
              originalEndPointCoordinates:
                  originalLineSegment.endPoint.coordinates,
              modifiedEndPointCoordinates:
                  modifiedLineSegmentsMap[originalLineSegmentMPID]!
                      .endPoint
                      .coordinates,
              descriptionType: descriptionType,
            );
          }
          break;
        case THBezierCurveLineSegment _:
          THBezierCurveLineSegment newLineSegment =
              modifiedLineSegmentsMap[originalLineSegmentMPID]
                  as THBezierCurveLineSegment;

          if (isFromDelta) {
            command = MPMoveBezierLineSegmentCommand.fromDelta(
              lineSegmentMPID: originalLineSegmentMPID,
              originalEndPointCoordinates:
                  originalLineSegment.endPoint.coordinates,
              originalControlPoint1Coordinates:
                  originalLineSegment.controlPoint1.coordinates,
              originalControlPoint2Coordinates:
                  originalLineSegment.controlPoint2.coordinates,
              deltaOnCanvas: deltaOnCanvas,
              descriptionType: descriptionType,
            );
          } else {
            command = MPMoveBezierLineSegmentCommand(
              lineSegmentMPID: originalLineSegmentMPID,
              originalEndPointCoordinates:
                  originalLineSegment.endPoint.coordinates,
              modifiedEndPointCoordinates: newLineSegment.endPoint.coordinates,
              originalControlPoint1Coordinates:
                  originalLineSegment.controlPoint1.coordinates,
              modifiedControlPoint1Coordinates:
                  newLineSegment.controlPoint1.coordinates,
              originalControlPoint2Coordinates:
                  originalLineSegment.controlPoint2.coordinates,
              modifiedControlPoint2Coordinates:
                  newLineSegment.controlPoint2.coordinates,
              descriptionType: descriptionType,
            );
          }
          break;
      }
      command._actualExecute(th2FileEditController);
    }
    th2FileEditController.elementEditController.substituteElement(
        th2FileEditController.thFile.elementByMPID(lineMPID).copyWith());
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPMoveLineCommand oppositeCommand = MPMoveLineCommand(
      lineMPID: lineMPID,
      originalLineSegmentsMap: modifiedLineSegmentsMap,
      modifiedLineSegmentsMap: originalLineSegmentsMap,
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
      'lineMPID': lineMPID,
      'originalLineSegmentsMap': originalLineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
      'modifiedLineSegmentsMap': modifiedLineSegmentsMap.map(
        (key, value) => MapEntry(key.toString(), value.toMap()),
      ),
    });

    return map;
  }

  factory MPMoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveLineCommand.forCWJM(
      lineMPID: map['lineMPID'],
      originalLineSegmentsMap: LinkedHashMap<int, THLineSegment>.fromEntries(
        (map['originalLineSegmentsMap'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(
                int.parse(e.key),
                THLineSegment.fromMap(e.value),
              ),
            ),
      ),
      modifiedLineSegmentsMap: LinkedHashMap<int, THLineSegment>.fromEntries(
        (map['modifiedLineSegmentsMap'] as Map<String, dynamic>).entries.map(
              (e) => MapEntry(
                int.parse(e.key),
                THLineSegment.fromMap(e.value),
              ),
            ),
      ),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPMoveLineCommand.fromJson(String source) {
    return MPMoveLineCommand.fromMap(jsonDecode(source));
  }

  @override
  MPMoveLineCommand copyWith({
    int? lineMPID,
    LinkedHashMap<int, THLineSegment>? originalLineSegmentsMap,
    LinkedHashMap<int, THLineSegment>? modifiedLineSegmentsMap,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveLineCommand.forCWJM(
      lineMPID: lineMPID ?? this.lineMPID,
      originalLineSegmentsMap:
          originalLineSegmentsMap ?? this.originalLineSegmentsMap,
      modifiedLineSegmentsMap:
          modifiedLineSegmentsMap ?? this.modifiedLineSegmentsMap,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPMoveLineCommand &&
        other.lineMPID == lineMPID &&
        const DeepCollectionEquality()
            .equals(other.originalLineSegmentsMap, originalLineSegmentsMap) &&
        const DeepCollectionEquality()
            .equals(other.modifiedLineSegmentsMap, modifiedLineSegmentsMap) &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineMPID,
        Object.hashAll(originalLineSegmentsMap.entries),
        Object.hashAll(modifiedLineSegmentsMap.entries),
      );
}
