part of 'mp_command.dart';

class MPMoveStraightLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  final THPositionPart originalEndPointPosition;
  late final THPositionPart modifiedEndPointPosition;
  final String originalLineInTH2File;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.moveStraightLineSegment;

  MPMoveStraightLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.modifiedEndPointPosition,
    required this.originalLineInTH2File,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPMoveStraightLineSegmentCommand({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required this.modifiedEndPointPosition,
    super.descriptionType = _defaultDescriptionType,
  }) : originalLineInTH2File = '',
       super();

  MPMoveStraightLineSegmentCommand.fromDelta({
    required this.lineSegmentMPID,
    required this.originalEndPointPosition,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    super.descriptionType = _defaultDescriptionType,
  }) : modifiedEndPointPosition = originalEndPointPosition.copyWith(
         coordinates: originalEndPointPosition.coordinates + deltaOnCanvas,
         decimalPositions: decimalPositions,
       ),
       originalLineInTH2File = '',
       super();

  @override
  MPCommandType get type => MPCommandType.moveStraightLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final THStraightLineSegment originalLineSegment = th2FileEditController
        .thFile
        .straightLineSegmentByMPID(lineSegmentMPID);
    final THStraightLineSegment newLineSegment = originalLineSegment.copyWith(
      endPoint: modifiedEndPointPosition,
      originalLineInTH2File: keepOriginalLineTH2File ? null : '',
    );

    th2FileEditController.elementEditController
        .substituteElementWithoutAddSelectableElement(newLineSegment);
    th2FileEditController.triggerNewLineRedraw();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID,
      originalEndPointPosition: modifiedEndPointPosition,
      modifiedEndPointPosition: originalEndPointPosition,
      originalLineInTH2File: th2FileEditController.thFile
          .elementByMPID(lineSegmentMPID)
          .originalLineInTH2File,
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
      'originalLineInTH2File': originalLineInTH2File,
    });

    return map;
  }

  factory MPMoveStraightLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      originalEndPointPosition: THPositionPart.fromMap(
        map['originalEndPointPosition'],
      ),
      modifiedEndPointPosition: THPositionPart.fromMap(
        map['modifiedEndPointPosition'],
      ),
      originalLineInTH2File: map['originalLineInTH2File'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
    String? originalLineInTH2File,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPMoveStraightLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      originalEndPointPosition:
          originalEndPointPosition ?? this.originalEndPointPosition,
      modifiedEndPointPosition:
          modifiedEndPointPosition ?? this.modifiedEndPointPosition,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPMoveStraightLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.originalEndPointPosition == originalEndPointPosition &&
        other.modifiedEndPointPosition == modifiedEndPointPosition &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        lineSegmentMPID,
        originalEndPointPosition,
        modifiedEndPointPosition,
        originalLineInTH2File,
      );
}
