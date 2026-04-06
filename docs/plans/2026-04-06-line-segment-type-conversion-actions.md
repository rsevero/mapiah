<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Line Segment Type Conversion Actions — Implementation Plan

## Goal

Add 2 new edit actions that convert line segments between the 2 supported segment types:

- Convert selected segments or selected lines to straight line segments
- Convert selected segments or selected lines to Bézier curve line segments

### Required UX

- Keyboard shortcuts:
  - `J`: convert to Bézier
  - `Shift+J`: convert to straight
- Add `_stateContextFABButton` actions in `TH2FileEditBodyWidget`
- Make both actions available in:
  - `MPTH2FileEditStateEditSingleLine`
    - Enabled when at least one non-start end point is selected
  - `MPTH2FileEditStateSelectNonEmptySelection`
    - Enabled when at least one line is selected
- Update help/docs
- Add tests for mixed and single-type lines, including undo

## Reuse Strategy

The codebase already has the most important low-level piece:

- `TH2FileEditUserInteractionController.prepareSetLineSegmentType()`
- `MPCommandFactory.setLineSegmentsType()`

That existing path already:

- Skips start points in single-line editing
- Converts selected non-start segments to the target type
- Preserves segment `mpID`, options, and attributes
- Produces undoable commands

The new work is mostly about exposing this capability as first-class actions in the right states, and adding a second conversion path for the “selected lines” state.

## Important Architectural Constraint

`MPCommandFactory.setLineSegmentsType()` assumes all `originalLineSegments` belong to the same parent line, because it resolves the previous line segment from `originalLineSegments.first.parentMPID`.

That means:

- `MPTH2FileEditStateEditSingleLine` can reuse the existing `prepareSetLineSegmentType()` directly
- `MPTH2FileEditStateSelectNonEmptySelection` cannot pass segments from multiple selected lines into a single `setLineSegmentsType()` call

So the line-selection action should build one conversion command per selected line, then wrap them in `MPCommandFactory.multipleCommandsFromList(...)`.

## File Map

### Core behavior

- Modify `lib/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart`
- Modify `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart`
- Modify `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_edit_single_line.dart`
- Modify `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_non_empty_selection.dart`
- Modify `lib/src/controllers/th2_file_edit_user_interaction_controller.dart`
- Optionally modify `lib/src/controllers/th2_file_edit_controller.dart`

### UI

- Modify `lib/src/widgets/th2_file_edit_body_widget.dart`

### Undo/redo text

- Prefer modifying `lib/src/commands/types/mp_command_description_type.dart`
- Prefer modifying `lib/src/auxiliary/mp_text_to_user.dart`
- Modify `lib/l10n/intl_en.arb`
- Modify `lib/l10n/intl_pt.arb`
- Run `flutter gen-l10n`

### Docs

- Modify `assets/help/en/keyboard_shortcuts_edit.md`
- Modify `assets/help/en/th2_file_edit_page_help.md`
- Modify `assets/help/pt/keyboard_shortcuts_edit.md`
- Modify `assets/help/pt/th2_file_edit_page_help.md`

### Tests

- Add a focused action/controller test for line-selection conversion
- Add a focused UI shortcut test for `J` / `Shift+J`
- Add or extend `.th2` fixtures under `test/auxiliary/` for:
  - mixed line
  - all-straight line
  - all-Bézier line

## Implementation Tasks

### 1. Add 2 explicit button/action types

Add new `MPButtonType` values:

- `convertLineSegmentsToBezier`
- `convertLineSegmentsToStraight`

Then wire them in `MPTH2FileEditState.onButtonPressed()` so they dispatch to the correct controller methods.

Recommended mapping:

- In single-line edit state:
  - call existing `prepareSetLineSegmentType(...)`
- In selection state:
  - call a new “selected lines” conversion method

To keep `onButtonPressed()` simple, prefer controller methods that branch internally based on current state or selection shape.

### 2. Add controller methods for both selection modes

Keep the existing method:

- `prepareSetLineSegmentType(...)`

Add a new method dedicated to line selection, for example:

- `prepareSetSelectedLinesLineSegmentType(...)`

Behavior:

- Iterate selected elements
- Keep only `MPSelectedLine`
- For each line:
  - fetch its line segments in order
  - skip the first segment, since it represents the start point and has no previous segment to convert from
  - keep only segments whose current type differs from the requested target type
  - if any remain, create one `MPCommandFactory.setLineSegmentsType(...)` command for that line
- Wrap all per-line commands in `MPCommandFactory.multipleCommandsFromList(...)`
- Execute once so undo restores all changed lines together
- Refresh selection/UI similarly to other edit actions

This approach avoids changing the existing command factory contract and keeps undo behavior predictable.

### 3. Add enablement helpers

The requested enablement differs by state, so the UI and keyboard handlers need explicit predicates.

Add a computed/helper for single-line editing, for example on `TH2FileEditController`:

- `hasSelectedNonStartEndPoints`

Suggested rule:

- true only when there is at least one selected end/control point whose line-segment position is not `0`
- false for empty selection
- false for control-point-only selection

The selection-state rule already exists:

- `hasSelectedLines`

### 4. Wire keyboard shortcuts

#### `MPTH2FileEditStateEditSingleLine`

Add `J` handling in `onKeyDownEvent(...)`:

- `J` with no Ctrl/Meta/Alt/Shift:
  - convert selected eligible segments to Bézier
- `Shift+J` with no Ctrl/Meta/Alt:
  - convert selected eligible segments to straight

Only mark the key as handled when the action is actually eligible.

#### `MPTH2FileEditStateSelectNonEmptySelection`

Add matching `J` / `Shift+J` handling:

