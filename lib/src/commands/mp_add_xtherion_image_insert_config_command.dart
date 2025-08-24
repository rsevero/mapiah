part of 'mp_command.dart';

class MPAddXTherionImageInsertConfigCommand extends MPCommand {
  final THXTherionImageInsertConfig newImageInsertConfig;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addXTherionImageInsertConfig;

  MPAddXTherionImageInsertConfigCommand.forCWJM({
    required this.newImageInsertConfig,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddXTherionImageInsertConfigCommand({
    required this.newImageInsertConfig,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.addXTherionImageInsertConfig;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newImageInsertConfig,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPRemoveXTherionImageInsertConfigCommand(
      xtherionImageInsertConfigMPID: newImageInsertConfig.mpID,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPAddXTherionImageInsertConfigCommand copyWith({
    THXTherionImageInsertConfig? newImageInsertConfig,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddXTherionImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: newImageInsertConfig ?? this.newImageInsertConfig,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddXTherionImageInsertConfigCommand.fromMap(
    Map<String, dynamic> map,
  ) {
    return MPAddXTherionImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: THXTherionImageInsertConfig.fromMap(
        map['newImageInsertConfig'],
      ),
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddXTherionImageInsertConfigCommand.fromJson(String source) {
    return MPAddXTherionImageInsertConfigCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'newImageInsertConfig': newImageInsertConfig.toMap()});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddXTherionImageInsertConfigCommand &&
        other.newImageInsertConfig == newImageInsertConfig;
  }

  @override
  int get hashCode => super.hashCode ^ newImageInsertConfig.hashCode;
}
