# Split Lines at Crossings — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When 2+ lines are selected, `Ctrl+Shift+X` (and a FAB button) detects all straight-segment crossing points between selected lines and splits each line into sub-lines at those points, using the existing ID-suffix and option-inheritance convention.

**Architecture:** `MPGeometryAux.straightSegmentIntersection()` computes crossings; `TH2FileEditSplitMergeController.prepareSplitLinesAtCrossings()` builds an `MPMultipleElementsCommand` containing `MPAddLineCommand`s and a remove for each affected line — the same pattern as the existing `prepareSplitLineAtSelectedEndPoints`. No separate command class needed.

**Tech Stack:** Flutter/Dart, MobX, existing `MPAddLineCommand`, `MPMultipleElementsCommand`, `MPCommandFactory.removeLineFromExisting`, `THStraightLineSegment`, `THPositionPart`, `THEndline`.

---

## File Map

| Action | File |
|--------|------|
| Create | `lib/src/auxiliary/mp_geometry_aux.dart` |
| Modify | `lib/src/commands/types/mp_command_description_type.dart` |
| Modify | `lib/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart` |
| Modify | `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart` |
| Modify | `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_non_empty_selection.dart` |
| Modify | `lib/src/controllers/th2_file_edit_controller.dart` |
| Modify | `lib/src/controllers/th2_file_edit_split_merge_controller.dart` |
| Modify | `lib/src/widgets/th2_file_edit_body_widget.dart` |
| Modify | `lib/l10n/intl_en.arb` |
| Modify | `lib/l10n/intl_pt.arb` |
| Modify | `assets/help/en/.md` (keyboard shortcuts EN) |
| Modify | `assets/help/pt/keyboard_shortcuts_edit.md` (keyboard shortcuts PT) |
| Create | `test/0950-auxiliary_MPGeometryAux_test.dart` |
| Create | `test/2600-integration_split_lines_at_crossings_test.dart` |
| Create | `test/auxiliary/2026-03-30-002-two_straight_lines_crossing_once.th2` |
| Create | `test/auxiliary/2026-03-30-003-two_straight_lines_not_crossing.th2` |
| Create | `test/auxiliary/2026-03-30-004-three_straight_lines_multiple_crossings.th2` |

---

## Task 1: MPGeometryAux — geometry utility

**Files:**
- Create: `lib/src/auxiliary/mp_geometry_aux.dart`
- Create: `test/0950-auxiliary_MPGeometryAux_test.dart`

### Understanding the data model
In a `THLine`, `getLineSegments(th2File)` returns an ordered list `[seg0, seg1, ..., segN]` where each segment stores only its `endPoint`. The geometric line segment `j` (0-indexed) runs from `segs[j].endPoint.coordinates` to `segs[j+1].endPoint.coordinates`. A line with 4 points has 4 `THLineSegment` objects and 3 geometric segments.

- [ ] **Step 1: Write failing geometry tests**

Create `test/0950-auxiliary_MPGeometryAux_test.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_geometry_aux.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const double eps = 1e-9;

  group('MPGeometryAux.straightSegmentIntersection', () {
    test('X crossing in the middle returns correct point', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(10, 0),
        const Offset(5, -5), const Offset(5, 5),
      );

      expect(result, isNotNull);
      expect(result!.point.dx, closeTo(5.0, eps));
      expect(result.point.dy, closeTo(0.0, eps));
      expect(result.tA, closeTo(0.5, eps));
      expect(result.tB, closeTo(0.5, eps));
    });

    test('diagonal crossing returns correct point', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(10, 10),
        const Offset(0, 10), const Offset(10, 0),
      );

      expect(result, isNotNull);
      expect(result!.point.dx, closeTo(5.0, eps));
      expect(result.point.dy, closeTo(5.0, eps));
    });

    test('parallel segments return null', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(10, 0),
        const Offset(0, 1), const Offset(10, 1),
      );

      expect(result, isNull);
    });

    test('collinear segments return null', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(10, 0),
        const Offset(5, 0), const Offset(15, 0),
      );

      expect(result, isNull);
    });

    test('segments that cross only when extended return null', () {
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(4, 0),
        const Offset(5, -5), const Offset(5, 5),
      );

      expect(result, isNull);
    });

    test('T-intersection (endpoint on other segment) returns null', () {
      // p1 lies exactly on segment B — strict exclusive bounds exclude it
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(10, 0),
        const Offset(10, -5), const Offset(10, 5),
      );

      expect(result, isNull);
    });

    test('crossing very near endpoint returns null (exclusive bounds)', () {
      const double nearlyOne = 1.0 - 1e-11;
      final result = MPGeometryAux.straightSegmentIntersection(
        const Offset(0, 0), const Offset(10, 0),
        const Offset(nearlyOne * 10, -5), const Offset(nearlyOne * 10, 5),
      );

      expect(result, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
cd /devel/mapiah && flutter test test/0950-auxiliary_MPGeometryAux_test.dart
```
Expected: error — `mp_geometry_aux.dart` does not exist.

