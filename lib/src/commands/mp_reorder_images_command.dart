// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

class MPReorderImagesCommand extends MPCommand {
  final int oldIndex;
  final int newIndex;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.reorderImages;

  MPReorderImagesCommand.forCWJM({
    required this.oldIndex,
    required this.newIndex,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPReorderImagesCommand({
    required this.oldIndex,
    required this.newIndex,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.reorderImages;

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeReorderImages(
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPCommand oppositeCommand = MPReorderImagesCommand.forCWJM(
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
  MPReorderImagesCommand copyWith({
    int? oldIndex,
    int? newIndex,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPReorderImagesCommand.forCWJM(
      oldIndex: oldIndex ?? this.oldIndex,
      newIndex: newIndex ?? this.newIndex,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPReorderImagesCommand.fromMap(Map<String, dynamic> map) {
    return MPReorderImagesCommand.forCWJM(
      oldIndex: map['oldIndex'],
      newIndex: map['newIndex'],
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  factory MPReorderImagesCommand.fromJson(String source) {
    return MPReorderImagesCommand.fromMap(jsonDecode(source));
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

    return other is MPReorderImagesCommand &&
        other.oldIndex == oldIndex &&
        other.newIndex == newIndex;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, oldIndex, newIndex);
}
