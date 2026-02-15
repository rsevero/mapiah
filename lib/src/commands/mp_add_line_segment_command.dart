part of 'mp_command.dart';

class MPAddLineSegmentCommand extends MPCommand with MPPosCommandMixin {
  final THLineSegment newLineSegment;
  late final int lineSegmentPositionInParent;

  /// This parameter does not need to be saved for undos. Its just an
  /// alternative way to specify the position of the new line segment,
  /// where the new line segment will be added just before the line segment with
  /// this MPID.
  final int? _existingLineSegmentMPID;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addLineSegment;

  MPAddLineSegmentCommand.forCWJM({
    required this.newLineSegment,
    required this.lineSegmentPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : _existingLineSegmentMPID = null,
       super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddLineSegmentCommand({
    required this.newLineSegment,
    this.lineSegmentPositionInParent =
        mpAddChildAtEndMinusOneOfParentChildrenList,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : _existingLineSegmentMPID = null,
       super() {
    this.posCommand = posCommand;
  }

  MPAddLineSegmentCommand.atExistingLineSegmentPosition({
    required this.newLineSegment,
    required int existingLineSegmentMPID,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : _existingLineSegmentMPID = existingLineSegmentMPID,
       super() {
    this.posCommand = posCommand;
  }

  @override
  MPCommandType get type => MPCommandType.addLineSegment;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    if (_existingLineSegmentMPID != null) {
      final THFile thFile = th2FileEditController.thFile;
      final THLine line = thFile.lineByMPID(newLineSegment.parentMPID);
      final int existingLineSegmentIndex = line.childrenMPIDs.indexOf(
        _existingLineSegmentMPID,
      );

      lineSegmentPositionInParent = existingLineSegmentIndex;
    }

    elementEditController.executeAddLineSegment(
      newLineSegment: newLineSegment,
      lineSegmentPositionInParent: lineSegmentPositionInParent,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        MPCommandFactory.removeLineSegmentFromExisting(
          toRemoveLineSegmentMPID: newLineSegment.mpID,
          thFile: th2FileEditController.thFile,
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
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: newLineSegment ?? this.newLineSegment,
      lineSegmentPositionInParent:
          lineSegmentPositionInParent ?? this.lineSegmentPositionInParent,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddLineSegmentCommand.fromMap(Map<String, dynamic> map) {
    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: THLineSegment.fromMap(map['newLineSegment']),
      lineSegmentPositionInParent: map['lineSegmentPositionInParent'],
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
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
      'posCommand': posCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddLineSegmentCommand &&
        other.newLineSegment == newLineSegment &&
        other.lineSegmentPositionInParent == lineSegmentPositionInParent &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newLineSegment,
    lineSegmentPositionInParent,
    posCommand?.hashCode ?? 0,
  );
}
