part of 'mp_command.dart';

class MPAddAreaBorderTHIDCommand extends MPCommand {
  final THAreaBorderTHID newAreaBorderTHID;
  final int areaBorderTHIDPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addAreaBorderTHID;

  MPAddAreaBorderTHIDCommand.forCWJM({
    required this.newAreaBorderTHID,
    required this.areaBorderTHIDPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaBorderTHIDCommand({
    required this.newAreaBorderTHID,
    this.areaBorderTHIDPositionInParent =
        mpAddChildAtEndMinusOneOfParentChildrenList,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaBorderTHIDCommand.fromExisting({
    required THAreaBorderTHID existingAreaBorderTHID,
    int? areaBorderTHIDPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newAreaBorderTHID = existingAreaBorderTHID,
       areaBorderTHIDPositionInParent =
           areaBorderTHIDPositionInParent ??
           existingAreaBorderTHID
               .parent(thFile)
               .getChildPosition(existingAreaBorderTHID),
       super();

  @override
  MPCommandType get type => MPCommandType.addAreaBorderTHID;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newAreaBorderTHID,
      childPositionInParent: areaBorderTHIDPositionInParent,
    );
    th2FileEditController.triggerNonSelectedElementsRedraw();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _prepareUndoRedoInfo() {
    // Nothing to prepare for this command.
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveAreaBorderTHIDCommand(
      areaBorderTHIDMPID: newAreaBorderTHID.mpID,
      th2FileEditController: th2FileEditController,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddAreaBorderTHIDCommand copyWith({
    THAreaBorderTHID? newAreaBorderTHID,
    int? areaBorderTHIDPositionInParent,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: newAreaBorderTHID ?? this.newAreaBorderTHID,
      areaBorderTHIDPositionInParent:
          areaBorderTHIDPositionInParent ?? this.areaBorderTHIDPositionInParent,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: THAreaBorderTHID.fromMap(map['newAreaBorderTHID']),
      areaBorderTHIDPositionInParent: map['elementPositionInParent'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddAreaBorderTHIDCommand.fromJson(String source) {
    return MPAddAreaBorderTHIDCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newAreaBorderTHID': newAreaBorderTHID.toMap(),
      'elementPositionInParent': areaBorderTHIDPositionInParent,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddAreaBorderTHIDCommand &&
        other.newAreaBorderTHID == newAreaBorderTHID &&
        other.areaBorderTHIDPositionInParent == areaBorderTHIDPositionInParent;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newAreaBorderTHID,
    areaBorderTHIDPositionInParent,
  );
}
