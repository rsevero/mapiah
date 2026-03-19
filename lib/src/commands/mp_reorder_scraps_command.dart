// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPReorderScrapsCommand extends MPCommand {
  final int oldIndex;
  final int newIndex;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.reorderScraps;

  MPReorderScrapsCommand.forCWJM({
    required this.oldIndex,
    required this.newIndex,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPReorderScrapsCommand({
    required this.oldIndex,
    required this.newIndex,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.reorderScraps;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeReorderScraps(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPReorderScrapsCommand.forCWJM(
      oldIndex: newIndex,
      newIndex: oldIndex,
      descriptionType: descriptionType,
    );

    return MPUndoRedoCommand(
      mapRedo: toMap(),
      mapUndo: oppositeCommand.toMap(),
    );
  }

  @override
  MPReorderScrapsCommand copyWith({
    int? oldIndex,
    int? newIndex,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPReorderScrapsCommand.forCWJM(
      oldIndex: oldIndex ?? this.oldIndex,
      newIndex: newIndex ?? this.newIndex,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPReorderScrapsCommand.fromMap(Map<String, dynamic> map) {
    return MPReorderScrapsCommand.forCWJM(
      oldIndex: map['oldIndex'],
      newIndex: map['newIndex'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPReorderScrapsCommand.fromJson(String source) {
    return MPReorderScrapsCommand.fromMap(jsonDecode(source));
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();

    map.addAll({'oldIndex': oldIndex, 'newIndex': newIndex});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!super.equalsBase(other)) {
      return false;
    }

    return other is MPReorderScrapsCommand &&
        other.oldIndex == oldIndex &&
        other.newIndex == newIndex;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, oldIndex, newIndex);
}
