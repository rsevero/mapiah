part of 'mp_command.dart';

class MPRemovePointCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPreCommandMixin {
  final int pointMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removePoint;

  MPRemovePointCommand.forCWJM({
    required this.pointMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemovePointCommand({
    required this.pointMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  MPRemovePointCommand.fromExisting({
    required int existingPointMPID,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : pointMPID = existingPointMPID,
       super() {
    preCommand = getRemoveEmptyLinesAfterCommand(
      elementMPID: existingPointMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removePoint;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THPoint originalPoint = thFile.pointByMPID(pointMPID);
    final THIsParentMixin pointParent = originalPoint.parent(thFile);
    final int pointPositionInParent = pointParent.getChildPosition(
      originalPoint,
    );

    _undoRedoInfo = {
      'removedPoint': originalPoint,
      'removedPointPositionInParent': pointPositionInParent,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      pointMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddPointCommand.forCWJM(
      newPoint: _undoRedoInfo!['removedPoint'] as THPoint,
      pointPositionInParent:
          _undoRedoInfo!['removedPointPositionInParent'] as int,
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
  MPRemovePointCommand copyWith({
    int? pointMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemovePointCommand.forCWJM(
      pointMPID: pointMPID ?? this.pointMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemovePointCommand.fromMap(Map<String, dynamic> map) {
    return MPRemovePointCommand.forCWJM(
      pointMPID: map['pointMPID'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemovePointCommand.fromJson(String source) {
    return MPRemovePointCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'pointMPID': pointMPID, 'preCommand': preCommand?.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemovePointCommand &&
        other.pointMPID == pointMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, pointMPID, preCommand ?? 0);
}
