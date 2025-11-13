part of 'mp_command.dart';

class MPAddAreaBorderTHIDCommand extends MPCommand with MPEmptyLinesAfterMixin {
  final THAreaBorderTHID newAreaBorderTHID;
  late final int areaBorderTHIDPositionInParent;
  late final List<int> emptyLinesAfterMPIDs;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addAreaBorderTHID;

  MPAddAreaBorderTHIDCommand.forCWJM({
    required this.newAreaBorderTHID,
    required this.areaBorderTHIDPositionInParent,
    required this.emptyLinesAfterMPIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaBorderTHIDCommand({
    required this.newAreaBorderTHID,
    this.areaBorderTHIDPositionInParent =
        mpAddChildAtEndMinusOneOfParentChildrenList,
    required this.emptyLinesAfterMPIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaBorderTHIDCommand.fromExisting({
    required THAreaBorderTHID existingAreaBorderTHID,
    int? areaBorderTHIDPositionInParent,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : newAreaBorderTHID = existingAreaBorderTHID,
       super() {
    final THIsParentMixin parent = existingAreaBorderTHID.parent(thFile);

    areaBorderTHIDPositionInParent =
        areaBorderTHIDPositionInParent ??
        parent.getChildPosition(existingAreaBorderTHID);
    emptyLinesAfterMPIDs = getEmptyLinesAfter(
      parent: parent,
      positionInParent: areaBorderTHIDPositionInParent,
      thFile: thFile,
    );
  }

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
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveAreaBorderTHIDCommand(
      areaBorderTHIDMPID: newAreaBorderTHID.mpID,
      emptyLinesAfterMPIDs: emptyLinesAfterMPIDs,
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
    List<int>? emptyLinesAfterMPIDs,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: newAreaBorderTHID ?? this.newAreaBorderTHID,
      areaBorderTHIDPositionInParent:
          areaBorderTHIDPositionInParent ?? this.areaBorderTHIDPositionInParent,
      emptyLinesAfterMPIDs: emptyLinesAfterMPIDs ?? this.emptyLinesAfterMPIDs,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: THAreaBorderTHID.fromMap(map['newAreaBorderTHID']),
      areaBorderTHIDPositionInParent: map['elementPositionInParent'],
      emptyLinesAfterMPIDs: List<int>.from(map['emptyLinesAfterMPIDs']),
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
      'emptyLinesAfterMPIDs': emptyLinesAfterMPIDs.toList(),
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
        const DeepCollectionEquality().equals(
          other.emptyLinesAfterMPIDs,
          emptyLinesAfterMPIDs,
        );
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newAreaBorderTHID,
    areaBorderTHIDPositionInParent,
    Object.hashAll(emptyLinesAfterMPIDs),
  );
}
