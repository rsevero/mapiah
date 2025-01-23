import 'dart:convert';

import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/move_line_command.dart';
import 'package:mapiah/src/commands/move_point_command.dart';
import 'package:mapiah/src/commands/move_straight_line_segment_command.dart';

class UndoRedoCommand {
  final CommandType commandType;
  final String description;
  final Map<String, dynamic> map;

  UndoRedoCommand(
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

  factory UndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return UndoRedoCommand(
      commandType: CommandType.values.byName(map['commandType']),
      description: map['description'],
      map: map['map'],
    );
  }

  factory UndoRedoCommand.fromJson(String jsonString) {
    return UndoRedoCommand.fromMap(jsonDecode(jsonString));
  }

  UndoRedoCommand copyWith({
    CommandType? commandType,
    String? description,
    Map<String, dynamic>? map,
  }) {
    return UndoRedoCommand(
      commandType: commandType ?? this.commandType,
      description: description ?? this.description,
      map: map ?? this.map,
    );
  }

  @override
  bool operator ==(covariant UndoRedoCommand other) {
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

  Command get command {
    switch (commandType) {
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
}
