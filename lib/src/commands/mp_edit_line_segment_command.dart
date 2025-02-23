part of 'mp_command.dart';

class MPEditLineSegmentCommand extends MPCommand {
  final THLineSegment newLineSegment;

  MPEditLineSegmentCommand.forCWJM({
    required this.newLineSegment,
    required super.oppositeCommand,
    super.descriptionType = MPCommandDescriptionType.editLineSegment,
  }) : super.forCWJM();

  MPEditLineSegmentCommand({
    required this.newLineSegment,
    super.descriptionType = MPCommandDescriptionType.editLineSegment,
  }) : super();

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.substituteElement(
      newLineSegment,
    );
  }

  @override
  MPUndoRedoCommand _createOppositeCommand(
      TH2FileEditController th2FileEditController) {
    final THLineSegment currentLineSegment = th2FileEditController.thFile
        .elementByMapiahID(newLineSegment.mapiahID) as THLineSegment;
    final MPEditLineSegmentCommand oppositeCommand = MPEditLineSegmentCommand(
      newLineSegment: currentLineSegment,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
        commandType: oppositeCommand.type,
        descriptionType: descriptionType,
        map: oppositeCommand.toMap());
  }

  @override
  MPCommand copyWith({
    THLineSegment? currentLineSegment,
    THLineSegment? newLineSegment,
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  }) {
    return MPEditLineSegmentCommand.forCWJM(
      newLineSegment: newLineSegment ?? this.newLineSegment,
      oppositeCommand: oppositeCommand ?? this.oppositeCommand,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPEditLineSegmentCommand.forCWJM(
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
      oppositeCommand: map['oppositeCommand'] == null
          ? null
          : MPUndoRedoCommand.fromMap(map['oppositeCommand']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPEditLineSegmentCommand.fromJson(String source) {
    return MPEditLineSegmentCommand.fromMap(jsonDecode(source));
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

    return other is MPEditLineSegmentCommand &&
        other.newLineSegment == newLineSegment &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ newLineSegment.hashCode;

  @override
  MPCommandType get type => MPCommandType.editLineSegment;
}
