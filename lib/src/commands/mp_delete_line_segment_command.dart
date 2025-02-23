part of 'mp_command.dart';

class MPDeleteLineSegmentCommand extends MPCommand {
  final int lineSegmentMapiahID;

  MPDeleteLineSegmentCommand.forCWJM({
    required this.lineSegmentMapiahID,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.deleteLineSegment,
  }) : super.forCWJM();

  MPDeleteLineSegmentCommand({
    required this.lineSegmentMapiahID,
    super.descriptionType = MPCommandDescriptionType.deleteLineSegment,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.deleteElementByMapiahID(lineSegmentMapiahID);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
      TH2FileEditController th2FileEditController) {
    final MPAddLineSegmentCommand oppositeCommand = MPAddLineSegmentCommand(
      newLineSegment: th2FileEditController.thFile
          .elementByMapiahID(lineSegmentMapiahID) as THLineSegment,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    int? lineSegmentMapiahID,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPDeleteLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: lineSegmentMapiahID ?? this.lineSegmentMapiahID,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPDeleteLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPDeleteLineSegmentCommand.forCWJM(
      lineSegmentMapiahID: map['lineSegmentMapiahID'],
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
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
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ lineSegmentMapiahID.hashCode;

  @override
  MPCommandType get type => MPCommandType.addElements;
}
