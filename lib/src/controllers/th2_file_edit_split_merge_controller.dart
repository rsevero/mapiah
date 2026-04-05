// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_geometry_aux.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
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

typedef _BezierSplitInfo = ({
  Offset controlPoint1,
  Offset controlPoint2,
  Offset endPoint,
});

enum _LineExtremityType { start, end }

typedef _ExtremityCoincidence = ({
  int lineAMPID,
  _LineExtremityType lineAExtremity,
  int lineBMPID,
  _LineExtremityType lineBExtremity,
  double distanceSquared,
});

typedef _LineAdjacency = ({
  int otherLineMPID,
  _LineExtremityType thisExtremity,
  _LineExtremityType otherExtremity,
  double distanceSquared,
});

typedef _OrientedLine = ({THLine line, bool reversed});

typedef _OrientedSeg = ({int idx, bool reversed});

class TH2FileEditSplitMergeController = TH2FileEditSplitMergeControllerBase
    with _$TH2FileEditSplitMergeController;

abstract class TH2FileEditSplitMergeControllerBase with Store {
  @readonly
  TH2File _th2File;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditSplitMergeControllerBase(this._th2FileEditController)
    : _th2File = _th2FileEditController.th2File;

  Offset _lineStartPoint(THLine line) {
    return line.getLineSegments(_th2File).first.endPoint.coordinates;
  }

  Offset _lineEndPoint(THLine line) {
    return line.getLineSegments(_th2File).last.endPoint.coordinates;
  }

  List<_ExtremityCoincidence> _computeExtremityCoincidences(
    List<THLine> selectedLines,
    double toleranceOnCanvas,
  ) {
    final List<_ExtremityCoincidence> coincidences = <_ExtremityCoincidence>[];
    final double toleranceOnCanvasSquared =
        toleranceOnCanvas * toleranceOnCanvas;

    for (int i = 0; i < selectedLines.length; i++) {
      final THLine lineA = selectedLines[i];
      final Offset lineAStart = _lineStartPoint(lineA);
      final Offset lineAEnd = _lineEndPoint(lineA);

      for (int j = i + 1; j < selectedLines.length; j++) {
        final THLine lineB = selectedLines[j];
        final Offset lineBStart = _lineStartPoint(lineB);
        final Offset lineBEnd = _lineEndPoint(lineB);

        final List<(_LineExtremityType, Offset, _LineExtremityType, Offset)>
        candidates = <(_LineExtremityType, Offset, _LineExtremityType, Offset)>[
          (
            _LineExtremityType.start,
            lineAStart,
            _LineExtremityType.start,
            lineBStart,
          ),
          (
            _LineExtremityType.start,
            lineAStart,
            _LineExtremityType.end,
            lineBEnd,
          ),
          (
            _LineExtremityType.end,
            lineAEnd,
            _LineExtremityType.start,
            lineBStart,
          ),
          (_LineExtremityType.end, lineAEnd, _LineExtremityType.end, lineBEnd),
        ];

        for (final (
              _LineExtremityType lineAExtremity,
              Offset lineAPosition,
              _LineExtremityType lineBExtremity,
              Offset lineBPosition,
            )
            in candidates) {
          final double distSq = (lineAPosition - lineBPosition).distanceSquared;

          if (distSq <= toleranceOnCanvasSquared) {
            coincidences.add((
              lineAMPID: lineA.mpID,
              lineAExtremity: lineAExtremity,
              lineBMPID: lineB.mpID,
              lineBExtremity: lineBExtremity,
              distanceSquared: distSq,
            ));
          }
        }
      }
    }

    return coincidences;
  }

  Map<int, List<_LineAdjacency>> _buildAdjacency(
    List<_ExtremityCoincidence> coincidences,
  ) {
    final Map<int, List<_LineAdjacency>> adjacency =
        <int, List<_LineAdjacency>>{};

    for (final _ExtremityCoincidence coincidence in coincidences) {
      adjacency
          .putIfAbsent(coincidence.lineAMPID, () => <_LineAdjacency>[])
          .add((
            otherLineMPID: coincidence.lineBMPID,
            thisExtremity: coincidence.lineAExtremity,
            otherExtremity: coincidence.lineBExtremity,
            distanceSquared: coincidence.distanceSquared,
          ));

      adjacency
          .putIfAbsent(coincidence.lineBMPID, () => <_LineAdjacency>[])
          .add((
            otherLineMPID: coincidence.lineAMPID,
            thisExtremity: coincidence.lineBExtremity,
            otherExtremity: coincidence.lineAExtremity,
            distanceSquared: coincidence.distanceSquared,
          ));
    }

    return adjacency;
  }

