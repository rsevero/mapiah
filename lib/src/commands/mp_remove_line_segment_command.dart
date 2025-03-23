part of 'mp_command.dart';

class MPRemoveLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeLineSegment;

  MPRemoveLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveLineSegmentCommand({
    required this.lineSegmentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController
        .removeElementByMPID(lineSegmentMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THLineSegment newLineSegment = th2FileEditController.thFile
        .elementByMPID(lineSegmentMPID) as THLineSegment;
    final MPAddLineSegmentCommand oppositeCommand = MPAddLineSegmentCommand(
      newLineSegment: newLineSegment,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineSegmentMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPRemoveLineSegmentCommand.fromJson(String source) {
    return MPRemoveLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'lineSegmentMPID': lineSegmentMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPRemoveLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ lineSegmentMPID.hashCode;
}
