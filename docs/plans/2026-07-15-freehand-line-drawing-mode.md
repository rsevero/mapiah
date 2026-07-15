<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Freehand Line Drawing Mode — Implementation Plan

**Date:** 2026-07-15  
**Status:** Proposed

## Goal

Add a dedicated freehand line drawing tool to the TH2 editor. A user should be
able to press and drag with a mouse, stylus, or finger, see the stroke while it
is being drawn, and release to create one normal, editable Therion `THLine`.

The captured stroke is simplified and stored as a **series of straight line
segments** made only of `THStraightLineSegment` elements, matching SexyTopo's
freehand representation.

The result remains an ordinary Mapiah line after creation. It uses the selected
line type/subtype and default options, can be edited with the existing line
editor, serializes normally to `.th2`, and is undone/redone as a single action.

## User Experience

### Entering and leaving the tool

- Add a **Freehand line** action beside the existing point/line/area creation
  actions.
- Assign `F` as the shortcut. It is currently unused in the editor shortcut
  table.
- Show the freehand action as pressed while its state is active.
- Use the precise cursor while idle and the grabbing/drawing cursor while a
  stroke is active.
- `Escape` while a stroke is active cancels only that stroke and remains in
  freehand mode. `Escape` with no active stroke returns to selection mode,
  following the normal state-machine behavior.

### Drawing a stroke

1. Primary-button/pointer down starts an in-memory stroke at the snapped start
   position.
2. Pointer moves append samples and repaint the preview immediately.
3. Primary-button/pointer up optionally snaps the final endpoint, simplifies
   the captured points into straight segments, and adds one `THLine` in one
   undoable command.
4. The tool remains active so the user can draw another line immediately.

A click/tap without a meaningful drag creates nothing. Mapiah has no useful
Therion line representation for a dot, so this intentionally differs from
SexyTopo's visible dot behavior.

### Straight-segment behavior

- Every committed stroke contains a straight move-to/start segment followed
  only by straight drawing segments.
- Show one localized status-bar message, for example:
  `Draw a freehand {type} line as a series of straight segments`.
- Simplification reduces redundant pointer samples without changing the output
  segment type.

Do not overload `MPNewLineCreationMethod`. Its existing values select how
control points are constructed in the click-based line tool; freehand is a
separate interaction state with different pointer lifetime and commit rules.

## SexyTopo Behaviors to Preserve

The design is based on the local SexyTopo implementation in:

- `control/graph/GraphView.java`, especially `handleDraw()`
- `model/sketch/Sketch.java`, especially `startNewPath()`, `finishPath()`, and
  `abandonActivePath()`
- `control/util/Space2DUtils.java`, especially its Douglas–Peucker
  simplification
- `model/sketch/PathDetail.java`

