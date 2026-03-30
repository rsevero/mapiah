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
  double distance,
});

typedef _LineAdjacency = ({
  int otherLineMPID,
  _LineExtremityType thisExtremity,
  _LineExtremityType otherExtremity,
  double distance,
});

typedef _OrientedLine = ({THLine line, bool reversed});

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
          final double distance = (lineAPosition - lineBPosition).distance;

          if (distance <= toleranceOnCanvas) {
            coincidences.add((
              lineAMPID: lineA.mpID,
              lineAExtremity: lineAExtremity,
              lineBMPID: lineB.mpID,
              lineBExtremity: lineBExtremity,
              distance: distance,
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
            distance: coincidence.distance,
          ));

      adjacency
          .putIfAbsent(coincidence.lineBMPID, () => <_LineAdjacency>[])
          .add((
            otherLineMPID: coincidence.lineAMPID,
            thisExtremity: coincidence.lineBExtremity,
            otherExtremity: coincidence.lineAExtremity,
            distance: coincidence.distance,
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

    candidates.sort((a, b) => a.distance.compareTo(b.distance));
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