- [ ] **Step 3: Create `lib/src/auxiliary/mp_geometry_aux.dart`**

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';

/// Geometric intersection result for two straight segments.
typedef MPSegmentIntersection = ({Offset point, double tA, double tB});

/// Static geometry utilities used by Mapiah.
class MPGeometryAux {
  MPGeometryAux._();

  /// Returns the intersection of finite straight segments (p0,p1) and (p2,p3),
  /// or null if they do not cross strictly within both segments' interiors.
  ///
  /// Uses parametric form: P(t) = p0 + t*(p1-p0), Q(s) = p2 + s*(p3-p2).
  /// Both t and s must be in the open interval (epsilon, 1-epsilon).
  static MPSegmentIntersection? straightSegmentIntersection(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3, {
    double epsilon = 1e-10,
  }) {
    final double dx1 = p1.dx - p0.dx;
    final double dy1 = p1.dy - p0.dy;
    final double dx2 = p3.dx - p2.dx;
    final double dy2 = p3.dy - p2.dy;

    final double denom = dx1 * dy2 - dy1 * dx2;

    if (denom.abs() < epsilon) {
      return null; // parallel or collinear
    }

    final double dx0 = p2.dx - p0.dx;
    final double dy0 = p2.dy - p0.dy;

    final double tA = (dx0 * dy2 - dy0 * dx2) / denom;
    final double tB = (dx0 * dy1 - dy0 * dx1) / denom;

    if (tA <= epsilon || tA >= 1.0 - epsilon ||
        tB <= epsilon || tB >= 1.0 - epsilon) {
      return null;
    }

    final Offset point = Offset(p0.dx + tA * dx1, p0.dy + tA * dy1);

    return (point: point, tA: tA, tB: tB);
  }
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
cd /devel/mapiah && flutter test test/0950-auxiliary_MPGeometryAux_test.dart
```
Expected: All tests pass.

- [ ] **Step 5: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: add MPGeometryAux with straight segment intersection utility

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 2: Test fixtures

**Files:**
- Create: `test/auxiliary/2026-03-30-002-two_straight_lines_crossing_once.th2`
- Create: `test/auxiliary/2026-03-30-003-two_straight_lines_not_crossing.th2`
- Create: `test/auxiliary/2026-03-30-004-three_straight_lines_multiple_crossings.th2`

- [ ] **Step 1: Create `2026-03-30-002-two_straight_lines_crossing_once.th2`**

Two lines that cross exactly once: a horizontal line and a vertical line.

```
encoding UTF-8
scrap scrap1
  line wall -id line1
    0 0
    100 0
  endline
  line wall -id line2
    50 -50
    50 50
  endline
endscrap
```

Save to `test/auxiliary/2026-03-30-002-two_straight_lines_crossing_once.th2`.

Crossing: line1's geoSeg 0 (from (0,0) to (100,0)) crosses line2's geoSeg 0 (from (50,-50) to (50,50)) at (50,0). tA=0.5, tB=0.5.

After split:
- line1 → line1-1 (segments: [(0,0),(50,0)]) and line1-2 (segments: [(50,0),(100,0)])
- line2 → line2-1 (segments: [(50,-50),(50,0)]) and line2-2 (segments: [(50,0),(50,50)])

Each sub-line has 2 THLineSegment objects (the starting-point segment + one endpoint segment).

- [ ] **Step 2: Create `2026-03-30-003-two_straight_lines_not_crossing.th2`**

Two lines that do not cross (parallel horizontal lines).

```
encoding UTF-8
scrap scrap1
  line wall -id lineA
    0 0
    100 0
  endline
  line wall -id lineB
    0 10
    100 10
  endline
endscrap
```

Save to `test/auxiliary/2026-03-30-003-two_straight_lines_not_crossing.th2`.

- [ ] **Step 3: Create `2026-03-30-004-three_straight_lines_multiple_crossings.th2`**

Three lines where each pair crosses at least once. Use a triangle arrangement so each pair crosses exactly once.

```
encoding UTF-8
scrap scrap1
  line wall -id lineX
    0 0
    100 0
  endline
  line wall -id lineY
    0 100
    100 -100
  endline
  line wall -id lineZ
    100 100
    0 -100
  endline
endscrap
```

Crossings:
- lineX × lineY: horizontal (0,0)→(100,0) vs diagonal (0,100)→(100,-100). Intersection at y=0: 100-200t=0 → t=0.5, x=50. Cross at (50,0).
- lineX × lineZ: horizontal (0,0)→(100,0) vs diagonal (100,100)→(0,-100). At y=0: 100-200t=0 → t=0.5, x=50. Cross at (50,0). Wait, these cross at the same point! Let me recalculate.

Actually (100,100)→(0,-100): x=100-100t, y=100-200t. At y=0: t=0.5, x=50. Same point (50,0).

To avoid all three crossing at the same point, use different coordinates:

```
encoding UTF-8
scrap scrap1
  line wall -id lineX
    0 0
    120 0
  endline
  line wall -id lineY
    0 80
    120 -80
  endline
  line wall -id lineZ
    20 -60
    100 60
  endline
endscrap
```

- lineX × lineY: (0,0)→(120,0) vs (0,80)→(120,-80). y=0: 80-160t=0→t=0.5, x=60. Cross at (60,0).
- lineX × lineZ: (0,0)→(120,0) vs (20,-60)→(100,60). y=0: -60+120t=0→t=0.5, x=20+80*0.5=60. Same point again.

Let me try:

```
encoding UTF-8
scrap scrap1
  line wall -id lineX
    0 0
    100 0
  endline
  line wall -id lineY
    30 -50
    30 50
  endline
  line wall -id lineZ
    70 -50
    70 50
  endline
endscrap
```

- lineX × lineY: at (30, 0). tA=0.3, tB=0.5.
- lineX × lineZ: at (70, 0). tA=0.7, tB=0.5.
- lineY × lineZ: vertical lines at x=30 and x=70 — they are parallel, no crossing.

This is two crossings involving lineX, and lineY/lineZ don't cross each other. That's fine for the test — it verifies multi-crossing handling.

Save to `test/auxiliary/2026-03-30-004-three_straight_lines_multiple_crossings.th2`.

After split:
- lineX (2 crossings at t=0.3 and t=0.7): 3 sub-lines: lineX-1 (0,0)→(30,0), lineX-2 (30,0)→(70,0), lineX-3 (70,0)→(100,0)
- lineY (1 crossing at (30,0)): 2 sub-lines: lineY-1, lineY-2
- lineZ (1 crossing at (70,0)): 2 sub-lines: lineZ-1, lineZ-2

- [ ] **Step 4: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Test: add fixture files for split lines at crossings tests

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 3: Enum additions

**Files:**
- Modify: `lib/src/commands/types/mp_command_description_type.dart`
- Modify: `lib/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart`

- [ ] **Step 1: Add `splitLinesAtCrossings` to `MPCommandDescriptionType`**

In `lib/src/commands/types/mp_command_description_type.dart`, add after `splitLineAtSelectedPoints`:

```dart
  splitLineAtSelectedPoints,
  splitLinesAtCrossings,   // ← add this line
  toggleReverseOption,
```

Also add the opposite mapping at the end of `getOppositeDescription`. Find the `splitLineAtSelectedPoints` case and add after it. Search for where `splitLineAtSelectedPoints` appears in the switch — it's in the default/unhandled cases. Add:

```dart
      case MPCommandDescriptionType.splitLinesAtCrossings:
        return MPCommandDescriptionType.splitLinesAtCrossings;
```

(self-referential — splitting is not trivially reversible via description type alone; the undo is built by `MPMultipleElementsCommand`.)

- [ ] **Step 2: Add `splitLinesAtCrossings` to `MPButtonType`**

In `lib/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart`, add after `splitLineAtSelectedEndPoints` (keeping alphabetical order):

```dart
  splitLineAtSelectedEndPoints,
  splitLinesAtCrossings,   // ← add this line
  undo,
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```

Expected: warnings about unhandled enum cases in switches — these will be fixed in subsequent tasks.

- [ ] **Step 4: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: add splitLinesAtCrossings to MPCommandDescriptionType and MPButtonType enums

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 4: `hasAtLeastTwoSelectedLines` getter

**Files:**
- Modify: `lib/src/controllers/th2_file_edit_controller.dart`

- [ ] **Step 1: Find `hasSelectedLines` in `th2_file_edit_controller.dart`**

It's around line 344:
```dart
@computed
bool get hasSelectedLines => selectionController
    .mpSelectedElementsLogical
    .values
    .any((final MPSelectedElement e) => e is MPSelectedLine);
```

- [ ] **Step 2: Add `hasAtLeastTwoSelectedLines` immediately after**

```dart
@computed
bool get hasAtLeastTwoSelectedLines {
  int lineCount = 0;

  for (final MPSelectedElement element
      in selectionController.mpSelectedElementsLogical.values) {
    if (element is MPSelectedLine) {
      lineCount++;
      if (lineCount >= 2) {
        return true;
      }
    }
  }

  return false;
}
```

- [ ] **Step 3: Run dart build_runner (if not watching)**

The project runs `dart run build_runner watch` continuously, so the `.g.dart` file regenerates automatically. Verify by checking that no error appears.

- [ ] **Step 4: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```
Expected: No new issues.

- [ ] **Step 5: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: add hasAtLeastTwoSelectedLines computed getter to TH2FileEditController

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 5: `prepareSplitLinesAtCrossings` in the controller

**Files:**
- Modify: `lib/src/controllers/th2_file_edit_split_merge_controller.dart`

This is the core logic task. Read `prepareSplitLineAtSelectedEndPoints` (lines 35–224) in full before writing.

### Key concepts
- `getLineSegments(th2File)` returns `[seg0, seg1, ..., segN]`. Geometric segment `j` goes from `segs[j].endPoint.coordinates` to `segs[j+1].endPoint.coordinates`.
- A crossing at geometric segment `j` of a line is represented as `({int geoSegIdx, Offset crossPoint, double tOnSeg})`.
- After inserting a crossing point at `geoSegIdx=j`, a new `THStraightLineSegment` with `endPoint=crossPoint` is conceptually placed between `segs[j]` and `segs[j+1]` in the virtual list.
- Multiple crossings on the **same** geometric segment are ordered by `tOnSeg` ascending.
- When building sub-line commands for multiple lines, sort lines by their position in the parent scrap (ascending) and track a cumulative position offset.

### Crossing data typedef
Add this typedef near the top of the file (after imports, before the class):

```dart
typedef _CrossingData = ({int geoSegIdx, Offset crossPoint, double tOnSeg});
```

- [ ] **Step 1: Add imports to the controller**

At the top of `th2_file_edit_split_merge_controller.dart`, add:

```dart
import 'package:mapiah/src/auxiliary/mp_geometry_aux.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
```

Also ensure these are already present (they should be):
```dart
import 'package:mapiah/src/elements/th_element.dart'; // THEndline, THLine, THStraightLineSegment etc.
```

- [ ] **Step 2: Add the `_CrossingData` typedef and `_computeCrossings` helper**

Add after the class declaration but before `prepareSplitLineAtSelectedEndPoints`:

```dart
typedef _CrossingData = ({int geoSegIdx, Offset crossPoint, double tOnSeg});

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

          result
              .putIfAbsent(lineA.mpID, () => [])
              .add((
                geoSegIdx: k,
                crossPoint: hit.point,
                tOnSeg: hit.tA,
              ));
          result
              .putIfAbsent(lineB.mpID, () => [])
              .add((
                geoSegIdx: m,
                crossPoint: hit.point,
                tOnSeg: hit.tB,
              ));
        }
      }
    }
  }

  // Sort each line's crossings: by geoSegIdx asc, then tOnSeg asc.
  for (final List<_CrossingData> crossings in result.values) {
    crossings.sort((a, b) {
      final int segCmp = a.geoSegIdx.compareTo(b.geoSegIdx);

      if (segCmp != 0) {
        return segCmp;
      }

      return a.tOnSeg.compareTo(b.tOnSeg);
    });
  }

  return result;
}
```

- [ ] **Step 3: Add the `_buildSubLineCommandsForLine` helper**

Add after `_computeCrossings`:

```dart
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

  // Build virtual segment list: items are either an int (index into lineSegMPIDs)
  // or an Offset (crossing point to insert as a new straight segment).
  // Also track split indices in the virtual list.
  final List<dynamic> virtualSegs = [];
  final List<int> splitVirtualIndices = [];
  int crossingIdx = 0;

  for (int i = 0; i < lineSegMPIDs.length; i++) {
    virtualSegs.add(i);

    while (crossingIdx < crossings.length &&
        crossings[crossingIdx].geoSegIdx == i) {
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

    final int newLineMPID =
        mpLocator.mpGeneralController.nextMPIDForElements();
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
        final THLineSegment origSeg =
            _th2File.lineSegmentByMPID(lineSegMPIDs[vSeg]);

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
```

- [ ] **Step 4: Add `prepareSplitLinesAtCrossings`**

Add as a new `@action` method after `prepareSplitLineAtSelectedEndPoints`:

```dart
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

  final Map<int, List<_CrossingData>> crossingsPerLine =
      _computeCrossings(selectedLines);

  if (crossingsPerLine.isEmpty) {
    final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mpLocator.appLocalizations.noLinesAtCrossingsFound,
          ),
        ),
      );
    }

    return;
  }

  // Determine parent scrap (all selected lines must share the same scrap).
  final THIsParentMixin parentScrap =
      _th2File.lineByMPID(crossingsPerLine.keys.first).parent(
        th2File: _th2File,
      );

  // Sort affected lines by their position in the parent (ascending) so that
  // cumulative position offsets are computed correctly.
  final List<int> sortedLineMPIDs = crossingsPerLine.keys.toList()
    ..sort(
      (final int a, final int b) =>
          parentScrap
              .getChildPosition(_th2File.lineByMPID(a))
              .compareTo(parentScrap.getChildPosition(_th2File.lineByMPID(b))),
    );

  final List<MPCommand> outerCommands = [];
  int cumulativeOffset = 0;

  for (final int lineMPID in sortedLineMPIDs) {
    final THLine originalLine = _th2File.lineByMPID(lineMPID);
    final int originalLinePosition = parentScrap.getChildPosition(originalLine);
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

  // Re-select all resulting sub-lines.
  final List<THLine> newSubLines = _th2File
      .getLines()
      .where(
        (final THLine line) => !selectedLines.contains(line),
      )
      .toList();

  _th2FileEditController.selectionController.setSelectedElements(
    newSubLines,
    setState: false,
  );
}
```

- [ ] **Step 5: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```
Expected: No issues (or only the pre-existing enum switch warnings from Task 3 that will be fixed in Task 6).

- [ ] **Step 6: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: add prepareSplitLinesAtCrossings to TH2FileEditSplitMergeController

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 6: State machine wiring

**Files:**
- Modify: `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart`
- Modify: `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_non_empty_selection.dart`

- [ ] **Step 1: Add dispatch in `mp_th2_file_edit_state.dart`**

Find the `splitLineAtSelectedEndPoints` case (around line 306):
```dart
case MPButtonType.splitLineAtSelectedEndPoints:
  th2FileEditController.splitMergeController
      .prepareSplitLineAtSelectedEndPoints();
  return true;
```

Add immediately after it:
```dart
case MPButtonType.splitLinesAtCrossings:
  th2FileEditController.splitMergeController
      .prepareSplitLinesAtCrossings();
  return true;
```

- [ ] **Step 2: Add `Ctrl+Shift+X` keyboard shortcut in `mp_th2_file_edit_state_select_non_empty_selection.dart`**

Find the `LogicalKeyboardKey.keyX` case (around line 364):
```dart
case LogicalKeyboardKey.keyX:
  if ((isCtrlPressed || isMetaPressed) && !isShiftPressed) {
    if (isAltPressed) {
      th2FileEditController.areaLineCreationController
          .createMapConnectionLines();
      keyProcessed = true;
    } else {
      th2FileEditController.copyPasteController.cutSelectedElements();
      keyProcessed = true;
    }
  }
```

Replace with:
```dart
case LogicalKeyboardKey.keyX:
  if ((isCtrlPressed || isMetaPressed) && isShiftPressed && !isAltPressed) {
    th2FileEditController.stateController.onButtonPressed(
      MPButtonType.splitLinesAtCrossings,
    );
    keyProcessed = true;
  } else if ((isCtrlPressed || isMetaPressed) && !isShiftPressed) {
    if (isAltPressed) {
      th2FileEditController.areaLineCreationController
          .createMapConnectionLines();
      keyProcessed = true;
    } else {
      th2FileEditController.copyPasteController.cutSelectedElements();
      keyProcessed = true;
    }
  }
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: wire splitLinesAtCrossings to state machine and Ctrl+Shift+X shortcut

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 7: Localizations

**Files:**
- Modify: `lib/l10n/intl_en.arb`
- Modify: `lib/l10n/intl_pt.arb`

Run `flutter gen-l10n` after both files are edited.

- [ ] **Step 1: Add EN strings to `intl_en.arb`**

Find `"th2FileEditPageSplitLineAtSelectedEndPoints"` (around line 2264) and add the two new keys after its closing `},`:

```json
  "th2FileEditPageSplitLinesAtCrossings": "Split selected lines at crossings (Ctrl+Shift+X)",
  "@th2FileEditPageSplitLinesAtCrossings": {
    "description": "Tooltip for the split selected lines at crossings FAB. Used on: lib/src/widgets/th2_file_edit_body_widget.dart",
    "type": "text"
  },
  "noLinesAtCrossingsFound": "No crossings found between selected lines",
  "@noLinesAtCrossingsFound": {
    "description": "Snackbar message when selected lines have no crossings. Used on: lib/src/controllers/th2_file_edit_split_merge_controller.dart",
    "type": "text"
  },
```

- [ ] **Step 2: Add PT strings to `intl_pt.arb`**

Find `"th2FileEditPageSplitLineAtSelectedEndPoints"` and add after:

```json
  "th2FileEditPageSplitLinesAtCrossings": "Dividir linhas selecionadas nos cruzamentos (Ctrl+Shift+X)",
  "noLinesAtCrossingsFound": "Nenhum cruzamento encontrado entre as linhas selecionadas",
```

- [ ] **Step 3: Run gen-l10n**

```bash
cd /devel/mapiah && flutter gen-l10n
```
Expected: No errors. `lib/src/generated/i18n/` files updated.

- [ ] **Step 4: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: add EN/PT localizations for split lines at crossings feature

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 8: FAB button

**Files:**
- Modify: `lib/src/widgets/th2_file_edit_body_widget.dart`

- [ ] **Step 1: Add FAB button to `_selectNonEmptySelectionContextFABs`**

Find this button (around line 705):
```dart
_stateContextFABButton(
  heroTag: '${heroPrefix}_ctx_simplify_lines',
  onPressed: hasSelectedLines
      ? () => th2FileEditController.stateController.onButtonPressed(
          MPButtonType.simplifyLines,
        )
      : null,
  icon: Icons.auto_fix_normal,
  tooltip: appLocalizations.th2FileEditPageSimplifyLines,
),
```

Add before it (keeping the list alphabetically by tooltip is not required here, but add it after `simplify_lines_bezier` and before `open_option_window` — matching the keyboard shortcuts section ordering):

Actually, insert it after the `_ctx_open_option_window` button, before `_ctx_reverse_line`:

Find:
```dart
_stateContextFABButton(
  heroTag: '${heroPrefix}_ctx_reverse_line',
  onPressed: hasSelectedLines
      ? () => th2FileEditController.stateController.onButtonPressed(
```

Add before it:
```dart
_stateContextFABButton(
  heroTag: '${heroPrefix}_ctx_split_lines_at_crossings',
  onPressed: th2FileEditController.hasAtLeastTwoSelectedLines
      ? () => th2FileEditController.stateController.onButtonPressed(
          MPButtonType.splitLinesAtCrossings,
        )
      : null,
  icon: Icons.call_split,
  tooltip: appLocalizations.th2FileEditPageSplitLinesAtCrossings,
),
```

- [ ] **Step 2: Run flutter analyze**

```bash
cd /devel/mapiah && flutter analyze
```
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Feat: add split lines at crossings FAB button to selectNonEmptySelection context

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 9: Keyboard shortcuts help pages

**Files:**
- Modify: `assets/help/en/.md`
- Modify: `assets/help/pt/keyboard_shortcuts_edit.md`

- [ ] **Step 1: Uncomment EN shortcut**

In `assets/help/en/.md`, find:
```markdown
<!-- | Split selected lines at line crossings                     | Ctrl+Shift+X                 | -->
```
Replace with:
```markdown
| Split selected lines at crossings                          | Ctrl+Shift+X                 |
```

The table is alphabetically ordered. "Split selected lines at crossings" sorts after "Split line at selected line points" — verify the placement is correct.

- [ ] **Step 2: Uncomment PT shortcut**

In `assets/help/pt/keyboard_shortcuts_edit.md`, find:
```markdown
<!-- | Dividir linhas selecionadas nos cruzamentos de linhas                  | Ctrl+Shift+X                         | -->
```
Replace with:
```markdown
| Dividir linhas selecionadas nos cruzamentos de linhas                  | Ctrl+Shift+X                         |
```

- [ ] **Step 3: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Docs: uncomment Ctrl+Shift+X shortcut in EN/PT keyboard shortcuts help pages

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 10: Integration tests

**Files:**
- Create: `test/2600-integration_split_lines_at_crossings_test.dart`

- [ ] **Step 1: Write the test file**

Create `test/2600-integration_split_lines_at_crossings_test.dart`:

```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'th_test_aux.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

Map<String?, THLine> _linesByID(TH2File th2File) {
  return {
    for (final THLine line in th2File.getLines())
      MPCommandOptionAux.getID(line): line,
  };
}

Future<TH2FileEditController> _loadController(
  String filename,
  MPLocator mpLocator,
) async {
  final String path = THTestAux.testPath(filename);
  final TH2FileParser parser = TH2FileParser();
  final (parsedFile, isSuccessful, errors) = await parser.parse(
    path,
    forceNewController: true,
  );

  expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');
  expect(parsedFile, isA<TH2File>());

  final TH2FileEditController controller = mpLocator.mpGeneralController
      .getTH2FileEditController(filename: path);

  controller.setActiveScrap(controller.th2File.getScraps().first.mpID);

  return controller;
}

void _selectAllLines(TH2FileEditController controller) {
  for (final THLine line in controller.th2File.getLines()) {
    controller.selectionController.addSelectedElement(line);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  group('split lines at crossings', () {
    test(
      '2 straight lines crossing once → each splits into 2 sub-lines, undo restores',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-002-two_straight_lines_crossing_once.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        expect(th2File.getLines().length, 4);

        final Map<String?, THLine> byID = _linesByID(th2File);

        expect(byID.containsKey('line1-1'), isTrue);
        expect(byID.containsKey('line1-2'), isTrue);
        expect(byID.containsKey('line2-1'), isTrue);
        expect(byID.containsKey('line2-2'), isTrue);

        // Each sub-line has 2 THLineSegment objects (start + one endpoint).
        expect(byID['line1-1']!.getLineSegmentMPIDs(th2File).length, 2);
        expect(byID['line1-2']!.getLineSegmentMPIDs(th2File).length, 2);
        expect(byID['line2-1']!.getLineSegmentMPIDs(th2File).length, 2);
        expect(byID['line2-2']!.getLineSegmentMPIDs(th2File).length, 2);

        // Undo restores original state.
        controller.undo();

        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test(
      '2 straight lines crossing multiple times → correct sub-line counts, undo restores',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-001-2_straight_lines_intercepting.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        // Both original lines are gone.
        final List<THLine> resultLines = th2File.getLines().toList();

        expect(resultLines.length, greaterThan(2));

        // Every resulting line is a sub-line (has an ID ending in -N).
        for (final THLine line in resultLines) {
          final String? id = MPCommandOptionAux.getID(line);

          expect(id, isNotNull);
          expect(id, matches(RegExp(r'.+-\d+$')));
        }

        // Undo restores original 2 lines.
        controller.undo();

        expect(th2File.getLines().length, 2);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );

    test(
      '2 parallel lines (no crossing) → no changes, snackbar intended',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-003-two_straight_lines_not_crossing.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        // File unchanged: still 2 lines.
        expect(th2File.getLines().length, 2);
      },
    );

    test(
      '3 straight lines (lineX crossed by lineY and lineZ) → correct sub-line counts, undo restores',
      () async {
        final TH2FileEditController controller = await _loadController(
          '2026-03-30-004-three_straight_lines_multiple_crossings.th2',
          mpLocator,
        );
        final TH2File th2File = controller.th2File;
        final TH2File snapshotOriginal = TH2File.fromMap(th2File.toMap());

        _selectAllLines(controller);

        controller.splitMergeController.prepareSplitLinesAtCrossings();

        final Map<String?, THLine> byID = _linesByID(th2File);

        // lineX has 2 crossings → 3 sub-lines.
        expect(byID.containsKey('lineX-1'), isTrue);
        expect(byID.containsKey('lineX-2'), isTrue);
        expect(byID.containsKey('lineX-3'), isTrue);

        // lineY has 1 crossing → 2 sub-lines.
        expect(byID.containsKey('lineY-1'), isTrue);
        expect(byID.containsKey('lineY-2'), isTrue);

        // lineZ has 1 crossing → 2 sub-lines.
        expect(byID.containsKey('lineZ-1'), isTrue);
        expect(byID.containsKey('lineZ-2'), isTrue);

        // Total: 7 lines.
        expect(th2File.getLines().length, 7);

        // Undo restores original 3 lines.
        controller.undo();

        expect(th2File.getLines().length, 3);
        expect(th2File == snapshotOriginal, isTrue);
        expect(identical(th2File, snapshotOriginal), isFalse);
      },
    );
  });
}
```

- [ ] **Step 2: Run tests**

```bash
cd /devel/mapiah && flutter test test/2600-integration_split_lines_at_crossings_test.dart
```
Expected: All 4 tests pass.

- [ ] **Step 3: Run full test suite to confirm no regressions**

```bash
cd /devel/mapiah && flutter test
```
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Test: add integration tests for split lines at crossings

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```

---

## Task 11: CHANGELOG and TODO

**Files:**
- Modify: `CHANGELOG.md`
- Modify: `TODO.md` (if applicable)

- [ ] **Step 1: Update CHANGELOG.md**

Add an entry in the appropriate `Unreleased` / `Added` section:

```markdown
- Split selected lines at crossings: select 2+ lines and press Ctrl+Shift+X (or use the new FAB button) to split all lines at their mutual crossing points. Straight segments only; Bézier support is a future extension. (#XX)
```

- [ ] **Step 2: Check TODO.md**

Open `TODO.md` and mark any related items as done if applicable.

- [ ] **Step 3: Final flutter analyze and test run**

```bash
cd /devel/mapiah && flutter analyze && flutter test
```
Expected: All clean.

- [ ] **Step 4: Commit**

```bash
cd /devel/mapiah && git add -A && git commit -m "$(cat <<'EOF'
Docs: update CHANGELOG for split lines at crossings feature

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
Signed-off-by: Rodrigo Severo <rodrigo@fabricadeideias.com>
EOF
)"
```
