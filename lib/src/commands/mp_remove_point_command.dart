part of 'mp_command.dart';

class MPRemovePointCommand extends MPCommand with MPPreCommandMixin {
  final int pointMPID;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removePoint;

  MPRemovePointCommand.forCWJM({
    required this.pointMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemovePointCommand({
    required this.pointMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  @override
  MPCommandType get type => MPCommandType.removePoint;

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
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeRemoveElementByMPID(
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
  int get hashCode =>
      Object.hash(super.hashCode, pointMPID, preCommand?.hashCode ?? 0);
}
