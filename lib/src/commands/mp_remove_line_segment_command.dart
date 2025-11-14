part of 'mp_command.dart';

class MPRemoveLineSegmentCommand extends MPCommand {
  final THLineSegment lineSegment;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeLineSegment;

  MPRemoveLineSegmentCommand.forCWJM({
    required this.lineSegment,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveLineSegmentCommand({
    required this.lineSegment,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final MPCommand addLineSegmentCommand =
        MPAddLineSegmentCommand.fromExisting(
          existingLineSegment: lineSegment,
          thFile: thFile,
          descriptionType: descriptionType,
        );

    _undoRedoInfo = {'addLineSegmentCommand': addLineSegmentCommand};
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      lineSegment.mpID,
      setState: false,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['addLineSegmentCommand'] as MPCommand;

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveLineSegmentCommand copyWith({
    THLineSegment? lineSegment,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineSegmentCommand.forCWJM(
      lineSegment: lineSegment ?? this.lineSegment,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveLineSegmentCommand.forCWJM(
      lineSegment: THLineSegment.fromMap(map['lineSegment']),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveLineSegmentCommand.fromJson(String source) {
    return MPRemoveLineSegmentCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'lineSegment': lineSegment.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveLineSegmentCommand &&
        other.lineSegment == lineSegment;
  }

  @override
  int get hashCode => super.hashCode ^ lineSegment.hashCode;
}
