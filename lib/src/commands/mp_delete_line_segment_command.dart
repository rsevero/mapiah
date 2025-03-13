part of 'mp_command.dart';

class MPDeleteLineSegmentCommand extends MPCommand {
  final int lineSegmentMapiahID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deleteLineSegment;

  MPDeleteLineSegmentCommand.forCWJM({
    required this.lineSegmentMapiahID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeleteLineSegmentCommand({
    required this.lineSegmentMapiahID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.deleteLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController
        .deleteElementByMapiahID(lineSegmentMapiahID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THLineSegment newLineSegment = th2FileEditController.thFile
        .elementByMapiahID(lineSegmentMapiahID) as THLineSegment;
    final MPAddLineSegmentCommand oppositeCommand = MPAddLineSegmentCommand(
      newLineSegment: newLineSegment,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      mapUndo: oppositeCommand.toMap(),
      mapRedo: toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineSegmentMapiahID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPDeleteLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: lineSegmentMapiahID ?? this.lineSegmentMapiahID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: map['lineSegmentMapiahID'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPDeleteLineSegmentCommand.fromJson(String source) {
    return MPDeleteLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineSegmentMapiahID': lineSegmentMapiahID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeleteLineSegmentCommand &&
        other.lineSegmentMapiahID == lineSegmentMapiahID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ lineSegmentMapiahID.hashCode;
}
