part of "mp_command.dart";

class MPRemoveAreaBorderTHIDCommand extends MPCommand {
  final int areaBorderTHIDMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeAreaBorderTHID;

  MPRemoveAreaBorderTHIDCommand.forCWJM({
    required this.areaBorderTHIDMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveAreaBorderTHIDCommand({
    required this.areaBorderTHIDMPID,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeAreaBorderTHID;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      areaBorderTHIDMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THFile thFile = th2FileEditController.thFile;
    final THAreaBorderTHID originalAreaBorderTHID = thFile.areaBorderTHIDByMPID(
      areaBorderTHIDMPID,
    );
    final MPCommand oppositeCommand = MPAddAreaBorderTHIDCommand.fromExisting(
      existingAreaBorderTHID: originalAreaBorderTHID,
      thFile: thFile,
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
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveAreaBorderTHIDCommand.forCWJM(
      areaBorderTHIDMPID: areaBorderTHIDMPID ?? this.areaBorderTHIDMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveAreaBorderTHIDCommand.forCWJM(
      areaBorderTHIDMPID: map['areaBorderTHIDMPID'],
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

    map.addAll({'areaBorderTHIDMPID': areaBorderTHIDMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveAreaBorderTHIDCommand &&
        other.areaBorderTHIDMPID == areaBorderTHIDMPID;
  }

  @override
  int get hashCode => super.hashCode ^ areaBorderTHIDMPID.hashCode;
}
