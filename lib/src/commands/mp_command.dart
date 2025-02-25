library;

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/parameters/mp_add_element_command_params.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_complete_params.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_params.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_command.dart';

part 'mp_add_elements_command.dart';
part 'mp_add_line_command.dart';
part 'mp_add_line_segment_command.dart';
part 'mp_add_point_command.dart';
part 'mp_delete_elements_command.dart';
part 'mp_delete_line_command.dart';
part 'mp_delete_line_segment_command.dart';
part 'mp_delete_point_command.dart';
part 'mp_edit_line_segment_command.dart';
part 'mp_move_bezier_line_segment_command.dart';
part 'mp_move_elements_command.dart';
part 'mp_move_line_command.dart';
part 'mp_move_point_command.dart';
part 'mp_move_straight_line_segment_command.dart';
part 'types/mp_command_type.dart';

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

  MPUndoRedoCommand execute(TH2FileEditController th2FileEditController) {
    oppositeCommand = _createOppositeCommand(th2FileEditController);
    _actualExecute(th2FileEditController);

    return oppositeCommand!;
  }

  /// The description for the undo/redo command should be the description of
  /// the original command so the message on undo and redo are the same even
  /// if the actual original and opposite commands are different.
  MPUndoRedoCommand _createOppositeCommand(
    TH2FileEditController th2FileEditController,
  );

  void _actualExecute(TH2FileEditController th2FileEditController);

  MPCommand copyWith({
    MPCommandDescriptionType? descriptionType,
    MPUndoRedoCommand? oppositeCommand,
  });

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'commandType': type.name,
      'oppositeCommand': oppositeCommand?.toMap(),
      'descriptionType': descriptionType.name,
    };
  }

  static MPCommand fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPCommand &&
        other.oppositeCommand == oppositeCommand &&
        other.descriptionType == descriptionType;
  }

  @override
  int get hashCode => Object.hash(
        oppositeCommand,
        descriptionType,
      );

  static MPCommand fromMap(Map<String, dynamic> map) {
    switch (MPCommandType.values.byName(map['commandType'])) {
      case MPCommandType.addElements:
        return MPAddElementsCommand.fromMap(map);
      case MPCommandType.addLine:
        return MPAddLineCommand.fromMap(map);
      case MPCommandType.addLineSegment:
        return MPAddLineSegmentCommand.fromMap(map);
      case MPCommandType.addPoint:
        return MPAddPointCommand.fromMap(map);
      case MPCommandType.deleteElements:
        return MPDeleteElementsCommand.fromMap(map);
      case MPCommandType.deleteLine:
        return MPDeleteLineCommand.fromMap(map);
      case MPCommandType.deleteLineSegment:
        return MPDeleteLineSegmentCommand.fromMap(map);
      case MPCommandType.deletePoint:
        return MPDeletePointCommand.fromMap(map);
      case MPCommandType.editLineSegment:
        return MPEditLineSegmentCommand.fromMap(map);
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
