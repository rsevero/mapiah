part of "mp_command.dart";

class MPRemoveScrapCommand extends MPCommand {
  final int scrapMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeScrap;

  MPRemoveScrapCommand.forCWJM({
    required this.scrapMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveScrapCommand({
    required this.scrapMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeScrap;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      scrapMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THScrap originalScrap = thFile.scrapByMPID(scrapMPID);
    final Iterable<THElement> originalScrapChildren = originalScrap.getChildren(
      thFile,
    );

    final MPCommand oppositeCommand = MPAddScrapCommand(
      newScrap: originalScrap,
      scrapChildren: originalScrapChildren,
      descriptionType: descriptionType,
    );

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

    return other is MPRemoveScrapCommand &&
        other.scrapMPID == scrapMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ scrapMPID.hashCode;
}
