part of 'mp_command.dart';

class MPAddLineSegmentCommand extends MPCommand {
  final THLineSegment newLineSegment;
  final int? beforeLineSegmentMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addLineSegment;

  MPAddLineSegmentCommand.forCWJM({
    required this.newLineSegment,
    this.beforeLineSegmentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddLineSegmentCommand({
    required this.newLineSegment,
    this.beforeLineSegmentMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    if (beforeLineSegmentMPID == null) {
      th2FileEditController.elementEditController.applyAddElement(
        newElement: newLineSegment,
      );
    } else {
      th2FileEditController.elementEditController.applyInsertLineSegment(
        newLineSegment: newLineSegment,
        beforeLineSegmentMPID: beforeLineSegmentMPID!,
      );
    }
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPRemoveLineSegmentCommand oppositeCommand =
        MPRemoveLineSegmentCommand(
      lineSegmentMPID: newLineSegment.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
    THLineSegment? newLineSegment,
    int? beforeLineSegmentMPID,
    bool makeBeforeLineSegmentMPIDNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: newLineSegment ?? this.newLineSegment,
      beforeLineSegmentMPID: makeBeforeLineSegmentMPIDNull
          ? null
          : (beforeLineSegmentMPID ?? this.beforeLineSegmentMPID),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
      beforeLineSegmentMPID: map['beforeLineSegmentMPID'],
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
      'beforeLineSegmentMPID': beforeLineSegmentMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPAddLineSegmentCommand &&
        other.newLineSegment == newLineSegment &&
        other.beforeLineSegmentMPID == beforeLineSegmentMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        newLineSegment,
        beforeLineSegmentMPID,
      );
}
