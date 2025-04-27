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
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveArea(areaMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THArea originalArea = thFile.areaByMPID(areaMPID);

    final MPAddAreaCommand oppositeCommand = MPAddAreaCommand(
      newArea: originalArea,
      th2FileEditController: th2FileEditController,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPCommand copyWith({
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
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPRemoveAreaCommand.fromJson(String source) {
    return MPRemoveAreaCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'areaMPID': areaMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPRemoveAreaCommand &&
        other.areaMPID == areaMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ areaMPID.hashCode;
}
