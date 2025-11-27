part of 'mp_command.dart';

class MPRemoveXTherionImageInsertConfigCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPreCommandMixin {
  final int xtherionImageInsertConfigMPID;

  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.removeXTherionImageInsertConfig;

  static MPCommandDescriptionType get defaultDescriptionTypeStatic =>
      _defaultDescriptionType;

  MPRemoveXTherionImageInsertConfigCommand.forCWJM({
    required this.xtherionImageInsertConfigMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveXTherionImageInsertConfigCommand({
    required this.xtherionImageInsertConfigMPID,
    required MPCommand? preCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  MPRemoveXTherionImageInsertConfigCommand.fromExisting({
    required int existingXTherionImageInsertConfigMPID,
    required THFile thFile,
    super.descriptionType = _defaultDescriptionType,
  }) : xtherionImageInsertConfigMPID = existingXTherionImageInsertConfigMPID,
       super() {
    preCommand = getRemoveEmptyLinesAfterCommand(
      elementMPID: existingXTherionImageInsertConfigMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.removeXTherionImageInsertConfig;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final THFile thFile = th2FileEditController.thFile;
    final THXTherionImageInsertConfig originalImageInsert = thFile
        .xtherionImageInsertConfigByMPID(xtherionImageInsertConfigMPID);
    final THIsParentMixin imageInsertParent = originalImageInsert.parent(
      thFile,
    );
    final int imageInsertPositionInParent = imageInsertParent.getChildPosition(
      originalImageInsert,
    );

    _undoRedoInfo = {
      'removedImageInsert': originalImageInsert,
      'removedImageInsertPositionInParent': imageInsertPositionInParent,
    };
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyRemoveElementByMPID(
      xtherionImageInsertConfigMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        MPAddXTherionImageInsertConfigCommand.forCWJM(
          newImageInsertConfig:
              _undoRedoInfo!['removedImageInsert']
                  as THXTherionImageInsertConfig,
          xTherionImageInsertConfigPositionInParent:
              _undoRedoInfo!['removedImageInsertPositionInParent'] as int,
          posCommand: preCommand
              ?.getUndoRedoCommand(th2FileEditController)
              .undoCommand,
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
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveXTherionImageInsertConfigCommand.forCWJM(
      xtherionImageInsertConfigMPID:
          xtherionImageInsertConfigMPID ?? this.xtherionImageInsertConfigMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveXTherionImageInsertConfigCommand.fromMap(
    Map<String, dynamic> map,
  ) {
    return MPRemoveXTherionImageInsertConfigCommand.forCWJM(
      xtherionImageInsertConfigMPID: map['xtherionImageInsertConfigMPID'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
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
      'preCommand': preCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveXTherionImageInsertConfigCommand &&
        other.xtherionImageInsertConfigMPID == xtherionImageInsertConfigMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    xtherionImageInsertConfigMPID,
    preCommand?.hashCode ?? 0,
  );
}
