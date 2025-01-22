import 'dart:convert';

import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/commands/move_bezier_line_segment_command.dart';
import 'package:mapiah/src/commands/move_line_command.dart';
import 'package:mapiah/src/commands/move_point_command.dart';
import 'package:mapiah/src/commands/move_straight_line_segment_command.dart';

class UndoRedoCommand {
  final CommandType type;
  final String description;
  final String json;

  UndoRedoCommand(
      {required this.type, required this.description, required this.json});

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'description': description,
      'json': json,
    };
  }

  factory UndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return UndoRedoCommand(
      type: CommandType.values.byName(map['type']),
      description: map['description'],
      json: map['json'],
    );
  }

  factory UndoRedoCommand.fromJson(String jsonString) {
    return UndoRedoCommand.fromMap(jsonDecode(jsonString));
  }

  UndoRedoCommand copyWith({
    CommandType? type,
    String? description,
    String? json,
  }) {
    return UndoRedoCommand(
      type: type ?? this.type,
      description: description ?? this.description,
      json: json ?? this.json,
    );
  }

  @override
  bool operator ==(covariant UndoRedoCommand other) {
    if (identical(this, other)) return true;

    return other.type == type &&
        other.description == description &&
        other.json == json;
  }

  @override
  int get hashCode => Object.hash(
        type,
        description,
        json,
      );

  Command get command {
    switch (type) {
      case CommandType.moveBezierLineSegment:
        return MoveBezierLineSegmentCommand.fromJson(json);
      case CommandType.moveLine:
        return MoveLineCommand.fromJson(json);
      case CommandType.movePoint:
        return MovePointCommand.fromJson(json);
      case CommandType.moveStraightLineSegment:
        return MoveStraightLineSegmentCommand.fromJson(json);
    }
  }
}
