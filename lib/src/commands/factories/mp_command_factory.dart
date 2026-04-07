// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';
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
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:path/path.dart' as p;

class MPCommandFactory {
  static MPCommand _actualRemoveLineSegmentFromExisting({
    required int toRemoveLineSegmentMPID,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final THLine parentLine = th2File.lineByMPID(
      th2File.lineSegmentByMPID(toRemoveLineSegmentMPID).parentMPID,
    );
    final int lineSegmentsCountInParentLine = parentLine
        .getLineSegmentMPIDs(th2File)
        .length;

    if (lineSegmentsCountInParentLine < 3) {
      return removeLineFromExisting(
        existingLineMPID: parentLine.mpID,
        isInteractiveLineCreation: false,
        th2File: th2File,
        descriptionType: descriptionType,
      );
    } else {
      final MPCommand? preCommand = removeEmptyLinesAfterCommand(
        elementMPID: toRemoveLineSegmentMPID,
        th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddAreaBorderTHIDCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingAreaBorderTHID.parent(
      th2File: th2File,
    );

    areaBorderTHIDPositionInParent =
        areaBorderTHIDPositionInParent ??
        parent.getChildPosition(existingAreaBorderTHID);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddAreaCommand.defaultDescriptionType,
  }) {
    final List<THElement> areaChildren = existingArea
        .getChildren(th2File)
        .toList();
    final THIsParentMixin parent = existingArea.parent(th2File: th2File);

    areaPositionInParent =
        areaPositionInParent ?? parent.getChildPosition(existingArea);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddElementCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingElement.parent(th2File: th2File);

    elementPositionInParent =
        elementPositionInParent ?? parent.getChildPosition(existingElement);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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
    required TH2File th2File,
    int positionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
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
            areaChildren: element.getChildren(th2File).toList(),
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
            lineChildren: element.getChildren(th2File).toList(),
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
            scrapChildren: element.getChildren(th2File).toList(),
            th2File: th2File,
            posCommand: null,
          );
        case THXTherionImageInsertConfig _:
        case MPImageInsertConfig _:
          addCommand = MPAddImageInsertConfigCommand.forCWJM(
            newImageInsertConfig: element,
            imageInsertConfigPositionInParent: positionInParent,
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
    required TH2File th2File,
    required THIsParentMixin parent,
    required int positionInParent,
    required MPCommandDescriptionType descriptionType,
  }) {
    final List<int> emptyLinesAfter = MPElementEditAux.getEmptyLinesAfter(
      th2File: th2File,
      parent: parent,
      positionInParent: positionInParent,
    );

    if (emptyLinesAfter.isEmpty) {
      return null;
    }

    final List<MPCommand> addEmptyLinesAfterCommands = [];

    for (final int emptyLineMPID in emptyLinesAfter) {
      final THEmptyLine emptyLine = th2File.emptyLineByMPID(emptyLineMPID);
      final MPCommand addEmptyLineCommand = addEmptyLineFromExisting(
        existingEmptyLine: emptyLine,
        th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddEmptyLineCommand.defaultDescriptionType,
  }) {
    emptyLinePositionInParent =
        emptyLinePositionInParent ??
        existingEmptyLine
            .parent(th2File: th2File)
            .getChildPosition(existingEmptyLine);

    return MPAddEmptyLineCommand.forCWJM(
      newEmptyLine: existingEmptyLine,
      emptyLinePositionInParent: emptyLinePositionInParent,
      descriptionType: descriptionType,
    );
  }

  static MPAddLineCommand addLineFromStartEnd({
    required THLine line,
    required String type,
    required String subtype,
    required Offset start,
    required Offset end,
    required TH2FileEditController th2FileEditController,
    List<MPCommand>? posCommands,
    bool setUsedLinetype = true,
  }) {
    final int newLineMPID = line.mpID;
    final List<THElement> lineChildren = [];

    posCommands ??= [];

    lineChildren.add(
      MPElementEditAux.createStraightLineSegmentFromCanvasCoordinates(
        endPointCanvasCoordinates: start,
        lineMPID: newLineMPID,
        th2FileEditController: th2FileEditController,
      ),
    );
    lineChildren.add(
      MPElementEditAux.createStraightLineSegmentFromCanvasCoordinates(
        endPointCanvasCoordinates: end,
        lineMPID: newLineMPID,
        th2FileEditController: th2FileEditController,
      ),
    );
    lineChildren.add(THEndline(parentMPID: newLineMPID));

    MPCommand? posCommandSetSubtype;

    if (subtype.isNotEmpty) {
      final THCommandOption lineSubtypeOption = THSubtypeCommandOption(
        parentMPID: line.mpID,
        subtype: subtype,
      );

      posCommandSetSubtype = MPCommandFactory.setOptionOnElements(
        elements: [line],
        th2File: th2FileEditController.th2File,
        toOption: lineSubtypeOption,
      );

      posCommands.add(posCommandSetSubtype);
    }

    final MPCommand? posCommand = (posCommands.isEmpty)
        ? null
        : MPCommandFactory.multipleCommandsFromList(
            commandsList: posCommands,
            descriptionType: MPCommandDescriptionType.addLine,
            completionType:
                MPMultipleElementsCommandCompletionType.elementsEdited,
          );
    final MPAddLineCommand addLineCommand = MPAddLineCommand(
      newLine: line,
      lineChildren: lineChildren,
      preCommand: null,
      posCommand: posCommand,
    );

    if (setUsedLinetype) {
      th2FileEditController.elementEditController.setUsedLineType(
        lineType: type,
        lineSubtype: subtype,
      );
    }

    return addLineCommand;
  }

  static MPAddLineCommand addLineFromExisting({
    required THLine existingLine,
    int? linePositionInParent,
    Offset? lineStartScreenPosition,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddLineCommand.defaultDescriptionType,
  }) {
    final List<THElement> lineChildren = existingLine
        .getChildren(th2File)
        .toList();
    final int existingLineMPID = existingLine.mpID;
    final int? areaMPID = th2File.getAreaMPIDByLineMPID(existingLineMPID);
    final THIsParentMixin parent = existingLine.parent(th2File: th2File);
    final MPAddAreaBorderTHIDCommand? addAreaTHIDCommand;

    linePositionInParent =
        linePositionInParent ?? parent.getChildPosition(existingLine);

    if (areaMPID == null) {
      addAreaTHIDCommand = null;
    } else {
      final THArea area = th2File.areaByMPID(areaMPID);
      final THAreaBorderTHID? areaTHID = area.areaBorderByLineMPID(
        existingLineMPID,
        th2File,
      );

      if (areaTHID == null) {
        addAreaTHIDCommand = null;
      } else {
        addAreaTHIDCommand = MPCommandFactory.addAreaBorderTHIDFromExisting(
          existingAreaBorderTHID: areaTHID,
          th2File: th2File,
          descriptionType: descriptionType,
        );
      }
    }

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddLineSegmentCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingLineSegment.parent(th2File: th2File);

    lineSegmentPositionInParent =
        lineSegmentPositionInParent ??
        parent.getChildPosition(existingLineSegment);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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

  static MPCommand addTHIDToElement({
    required THElement element,
    required TH2File th2File,
    required String newTHID,
  }) {
    final THIDCommandOption thIDOption = THIDCommandOption.forCWJM(
      parentMPID: element.mpID,
      thID: newTHID,
      originalLineInTH2File: '',
    );
    final MPCommand addTHIDCommand = MPSetOptionToElementCommand(
      toOption: thIDOption,
    );

    return addTHIDCommand;
  }

  static MPCommand addLineToArea({
    required THArea area,
    required THLine line,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.addAreaBorderTHID,
  }) {
    final List<MPCommand> commandsList = [];
    final THArea effectiveArea = th2File.areaByMPID(area.mpID);

    String? lineTHID = MPCommandOptionAux.getID(line);

    if (lineTHID == null) {
      String? areaTHID = MPCommandOptionAux.getID(effectiveArea);

      if (areaTHID == null) {
        final String newAreaTHID = th2File.getNewTHID(
          element: effectiveArea,
          prefix: mpAreaTHIDPrefix,
        );
        final MPCommand addAreaTHIDCommand = addTHIDToElement(
          element: effectiveArea,
          th2File: th2File,
          newTHID: newAreaTHID,
        );

        commandsList.add(addAreaTHIDCommand);
        areaTHID = newAreaTHID;
      }

      final String lineTHIDPrefix = '$areaTHID-$mpLineTHIDPrefix';
      final String newLineTHID = th2File.getNewTHID(
        element: line,
        prefix: lineTHIDPrefix,
      );
      final MPCommand addLineTHIDCommand = addTHIDToElement(
        element: line,
        th2File: th2File,
        newTHID: newLineTHID,
      );

      commandsList.add(addLineTHIDCommand);
      lineTHID = newLineTHID;
    }

    final THAreaBorderTHID areaBorderTHID = THAreaBorderTHID(
      parentMPID: effectiveArea.mpID,
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
    required String pointSubtypeString,
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

    // Option commands (subtype + defaults) must run AFTER the point is added
    // to the file, so they are placed in posCommand rather than alongside the
    // add command inside MPMultipleElementsCommand.  posCommand is executed via
    // _execPreCreateUndoRedoCommand, which runs after _actualExecute.
    final List<MPCommand> optionCommandsList = [];

    if (THPointType.fromString(pointTypeString) == THPointType.station) {
      final String nextStationName = th2FileEditController.elementEditController
          .getAndReserveNextAvailableStationName();
      final THStationNameCommandOption stationNameOption =
          THStationNameCommandOption.fromStringWithParentMPID(
            parentMPID: newPoint.mpID,
            name: nextStationName,
          );

      optionCommandsList.add(
        MPSetOptionToElementCommand(toOption: stationNameOption),
      );
    }

    if (pointSubtypeString.trim().isNotEmpty) {
      final THCommandOption pointSubtypeOption = THSubtypeCommandOption(
        parentMPID: newPoint.mpID,
        subtype: pointSubtypeString.trim(),
      );

      optionCommandsList.add(
        MPSetOptionToElementCommand(toOption: pointSubtypeOption),
      );
    }

    final List<THCommandOption> defaultOptions = th2FileEditController
        .defaultOptionsController
        .getApplicableDefaults(
          elementType: THElementType.point,
          typeString: pointTypeString,
        );

    for (final THCommandOption defaultOption in defaultOptions) {
      if ((defaultOption.type == THCommandOptionType.subtype) ||
          ((defaultOption.type == THCommandOptionType.station) &&
              (THPointType.fromString(pointTypeString) ==
                  THPointType.station))) {
        continue;
      }
      optionCommandsList.add(
        MPSetOptionToElementCommand(
          toOption: defaultOption.copyWith(parentMPID: newPoint.mpID),
        ),
      );
    }

    final MPCommand? posCommand = optionCommandsList.isEmpty
        ? null
        : multipleCommandsFromList(
            commandsList: optionCommandsList,
            descriptionType: MPCommandDescriptionType.addPoint,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
          );

    return MPAddPointCommand(
      newPoint: newPoint,
      posCommand: posCommand,
      descriptionType: MPCommandDescriptionType.addPoint,
    );
  }

  static MPAddPointCommand addPointFromExisting({
    required THPoint existingPoint,
    int? pointPositionInParent,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddPointCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingPoint.parent(th2File: th2File);

    pointPositionInParent =
        pointPositionInParent ?? parent.getChildPosition(existingPoint);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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
    required TH2File th2File,
    List<THElement>? scrapChildren,
    List<THCommandOption>? scrapOptions,
  }) {
    final THScrap newScrap = THScrap(parentMPID: th2File.mpID, thID: thID);
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
      th2File: th2File,
      posCommand: null,
    );

    return addScrapCommandForNewScrap;
  }

  static MPCommand addScrapChildren({
    required THScrap scrap,
    required TH2File th2File,
  }) {
    final List<THElement> scrapChildrenAsElements = scrap
        .getChildren(th2File)
        .toList();
    final MPCommand scrapChildrenCommand = MPCommandFactory.addElements(
      elements: scrapChildrenAsElements,
      th2File: th2File,
      positionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    return scrapChildrenCommand;
  }

  static MPAddScrapCommand addSScrapFromExisting({
    required THScrap existingScrap,
    int? scrapPositionInParent,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPAddScrapCommand.defaultDescriptionType,
  }) {
    final THIsParentMixin parent = existingScrap.parent(th2File: th2File);

    scrapPositionInParent =
        scrapPositionInParent ?? parent.getChildPosition(existingScrap);

    final MPCommand addScrapChildrenCommand = addScrapChildren(
      scrap: existingScrap,
      th2File: th2File,
    );
    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
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

  static MPCommand addImageInsertConfig({
    required String imageFilename,
    required TH2FileEditController th2FileEditController,
  }) {
    final TH2File th2File = th2FileEditController.th2File;
    final String fromPath = p.dirname(th2File.filename);
    final String normalizedImageFilename = imageFilename.replaceAll(
      mpWindowsBackslashPair,
      mpWindowsForwardSlash,
    );
    final String normalizedFromPath = fromPath.replaceAll(
      mpWindowsBackslashPair,
      mpWindowsForwardSlash,
    );
    final String rawRelativeImagePath = p.posix.relative(
      normalizedImageFilename,
      from: normalizedFromPath,
    );
    final String relativeImagePath =
        (rawRelativeImagePath.startsWith('./') ||
            rawRelativeImagePath.startsWith('../'))
        ? rawRelativeImagePath
        : './$rawRelativeImagePath';
    final Rect fileBoundingBox = th2File.getBoundingBox(th2FileEditController)!;
    final THXTherionImageInsertConfig
    newImage = THXTherionImageInsertConfig.adjustPosition(
      parentMPID: th2File.mpID,
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
    final MPAddImageInsertConfigCommand addImageCommand =
        MPAddImageInsertConfigCommand(
          newImageInsertConfig: newImage,
          imageInsertConfigPositionInParent:
              mpAddChildAtEndOfParentChildrenList,
          posCommand: null,
        );

    return addImageCommand;
  }

  static MPAddImageInsertConfigCommand addImageInsertConfigFromExisting({
    required THElement existingImageInsertConfig,
    required TH2File th2File,
    int? imageInsertConfigPositionInParent,
    MPCommandDescriptionType descriptionType =
        MPAddImageInsertConfigCommand.defaultDescriptionType,
  }) {
    if ((existingImageInsertConfig is! THXTherionImageInsertConfig) &&
        (existingImageInsertConfig is! MPImageInsertConfig)) {
      throw ArgumentError(
        'MPCommandFactory.addImageInsertConfigFromExisting only supports image insert configs.',
      );
    }

    final THIsParentMixin parent = existingImageInsertConfig.parent(
      th2File: th2File,
    );

    imageInsertConfigPositionInParent =
        imageInsertConfigPositionInParent ??
        parent.getChildPosition(existingImageInsertConfig);

    final MPCommand? posCommand = addEmptyLinesAfterCommand(
      th2File: th2File,
      parent: parent,
      positionInParent: imageInsertConfigPositionInParent,
      descriptionType: descriptionType,
    );

    return MPAddImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: existingImageInsertConfig,
      imageInsertConfigPositionInParent: imageInsertConfigPositionInParent,
      posCommand: posCommand,
      descriptionType: descriptionType,
    );
  }

  static MPCommand editAreasTypeSubtype({
    required List<int> areaMPIDs,
    required String newAreaTypeSubtype,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editAreasTypeSubtype,
  }) {
    final List<MPCommand> commandsList = [];
    final ({String subtype, String type}) typeSubtype =
        MPCommandOptionAux.getPLATypeSubtypeRecord(newAreaTypeSubtype);
    final THAreaType newAreaType = THAreaType.fromString(typeSubtype.type);
    final String unknownPLAType = THAreaType.unknownPLATypeFromString(
      typeSubtype.type,
    );
    final bool setSubtype = typeSubtype.subtype.trim().isNotEmpty;

    for (final int areaMPID in areaMPIDs) {
      final MPCommand editAreaTypeCommand = MPEditAreaTypeCommand(
        areaMPID: areaMPID,
        newAreaType: newAreaType,
        unknownPLAType: unknownPLAType,
        descriptionType: descriptionType,
      );

      commandsList.add(editAreaTypeCommand);

      if (setSubtype) {
        final THSubtypeCommandOption newSubtypeOption = THSubtypeCommandOption(
          parentMPID: areaMPID,
          subtype: typeSubtype.subtype,
        );
        final MPCommand setAreaSubtypeCommand = MPSetOptionToElementCommand(
          toOption: newSubtypeOption,
        );

        commandsList.add(setAreaSubtypeCommand);
      } else {
        final THArea area = th2File.areaByMPID(areaMPID);

        if (area.hasOption(THCommandOptionType.subtype)) {
          final MPCommand removeSubtypeCommand =
              MPRemoveOptionFromElementCommand(
                parentMPID: areaMPID,
                optionType: THCommandOptionType.subtype,
              );

          commandsList.add(removeSubtypeCommand);
        }
      }
    }

    return multipleCommandsFromList(
      commandsList: commandsList,
      descriptionType: descriptionType,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editLineSegmentsType,
  }) {
    final List<MPCommand> commandsList = [];

    for (final THLineSegment changedLineSegment in changedLineSegments) {
      final MPCommand setLineSegmentTypeCommand = MPEditLineSegmentCommand(
        originalLineSegment: th2File.lineSegmentByMPID(changedLineSegment.mpID),
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

  static MPCommand editLinesTypeSubtype({
    required List<int> lineMPIDs,
    required String newLineTypeSubtype,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editLinesTypeSubtype,
  }) {
    final List<MPCommand> commandsList = [];
    final ({String subtype, String type}) typeSubtype =
        MPCommandOptionAux.getPLATypeSubtypeRecord(newLineTypeSubtype);
    final THLineType newLineType = THLineType.fromString(typeSubtype.type);
    final String unknownPLAType = THLineType.unknownPLATypeFromString(
      typeSubtype.type,
    );
    final bool setSubtype = typeSubtype.subtype.trim().isNotEmpty;

    for (final int lineMPID in lineMPIDs) {
      final MPCommand editLineTypeCommand = MPEditLineTypeCommand(
        lineMPID: lineMPID,
        newLineType: newLineType,
        unknownPLAType: unknownPLAType,
        descriptionType: descriptionType,
      );

      commandsList.add(editLineTypeCommand);

      if (setSubtype) {
        final THSubtypeCommandOption newSubtypeOption = THSubtypeCommandOption(
          parentMPID: lineMPID,
          subtype: typeSubtype.subtype,
        );
        final MPCommand setLineSubtypeCommand = MPSetOptionToElementCommand(
          toOption: newSubtypeOption,
        );

        commandsList.add(setLineSubtypeCommand);
      } else {
        final THLine line = th2File.lineByMPID(lineMPID);

        if (line.hasOption(THCommandOptionType.subtype)) {
          final MPCommand removeSubtypeCommand =
              MPRemoveOptionFromElementCommand(
                parentMPID: lineMPID,
                optionType: THCommandOptionType.subtype,
              );

          commandsList.add(removeSubtypeCommand);
        }
      }
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

  static MPCommand editPointsTypeSubtype({
    required List<int> pointMPIDs,
    required String newPointTypeSubtype,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.editPointsTypeSubtype,
  }) {
    final List<MPCommand> commandsList = [];
    final ({String subtype, String type}) typeSubtype =
        MPCommandOptionAux.getPLATypeSubtypeRecord(newPointTypeSubtype);
    final THPointType newPointType = THPointType.fromString(typeSubtype.type);
    final String unknownPLAType = THPointType.unknownPLATypeFromString(
      typeSubtype.type,
    );
    final bool setSubtype = typeSubtype.subtype.trim().isNotEmpty;

    for (final int pointMPID in pointMPIDs) {
      final MPCommand editPointTypeCommand = MPEditPointTypeCommand(
        pointMPID: pointMPID,
        newPointType: newPointType,
        unknownPLAType: unknownPLAType,
        descriptionType: descriptionType,
      );

      commandsList.add(editPointTypeCommand);

      if (setSubtype) {
        final THSubtypeCommandOption newSubtypeOption = THSubtypeCommandOption(
          parentMPID: pointMPID,
          subtype: typeSubtype.subtype,
        );
        final MPCommand setPointSubtypeCommand = MPSetOptionToElementCommand(
          toOption: newSubtypeOption,
        );

        commandsList.add(setPointSubtypeCommand);
      } else {
        final THPoint point = th2File.pointByMPID(pointMPID);

        if (point.hasOption(THCommandOptionType.subtype)) {
          final MPCommand removeSubtypeCommand =
              MPRemoveOptionFromElementCommand(
                parentMPID: pointMPID,
                optionType: THCommandOptionType.subtype,
              );

          commandsList.add(removeSubtypeCommand);
        }
      }
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
        // ? commandsList.first.copyWith(descriptionType: descriptionType)
        ? commandsList.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commandsList,
            completionType: completionType,
            descriptionType: descriptionType,
          );
  }

  static MPCommand removeAreaBorderTHIDFromExisting({
    required int existingAreaBorderTHIDMPID,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemoveAreaBorderTHIDCommand.defaultDescriptionType,
  }) {
    final THAreaBorderTHID areaBorderTHID = th2File.areaBorderTHIDByMPID(
      existingAreaBorderTHIDMPID,
    );
    final THArea parentArea = th2File.areaByMPID(areaBorderTHID.parentMPID);
    final int areaBorderSiblingsCount = parentArea
        .getAreaBorderTHIDMPIDs(th2File)
        .length;

    if (areaBorderSiblingsCount == 1) {
      return removeAreaFromExisting(
        existingAreaMPID: parentArea.mpID,
        th2File: th2File,
        descriptionType: descriptionType,
      );
    } else if (areaBorderSiblingsCount > 1) {
      final MPCommand? preCommand = removeEmptyLinesAfterCommand(
        elementMPID: existingAreaBorderTHIDMPID,
        th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemoveAreaCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingAreaMPID,
      th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeOptionFromElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int parentMPID in parentMPIDs) {
      final MPRemoveAttrOptionFromElementCommand
      removeAttrOptionFromElementCommand = MPRemoveAttrOptionFromElementCommand(
        parentMPID: parentMPID,
        attrName: attrName,
        plaOriginalTH2FileLine: th2File
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemoveElementCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingElementMPID,
      th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeElements,
  }) {
    final List<MPCommand> commandsList = [];

    for (final int mpID in mpIDs) {
      final MPCommand removeCommand;

      switch (th2File.getElementTypeByMPID(mpID)) {
        case THElementType.area:
          removeCommand = removeAreaFromExisting(
            existingAreaMPID: mpID,
            th2File: th2File,
            descriptionType: descriptionType,
          );
        case THElementType.areaBorderTHID:
          removeCommand = MPCommandFactory.removeAreaBorderTHIDFromExisting(
            existingAreaBorderTHIDMPID: mpID,
            th2File: th2File,
            descriptionType: descriptionType,
          );
        case THElementType.emptyLine:
          removeCommand = MPRemoveEmptyLineCommand(emptyLineMPID: mpID);
        case THElementType.line:
          removeCommand = removeLineFromExisting(
            existingLineMPID: mpID,
            isInteractiveLineCreation: false,
            th2File: th2File,
            descriptionType: descriptionType,
          );
        case THElementType.lineSegment:
          removeCommand = removeLineSegmentFromExisting(
            toRemoveLineSegmentMPID: mpID,
            th2File: th2File,
            descriptionType: descriptionType,
          );
        case THElementType.point:
          removeCommand = removePointFromExisting(
            existingPointMPID: mpID,
            th2File: th2File,
            descriptionType: descriptionType,
          );
        case THElementType.scrap:
          removeCommand = removeScrapFromExisting(
            existingScrapMPID: mpID,
            th2File: th2File,
          );
        case THElementType.mapiahImageInsertConfig:
        case THElementType.xTherionImageInsertConfig:
          removeCommand = removeImageInsertConfigFromExisting(
            existingImageInsertConfigMPID: mpID,
            th2File: th2File,
            descriptionType: descriptionType,
          );
        default:
          removeCommand = removeElementFromExisting(
            existingElementMPID: mpID,
            th2File: th2File,
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
    required TH2File th2File,
    required MPCommandDescriptionType descriptionType,
  }) {
    final THElement element = th2File.elementByMPID(elementMPID);
    final THIsParentMixin parent = element.parent(th2File: th2File);
    final List<int> emptyLinesAfter = MPElementEditAux.getEmptyLinesAfter(
      th2File: th2File,
      parent: parent,
      positionInParent: parent.getChildPosition(element),
    );

    if (emptyLinesAfter.isEmpty) {
      return null;
    }

    return MPCommandFactory.removeElements(
      mpIDs: emptyLinesAfter,
      th2File: th2File,
      descriptionType: descriptionType,
    );
  }

  static MPRemoveLineCommand removeLineFromExisting({
    required int existingLineMPID,
    required bool isInteractiveLineCreation,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemoveLineCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingLineMPID,
      th2File: th2File,
      descriptionType: descriptionType,
    );
    final MPCommand? posCommand;
    final int? areaMPID = th2File.getAreaMPIDByLineMPID(existingLineMPID);

    if (areaMPID == null) {
      posCommand = null;
    } else {
      final THArea area = th2File.areaByMPID(areaMPID);
      final THAreaBorderTHID? areaTHID = area.areaBorderByLineMPID(
        existingLineMPID,
        th2File,
      );

      if (areaTHID == null) {
        throw StateError(
          'Line with MPID $existingLineMPID is part of area with MPID $areaMPID but no areaBorderTHID found for it at MPCommandFactory.removeLineFromExisting().',
        );
      } else {
        posCommand = MPCommandFactory.removeAreaBorderTHIDFromExisting(
          existingAreaBorderTHIDMPID: areaTHID.mpID,
          th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final THLineSegment toRemoveLineSegment = th2File.lineSegmentByMPID(
      toRemoveLineSegmentMPID,
    );
    final THLine line = th2File.lineByMPID(toRemoveLineSegment.parentMPID);
    final List<THLineSegment> lineSegments = line.getLineSegments(th2File);
    final int lineSegmentIndex = lineSegments.indexOf(toRemoveLineSegment);

    if ((lineSegmentIndex == 0) ||
        (lineSegmentIndex == lineSegments.length - 1)) {
      return _actualRemoveLineSegmentFromExisting(
        toRemoveLineSegmentMPID: toRemoveLineSegmentMPID,
        th2File: th2File,
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
          th2File: th2File,
        );
      } else {
        final THLineSegment? previousLineSegment = line.getPreviousLineSegment(
          toRemoveLineSegment,
          th2File,
        );

        if (previousLineSegment == null) {
          throw Exception(
            'Error: previousLineSegment is null at TH2FileEditElementEditController.getRemoveLineSegmentCommand().',
          );
        }

        final THBezierCurveLineSegment toRemoveLineSegmentAsBezier =
            toRemoveLineSegmentIsStraight
            ? MPElementEditAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: previousLineSegment.endPoint.coordinates,
                straightLineSegment: toRemoveLineSegment,
              )
            : toRemoveLineSegment as THBezierCurveLineSegment;
        final THBezierCurveLineSegment nextLineSegmentBezier =
            nextLineSegmentIsStraight
            ? MPElementEditAux.getBezierCurveLineSegmentFromStraightLineSegment(
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
          th2File: th2File,
        );
      }
    }
  }

  static MPCommand removeLineSegments({
    required Iterable<int> lineSegmentMPIDs,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegments,
  }) {
    assert(lineSegmentMPIDs.isNotEmpty);

    final THLine parentLine = th2File.lineByMPID(
      th2File.lineSegmentByMPID(lineSegmentMPIDs.first).parentMPID,
    );
    final int lineSegmentsCountInParentLine = parentLine
        .getLineSegmentMPIDs(th2File)
        .length;
    final int remainingLineSegmentsCount =
        lineSegmentsCountInParentLine - lineSegmentMPIDs.length;

    if (remainingLineSegmentsCount < 2) {
      return removeLineFromExisting(
        existingLineMPID: parentLine.mpID,
        isInteractiveLineCreation: false,
        th2File: th2File,
        descriptionType: descriptionType,
      );
    } else {
      final List<MPCommand> commandsList = [];

      for (final int lineSegmentMPID in lineSegmentMPIDs) {
        final MPCommand removeLineSegmentCommand =
            removeLineSegmentFromExisting(
              toRemoveLineSegmentMPID: lineSegmentMPID,
              th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.removeLineSegment,
  }) {
    final List<MPCommand> commandsList = [];

    final MPCommand removeLineSegmentCommand =
        _actualRemoveLineSegmentFromExisting(
          toRemoveLineSegmentMPID: toRemoveLineSegmentMPID,
          th2File: th2File,
          descriptionType: descriptionType,
        );
    final MPCommand editLineSegmentCommand = MPEditLineSegmentCommand(
      originalLineSegment: th2File.lineSegmentByMPID(
        lineSegmentSubstitute.mpID,
      ),
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
    required TH2File th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemovePointCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingPointMPID,
      th2File: th2File,
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
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemoveScrapCommand.defaultDescriptionType,
  }) {
    assert(existingScrapMPID > 0);

    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingScrapMPID,
      th2File: th2File,
      descriptionType: descriptionType,
    );

    return MPRemoveScrapCommand.forCWJM(
      scrapMPID: existingScrapMPID,
      preCommand: preCommand,
      descriptionType: descriptionType,
    );
  }

  static MPRemoveImageInsertConfigCommand removeImageInsertConfigFromExisting({
    required int existingImageInsertConfigMPID,
    required TH2File th2File,
    MPCommandDescriptionType descriptionType =
        MPRemoveImageInsertConfigCommand.defaultDescriptionType,
  }) {
    final MPCommand? preCommand = removeEmptyLinesAfterCommand(
      elementMPID: existingImageInsertConfigMPID,
      th2File: th2File,
      descriptionType: descriptionType,
    );

    return MPRemoveImageInsertConfigCommand.forCWJM(
      imageInsertConfigMPID: existingImageInsertConfigMPID,
      preCommand: preCommand,
      descriptionType: descriptionType,
    );
  }

  static MPCommand convertXTherionImageInsertConfigToMapiahImageInsertConfig({
    required int existingXTherionImageInsertConfigMPID,
    required TH2FileEditController th2FileEditController,
    MPCommandDescriptionType descriptionType =
        MPCommandDescriptionType.multipleElements,
  }) {
    final TH2File th2File = th2FileEditController.th2File;
    final THXTherionImageInsertConfig existingImage = th2File
        .xtherionImageInsertConfigByMPID(existingXTherionImageInsertConfigMPID);
    final THIsParentMixin parent = existingImage.parent(th2File: th2File);
    final int imagePositionInParent = parent.getChildPosition(existingImage);
    final MPImageInsertConfig mapiahImage =
        MPImageInsertConfig.fromXTherionImageInsertConfig(
          xtherionImageInsertConfig: existingImage,
          th2FileEditController: th2FileEditController,
        );
    final MPCommand removeImageCommand =
        MPRemoveImageInsertConfigCommand.forCWJM(
          imageInsertConfigMPID: existingImage.mpID,
          preCommand: null,
          descriptionType: descriptionType,
        );
    final MPCommand addImageCommand = MPAddImageInsertConfigCommand.forCWJM(
      newImageInsertConfig: mapiahImage,
      imageInsertConfigPositionInParent: imagePositionInParent,
      posCommand: null,
      descriptionType: descriptionType,
    );

    return multipleCommandsFromList(
      commandsList: <MPCommand>[removeImageCommand, addImageCommand],
      descriptionType: descriptionType,
      completionType:
          MPMultipleElementsCommandCompletionType.elementsListChanged,
    );
  }

  static MPReorderImagesCommand reorderImages({
    required int oldIndex,
    required int newIndex,
    MPCommandDescriptionType descriptionType =
        MPReorderImagesCommand.defaultDescriptionType,
  }) {
    return MPReorderImagesCommand(
      oldIndex: oldIndex,
      newIndex: newIndex,
      descriptionType: descriptionType,
    );
  }

  static MPReorderScrapsCommand reorderScraps({
    required int oldIndex,
    required int newIndex,
    MPCommandDescriptionType descriptionType =
        MPReorderScrapsCommand.defaultDescriptionType,
  }) {
    return MPReorderScrapsCommand(
      oldIndex: oldIndex,
      newIndex: newIndex,
      descriptionType: descriptionType,
    );
  }

  static MPCommand setAttrOptionOnElements({
    required THAttrCommandOption toOption,
    required List<THElement> elements,
    required TH2File th2File,
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
    required TH2File th2File,
    required Iterable<THLineSegment> originalLineSegments,
  }) {
    if (originalLineSegments.isEmpty) {
      throw ArgumentError(
        'originalLineSegments cannot be empty in MPCommandFactory.setLineSegmentType',
      );
    }

    final List<THLineSegment> changedLineSegments = [];
    final THLine line = th2File.lineByMPID(
      originalLineSegments.first.parentMPID,
    );

    switch (selectedLineSegmentType) {
      case MPSelectedLineSegmentType.bezierCurveLineSegment:
        for (final THLineSegment currentLineSegment in originalLineSegments) {
          if (currentLineSegment is! THStraightLineSegment) {
            throw ArgumentError(
              'All originalLineSegments must be THStraightLineSegment to convert to THBezierCurveLineSegment in MPCommandFactory.setLineSegmentType: found line segment with MPID ${currentLineSegment.mpID} of type ${currentLineSegment.elementType.name}',
            );
          }

          final THLineSegment? previousLineSegment = line
              .getPreviousLineSegment(currentLineSegment, th2File);

          if (previousLineSegment == null) {
            continue;
          }

          final THBezierCurveLineSegment changedLineSegment =
              MPElementEditAux.getBezierCurveLineSegmentFromStraightLineSegment(
                start: previousLineSegment.endPoint.coordinates,
                straightLineSegment: currentLineSegment,
              );

          changedLineSegments.add(changedLineSegment);
        }
      case MPSelectedLineSegmentType.straightLineSegment:
        for (final THLineSegment currentLineSegment in originalLineSegments) {
          if (currentLineSegment is! THBezierCurveLineSegment) {
            throw ArgumentError(
              'All originalLineSegments must be THBezierCurveLineSegment to convert to THStraightLineSegment in MPCommandFactory.setLineSegmentType: found line segment with MPID ${currentLineSegment.mpID} of type ${currentLineSegment.elementType.name}',
            );
          }

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
          th2File: th2File,
          changedLineSegments: changedLineSegments,
        );

    return setLineSegmentTypeCommand;
  }

  static MPCommand setOptionOnElements({
    required THCommandOption toOption,
    required List<THElement> elements,
    required TH2File th2File,
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
