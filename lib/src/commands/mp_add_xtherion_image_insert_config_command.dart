part of 'mp_command.dart';

class MPAddXTherionImageInsertConfigCommand extends MPCommand
    with MPEmptyLinesAfterMixin, MPPosCommandMixin {
  final THXTherionImageInsertConfig newImageInsertConfig;
  late final int xTherionImageInsertConfigPositionInParent;
  static const MPCommandDescriptionType _defaultDescriptionType =
      MPCommandDescriptionType.addXTherionImageInsertConfig;

  MPAddXTherionImageInsertConfigCommand.forCWJM({
    required this.newImageInsertConfig,
    required this.xTherionImageInsertConfigPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super.forCWJM() {
    this.posCommand = posCommand;
  }

  MPAddXTherionImageInsertConfigCommand({
    required this.newImageInsertConfig,
    required this.xTherionImageInsertConfigPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = _defaultDescriptionType,
  }) : super() {
    this.posCommand = posCommand;
  }

  MPAddXTherionImageInsertConfigCommand.fromExisting({
    required THXTherionImageInsertConfig existingImageInsertConfig,
    required THFile thFile,
    int? xTherionImageInsertConfigPositionInParent,
    super.descriptionType = _defaultDescriptionType,
  }) : newImageInsertConfig = existingImageInsertConfig,
       super() {
    final THIsParentMixin parent = existingImageInsertConfig.parent(thFile);

    this.xTherionImageInsertConfigPositionInParent =
        xTherionImageInsertConfigPositionInParent ??
        parent.getChildPosition(existingImageInsertConfig);
    posCommand = getAddEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: this.xTherionImageInsertConfigPositionInParent,
      descriptionType: descriptionType,
    );
  }

  @override
  MPCommandType get type => MPCommandType.addXTherionImageInsertConfig;

  @override
  MPCommandDescriptionType get defaultDescriptionType =>
      _defaultDescriptionType;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.applyAddElement(
      newElement: newImageInsertConfig,
      childPositionInParent: xTherionImageInsertConfigPositionInParent,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        MPRemoveXTherionImageInsertConfigCommand.fromExisting(
          existingXTherionImageInsertConfigMPID: newImageInsertConfig.mpID,
          thFile: th2FileEditController.thFile,
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
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddXTherionImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: newImageInsertConfig ?? this.newImageInsertConfig,
      xTherionImageInsertConfigPositionInParent:
          xTherionImageInsertConfigPositionInParent ??
          this.xTherionImageInsertConfigPositionInParent,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
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
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
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
      'posCommand': posCommand?.toMap(),
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
            xTherionImageInsertConfigPositionInParent &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newImageInsertConfig,
    xTherionImageInsertConfigPositionInParent,
    posCommand?.hashCode ?? 0,
  );
}
