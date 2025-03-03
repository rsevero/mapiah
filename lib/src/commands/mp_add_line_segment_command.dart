part of 'mp_command.dart';

class MPAddLineSegmentCommand extends MPCommand {
  final THLineSegment newLineSegment;

  MPAddLineSegmentCommand.forCWJM({
    required this.newLineSegment,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.addLineSegment,
  }) : super.forCWJM();

  MPAddLineSegmentCommand({
    required this.newLineSegment,
    super.descriptionType = MPCommandDescriptionType.addLineSegment,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.addElement(newElement: newLineSegment);
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPDeleteLineSegmentCommand oppositeCommand =
        MPDeleteLineSegmentCommand(
      lineSegmentMapiahID: newLineSegment.mapiahID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      commandType: oppositeCommand.type,
      descriptionType: descriptionType,
      map: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THLineSegment? newLineSegment,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: newLineSegment ?? this.newLineSegment,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPAddLineSegmentCommand.fromJson(String source) {
    return MPAddLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newLineSegment': newLineSegment.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddLineSegmentCommand &&
        other.newLineSegment == newLineSegment &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ newLineSegment.hashCode;

  @override
  MPCommandType get type => MPCommandType.addLineSegment;
}
