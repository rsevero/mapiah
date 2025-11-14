part of '../mp_command.dart';

mixin MPPreCommandMixin on MPCommand {
  late final MPCommand? preCommand;

  void prepareUndoRedoInfoPreCommand({
    required TH2FileEditController th2FileEditController,
  }) {
    if (preCommand != null) {
      preCommand!._prepareUndoRedoInfo(th2FileEditController);
    }
  }

  void actualExecutePreCommand({
    required TH2FileEditController th2FileEditController,
  }) {
    if (preCommand != null) {
      preCommand!._actualExecute(
        th2FileEditController,
        keepOriginalLineTH2File: true,
      );
    }
  }
}
