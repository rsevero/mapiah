part of 'mp_command.dart';

class MPEditLineSegmentCommand extends MPCommand {
  final THLineSegment newLineSegment;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.editLineSegment;

  MPEditLineSegmentCommand.forCWJM({
    required this.newLineSegment,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPEditLineSegmentCommand({
    required this.newLineSegment,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.editLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController
        .executeSubstituteElement(newLineSegment);
    th2FileEditController.triggerNewLineRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THLineSegment currentLineSegment = th2FileEditController.thFile
        .elementByMPID(newLineSegment.mpID) as THLineSegment;
    final MPEditLineSegmentCommand oppositeCommand = MPEditLineSegmentCommand(
      newLineSegment: currentLineSegment,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THLineSegment? currentLineSegment,
    THLineSegment? newLineSegment,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPEditLineSegmentCommand.forCWJM(
      newLineSegment: newLineSegment ?? this.newLineSegment,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPEditLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPEditLineSegmentCommand.forCWJM(
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
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
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ newLineSegment.hashCode;
}
