part of "mp_command.dart";

class MPRemoveScrapCommand extends MPCommand {
  final int scrapMPID;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeScrap;

  MPRemoveScrapCommand.forCWJM({
    required this.scrapMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    assert(scrapMPID > 0);
  }

  MPRemoveScrapCommand({
    required this.scrapMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    assert(scrapMPID > 0);
  }

  @override
  MPCommandType get type => MPCommandType.removeScrap;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  Map<String, dynamic>? _getUndoRedoInfo(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THScrap originalScrap = thFile.scrapByMPID(scrapMPID);
    final MPCommand addScrapCommand = MPAddScrapCommand.fromExisting(
      existingScrap: originalScrap,
      th2FileEditController: th2FileEditController,
      descriptionType: descriptionType,
    );
    final Map<String, dynamic> undoRedoInfo = {
      'addScrapCommand': addScrapCommand,
    };

    return undoRedoInfo;
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.setActiveScrapForScrapRemoval(scrapMPID);
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      scrapMPID,
    );
    th2FileEditController.triggerAllElementsRedraw();
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['addScrapCommand'] as MPCommand;

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveScrapCommand copyWith({
    int? scrapMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveScrapCommand.forCWJM(
      scrapMPID: scrapMPID ?? this.scrapMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveScrapCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveScrapCommand.forCWJM(
      scrapMPID: map['scrapMPID'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveScrapCommand.fromJson(String source) {
    return MPRemoveScrapCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'scrapMPID': scrapMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveScrapCommand && other.scrapMPID == scrapMPID;
  }

  @override
  int get hashCode => super.hashCode ^ scrapMPID.hashCode;
}
