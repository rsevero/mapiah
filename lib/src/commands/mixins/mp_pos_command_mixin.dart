part of '../mp_command.dart';

mixin MPPosCommandMixin on MPCommand {
  late final MPCommand? posCommand;

  void prepareUndoRedoInfoPosCommand({
    required TH2FileEditController th2FileEditController,
  }) {
    if (posCommand != null) {
      posCommand!._prepareUndoRedoInfo(th2FileEditController);
    }
  }

  void actualExecutePosCommand({
    required TH2FileEditController th2FileEditController,
  }) {
    if (posCommand != null) {
      posCommand!._actualExecute(
        th2FileEditController,
        keepOriginalLineTH2File: true,
      );
    }
  }
}
