import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

class MPMultipleElementsCommandFactory {
  static MPMultipleElementsCommand createSetOptionOnElements({
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

  static MPMultipleElementsCommand setAttrOptionOnElements({
    required THAttrCommandOption option,
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

      final MPSetAttrOptionToElementCommand setOptionToElementCommand =
          MPSetAttrOptionToElementCommand(
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

  static MPMultipleElementsCommand removeAttrOptionFromElements({
    required String attrName,
    required List<int> parentMPIDs,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeOptionFromElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int parentMPID in parentMPIDs) {
      final MPRemoveAttrOptionFromElementCommand
      removeAttrOptionFromElementCommand = MPRemoveAttrOptionFromElementCommand(
        attrName: attrName,
        parentMPID: parentMPID,
        currentOriginalLineInTH2File: thFile
            .elementByMPID(parentMPID)
            .originalLineInTH2File,
        descriptionType: descriptionType,
      );

      commandsList.add(removeAttrOptionFromElementCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand removeElements({
    required List<int> mpIDs,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int mpID in mpIDs) {
      final MPCommand removeCommand;

      switch (thFile.getElementTypeByMPID(mpID)) {
        case THElementType.point:
          removeCommand = MPRemovePointCommand(pointMPID: mpID);
        case THElementType.line:
          removeCommand = MPRemoveLineCommand(
            lineMPID: mpID,
            isInteractiveLineCreation: false,
          );
        default:
          throw ArgumentError(
            'Unsupported element type in MPMultipleElementsCommand.removeElements',
          );
      }

      commandsList.add(removeCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand removeLineSegmentWithSubstitution({
    required int lineSegmentMPID,
    required THLineSegment lineSegmentSubstitution,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final List<MPCommand> commandsList = [];

    final MPCommand removeLineSegmentCommand = MPRemoveLineSegmentCommand(
      lineSegment: thFile.lineSegmentByMPID(lineSegmentMPID),
    );
    final MPCommand editLineSegmentCommand = MPEditLineSegmentCommand(
      originalLineSegment: thFile.lineSegmentByMPID(
        lineSegmentSubstitution.mpID,
      ),
      newLineSegment: lineSegmentSubstitution,
    );

    commandsList.add(removeLineSegmentCommand);
    commandsList.add(editLineSegmentCommand);

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand removeLineSegments({
    required Iterable<int> lineSegmentMPIDs,
    required TH2FileEditController th2FileEditController,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegments,
  }) {
    final List<MPCommand> commandsList = [];
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final MPCommand removeLineSegmentCommand = elementEditController
          .getRemoveLineSegmentCommand(lineSegmentMPID);

      commandsList.add(removeLineSegmentCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }
}
