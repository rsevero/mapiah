part of 'mp_command.dart';

class MPAddAreaBorderTHIDCommand extends MPCommand {
  final THAreaBorderTHID newAreaBorderTHID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addAreaBorderTHID;

  MPAddAreaBorderTHIDCommand.forCWJM({
    required this.newAreaBorderTHID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddAreaBorderTHIDCommand({
    required this.newAreaBorderTHID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

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
    );
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
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: newAreaBorderTHID ?? this.newAreaBorderTHID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddAreaBorderTHIDCommand.fromMap(Map<String, dynamic> map) {
    return MPAddAreaBorderTHIDCommand.forCWJM(
      newAreaBorderTHID: THAreaBorderTHID.fromMap(map['newAreaBorderTHID']),
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

    map.addAll({'newAreaBorderTHID': newAreaBorderTHID.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddAreaBorderTHIDCommand &&
        other.newAreaBorderTHID == newAreaBorderTHID;
  }

  @override
  int get hashCode => super.hashCode ^ newAreaBorderTHID.hashCode;
}
