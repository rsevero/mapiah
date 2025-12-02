part of 'mp_command.dart';

class MPAddAreaBorderTHIDCommand extends MPCommand with MPPosCommandMixin {
  final THAreaBorderTHID newAreaBorderTHID;
  late final int areaBorderTHIDPositionInParent;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addAreaBorderTHID;

  MPAddAreaBorderTHIDCommand.forCWJM({
    required this.newAreaBorderTHID,
    required this.areaBorderTHIDPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddAreaBorderTHIDCommand({
    required this.newAreaBorderTHID,
    this.areaBorderTHIDPositionInParent =
        mpAddChildAtEndMinusOneOfParentChildrenList,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  @override
  MPCommandType get type => MPCommandType.addAreaBorderTHID;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeAddElement(
      newElement: newAreaBorderTHID,
      childPositionInParent: areaBorderTHIDPositionInParent,
    );

    th2FileEditController.triggerNonSelectedElementsRedraw();
    th2FileEditController.triggerSelectedElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveAreaBorderTHIDCommand(
      areaBorderTHIDMPID: newAreaBorderTHID.mpID,
      preCommand: posCommand
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
  MPAddAreaBorderTHIDCommand copyWith({
    THAreaBorderTHID? newAreaBorderTHID,
    int? areaBorderTHIDPositionInParent,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: newAreaBorderTHID ?? this.newAreaBorderTHID,
      areaBorderTHIDPositionInParent:
          areaBorderTHIDPositionInParent ?? this.areaBorderTHIDPositionInParent,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: THAreaBorderTHID.fromMap(map['newAreaBorderTHID']),
      areaBorderTHIDPositionInParent: map['elementPositionInParent'],
      posCommand: (map.containsKey('posCommand') && (map['posCommand'] != null))
          ? MPCommand.fromMap(map['posCommand'])
          : null,
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
      'posCommand': posCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddAreaBorderTHIDCommand &&
        other.newAreaBorderTHID == newAreaBorderTHID &&
        other.areaBorderTHIDPositionInParent ==
            areaBorderTHIDPositionInParent &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newAreaBorderTHID,
    areaBorderTHIDPositionInParent,
    posCommand?.hashCode ?? 0,
  );
}
