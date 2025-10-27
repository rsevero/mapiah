part of "mp_command.dart";

class MPRemoveAreaCommand extends MPCommand {
  final int areaMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeArea;

  MPRemoveAreaCommand.forCWJM({
    required this.areaMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveAreaCommand({
    required this.areaMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeArea;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THArea area = thFile.areaByMPID(areaMPID);
    final List<THElement> areaChildren = area.getChildren(thFile).toList();
    final THIsParentMixin areaParent = area.parent(thFile);
    final int areaPositionInParent = areaParent.getChildPosition(area);

    _undoRedoInfo = {
      'removedArea': area,
      'removedAreaChildren': areaChildren,
      'removedAreaPositionInParent': areaPositionInParent,
    };
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      areaMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddAreaCommand.forCWJM(
      newArea: _undoRedoInfo!['removedArea'],
      areaChildren: _undoRedoInfo!['removedAreaChildren'],
      areaPositionInParent: _undoRedoInfo!['removedAreaPositionInParent'],
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveAreaCommand copyWith({
    int? areaMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAreaCommand.forCWJM(
      areaMPID: areaMPID ?? this.areaMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAreaCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveAreaCommand.forCWJM(
      areaMPID: map['areaMPID'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveAreaCommand.fromJson(String source) {
    return MPRemoveAreaCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'areaMPID': areaMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAreaCommand && other.areaMPID == areaMPID;
  }

  @override
  int get hashCode => super.hashCode ^ areaMPID.hashCode;
}
