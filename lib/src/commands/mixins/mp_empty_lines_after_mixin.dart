part of '../mp_command.dart';

mixin MPEmptyLinesAfterMixin on MPCommand {
  List<int> getEmptyLinesAfter({
    required THFile thFile,
    required THIsParentMixin parent,
    required int positionInParent,
  }) {
    final List<int> emptyLinesAfter = [];
    final List<int> siblingsMPIDs = parent.childrenMPIDs;

    for (int i = positionInParent + 1; i < siblingsMPIDs.length; i++) {
      final int siblingMPID = siblingsMPIDs[i];
      final THElementType siblingElementType = thFile.getElementTypeByMPID(
        siblingMPID,
      );

      if (siblingElementType == THElementType.emptyLine) {
        emptyLinesAfter.add(siblingMPID);
      } else {
        break;
      }
    }

    return emptyLinesAfter;
  }

  MPCommand? getRemoveEmptyLinesAfterCommand({
    required int elementMPID,
    required THFile thFile,
    required MPCommandDescriptionType descriptionType,
  }) {
    final THElement element = thFile.elementByMPID(elementMPID);
    final THIsParentMixin parent = element.parent(thFile);
    final List<int> emptyLinesAfter = getEmptyLinesAfter(
      thFile: thFile,
      parent: parent,
      positionInParent: parent.getChildPosition(element),
    );

    if (emptyLinesAfter.isEmpty) {
      return null;
    }

    return MPCommandFactory.removeElements(
      mpIDs: emptyLinesAfter,
      thFile: thFile,
      descriptionType: descriptionType,
    );
  }

  MPCommand? getAddEmptyLinesAfterCommand({
    required THFile thFile,
    required THIsParentMixin parent,
    required int positionInParent,
    required MPCommandDescriptionType descriptionType,
  }) {
    final List<int> emptyLinesAfter = getEmptyLinesAfter(
      thFile: thFile,
      parent: parent,
      positionInParent: positionInParent,
    );

    if (emptyLinesAfter.isEmpty) {
      return null;
    }

    final List<MPCommand> addEmptyLinesAfterCommands = [];

    for (final int emptyLineMPID in emptyLinesAfter) {
      final THEmptyLine emptyLine = thFile.emptyLineByMPID(emptyLineMPID);
      final MPCommand addEmptyLineCommand = MPAddEmptyLineCommand.fromExisting(
        existingEmptyLine: emptyLine,
        thFile: thFile,
        descriptionType: descriptionType,
      );
      addEmptyLinesAfterCommands.add(addEmptyLineCommand);
    }

    return (addEmptyLinesAfterCommands.length == 1)
        ? addEmptyLinesAfterCommands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: addEmptyLinesAfterCommands,
            descriptionType: descriptionType,
            completionType:
                MPMultipleElementsCommandCompletionType.elementsListChanged,
          );
  }
}
