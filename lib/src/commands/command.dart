import 'dart:convert';

import 'package:mapiah/src/commands/move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/move_line_command.dart';
import 'package:mapiah/src/commands/move_point_command.dart';
import 'package:mapiah/src/commands/move_straight_line_segment_command.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

enum CommandType {
  moveBezierLineSegment,
  moveLine,
  movePoint,
  moveStraightLineSegment,
}

/// Abstract class that defines the structure of a command.
///
/// It is responsible both for executing and undoing the command, therefore, all
/// actions that should support undo must be impmentend as a command.
abstract class Command {
  late final String description;
  late final UndoRedoCommand undoRedo;

  Command.forCWJM({required this.description, required this.undoRedo});

  Command({required this.description});

  CommandType get type;

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  static Command fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  static Command fromMap(Map<String, dynamic> map) {
    switch (CommandType.values.byName(map['commandType'])) {
      case CommandType.moveBezierLineSegment:
        return MoveBezierLineSegmentCommand.fromMap(map);
      case CommandType.moveLine:
        return MoveLineCommand.fromMap(map);
      case CommandType.movePoint:
        return MovePointCommand.fromMap(map);
      case CommandType.moveStraightLineSegment:
        return MoveStraightLineSegmentCommand.fromMap(map);
    }
  }

  Command copyWith({
    required String description,
    required UndoRedoCommand undoRedo,
  });

  UndoRedoCommand execute(THFile thFile) {
    undoRedo = createUndoRedo(thFile);
    actualExecute(thFile);

    return undoRedo;
  }

  /// The description for the undo/redo command should be the description of
  /// the original command so the message on undo and redo are the same even
  /// if the actual original and opposite commands are different.
  UndoRedoCommand createUndoRedo(THFile thFile);

  void actualExecute(THFile thFile);
}
