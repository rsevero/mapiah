part of 'mp_command.dart';

class MPDeleteLineSegmentCommand extends MPCommand {
  final int lineSegmentMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.deleteLineSegment;

  MPDeleteLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPDeleteLineSegmentCommand({
    required this.lineSegmentMPID,
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
        .deleteElementByMPID(lineSegmentMPID);
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
      commandType: oppositeCommand.type,
      mapUndo: oppositeCommand.toMap(),
      mapRedo: toMap(),
    );
  }

  @override
  MPCommand copyWith({
    int? lineSegmentMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPDeleteLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
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
      'lineSegmentMPID': lineSegmentMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPDeleteLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ lineSegmentMPID.hashCode;
}
