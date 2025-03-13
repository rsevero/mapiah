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
    final MPUndoRedoCommand undo =
        command.getUndoRedoCommand(th2FileEditController);

    command.execute(th2FileEditController);

    if (_redo.isNotEmpty) {
      final int redoLastIndex = _redo.length - 1;
      final List<MPUndoRedoCommand> undoFromRedoCommands = [];
      final List<MPUndoRedoCommand> redoFromRedoCommands = [];

      /// To keep the complete history of user actions we add to the undo list
      /// all redo commands with their respective undo commands:
      ///
      /// 1. Iterate over the redo list starting from last to first.
      /// 2. Get opposite of redo command.
      /// 3. Create a new redo command with the original redo command map and
      ///    the undo command description type to properly describe this new
      ///    redo command.
      /// 4. Create lists with the new undo and redo commands.
      for (int i = redoLastIndex; i >= 0; i--) {
        final MPUndoRedoCommand redoOriginal = _redo[i];
        final MPCommand redoCommandOriginal = redoOriginal.undoCommand;
        final MPUndoRedoCommand oppositeRedoOriginal = redoOriginal.copyWith(
          mapUndo: redoOriginal.mapRedo,
          mapRedo: redoOriginal.mapUndo,
        );
        final MPCommand undoRedoCommandOriginal =
            oppositeRedoOriginal.undoCommand;
        final MPUndoRedoCommand redoFinal = redoOriginal.copyWith(
          mapUndo: redoCommandOriginal
              .copyWith(
                descriptionType: undoRedoCommandOriginal.defaultDescriptionType,
              )
              .toMap(),
        );

        redoFromRedoCommands.add(redoFinal);
        undoFromRedoCommands.add(oppositeRedoOriginal);
      }

      /// 5. Add the new undo commands to the undo list.
      _undo.addAll(undoFromRedoCommands);

      /// 6. Add the new redo commands in reverse order to the undo list.
      for (int i = redoLastIndex; i >= 0; i--) {
        _undo.add(redoFromRedoCommands[i]);
      }

      /// 7. Clear the redo list.
      _redo.clear();
    }

    _undo.add(undo);
  }

  void executeAndSubstituteLastUndo(MPCommand command) {
    if (_undo.isEmpty) {
      return;
    }

    final MPUndoRedoCommand undo =
        command.getUndoRedoCommand(th2FileEditController);

    command.execute(th2FileEditController);

    _undo.removeLast();
    _undo.add(undo);
  }

  void undo() {
    if (_undo.isEmpty) {
      return;
    }

    final MPUndoRedoCommand lastUndo = _undo.removeLast();
    final MPCommand command = lastUndo.undoCommand;
    final MPUndoRedoCommand redo = lastUndo.copyWith(
      mapUndo: lastUndo.mapRedo,
      mapRedo: lastUndo.mapUndo,
    );

    command.execute(th2FileEditController);

    _redo.add(redo);
    th2FileEditController.triggerAllElementsRedraw();
  }

  void redo() {
    if (_redo.isEmpty) {
      return;
    }

    final MPUndoRedoCommand lastRedo = _redo.removeLast();
    final MPCommand command = lastRedo.undoCommand;
    final MPUndoRedoCommand undo = lastRedo.copyWith(
      mapUndo: lastRedo.mapRedo,
      mapRedo: lastRedo.mapUndo,
    );

    command.execute(th2FileEditController);

    th2FileEditController.triggerAllElementsRedraw();
    _undo.add(undo);
  }

  bool get hasUndo => _undo.isNotEmpty;

  bool get hasRedo => _redo.isNotEmpty;

  String _undoRedoDescription(MPUndoRedoCommand undoRedoCommand) {
    return MPTextToUser.getCommandDescription(
      undoRedoCommand.undoCommand.descriptionType,
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
