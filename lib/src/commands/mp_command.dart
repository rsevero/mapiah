library;

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_complete_parameters.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_parameters.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_command.dart';

part 'types/mp_command_type.dart';
part 'mp_move_bezier_line_segment_command.dart';
part 'mp_move_elements_command.dart';
part 'mp_move_line_command.dart';
part 'mp_move_point_command.dart';
part 'mp_move_straight_line_segment_command.dart';

/// Abstract class that defines the structure of a command.
///
/// It is responsible both for executing and undoing the command, therefore, all
/// actions that should support undo must be impmentend as a command.
abstract class MPCommand {
  late final MPCommandDescriptionType descriptionType;
  MPUndoRedoCommand? oppositeCommand;

  MPCommand.forCWJM(
      {required this.descriptionType, required this.oppositeCommand});

  MPCommand({required this.descriptionType});

  MPCommandType get type;

  MPUndoRedoCommand execute(TH2FileEditStore th2FileEditStore) {
    oppositeCommand = _createOppositeCommand();
    _actualExecute(th2FileEditStore);

    return oppositeCommand!;
  }

  /// The description for the undo/redo command should be the description of
  /// the original command so the message on undo and redo are the same even
  /// if the actual original and opposite commands are different.
  MPUndoRedoCommand _createOppositeCommand();

  void _actualExecute(TH2FileEditStore th2FileEditStore);

  MPCommand copyWith({
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  });

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  static MPCommand fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static MPCommand fromMap(Map<String, dynamic> map) {
    switch (MPCommandType.values.byName(map['commandType'])) {
      case MPCommandType.moveBezierLineSegment:
        return MPMoveBezierLineSegmentCommand.fromMap(map);
      case MPCommandType.moveElements:
        return MPMoveElementsCommand.fromMap(map);
      case MPCommandType.moveLine:
        return MPMoveLineCommand.fromMap(map);
      case MPCommandType.movePoint:
        return MPMovePointCommand.fromMap(map);
      case MPCommandType.moveStraightLineSegment:
        return MPMoveStraightLineSegmentCommand.fromMap(map);
    }
  }
}
