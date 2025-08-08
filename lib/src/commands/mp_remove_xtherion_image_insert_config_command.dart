part of 'mp_command.dart';

class MPRemoveXTherionImageInsertConfigCommand extends MPCommand {
  final int xtherionImageInsertConfigMPID;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeXTherionImageInsertConfig;

  MPRemoveXTherionImageInsertConfigCommand.forCWJM({
    required this.xtherionImageInsertConfigMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveXTherionImageInsertConfigCommand({
    required this.xtherionImageInsertConfigMPID,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeXTherionImageInsertConfig;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController
        .applyRemoveElementByMPID(xtherionImageInsertConfigMPID);
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final THXTherionImageInsertConfig originalElement = th2FileEditController
        .thFile
        .xtherionImageInsertConfigByMPID(xtherionImageInsertConfigMPID);
    final MPCommand oppositeCommand = MPAddXTherionImageInsertConfigCommand(
      newImageInsertConfig: originalElement,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveXTherionImageInsertConfigCommand copyWith({
    int? xtherionImageInsertConfigMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveXTherionImageInsertConfigCommand.forCWJM(
      xtherionImageInsertConfigMPID:
          xtherionImageInsertConfigMPID ?? this.xtherionImageInsertConfigMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveXTherionImageInsertConfigCommand.fromMap(
      Map<String, dynamic> map) {
    return MPRemoveXTherionImageInsertConfigCommand.forCWJM(
      xtherionImageInsertConfigMPID: map['xtherionImageInsertConfigMPID'],
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
    );
  }

  factory MPRemoveXTherionImageInsertConfigCommand.fromJson(String source) {
    return MPRemoveXTherionImageInsertConfigCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'xtherionImageInsertConfigMPID': xtherionImageInsertConfigMPID,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPRemoveXTherionImageInsertConfigCommand &&
        other.xtherionImageInsertConfigMPID == xtherionImageInsertConfigMPID &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => super.hashCode ^ xtherionImageInsertConfigMPID.hashCode;
}
