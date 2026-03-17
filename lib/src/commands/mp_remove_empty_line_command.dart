// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPRemoveEmptyLineCommand extends MPCommand {
  final int emptyLineMPID;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.removeEmptyLine;

  MPRemoveEmptyLineCommand.forCWJM({
    required this.emptyLineMPID,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPRemoveEmptyLineCommand({
    required this.emptyLineMPID,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.removeEmptyLine;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    final TH2File th2File = th2FileEditController.th2File;
    final THEmptyLine originalEmptyLine = th2File.emptyLineByMPID(
      emptyLineMPID,
    );
    final MPCommand addEmptyLineCommand =
        MPCommandFactory.addEmptyLineFromExisting(
          existingEmptyLine: originalEmptyLine,
          th2File: th2File,
          descriptionType: descriptionType,
        );

    _undoRedoInfo = {'addEmptyLineCommand': addEmptyLineCommand};
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeRemoveElementByMPID(
      emptyLineMPID,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand =
        _undoRedoInfo!['addEmptyLineCommand'] as MPCommand;

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPRemoveEmptyLineCommand copyWith({
    int? emptyLineMPID,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPRemoveEmptyLineCommand.forCWJM(
      emptyLineMPID: emptyLineMPID ?? this.emptyLineMPID,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPRemoveEmptyLineCommand.fromMap(Map<String, dynamic> map) {
    return MPRemoveEmptyLineCommand.forCWJM(
      emptyLineMPID: map['emptyLineMPID'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPRemoveEmptyLineCommand.fromJson(String source) {
    return MPRemoveEmptyLineCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'emptyLineMPID': emptyLineMPID});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPRemoveEmptyLineCommand &&
        other.emptyLineMPID == emptyLineMPID;
  }

  @override
  int get hashCode => super.hashCode ^ emptyLineMPID.hashCode;
}
