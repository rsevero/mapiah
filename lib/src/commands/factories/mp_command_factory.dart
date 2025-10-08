import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:path/path.dart' as p;

class MPCommandFactory {
  static MPCommand addLineToArea({
    required THArea area,
    required THLine line,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.addAreaBorderTHID,
  }) {
    final List<MPCommand> commands = [];
    final String lineTHID;

    if (line.hasOption(THCommandOptionType.id)) {
      lineTHID =
          (line.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;
    } else {
      final String areaTHID;

      if (area.hasOption(THCommandOptionType.id)) {
        areaTHID =
            (area.optionByType(THCommandOptionType.id) as THIDCommandOption)
                .thID;
      } else {
        final String newAreaTHID = thFile.getNewTHID(
          element: area,
          prefix: mpAreaTHIDPrefix,
        );
        final THIDCommandOption areaTHIDOption = THIDCommandOption.forCWJM(
          parentMPID: area.mpID,
          thID: newAreaTHID,
          originalLineInTH2File: '',
        );
        final MPCommand addAreaTHIDCommand = MPSetOptionToElementCommand(
          option: areaTHIDOption,
          currentOriginalLineInTH2File: area.originalLineInTH2File,
        );

        commands.add(addAreaTHIDCommand);
        areaTHID = newAreaTHID;
      }

      final String lineTHIDPrefix = '$areaTHID-$mpLineTHIDPrefix';
      final String newLineTHID = thFile.getNewTHID(
        element: line,
        prefix: lineTHIDPrefix,
      );
      final THIDCommandOption lineTHIDOption = THIDCommandOption.forCWJM(
        parentMPID: line.mpID,
        thID: newLineTHID,
        originalLineInTH2File: '',
      );
      final MPCommand addLineTHIDCommand = MPSetOptionToElementCommand(
        option: lineTHIDOption,
        currentOriginalLineInTH2File: line.originalLineInTH2File,
      );

      commands.add(addLineTHIDCommand);
      lineTHID = newLineTHID;
    }

    final THAreaBorderTHID areaBorderTHID = THAreaBorderTHID(
      parentMPID: area.mpID,
      thID: lineTHID,
    );
    final MPCommand addAreaBorderTHIDCommand = MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID: areaBorderTHID,
    );

    commands.add(addAreaBorderTHIDCommand);

    final MPCommand command = (commands.length == 1)
        ? commands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commands,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
          );

