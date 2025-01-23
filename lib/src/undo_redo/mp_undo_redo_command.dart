import 'dart:convert';

import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/mp_move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/mp_move_line_command.dart';
import 'package:mapiah/src/commands/mp_move_point_command.dart';
import 'package:mapiah/src/commands/mp_move_straight_line_segment_command.dart';

class MPUndoRedoCommand {
  final MPCommandType commandType;
  final String description;
  final Map<String, dynamic> map;

  MPUndoRedoCommand(
      {required this.commandType,
      required this.description,
      required this.map});

  Map<String, dynamic> toMap() {
    return {
      'commandType': commandType.name,
      'description': description,
      'map': map,
    };
  }

  factory MPUndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return MPUndoRedoCommand(
      commandType: MPCommandType.values.byName(map['commandType']),
      description: map['description'],
      map: map['map'],
    );
  }

  factory MPUndoRedoCommand.fromJson(String jsonString) {
    return MPUndoRedoCommand.fromMap(jsonDecode(jsonString));
  }

  MPUndoRedoCommand copyWith({
    MPCommandType? commandType,
    String? description,
    Map<String, dynamic>? map,
  }) {
    return MPUndoRedoCommand(
      commandType: commandType ?? this.commandType,
      description: description ?? this.description,
      map: map ?? this.map,
    );
  }

  @override
  bool operator ==(covariant MPUndoRedoCommand other) {
    if (identical(this, other)) return true;

    return other.commandType == commandType &&
        other.description == description &&
        other.map == map;
  }

  @override
  int get hashCode => Object.hash(
        commandType,
        description,
        map,
      );

  MPCommand get command {
    switch (commandType) {
      case MPCommandType.moveBezierLineSegment:
        return MPMoveBezierLineSegmentCommand.fromMap(map);
      case MPCommandType.moveLine:
        return MPMoveLineCommand.fromMap(map);
      case MPCommandType.movePoint:
        return MPMovePointCommand.fromMap(map);
      case MPCommandType.moveStraightLineSegment:
        return MPMoveStraightLineSegmentCommand.fromMap(map);
    }
  }
}