- `J`:
  - convert all selected lines to Bézier segments
- `Shift+J`:
  - convert all selected lines to straight segments

Preserve existing `Ctrl+J` behavior for “join lines at coinciding extremities”.

Recommended ordering in the `keyJ` case:

- first check plain `J` / `Shift+J`
- then keep existing `Ctrl+J`

That prevents regressions and keeps the shortcut family consistent.

### 5. Add context FAB buttons

In `TH2FileEditBodyWidget` add 2 new `_stateContextFABButton(...)` entries to both:

- `_editSingleLineContextFABs(...)`
- `_selectNonEmptySelectionContextFABs(...)`

Recommended details:

- Straight action:
  - icon: `Icons.straighten`
- Bézier action:
  - icon: `Icons.gesture`

Enablement:

- edit-single-line context:
  - enabled only when `hasSelectedNonStartEndPoints`
- selection context:
  - enabled only when `hasSelectedLines`

Placement:

- put them close to the existing simplify/reverse/smooth line actions
- keep the line-edit action cluster grouped together

### 6. Add localized labels/tooltips

New tooltip strings will be needed for the 2 FAB actions.

Recommended keys:

- `th2FileEditPageConvertLineSegmentsToBezier`
- `th2FileEditPageConvertLineSegmentsToStraight`

Suggested English values:

- `Convert line segments to Bézier (J)`
- `Convert line segments to straight (Shift+J)`

Because these are new user-facing actions, update both:

- `lib/l10n/intl_en.arb`
- `lib/l10n/intl_pt.arb`

Then run:

- `flutter gen-l10n`

### 7. Improve undo/redo command description

The conversion can technically reuse `editLineSegmentType`, but explicit command descriptions will make undo/redo text clearer.

Preferred approach:

- Add new `MPCommandDescriptionType` values for:
  - converting to Bézier
  - converting to straight
- Map them in `MPTextToUser`
- Add localized strings in both `.arb` files

Use these descriptions:

- for single-line segment conversion
- for whole-line conversion in selection mode

If keeping scope smaller is more important than UX polish, reusing `editLineSegmentType` is acceptable, but the preferred implementation is to make undo text explicit.

### 8. Update help pages

#### `assets/help/en/keyboard_shortcuts_edit.md`

Add 2 rows in alphabetical order:

- `Convert selected line segments to Bézier curve`
- `Convert selected line segments to straight`

Shortcuts:

- `J`
- `Shift+J`

#### `assets/help/en/th2_file_edit_page_help.md`

Add a new section near other line operations, for example:

- `Convert line segments`

Document:

- availability in line-edit mode and selection mode
- eligibility rules in each state
- what happens on mixed lines
- that already-matching segments remain unchanged
- that the action is undoable
- keyboard shortcuts
- corresponding context FABs

Do the same updates in the PT help files for parity with the project guidelines.

## Test Plan

### 1. Single-line edit shortcut tests

Create or extend a widget test similar to `test/t3150_ui_simplify_line_ctrl_l_test.dart`.

Cover:

- open a file with a line in `editSingleLine` state
- select non-start end points
- press `J`
- verify converted segments are Bézier
- undo
- verify original file restored

And:

- press `Shift+J`
- verify converted segments are straight
- undo
- verify original file restored

Also add a guard case:

- only the start point selected
- `J` and `Shift+J` do nothing

### 2. Selection-state action tests

Add a non-widget action/controller test that selects whole lines and invokes the new selected-lines conversion method.

Required matrix:

- mixed line -> convert to straight -> undo
- mixed line -> convert to Bézier -> undo
- all-straight line -> convert to straight (no-op) -> no undo available
- all-straight line -> convert to Bézier -> undo
- all-Bézier line -> convert to Bézier (no-op) -> no undo available
- all-Bézier line -> convert to straight -> undo

Assertions should check:

- serialized TH2 output or exact segment runtime types
- unchanged cases do not create an unnecessary edit
- undo returns exactly to the original serialized form

### 3. Multi-line selection coverage

Add one test with 2 selected lines so we verify the line-selection implementation does not break on the multi-parent constraint of `setLineSegmentsType(...)`.

This is important because the per-line command grouping is the main new logic in selection mode.

### 4. FAB enablement smoke test

Add a widget-level smoke test for button enablement if practical:

- edit-single-line state with no eligible selected point -> disabled
- edit-single-line state with eligible non-start point -> enabled
- selection state with no selected line -> disabled
- selection state with selected line -> enabled

If this is too brittle at widget level, cover the predicate getters directly and keep FAB validation to a light smoke check.

## Suggested Fixtures

Add or reuse `.th2` fixtures that make segment types easy to inspect:

- one line with alternating straight/Bézier segments
- one all-straight line
- one all-Bézier line
- one file with 2 selectable lines

Keep them small and hand-readable so failures are easy to debug.

## Validation Checklist

- `flutter test` for all new/changed tests
- `flutter analyze`
- `flutter gen-l10n`

## Recommended Implementation Order

1. Add the line-selection controller method and tests first
2. Add new button types and `onButtonPressed()` wiring
3. Add `J` / `Shift+J` keyboard handling in both states
4. Add controller predicate(s) for enablement
5. Add context FAB buttons
6. Add localizations
7. Update EN/PT help pages
8. Run tests and analyze

## Expected Outcome

After implementation:

- `J` converts eligible segments/selected lines to Bézier
- `Shift+J` converts eligible segments/selected lines to straight
- actions are available from both keyboard and state-context FABs
- single-line edit mode only acts on selected non-start points
- selection mode acts on all selected lines
- mixed and single-type lines are covered
- undo restores the original geometry and segment types cleanly