    return command;
  }

  static MPCommand addPoint({
    required Offset screenPosition,
    required String pointTypeString,
    required TH2FileEditController th2FileEditController,
  }) {
    final THPoint newPoint = THPoint.pointTypeFromString(
      parentMPID: th2FileEditController.activeScrapID,
      pointTypeString:
          th2FileEditController.elementEditController.lastUsedPointType,
      position: THPositionPart(
        coordinates: th2FileEditController.offsetScreenToCanvas(screenPosition),
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
    );
    final MPAddPointCommand command = MPAddPointCommand(newPoint: newPoint);

    return command;
  }

  static MPCommand addScrap({
    required String thID,
    required THFile thFile,
    List<THElement>? scrapChildren,
    List<THCommandOption>? scrapOptions,
  }) {
    final THScrap newScrap = THScrap(parentMPID: thFile.mpID, thID: thID);
    final int newScrapMPID = newScrap.mpID;

    scrapChildren ??= [];
    scrapOptions ??= [];

    for (THCommandOption option in scrapOptions) {
      if (option.parentMPID != newScrapMPID) {
        option = option.copyWith(parentMPID: newScrapMPID);
      }

      newScrap.addUpdateOption(option);
    }

    // Re-parent existing children so they belong to the new scrap.
    for (int i = 0; i < scrapChildren.length; i++) {
      final THElement child = scrapChildren[i];

      if (child.parentMPID != newScrapMPID) {
        final THElement updated = child.copyWith(parentMPID: newScrapMPID);

        scrapChildren[i] = updated;
      }
    }

    scrapChildren.add(THEndscrap(parentMPID: newScrapMPID));

    final MPCommand addScrapCommandForNewScrap = MPAddScrapCommand(
      newScrap: newScrap,
      scrapChildren: scrapChildren,
    );

    return addScrapCommandForNewScrap;
  }

  static MPCommand addXTherionInsertImageConfig({
    required String imageFilename,
    required TH2FileEditController th2FileEditController,
  }) {
    final THFile thFile = th2FileEditController.thFile;
    final String fromPath = p.dirname(thFile.filename);
    final String rawRelativeImagePath = p.relative(
      imageFilename,
      from: fromPath,
    );
    final String relativeImagePath =
        (rawRelativeImagePath.startsWith('./') ||
            rawRelativeImagePath.startsWith('../'))
        ? rawRelativeImagePath
        : './$rawRelativeImagePath';
    final Rect fileBoundingBox = thFile.getBoundingBox(th2FileEditController);
    final THXTherionImageInsertConfig
    newImage = THXTherionImageInsertConfig.adjustPosition(
      parentMPID: thFile.mpID,
      filename: relativeImagePath,
      xx: THDoublePart(value: fileBoundingBox.left),
      // For Flutter's canvas, the top is 0 and positive values of Y go down but
      // in the TH2 format, the top is the maximum Y value.
      // That's why Flutter calls the maximum Y value "bottom" and despite being
      // called *bottom*, we use it to align the new image to the *top* left
      // point of the current drawing.
      yy: THDoublePart(value: fileBoundingBox.bottom),
      th2FileEditController: th2FileEditController,
    );
    final MPAddXTherionImageInsertConfigCommand addImageCommand =
        MPAddXTherionImageInsertConfigCommand(
          newImageInsertConfig: newImage,
          xTherionImageInsertConfigPositionInParent:
              mpAddChildAtEndOfParentChildrenList,
        );

    return addImageCommand;
  }

  static MPCommand setLineSegmentsType({
    required MPSelectedLineSegmentType selectedLineSegmentType,
    required THFile thFile,
    required List<THLineSegment> originalLineSegments,
  }) {
    final List<THLineSegment> changedLineSegments = [];

    switch (selectedLineSegmentType) {
      case MPSelectedLineSegmentType.bezierCurveLineSegment:
        final THLine line = thFile.lineByMPID(
          originalLineSegments.first.parentMPID,
        );

        for (final THLineSegment currentLineSegment in originalLineSegments) {
          final THLineSegment? previousLineSegment = line
              .getPreviousLineSegment(currentLineSegment, thFile);

          if (previousLineSegment == null) {
            continue;
          }

          final THBezierCurveLineSegment changedLineSegment =
              MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: previousLineSegment.endPoint.coordinates,
                straightLineSegment:
                    (currentLineSegment as THStraightLineSegment),
              );

          changedLineSegments.add(changedLineSegment);
        }
      case MPSelectedLineSegmentType.straightLineSegment:
        for (final THLineSegment currentLineSegment in originalLineSegments) {
          final THStraightLineSegment changedLineSegment =
              THStraightLineSegment.forCWJM(
                mpID: currentLineSegment.mpID,
                parentMPID: currentLineSegment.parentMPID,
                endPoint: currentLineSegment.endPoint,
                optionsMap: currentLineSegment.optionsMap,
                attrOptionsMap: currentLineSegment.attrOptionsMap,
                originalLineInTH2File: '',
              );

          changedLineSegments.add(changedLineSegment);
        }
      default:
        throw ArgumentError(
          'Unsupported selectedLineSegmentType in MPCommandFactory.setLineSegmentType',
        );
    }

    final MPCommand setLineSegmentTypeCommand =
        MPCommandFactory.editLinesSegmentType(
          thFile: thFile,
          changedLineSegments: changedLineSegments,
        );

    return setLineSegmentTypeCommand;
  }

  static MPCommand setOptionOnElements({
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand removeOptionFromElements({
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand setAttrOptionOnElements({
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand removeAttrOptionFromElements({
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand removeElements({
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
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

  static MPCommand removeLineSegments({
    required Iterable<int> lineSegmentMPIDs,
    required TH2FileEditController th2FileEditController,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegments,
  }) {
    assert(lineSegmentMPIDs.isNotEmpty);

    final List<MPCommand> commandsList = [];
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

    for (final int lineSegmentMPID in lineSegmentMPIDs) {
      final MPCommand removeLineSegmentCommand = elementEditController
          .getRemoveLineSegmentCommand(lineSegmentMPID);

      commandsList.add(removeLineSegmentCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveElementsFromDeltaOnCanvas({
    required Iterable<MPSelectedElement> mpSelectedElements,
    required Offset deltaOnCanvas,
    int? decimalPositions,
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveElementsFromReferenceElementExactPosition({
    required Iterable<MPSelectedElement> mpSelectedElements,
    required THElement referenceElement,
    required THPositionPart referenceElementFinalPosition,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveElements,
  }) {
    final List<MPCommand> commandsList = [];
    final int referenceElementMPID = referenceElement.mpID;
    late final Offset deltaOnCanvas;
    int? referenceElementParentMPID;

    if (referenceElement is THPoint) {
      deltaOnCanvas =
          referenceElementFinalPosition.coordinates -
          referenceElement.position.coordinates;
    } else if (referenceElement is THLineSegment) {
      deltaOnCanvas =
          referenceElementFinalPosition.coordinates -
          referenceElement.endPoint.coordinates;
      referenceElementParentMPID = referenceElement.parentMPID;
    } else {
      throw ArgumentError(
        'Unsupported referenceElement type in MPCommandFactory.moveElementsFromReferenceElementExactPosition',
      );
    }

    for (final MPSelectedElement mpSelectedElement in mpSelectedElements) {
      final THElement element = mpSelectedElement.originalElementClone;
      final MPCommand moveCommand;

      switch (element) {
        case THPoint _:
          moveCommand = (element.mpID == referenceElementMPID)
              ? MPMovePointCommand(
                  pointMPID: element.mpID,
                  originalPosition: element.position,
                  modifiedPosition: referenceElementFinalPosition,
                  descriptionType: descriptionType,
                )
              : MPMovePointCommand.fromDeltaOnCanvas(
                  pointMPID: element.mpID,
                  originalPosition: element.position,
                  deltaOnCanvas: deltaOnCanvas,
                );
        case THLine _:
          moveCommand = (element.mpID == referenceElementParentMPID)
              ? MPMoveLineCommand.fromLineSegmentExactPosition(
                  lineMPID: element.mpID,
                  originalLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
                      .originalLineSegmentsMapClone,
                  referenceLineSegment: referenceElement as THLineSegment,
                  referenceLineSegmentFinalPosition:
                      referenceElementFinalPosition,
                  descriptionType: descriptionType,
                )
              : MPMoveLineCommand.fromDeltaOnCanvas(
                  lineMPID: element.mpID,
                  originalLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
                      .originalLineSegmentsMapClone,
                  deltaOnCanvas: deltaOnCanvas,
                );
        case THArea _:
          moveCommand = (referenceElement is THLineSegment)
              ? MPMoveAreaCommand.fromLineSegmentExactPosition(
                  areaMPID: element.mpID,
                  originalLines:
                      (mpSelectedElement as MPSelectedArea).originalLines,
                  referenceLineSegment: referenceElement,
                  referenceLineSegmentFinalPosition:
                      referenceElementFinalPosition,
                  descriptionType: descriptionType,
                )
              : MPMoveAreaCommand.fromDeltaOnCanvas(
                  areaMPID: element.mpID,
                  originalLines:
                      (mpSelectedElement as MPSelectedArea).originalLines,
                  deltaOnCanvas: deltaOnCanvas,
                );
        default:
          throw ArgumentError(
            'Unsupported MPSelectedElement type in MPMultipleElementsCommand.moveElementsFromDelta',
          );
      }

      commandsList.add(moveCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveLineSegments({
    required Map<int, THLineSegment> originalElementsMap,
    required Map<int, THLineSegment> modifiedElementsMap,
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveLineSegmentsFromDeltaOnCanvas({
    required LinkedHashMap<int, THLineSegment> originalElementsMap,
    required Offset deltaOnCanvas,
    int? decimalPositions,
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
          moveLineSegmentCommand =
              MPMoveStraightLineSegmentCommand.fromDeltaOnCanvas(
                lineSegmentMPID: originalElementMPID,
                originalEndPointPosition: originalElement.endPoint,
                deltaOnCanvas: deltaOnCanvas,
                decimalPositions: decimalPositions,
              );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand =
              MPMoveBezierLineSegmentCommand.fromDeltaOnCanvas(
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveLineSegmentsFromLineSegmentExactPosition({
    required LinkedHashMap<int, THLineSegment> originalElementsMap,
    required THPositionPart referenceLineSegmentFinalPosition,
    required THLineSegment referenceLineSegment,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLineSegments,
  }) {
    final List<MPCommand> commandsList = [];
    final int referenceLineSegmentMPID = referenceLineSegment.mpID;
    final Offset deltaOnCanvas =
        referenceLineSegmentFinalPosition.coordinates -
        referenceLineSegment.endPoint.coordinates;

    for (final entry in originalElementsMap.entries) {
      final int originalElementMPID = entry.key;
      final THLineSegment originalElement = entry.value;
      final MPCommand moveLineSegmentCommand;

      switch (originalElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand =
              (originalElementMPID == referenceLineSegmentMPID)
              ? MPMoveStraightLineSegmentCommand(
                  lineSegmentMPID: referenceLineSegmentMPID,
                  originalEndPointPosition: originalElement.endPoint,
                  modifiedEndPointPosition: referenceLineSegmentFinalPosition,
                  descriptionType: descriptionType,
                )
              : MPMoveStraightLineSegmentCommand.fromDeltaOnCanvas(
                  lineSegmentMPID: originalElementMPID,
                  originalEndPointPosition: originalElement.endPoint,
                  deltaOnCanvas: deltaOnCanvas,
                );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand =
              (originalElementMPID == referenceLineSegmentMPID)
              ? MPMoveBezierLineSegmentCommand.fromEndPointExactPosition(
                  lineSegmentMPID: referenceLineSegmentMPID,
                  originalEndPointPosition: referenceLineSegment.endPoint,
                  originalControlPoint1Position:
                      (referenceLineSegment as THBezierCurveLineSegment)
                          .controlPoint1,
                  originalControlPoint2Position:
                      referenceLineSegment.controlPoint2,
                  lineSegmentFinalPosition: referenceLineSegmentFinalPosition,
                  descriptionType: descriptionType,
                )
              : MPMoveBezierLineSegmentCommand.fromDeltaOnCanvas(
                  lineSegmentMPID: originalElementMPID,
                  originalEndPointPosition: originalElement.endPoint,
                  originalControlPoint1Position: originalElement.controlPoint1,
                  originalControlPoint2Position: originalElement.controlPoint2,
                  deltaOnCanvas: deltaOnCanvas,
                );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand editLinesSegmentType({
    required List<THLineSegment> changedLineSegments,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editLineSegmentsType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final THLineSegment changedLineSegment in changedLineSegments) {
      final MPCommand setLineSegmentTypeCommand = MPEditLineSegmentCommand(
        originalLineSegment: thFile.lineSegmentByMPID(changedLineSegment.mpID),
        newLineSegment: changedLineSegment,
        descriptionType: descriptionType,
      );

      commandsList.add(setLineSegmentTypeCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveLinesFromDeltaOnCanvas({
    required Iterable<MPSelectedLine> lines,
    required Offset deltaOnCanvas,
    int? decimalPositions,
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

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand moveLinesFromLineSegmentExactPosition({
    required Iterable<MPSelectedLine> lines,
    required THLineSegment referenceLineSegment,
    required THPositionPart referenceLineSegmentFinalPosition,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLines,
  }) {
    final List<MPCommand> commandsList = [];
    final int referenceLineMPID = referenceLineSegment.parentMPID;
    final Offset deltaOnCanvas =
        referenceLineSegmentFinalPosition.coordinates -
        referenceLineSegment.endPoint.coordinates;

    for (final MPSelectedLine line in lines) {
      final MPCommand moveLineCommand = (line.mpID == referenceLineMPID)
          ? MPMoveLineCommand.fromLineSegmentExactPosition(
              lineMPID: referenceLineMPID,
              originalLineSegmentsMap: line.originalLineSegmentsMapClone,
              referenceLineSegment: referenceLineSegment,
              referenceLineSegmentFinalPosition:
                  referenceLineSegmentFinalPosition,
              descriptionType: descriptionType,
            )
          : MPMoveLineCommand.fromDeltaOnCanvas(
              lineMPID: line.mpID,
              originalLineSegmentsMap: line.originalLineSegmentsMapClone,
              deltaOnCanvas: deltaOnCanvas,
              descriptionType: descriptionType,
            );

      commandsList.add(moveLineCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand editAreasType({
    required List<int> areaMPIDs,
    required THAreaType newAreaType,
    required String unknownPLAType,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editAreasType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int areaMPID in areaMPIDs) {
      final MPCommand editAreaTypeCommand = MPEditAreaTypeCommand(
        areaMPID: areaMPID,
        newAreaType: newAreaType,
        unknownPLAType: unknownPLAType,
        descriptionType: descriptionType,
      );

      commandsList.add(editAreaTypeCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand editLinesType({
    required List<int> lineMPIDs,
    required THLineType newLineType,
    required String unknownPLAType,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editLinesType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int lineMPID in lineMPIDs) {
      final MPCommand editLineTypeCommand = MPEditLineTypeCommand(
        lineMPID: lineMPID,
        newLineType: newLineType,
        unknownPLAType: unknownPLAType,
        descriptionType: descriptionType,
      );

      commandsList.add(editLineTypeCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }

  static MPCommand editPointsType({
    required List<int> pointMPIDs,
    required THPointType newPointType,
    required String unknownPLAType,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editPointsType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int pointMPID in pointMPIDs) {
      final MPCommand editPointTypeCommand = MPEditPointTypeCommand(
        pointMPID: pointMPID,
        newPointType: newPointType,
        unknownPLAType: unknownPLAType,
        descriptionType: descriptionType,
      );

      commandsList.add(editPointTypeCommand);
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
            descriptionType: descriptionType,
          );
  }
}
