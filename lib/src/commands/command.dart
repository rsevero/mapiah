import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/commands/command_type.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

part "command.mapper.dart";

/// Abstract class that defines the structure of a command.
///
/// It is responsible both for executing and undoing the command, therefore, all
/// actions that should support undo must be impmentend as a command.
@MappableClass()
abstract class Command with CommandMappable {
  late final CommandType _type;
  String description;
  late final UndoRedoCommand _undoRedo;

  Command({required CommandType type, required this.description}) {
    _type = type;
  }

  CommandType get type => _type;

  UndoRedoCommand execute(THFile thFile) {
    _undoRedo = createUndoRedo(thFile);
    actualExecute(thFile);

    return _undoRedo;
  }

  /// The description for the undo/redo command should be the description of
  /// the original command so the message on undo and redo are the same even
  /// if the actual original and opposite commands are different.
  UndoRedoCommand createUndoRedo(THFile thFile);

  void actualExecute(THFile thFile);
}
