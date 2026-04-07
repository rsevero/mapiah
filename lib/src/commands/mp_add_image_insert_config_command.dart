// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPAddImageInsertConfigCommand extends MPCommand with MPPosCommandMixin {
  final THElement newImageInsertConfig;
  late final int imageInsertConfigPositionInParent;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.addImageInsertConfig;

  MPAddImageInsertConfigCommand.forCWJM({
    required this.newImageInsertConfig,
    required this.imageInsertConfigPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    _assertImageInsertConfig(newImageInsertConfig);
    this.posCommand = posCommand;
  }

  MPAddImageInsertConfigCommand({
    required this.newImageInsertConfig,
    required this.imageInsertConfigPositionInParent,
    required MPCommand? posCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    _assertImageInsertConfig(newImageInsertConfig);
    this.posCommand = posCommand;
  }

  @override
  MPCommandType get type => MPCommandType.addImageInsertConfig;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeAddElement(
      newElement: newImageInsertConfig,
      childPositionInParent: imageInsertConfigPositionInParent,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        MPCommandFactory.removeImageInsertConfigFromExisting(
          existingImageInsertConfigMPID: newImageInsertConfig.mpID,
          th2File: th2FileEditController.th2File,
          descriptionType: descriptionType,
        );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  static void _assertImageInsertConfig(THElement imageInsertConfig) {
    if (imageInsertConfig is! MPRuntimeImageInsertConfigMixin) {
      throw ArgumentError(
        'MPAddImageInsertConfigCommand only supports image insert configs.',
      );
    }
  }

  @override
  MPAddImageInsertConfigCommand copyWith({
    THElement? newImageInsertConfig,
    int? imageInsertConfigPositionInParent,
    MPCommand? posCommand,
    bool makePosCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPAddImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: newImageInsertConfig ?? this.newImageInsertConfig,
      imageInsertConfigPositionInParent:
          imageInsertConfigPositionInParent ??
          this.imageInsertConfigPositionInParent,
      posCommand: makePosCommandNull ? null : (posCommand ?? this.posCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPAddImageInsertConfigCommand.fromMap(Map<String, dynamic> map) {
    return MPAddImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: THElement.fromMap(map['newImageInsertConfig']),
      imageInsertConfigPositionInParent:
          map['xTherionImageInsertConfigPositionInParent'],
      posCommand: map.containsKey('posCommand') && (map['posCommand'] != null)
          ? MPCommand.fromMap(map['posCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPAddImageInsertConfigCommand.fromJson(String source) {
    return MPAddImageInsertConfigCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();

    map.addAll({
      'newImageInsertConfig': newImageInsertConfig.toMap(),
      'xTherionImageInsertConfigPositionInParent':
          imageInsertConfigPositionInParent,
      'posCommand': posCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (!super.equalsBase(other)) return false;

    return other is MPAddImageInsertConfigCommand &&
        other.newImageInsertConfig == newImageInsertConfig &&
        other.imageInsertConfigPositionInParent ==
            imageInsertConfigPositionInParent &&
        other.posCommand == posCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    newImageInsertConfig,
    imageInsertConfigPositionInParent,
    posCommand?.hashCode ?? 0,
  );
}
