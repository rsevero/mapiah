// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPSetFileEncodingCommand extends MPCommand {
  final String fromEncoding;
  final String toEncoding;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.setFileEncoding;

  MPSetFileEncodingCommand.forCWJM({
    required this.fromEncoding,
    required this.toEncoding,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPSetFileEncodingCommand({
    required this.fromEncoding,
    required this.toEncoding,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.setFileEncoding;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    _undoRedoInfo = {};
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.propertiesController.applySetEncoding(
      fromEncoding: fromEncoding,
      toEncoding: toEncoding,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPSetFileEncodingCommand undoCommand =
        MPSetFileEncodingCommand.forCWJM(
          fromEncoding: toEncoding,
          toEncoding: fromEncoding,
          descriptionType: descriptionType,
        );

    return MPUndoRedoCommand(mapRedo: toMap(), mapUndo: undoCommand.toMap());
  }

  @override
  MPSetFileEncodingCommand copyWith({
    String? fromEncoding,
    String? toEncoding,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPSetFileEncodingCommand.forCWJM(
      fromEncoding: fromEncoding ?? this.fromEncoding,
      toEncoding: toEncoding ?? this.toEncoding,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPSetFileEncodingCommand.fromMap(Map<String, dynamic> map) {
    return MPSetFileEncodingCommand.forCWJM(
      fromEncoding: map['fromEncoding'],
      toEncoding: map['toEncoding'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPSetFileEncodingCommand.fromJson(String jsonString) {
    return MPSetFileEncodingCommand.fromMap(jsonDecode(jsonString));
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();

    map.addAll({'fromEncoding': fromEncoding, 'toEncoding': toEncoding});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPSetFileEncodingCommand &&
        other.fromEncoding == fromEncoding &&
        other.toEncoding == toEncoding;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, fromEncoding, toEncoding);
}
