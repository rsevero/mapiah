// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_geometry_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_split_merge_controller.g.dart';

typedef _CrossingData = ({int geoSegIdx, Offset crossPoint, double tOnSeg});

class TH2FileEditSplitMergeController = TH2FileEditSplitMergeControllerBase
    with _$TH2FileEditSplitMergeController;

abstract class TH2FileEditSplitMergeControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditSplitMergeControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  Map<int, List<_CrossingData>> _computeCrossings(List<THLine> lines) {
    final Map<int, List<_CrossingData>> result = {};

    for (int i = 0; i < lines.length; i++) {
      for (int j = i + 1; j < lines.length; j++) {
        final THLine lineA = lines[i];
        final THLine lineB = lines[j];
        final List<THLineSegment> segsA = lineA.getLineSegments(_th2File);
        final List<THLineSegment> segsB = lineB.getLineSegments(_th2File);

        for (int k = 0; k < segsA.length - 1; k++) {
          if (segsA[k + 1] is THBezierCurveLineSegment) {
            continue;
          }

          final Offset p0 = segsA[k].endPoint.coordinates;
          final Offset p1 = segsA[k + 1].endPoint.coordinates;

          for (int m = 0; m < segsB.length - 1; m++) {
            if (segsB[m + 1] is THBezierCurveLineSegment) {
              continue;
            }

            final Offset p2 = segsB[m].endPoint.coordinates;
            final Offset p3 = segsB[m + 1].endPoint.coordinates;

            final MPSegmentIntersection? hit =
                MPGeometryAux.straightSegmentIntersection(p0, p1, p2, p3);

            if (hit == null) {
              continue;
            }

            result.putIfAbsent(lineA.mpID, () => []).add((
              geoSegIdx: k,
              crossPoint: hit.point,
              tOnSeg: hit.tA,
            ));
            result.putIfAbsent(lineB.mpID, () => []).add((
              geoSegIdx: m,
              crossPoint: hit.point,
              tOnSeg: hit.tB,
            ));
          }
        }
      }
    }

    for (final List<_CrossingData> crossings in result.values) {
      crossings.sort((final _CrossingData a, final _CrossingData b) {
        final int segCmp = a.geoSegIdx.compareTo(b.geoSegIdx);

        if (segCmp != 0) {
          return segCmp;
        }

        return a.tOnSeg.compareTo(b.tOnSeg);
      });
    }

