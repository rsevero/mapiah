// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_command.dart';

/// Replaces the whole contents of the file with a snapshot, as one canvas
/// undo step for a text edit.
///
/// The two snapshots are `TH2File.toMap()` maps shared, never copied, by the
/// command, its inverse and their maps in the undo stack: [toMap] puts the
/// map objects themselves under `before` and `after`, [fromMap] keeps the
/// maps it receives and [copyWith] passes them on. Nothing mutates them.
class MPReplaceTH2FileContentsCommand extends MPCommand {
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;

  static const MPCommandDescriptionType defaultDescriptionType =
      MPCommandDescriptionType.replaceTH2FileContents;

  MPReplaceTH2FileContentsCommand.forCWJM({
    required this.before,
    required this.after,
    super.descriptionType = defaultDescriptionType,
  }) : super.forCWJM();

  MPReplaceTH2FileContentsCommand({
    required this.before,
    required this.after,
    super.descriptionType = defaultDescriptionType,
  }) : super();

  @override
  MPCommandType get type => MPCommandType.replaceTH2FileContents;

  @override
  void _prepareUndoRedoInfo(TH2FileEditController th2FileEditController) {
    _undoRedoInfo = {};
  }

  @override
  void _actualExecute(TH2FileEditController th2FileEditController) {
    th2FileEditController.elementEditController.executeReplaceTH2FileContents(
      after,
    );
  }

  @override
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    final MPReplaceTH2FileContentsCommand undoCommand =
        MPReplaceTH2FileContentsCommand.forCWJM(
          before: after,
          after: before,
          descriptionType: descriptionType,
        );

    return MPUndoRedoCommand(mapRedo: toMap(), mapUndo: undoCommand.toMap());
  }

  @override
  MPReplaceTH2FileContentsCommand copyWith({
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    MPCommandDescriptionType? descriptionType,
  }) {
    return MPReplaceTH2FileContentsCommand.forCWJM(
      before: before ?? this.before,
      after: after ?? this.after,
      descriptionType: descriptionType ?? this.descriptionType,
    );
  }

  factory MPReplaceTH2FileContentsCommand.fromMap(Map<String, dynamic> map) {
    return MPReplaceTH2FileContentsCommand.forCWJM(
      before: map['before'] as Map<String, dynamic>,
      after: map['after'] as Map<String, dynamic>,
      descriptionType: MPCommandDescriptionType.values.byName(
        map['descriptionType'],
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();

    map.addAll({'before': before, 'after': after});

    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (!super.equalsBase(other)) return false;

    return other is MPReplaceTH2FileContentsCommand &&
        identical(other.before, before) &&
        identical(other.after, after);
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    identityHashCode(before),
    identityHashCode(after),
  );
}
