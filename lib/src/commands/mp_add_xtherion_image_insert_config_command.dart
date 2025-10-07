part of 'mp_command.dart';

class MPAddXTherionImageInsertConfigCommand extends MPCommand {
  final THXTherionImageInsertConfig newImageInsertConfig;
  final int xTherionImageInsertConfigPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addXTherionImageInsertConfig;

  MPAddXTherionImageInsertConfigCommand.forCWJM({
    required this.newImageInsertConfig,
    required this.xTherionImageInsertConfigPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM();

  MPAddXTherionImageInsertConfigCommand({
    required this.newImageInsertConfig,
    required this.xTherionImageInsertConfigPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : super();

  MPAddXTherionImageInsertConfigCommand.fromExisting({
    required THXTherionImageInsertConfig existingImageInsertConfig,
    required TH2FileEditController th2FileEditController,
    super.descriptionType = _defaultDescriptionType,
  }) : newImageInsertConfig = existingImageInsertConfig,
       xTherionImageInsertConfigPositionInParent = existingImageInsertConfig
           .parent(th2FileEditController.thFile)
           .getChildPosition(existingImageInsertConfig),
       super();

  @override
  MPCommandType get type => MPCommandType.addXTherionImageInsertConfig;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  bool get hasNewExecuteMethod => true;

  @override
  void _prepareUndoRedoInfo() {
    // Nothing to prepare for this command.
  }

  @override
  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newImageInsertConfig,
      childPositionInParent: xTherionImageInsertConfigPositionInParent,
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
    int? xTherionImageInsertConfigPositionInParent,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddXTherionImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: newImageInsertConfig ?? this.newImageInsertConfig,
      xTherionImageInsertConfigPositionInParent:
          xTherionImageInsertConfigPositionInParent ??
          this.xTherionImageInsertConfigPositionInParent,
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
      xTherionImageInsertConfigPositionInParent:
          map['xTherionImageInsertConfigPositionInParent'],
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

    map.addAll({
      'newImageInsertConfig': newImageInsertConfig.toMap(),
      'xTherionImageInsertConfigPositionInParent':
          xTherionImageInsertConfigPositionInParent,
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPAddXTherionImageInsertConfigCommand &&
        other.newImageInsertConfig == newImageInsertConfig &&
        other.xTherionImageInsertConfigPositionInParent ==
            xTherionImageInsertConfigPositionInParent;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newImageInsertConfig,
    xTherionImageInsertConfigPositionInParent,
  );
}