  _LineAdjacency? _bestAdjacencyBetween(
    int thisLineMPID,
    int otherLineMPID,
    Map<int, List<_LineAdjacency>> adjacency,
  ) {
    final List<_LineAdjacency> candidates =
        adjacency[thisLineMPID]
            ?.where((a) => a.otherLineMPID == otherLineMPID)
            .toList() ??
        <_LineAdjacency>[];

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => a.distanceSquared.compareTo(b.distanceSquared));
    return candidates.first;
  }

  Set<int> _collectConnectedComponent(
    int seedLineMPID,
    Map<int, List<_LineAdjacency>> adjacency,
  ) {
    final Set<int> component = <int>{};
    final List<int> stack = <int>[seedLineMPID];

    while (stack.isNotEmpty) {
      final int current = stack.removeLast();

      if (component.contains(current)) {
        continue;
      }

      component.add(current);

      for (final _LineAdjacency next
          in adjacency[current] ?? <_LineAdjacency>[]) {
        if (!component.contains(next.otherLineMPID)) {
          stack.add(next.otherLineMPID);
        }
      }
    }

    return component;
  }

  List<List<int>> _buildJoinPathsForComponent({
    required Set<int> componentLineMPIDs,
    required Map<int, List<_LineAdjacency>> adjacency,
    required Map<int, int> selectionOrder,
  }) {
    final List<List<int>> paths = <List<int>>[];
    final Set<int> unvisited = Set<int>.from(componentLineMPIDs);

    while (unvisited.isNotEmpty) {
      final List<int> degreeOneCandidates = unvisited.where((lineMPID) {
        final int degreeInUnvisited =
            (adjacency[lineMPID] ?? <_LineAdjacency>[])
                .where((a) => unvisited.contains(a.otherLineMPID))
                .length;
        return degreeInUnvisited <= 1;
      }).toList();

      final List<int> startCandidates = degreeOneCandidates.isNotEmpty
          ? degreeOneCandidates
          : unvisited.toList();

      startCandidates.sort((a, b) {
        return (selectionOrder[a] ?? mpMaximumInt).compareTo(
          selectionOrder[b] ?? mpMaximumInt,
        );
      });

      final int start = startCandidates.first;
      final List<int> path = <int>[];
      int current = start;
      int? previous;

      while (true) {
        path.add(current);
        unvisited.remove(current);

        final List<int> nextCandidates =
            (adjacency[current] ?? <_LineAdjacency>[])
                .map((a) => a.otherLineMPID)
                .where((lineMPID) => unvisited.contains(lineMPID))
                .where((lineMPID) => lineMPID != previous)
                .toSet()
                .toList();

        if (nextCandidates.isEmpty) {
          break;
        }

        nextCandidates.sort((a, b) {
          return (selectionOrder[a] ?? mpMaximumInt).compareTo(
            selectionOrder[b] ?? mpMaximumInt,
          );
        });

        previous = current;
        current = nextCandidates.first;
      }

      if (path.length >= 2) {
        paths.add(path);
      }
    }

    return paths;
  }

  List<_OrientedLine> _buildOrientedPathLines({
    required List<int> pathLineMPIDs,
    required Map<int, List<_LineAdjacency>> adjacency,
  }) {
    final List<_OrientedLine> orientedLines = <_OrientedLine>[];

    for (int i = 0; i < pathLineMPIDs.length; i++) {
      final THLine currentLine = _th2File.lineByMPID(pathLineMPIDs[i]);
      bool reversed = false;

      if (i == 0) {
        if (pathLineMPIDs.length >= 2) {
          final _LineAdjacency? firstToNext = _bestAdjacencyBetween(
            pathLineMPIDs[i],
            pathLineMPIDs[i + 1],
            adjacency,
          );

          if (firstToNext != null) {
            reversed = (firstToNext.thisExtremity == _LineExtremityType.start);
          }
        }
      } else {
        final _LineAdjacency? previousToCurrent = _bestAdjacencyBetween(
          pathLineMPIDs[i],
          pathLineMPIDs[i - 1],
          adjacency,
        );

        if (previousToCurrent != null) {
          reversed =
              (previousToCurrent.thisExtremity == _LineExtremityType.end);
        }
      }

      orientedLines.add((line: currentLine, reversed: reversed));
    }

    return orientedLines;
  }

  List<THLineSegment> _copyLineSegmentsForOrientation({
    required THLine line,
    required bool reversed,
    required int newParentMPID,
  }) {
    final List<THLineSegment> originalSegments = line.getLineSegments(_th2File);

    if (!reversed) {
      return originalSegments
          .map((segment) => _copySegment(segment, newParentMPID))
          .toList();
    }

    final List<THLineSegment> reversedSegments = <THLineSegment>[];

    reversedSegments.add(
      THStraightLineSegment(
        parentMPID: newParentMPID,
        endPoint: originalSegments.last.endPoint.copyWith(),
      ),
    );

    for (int i = originalSegments.length - 1; i >= 1; i--) {
      final THLineSegment originalSegment = originalSegments[i];
      final THLineSegment previousOriginalSegment = originalSegments[i - 1];

      switch (originalSegment) {
        case THBezierCurveLineSegment _:
          reversedSegments.add(
            THBezierCurveLineSegment(
              parentMPID: newParentMPID,
              controlPoint1: originalSegment.controlPoint2.copyWith(),
              controlPoint2: originalSegment.controlPoint1.copyWith(),
              endPoint: previousOriginalSegment.endPoint.copyWith(),
              optionsMap:
                  SplayTreeMap<THCommandOptionType, THCommandOption>.from(
                    originalSegment.optionsMap,
                  ),
              attrOptionsMap: SplayTreeMap<String, THAttrCommandOption>.from(
                originalSegment.attrOptionsMap,
              ),
            ),
          );
        case THStraightLineSegment _:
          reversedSegments.add(
            THStraightLineSegment(
              parentMPID: newParentMPID,
              endPoint: previousOriginalSegment.endPoint.copyWith(),
              optionsMap:
                  SplayTreeMap<THCommandOptionType, THCommandOption>.from(
                    originalSegment.optionsMap,
                  ),
              attrOptionsMap: SplayTreeMap<String, THAttrCommandOption>.from(
                originalSegment.attrOptionsMap,
              ),
            ),
          );
        default:
          throw StateError(
            'Unknown THLineSegment subtype at TH2FileEditSplitMergeController._copyLineSegmentsForOrientation: ${originalSegment.runtimeType}',
          );
      }
    }

    return reversedSegments;
  }

  void _buildJoinPathCommand({
    required List<int> pathLineMPIDs,
    required Map<int, int> selectionOrder,
    required Map<int, List<_LineAdjacency>> adjacency,
    required THIsParentMixin parentScrap,
    required int adjustedInsertionPosition,
    required List<MPCommand> outerCommands,
    required List<int> createdJoinedLineMPIDs,
  }) {
    if (pathLineMPIDs.length < 2) {
      return;
    }

    final List<_OrientedLine> orientedLines = _buildOrientedPathLines(
      pathLineMPIDs: pathLineMPIDs,
      adjacency: adjacency,
    );

    final List<int> orderedBySelection = List<int>.from(pathLineMPIDs)
      ..sort((a, b) {
        return (selectionOrder[a] ?? mpMaximumInt).compareTo(
          selectionOrder[b] ?? mpMaximumInt,
        );
      });
    final THLine canonicalLine = _th2File.lineByMPID(orderedBySelection.first);

    final int newLineMPID = mpLocator.mpGeneralController.nextMPIDForElements();
    final THLine newJoinedLine = canonicalLine.copyWith(
      mpID: newLineMPID,
      childrenMPIDs: <int>[],
      originalLineInTH2File: '',
      makeSameLineCommentNull: true,
    );

    final List<THLineSegment> joinedSegments = <THLineSegment>[];

    for (int i = 0; i < orientedLines.length; i++) {
      final _OrientedLine oriented = orientedLines[i];
      final List<THLineSegment> lineSegments = _copyLineSegmentsForOrientation(
        line: oriented.line,
        reversed: oriented.reversed,
        newParentMPID: newLineMPID,
      );

      if (i == 0) {
        joinedSegments.addAll(lineSegments);
      } else {
        joinedSegments.addAll(lineSegments.skip(1));
      }
    }

    final List<MPCommand> segmentCommands = joinedSegments
        .map(
          (segment) => MPAddLineSegmentCommand(
            newLineSegment: segment,
            posCommand: null,
            descriptionType:
                MPCommandDescriptionType.joinLinesAtCoincidingExtremities,
          ),
        )
        .toList();

    final MPCommand posCommand = (segmentCommands.length == 1)
        ? segmentCommands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: segmentCommands,
            completionType:
                MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
            descriptionType:
                MPCommandDescriptionType.joinLinesAtCoincidingExtremities,
          );

    for (final int lineMPID in pathLineMPIDs) {
      outerCommands.add(
        MPCommandFactory.removeLineFromExisting(
          existingLineMPID: lineMPID,
          isInteractiveLineCreation: false,
          th2File: _th2File,
          descriptionType:
              MPCommandDescriptionType.joinLinesAtCoincidingExtremities,
        ),
      );
    }

    outerCommands.add(
      MPAddLineCommand(
        newLine: newJoinedLine,
        lineChildren: <THEndline>[THEndline(parentMPID: newLineMPID)],
        linePositionInParent: adjustedInsertionPosition,
        posCommand: posCommand,
        preCommand: null,
        descriptionType:
            MPCommandDescriptionType.joinLinesAtCoincidingExtremities,
      ),
    );

    createdJoinedLineMPIDs.add(newLineMPID);
  }

  @action
  void prepareJoinLinesAtCoincidingExtremities() {
    final List<MPSelectedLine> selectedLogicalLines = _th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .values
        .whereType<MPSelectedLine>()
        .toList();

    if (selectedLogicalLines.length < 2) {
      return;
    }

    final List<THLine> selectedLines = selectedLogicalLines
        .map((selectedLine) => _th2File.lineByMPID(selectedLine.mpID))
        .toList();

    final Map<int, int> selectionOrderByMPID = <int, int>{};
    for (int i = 0; i < selectedLines.length; i++) {
      selectionOrderByMPID[selectedLines[i].mpID] = i;
    }

    final double toleranceOnCanvas = _th2FileEditController.scaleScreenToCanvas(
      mpJoinLineExtremityToleranceOnScreen,
    );
    final List<_ExtremityCoincidence> coincidences =
        _computeExtremityCoincidences(selectedLines, toleranceOnCanvas);

    if (coincidences.isEmpty) {
      final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mpLocator.appLocalizations.noCoincidingLineExtremitiesFound,
            ),
          ),
        );
      }

      return;
    }

    final Map<int, List<_LineAdjacency>> adjacency = _buildAdjacency(
      coincidences,
    );
    final Set<int> joinableLineMPIDs = adjacency.keys.toSet();

    if (joinableLineMPIDs.length < 2) {
      final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mpLocator.appLocalizations.noCoincidingLineExtremitiesFound,
            ),
          ),
        );
      }

      return;
    }

    final THIsParentMixin parentScrap = _th2File
        .lineByMPID(joinableLineMPIDs.first)
        .parent(th2File: _th2File);

    final Set<int> remaining = Set<int>.from(joinableLineMPIDs);
    final List<List<int>> allJoinPaths = <List<int>>[];

    while (remaining.isNotEmpty) {
      final int seed = remaining.first;
      final Set<int> component = _collectConnectedComponent(seed, adjacency);
      remaining.removeAll(component);

      final List<List<int>> componentPaths = _buildJoinPathsForComponent(
        componentLineMPIDs: component,
        adjacency: adjacency,
        selectionOrder: selectionOrderByMPID,
      );

      allJoinPaths.addAll(componentPaths.where((path) => path.length >= 2));
    }

    if (allJoinPaths.isEmpty) {
      final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mpLocator.appLocalizations.noCoincidingLineExtremitiesFound,
            ),
          ),
        );
      }

      return;
    }

    allJoinPaths.sort((pathA, pathB) {
      final int minPositionA = pathA
          .map(
            (lineMPID) =>
                parentScrap.getChildPosition(_th2File.lineByMPID(lineMPID)),
          )
          .reduce((a, b) => a < b ? a : b);
      final int minPositionB = pathB
          .map(
            (lineMPID) =>
                parentScrap.getChildPosition(_th2File.lineByMPID(lineMPID)),
          )
          .reduce((a, b) => a < b ? a : b);
      return minPositionA.compareTo(minPositionB);
    });

    final List<MPCommand> outerCommands = <MPCommand>[];
    final List<int> createdJoinedLineMPIDs = <int>[];
    int cumulativeOffset = 0;

    for (final List<int> path in allJoinPaths) {
      final int minOriginalPosition = path
          .map(
            (lineMPID) =>
                parentScrap.getChildPosition(_th2File.lineByMPID(lineMPID)),
          )
          .reduce((a, b) => a < b ? a : b);

      _buildJoinPathCommand(
        pathLineMPIDs: path,
        selectionOrder: selectionOrderByMPID,
        adjacency: adjacency,
        parentScrap: parentScrap,
        adjustedInsertionPosition: minOriginalPosition + cumulativeOffset,
        outerCommands: outerCommands,
        createdJoinedLineMPIDs: createdJoinedLineMPIDs,
      );

      cumulativeOffset += 1 - path.length;
    }

    final MPMultipleElementsCommand joinCommand =
        MPMultipleElementsCommand.forCWJM(
          commandsList: outerCommands,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsListChanged,
          descriptionType:
              MPCommandDescriptionType.joinLinesAtCoincidingExtremities,
        );

    _th2FileEditController.execute(joinCommand);
    _th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectNonEmptySelection,
    );

    final List<THLine> joinedLines = createdJoinedLineMPIDs
        .map((lineMPID) => _th2File.lineByMPID(lineMPID))
        .toList();

    _th2FileEditController.selectionController.setSelectedElements(
      joinedLines,
      setState: false,
    );
  }

  Map<int, List<_CrossingData>> _computeCrossings(List<THLine> lines) {
    final Map<int, List<_CrossingData>> result = {};

    for (int i = 0; i < lines.length; i++) {
      for (int j = i + 1; j < lines.length; j++) {
        final THLine lineA = lines[i];
        final THLine lineB = lines[j];
        final List<THLineSegment> segsA = lineA.getLineSegments(_th2File);
        final List<THLineSegment> segsB = lineB.getLineSegments(_th2File);

        for (int k = 0; k < segsA.length - 1; k++) {
          final THLineSegment segA = segsA[k + 1];

          for (int m = 0; m < segsB.length - 1; m++) {
            final THLineSegment segB = segsB[m + 1];

            // Case 1: Both segments are straight
            if ((segA is! THBezierCurveLineSegment) &&
                (segB is! THBezierCurveLineSegment)) {
              final Offset p0 = segsA[k].endPoint.coordinates;
              final Offset p1 = segA.endPoint.coordinates;
              final Offset p2 = segsB[m].endPoint.coordinates;
              final Offset p3 = segB.endPoint.coordinates;

              final MPSegmentIntersection? hit =
                  MPGeometryAux.straightSegmentIntersection(p0, p1, p2, p3);

              if (hit != null) {
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
            // Case 2: Bézier A vs Straight B
            else if ((segA is THBezierCurveLineSegment) &&
                (segB is! THBezierCurveLineSegment)) {
              final THBezierCurveLineSegment bezierSegA = segA;
              final Offset p0 = segsA[k].endPoint.coordinates;
              final Offset p3 = bezierSegA.endPoint.coordinates;
              final Offset lineStart = segsB[m].endPoint.coordinates;
              final Offset lineEnd = segB.endPoint.coordinates;

              final List<BezierStraightIntersection> hits =
                  MPGeometryAux.bezierSegmentStraightSegmentIntersection(
                    p0,
                    bezierSegA.controlPoint1.coordinates,
                    bezierSegA.controlPoint2.coordinates,
                    p3,
                    lineStart,
                    lineEnd,
                  );

              for (final BezierStraightIntersection hit in hits) {
                result.putIfAbsent(lineA.mpID, () => []).add((
                  geoSegIdx: k,
                  crossPoint: hit.point,
                  tOnSeg: hit.tBezier,
                ));
                result.putIfAbsent(lineB.mpID, () => []).add((
                  geoSegIdx: m,
                  crossPoint: hit.point,
                  tOnSeg: hit.tLine,
                ));
              }
            }
            // Case 3: Straight A vs Bézier B
            else if ((segA is! THBezierCurveLineSegment) &&
                (segB is THBezierCurveLineSegment)) {
              final THBezierCurveLineSegment bezierSegB = segB;
              final Offset lineStart = segsA[k].endPoint.coordinates;
              final Offset lineEnd = segA.endPoint.coordinates;
              final Offset p0 = segsB[m].endPoint.coordinates;
              final Offset p3 = bezierSegB.endPoint.coordinates;

              final List<BezierStraightIntersection> hits =
                  MPGeometryAux.bezierSegmentStraightSegmentIntersection(
                    p0,
                    bezierSegB.controlPoint1.coordinates,
                    bezierSegB.controlPoint2.coordinates,
                    p3,
                    lineStart,
                    lineEnd,
                  );

              for (final BezierStraightIntersection hit in hits) {
                result.putIfAbsent(lineA.mpID, () => []).add((
                  geoSegIdx: k,
                  crossPoint: hit.point,
                  tOnSeg: hit.tLine,
                ));
                result.putIfAbsent(lineB.mpID, () => []).add((
                  geoSegIdx: m,
                  crossPoint: hit.point,
                  tOnSeg: hit.tBezier,
                ));
              }
            }
            // Case 4: Both Bézier
            else if ((segA is THBezierCurveLineSegment) &&
                (segB is THBezierCurveLineSegment)) {
              final Offset p0A = segsA[k].endPoint.coordinates;
              final Offset p0B = segsB[m].endPoint.coordinates;

              final List<BezierBezierIntersection> hits =
                  MPGeometryAux.bezierBezierIntersection(
                    p0A,
                    segA.controlPoint1.coordinates,
                    segA.controlPoint2.coordinates,
                    segA.endPoint.coordinates,
                    p0B,
                    segB.controlPoint1.coordinates,
                    segB.controlPoint2.coordinates,
                    segB.endPoint.coordinates,
                  );

              for (final BezierBezierIntersection hit in hits) {
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

  /// Subdivides a cubic Bézier curve at parameter t using de Casteljau's algorithm.
  /// Returns a tuple of (left piece, right piece) where each piece is a complete Bézier control point set.
  ({_BezierSplitInfo left, _BezierSplitInfo right}) _subdivideBezierAtT(
    Offset start,
    Offset cp1,
    Offset cp2,
    Offset end,
    double t,
  ) {
    // de Casteljau's algorithm: compute intermediate points on the Bézier hierarchy
    final Offset m01 = Offset.lerp(start, cp1, t)!;
    final Offset m12 = Offset.lerp(cp1, cp2, t)!;
    final Offset m23 = Offset.lerp(cp2, end, t)!;

    final Offset m012 = Offset.lerp(m01, m12, t)!;
    final Offset m123 = Offset.lerp(m12, m23, t)!;

    final Offset split = Offset.lerp(m012, m123, t)!;

    return (
      left: (controlPoint1: m01, controlPoint2: m012, endPoint: split),
      right: (controlPoint1: m123, controlPoint2: m23, endPoint: end),
    );
  }

  Offset _splitMarkerPoint(dynamic splitMarker) {
    if (splitMarker is _BezierSplitInfo) {
      return splitMarker.endPoint;
    }

    return splitMarker as Offset;
  }

  void _buildSubLineCommandsForLine({
    required THLine originalLine,
    required List<_CrossingData> crossings,
    required int adjustedLinePosition,
    required List<MPCommand> outerCommands,
    required List<int> newSubLineMPIDs,
  }) {
    final List<int> lineSegMPIDs = originalLine.getLineSegmentMPIDs(_th2File);
    final List<THLineSegment> lineSegs = originalLine.getLineSegments(_th2File);
    final String? originalID = originalLine.hasOption(THCommandOptionType.id)
        ? (originalLine.getOption(THCommandOptionType.id)! as THIDCommandOption)
              .thID
        : null;

    // Build virtual segment list: items are int (segment index), Offset (straight crossing),
    // or _BezierSplitInfo (subdivided Bézier piece).
    // Track split indices in the virtual list.
    final List<dynamic> virtualSegs = [];
    final List<int> splitVirtualIndices = [];

    int crossingIdx = 0;

    for (int i = 0; i < lineSegMPIDs.length; i++) {
      virtualSegs.add(i);
      double previousSplitTOnOriginalSegment = 0.0;
      Offset currentSegmentStart = lineSegs[i].endPoint.coordinates;

      while ((crossingIdx < crossings.length) &&
          (crossings[crossingIdx].geoSegIdx == i)) {
        splitVirtualIndices.add(virtualSegs.length);
        final double tOnOriginalSegment = crossings[crossingIdx].tOnSeg;
        final THLineSegment seg = lineSegs[i + 1];

        // Check if this segment is Bézier
        if (seg is THBezierCurveLineSegment) {
          final double remainingSegmentFraction =
              1.0 - previousSplitTOnOriginalSegment;
          final double tOnCurrentSegment =
              (tOnOriginalSegment - previousSplitTOnOriginalSegment) /
              remainingSegmentFraction;

          // Subdivide the Bézier at parameter t on the current remainder.
          final (
            :_BezierSplitInfo left,
            :_BezierSplitInfo right,
          ) = _subdivideBezierAtT(
            currentSegmentStart,
            seg.controlPoint1.coordinates,
            seg.controlPoint2.coordinates,
            seg.endPoint.coordinates,
            tOnCurrentSegment,
          );

          // Add left Bézier piece
          virtualSegs.add(left);

          // Replace the original segment with the right piece for processing next crossing
          // (update lineSegs locally for next iteration)
          lineSegs[i + 1] = THBezierCurveLineSegment(
            parentMPID: seg.parentMPID,
            controlPoint1: THPositionPart(coordinates: right.controlPoint1),
            controlPoint2: THPositionPart(coordinates: right.controlPoint2),
            endPoint: THPositionPart(coordinates: right.endPoint),
            optionsMap: seg.optionsMap,
            attrOptionsMap: seg.attrOptionsMap,
          );
          currentSegmentStart = left.endPoint;
        } else {
          // For straight segments, just add the crossing point
          virtualSegs.add(crossings[crossingIdx].crossPoint);
        }

        previousSplitTOnOriginalSegment = tOnOriginalSegment;
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
        final Offset prevCrossPoint = _splitMarkerPoint(
          virtualSegs[prevSplitVIdx],
        );
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
          // Original segment index
          final THLineSegment origSeg = lineSegs[vSeg];

          newSeg = _copySegment(origSeg, newLineMPID);
        } else if (vSeg is _BezierSplitInfo) {
          // Subdivided Bézier piece
          final _BezierSplitInfo info = vSeg;
          newSeg = THBezierCurveLineSegment(
            parentMPID: newLineMPID,
            controlPoint1: THPositionPart(coordinates: info.controlPoint1),
            controlPoint2: THPositionPart(coordinates: info.controlPoint2),
            endPoint: THPositionPart(coordinates: info.endPoint),
          );
        } else {
          // Crossing point (straight segment end)
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

      newSubLineMPIDs.add(newLineMPID);

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
    final List<int> newSubLineMPIDs = [];
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
        newSubLineMPIDs: newSubLineMPIDs,
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

    final List<THLine> newSubLines = newSubLineMPIDs
        .map((final int mpID) => _th2File.lineByMPID(mpID))
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

  /// Appends a straight closing segment to [segments] if the line is not
  /// already closed (i.e. last segment's endPoint != first segment's endPoint).
  List<THLineSegment> _ensureClosed({
    required List<THLineSegment> segments,
    required int newParentMPID,
  }) {
    if (segments.length < 2) {
      return segments;
    }

    final Offset firstPoint = segments.first.endPoint.coordinates;
    final Offset lastPoint = segments.last.endPoint.coordinates;
    final double gapSquared = (firstPoint - lastPoint).distanceSquared;

    if (gapSquared <= mpDoubleComparisonEpsilonSquared) {
      return segments;
    }

    return [
      ...segments,
      THStraightLineSegment(
        parentMPID: newParentMPID,
        endPoint: THPositionPart(coordinates: firstPoint),
      ),
    ];
  }

  /// Computes the 2-D cross product of vectors a and b.
  double _cross2D(Offset a, Offset b) => (a.dx * b.dy) - (a.dy * b.dx);

  /// Returns the departure tangent at the start (t=0) of [seg], given that
  /// the segment starts at [segStart].
  Offset _departureTangent(THLineSegment seg, Offset segStart) {
    switch (seg) {
      case THBezierCurveLineSegment _:
        final Offset d = seg.controlPoint1.coordinates - segStart;

        if (d.distanceSquared > mpDoubleComparisonEpsilonSquared) {
          return d;
        }

        final Offset d2 = seg.controlPoint2.coordinates - segStart;

        if (d2.distanceSquared > mpDoubleComparisonEpsilonSquared) {
          return d2;
        }

        return seg.endPoint.coordinates - segStart;
      default:
        return seg.endPoint.coordinates - segStart;
    }
  }

  /// Returns the arrival tangent at the end (t=1) of [seg], given that
  /// the segment starts at [segStart].
  Offset _arrivalTangent(THLineSegment seg, Offset segStart) {
    switch (seg) {
      case THBezierCurveLineSegment _:
        final Offset d =
            seg.endPoint.coordinates - seg.controlPoint2.coordinates;

        if (d.distanceSquared > mpDoubleComparisonEpsilonSquared) {
          return d;
        }

        final Offset d2 =
            seg.endPoint.coordinates - seg.controlPoint1.coordinates;

        if (d2.distanceSquared > mpDoubleComparisonEpsilonSquared) {
          return d2;
        }

        return seg.endPoint.coordinates - segStart;
      default:
        return seg.endPoint.coordinates - segStart;
    }
  }

  /// Groups [lines] by mergeability for area merging (union-find).
  ///
  /// Two lines are placed in the same group when they:
  ///   • share a common line segment — any segment from one line is
  ///     geometrically identical (same type, same start/end/control points,
  ///     considering the reversed version) to any segment from the other, or
  ///   • cross each other (geometric intersection).
  ///
  /// Lines that meet neither criterion form singleton groups.
  List<List<THLine>> _groupLTSAsByMergeability(List<THLine> lines) {
    final int n = lines.length;
    final List<int> parent = List<int>.generate(n, (i) => i);

    int find(int x) {
      while (parent[x] != x) {
        parent[x] = parent[parent[x]];
        x = parent[x];
      }

      return x;
    }

    void union(int a, int b) {
      final int ra = find(a);
      final int rb = find(b);

      if (ra != rb) {
        parent[ra] = rb;
      }
    }

    // Precompute segment lists and their start points for each line.
    final List<List<THLineSegment>> allSegs = lines.map((line) {
      return line.getLineSegments(_th2File);
    }).toList();

    final List<List<Offset>> allStarts = allSegs.map((segs) {
      final List<Offset> starts = [];

      for (int k = 0; k < segs.length - 1; k++) {
        starts.add(segs[k].endPoint.coordinates);
      }

      return starts;
    }).toList();

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        // Criterion 1: lines cross each other (geometric intersection).
        bool mergeable = _computeCrossings([lines[i], lines[j]]).isNotEmpty;

        // Criterion 2: shared segment — any segment of line i is a geometric
        // duplicate (same or reversed) of any segment of line j.
        if (!mergeable) {
          outer:
          for (int si = 0; si < allStarts[i].length; si++) {
            for (int sj = 0; sj < allStarts[j].length; sj++) {
              if (_segmentsAreGeometricDuplicates(
                segI: allSegs[i][si + 1],
                startI: allStarts[i][si],
                segJ: allSegs[j][sj + 1],
                startJ: allStarts[j][sj],
              )) {
                mergeable = true;

                break outer;
              }
            }
          }
        }

        if (mergeable) {
          union(i, j);
        }
      }
    }

    final Map<int, List<THLine>> groups = {};

    for (int i = 0; i < n; i++) {
      groups.putIfAbsent(find(i), () => []).add(lines[i]);
    }

    return groups.values.toList();
  }

  /// Traces a closed boundary path starting from [start], always taking the
  /// [pickLeft] (or right) turn at each junction. Segments may be traversed in
  /// either direction; each physical segment may appear at most once.
  ///
  /// Returns the ordered list of oriented segments forming the path, or null
  /// if the path cannot be closed.
  List<_OrientedSeg>? _traceBoundaryPath({
    required List<THLineSegment> allSegs,
    required List<Offset> segStarts,
    required Map<_OrientedSeg, List<_OrientedSeg>> adjacency,
    required _OrientedSeg start,
    required bool pickLeft,
  }) {
    final List<_OrientedSeg> path = [start];
    final Set<int> usedIndices = {start.idx};

    // The target is the effective start of the first oriented segment; we need
    // to return to it to close the boundary loop.
    final Offset targetStart = start.reversed
        ? allSegs[start.idx].endPoint.coordinates
        : segStarts[start.idx];

    _OrientedSeg current = start;

    while (true) {
      final Offset currentEnd = current.reversed
          ? segStarts[current.idx]
          : allSegs[current.idx].endPoint.coordinates;

      // Check if we have returned to the start of the first segment.
      if ((path.length > 1) &&
          ((currentEnd - targetStart).distanceSquared <=
              mpDoubleComparisonEpsilonSquared)) {
        break;
      }

      // Arrival tangent: for a reversed segment, it is the negated departure
      // tangent of the forward segment.
      final Offset arrDir = current.reversed
          ? -_departureTangent(allSegs[current.idx], segStarts[current.idx])
          : _arrivalTangent(allSegs[current.idx], segStarts[current.idx]);

      final List<_OrientedSeg> candidates = (adjacency[current] ?? [])
          .where((c) => !usedIndices.contains(c.idx))
          .toList();

      if (candidates.isEmpty) {
        // Dead end — path cannot be closed this way.
        return null;
      }

      // Sort candidates by turn angle relative to incoming direction.
      // pickLeft → most counter-clockwise (largest positive cross product);
      // pickRight → most clockwise (most negative).
      // For a reversed candidate, its departure tangent is the negated arrival
      // tangent of the forward segment.
      candidates.sort((a, b) {
        final Offset aDep = a.reversed
            ? -_arrivalTangent(allSegs[a.idx], segStarts[a.idx])
            : _departureTangent(allSegs[a.idx], segStarts[a.idx]);
        final Offset bDep = b.reversed
            ? -_arrivalTangent(allSegs[b.idx], segStarts[b.idx])
            : _departureTangent(allSegs[b.idx], segStarts[b.idx]);

        final double crossA = _cross2D(arrDir, aDep);
        final double crossB = _cross2D(arrDir, bDep);

        return pickLeft ? crossB.compareTo(crossA) : crossA.compareTo(crossB);
      });

      current = candidates.first;
      path.add(current);
      usedIndices.add(current.idx);

      if (path.length > allSegs.length + 1) {
        // Cycle detection guard.
        return null;
      }
    }

    return path;
  }

  /// Builds a bounding box for a segment given its start point.
  Rect _segBoundingBox(THLineSegment seg, Offset start) {
    return seg.getBoundingBox(start);
  }

  /// Returns true when [segI] (from [startI]) and [segJ] (from [startJ])
  /// represent the same geometric edge — either in the same direction or
  /// reversed.
  ///
  /// For Bézier curves, reversal swaps the control points: cp1 ↔ cp2.
  /// Mixed segment types (straight vs Bézier) are never duplicates.
  bool _segmentsAreGeometricDuplicates({
    required THLineSegment segI,
    required Offset startI,
    required THLineSegment segJ,
    required Offset startJ,
  }) {
    final Offset endI = segI.endPoint.coordinates;
    final Offset endJ = segJ.endPoint.coordinates;

    final bool endpointsSameDir =
        ((startI - startJ).distanceSquared <=
            mpDoubleComparisonEpsilonSquared) &&
        ((endI - endJ).distanceSquared <= mpDoubleComparisonEpsilonSquared);
    final bool endpointsReversed =
        ((startI - endJ).distanceSquared <= mpDoubleComparisonEpsilonSquared) &&
        ((endI - startJ).distanceSquared <= mpDoubleComparisonEpsilonSquared);

    if (!endpointsSameDir && !endpointsReversed) {
      return false;
    }

    switch ((segI, segJ)) {
      case (THStraightLineSegment _, THStraightLineSegment _):
        return true;

      case (THBezierCurveLineSegment bezI, THBezierCurveLineSegment bezJ):
        final Offset cp1I = bezI.controlPoint1.coordinates;
        final Offset cp2I = bezI.controlPoint2.coordinates;
        final Offset cp1J = bezJ.controlPoint1.coordinates;
        final Offset cp2J = bezJ.controlPoint2.coordinates;

        if (endpointsSameDir) {
          return ((cp1I - cp1J).distanceSquared <=
                  mpDoubleComparisonEpsilonSquared) &&
              ((cp2I - cp2J).distanceSquared <=
                  mpDoubleComparisonEpsilonSquared);
        } else {
          // Reversed Bézier: cp1 of reversed = cp2 of original, and vice versa.
          return ((cp1I - cp2J).distanceSquared <=
                  mpDoubleComparisonEpsilonSquared) &&
              ((cp2I - cp1J).distanceSquared <=
                  mpDoubleComparisonEpsilonSquared);
        }

      default:
        // Mixed types cannot be duplicates.
        return false;
    }
  }

  /// Collects all THLine objects referenced by the THAreaBorderTHIDs of
  /// [selectedAreas], deduplicated by MPID.
  List<THLine> _collectLTSAs(List<THArea> selectedAreas) {
    final Set<int> seen = {};
    final List<THLine> ltsa = [];

    for (final THArea area in selectedAreas) {
      for (final int lineMPID in area.getLineMPIDs(_th2File)) {
        if (seen.add(lineMPID)) {
          ltsa.add(_th2File.lineByMPID(lineMPID));
        }
      }
    }

    return ltsa;
  }

  void _showSnackbar(String message) {
    final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

    if (context != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @action
  void prepareMergeAreas() {
    // 1. Collect and validate selections.
    final ({List<THArea> selectedAreas, List<THLine> allLTSAs})? selections =
        _collectAndValidateMergeSelections();

    if (selections == null) {
      return;
    }

    final List<THArea> selectedAreas = selections.selectedAreas;
    final List<THLine> allLTSAs = selections.allLTSAs;

    // 2. Use the first selected area and first LTSA as canonical sources for
    // options and IDs.
    final THArea canonicalArea = selectedAreas.first;
    final THLine canonicalLine = allLTSAs.first;
    final String? canonicalAreaTHID =
        canonicalArea.hasOption(THCommandOptionType.id)
        ? (canonicalArea.getOption(THCommandOptionType.id)!
                  as THIDCommandOption)
              .thID
        : null;
    final String? canonicalLineTHID =
        canonicalLine.hasOption(THCommandOptionType.id)
        ? (canonicalLine.getOption(THCommandOptionType.id)!
                  as THIDCommandOption)
              .thID
        : null;

    // 3. Determine insert position: earliest position among all selected areas
    // in their parent scrap.
    final THIsParentMixin parentScrap = canonicalArea.parent(th2File: _th2File);

    int insertPosition = parentScrap.getChildPosition(canonicalArea);

    for (final THArea area in selectedAreas) {
      final int pos = parentScrap.getChildPosition(area);

      if (pos < insertPosition) {
        insertPosition = pos;
      }
    }

    // 4. Group LTSAs by mergeability: lines that share a common segment or
    // cross each other form one group; isolated lines are singleton groups.
    final List<List<THLine>> groups = _groupLTSAsByMergeability(allLTSAs);

    // 5. Pre-compute canonical area THID. If the canonical area has no
    // explicit ID we generate one now, before any commands execute, so it can
    // be used as a prefix for line IDs.
    final String effectiveAreaTHID =
        canonicalAreaTHID ??
        _th2File.getNewTHID(element: canonicalArea, prefix: mpAreaTHIDPrefix);

    // Track IDs reserved during this build pass so getNewTHID does not
    // collide across groups (IDs are not in the file yet at this point).
    final Set<String> reservedTHIDs = {};

    if (canonicalAreaTHID == null) {
      reservedTHIDs.add(effectiveAreaTHID);
    }

    // 6. Build outer command list.
    final List<MPCommand> outerCommands = [];
    final List<int> newLineMPIDs = [];
    final List<int> newAreaMPIDs = [];

    // 6a. Remove all selected areas and their original border lines.
    outerCommands.addAll(
      _buildMergeRemovalCommands(
        selectedAreas: selectedAreas,
        allLTSAs: allLTSAs,
      ),
    );

    // 6b. For each group, create a merged line + new area.
    // Offset insertion position to account for the removed elements.
    int lineInsertOffset = 0;
    int areaInsertOffset = 0;

    for (int g = 0; g < groups.length; g++) {
      // Build merged line command.
      final ({MPCommand command, int newLineMPID, String lineTHIDForGroup})?
      lineResult = _buildMergedLineCommandForGroup(
        groupLines: groups[g],
        allLTSAs: allLTSAs,
        g: g,
        canonicalLineTHID: canonicalLineTHID,
        effectiveAreaTHID: effectiveAreaTHID,
        reservedTHIDs: reservedTHIDs,
        insertPosition: insertPosition,
        lineInsertOffset: lineInsertOffset,
      );

      if (lineResult == null) {
        return;
      }

      outerCommands.add(lineResult.command);
      newLineMPIDs.add(lineResult.newLineMPID);
      lineInsertOffset++;

      // Build new area command.
      final ({MPCommand command, int newAreaMPID}) areaResult =
          _buildNewAreaCommandForGroup(
            canonicalArea: canonicalArea,
            g: g,
            effectiveAreaTHID: effectiveAreaTHID,
            lineTHIDForGroup: lineResult.lineTHIDForGroup,
            reservedTHIDs: reservedTHIDs,
            insertPosition: insertPosition,
            lineInsertOffset: lineInsertOffset,
            areaInsertOffset: areaInsertOffset,
          );

      outerCommands.add(areaResult.command);
      newAreaMPIDs.add(areaResult.newAreaMPID);
      areaInsertOffset++;
    }

    // 7. Execute and update selection.
    final MPMultipleElementsCommand mergeCommand =
        MPMultipleElementsCommand.forCWJM(
          commandsList: outerCommands,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsListChanged,
          descriptionType: MPCommandDescriptionType.mergeAreas,
        );

    _th2FileEditController.execute(mergeCommand);

    _th2FileEditController.stateController.setState(
      MPTH2FileEditStateType.selectNonEmptySelection,
    );

    final List<THArea> newAreas = newAreaMPIDs
        .map((mpID) => _th2File.areaByMPID(mpID))
        .toList();

    _th2FileEditController.selectionController.setSelectedElements(
      newAreas,
      setState: false,
    );
  }

  /// Collects selected areas and their border lines, validates that there are
  /// enough elements to merge. Returns null (and shows a snackbar) if
  /// validation fails.
  ({List<THArea> selectedAreas, List<THLine> allLTSAs})?
  _collectAndValidateMergeSelections() {
    final List<THArea> selectedAreas = _th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .values
        .whereType<MPSelectedArea>()
        .map((final MPSelectedArea sel) => _th2File.areaByMPID(sel.mpID))
        .toList();

    if (selectedAreas.isEmpty) {
      _showSnackbar(mpLocator.appLocalizations.mergeAreasNoSelectedAreas);

      return null;
    }

    final List<THLine> allLTSAs = _collectLTSAs(selectedAreas);

    if (allLTSAs.length < 2) {
      _showSnackbar(mpLocator.appLocalizations.mergeAreasNoSelectedAreas);

      return null;
    }

    return (selectedAreas: selectedAreas, allLTSAs: allLTSAs);
  }

  /// Builds the commands that remove all [selectedAreas] and their original
  /// [allLTSAs] border lines before the merged replacements are inserted.
  ///
  /// We do NOT use removeLineFromExisting here because that factory method
  /// adds a posCommand to also remove the associated area border THID. The
  /// areas and their border THIDs are already removed by the area removal
  /// commands above, so we only need to remove the line itself (plus any
  /// trailing empty lines).
  List<MPCommand> _buildMergeRemovalCommands({
    required List<THArea> selectedAreas,
    required List<THLine> allLTSAs,
  }) {
    final List<MPCommand> commands = [];

    for (final THArea area in selectedAreas) {
      commands.add(
        MPCommandFactory.removeAreaFromExisting(
          existingAreaMPID: area.mpID,
          th2File: _th2File,
          descriptionType: MPCommandDescriptionType.mergeAreas,
        ),
      );
    }

    for (final THLine line in allLTSAs) {
      final MPCommand? preCommand =
          MPCommandFactory.removeEmptyLinesAfterCommand(
            elementMPID: line.mpID,
            th2File: _th2File,
            descriptionType: MPCommandDescriptionType.mergeAreas,
          );

      commands.add(
        MPRemoveLineCommand.forCWJM(
          lineMPID: line.mpID,
          isInteractiveLineCreation: false,
          preCommand: preCommand,
          posCommand: null,
          descriptionType: MPCommandDescriptionType.mergeAreas,
        ),
      );
    }

    return commands;
  }

  /// Builds the [MPAddLineCommand] for the merged border line of one group.
  /// Reserves [lineTHIDForGroup] in [reservedTHIDs].
  /// Returns null (and shows a snackbar) if segment geometry is invalid.
  ({MPCommand command, int newLineMPID, String lineTHIDForGroup})?
  _buildMergedLineCommandForGroup({
    required List<THLine> groupLines,
    required List<THLine> allLTSAs,
    required int g,
    required String? canonicalLineTHID,
    required String effectiveAreaTHID,
    required Set<String> reservedTHIDs,
    required int insertPosition,
    required int lineInsertOffset,
  }) {
    // Determine canonical line for this group (first in allLTSAs order).
    final THLine groupCanonicalLine = allLTSAs.firstWhere(
      (l) => groupLines.contains(l),
      orElse: () => groupLines.first,
    );

    final int newLineMPID = mpLocator.mpGeneralController.nextMPIDForElements();

    // Determine the THID for the merged line.
    // First group: reuse canonical line THID if it had one, otherwise
    // auto-generate one based on the area THID prefix.
    // Subsequent groups: always auto-generate.
    final String lineTHIDForGroup;

    if ((g == 0) && (canonicalLineTHID != null)) {
      lineTHIDForGroup = canonicalLineTHID;
    } else {
      // Generate a unique ID not already used in the file or in this pass.
      final String prefix = '$effectiveAreaTHID-$mpLineTHIDPrefix';

      int counter = 1;
      String candidate = '$prefix$counter';

      while (_th2File.hasElementByTHID(candidate) ||
          reservedTHIDs.contains(candidate)) {
        counter++;
        candidate = '$prefix$counter';
      }

      lineTHIDForGroup = candidate;
    }

    reservedTHIDs.add(lineTHIDForGroup);

    final SplayTreeMap<THCommandOptionType, THCommandOption> lineOptionsMap =
        SplayTreeMap<THCommandOptionType, THCommandOption>.from(
          groupCanonicalLine.optionsMap,
        );

    lineOptionsMap.remove(THCommandOptionType.id);
    lineOptionsMap[THCommandOptionType.id] = THIDCommandOption(
      parentMPID: newLineMPID,
      thID: lineTHIDForGroup,
    );

    final THLine mergedLineWithOptions = groupCanonicalLine.copyWith(
      mpID: newLineMPID,
      childrenMPIDs: [],
      optionsMap: lineOptionsMap,
      originalLineInTH2File: '',
      makeSameLineCommentNull: true,
    );

    final List<THElement> lineChildren = [];
    final List<MPCommand> segmentCommands = [];
    List<THLineSegment> mergedSegs;

    try {
      mergedSegs = _buildMergedSegmentsForGroup(
        lines: groupLines,
        newLineMPID: mergedLineWithOptions.mpID,
      );
    } on StateError catch (e) {
      if (e.message == 'mergeAreasLineSegmentsOutsideBoundary') {
        _showSnackbar(
          mpLocator.appLocalizations.mergeAreasLineSegmentsOutsideBoundary,
        );

        return null;
      }
      rethrow;
    }

    for (final THLineSegment seg in mergedSegs) {
      segmentCommands.add(
        MPAddLineSegmentCommand(
          newLineSegment: seg,
          posCommand: null,
          descriptionType: MPCommandDescriptionType.mergeAreas,
        ),
      );
    }

    lineChildren.add(THEndline(parentMPID: mergedLineWithOptions.mpID));

    final MPCommand posCommand = (segmentCommands.length == 1)
        ? segmentCommands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: segmentCommands,
            completionType:
                MPMultipleElementsCommandCompletionType.lineSegmentsEdited,
            descriptionType: MPCommandDescriptionType.mergeAreas,
          );

    final MPCommand command = MPAddLineCommand(
      newLine: mergedLineWithOptions,
      lineChildren: lineChildren,
      linePositionInParent: insertPosition + lineInsertOffset,
      posCommand: posCommand,
      preCommand: null,
      descriptionType: MPCommandDescriptionType.mergeAreas,
    );

    return (
      command: command,
      newLineMPID: newLineMPID,
      lineTHIDForGroup: lineTHIDForGroup,
    );
  }

  /// Builds the [MPAddAreaCommand] for the new area of one group.
  /// Reserves [areaTHIDForGroup] in [reservedTHIDs] for groups after the
  /// first.
  ({MPCommand command, int newAreaMPID}) _buildNewAreaCommandForGroup({
    required THArea canonicalArea,
    required int g,
    required String effectiveAreaTHID,
    required String lineTHIDForGroup,
    required Set<String> reservedTHIDs,
    required int insertPosition,
    required int lineInsertOffset,
    required int areaInsertOffset,
  }) {
    final int newAreaMPID = mpLocator.mpGeneralController.nextMPIDForElements();
    final SplayTreeMap<THCommandOptionType, THCommandOption> areaOptionsMap =
        SplayTreeMap<THCommandOptionType, THCommandOption>.from(
          canonicalArea.optionsMap,
        );

    areaOptionsMap.remove(THCommandOptionType.id);

    // First group inherits the canonical area THID (original or generated).
    // Subsequent groups get a new unique ID.
    final String areaTHIDForGroup;

    if (g == 0) {
      areaTHIDForGroup = effectiveAreaTHID;
    } else {
      int counter = 1;
      String candidate = '$mpAreaTHIDPrefix$counter';

      while (_th2File.hasElementByTHID(candidate) ||
          reservedTHIDs.contains(candidate)) {
        counter++;
        candidate = '$mpAreaTHIDPrefix$counter';
      }

      areaTHIDForGroup = candidate;
      reservedTHIDs.add(areaTHIDForGroup);
    }

    areaOptionsMap[THCommandOptionType.id] = THIDCommandOption(
      parentMPID: newAreaMPID,
      thID: areaTHIDForGroup,
    );

    final THArea newArea = canonicalArea.copyWith(
      mpID: newAreaMPID,
      childrenMPIDs: [],
      optionsMap: areaOptionsMap,
      originalLineInTH2File: '',
      makeSameLineCommentNull: true,
    );

    final THAreaBorderTHID borderTHID = THAreaBorderTHID(
      parentMPID: newAreaMPID,
      thID: lineTHIDForGroup,
    );
    final THEndarea endarea = THEndarea(parentMPID: newAreaMPID);

    final MPCommand command = MPAddAreaCommand.forCWJM(
      newArea: newArea,
      areaPositionInParent:
          insertPosition + lineInsertOffset + areaInsertOffset,
      areaChildren: [borderTHID, endarea],
      posCommand: null,
      descriptionType: MPCommandDescriptionType.mergeAreas,
    );

    return (command: command, newAreaMPID: newAreaMPID);
  }

  /// Builds the ordered merged segment list for a group of [lines] using the
  /// bounding-path algorithm. This is a pure computation (no file mutation)
  /// used by [prepareMergeAreas] to obtain the segment list for the new line.
  List<THLineSegment> _buildMergedSegmentsForGroup({
    required List<THLine> lines,
    required int newLineMPID,
  }) {
    if (lines.length == 1) {
      // Single line — just close it and return a copy.
      final List<THLineSegment> rawSegs = lines.first.getLineSegments(_th2File);
      final List<THLineSegment> copied = rawSegs
          .map((s) => _copySegment(s, newLineMPID))
          .toList();

      return _ensureClosed(segments: copied, newParentMPID: newLineMPID);
    }

    // 1. Flatten all segments from all lines into a single list.
    final ({List<THLineSegment> segs, List<Offset> starts}) flat =
        _flattenClosedSegments(lines: lines, newLineMPID: newLineMPID);
    final List<THLineSegment> allSegs = flat.segs;
    final List<Offset> segStarts = flat.starts;

    if (allSegs.isEmpty) {
      return [];
    }

    // 2. Remove shared inner edges.
    _removeSharedEdges(allSegs: allSegs, segStarts: segStarts);

    if (allSegs.isEmpty) {
      return [];
    }

    // 3. Build adjacency map (supports both forward and reversed traversal).
    final Map<_OrientedSeg, List<_OrientedSeg>> adjacency =
        _buildSegmentAdjacency(allSegs: allSegs, segStarts: segStarts);

    // 4. Find the best starting segment.
    final int startIdx = _findBoundaryStartIndex(
      allSegs: allSegs,
      segStarts: segStarts,
    );

    // 5. Trace boundary paths and choose the one that covers all segments.
    final List<_OrientedSeg> chosenPath = _chooseBoundaryPath(
      allSegs: allSegs,
      segStarts: segStarts,
      adjacency: adjacency,
      startIdx: startIdx,
    );

    // 6. Assemble: pin segment + path segments (reversed segments are flipped).
    final _OrientedSeg firstSeg = chosenPath.first;
    final Offset pinEnd = firstSeg.reversed
        ? allSegs[firstSeg.idx].endPoint.coordinates
        : segStarts[firstSeg.idx];

    return [
      THStraightLineSegment(
        parentMPID: newLineMPID,
        endPoint: THPositionPart(coordinates: pinEnd),
      ),
      ...chosenPath.map(
        (os) => os.reversed
            ? _reverseSegment(allSegs[os.idx], segStarts[os.idx], newLineMPID)
            : allSegs[os.idx],
      ),
    ];
  }

  /// Copies and closes each line's segments, then flattens them into a single
  /// list ready for boundary tracing. Returns parallel [segs] and [starts]
  /// lists where [starts[i]] is the start point of [segs[i]].
  ({List<THLineSegment> segs, List<Offset> starts}) _flattenClosedSegments({
    required List<THLine> lines,
    required int newLineMPID,
  }) {
    final List<THLineSegment> segs = [];
    final List<Offset> starts = [];

    for (final THLine line in lines) {
      final List<THLineSegment> rawSegs = line.getLineSegments(_th2File);
      final List<THLineSegment> closed = _ensureClosed(
        segments: rawSegs.map((s) => _copySegment(s, newLineMPID)).toList(),
        newParentMPID: newLineMPID,
      );

      if (closed.isEmpty) {
        continue;
      }

      Offset prev = closed.first.endPoint.coordinates;

      for (int i = 1; i < closed.length; i++) {
        starts.add(prev);
        segs.add(closed[i]);
        prev = closed[i].endPoint.coordinates;
      }
    }

    return (segs: segs, starts: starts);
  }

  /// Removes shared inner edges in place from [allSegs] and [segStarts].
  /// Any segment that appears geometrically more than once (in either
  /// direction) is an interior boundary shared by two borders and must be
  /// dropped entirely.
  void _removeSharedEdges({
    required List<THLineSegment> allSegs,
    required List<Offset> segStarts,
  }) {
    final Set<int> sharedIndices = {};

    for (int i = 0; i < allSegs.length; i++) {
      if (sharedIndices.contains(i)) {
        continue;
      }

      for (int j = i + 1; j < allSegs.length; j++) {
        if (sharedIndices.contains(j)) {
          continue;
        }

        if (_segmentsAreGeometricDuplicates(
          segI: allSegs[i],
          startI: segStarts[i],
          segJ: allSegs[j],
          startJ: segStarts[j],
        )) {
          sharedIndices.add(i);
          sharedIndices.add(j);
        }
      }
    }

    if (sharedIndices.isEmpty) {
      return;
    }

    final List<THLineSegment> filteredSegs = [];
    final List<Offset> filteredStarts = [];

    for (int i = 0; i < allSegs.length; i++) {
      if (!sharedIndices.contains(i)) {
        filteredSegs.add(allSegs[i]);
        filteredStarts.add(segStarts[i]);
      }
    }

    allSegs
      ..clear()
      ..addAll(filteredSegs);
    segStarts
      ..clear()
      ..addAll(filteredStarts);
  }

  /// Builds an adjacency map for oriented segments. Each [_OrientedSeg]
  /// `(idx, reversed)` maps to the list of oriented segments that can
  /// immediately follow it — i.e., whose effective start point coincides with
  /// the effective end point of `(idx, reversed)`.
  ///
  /// Both forward and backward traversal of every segment are considered,
  /// which is necessary when border-line orientations are inconsistent across
  /// the areas being merged.
  Map<_OrientedSeg, List<_OrientedSeg>> _buildSegmentAdjacency({
    required List<THLineSegment> allSegs,
    required List<Offset> segStarts,
  }) {
    final int n = allSegs.length;
    final Map<_OrientedSeg, List<_OrientedSeg>> adjacency = {};

    for (int i = 0; i < n; i++) {
      adjacency[(idx: i, reversed: false)] = [];
      adjacency[(idx: i, reversed: true)] = [];
    }

    for (int i = 0; i < n; i++) {
      for (final bool iRev in [false, true]) {
        final Offset iEnd = iRev
            ? segStarts[i]
            : allSegs[i].endPoint.coordinates;
        final _OrientedSeg key = (idx: i, reversed: iRev);

        for (int j = 0; j < n; j++) {
          if (j == i) {
            continue;
          }

          for (final bool jRev in [false, true]) {
            final Offset jStart = jRev
                ? allSegs[j].endPoint.coordinates
                : segStarts[j];

            if ((jStart - iEnd).distanceSquared <=
                mpDoubleComparisonEpsilonSquared) {
              adjacency[key]!.add((idx: j, reversed: jRev));
            }
          }
        }
      }
    }

    return adjacency;
  }

  /// Returns the index of the segment whose bounding box is closest to the
  /// top-left corner of the overall group bounding box. This gives a
  /// consistent, deterministic starting point for boundary tracing.
  int _findBoundaryStartIndex({
    required List<THLineSegment> allSegs,
    required List<Offset> segStarts,
  }) {
    Rect groupBB = _segBoundingBox(allSegs[0], segStarts[0]);

    for (int i = 1; i < allSegs.length; i++) {
      groupBB = groupBB.expandToInclude(
        _segBoundingBox(allSegs[i], segStarts[i]),
      );
    }

    int startIdx = 0;
    double bestDist = double.infinity;

    for (int i = 0; i < allSegs.length; i++) {
      final Rect bb = _segBoundingBox(allSegs[i], segStarts[i]);
      final double dist = (bb.topLeft - groupBB.topLeft).distanceSquared;

      if (dist < bestDist) {
        bestDist = dist;
        startIdx = i;
      }
    }

    return startIdx;
  }

  /// Tries all four combinations of left/right turn and forward/reversed start
  /// orientation from [startIdx], and returns the path that covers all
  /// segments with the fewest uncovered segments. Throws a [StateError] with
  /// message `'mergeAreasLineSegmentsOutsideBoundary'` if no combination
  /// covers every segment.
  List<_OrientedSeg> _chooseBoundaryPath({
    required List<THLineSegment> allSegs,
    required List<Offset> segStarts,
    required Map<_OrientedSeg, List<_OrientedSeg>> adjacency,
    required int startIdx,
  }) {
    List<_OrientedSeg>? bestPath;
    int bestOutside = allSegs.length + 1;

    for (final bool pickLeft in [true, false]) {
      for (final bool startReversed in [false, true]) {
        final _OrientedSeg start = (idx: startIdx, reversed: startReversed);
        final List<_OrientedSeg>? path = _traceBoundaryPath(
          allSegs: allSegs,
          segStarts: segStarts,
          adjacency: adjacency,
          start: start,
          pickLeft: pickLeft,
        );

        if (path == null) {
          continue;
        }

        final int outside =
            allSegs.length - path.map((s) => s.idx).toSet().length;

        if (outside < bestOutside) {
          bestOutside = outside;
          bestPath = path;

          if (bestOutside == 0) {
            break;
          }
        }
      }

      if (bestOutside == 0) {
        break;
      }
    }

    if (bestOutside > 0) {
      throw StateError('mergeAreasLineSegmentsOutsideBoundary');
    }

    return bestPath!;
  }

  /// Returns a copy of [seg] traversed in the opposite direction. The new end
  /// point is [segStart] (the original start). For Bézier curves the control
  /// points are swapped so the curve shape is preserved.
  THLineSegment _reverseSegment(
    THLineSegment seg,
    Offset segStart,
    int newParentMPID,
  ) {
    switch (seg) {
      case THStraightLineSegment _:
        return THStraightLineSegment(
          parentMPID: newParentMPID,
          endPoint: THPositionPart(coordinates: segStart),
          optionsMap: SplayTreeMap<THCommandOptionType, THCommandOption>.from(
            seg.optionsMap,
          ),
          attrOptionsMap: SplayTreeMap<String, THAttrCommandOption>.from(
            seg.attrOptionsMap,
          ),
        );
      case THBezierCurveLineSegment _:
        return THBezierCurveLineSegment(
          parentMPID: newParentMPID,
          controlPoint1: seg.controlPoint2.copyWith(),
          controlPoint2: seg.controlPoint1.copyWith(),
          endPoint: THPositionPart(coordinates: segStart),
          optionsMap: SplayTreeMap<THCommandOptionType, THCommandOption>.from(
            seg.optionsMap,
          ),
          attrOptionsMap: SplayTreeMap<String, THAttrCommandOption>.from(
            seg.attrOptionsMap,
          ),
        );
      default:
        throw StateError(
          'Unknown THLineSegment subtype at TH2FileEditSplitMergeController._reverseSegment: ${seg.runtimeType}',
        );
    }
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
