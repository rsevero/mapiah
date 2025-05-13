import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/commands/mp_undo_redo_command.dart';
import 'package:mobx/mobx.dart';

part 'mp_undo_redo_controller.g.dart';

class MPUndoRedoController = MPUndoRedoControllerBase
    with _$MPUndoRedoController;

abstract class MPUndoRedoControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  MPUndoRedoControllerBase(TH2FileEditController th2FileEditController)
      : _th2FileEditController = th2FileEditController,
        _thFile = th2FileEditController.thFile;

  final List<MPUndoRedoCommand> _undos = [];
  final List<MPUndoRedoCommand> _redos = [];

  bool get hasUndo => _undos.isNotEmpty;
  bool get hasRedo => _redos.isNotEmpty;

  void add(MPCommand command) {
    final MPUndoRedoCommand undo =
        command.getUndoRedoCommand(_th2FileEditController);

    if (_redos.isNotEmpty) {
      final int redoLastIndex = _redos.length - 1;
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
        final MPUndoRedoCommand redoOriginal = _redos[i];
        final MPCommand redoCommandOriginal = redoOriginal.undoCommand;
        final MPUndoRedoCommand oppositeRedoOriginal = redoOriginal.copyWith(
          mapUndo: redoOriginal.mapRedo,
          mapRedo: redoOriginal.mapUndo,
        );
        final MPUndoRedoCommand redoFinal = redoOriginal.copyWith(
          mapUndo: redoCommandOriginal
              .copyWith(
                descriptionType:
                    MPCommandDescriptionType.getOppositeDescription(
                  redoCommandOriginal.descriptionType,
                ),
              )
              .toMap(),
        );

        redoFromRedoCommands.add(redoFinal);
        undoFromRedoCommands.add(oppositeRedoOriginal);
      }

      /// 5. Add the new undo commands to the undo list.
      _undos.addAll(undoFromRedoCommands);

      /// 6. Add the new redo commands in reverse order to the undo list.
      for (int i = redoLastIndex; i >= 0; i--) {
        _undos.add(redoFromRedoCommands[i]);
      }

      /// 7. Clear the redo list.
      _redos.clear();
    }

    _undos.add(undo);
  }

  void execute(MPCommand command) {
    command.execute(_th2FileEditController);
    add(command);
  }

  void executeAndSubstituteLastUndo(MPCommand command) {
    if (_undos.isEmpty) {
      return;
    }

    final MPUndoRedoCommand undo =
        command.getUndoRedoCommand(_th2FileEditController);

    command.execute(_th2FileEditController);

    _undos.removeLast();
    _undos.add(undo);
  }

  void clearUndoRedoStack() {
    _undos.clear();
    _redos.clear();
  }

  void undo() {
    if (_undos.isEmpty) {
      return;
    }

    final MPUndoRedoCommand lastUndo = _undos.removeLast();
    final MPCommand command = lastUndo.undoCommand;
    final MPUndoRedoCommand redo = lastUndo.copyWith(
      mapUndo: lastUndo.mapRedo,
      mapRedo: lastUndo.mapUndo,
    );

    command.execute(_th2FileEditController, keepOriginalLineTH2File: true);

    _redos.add(redo);
    _th2FileEditController.triggerAllElementsRedraw();
  }

  void redo() {
    if (_redos.isEmpty) {
      return;
    }

    final MPUndoRedoCommand lastRedo = _redos.removeLast();
    final MPCommand command = lastRedo.undoCommand;
    final MPUndoRedoCommand undo = lastRedo.copyWith(
      mapUndo: lastRedo.mapRedo,
      mapRedo: lastRedo.mapUndo,
    );

    command.execute(_th2FileEditController, keepOriginalLineTH2File: true);

    _th2FileEditController.triggerAllElementsRedraw();
    _undos.add(undo);
  }

  String _undoRedoDescription(MPUndoRedoCommand undoRedoCommand) {
    return MPTextToUser.getCommandDescription(
      undoRedoCommand.undoCommand.descriptionType,
    );
  }

  String get undoDescription {
    if (_undos.isEmpty) {
      return '';
    }

    return _undoRedoDescription(_undos.last);
  }

  String get redoDescription {
    if (_redos.isEmpty) {
      return '';
    }

    return _undoRedoDescription(_redos.last);
  }
}
