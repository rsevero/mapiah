import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/commands/mp_command.dart';
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
      final int redoLastIndex = _redo.length - 1;
      final List<MPUndoRedoCommand> undoFromRedoCommands = [];
      final List<MPUndoRedoCommand> redoFromRedoCommands = [];

      /// To keep the complete history of user actions we add to the undo list
      /// all redo commands with their respective undo commands:
      ///
      /// 1. Iterate over the redo list starting from last to first.
      /// 2. Execute the redo command to get it's undo command.
      /// 3. Create a new redo command with the original redo command map and
      ///    the undo command description type to properly describe this new
      ///    redo command.
      /// 4. Create lists with the new undo and redo commands.
      for (int i = redoLastIndex; i >= 0; i--) {
        final MPUndoRedoCommand redoOriginal = _redo[i];
        final MPCommand redoCommandOriginal = redoOriginal.command;
        final MPUndoRedoCommand undoRedoOriginal =
            redoCommandOriginal.execute(th2FileEditController);
        final MPCommand undoRedoCommandOriginal = undoRedoOriginal.command;
        final MPUndoRedoCommand redoFinal = redoOriginal.copyWith(
          map: redoCommandOriginal
              .copyWith(
                descriptionType: undoRedoCommandOriginal.defaultDescriptionType,
              )
              .toMap(),
        );

        redoFromRedoCommands.add(redoFinal);
        undoFromRedoCommands.add(undoRedoOriginal);
      }

      /// 5. Execute the created undo commands to get the original state we had
      ///    before the execution of the redo commands on step 2.
      for (int i = redoLastIndex; i >= 0; i--) {
        undoFromRedoCommands[i].command.execute(th2FileEditController);
      }

      /// 6. Add the new undo commands to the undo list.
      _undo.addAll(undoFromRedoCommands);

      /// 7. Add the new redo commands in reverse order to the undo list.
      for (int i = redoLastIndex; i >= 0; i--) {
        _undo.add(redoFromRedoCommands[i]);
      }

      /// 8. Clear the redo list.
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

    _redo.add(redo);
    th2FileEditController.triggerAllElementsRedraw();
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

  String _undoRedoDescription(MPUndoRedoCommand undoRedoCommand) {
    return MPTextToUser.getCommandDescription(
      undoRedoCommand.command.descriptionType,
    );
  }

  String get undoDescription {
    if (_undo.isEmpty) {
      return '';
    }

    return _undoRedoDescription(_undo.last);
  }

  String get redoDescription {
    if (_redo.isEmpty) {
      return '';
    }

    return _undoRedoDescription(_redo.last);
  }
}
