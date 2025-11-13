part of "mp_command.dart";

class MPRemoveAreaBorderTHIDCommand extends MPCommand
    with MPEmptyLinesAfterMixin {
  final int areaBorderTHIDMPID;
  late final List<int> emptyLinesAfterMPIDs;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeAreaBorderTHID;

  MPRemoveAreaBorderTHIDCommand.forCWJM({
    required this.areaBorderTHIDMPID,
    required this.emptyLinesAfterMPIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveAreaBorderTHIDCommand({
    required this.areaBorderTHIDMPID,
    required this.emptyLinesAfterMPIDs,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPRemoveAreaBorderTHIDCommand.fromExisting({
    required int existingAreaBorderTHIDMPID,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : areaBorderTHIDMPID = existingAreaBorderTHIDMPID,
       super() {
    final THAreaBorderTHID areaBorderTHID = thFile.areaBorderTHIDByMPID(
      existingAreaBorderTHIDMPID,
    );
    final THIsParentMixin parent = thFile.parentByMPID(
      areaBorderTHID.parentMPID,
    );
    final int positionInParent = parent.getChildPosition(areaBorderTHID);

    emptyLinesAfterMPIDs = getEmptyLinesAfter(
      thFile: thFile,
      parent: parent,
      positionInParent: positionInParent,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removeAreaBorderTHID;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THAreaBorderTHID areaBorderTHID = thFile.areaBorderTHIDByMPID(
      areaBorderTHIDMPID,
    );
    final THIsParentMixin parent = thFile.parentByMPID(
      areaBorderTHID.parentMPID,
    );
    final int positionInParent = parent.getChildPosition(areaBorderTHID);

    _undoRedoInfo = {
      'removedAreaBorderTHID': areaBorderTHID,
      'removedAreaBorderTHIDPositionInParent': positionInParent,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    elementEditController.applyRemoveElementByMPID(areaBorderTHIDMPID);

    actualExecuteLinesAfterRemoval(
      elementEditController: elementEditController,
      emptyLinesAfter: emptyLinesAfterMPIDs,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID:
          _undoRedoInfo!['removedAreaBorderTHID'] as THAreaBorderTHID,
      areaBorderTHIDPositionInParent:
          _undoRedoInfo!['removedAreaBorderTHIDPositionInParent'] as int,
      emptyLinesAfterMPIDs: emptyLinesAfterMPIDs,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveAreaBorderTHIDCommand copyWith({
    int? areaBorderTHIDMPID,
    List<int>? emptyLinesAfterMPIDs,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAreaBorderTHIDCommand.forCWJM(
      areaBorderTHIDMPID: areaBorderTHIDMPID ?? this.areaBorderTHIDMPID,
      emptyLinesAfterMPIDs: emptyLinesAfterMPIDs ?? this.emptyLinesAfterMPIDs,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveAreaBorderTHIDCommand.forCWJM(
      areaBorderTHIDMPID: map['areaBorderTHIDMPID'],
      emptyLinesAfterMPIDs: List<int>.from(map['emptyLinesAfterMPIDs']),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveAreaBorderTHIDCommand.fromJson(String source) {
    return MPRemoveAreaBorderTHIDCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaBorderTHIDMPID': areaBorderTHIDMPID,
      'emptyLinesAfterMPIDs': emptyLinesAfterMPIDs.toList(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAreaBorderTHIDCommand &&
        other.areaBorderTHIDMPID == areaBorderTHIDMPID &&
        const DeepCollectionEquality().equals(
          other.emptyLinesAfterMPIDs,
          emptyLinesAfterMPIDs,
        );
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    areaBorderTHIDMPID,
    Object.hashAll(emptyLinesAfterMPIDs),
  );
}
