import 'dart:convert';

import 'package:mapiah/src/commands/mp_command.dart';

class MPUndoRedoCommand {
  final Map<String, dynamic> mapUndo;
  final Map<String, dynamic> mapRedo;

  MPUndoRedoCommand({required this.mapUndo, required this.mapRedo});

  Map<String, dynamic> toMap() {
    return {'mapUndo': mapUndo, 'mapRedo': mapRedo};
  }

  factory MPUndoRedoCommand.fromMap(Map<String, dynamic> map) {
    return MPUndoRedoCommand(mapUndo: map['mapUndo'], mapRedo: map['mapRedo']);
  }

  factory MPUndoRedoCommand.fromJson(String jsonString) {
    return MPUndoRedoCommand.fromMap(jsonDecode(jsonString));
  }

  MPUndoRedoCommand copyWith({
    Map<String, dynamic>? mapUndo,
    Map<String, dynamic>? mapRedo,
  }) {
    return MPUndoRedoCommand(
      mapUndo: mapUndo ?? this.mapUndo,
      mapRedo: mapRedo ?? this.mapRedo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPUndoRedoCommand &&
        other.mapUndo == mapUndo &&
        other.mapRedo == mapRedo;
  }

  @override
  int get hashCode => Object.hash(mapUndo, mapRedo);

  MPCommand get undoCommand {
    return MPCommand.fromMap(mapUndo);
  }

  MPCommand get redoCommand {
    return MPCommand.fromMap(mapRedo);
  }
}
