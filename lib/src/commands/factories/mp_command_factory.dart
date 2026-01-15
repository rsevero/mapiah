import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
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
  static MPCommand _actualRemoveLineSegmentFromExisting({
    required int toRemoveLineSegmentMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final THLine parentLine = thFile.lineByMPID(
      thFile.lineSegmentByMPID(toRemoveLineSegmentMPID).parentMPID,
    );
    final int lineSegmentsCountInParentLine = parentLine
        .getLineSegmentMPIDs(thFile)
        .length;

    if (lineSegmentsCountInParentLine < 3) {
      return removeLineFromExisting(
        existingLineMPID: parentLine.mpID,
        isInteractiveLineCreation: false,
        thFile: thFile,
        descriptionType: descriptionType,
      );
    } else {
      final MPCommand? preCommand = removeEmptyLinesAfterCommand(
        elementMPID: toRemoveLineSegmentMPID,
        thFile: thFile,
        descriptionType: descriptionType,
      );

      return MPRemoveLineSegmentCommand(
        lineSegmentMPID: toRemoveLineSegmentMPID,
        preCommand: preCommand,
      );
    }
  }

  static MPAddAreaBorderTHIDCommand addAreaBorderTHIDFromExisting({
    required THAreaBorderTHID existingAreaBorderTHID,
    int? areaBorderTHIDPositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddAreaBorderTHIDCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingAreaBorderTHID.parent(
      thFile: thFile,
    );

    areaBorderTHIDPositionInParent =
        areaBorderTHIDPositionInParent ??
        parent.getChildPosition(existingAreaBorderTHID);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: areaBorderTHIDPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID: existingAreaBorderTHID,
      areaBorderTHIDPositionInParent: areaBorderTHIDPositionInParent,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPAddAreaCommand addAreaFromExisting({
    required THArea existingArea,
    int? areaPositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddAreaCommand.defaultDescriptionType,
  }) {
    final List<THElement> areaChildren = existingArea
        .getChildren(thFile)
        .toList();
    final THIsParentMixin parent = existingArea.parent(thFile: thFile);

    areaPositionInParent =
        areaPositionInParent ?? parent.getChildPosition(existingArea);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: areaPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddAreaCommand.forCWJM(
      newArea: existingArea,
      areaChildren: areaChildren,
      areaPositionInParent: areaPositionInParent,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPAddElementCommand addElementFromExisting({
    required THElement existingElement,
    int? elementPositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddElementCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingElement.parent(thFile: thFile);

    elementPositionInParent =
        elementPositionInParent ?? parent.getChildPosition(existingElement);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: elementPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddElementCommand.forCWJM(
      newElement: existingElement,
      elementPositionInParent: elementPositionInParent,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPCommand addElements({
    required List<THElement> elements,
    required THFile thFile,
    int positionInParent = mpAddChildAtEndOfParentChildrenList,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.addElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final THElement element in elements) {
      final MPCommand addCommand;

      switch (element) {
        case THArea _:
          addCommand = MPAddAreaCommand.forCWJM(
            newArea: element,
            areaChildren: element.getChildren(thFile).toList(),
            areaPositionInParent: positionInParent,
            posCommand: null,
            descriptionType: descriptionType,
          );
        case THAreaBorderTHID _:
          addCommand = MPAddAreaBorderTHIDCommand.forCWJM(
            newAreaBorderTHID: element,
            areaBorderTHIDPositionInParent: positionInParent,
            posCommand: null,
          );
        case THEmptyLine _:
          addCommand = MPAddEmptyLineCommand.forCWJM(
            newEmptyLine: element,
            emptyLinePositionInParent: positionInParent,
          );
        case THLine _:
          addCommand = MPAddLineCommand.forCWJM(
            newLine: element,
            linePositionInParent: positionInParent,
            lineChildren: element.getChildren(thFile).toList(),
            preCommand: null,
            posCommand: null,
          );
        case THLineSegment _:
          addCommand = MPAddLineSegmentCommand.forCWJM(
            newLineSegment: element,
            lineSegmentPositionInParent: positionInParent,
            posCommand: null,
          );
        case THPoint _:
          addCommand = MPAddPointCommand.forCWJM(
            newPoint: element,
            pointPositionInParent: positionInParent,
            posCommand: null,
          );
        case THScrap _:
          addCommand = MPAddScrapCommand(
            newScrap: element,
            scrapPositionInParent: positionInParent,
            scrapChildren: element.getChildren(thFile).toList(),
            thFile: thFile,
            posCommand: null,
          );
        case THXTherionImageInsertConfig _:
          addCommand = MPAddXTherionImageInsertConfigCommand.forCWJM(
            newImageInsertConfig: element,
            xTherionImageInsertConfigPositionInParent: positionInParent,
            posCommand: null,
          );
        default:
          addCommand = MPAddElementCommand.forCWJM(
            newElement: element,
            elementPositionInParent: positionInParent,
            posCommand: null,
          );
      }

      commandsList.add(addCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
    );
  }

  static MPCommand? addEmptyLinesAfterCommand({
    required THFile thFile,
    required THIsParentMixin parent,
    required int positionInParent,
    required MPCommandDescriptionType descriptionType,
  }) {
    final List<int> emptyLinesAfter = MPEditElementAux.getEmptyLinesAfter(
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
      final MPCommand addEmptyLineCommand = addEmptyLineFromExisting(
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

  static MPAddEmptyLineCommand addEmptyLineFromExisting({
    required THEmptyLine existingEmptyLine,
    int? emptyLinePositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddEmptyLineCommand.defaultDescriptionType,
  }) {
    emptyLinePositionInParent =
        emptyLinePositionInParent ??
        existingEmptyLine
            .parent(thFile: thFile)
            .getChildPosition(existingEmptyLine);

    return MPAddEmptyLineCommand.forCWJM(
      newEmptyLine: existingEmptyLine,
      emptyLinePositionInParent: emptyLinePositionInParent,
      descriptionType: descriptionType,
    );
  }

  static MPAddLineCommand addLineFromExisting({
    required THLine existingLine,
    int? linePositionInParent,
    Offset? lineStartScreenPosition,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddLineCommand.defaultDescriptionType,
  }) {
    final List<THElement> lineChildren = existingLine
        .getChildren(thFile)
        .toList();
    final int existingLineMPID = existingLine.mpID;
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(existingLineMPID);
    final THIsParentMixin parent = existingLine.parent(thFile: thFile);
    final MPAddAreaBorderTHIDCommand? addAreaTHIDCommand;

    linePositionInParent =
        linePositionInParent ?? parent.getChildPosition(existingLine);

    if (areaMPID == null) {
      addAreaTHIDCommand = null;
    } else {
      final THArea area = thFile.areaByMPID(areaMPID);
      final THAreaBorderTHID? areaTHID = area.areaBorderByLineMPID(
        existingLineMPID,
        thFile,
      );

      if (areaTHID == null) {
        addAreaTHIDCommand = null;
      } else {
        addAreaTHIDCommand = MPCommandFactory.addAreaBorderTHIDFromExisting(
          existingAreaBorderTHID: areaTHID,
          thFile: thFile,
          descriptionType: descriptionType,
        );
      }
    }

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: linePositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddLineCommand.forCWJM(
      newLine: existingLine,
      linePositionInParent: linePositionInParent,
      lineChildren: lineChildren,
      lineStartScreenPosition: lineStartScreenPosition,
      addAreaTHIDCommand: addAreaTHIDCommand,
      preCommand: null,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPAddLineSegmentCommand addLineSegmentFromExisting({
    required THLineSegment existingLineSegment,
    int? lineSegmentPositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddLineSegmentCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingLineSegment.parent(thFile: thFile);

    lineSegmentPositionInParent =
        lineSegmentPositionInParent ??
        parent.getChildPosition(existingLineSegment);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: lineSegmentPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddLineSegmentCommand.forCWJM(
      newLineSegment: existingLineSegment,
      lineSegmentPositionInParent: lineSegmentPositionInParent,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPCommand addLineToArea({
    required THArea area,
    required THLine line,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.addAreaBorderTHID,
  }) {
    final List<MPCommand> commandsList = [];
    final String lineTHID;

    if (line.hasOption(THCommandOptionType.id)) {
      lineTHID =
          (line.getOption(THCommandOptionType.id) as THIDCommandOption).thID;
    } else {
      final String areaTHID;

      if (area.hasOption(THCommandOptionType.id)) {
        areaTHID =
            (area.getOption(THCommandOptionType.id) as THIDCommandOption).thID;
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
          toOption: areaTHIDOption,
        );

        commandsList.add(addAreaTHIDCommand);
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
        toOption: lineTHIDOption,
      );

      commandsList.add(addLineTHIDCommand);
      lineTHID = newLineTHID;
    }

    final THAreaBorderTHID areaBorderTHID = THAreaBorderTHID(
      parentMPID: area.mpID,
      thID: lineTHID,
    );
    final MPCommand addAreaBorderTHIDCommand = MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID: areaBorderTHID,
      posCommand: null,
    );

    commandsList.add(addAreaBorderTHIDCommand);

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
    );
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
    final MPAddPointCommand command = MPAddPointCommand(
      newPoint: newPoint,
      posCommand: null,
    );

    return command;
  }

  static MPAddPointCommand addPointFromExisting({
    required THPoint existingPoint,
    int? pointPositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddPointCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingPoint.parent(thFile: thFile);

    pointPositionInParent =
        pointPositionInParent ?? parent.getChildPosition(existingPoint);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: pointPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddPointCommand.forCWJM(
      newPoint: existingPoint,
      pointPositionInParent: pointPositionInParent,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
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
      thFile: thFile,
      posCommand: null,
    );

    return addScrapCommandForNewScrap;
  }

  static MPCommand addScrapChildren({
    required THScrap scrap,
    required THFile thFile,
  }) {
    final List<THElement> scrapChildrenAsElements = scrap
        .getChildren(thFile)
        .toList();
    final MPCommand scrapChildrenCommand = MPCommandFactory.addElements(
      elements: scrapChildrenAsElements,
      thFile: thFile,
      positionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    return scrapChildrenCommand;
  }

  static MPAddScrapCommand addSScrapFromExisting({
    required THScrap existingScrap,
    int? scrapPositionInParent,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPAddScrapCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingScrap.parent(thFile: thFile);

    scrapPositionInParent =
        scrapPositionInParent ?? parent.getChildPosition(existingScrap);

    final MPCommand addScrapChildrenCommand = addScrapChildren(
      scrap: existingScrap,
      thFile: thFile,
    );
    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: scrapPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddScrapCommand.forCWJM(
      newScrap: existingScrap,
      scrapPositionInParent: scrapPositionInParent,
      addScrapChildrenCommand: addScrapChildrenCommand,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
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
    final Rect fileBoundingBox = thFile.getBoundingBox(th2FileEditController)!;
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
          posCommand: null,
        );

    return addImageCommand;
  }

  static MPAddXTherionImageInsertConfigCommand
  addXTherionImageInsertConfigFromExisting({
    required THXTherionImageInsertConfig existingImageInsertConfig,
    required THFile thFile,
    int? xTherionImageInsertConfigPositionInParent,
    MPCommandDescriptionType descriptionType =
        MPAddXTherionImageInsertConfigCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingImageInsertConfig.parent(
      thFile: thFile,
    );

    xTherionImageInsertConfigPositionInParent =
        xTherionImageInsertConfigPositionInParent ??
        parent.getChildPosition(existingImageInsertConfig);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      thFile: thFile,
      parent: parent,
      positionInParent: xTherionImageInsertConfigPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddXTherionImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: existingImageInsertConfig,
      xTherionImageInsertConfigPositionInParent:
          xTherionImageInsertConfigPositionInParent,
      posCommand: posCommand,
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

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
    );
  }

  static MPCommand editLineSegmentsType({
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

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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
            fromPosition: element.position,
            deltaOnCanvas: deltaOnCanvas,
            decimalPositions: decimalPositions,
            fromOriginalLineInTH2File: element.originalLineInTH2File,
          );
        case THLine _:
          moveCommand = MPMoveLineCommand.fromDeltaOnCanvas(
            lineMPID: element.mpID,
            fromLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
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

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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
                  fromPosition: element.position,
                  toPosition: referenceElementFinalPosition,
                  fromOriginalLineInTH2File: element.originalLineInTH2File,
                  toOriginalLineInTH2File: '',
                  descriptionType: descriptionType,
                )
              : MPMovePointCommand.fromDeltaOnCanvas(
                  pointMPID: element.mpID,
                  fromPosition: element.position,
                  deltaOnCanvas: deltaOnCanvas,
                  fromOriginalLineInTH2File: element.originalLineInTH2File,
                );
        case THLine _:
          moveCommand = (element.mpID == referenceElementParentMPID)
              ? MPMoveLineCommand.fromLineSegmentExactPosition(
                  lineMPID: element.mpID,
                  fromLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
                      .originalLineSegmentsMapClone,
                  referenceLineSegment: referenceElement as THLineSegment,
                  referenceLineSegmentFinalPosition:
                      referenceElementFinalPosition,
                  descriptionType: descriptionType,
                )
              : MPMoveLineCommand.fromDeltaOnCanvas(
                  lineMPID: element.mpID,
                  fromLineSegmentsMap: (mpSelectedElement as MPSelectedLine)
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

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
    );
  }

  static MPCommand moveLineSegments({
    required Map<int, THLineSegment> fromLineSegmentsMap,
    required Map<int, THLineSegment> toLineSegmentsMap,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLineSegments,
  }) {
    final List<MPCommand> commandsList = [];

    for (final entry in fromLineSegmentsMap.entries) {
      final int elementMPID = entry.key;
      final THLineSegment fromElement = entry.value;
      final THLineSegment toElement = toLineSegmentsMap[elementMPID]!;
      final MPCommand moveLineSegmentCommand;

      switch (fromElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand = MPMoveStraightLineSegmentCommand(
            lineSegmentMPID: elementMPID,
            fromEndPointPosition: fromElement.endPoint,
            toEndPointPosition: toElement.endPoint,
            fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
            toOriginalLineInTH2File: toElement.originalLineInTH2File,
          );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand = MPMoveBezierLineSegmentCommand(
            lineSegmentMPID: elementMPID,
            fromEndPointPosition: fromElement.endPoint,
            toEndPointPosition: toElement.endPoint,
            fromControlPoint1Position: fromElement.controlPoint1,
            toControlPoint1Position:
                (toElement as THBezierCurveLineSegment).controlPoint1,
            fromControlPoint2Position: fromElement.controlPoint2,
            toControlPoint2Position: toElement.controlPoint2,
            fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
            toOriginalLineInTH2File: toElement.originalLineInTH2File,
          );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
    );
  }

  static MPCommand moveLineSegmentsFromDeltaOnCanvas({
    required LinkedHashMap<int, THLineSegment> fromElementsMap,
    required Offset deltaOnCanvas,
    int? decimalPositions,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.moveLineSegments,
  }) {
    final List<MPCommand> commandsList = [];

    for (final entry in fromElementsMap.entries) {
      final int elementMPID = entry.key;
      final THLineSegment fromElement = entry.value;
      final MPCommand moveLineSegmentCommand;

      switch (fromElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand =
              MPMoveStraightLineSegmentCommand.fromDeltaOnCanvas(
                lineSegmentMPID: elementMPID,
                fromEndPointPosition: fromElement.endPoint,
                deltaOnCanvas: deltaOnCanvas,
                decimalPositions: decimalPositions,
                fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
              );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand =
              MPMoveBezierLineSegmentCommand.fromDeltaOnCanvas(
                lineSegmentMPID: elementMPID,
                fromEndPointPosition: fromElement.endPoint,
                fromControlPoint1Position: fromElement.controlPoint1,
                fromControlPoint2Position: fromElement.controlPoint2,
                deltaOnCanvas: deltaOnCanvas,
                decimalPositions: decimalPositions,
                fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
              );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
    );
  }

  static MPCommand moveLineSegmentsFromLineSegmentExactPosition({
    required LinkedHashMap<int, THLineSegment> fromElementsMap,
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

    for (final entry in fromElementsMap.entries) {
      final int elementMPID = entry.key;
      final THLineSegment fromElement = entry.value;
      final MPCommand moveLineSegmentCommand;

      switch (fromElement) {
        case THStraightLineSegment _:
          moveLineSegmentCommand = (elementMPID == referenceLineSegmentMPID)
              ? MPMoveStraightLineSegmentCommand(
                  lineSegmentMPID: referenceLineSegmentMPID,
                  fromEndPointPosition: fromElement.endPoint,
                  toEndPointPosition: referenceLineSegmentFinalPosition,
                  fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
                  toOriginalLineInTH2File: '',
                  descriptionType: descriptionType,
                )
              : MPMoveStraightLineSegmentCommand.fromDeltaOnCanvas(
                  lineSegmentMPID: elementMPID,
                  fromEndPointPosition: fromElement.endPoint,
                  deltaOnCanvas: deltaOnCanvas,
                  fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
                  descriptionType: descriptionType,
                );
        case THBezierCurveLineSegment _:
          moveLineSegmentCommand = (elementMPID == referenceLineSegmentMPID)
              ? MPMoveBezierLineSegmentCommand.fromEndPointExactPosition(
                  lineSegmentMPID: referenceLineSegmentMPID,
                  fromEndPointPosition: referenceLineSegment.endPoint,
                  fromControlPoint1Position:
                      (referenceLineSegment as THBezierCurveLineSegment)
                          .controlPoint1,
                  fromControlPoint2Position: referenceLineSegment.controlPoint2,
                  lineSegmentFinalPosition: referenceLineSegmentFinalPosition,
                  fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
                  descriptionType: descriptionType,
                )
              : MPMoveBezierLineSegmentCommand.fromDeltaOnCanvas(
                  lineSegmentMPID: elementMPID,
                  fromEndPointPosition: fromElement.endPoint,
                  fromControlPoint1Position: fromElement.controlPoint1,
                  fromControlPoint2Position: fromElement.controlPoint2,
                  deltaOnCanvas: deltaOnCanvas,
                  fromOriginalLineInTH2File: fromElement.originalLineInTH2File,
                  descriptionType: descriptionType,
                );
        default:
          throw ArgumentError(
            'Unsupported THLineSegment type in MPMultipleElementsCommand.moveLineSegments',
          );
      }

      commandsList.add(moveLineSegmentCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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
        fromLineSegmentsMap: line.originalLineSegmentsMapClone,
        deltaOnCanvas: deltaOnCanvas,
        decimalPositions: decimalPositions,
        descriptionType: descriptionType,
      );

      commandsList.add(moveLineCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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
              fromLineSegmentsMap: line.originalLineSegmentsMapClone,
              referenceLineSegment: referenceLineSegment,
              referenceLineSegmentFinalPosition:
                  referenceLineSegmentFinalPosition,
              descriptionType: descriptionType,
            )
          : MPMoveLineCommand.fromDeltaOnCanvas(
              lineMPID: line.mpID,
              fromLineSegmentsMap: line.originalLineSegmentsMapClone,
              deltaOnCanvas: deltaOnCanvas,
              descriptionType: descriptionType,
            );

      commandsList.add(moveLineCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
    );
  }

  static MPCommand multipleCommandsFromList({
    required List<MPCommand> commandsList,
    required MPCommandDescriptionType descriptionType,
    required MPMultipleElementsCommandCompletionType completionType,
  }) {
    if (commandsList.isEmpty) {
      throw ArgumentError(
        'commandsList cannot be empty in MPCommandFactory.multipleCommandsFromList',
      );
    }

    return (commandsList.length == 1)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType: completionType,
            descriptionType: descriptionType,
          );
  }

  static MPCommand removeAreaBorderTHIDFromExisting({
    required int existingAreaBorderTHIDMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemoveAreaBorderTHIDCommand.defaultDescriptionType,
  }) {
    final THAreaBorderTHID areaBorderTHID = thFile.areaBorderTHIDByMPID(
      existingAreaBorderTHIDMPID,
    );
    final THArea parentArea = thFile.areaByMPID(areaBorderTHID.parentMPID);
    final int areaBorderSiblingsCount = parentArea
        .getAreaBorderTHIDMPIDs(thFile)
        .length;

    if (areaBorderSiblingsCount == 1) {
      return removeAreaFromExisting(
        existingAreaMPID: parentArea.mpID,
        thFile: thFile,
        descriptionType: descriptionType,
      );
    } else if (areaBorderSiblingsCount > 1) {
      final MPCommand? preCommand = removeEmptyLinesAfterCommand(
        elementMPID: existingAreaBorderTHIDMPID,
        thFile: thFile,
        descriptionType: descriptionType,
      );

      return MPRemoveAreaBorderTHIDCommand(
        areaBorderTHIDMPID: existingAreaBorderTHIDMPID,
        preCommand: preCommand,
        descriptionType: descriptionType,
      );
    } else {
      throw StateError(
        'AreaBorderTHID with MPID $existingAreaBorderTHIDMPID parent area has no areaBorderTHIDs.',
      );
    }
  }

  static MPRemoveAreaCommand removeAreaFromExisting({
    required int existingAreaMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemoveAreaCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingAreaMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );

    return MPRemoveAreaCommand.forCWJM(
      areaMPID: existingAreaMPID,
      preCommand: preCommand,
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
        parentMPID: parentMPID,
        attrName: attrName,
        plaOriginalTH2FileLine: thFile
            .elementByMPID(parentMPID)
            .originalLineInTH2File,
        descriptionType: descriptionType,
      );

      commandsList.add(removeAttrOptionFromElementCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
    );
  }

  static MPRemoveElementCommand removeElementFromExisting({
    required int existingElementMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemoveElementCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingElementMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );

    return MPRemoveElementCommand.forCWJM(
      elementMPID: existingElementMPID,
      preCommand: preCommand,
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
        case THElementType.area:
          removeCommand = removeAreaFromExisting(
            existingAreaMPID: mpID,
            thFile: thFile,
            descriptionType: descriptionType,
          );
        case THElementType.areaBorderTHID:
          removeCommand = MPCommandFactory.removeAreaBorderTHIDFromExisting(
            existingAreaBorderTHIDMPID: mpID,
            thFile: thFile,
            descriptionType: descriptionType,
          );
        case THElementType.emptyLine:
          removeCommand = MPRemoveEmptyLineCommand(emptyLineMPID: mpID);
        case THElementType.line:
          removeCommand = removeLineFromExisting(
            existingLineMPID: mpID,
            isInteractiveLineCreation: false,
            thFile: thFile,
            descriptionType: descriptionType,
          );
        case THElementType.lineSegment:
          removeCommand = removeLineSegmentFromExisting(
            toRemoveLineSegmentMPID: mpID,
            thFile: thFile,
            descriptionType: descriptionType,
          );
        case THElementType.point:
          removeCommand = removePointFromExisting(
            existingPointMPID: mpID,
            thFile: thFile,
            descriptionType: descriptionType,
          );
        case THElementType.scrap:
          removeCommand = removeScrapFromExisting(
            existingScrapMPID: mpID,
            thFile: thFile,
          );
        case THElementType.xTherionImageInsertConfig:
          removeCommand = removeXTherionImageInsertConfigFromExisting(
            existingXTherionImageInsertConfigMPID: mpID,
            thFile: thFile,
            descriptionType: descriptionType,
          );
        default:
          removeCommand = removeElementFromExisting(
            existingElementMPID: mpID,
            thFile: thFile,
            descriptionType: descriptionType,
          );
      }

      commandsList.add(removeCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
    );
  }

  static MPCommand? removeEmptyLinesAfterCommand({
    required int elementMPID,
    required THFile thFile,
    required MPCommandDescriptionType descriptionType,
  }) {
    final THElement element = thFile.elementByMPID(elementMPID);
    final THIsParentMixin parent = element.parent(thFile: thFile);
    final List<int> emptyLinesAfter = MPEditElementAux.getEmptyLinesAfter(
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

  static MPRemoveLineCommand removeLineFromExisting({
    required int existingLineMPID,
    required bool isInteractiveLineCreation,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemoveLineCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingLineMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );
    final MPCommand? posCommand;
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(existingLineMPID);

    if (areaMPID == null) {
      posCommand = null;
    } else {
      final THArea area = thFile.areaByMPID(areaMPID);
      final THAreaBorderTHID? areaTHID = area.areaBorderByLineMPID(
        existingLineMPID,
        thFile,
      );

      if (areaTHID == null) {
        throw StateError(
          'Line with MPID $existingLineMPID is part of area with MPID $areaMPID but no areaBorderTHID found for it at MPCommandFactory.removeLineFromExisting().',
        );
      } else {
        posCommand = MPCommandFactory.removeAreaBorderTHIDFromExisting(
          existingAreaBorderTHIDMPID: areaTHID.mpID,
          thFile: thFile,
          descriptionType: descriptionType,
        );
      }
    }

    return MPRemoveLineCommand.forCWJM(
      lineMPID: existingLineMPID,
      isInteractiveLineCreation: isInteractiveLineCreation,
      preCommand: preCommand,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPCommand removeLineSegmentFromExisting({
    required int toRemoveLineSegmentMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final THLineSegment toRemoveLineSegment = thFile.lineSegmentByMPID(
      toRemoveLineSegmentMPID,
    );
    final THLine line = thFile.lineByMPID(toRemoveLineSegment.parentMPID);
    final List<THLineSegment> lineSegments = line.getLineSegments(thFile);
    final int lineSegmentIndex = lineSegments.indexOf(toRemoveLineSegment);

    if ((lineSegmentIndex == 0) ||
        (lineSegmentIndex == lineSegments.length - 1)) {
      return _actualRemoveLineSegmentFromExisting(
        toRemoveLineSegmentMPID: toRemoveLineSegmentMPID,
        thFile: thFile,
      );
    } else {
      final bool toRemoveLineSegmentIsStraight =
          toRemoveLineSegment is THStraightLineSegment;
      final THLineSegment nextLineSegment = lineSegments[lineSegmentIndex + 1];
      final bool nextLineSegmentIsStraight =
          nextLineSegment is THStraightLineSegment;

      if (toRemoveLineSegmentIsStraight && nextLineSegmentIsStraight) {
        return _actualRemoveLineSegmentFromExisting(
          toRemoveLineSegmentMPID: toRemoveLineSegmentMPID,
          thFile: thFile,
        );
      } else {
        final THLineSegment? previousLineSegment = line.getPreviousLineSegment(
          toRemoveLineSegment,
          thFile,
        );

        if (previousLineSegment == null) {
          throw Exception(
            'Error: previousLineSegment is null at TH2FileEditElementEditController.getRemoveLineSegmentCommand().',
          );
        }

        final THBezierCurveLineSegment toRemoveLineSegmentAsBezier =
            toRemoveLineSegmentIsStraight
            ? MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: previousLineSegment.endPoint.coordinates,
                straightLineSegment: toRemoveLineSegment,
              )
            : toRemoveLineSegment as THBezierCurveLineSegment;
        final THBezierCurveLineSegment nextLineSegmentBezier =
            nextLineSegmentIsStraight
            ? MPEditElementAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: toRemoveLineSegment.endPoint.coordinates,
                straightLineSegment: nextLineSegment,
              )
            : nextLineSegment as THBezierCurveLineSegment;
        final THBezierCurveLineSegment lineSegmentSubstitute =
            THBezierCurveLineSegment.forCWJM(
              mpID: nextLineSegmentBezier.mpID,
              parentMPID: nextLineSegmentBezier.parentMPID,
              controlPoint1: toRemoveLineSegmentAsBezier.controlPoint1,
              controlPoint2: nextLineSegmentBezier.controlPoint2,
              endPoint: nextLineSegmentBezier.endPoint,
              optionsMap: nextLineSegmentBezier.optionsMap,
              attrOptionsMap: nextLineSegmentBezier.attrOptionsMap,
              originalLineInTH2File: '',
            );

        return MPCommandFactory.removeLineSegmentWithSubstitution(
          toRemoveLineSegmentMPID: toRemoveLineSegmentMPID,
          lineSegmentSubstitute: lineSegmentSubstitute,
          thFile: thFile,
        );
      }
    }
  }

  static MPCommand removeLineSegments({
    required Iterable<int> lineSegmentMPIDs,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegments,
  }) {
    assert(lineSegmentMPIDs.isNotEmpty);

    final THLine parentLine = thFile.lineByMPID(
      thFile.lineSegmentByMPID(lineSegmentMPIDs.first).parentMPID,
    );
    final int lineSegmentsCountInParentLine = parentLine
        .getLineSegmentMPIDs(thFile)
        .length;
    final int remainingLineSegmentsCount =
        lineSegmentsCountInParentLine - lineSegmentMPIDs.length;

    if (remainingLineSegmentsCount < 2) {
      return removeLineFromExisting(
        existingLineMPID: parentLine.mpID,
        isInteractiveLineCreation: false,
        thFile: thFile,
        descriptionType: descriptionType,
      );
    } else {
      final List<MPCommand> commandsList = [];

      for (final int lineSegmentMPID in lineSegmentMPIDs) {
        final MPCommand removeLineSegmentCommand =
            removeLineSegmentFromExisting(
              toRemoveLineSegmentMPID: lineSegmentMPID,
              thFile: thFile,
              descriptionType: descriptionType,
            );

        commandsList.add(removeLineSegmentCommand);
      }

      return multipleCommandsFromList(
        commandsList: commandsList,
        descriptionType: descriptionType,
        completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
      );
    }
  }

  static MPCommand removeLineSegmentWithSubstitution({
    required int toRemoveLineSegmentMPID,
    required THLineSegment lineSegmentSubstitute,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final List<MPCommand> commandsList = [];

    final MPCommand removeLineSegmentCommand =
        _actualRemoveLineSegmentFromExisting(
          toRemoveLineSegmentMPID: toRemoveLineSegmentMPID,
          thFile: thFile,
          descriptionType: descriptionType,
        );
    final MPCommand editLineSegmentCommand = MPEditLineSegmentCommand(
      originalLineSegment: thFile.lineSegmentByMPID(lineSegmentSubstitute.mpID),
      newLineSegment: lineSegmentSubstitute,
    );

    commandsList.add(removeLineSegmentCommand);
    commandsList.add(editLineSegmentCommand);

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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
            descriptionType: descriptionType,
          );

      commandsList.add(removeOptionFromElementCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
    );
  }

  static MPRemovePointCommand removePointFromExisting({
    required int existingPointMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemovePointCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingPointMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );

    return MPRemovePointCommand.forCWJM(
      pointMPID: existingPointMPID,
      preCommand: preCommand,
      descriptionType: descriptionType,
    );
  }

  static MPRemoveScrapCommand removeScrapFromExisting({
    required int existingScrapMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemoveScrapCommand.defaultDescriptionType,
  }) {
    assert(existingScrapMPID > 0);

    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingScrapMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );

    return MPRemoveScrapCommand.forCWJM(
      scrapMPID: existingScrapMPID,
      preCommand: preCommand,
      descriptionType: descriptionType,
    );
  }

  static MPRemoveXTherionImageInsertConfigCommand
  removeXTherionImageInsertConfigFromExisting({
    required int existingXTherionImageInsertConfigMPID,
    required THFile thFile,
    MPCommandDescriptionType descriptionType =
        MPRemoveXTherionImageInsertConfigCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingXTherionImageInsertConfigMPID,
      thFile: thFile,
      descriptionType: descriptionType,
    );

    return MPRemoveXTherionImageInsertConfigCommand.forCWJM(
      xtherionImageInsertConfigMPID: existingXTherionImageInsertConfigMPID,
      preCommand: preCommand,
      descriptionType: descriptionType,
    );
  }

  static MPCommand setAttrOptionOnElements({
    required THAttrCommandOption toOption,
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
            toOption: toOption.copyWith(parentMPID: element.mpID),
            descriptionType: descriptionType,
          );

      commandsList.add(setOptionToElementCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
    );
  }

  static MPCommand setLineSegmentsType({
    required MPSelectedLineSegmentType selectedLineSegmentType,
    required THFile thFile,
    required Iterable<THLineSegment> originalLineSegments,
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
        MPCommandFactory.editLineSegmentsType(
          thFile: thFile,
          changedLineSegments: changedLineSegments,
        );

    return setLineSegmentTypeCommand;
  }

  static MPCommand setOptionOnElements({
    required THCommandOption toOption,
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

      final int parentMPID = element.mpID;
      final MPSetOptionToElementCommand setOptionToElementCommand =
          MPSetOptionToElementCommand(
            toOption: toOption.copyWith(parentMPID: parentMPID),
            descriptionType: descriptionType,
          );

      commandsList.add(setOptionToElementCommand);
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.optionsEdited,
    );
  }
}
