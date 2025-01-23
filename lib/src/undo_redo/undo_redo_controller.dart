import 'package:mapiah/src/commands/command.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/undo_redo/undo_redo_command.dart';

class UndoRedoController {
  final List<UndoRedoCommand> _undo = [];
  final List<UndoRedoCommand> _redo = [];
  final THFileStore thFileStore;

  UndoRedoController(this.thFileStore);

  void execute(Command command) {
    final UndoRedoCommand undo = command.execute(thFileStore);

    if (_redo.isNotEmpty) {
      _undo.addAll(_redo);
      _redo.clear();
    }

    _undo.add(undo);
  }

  void undo() {
    if (_undo.isEmpty) {
      return;
    }
    final Command command = _undo.removeLast().command;
    final UndoRedoCommand redo = command.execute(thFileStore);
    _redo.add(redo);
  }

  void redo() {
    if (_redo.isEmpty) {
      return;
    }
    final Command command = _redo.removeLast().command;
    final UndoRedoCommand undo = command.execute(thFileStore);
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
