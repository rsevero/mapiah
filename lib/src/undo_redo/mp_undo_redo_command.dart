import 'dart:convert';

import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/mp_command_description_type.dart';

class MPUndoRedoCommand {
  final MPCommandType commandType;
  final MPCommandDescriptionType descriptionType;
  final Map<String, dynamic> map;

  MPUndoRedoCommand(
      {required this.commandType,
      required this.descriptionType,
      required this.map});

  Map<String, dynamic> toMap() {
    return {
      'commandType': commandType.name,
      'descriptionType': descriptionType,
      'map': map,
    };
  }

  factory MPUndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return MPUndoRedoCommand(
      commandType: MPCommandType.values.byName(map['commandType']),
      descriptionType:
          MPCommandDescriptionType.values.byName(map['descriptionType']),
      map: map['map'],
    );
  }

  factory MPUndoRedoCommand.fromJson(String jsonString) {
    return MPUndoRedoCommand.fromMap(jsonDecode(jsonString));
  }

  MPUndoRedoCommand copyWith({
    MPCommandType? commandType,
    MPCommandDescriptionType? descriptionType,
    Map<String, dynamic>? map,
  }) {
    return MPUndoRedoCommand(
      commandType: commandType ?? this.commandType,
      descriptionType: descriptionType ?? this.descriptionType,
      map: map ?? this.map,
    );
  }

  @override
  bool operator ==(covariant MPUndoRedoCommand other) {
    if (identical(this, other)) return true;

    return other.commandType == commandType &&
        other.descriptionType == descriptionType &&
        other.map == map;
  }

  @override
  int get hashCode => Object.hash(
        commandType,
        descriptionType,
        map,
      );

  MPCommand get command {
    switch (commandType) {
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
