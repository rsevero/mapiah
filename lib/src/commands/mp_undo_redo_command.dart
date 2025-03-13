import 'dart:convert';

import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';

class MPUndoRedoCommand {
  final MPCommandType commandType;
  final Map<String, dynamic> mapUndo;
  final Map<String, dynamic> mapRedo;

  MPUndoRedoCommand({
    required this.commandType,
    required this.mapUndo,
    required this.mapRedo,
  });

  Map<String, dynamic> toMap() {
    return {
      'commandType': commandType.name,
      'mapUndo': mapUndo,
      'mapRedo': mapRedo,
    };
  }

  factory MPUndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return MPUndoRedoCommand(
      commandType: MPCommandType.values.byName(map['commandType']),
      mapUndo: map['mapUndo'],
      mapRedo: map['mapRedo'],
    );
  }

  factory MPUndoRedoCommand.fromJson(String jsonString) {
    return MPUndoRedoCommand.fromMap(jsonDecode(jsonString));
  }

  MPUndoRedoCommand copyWith({
    MPCommandType? commandType,
    MPCommandDescriptionType? descriptionType,
    Map<String, dynamic>? mapUndo,
    Map<String, dynamic>? mapRedo,
  }) {
    return MPUndoRedoCommand(
      commandType: commandType ?? this.commandType,
      mapUndo: mapUndo ?? this.mapUndo,
      mapRedo: mapRedo ?? this.mapRedo,
    );
  }

  @override
  bool operator ==(covariant MPUndoRedoCommand other) {
    if (identical(this, other)) return true;

    return other.commandType == commandType &&
        other.mapUndo == mapUndo &&
        other.mapRedo == mapRedo;
  }

  @override
  int get hashCode => Object.hash(
        commandType,
        mapUndo,
        mapRedo,
      );

  MPCommand get undoCommand {
    return MPCommand.fromMap(mapUndo);
  }

  MPCommand get redoCommand {
    return MPCommand.fromMap(mapRedo);
  }
}
