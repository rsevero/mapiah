<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Design: Split Selected Lines at Crossings

**Date:** 2026-03-30
**Status:** Approved

## Overview

When 2+ `THLine` elements are selected, the user can invoke a "split at crossings" command. Every pair of selected lines is checked for geometric intersections between their straight segments. Each intersecting segment is split at the crossing point, and each affected line is then divided into sub-lines at those points — following the same ID-suffix and option-inheritance convention as the existing "split at selected end points" feature.

Bézier segments are skipped silently in this version; Bézier support is a planned future extension.

---

## Trigger

- **Keyboard shortcut:** `Ctrl+Shift+X` (already reserved/commented-out in both EN and PT shortcut files)
- **FAB button:** new button in `_selectNonEmptySelectionContextFABs()` in `th2_file_edit_body_widget.dart`, enabled only when ≥ 2 selected elements are `THLine`s

---

## Architecture

### 1. Geometry Layer

**New file:** `lib/src/auxiliary/mp_geometry_aux.dart`

```dart
class MPGeometryAux {
  static Offset? straightSegmentIntersection(
    Offset p0, Offset p1,   // segment A endpoints
    Offset p2, Offset p3,   // segment B endpoints
    {double epsilon = 1e-10}
  );
}
```

Uses the parametric form:
- `P(t) = p0 + t*(p1-p0)`, `Q(s) = p2 + s*(p3-p2)`
- If `|denominator| < epsilon` → parallel/collinear → return null
- If both `t` and `s` are strictly in `(epsilon, 1-epsilon)` → return intersection point
- Strict-exclusive bounds prevent splitting at or very near existing segment endpoints

---

### 2. Controller

**File:** `lib/src/controllers/th2_file_edit_split_merge_controller.dart`

New method `prepareSplitLinesAtCrossings()`:

1. Gets selected line MPIDs from selection controller (must be ≥ 2)
2. Iterates all pairs of selected lines
3. For each pair, iterates all pairs of straight segments (one per line); Bézier segments skipped silently
4. Calls `MPGeometryAux.straightSegmentIntersection()` for each segment pair
5. Collects results grouped by line:
   `Map<int mpid, List<({int segmentIndex, double t, Offset crossPoint})>>`
6. If map is empty → shows snackbar ("No crossings found between selected lines")
7. Otherwise creates and executes `MPSplitLinesAtCrossingsCommand` with the pre-computed crossing data

Crossing data is pre-computed in the controller so the command receives clean, validated input.

---

### 3. Command

**New file:** `lib/src/commands/mp_split_lines_at_crossings_command.dart`

`MPSplitLinesAtCrossingsCommand extends MPCommand`

Receives pre-computed crossing data from the controller.

**`_prepareUndoRedoInfo`:**
Captures original state of all affected lines (original segment lists + line options/IDs) for undo.

**`_actualExecute`:**
For each affected line (crossings sorted by segment index descending, then by `t` descending, so later insertions don't shift earlier indices):
1. Splits each intersected straight segment `(A→B)` at crossing point `P` into two straight segments `(A→P)` and `(P→B)`, producing a new segment list for the line
2. Calls `applyReplaceLineSegments` to install the new segment list
3. Calls the existing split-into-sub-lines apply logic (same internals as `prepareSplitLineAtSelectedEndPoints`) to split the line at the newly-inserted crossing endpoints, following the same ID-suffix (`_1`, `_2`, …) and option-inheritance convention

All affected lines handled in one command → single undo step.

**`_createUndoRedoCommand`:**
Creates inverse command that removes sub-lines and restores original lines from captured state.

---

### 4. UI

**`MPButtonType` enum:** add `splitLinesAtCrossings`

**State machine:** wire `splitLinesAtCrossings` → `prepareSplitLinesAtCrossings()` in the same dispatch location as other split-merge button types

**FAB button** in `_selectNonEmptySelectionContextFABs`:
- Enabled only when `hasAtLeastTwoSelectedLines` (new getter: checks ≥ 2 selected elements are `THLine`)
- Icon: `Icons.call_split` (consistent with existing split button)
- Tooltip from localizations

**Keyboard shortcut:** uncomment `Ctrl+Shift+X` in:
- `assets/help/en/.md`
- `assets/help/pt/keyboard_shortcuts_edit.md`
- Wire handler in the existing shortcut dispatcher

**Localizations** (`lib/l10n/intl_en.arb` + `intl_pt.arb`):
- Button tooltip: `"Split selected lines at crossings"`
- Snackbar: `"No crossings found between selected lines"`

---

## Testing

### Geometry unit tests

**File:** `test/XXXX-auxiliary_MPGeometryAux_test.dart`

Cases:
- Two segments crossing in the middle → returns correct point
- Parallel segments → null
- Collinear/overlapping segments → null
- Segments that would cross if extended but not within bounds → null
- Crossing exactly at an endpoint → null (strict exclusive bounds)
- T-intersection (endpoint of one on the other) → null

### Command integration tests

**File:** `test/XXXX-commands_MPSplitLinesAtCrossingsCommand_test.dart`

| Fixture | Expected result |
|---------|----------------|
| `2026-03-30-001-2_straight_lines_intercepting.th2` (2 lines, multiple crossings) | Both split into correct number of sub-lines; correct IDs; correct segment counts; undo restores original |
| `2026-03-30-002-two_straight_lines_crossing_once.th2` | Both split into 2 sub-lines each; correct IDs; correct segment counts; undo restores original |
| `2026-03-30-003-two_straight_lines_not_crossing.th2` | Snackbar triggered; no changes to file |
| `2026-03-30-004-three_straight_lines_multiple_crossings.th2` | All lines split correctly; undo restores all |

### Test fixtures to create

- `test/auxiliary/2026-03-30-002-two_straight_lines_crossing_once.th2`
- `test/auxiliary/2026-03-30-003-two_straight_lines_not_crossing.th2`
- `test/auxiliary/2026-03-30-004-three_straight_lines_multiple_crossings.th2`

(`2026-03-30-001-2_straight_lines_intercepting.th2` already exists.)

---

## Out of Scope (Future)

- Bézier segment intersection (curve-curve, curve-straight)
- Splitting lines that cross non-selected lines
