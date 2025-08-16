import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';

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

  static MPMultipleElementsCommand moveElementsFromDeltaOnCanvas({
    required Offset deltaOnCanvas,
    required int decimalPositions,
    required Iterable<MPSelectedElement> mpSelectedElements,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      final THElement element = mpSelectedElement.originalElementClone;
      final MPCommand moveCommand;

      switch (element) {
        case THPoint _:
          moveCommand = MPMovePointCommand.fromDeltaOnCanvas(
            pointMPID: element.mpID,
            originalPosition: element.position,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        case THLine _:
          moveCommand = MPMoveLineCommand.fromDeltaOnCanvas(
            lineMPID: element.mpID,
            originalLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
                .originalLineSegmentsMapClone,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        default:
          throw ArgumentError(
            'Unsupported MPSelectedElement type in MPMultipleElementsCommand.moveElementsFromDelta',
          );
      }

      commandsList.add(moveCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand moveLineSegments({
    required LinkedHashMap<int, THLineSegment> originalElementsMap,
    required LinkedHashMap<int, THLineSegment> modifiedElementsMap,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLineSegments,
  }) {
    final List<MPCommand> commandsList = [];

    for (final entry in originalElementsMap.entries) {
      final int originalElementMPID = entry.key;
      final THLineSegment originalElement = entry.value;
      final THLineSegment modifiedElement =
          modifiedElementsMap[originalElementMPID]!;
      final MPCommand moveLineSegmentCommand;

      switch (originalElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand = MPMoveStraightLineSegmentCommand(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            modifiedEndPointPosition: modifiedElement.endPoint,
          );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand = MPMoveBezierLineSegmentCommand(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            modifiedEndPointPosition: modifiedElement.endPoint,
            originalControlPoint1Position: originalElement.controlPoint1,
            modifiedControlPoint1Position:
                (modifiedElement as THBezierCurveLineSegment).controlPoint1,
            originalControlPoint2Position: originalElement.controlPoint2,
            modifiedControlPoint2Position: modifiedElement.controlPoint2,
          );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand moveLineSegmentsFromDeltaOnCanvas({
    required LinkedHashMap<int, THLineSegment> originalElementsMap,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLineSegments,
  }) {
    final List<MPCommand> commandsList = [];

    for (final entry in originalElementsMap.entries) {
      final int originalElementMPID = entry.key;
      final THLineSegment originalElement = entry.value;
      final MPCommand moveLineSegmentCommand;

      switch (originalElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand = MPMoveStraightLineSegmentCommand.fromDelta(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand = MPMoveBezierLineSegmentCommand.fromDelta(
            lineSegmentMPID: originalElementMPID,
            originalEndPointPosition: originalElement.endPoint,
            originalControlPoint1Position: originalElement.controlPoint1,
            originalControlPoint2Position: originalElement.controlPoint2,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
          );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand editLinesSegmentType({
    required List<THLineSegment> newLineSegments,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editLineSegmentsType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final THLineSegment newLineSegment in newLineSegments) {
      final MPCommand setLineSegmentTypeCommand = MPEditLineSegmentCommand(
        originalLineSegment: thFile.lineSegmentByMPID(newLineSegment.mpID),
        newLineSegment: newLineSegment,
        descriptionType: descriptionType,
      );

      commandsList.add(setLineSegmentTypeCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand moveLinesFromDeltaOnCanvas({
    required Iterable<MPSelectedLine> lines,
    required Offset deltaOnCanvas,
    required int decimalPositions,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLines,
  }) {
    final List<MPCommand> commandsList = [];

    for (final MPSelectedLine line in lines) {
      final MPCommand moveLineCommand = MPMoveLineCommand.fromDeltaOnCanvas(
        lineMPID: line.mpID,
        originalLineSegmentsMap: line.originalLineSegmentsMapClone,
        deltaOnCanvas: deltaOnCanvas,
        decimalPositions: decimalPositions,
        descriptionType: descriptionType,
      );

      commandsList.add(moveLineCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand editAreasType({
    required List<int> areaMPIDs,
    required THAreaType newAreaType,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editAreasType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int areaMPID in areaMPIDs) {
      final MPCommand editAreaTypeCommand = MPEditAreaTypeCommand(
        areaMPID: areaMPID,
        newAreaType: newAreaType,
        descriptionType: descriptionType,
      );

      commandsList.add(editAreaTypeCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }

  static MPMultipleElementsCommand editLinesType({
    required List<int> lineMPIDs,
    required THLineType newLineType,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editLinesType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int lineMPID in lineMPIDs) {
      final MPCommand editLineTypeCommand = MPEditLineTypeCommand(
        lineMPID: lineMPID,
        newLineType: newLineType,
        descriptionType: descriptionType,
      );

      commandsList.add(editLineTypeCommand);
    }

    return MPMultipleElementsCommand.forCWJM(
      commandsList: commandsList,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
      descriptionType: descriptionType,
    );
  }
}
