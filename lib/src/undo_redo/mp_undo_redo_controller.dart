import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_command.dart';

class MPUndoRedoController {
  final List<MPUndoRedoCommand> _undo = [];
  final List<MPUndoRedoCommand> _redo = [];
  final THFileEditStore thFileEditStore;

  MPUndoRedoController(this.thFileEditStore);

  void execute(MPCommand command) {
    final MPUndoRedoCommand undo = command.execute(thFileEditStore);

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
    final MPUndoRedoCommand redo = command.execute(thFileEditStore);
    _redo.add(redo);
  }

  void redo() {
    if (_redo.isEmpty) {
      return;
    }
    final MPCommand command = _redo.removeLast().command;
    final MPUndoRedoCommand undo = command.execute(thFileEditStore);
    _undo.add(undo);
  }

  bool get hasUndo => _undo.isNotEmpty;

  bool get hasRedo => _redo.isNotEmpty;

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
