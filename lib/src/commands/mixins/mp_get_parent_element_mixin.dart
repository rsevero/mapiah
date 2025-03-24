part of '../mp_command.dart';

mixin MPGetParentElementMixin on MPCommand {
  late final int parentMPID;
  THHasOptionsMixin? _parentElement;

  THHasOptionsMixin getParentElement(
      TH2FileEditController th2FileEditController) {
    if (_parentElement == null) {
      final THElement parentElement =
          th2FileEditController.thFile.elementByMPID(parentMPID);

      if (parentElement is! THHasOptionsMixin) {
        throw StateError('Parent element is not a THHasOptionsMixin');
      }
      _parentElement = parentElement;
    }

    return _parentElement!;
  }
}
