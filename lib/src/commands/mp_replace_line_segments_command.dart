part of 'mp_command.dart';

class MPReplaceLineSegmentsCommand extends MPCommand {
  final int lineMPID;
  final List<({int lineSegmentPosition, THLineSegment lineSegment})>
  originalLineSegments;
  final List<({int lineSegmentPosition, THLineSegment lineSegment})>
  newLineSegments;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.replaceLineSegments;

  MPReplaceLineSegmentsCommand.forCWJM({
    required this.lineMPID,
    required this.originalLineSegments,
    required this.newLineSegments,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPReplaceLineSegmentsCommand({
    required this.lineMPID,
    required this.originalLineSegments,
    required this.newLineSegments,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPReplaceLineSegmentsCommand.fromExisting({
    required this.lineMPID,
    required this.newLineSegments,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : originalLineSegments = thFile
           .lineByMPID(lineMPID)
           .getLineSegmentsPositionList(thFile),
       super();

  @override
  MPCommandType get type => MPCommandType.replaceLineSegments;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THLine line = thFile.lineByMPID(lineMPID);
    final List<({THLineSegment lineSegment, int lineSegmentPosition})>
    originalLineSegments = line.getLineSegmentsPositionList(thFile);
    final MPCommand replaceLineSegmentsCommand =
        MPReplaceLineSegmentsCommand.forCWJM(
          lineMPID: lineMPID,
          originalLineSegments: newLineSegments,
          newLineSegments: originalLineSegments,
        );

    _undoRedoInfo = {'replaceLineSegmentsCommand': replaceLineSegmentsCommand};
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyReplaceLineLineSegments(
      lineMPID,
      newLineSegments,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['replaceLineSegmentsCommand'] as MPCommand;

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
      'originalLineSegments': originalLineSegments
          .map(
            (e) => {
              'lineSegmentPosition': e.lineSegmentPosition,
              'lineSegment': e.lineSegment.toMap(),
            },
          )
          .toList(),
      'newLineSegments': newLineSegments
          .map(
            (e) => {
              'lineSegmentPosition': e.lineSegmentPosition,
              'lineSegment': e.lineSegment.toMap(),
            },
          )
          .toList(),
    });

    return map;
  }

  factory MPReplaceLineSegmentsCommand.fromMap(Map<String, dynamic> map) {
    final List<({int lineSegmentPosition, THLineSegment lineSegment})>
    originalLineSegments = (map['originalLineSegments'] as List)
        .map<({int lineSegmentPosition, THLineSegment lineSegment})>((raw) {
          final Map<dynamic, dynamic> r = raw as Map;
          final dynamic posRaw = r['lineSegmentPosition'];
          final int pos = posRaw is int ? posRaw : int.parse(posRaw.toString());
          return (
            lineSegmentPosition: pos,
            lineSegment: THLineSegment.fromMap(r['lineSegment']),
          );
        })
        .toList();

    final List<({int lineSegmentPosition, THLineSegment lineSegment})>
    newLineSegments = (map['newLineSegments'] as List)
        .map<({int lineSegmentPosition, THLineSegment lineSegment})>((raw) {
          final Map<dynamic, dynamic> r = raw as Map;
          final dynamic posRaw = r['lineSegmentPosition'];
          final int pos = posRaw is int ? posRaw : int.parse(posRaw.toString());
          return (
            lineSegmentPosition: pos,
            lineSegment: THLineSegment.fromMap(r['lineSegment']),
          );
        })
        .toList();

    return MPReplaceLineSegmentsCommand(
      lineMPID: map['lineMPID'] as int,
      originalLineSegments: originalLineSegments,
      newLineSegments: newLineSegments,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPReplaceLineSegmentsCommand.fromJson(String source) {
    return MPReplaceLineSegmentsCommand.fromMap(jsonDecode(source));
  }

  @override
  MPReplaceLineSegmentsCommand copyWith({
    int? lineMPID,
    List<({int lineSegmentPosition, THLineSegment lineSegment})>?
    originalLineSegments,
    List<({int lineSegmentPosition, THLineSegment lineSegment})>?
    newLineSegments,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPReplaceLineSegmentsCommand(
      lineMPID: lineMPID ?? this.lineMPID,
      originalLineSegments: originalLineSegments ?? this.originalLineSegments,
      newLineSegments: newLineSegments ?? this.newLineSegments,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPReplaceLineSegmentsCommand &&
        other.lineMPID == lineMPID &&
        const DeepCollectionEquality().equals(
          other.originalLineSegments,
          originalLineSegments,
        ) &&
        const DeepCollectionEquality().equals(
          other.newLineSegments,
          newLineSegments,
        );
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    lineMPID,
    const DeepCollectionEquality().hash(originalLineSegments),
    const DeepCollectionEquality().hash(newLineSegments),
  );
}
