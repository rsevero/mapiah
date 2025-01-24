part of 'mp_command.dart';

class MPMoveLineCommand extends MPCommand {
  final THLine originalLine;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap;
  late final THLine newLine;
  late final LinkedHashMap<int, THLineSegment> newLineSegmentsMap;
  final Offset deltaOnCanvas;
  final bool isFromDelta;

  MPMoveLineCommand.forCWJM({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.newLine,
    required this.newLineSegmentsMap,
    required super.oppositeCommand,
    super.description = mpMoveLineCommandDescription,
    this.deltaOnCanvas = Offset.zero,
    this.isFromDelta = false,
  }) : super.forCWJM();

  MPMoveLineCommand({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.newLine,
    required this.newLineSegmentsMap,
    super.description = mpMoveLineCommandDescription,
    this.deltaOnCanvas = Offset.zero,
    this.isFromDelta = false,
  }) : super();

  MPMoveLineCommand.fromDelta({
    required this.originalLine,
    required this.originalLineSegmentsMap,
    required this.deltaOnCanvas,
    super.description = mpMoveLineCommandDescription,
  })  : newLine = originalLine.copyWith(),
        isFromDelta = true,
        super() {
    newLineSegmentsMap = LinkedHashMap<int, THLineSegment>();
    for (var entry in originalLineSegmentsMap.entries) {
      final int originalLineSegmentMapiahID = entry.key;
      final THLineSegment originalLineSegment = entry.value;
      late THLineSegment newLineSegment;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          newLineSegment = originalLineSegment.copyWith(
              endPoint: originalLineSegment.endPoint.copyWith(
            coordinates:
                originalLineSegment.endPoint.coordinates + deltaOnCanvas,
          ));
          break;
        case THBezierCurveLineSegment _:
          newLineSegment = originalLineSegment.copyWith(
              endPoint: originalLineSegment.endPoint.copyWith(
                  coordinates:
                      originalLineSegment.endPoint.coordinates + deltaOnCanvas),
              controlPoint1: originalLineSegment.controlPoint1.copyWith(
                  coordinates: originalLineSegment.controlPoint1.coordinates +
                      deltaOnCanvas),
              controlPoint2: originalLineSegment.controlPoint2.copyWith(
                  coordinates: originalLineSegment.controlPoint2.coordinates +
                      deltaOnCanvas));
          break;
      }

      newLineSegmentsMap[originalLineSegmentMapiahID] = newLineSegment;
    }
  }

  @override
  MPCommandType get type => MPCommandType.moveLine;

  @override
  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'originalLine': originalLine.toMap(),
      'originalLineSegmentsMap': originalLineSegmentsMap
          .map((key, value) => MapEntry(key, value.toMap())),
      'newLine': newLine.toMap(),
      'newLineSegmentsMap':
          newLineSegmentsMap.map((key, value) => MapEntry(key, value.toMap())),
      'oppositeCommand': oppositeCommand?.toMap(),
      'deltaOnCanvas': {'dx': deltaOnCanvas.dx, 'dy': deltaOnCanvas.dy},
      'isFromDelta': isFromDelta,
      'description': description,
    };
  }

  factory MPMoveLineCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveLineCommand.forCWJM(
      originalLine: THLine.fromMap(map['originalLine']),
      originalLineSegmentsMap: LinkedHashMap<int, THLineSegment>.from(
        map['originalLineSegmentsMap']
            .map((key, value) => MapEntry(key, THLineSegment.fromMap(value))),
      ),
      newLine: THLine.fromMap(map['newLine']),
      newLineSegmentsMap: LinkedHashMap<int, THLineSegment>.from(
        map['newLineSegmentsMap']
            .map((key, value) => MapEntry(key, THLineSegment.fromMap(value))),
      ),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      deltaOnCanvas:
          Offset(map['deltaOnCanvas']['dx'], map['deltaOnCanvas']['dy']),
      isFromDelta: map['isFromDelta'],
      description: map['description'],
    );
  }

  factory MPMoveLineCommand.fromJson(String jsonString) {
    return MPMoveLineCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  MPMoveLineCommand copyWith({
    THLine? originalLine,
    LinkedHashMap<int, THLineSegment>? originalLineSegmentsMap,
    THLine? newLine,
    LinkedHashMap<int, THLineSegment>? newLineSegmentsMap,
    MPUndoRedoCommand? oppositeCommand,
    Offset? deltaOnCanvas,
    bool? isFromDelta,
    String? description,
  }) {
    return MPMoveLineCommand.forCWJM(
      originalLine: originalLine ?? this.originalLine,
      originalLineSegmentsMap:
          originalLineSegmentsMap ?? this.originalLineSegmentsMap,
      newLine: newLine ?? this.newLine,
      newLineSegmentsMap: newLineSegmentsMap ?? this.newLineSegmentsMap,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      deltaOnCanvas: deltaOnCanvas ?? this.deltaOnCanvas,
      isFromDelta: isFromDelta ?? this.isFromDelta,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(covariant MPMoveLineCommand other) {
    if (identical(this, other)) return true;

    return other.originalLine == originalLine &&
        other.originalLineSegmentsMap == originalLineSegmentsMap &&
        other.newLine == newLine &&
        other.newLineSegmentsMap == newLineSegmentsMap &&
        other.oppositeCommand == oppositeCommand &&
        other.deltaOnCanvas == deltaOnCanvas &&
        other.isFromDelta == isFromDelta &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        originalLine,
        originalLineSegmentsMap,
        newLine,
        newLineSegmentsMap,
        oppositeCommand,
        deltaOnCanvas,
        isFromDelta,
        description,
      );

  @override
  void actualExecute(THFileStore thFileStore) {
    for (final entry in originalLineSegmentsMap.entries) {
      final int originalLineSegmentMapiahID = entry.key;
      final THLineSegment originalLineSegment = entry.value;
      late MPCommand command;

      switch (originalLineSegment) {
        case THStraightLineSegment _:
          if (isFromDelta) {
            command = MPMoveStraightLineSegmentCommand.fromDelta(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              deltaOnCanvas: deltaOnCanvas,
              description: description,
            );
          } else {
            command = MPMoveStraightLineSegmentCommand(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              endPointNewCoordinates:
                  newLineSegmentsMap[originalLineSegmentMapiahID]!
                      .endPoint
                      .coordinates,
              description: description,
            );
          }
          break;
        case THBezierCurveLineSegment _:
          THBezierCurveLineSegment newLineSegment =
              newLineSegmentsMap[originalLineSegmentMapiahID]
                  as THBezierCurveLineSegment;

          if (isFromDelta) {
            command = MPMoveBezierLineSegmentCommand.fromDelta(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              controlPoint1OriginalCoordinates:
                  originalLineSegment.controlPoint1.coordinates,
              controlPoint2OriginalCoordinates:
                  originalLineSegment.controlPoint2.coordinates,
              deltaOnCanvas: deltaOnCanvas,
              description: description,
            );
          } else {
            command = MPMoveBezierLineSegmentCommand(
              lineSegment: originalLineSegment,
              endPointOriginalCoordinates:
                  originalLineSegment.endPoint.coordinates,
              endPointNewCoordinates: newLineSegment.endPoint.coordinates,
              controlPoint1OriginalCoordinates:
                  originalLineSegment.controlPoint1.coordinates,
              controlPoint1NewCoordinates:
                  newLineSegment.controlPoint1.coordinates,
              controlPoint2OriginalCoordinates:
                  originalLineSegment.controlPoint2.coordinates,
              controlPoint2NewCoordinates:
                  newLineSegment.controlPoint2.coordinates,
              description: description,
            );
          }
          break;
      }

      command.execute(thFileStore);
    }
  }

  @override
  MPUndoRedoCommand createOppositeCommand() {
    final MPMoveLineCommand oppositeCommand = MPMoveLineCommand(
      originalLine: newLine,
      originalLineSegmentsMap: newLineSegmentsMap,
      newLine: originalLine,
      newLineSegmentsMap: originalLineSegmentsMap,
      description: description,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        description: description,
        map: oppositeCommand.toMap());
  }
}
