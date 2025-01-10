import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

class UndoRedoController {
  final List<UndoRedoCommand> _undo = [];
  final List<UndoRedoCommand> _redo = [];
  final THFile _thFile;

  UndoRedoController(THFile thFile) : _thFile = thFile;

  void execute(Command command) {
    final UndoRedoCommand undo = command.execute(_thFile);
    _undo.add(undo);
    _redo.clear();
  }

  void undo() {
    if (_undo.isEmpty) {
      return;
    }
    final Command command = _undo.removeLast().command;
    final UndoRedoCommand redo = command.execute(_thFile);
    _redo.add(redo);
  }

  void redo() {
    if (_redo.isEmpty) {
      return;
    }
    final Command command = _redo.removeLast().command;
    final UndoRedoCommand undo = command.execute(_thFile);
    _undo.add(undo);
  }

  bool get canUndo => _undo.isNotEmpty;

  bool get canRedo => _redo.isNotEmpty;

  String get undoDescription {
    if (_undo.isEmpty) {
      return '';
    }
    return _undo.last.description;
  }

  String get redoDescription {
    if (_redo.isEmpty) {
      return '';
    }
    return _redo.last.description;
  }
}
