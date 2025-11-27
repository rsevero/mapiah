import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

mixin MPEmptyLinesAfterMixin {
  static List<int> getEmptyLinesAfter({
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
    return MPCommandFactory.removeEmptyLinesAfterCommand(
      elementMPID: elementMPID,
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
