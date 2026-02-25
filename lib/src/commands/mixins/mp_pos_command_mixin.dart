part of '../mp_command.dart';

mixin MPPosCommandMixin on MPCommand {
  late final MPCommand? posCommand;

  @override
  void _execPreCreateUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    posCommand?.execute(th2FileEditController);
  }
}
