import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/undo_redo/mp_undo_redo_command.dart';

class MPUndoRedoController {
  final List<MPUndoRedoCommand> _undo = [];
  final List<MPUndoRedoCommand> _redo = [];
  final TH2FileEditController th2FileEditController;

  MPUndoRedoController(this.th2FileEditController);

  void execute(MPCommand command) {
    final MPUndoRedoCommand undo = command.execute(th2FileEditController);

    if (_redo.isNotEmpty) {
      _undo.addAll(_redo);
      _redo.clear();
    }

    _undo.add(undo);
  }

  void executeAndSubstituteLastUndo(MPCommand command) {
    if (_undo.isEmpty) {
      return;
    }

    final MPUndoRedoCommand undo = command.execute(th2FileEditController);

    _undo.removeLast();
    _undo.add(undo);
  }

  void undo() {
    if (_undo.isEmpty) {
      return;
    }
    final MPCommand command = _undo.removeLast().command;
    final MPUndoRedoCommand redo = command.execute(th2FileEditController);
    th2FileEditController.triggerAllElementsRedraw();
    _redo.add(redo);
  }

  void redo() {
    if (_redo.isEmpty) {
      return;
    }
    final MPCommand command = _redo.removeLast().command;
    final MPUndoRedoCommand undo = command.execute(th2FileEditController);
    th2FileEditController.triggerAllElementsRedraw();
    _undo.add(undo);
  }

  bool get hasUndo => _undo.isNotEmpty;

  bool get hasRedo => _redo.isNotEmpty;

  String get undoDescription {
    if (_undo.isEmpty) {
      return '';
    }
    return MPTextToUser.getCommandDescription(
      _undo.last.descriptionType,
    );
  }

  String get redoDescription {
    if (_redo.isEmpty) {
      return '';
    }
    return MPTextToUser.getCommandDescription(
      _redo.last.descriptionType,
    );
  }
}
