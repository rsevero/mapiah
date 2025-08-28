part of 'mp_command.dart';

class MPAddLineSegmentCommand extends MPCommand {
  late final THLineSegment newLineSegment;
  final int lineSegmentPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addLineSegment;

  MPAddLineSegmentCommand.forCWJM({
    required this.newLineSegment,
    required this.lineSegmentPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddLineSegmentCommand({
    required this.newLineSegment,
    this.lineSegmentPositionInParent =
        mpAddChildAtEndMinusOneOfParentChildrenList,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddLineSegmentCommand.fromExisting({
    required THLineSegment existingLineSegment,
    int? lineSegmentPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newLineSegment = existingLineSegment,
       lineSegmentPositionInParent =
           lineSegmentPositionInParent ??
           existingLineSegment
               .parent(thFile)
               .getChildPosition(existingLineSegment),
       super();

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
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.applyAddLineSegment(
      newLineSegment: newLineSegment,
      lineSegmentPositionInParent: lineSegmentPositionInParent,
    );
    elementEditController.afterAddLineSegment(newLineSegment);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveLineSegmentCommand(
      lineSegment: newLineSegment,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddLineSegmentCommand copyWith({
    THLineSegment? newLineSegment,
    int? lineSegmentPositionInParent,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: newLineSegment ?? this.newLineSegment,
      lineSegmentPositionInParent:
          lineSegmentPositionInParent ?? this.lineSegmentPositionInParent,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
      lineSegmentPositionInParent: map['lineSegmentPositionInParent'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
      'lineSegmentPositionInParent': lineSegmentPositionInParent,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddLineSegmentCommand &&
        other.newLineSegment == newLineSegment &&
        other.lineSegmentPositionInParent == lineSegmentPositionInParent;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, newLineSegment, lineSegmentPositionInParent);
}
