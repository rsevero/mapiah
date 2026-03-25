// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_split_merge_controller.g.dart';

class TH2FileEditSplitMergeController = TH2FileEditSplitMergeControllerBase
    with _$TH2FileEditSplitMergeController;

abstract class TH2FileEditSplitMergeControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditSplitMergeControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  @action
  void prepareSplitLineAtSelectedEndPoints() {
    final Map<int, MPSelectedEndControlPoint> allSelected =
        _th2FileEditController.selectionController.selectedEndControlPoints;

    final List<MPSelectedEndControlPoint> endPoints = allSelected.values
        .where(
          (ep) =>
              (ep.type == MPEndControlPointType.endPointStraight) ||
              (ep.type == MPEndControlPointType.endPointBezierCurve),
        )
        .toList();

    if (endPoints.isEmpty) {
      return;
    }

    final int lineMPID = endPoints.first.originalLineSegmentClone.parentMPID;
    final THLine originalLine = _th2File.lineByMPID(lineMPID);

    if (_th2File.getAreaMPIDByLineMPID(lineMPID) != null) {
      final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mpLocator.appLocalizations.cannotSplitAreaBorderLine),
          ),
        );
      }

      return;
    }

    final List<int> lineSegmentMPIDs = originalLine.getLineSegmentMPIDs(
      _th2File,
    );

    if (lineSegmentMPIDs.length < 2) {
      return;
    }

    final int lastSegmentMPID = lineSegmentMPIDs.last;

    endPoints.sort((a, b) {
      final int posA = lineSegmentMPIDs.indexOf(
        a.originalLineSegmentClone.mpID,
      );
      final int posB = lineSegmentMPIDs.indexOf(
        b.originalLineSegmentClone.mpID,
      );

      return posA.compareTo(posB);
    });

    final List<int> splitPointMPIDs = endPoints
        .map((ep) => ep.originalLineSegmentClone.mpID)
        .where((mpID) => mpID != lastSegmentMPID)
        .toList();

    if (splitPointMPIDs.isEmpty) {
      return;
    }

    final THIsParentMixin parentScrap = originalLine.parent(th2File: _th2File);
    final int originalLinePosition = parentScrap.getChildPosition(originalLine);
    final String? originalID = originalLine.hasOption(THCommandOptionType.id)
        ? (originalLine.getOption(THCommandOptionType.id)! as THIDCommandOption)
              .thID
        : null;
    final List<MPCommand> outerCommands = [];
    final List<int> newSubLineMPIDs = [];

    int segStart = 0;

    for (int i = 0; i <= splitPointMPIDs.length; i++) {
      final int segEnd = (i < splitPointMPIDs.length)
          ? lineSegmentMPIDs.indexOf(splitPointMPIDs[i])
          : lineSegmentMPIDs.length - 1;

      final int newLineMPID = mpLocator.mpGeneralController
          .nextMPIDForElements();
      final SplayTreeMap<THCommandOptionType, THCommandOption> newOptionsMap =
          _buildOptionsForSubLine(
            originalLine: originalLine,
            subLineIndex: i,
            newLineMPID: newLineMPID,
            originalID: originalID,
          );
      final THLine newSubLine = originalLine.copyWith(
        mpID: newLineMPID,
        childrenMPIDs: [],
        optionsMap: newOptionsMap,
        originalLineInTH2File: '',
        makeSameLineCommentNull: true,
      );

      final List<MPCommand> segmentCommands = [];

      if (i > 0) {
        final THLineSegment prevSplitSegment = _th2File.lineSegmentByMPID(
          splitPointMPIDs[i - 1],
        );
        final THStraightLineSegment bridgeSegment = THStraightLineSegment(
          parentMPID: newLineMPID,
          endPoint: prevSplitSegment.endPoint.copyWith(),
        );

        segmentCommands.add(
          MPAddLineSegmentCommand(
            newLineSegment: bridgeSegment,
            posCommand: null,
            descriptionType: MPCommandDescriptionType.splitLineAtSelectedPoints,
          ),
        );
      }

      for (int j = segStart; j <= segEnd; j++) {
        final THLineSegment origSeg = _th2File.lineSegmentByMPID(
          lineSegmentMPIDs[j],
        );
        final THLineSegment newSeg = _copySegment(origSeg, newLineMPID);

        segmentCommands.add(
          MPAddLineSegmentCommand(
            newLineSegment: newSeg,
            posCommand: null,
            descriptionType: MPCommandDescriptionType.splitLineAtSelectedPoints,
          ),
        );
      }

      final MPCommand posCommand = (segmentCommands.length == 1)
          ? segmentCommands.first
          : MPMultipleElementsCommand.forCWJM(
              commandsList: segmentCommands,
              completionType:
                  MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
              descriptionType:
                  MPCommandDescriptionType.splitLineAtSelectedPoints,
            );

      final THEndline endline = THEndline(parentMPID: newLineMPID);

      outerCommands.add(
        MPAddLineCommand(
          newLine: newSubLine,
          lineChildren: [endline],
          linePositionInParent: originalLinePosition + i,
          posCommand: posCommand,
          preCommand: null,
          descriptionType: MPCommandDescriptionType.splitLineAtSelectedPoints,
        ),
      );

      newSubLineMPIDs.add(newLineMPID);
      segStart = segEnd + 1;
    }

    outerCommands.add(
      MPCommandFactory.removeLineFromExisting(
        existingLineMPID: lineMPID,
        isInteractiveLineCreation: false,
        th2File: _th2File,
        descriptionType: MPCommandDescriptionType.splitLineAtSelectedPoints,
      ),
    );

    final MPMultipleElementsCommand splitCommand =
        MPMultipleElementsCommand.forCWJM(
          commandsList: outerCommands,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsListChanged,
          descriptionType: MPCommandDescriptionType.splitLineAtSelectedPoints,
        );

    _th2FileEditController.execute(splitCommand);

    final List<THLine> newSubLines = newSubLineMPIDs
        .map((mpID) => _th2File.lineByMPID(mpID))
        .toList();

    _th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectNonEmptySelection,
    );
    _th2FileEditController.selectionController.setSelectedElements(
      newSubLines,
      setState: false,
    );
  }

  SplayTreeMap<THCommandOptionType, THCommandOption> _buildOptionsForSubLine({
    required THLine originalLine,
    required int subLineIndex,
    required int newLineMPID,
    required String? originalID,
  }) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> newOptionsMap =
        SplayTreeMap<THCommandOptionType, THCommandOption>.from(
          originalLine.optionsMap,
        );

    newOptionsMap.remove(THCommandOptionType.id);

    if (originalID != null) {
      newOptionsMap[THCommandOptionType.id] = THIDCommandOption(
        parentMPID: newLineMPID,
        thID: '$originalID-${subLineIndex + 1}',
      );
    }

    return newOptionsMap;
  }

  THLineSegment _copySegment(THLineSegment original, int newParentMPID) {
    switch (original) {
      case THStraightLineSegment _:
        return THStraightLineSegment(
          parentMPID: newParentMPID,
          endPoint: original.endPoint.copyWith(),
          optionsMap: SplayTreeMap<THCommandOptionType, THCommandOption>.from(
            original.optionsMap,
          ),
          attrOptionsMap: SplayTreeMap<String, THAttrCommandOption>.from(
            original.attrOptionsMap,
          ),
        );
      case THBezierCurveLineSegment _:
        return THBezierCurveLineSegment(
          parentMPID: newParentMPID,
          controlPoint1: original.controlPoint1.copyWith(),
          controlPoint2: original.controlPoint2.copyWith(),
          endPoint: original.endPoint.copyWith(),
          optionsMap: SplayTreeMap<THCommandOptionType, THCommandOption>.from(
            original.optionsMap,
          ),
          attrOptionsMap: SplayTreeMap<String, THAttrCommandOption>.from(
            original.attrOptionsMap,
          ),
        );
      default:
        throw StateError(
          'Unknown THLineSegment subtype at TH2FileEditSplitMergeController._copySegment: ${original.runtimeType}',
        );
    }
  }
}
