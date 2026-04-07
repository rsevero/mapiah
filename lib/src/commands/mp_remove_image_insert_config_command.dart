// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPRemoveImageInsertConfigCommand extends MPCommand
    with MPPreCommandMixin {
  final int imageInsertConfigMPID;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removeImageInsertConfig;

  MPRemoveImageInsertConfigCommand.forCWJM({
    required this.imageInsertConfigMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM() {
    this.preCommand = preCommand;
  }

  MPRemoveImageInsertConfigCommand({
    required this.imageInsertConfigMPID,
    required MPCommand? preCommand,
    super.descriptionType = defaultDescriptionType,
  }) : super() {
    this.preCommand = preCommand;
  }

  @override
  MPCommandType get type => MPCommandType.removeImageInsertConfig;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final TH2File th2File = th2FileEditController.th2File;
    final MPRuntimeImageInsertConfigMixin originalImageInsert = th2File
        .imageByMPID(imageInsertConfigMPID);
    final THIsParentMixin imageInsertParent = originalImageInsert.parent(
      th2File: th2File,
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
    th2FileEditController.elementEditController.executeRemoveElementByMPID(
      imageInsertConfigMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPAddImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: _undoRedoInfo!['removedImageInsert'] as THElement,
      imageInsertConfigPositionInParent:
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
  MPRemoveImageInsertConfigCommand copyWith({
    int? imageInsertConfigMPID,
    MPCommand? preCommand,
    bool makePreCommandNull = false,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveImageInsertConfigCommand.forCWJM(
      imageInsertConfigMPID:
          imageInsertConfigMPID ?? this.imageInsertConfigMPID,
      preCommand: makePreCommandNull ? null : (preCommand ?? this.preCommand),
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveImageInsertConfigCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveImageInsertConfigCommand.forCWJM(
      imageInsertConfigMPID: map['xtherionImageInsertConfigMPID'],
      preCommand: map.containsKey('preCommand') && (map['preCommand'] != null)
          ? MPCommand.fromMap(map['preCommand'])
          : null,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveImageInsertConfigCommand.fromJson(String source) {
    return MPRemoveImageInsertConfigCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'xtherionImageInsertConfigMPID': imageInsertConfigMPID,
      'preCommand': preCommand?.toMap(),
    });

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveImageInsertConfigCommand &&
        other.imageInsertConfigMPID == imageInsertConfigMPID &&
        other.preCommand == preCommand;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    imageInsertConfigMPID,
    preCommand?.hashCode ?? 0,
  );
}
