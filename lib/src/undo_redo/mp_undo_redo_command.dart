import 'dart:convert';

import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';

class MPUndoRedoCommand {
  final MPCommandType commandType;
  final Map<String, dynamic> map;

  MPUndoRedoCommand({
    required this.commandType,
    required this.map,
  });

  Map<String, dynamic> toMap() {
    return {
      'commandType': commandType.name,
      'map': map,
    };
  }

  factory MPUndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return MPUndoRedoCommand(
      commandType: MPCommandType.values.byName(map['commandType']),
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
      map: map ?? this.map,
    );
  }

  @override
  bool operator ==(covariant MPUndoRedoCommand other) {
    if (identical(this, other)) return true;

    return other.commandType == commandType && other.map == map;
  }

  @override
  int get hashCode => Object.hash(
        commandType,
        map,
      );

  MPCommand get command {
    return MPCommand.fromMap(map);
  }
}