    return result;
  }

  void _buildSubLineCommandsForLine({
    required THLine originalLine,
    required List<_CrossingData> crossings,
    required int adjustedLinePosition,
    required List<MPCommand> outerCommands,
  }) {
    final List<int> lineSegMPIDs = originalLine.getLineSegmentMPIDs(_th2File);
    final String? originalID = originalLine.hasOption(THCommandOptionType.id)
        ? (originalLine.getOption(THCommandOptionType.id)! as THIDCommandOption)
              .thID
        : null;

    // Build virtual segment list: items are either int (index into lineSegMPIDs)
    // or Offset (crossing point to insert as new straight segment).
    // Track split indices in the virtual list.
    final List<dynamic> virtualSegs = [];
    final List<int> splitVirtualIndices = [];

    int crossingIdx = 0;

    for (int i = 0; i < lineSegMPIDs.length; i++) {
      virtualSegs.add(i);

      while ((crossingIdx < crossings.length) &&
          (crossings[crossingIdx].geoSegIdx == i)) {
        splitVirtualIndices.add(virtualSegs.length);
        virtualSegs.add(crossings[crossingIdx].crossPoint);
        crossingIdx++;
      }
    }

    final int numSubLines = crossings.length + 1;

    int vSegStart = 0;

    for (int subLineI = 0; subLineI < numSubLines; subLineI++) {
      final int vSegEnd = (subLineI < splitVirtualIndices.length)
          ? splitVirtualIndices[subLineI]
          : virtualSegs.length - 1;

      final int newLineMPID = mpLocator.mpGeneralController
          .nextMPIDForElements();
      final SplayTreeMap<THCommandOptionType, THCommandOption> newOptionsMap =
          _buildOptionsForSubLine(
            originalLine: originalLine,
            subLineIndex: subLineI,
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

      if (subLineI > 0) {
        final int prevSplitVIdx = splitVirtualIndices[subLineI - 1];
        final Offset prevCrossPoint = virtualSegs[prevSplitVIdx] as Offset;
        final THStraightLineSegment bridgeSegment = THStraightLineSegment(
          parentMPID: newLineMPID,
          endPoint: THPositionPart(coordinates: prevCrossPoint),
        );

        segmentCommands.add(
          MPAddLineSegmentCommand(
            newLineSegment: bridgeSegment,
            posCommand: null,
            descriptionType: MPCommandDescriptionType.splitLinesAtCrossings,
          ),
        );
      }

      for (int vi = vSegStart; vi <= vSegEnd; vi++) {
        final dynamic vSeg = virtualSegs[vi];
        final THLineSegment newSeg;

        if (vSeg is int) {
          final THLineSegment origSeg = _th2File.lineSegmentByMPID(
            lineSegMPIDs[vSeg],
          );

          newSeg = _copySegment(origSeg, newLineMPID);
        } else {
          newSeg = THStraightLineSegment(
            parentMPID: newLineMPID,
            endPoint: THPositionPart(coordinates: vSeg as Offset),
          );
        }

        segmentCommands.add(
          MPAddLineSegmentCommand(
            newLineSegment: newSeg,
            posCommand: null,
            descriptionType: MPCommandDescriptionType.splitLinesAtCrossings,
          ),
        );
      }

      final MPCommand posCommand = (segmentCommands.length == 1)
          ? segmentCommands.first
          : MPMultipleElementsCommand.forCWJM(
              commandsList: segmentCommands,
              completionType:
                  MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
              descriptionType: MPCommandDescriptionType.splitLinesAtCrossings,
            );

      final THEndline endline = THEndline(parentMPID: newLineMPID);

      outerCommands.add(
        MPAddLineCommand(
          newLine: newSubLine,
          lineChildren: [endline],
          linePositionInParent: adjustedLinePosition + subLineI,
          posCommand: posCommand,
          preCommand: null,
          descriptionType: MPCommandDescriptionType.splitLinesAtCrossings,
        ),
      );

      vSegStart = vSegEnd + 1;
    }

    outerCommands.add(
      MPCommandFactory.removeLineFromExisting(
        existingLineMPID: originalLine.mpID,
        isInteractiveLineCreation: false,
        th2File: _th2File,
        descriptionType: MPCommandDescriptionType.splitLinesAtCrossings,
      ),
    );
  }

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

  @action
  void prepareSplitLinesAtCrossings() {
    final List<THLine> selectedLines = _th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .values
        .whereType<MPSelectedLine>()
        .map((final MPSelectedLine sel) => _th2File.lineByMPID(sel.mpID))
        .toList();

    if (selectedLines.length < 2) {
      return;
    }

    final Map<int, List<_CrossingData>> crossingsPerLine = _computeCrossings(
      selectedLines,
    );

    if (crossingsPerLine.isEmpty) {
      final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mpLocator.appLocalizations.noLinesAtCrossingsFound),
          ),
        );
      }

      return;
    }

    final THIsParentMixin parentScrap = _th2File
        .lineByMPID(crossingsPerLine.keys.first)
        .parent(th2File: _th2File);

    final List<int> sortedLineMPIDs = crossingsPerLine.keys.toList()
      ..sort(
        (final int a, final int b) => parentScrap
            .getChildPosition(_th2File.lineByMPID(a))
            .compareTo(parentScrap.getChildPosition(_th2File.lineByMPID(b))),
      );

    final List<MPCommand> outerCommands = [];
    int cumulativeOffset = 0;

    for (final int lineMPID in sortedLineMPIDs) {
      final THLine originalLine = _th2File.lineByMPID(lineMPID);
      final int originalLinePosition = parentScrap.getChildPosition(
        originalLine,
      );
      final List<_CrossingData> crossings = crossingsPerLine[lineMPID]!;

      _buildSubLineCommandsForLine(
        originalLine: originalLine,
        crossings: crossings,
        adjustedLinePosition: originalLinePosition + cumulativeOffset,
        outerCommands: outerCommands,
      );

      cumulativeOffset += crossings.length;
    }

    final MPMultipleElementsCommand splitCommand =
        MPMultipleElementsCommand.forCWJM(
          commandsList: outerCommands,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsListChanged,
          descriptionType: MPCommandDescriptionType.splitLinesAtCrossings,
        );

    _th2FileEditController.execute(splitCommand);

    _th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectNonEmptySelection,
    );

    final List<THLine> newSubLines = _th2File
        .getLines()
        .where((final THLine line) => !selectedLines.contains(line))
        .toList();

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
