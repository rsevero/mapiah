part of 'mp_command.dart';

class MPRemoveLineSegmentCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPreCommandMixin {
  final int lineSegmentMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeLineSegment;

  MPRemoveLineSegmentCommand.forCWJM({
    required this.lineSegmentMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveLineSegmentCommand({
    required this.lineSegmentMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  MPRemoveLineSegmentCommand.fromExisting({
    required int existingLineSegmentMPID,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : lineSegmentMPID = existingLineSegmentMPID,
       super() {
    preCommand = getRemoveEmptyLinesAfterCommand(
      elementMPID: existingLineSegmentMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removeLineSegment;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THLineSegment lineSegment = thFile.lineSegmentByMPID(lineSegmentMPID);
    final THIsParentMixin lineSegmentParent = lineSegment.parent(thFile);
    final int lineSegmentPositionInParent = lineSegmentParent.getChildPosition(
      lineSegment,
    );

    _undoRedoInfo = {
      'removedLineSegment': lineSegment,
      'removedLineSegmentPositionInParent': lineSegmentPositionInParent,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      lineSegmentMPID,
      setState: false,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddLineSegmentCommand.forCWJM(
      newLineSegment: _undoRedoInfo!['removedLineSegment'] as THLineSegment,
      lineSegmentPositionInParent:
          _undoRedoInfo!['removedLineSegmentPositionInParent'] as int,
      posCommand: preCommand
          ?.getUndoRedoCommand(th2FileEditController)
          .undoCommand,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveLineSegmentCommand copyWith({
    int? lineSegmentMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveLineSegmentCommand.forCWJM(
      lineSegmentMPID: lineSegmentMPID ?? this.lineSegmentMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveLineSegmentCommand.forCWJM(
      lineSegmentMPID: map['lineSegmentMPID'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
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

    map.addAll({
      'lineSegmentMPID': lineSegmentMPID,
      'preCommand': preCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveLineSegmentCommand &&
        other.lineSegmentMPID == lineSegmentMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode =>
      Object.hash(super.hashCode, lineSegmentMPID, preCommand ?? 0);
}
