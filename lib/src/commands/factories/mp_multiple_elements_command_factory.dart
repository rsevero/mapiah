import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

class MPMultipleElementsCommandFactory {
  static MPMultipleElementsCommand createSetOptionToElements({
    required THCommandOption option,
    required List<THElement> elements,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.setOptionToElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final THElement element in elements) {
      if (element is! THHasOptionsMixin) {
        throw ArgumentError(
          'Element with MPID ${element.parentMPID} does not support options',
        );
      }

      final MPSetOptionToElementCommand setOptionToElementCommand =
          MPSetOptionToElementCommand(
            option: option.copyWith(parentMPID: element.mpID),
            descriptionType: descriptionType,
            currentOriginalLineInTH2File: thFile
                .elementByMPID(element.mpID)
                .originalLineInTH2File,
          );

      commandsList.add(setOptionToElementCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand createRemoveOptionFromElements({
    required THCommandOptionType optionType,
    required List<int> parentMPIDs,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeOptionFromElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int parentMPID in parentMPIDs) {
      final MPRemoveOptionFromElementCommand removeOptionFromElementCommand =
          MPRemoveOptionFromElementCommand(
            optionType: optionType,
            parentMPID: parentMPID,
            currentOriginalLineInTH2File: thFile
                .elementByMPID(parentMPID)
                .originalLineInTH2File,
            descriptionType: descriptionType,
          );

      commandsList.add(removeOptionFromElementCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }
}
