import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_command.dart';

class MPUndoRedoController {
  final List<MPUndoRedoCommand> _undo = [];
  final List<MPUndoRedoCommand> _redo = [];
  final THFileStore thFileStore;

  MPUndoRedoController(this.thFileStore);

  void execute(MPCommand command) {
    final MPUndoRedoCommand undo = command.execute(thFileStore);

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
    final MPCommand command = _undo.removeLast().command;
    final MPUndoRedoCommand redo = command.execute(thFileStore);
    _redo.add(redo);
  }

  void redo() {
    if (_redo.isEmpty) {
      return;
    }
    final MPCommand command = _redo.removeLast().command;
    final MPUndoRedoCommand undo = command.execute(thFileStore);
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