The corresponding upstream project is
[richsmith/sexytopo](https://github.com/richsmith/sexytopo).

Preserve the following qualities:

- Pointer-down starts a transient path, pointer-move extends it, and pointer-up
  commits it.
- The raw path is visible immediately while drawing.
- Simplification happens at commit time rather than interrupting capture.
- Start and end snapping do not distort intermediate freehand samples.
- An unfinished path can be abandoned without leaving file or undo artifacts.
- A completed path is one undoable user action.

Adaptations required for Mapiah:

- SexyTopo stores a path as a generic point list; Mapiah must create Therion
  straight line segments from that list.
- Mapiah should use SexyTopo's extent-relative simplification epsilon in
  canvas/data coordinates, independent of the current zoom.
- Mapiah must bound the sample buffer to comply with project loop/resource
  rules and to remain safe during very long stylus gestures.
- Mapiah must not execute one command per sampled point.

## Architecture

### 1. Add a dedicated state

Add `MPTH2FileEditStateType.addFreehandLine` and
`MPTH2FileEditStateAddFreehandLine`.

The new state should use the existing canvas-move and common keyboard mixins,
but own the primary-pointer behavior:

- `onStateEnter()` sets the cursor and localized status message.
- `onPrimaryButtonPointerDown()` starts capture.
- `onPrimaryButtonDragUpdate()` appends samples.
- `onPrimaryButtonDragEnd()` finishes and commits the stroke.
- `onPrimaryButtonClick()` abandons the one-point stroke because
  `MPListenerWidget` reports pointer-up as a click when its drag threshold was
  not crossed.
- `onStateExit()` always abandons an unfinished stroke.
- `Escape` abandons an active stroke before delegating to the common state
  behavior.

Wire the state through:

- `lib/src/state_machine/mp_th2_file_edit_state_machine/types/mp_th2_file_edit_state_type.dart`
- `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart`
- `lib/src/controllers/th2_file_edit_state_controller.dart`
- `lib/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart`

Add `MPButtonType.addFreehandLine`, dispatch it to the new state, and include it
in any state-controller allowlists that currently contain the other creation
states.

### 2. Add a focused freehand controller

Create
`lib/src/controllers/th2_file_edit_freehand_line_creation_controller.dart`
and instantiate it from `TH2FileEditController`.

Keep it separate from `TH2FileEditAreaLineCreationController`. That controller
creates and edits the file model incrementally for click-based drawing;
freehand capture should remain transient until pointer-up.

Suggested observable/runtime state:

```dart
ObservableList<Offset> sampledCanvasPoints
bool isCapturing
double activeSampleSpacingOnScreen
Rect? rawStrokeBoundingBox
```

Suggested public operations:

```dart
void startStroke(Offset screenPosition)
void appendStrokeSample(Offset screenPosition)
void finishStroke(Offset screenPosition)
void abandonStroke()
```

Responsibilities:

- Convert screen coordinates to canvas/data coordinates exactly once per
  accepted sample.
- Expand `rawStrokeBoundingBox` for every accepted sample before any buffer
  compaction.
- Apply snapping only to the first and final points through
  `TH2FileEditSnapController`.
- Trigger only the freehand preview repaint during capture.
- Build and execute the add-line command only from `finishStroke()`.
- Clear all transient state after success, cancellation, state exit, or an
  error. Log and surface unexpected errors rather than swallowing them.

### 3. Sample in screen space and bound the buffer

Pointer event density varies by device. Accept a move sample only when it is at
least `mpFreehandMinimumSampleSpacingOnScreen` logical pixels from the last
accepted sample. Always retain the first and final points.

Add named constants in `lib/src/constants/mp_constants.dart` for:

- minimum sample spacing in logical pixels
- minimum committed stroke length in logical pixels
- maximum retained sample count
- simplification extent divisor (`500`)
- minimum simplification epsilon (`0.001` canvas/data units)

Sample spacing and minimum committed stroke length are input-gesture concerns
and remain in logical screen pixels. Simplification is a geometry concern and
must not use the current canvas scale or zoom.

When the buffer reaches the maximum:

1. Keep the first point, every second interior point, and the latest point.
2. Double `activeSampleSpacingOnScreen` for the remainder of that stroke.
3. Continue capturing rather than truncating the line.

This gives every compaction loop a finite input and provides an explicit
fallback for arbitrarily long gestures. Unit-test the limit and compaction
behavior; do not pick an unbounded “large enough” list.

### 4. Simplify once on pointer-up

Use Mapiah's existing iterative Douglas–Peucker implementation in
`MPStraightLineSimplificationAux.raumerDouglasPeuckerIterative()`.

Calculate the epsilon exactly as SexyTopo does, from the raw accepted stroke's
bounding box in canvas/data coordinates:

```text
maxDimension = max(boundingBox.width, boundingBox.height)
epsilon = max(maxDimension / 500, 0.001)
```

Use the incrementally maintained bounding box from before sample-buffer
compaction or Douglas–Peucker removes any points. Compaction must not lose an
extreme point and accidentally change the epsilon. The epsilon is therefore
proportional to the stroke's spatial extent, has an absolute floor of `0.001`,
and is independent of zoom and pointer-event density. Put this calculation in
a small pure helper and document that its constants deliberately match
SexyTopo.

Conversion pipeline:

1. Remove consecutive duplicate points, including duplicates introduced by
   endpoint snapping.
2. Reject fewer than two distinct points or a stroke shorter than the named
   minimum length.
3. Create temporary `THStraightLineSegment` values, including the Therion
   move-to/start segment as element zero.
4. Calculate the SexyTopo epsilon from the unsimplified stroke bounding box.
5. Simplify with that epsilon.
6. Ensure simplification retained at least the first and final points.
7. Assert that every generated line segment is a
   `THStraightLineSegment`.

The simplifier expects at least two segment objects and treats their endpoints
as the polyline vertices, which matches Mapiah's first-segment-as-start-point
representation.

### 5. Produce a series of straight line segments

- Use the simplified temporary segment list directly.
- Assert that every child before `THEndline` is a
  `THStraightLineSegment`.
- Preserve the exact snapped first and last endpoints.
- Preserve line-segment ordering and append exactly one `THEndline`.

### 6. Commit one complete line and one undo entry

On successful finish:

1. Read `getLineTypeAndSubtypeForNewLine()`.
2. Create one `THLine` under `activeScrapID`.
3. Re-parent the generated segments to that line and append one `THEndline`.
4. Build subtype/default-option post-commands using the same rules as
   `addNewLineLineSegment()`.
5. Execute one `MPAddLineCommand` containing the complete child list.
6. Call `setUsedLineType()` and the normal final controller refresh path.

Extract the shared “new line + subtype + applicable default options” builder
from `TH2FileEditAreaLineCreationController` rather than copying it. A suitable
home is a small pure helper in `MPElementEditAux` or a command-factory method
that returns the prepared `MPAddLineCommand`.

Do not add the raw stroke to `TH2File`, execute `MPAddLineSegmentCommand` for
each sample, or simplify through a second command. The add and simplification
must appear as one atomic undo step described as `Add line`.

### 7. Render a low-latency preview

Create `MPAddFreehandLineWidget`, following the overlay structure used by
`MPAddLineWidget`, and include it in `TH2FileWidget` only while the new state is
active.

During capture:

- Paint the raw accepted samples as one continuous polyline using the existing
  new-line paint.
- Paint the snapped start point immediately.
- Do not create `THLineSegment` objects or run Douglas–Peucker on every move
  event.
- Repaint only the preview boundary, not all file elements.

This mirrors SexyTopo's immediate raw-path feedback and postpones the more
expensive work until pointer-up. The committed line may become slightly simpler
at release; that transition is expected.

### 8. Handle pointer cancellation explicitly

`MPListenerWidget` currently handles pointer down/move/up but has no canvas
`onPointerCancel` path. Add a cancellation callback to:

- `MPActuatorInterface`
- `MPListenerWidget`
- the base `MPTH2FileEditState`
- `MPTH2FileEditStateAddFreehandLine`

On primary-pointer cancellation, abandon the transient stroke and reset drag
flags. This covers focus loss, gesture-arena cancellation, and interrupted
touch/stylus input without accidentally committing a partial line.

Keep the existing click/drag threshold for deciding whether a tap is a stroke,
but continue receiving all move events after dragging begins. `startStroke()`
on pointer-down ensures the initial part hidden by that threshold is still
represented by the first point.

## Settings and UI File Map

### Main action

- Modify `lib/src/widgets/th2_file_edit_action_buttons_widget.dart` to expose
  the new tool in the expanded add-element row and to recognize it as the
  active action.
- Add a dedicated icon such as `assets/icons/add_element-addFreehandLine.png`
  that visually distinguishes a hand-drawn stroke from the existing node-based
  line icon.
- Add the mode to `TH2FileEditController.activeAddElementButton`,
  `isAddElementMode`, and any derived visibility/state getters.

### Localization

Add English and Portuguese strings for:

- Freehand line action and shortcut tooltip
- Freehand status-bar message

Edit `lib/l10n/intl_en.arb` and `lib/l10n/intl_pt.arb`, then run
`flutter gen-l10n`. Do not edit generated localization Dart files directly.

## Detailed Implementation Sequence

### Phase 1 — Pure capture and conversion logic

1. Add constants for sampling, minimum length, maximum samples, and the
   SexyTopo epsilon formula.
2. Extract the shared complete-line command builder from existing interactive
   line creation.
3. Implement the freehand controller's bounded sample buffer.
4. Implement duplicate removal and straight-segment simplification.
5. Unit-test these pieces before state/UI wiring.

### Phase 2 — State and pointer lifecycle

1. Add the new button and state enum values.
2. Add the freehand state and dispatch rules.
3. Add canvas pointer-cancel propagation.
4. Wire start/append/finish/abandon behavior.
5. Verify state exit, `Escape`, tap-without-drag, and repeated strokes.

### Phase 3 — Preview and discoverability

1. Add the preview widget and redraw trigger.
2. Add the main action icon/button and `F` shortcut.
3. Add all localized strings.
4. Update English and Portuguese help pages and shortcut tables.

### Phase 4 — Integration hardening

1. Test snapping and the extent-relative SexyTopo epsilon.
2. Test default options, subtype, decimal positions, and active scrap.
3. Test undo/redo and the `.th2` round trip.
4. Profile long stylus strokes and verify only the preview repaints during
   capture.
5. Run the full test suite and `flutter analyze`.

## Tests

Use the next available numeric prefixes and descriptive `_test.dart` names.

### Capture/simplification unit tests

- Pointer samples closer than the minimum spacing are ignored.
- First and final samples are always retained.
- Consecutive duplicate samples are removed.
- A one-point tap and a below-minimum-length stroke create nothing.
- A right-angle path retains its corner.
- A nearly collinear dense path simplifies to start/end only.
- Epsilon is `max(width, height) / 500` when that value exceeds `0.001`.
- Epsilon is exactly `0.001` for sufficiently small strokes.
- Epsilon uses the larger bounding-box dimension and is unaffected by zoom.
- Buffer compaction does not change epsilon even if it removes a point that
  established a bounding-box extreme.
- Reaching the maximum sample count compacts the buffer, increases spacing,
  retains both ends, and continues accepting later movement.
- Snapping affects only the first and final points.

### Straight-segment output tests

- A stroke creates a straight move-to segment plus only
  `THStraightLineSegment` drawing segments.
- The output preserves exact first/final endpoints.
- Decimal positions on generated `THPositionPart` values match the controller.

### State/widget tests

- `F` enters freehand mode and the action button is shown as active.
- Dragging renders a preview without adding elements or undo entries before
  release.
- Release adds exactly one `THLine` and one undo entry.
- Undo removes the complete line; redo restores the exact segment geometry.
- A second drag creates a second independent line without leaving the mode.
- `Escape`, pointer cancel, state change, and widget disposal abandon the
  active preview without modifying the file.
- A non-drag click clears its temporary start point and creates nothing.
- Mouse, touch, and stylus pointer kinds use the same geometry pipeline.

### Integration and serialization tests

- The current line type/subtype and applicable default options are attached.
- The line is added to the active scrap and ordered before its `THEndline`.
- Start/end snapping uses the existing grid/element snap behavior.
- Save and reload preserves the straight-segment geometry.
- Very long strokes remain responsive and never exceed the retained-sample
  bound.

## Documentation and Release Work

Update:

- `assets/help/en/th2_file_edit_page_help.md`
- `assets/help/pt/th2_file_edit_page_help.md`
- `assets/help/en/keyboard_shortcuts_edit.md`
- `assets/help/pt/keyboard_shortcuts_edit.md`
- `CHANGELOG.md`
- `TODO.md` if it contains a matching freehand item

Keep shortcut tables alphabetical and document that freehand drawing creates a
simplified series of straight line segments.

## Acceptance Criteria

- The TH2 editor exposes a discoverable freehand line tool operable by pointer
  drag and `F`.
- Every completed freehand line is a **series of straight line segments**.
- The raw stroke previews continuously while drawing.
- No file element or undo entry is created until pointer-up.
- A completed stroke is one editable `THLine` and one undo/redo action.
- Endpoint snapping works without snapping intermediate samples.
- Capture is bounded and remains usable after buffer compaction.
- Tap, cancellation, `Escape`, and state exit leave no artifacts.
- Existing click-based line creation behavior and its creation-method setting
  remain unchanged.
- English/Portuguese UI and help are updated.
- Relevant focused tests, the full Flutter test suite, and `flutter analyze`
  pass without warnings.

## Out of Scope

- Pressure-sensitive line width; Therion line geometry does not encode a
  variable brush width.
- Erasing only part of a line while drawing; use existing line editing after
  commit.
- Joining a new stroke automatically to an existing line. Endpoint snapping
  may make coordinates coincide, but the result remains a separate `THLine`.
- Freehand area creation or automatic closure.
- Per-device tuning UI for sample spacing in the first version. A named
  constant and isolated capture logic leave room for a later setting if field
  testing shows one is needed.
