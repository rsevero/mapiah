<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 4: Drag and Drop, Context Menu, Shortcuts

**Date:** 2026-09-23  
**Status:** Proposed. Checked against the code at `a959868d` on 2026-09-23 (re-checked 2026-09-24, no code changes since). Revised on 2026-09-24: bring forward anchors each run on the sibling it steps over; every row has two drop zones, read by payload on scrap rows; selections that mix scraps with points, lines or areas are rejected; insertion lines show where elements land, even off screen; scraps are selected with Ctrl+click in a separate scrap selection; and modified clicks leave creation mode first. Revised again on 2026-09-24: forward anchors skip only elements that actually move; right-click selection runs in a new `onBeforeOpen` hook; plain clicks on scrap rows leave creation mode; Escape, a click on empty canvas and leaving selection mode clear the scrap selection, but selection-window zoom keeps it.  
**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md)  
**Prerequisite:** Phases 1–3 are in place: broken-file detection, `MPMoveElementsCommand` with `TH2HierarchyAux.validateMove`, and the read-only sidebar tree with `THProjectTreeRowContextMenuWidget` ([Phase 2 plan](2026-09-23-th2-element-tree-and-drawing-order-phase2-model-and-command.md), [Phase 3 plan](2026-09-23-th2-element-tree-and-drawing-order-phase3-sidebar-read-only.md)).  
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose

Phase 3 made the drawing order of a valid `.th2` file visible in the project sidebar. Phase 4 makes it editable, which is what issue #32 actually asks for:

- drag and drop of scrap, point, line and area rows, following the drop zones of parent plan §4.3;
- a right-click menu on element rows with **Bring forward**, **Send backward**, **Bring to front**, **Send to back** and **Move to scrap ▸** (parent plan §4.8);
- canvas keyboard shortcuts for the four order actions on the current selection.

Every edit goes through the Phase 2 `MPMoveElementsCommand`, so it is one undoable step, and through `TH2HierarchyAux.validateMove`, so a valid file stays valid. Broken files still have no edit actions.

## 2. Scope

### In scope

- Typed, localizable move-rejection reasons, including the element names for the area-border cases (§3.1).
- A pure move resolver used for hover feedback, no-op detection and the command factory (§3.2).
- Correct multi-element semantics for the four order actions (§3.3).
- `Ctrl`/`Shift` multi-selection of point, line and area rows, which parent plan §4.5 requires and Phase 3 did not build (§3.4).
- Scrap selection with `Ctrl`+click on scrap rows, kept apart from the canvas selection (§3.6).
- Opening the file's tab on the first edit made from the tree (§3.5).
- Drag sources, drop targets, insertion indicator, rejection feedback, scrap auto-expand and auto-scroll (§5).
- Element-row and scrap-row context menus (§6).
- Canvas shortcuts `Ctrl+]`, `Ctrl+[`, `Ctrl+Shift+]` and `Ctrl+Shift+[` (§7).
- EN/PT strings, EN/PT help and keyboard-shortcut pages, and one CHANGELOG entry (§8).

### Out of scope

- Moving elements between files. Cross-file drops are rejected with a reason.
- Keyboard focus and keyboard navigation inside the tree, including opening the menu with Shift+F10 or the Menu key.
- Selecting scraps on the canvas, and Shift+click range selection of scrap rows. A Shift+click on a scrap row behaves as a plain click.
- Moving comments with the element above or below them (parent plan §4.4 keeps them in place).
- Therion's own rendering order.
- Drag and drop while the tree filter is active (§5.1).

## 3. Existing constraints and prerequisite changes

### 3.1 Rejection reasons are internal strings

`MPHierarchyMoveCheck` (`lib/src/auxiliary/th2_hierarchy_aux.dart`) returns `reasonKey` strings such as `'line_border_shared'` and `'area_border_shared'`, with no way to name the line or area involved. Parent plan §3.1 wants messages like "Line X is also a border of area Y".

Change:

- Replace `String? reasonKey` with `MPHierarchyMoveRejection? rejection`, a new enum in the same file:

  | Value | Today's key | User-visible |
  |---|---|---|
  | `emptySelection` | `empty_selection` | no (never offered) |
  | `mixedScrapsAndDrawables` | new, checked right after `emptySelection` | specific |
  | `invalidTargetParent` | `invalid_target_parent` | generic |
  | `unknownElement` | `unknown_element` | generic |
  | `unsupportedElement` | `unsupported_element` | generic |
  | `scrapParentMustBeFile` | `scrap_parent_must_be_file` | specific |
  | `drawableParentMustBeScrap` | `drawable_parent_must_be_scrap` | specific |
  | `selfParent` | `self_parent` | generic |
  | `targetIsMoving` | `target_is_moving` | no (§5.3 never offers it) |
  | `targetNotChild` | `target_not_child` | generic |
  | `targetNotMovable` | `target_not_movable` | generic |
  | `lineBorderShared` | `line_border_shared` | specific, names line and area |
  | `areaBorderNotLine` | `area_border_not_line` | specific, names area |
  | `areaBorderWrongScrap` | `area_border_wrong_scrap` | specific, names line |
  | `areaBorderShared` | `area_border_shared` | specific, names line and area |
  | `brokenFile` | `broken_file` | generic |
  | `crossFile` | new, set by the tree (§5.3) | specific |

- **Mixed selections are rejected.** A move whose elements include both scraps and points, lines or areas is rejected with `mixedScrapsAndDrawables`, whatever the target. Today such a move is already rejected, but with `scrapParentMustBeFile` or `drawableParentMustBeScrap`, depending on the target, which names the wrong problem. The new check runs in `validateMove` before any per-element check, so drags, menu actions and shortcuts all get the same reason. It looks elements up with `tryElementByMPID` and skips MPIDs that are not in the file, so an unknown element is still reported as `unknownElement` by the per-element loop, not hidden or misreported by the mixed check.
- `MPHierarchyMoveCheck.rejected(rejection, {int? lineMPID, int? areaMPID})` carries the MPIDs of the elements the message names. For `lineBorderShared` and `areaBorderShared` the area is the first **non-moving** area that borders the line. It is one example of a missing area, not necessarily the only one: every area using the border must move together.
- `MPMoveElementsResult` changes the same way. Existing tests in `t2462` and `t3941` that assert string keys are updated to the enum.
- `TH2ElementTreeAux.moveRejectionMessage(check, th2File, appLocalizations)` builds the localized text (§8.1). Named elements use the row's plain label from the Phase 3 label builder (kind, type[:subtype], Therion id), so the message names them exactly as the tree shows them.

### 3.2 No-op detection only exists inside the command factory

`MPCommandFactory.moveElements` both validates and computes the effective move list (area border folding, file order), and returns `null` for a no-op. Hover feedback needs the same answer without building a command, many times per drag.

Change: move the order and folding logic out of the factory into `TH2HierarchyAux.resolveMoves(th2File, elementMPIDs:, newParentMPID:, beforeSiblingMPID:) → List<MPElementMove>`. It returns an empty list for a no-op. The factory calls it and returns `null` when it is empty. Hover calls `validateMove` and then `resolveMoves`; both are pure and read only the model. The tree caches the validation and move-resolution result per `(payload, targetRowId, zone, structureRevision)`, where `payload` is compared by identity, and clears the cache when a drag starts and when it ends, so moving the pointer inside one zone does not recompute it and a result is never reused for another drag. The insertion line's host row is not part of this cache: it depends on which rows are currently expanded (§5.4).

### 3.3 Order actions only look at the first element

`bringForward`/`sendBackward` in `th2_file_edit_element_edit_controller.dart` use only `ids.first` to compute the target. With a non-contiguous selection, for example `[a, c]` among `[a, b, c, d]`, `bringForward` asks to move both before `c`, which `validateMove` rejects (`targetIsMoving`). `bringToFront`/`sendToBack` gather the whole selection at one end, which is already correct.

Semantics for several selected siblings (all selected elements of a canvas selection share one parent, because selection only works inside the active scrap):

- **Bring forward:** every maximal run of adjacent selected movable siblings steps over the **one** non-selected movable sibling that follows it. Runs that are already last stay. Gaps between runs are kept. Example: `[a, B, c, D, e]` with `B` and `D` selected becomes `[a, c, B, e, D]`.
- **Send backward:** the mirror image.
- **Bring to front / Send to back:** unchanged; the selection keeps its relative order and goes to the end or the start of the parent.
- The whole action is **one** command and one undo step. It is a no-op, and creates no command, when every run is already at the boundary.

Implementation:

- Add `TH2HierarchyAux.resolveMoveGroups(th2File, parentMPID:, groups:)`, where each group is `(elementMPIDs, beforeSiblingMPID | afterSiblingMPID)`, with exactly one of the two anchors set (assert). It copies the affected parents' **full** `childrenMPIDs` lists once, then resolves each group against those same simulated lists, removing and inserting each element before calculating the next move's index. It never mutates `th2File`. `resolveMoves` delegates its single request to this shared resolver; `MPCommandFactory.moveElementGroups` calls it once and emits one `MPMoveElementsCommand` with the resulting moves, or no command when the final movable order is unchanged. Do not call the public `resolveMoves(th2File, ...)` separately for each group: each call would start from the original order. `MPMoveElementsCommand._prepareUndoRedoInfo` simulates the already resolved moves to record inverse positions; it does not resolve the forward indices.
- **Anchors are the stepped-over sibling.** Each group is anchored on the non-selected sibling it steps over, which is never an element of the action and so never moves while the action is resolved:
  - **Send backward:** `beforeSiblingMPID` = the non-selected movable sibling just before the run.
  - **Bring forward:** `afterSiblingMPID` = the non-selected movable sibling just after the run.
- **Resolving `afterSiblingMPID = X`** uses the same rule as a drop on the lower half of X's row (§5.2 "after T"), applied to the simulated list at that moment: insert before the next movable sibling of X that is not **moved** by the action, or before the scrap's `THEndscrap` (at file level: after the last scrap) when there is none. The element is **not** inserted directly after X, so comments and other hidden children between X and its next sibling stay in place (parent plan §4.4), and a menu action places elements exactly as the equivalent drop does.
- **"Moved" means an element of one of the groups**, not any selected element. A run that is already last stays and forms no group, so its elements are ordinary siblings for the other groups' anchors. `resolveMoveGroups` builds the skip set as the union of the groups' `elementMPIDs`. Example: forward `B` and `D` in `[a, B, c, D]`. `D` is already last and stays; the only group is `([B], after c)`. `c`'s next sibling `D` does not move, so `B` goes before it: `[a, c, B, D]`. Skipping every selected element would skip `D` and wrongly give `[a, c, D, B]`.
- Example: forward `B` and `D` in `[a, B, c, D, e]`. The groups are `([D], after e)` and `([B], after c)`. `D` after `e` finds no later movable sibling, so it goes to the end: `[a, B, c, e, D]`. `B` after `c` finds `e` (`D` is skipped, being moved by the action), so it goes before `e`: `[a, c, B, e, D]`. A before-anchor computed from the original list (`B` before `D`) would give `[a, c, e, B, D]` instead; this is why forward groups do not use one.
- Because no anchor ever moves, the result does not depend on the order the groups are processed in. The groups are still processed in file order of their first element, so the recorded move list, and therefore the command, is deterministic.
- `TH2HierarchyAux.validateMove` gains an optional `afterSiblingMPID`, exclusive with `beforeSiblingMPID` (assert). It gets the same checks as `beforeSiblingMPID`: it must not be moving (`targetIsMoving`), must be a child of the target parent (`targetNotChild`), and must be movable (`targetNotMovable`; unlike `beforeSiblingMPID`, `THEndscrap` is not accepted, since nothing can go after it).
- `_moveRelative` builds the runs from `_movableSiblingsOf(parent)` and calls it. A mixed selection (§3.1) is rejected with `mixedScrapsAndDrawables` before the runs are built, since scraps and points, lines or areas never share a parent. Otherwise, elements with different parents are not a valid input (assert); the tree and the canvas never produce them.
- Today `_moveRelative` goes through `moveElements`, and so through `checkMoveElements`, which rejects broken files. The group path must keep that: `_moveRelative` first returns `MPMoveElementsResult.rejected(brokenFile)` when the file is broken, then `rejected(mixedScrapsAndDrawables)` for a mixed selection, then validates every group with `TH2HierarchyAux.validateMove`, using that group's own elements as the moving set and its anchor as `beforeSiblingMPID` or `afterSiblingMPID`. If any group is rejected, the whole action is rejected with that group's rejection and no command is created. Only then does it call `MPCommandFactory.moveElementGroups`. `_moveToBoundary` keeps going through `moveElements` and needs no change.

### 3.4 The tree has no multi-selection

Parent plan §4.5 says rows support `Ctrl`/`Shift` multi-select. Phase 3 only implemented plain and double taps. Drag and the menu act on the selection, so Phase 4 adds it, keeping the Phase 3 rule that a row's highlight is its file controller's own selection:

- **Ctrl+click** (Meta on macOS, via `MPInteractionAux.isCtrlPressed()`/`isMetaPressed()`, as the canvas does) on an element row of the **active scrap** toggles that element in the selection with `selectionController.addSelectedElement(element, setState: true)`/`removeElementFromSelectedLogical(mpID, setState: true)`, so the selection state is set as the canvas does.
- **Shift+click** on an element row of the active scrap selects the range of visible element rows between the last clicked row (the anchor) and this row, inside that scrap, adding to the current selection. The anchor is the row id of the last plain or Ctrl click on a point, line or area row. It is kept in a new `rangeAnchorRowId` field of the shared `TH2ElementTreeTapTracker`, separate from the double-tap `_rowId`: `registerTap` clears `_rowId` when it completes a double tap, and Ctrl+clicks never call `registerTap`. Plain clicks set it next to `registerTap`, Ctrl+clicks set it directly, and `reset()` leaves it alone. It is cleared when it no longer names an existing visible row, or names a row of another scrap or file, in which case the Shift+click acts as a plain click and becomes the new anchor.
- A **modified click on a row of another scrap**, or of another file, behaves as a plain click: it switches the active scrap and selects only that element. Selection cannot span scraps (parent plan §4.5 assumed it could; the selection controller does not allow it, and Phase 4 keeps that rule).
- **Leaving creation mode first.** Ctrl+click and Shift+click on point, line and area rows first call `controller.stateController.onButtonPressed(MPButtonType.select)`, exactly as the plain tap does (Phase 3 plan §8), and only then toggle or extend the selection:
  - Plain taps, right-clicks (§6.2), Ctrl+click on scrap rows (§3.6) and every tree edit (§3.5) already leave creation mode this way; modified clicks must not be the exception.
  - Without it, `addSelectedElement(..., setState: true)` would switch state straight out of add-line, add-area or single-line edit, skipping the mode exit that finalizes an unfinished line (`finalizeNewLineCreation`).
  - The select button ends in `setSelectionState()` (`mp_th2_file_edit_state.dart`), and finalizing a line does not select it, so the toggle acts on exactly the selection the tree already highlights. In single-line edit, the edited line stays selected and the clicked element is added to it.
  - **Shift+click computes its range after the mode exit**, from the current visible rows, because finalizing an unfinished line can add a new row.
- Modified clicks never count toward a double tap.
- A modified click brings an open file's tab to the front, like a plain click, and never opens a tab.
- Selecting points, lines or areas this way clears the file's scrap selection (§3.6).

### 3.5 No "open the tab on the first edit" helper

Parent plan §4.2 requires that the first structural edit made from the tree on a tab-less file opens and activates the tab before the command runs, so the edit is visible and `Ctrl+Z`, Save and the close-tab prompt work.

Add `MPGeneralController.prepareTH2FileForTreeEdit(String th2FilePath) → TH2FileEditController?`:

1. Resolve the controller with `getTH2FileEditControllerIfExists`; return `null` unless it is loaded, not broken and has no `loadError`.
2. `addFileTab(path)`. It opens the tab if needed and always activates it.
3. `controller.stateController.onButtonPressed(MPButtonType.select)`, the same mode exit a tree tap uses (Phase 3 plan §8), so an in-progress line or area creation is finalized before its scrap is reordered.
4. Return the controller.

Every Phase 4 edit from the tree (drop, menu item) calls it first and does nothing when it returns `null`. Canvas shortcuts do not need it: their tab is already open and active.

### 3.6 Scraps cannot be selected safely through the canvas selection

`Ctrl`+click on scrap rows selects scraps, so drag, the menu and the canvas shortcuts can reorder several scraps at once. That selection is **not** stored in `mpSelectedElementsLogical`, the canvas selection:

- That map is read in 26 files: canvas painting, moving, snapping, option editing, copy and paste, and more. Most of them assume points, lines and areas.
- For example, `MPCommandFactory.moveElementsFromDeltaOnCanvas`, used by canvas drags and arrow keys in `MPTH2FileEditStateSelectNonEmptySelection`, throws `ArgumentError` for an `MPSelectedScrap`, and `addSelectedElement` silently ignores scraps.
- Today a scrap enters that map only briefly: the scraps dialog's right-click (`setSelectedScrapByMPID`) and the scrap copy, cut and duplicate helpers, which clear it again right away.

Making scraps a first-class canvas selection would mean auditing every one of those readers. Phase 4 instead gives each file a separate scrap selection:

- **Model:** `TH2FileEditSelectionController` gets `@observable ObservableSet<int> selectedScrapMPIDs`, with the actions `toggleSelectedScrap(int scrapMPID)` and `clearSelectedScraps()`, and a `selectedScrapMPIDsInFileOrder` getter. The build_runner watch regenerates the `.g.dart` file; do not run it manually. Ids that are no longer scraps of the file (after a scrap removal, its undo or a reload) are removed when `bumpStructureRevision` runs, and the getter skips them in any case.
- **Never mixed with points, lines and areas:** every method that puts points, lines or areas into `mpSelectedElementsLogical` (`addSelectedElement`, `addSelectedElements`, `setSelectedElements`) clears `selectedScrapMPIDs`. A Ctrl+click on a scrap row clears a non-empty canvas selection first. So at most one of the two is non-empty. The scraps dialog's temporary `setSelectedScrapByMPID` does not touch `selectedScrapMPIDs`.
- **Ctrl+click** (Meta on macOS) on a scrap row of a loaded, valid file:
  1. `onButtonPressed(MPButtonType.select)`, so line or area creation ends as for any tree selection;
  2. `setSelectedElements(<THElement>[], setState: true)` when the canvas selection is not empty, which leaves the editor in `selectEmptySelection`;
  3. `toggleSelectedScrap(scrapMPID)`.

  It does not change the active scrap. It brings an open file's tab to the front and never opens a tab, like the other modified clicks (§3.4), and never counts toward a double tap.
- **Plain click on a scrap row** first calls `onButtonPressed(MPButtonType.select)`, like a plain click on a point, line or area row, so an unfinished line is finalized (Phase 3's `_onScrapTap` only called `setActiveScrap`, which forces `selectEmptySelection` without that mode exit). It then makes the scrap active, as in Phase 3, and clears the scrap selection. **Shift+click on a scrap row** behaves as a plain click (§2).
- **Escape** also clears the scrap selection. Escape is handled in the shared `MPTH2FileEditStateKeyDownMixin`, which calls `deselectAllElements` and then sets `selectEmptySelection`; in `selectEmptySelection` that state change does nothing, so no state exit runs. `deselectAllElements` therefore calls `clearSelectedScraps()` itself.
- **A click on empty canvas** clears the scrap selection. `MPTH2FileEditStateSelectEmptySelection.onPrimaryButtonClick` calls `clearSelectedScraps()` when no element was clicked; a click on an element already clears it through `setSelectedElements`.
- **Leaving selection mode clears it.** `MPTH2FileEditStateSelectEmptySelection.onStateExit` calls `clearSelectedScraps()` whenever the next state is neither `selectEmptySelection` nor `selectionWindowZoom`, including when a drawing tool or another canvas navigation mode is entered. `selectionWindowZoom` is excluded for the same reason the canvas selection survives it today (`onStateExit` skips `onStateExitClearSelectionOnExit` and `onStateEnter` skips clearing when coming back from it): it is a short zoom that returns to `selectEmptySelection`, so the scrap selection is still there afterwards. This is separate from clearing `mpSelectedElementsLogical`: its existing exit helper does not know about the scrap selection. Returning to Select does not restore the old scrap selection. Entering `selectNonEmptySelection` by selecting a point, line or area already clears it through `addSelectedElement`/`setSelectedElements`.
- **The canvas never sees it.** The editor stays in `selectEmptySelection` while scraps are selected; leaving that state clears the scrap selection. Canvas drags, arrow keys, Delete, copy and paste and option editing never meet a scrap. The canvas does not draw the scrap selection; the tree shows it.
- **Tree highlight:** while a file's scrap selection is non-empty, the selected scrap rows get the `secondaryContainer` fill, and the active scrap row loses it unless it is selected. Otherwise the active scrap row keeps its Phase 3 fill. The active scrap row always shows its label in bold, so it stays recognizable while scraps are selected.
- **Uses:** drag (§5.1), the scrap-row context menu (§6.2) and the canvas shortcuts (§7) act on the scrap selection. A scrap move keeps it (§4), so a shortcut can be pressed repeatedly.

## 4. Where the edit lands and what is selected afterwards

- **Undo location:** the file's own `MPUndoRedoController`, as for any canvas edit. Because the tab is active after §3.5, `Ctrl+Z` undoes the tree edit right away.
- **Selection after an executed drop or menu action on points, lines and areas:** the active scrap becomes the target scrap and the moved elements become the selection (`setActiveScrap`, then `setSelectedElements(..., setState: true)`). A rejected or no-op result does not apply this selection change. The user sees where executed moves went, on the canvas and in the tree. Border lines folded into an area move (Phase 2) are not added to the selection.
- **Scrap moves** change neither the active scrap nor the selection, including the scrap selection (§3.6).
- **Undo and redo** keep today's rule from `executeMoveElements`: an element that leaves the active scrap is deselected.

## 5. Drag and drop

### 5.1 Drag sources

- Element rows (scraps, points, lines, areas) of loaded, valid files are wrapped in `Draggable<TH2ElementTreeDragPayload>`, with `pointerDragAnchorStrategy`, following `mp_available_scraps_widget.dart`. Desktop only, so plain `Draggable`, not `LongPressDraggable`. The `InkWell` tap still wins for clicks; a drag starts only after the pointer passes the drag slop.
- **Payload** (a small immutable class in `th2_element_tree_aux.dart`, instead of the bare `List<int>` the parent plan names, because cross-file rejection needs the file):

  ```dart
  final class TH2ElementTreeDragPayload {
    final String th2FilePath;                 // canonical path
    final TH2FileEditController controller;   // identity, to detect Reload
    final List<int> elementMPIDs;             // file order
    final bool isScrap;                       // every element is a scrap
  }
  ```

- **What is dragged:**
  - a point, line or area row that is **selected**: the whole selection of its file, in file order;
  - a point, line or area row that is **not selected**: that element only. Starting the drag does not change the selection; the drop does (§4);
  - a scrap row that is **selected** (§3.6): every selected scrap of its file, in file order;
  - a scrap row that is **not selected**: that scrap only, without changing the scrap selection.
- **Mixed selections.** A selection can hold a scrap next to points, lines or areas only in edge cases (the scraps dialog selects scraps with `setSelectedScrapByMPID`, and a Ctrl+click can then add an element). Dragging a row of such a selection still drags the whole selection, and every target rejects it with `mixedScrapsAndDrawables` (§3.1); the drag never silently drops part of it. `isScrap` is `true` only when every dragged element is a scrap; for a mixed payload the zones below are read as for points, lines and areas, which does not matter since every drop is rejected.
- **Feedback widget:** a `Material` with `mpDragFeedbackOpacity`, showing the dragged row's icon and label, plus "N elements" (`th2ElementTreeDragCount`) when more than one element moves. It also shows the current rejection reason, if any (§5.4).
- **Dragged rows** are drawn dimmed (the same `Opacity` as the scraps dialog uses for the dragged row) until the drag ends.
- **No drag while filtering.** With a filter active, the visible rows hide most siblings, so an insertion line between two visible rows would not show where the element really lands. Rows are not draggable while `THProjectTreeUIController` has a filter; the context menu still works.

### 5.2 Drop targets and zones

Every element row and every TH2 file row is a `DragTarget<TH2ElementTreeDragPayload>`. Other project rows are not targets, so hovering them shows no indicator.

The zone comes from the pointer's local y inside the row, from `DragTargetDetails.offset` converted with the row's `RenderBox.globalToLocal`, in `onMove`. **Every row has two zones**, its upper and lower half, split at `mpProjectTreeDropZoneHalfFraction = 1 / 2` (a constant, not a magic number). No row has three zones, so there is never a dead or ambiguous middle.

What the halves mean depends on the row and, for scrap rows, on what is being dragged. A payload is either all scraps or all points, lines and areas (§3.1):

- **Point, line and area rows:** before or after the row. They cannot contain anything.
- **Scrap rows:**
  - dragging **points, lines or areas**: the start or the end of that scrap. They can only go into a scrap, so "before" or "after" a scrap would always be rejected;
  - dragging **scraps**: before or after that scrap. A scrap cannot go into a scrap, so "into" would always be rejected.
- **File rows:** the start or the end of the file. "Before" or "after" a file row would mean leaving the file, which cross-file moves do not allow.

| Hover zone on target row T | Dragging points, lines or areas | Dragging scraps |
|---|---|---|
| upper half of a **point, line or area** row | before T, under T's scrap | rejected (`scrapParentMustBeFile`) |
| lower half of a **point, line or area** row | after T, under T's scrap | rejected (`scrapParentMustBeFile`) |
| upper half of a **scrap** row | at the start of that scrap | before T, under the file |
| lower half of a **scrap** row | at the end of that scrap | after T, under the file |
| upper half of the **file** row | rejected (`drawableParentMustBeScrap`) | at the start of the file |
| lower half of the **file** row | rejected (`drawableParentMustBeScrap`) | at the end of the file |

Every drop of a mixed payload is rejected with `mixedScrapsAndDrawables`. A scrap row that is being dragged is not a target at all (§5.3).

Dropping several elements gathers them into one block in file order, unlike Bring forward (§3.3), which keeps the gaps between runs. For example, `[a, B, c, D, e]` with `B` and `D` dropped on the lower half of `e` gives `[a, c, e, B, D]`, and on its upper half gives `[a, c, B, D, e]`.

Translating a request into `validateMove` arguments:

- **before T:** `beforeSiblingMPID = T`.
- **after T:** `beforeSiblingMPID` = the next **movable** sibling of T in the full `childrenMPIDs` (scrap, point, line or area) that is **not being dragged**, or, if there is none, the scrap's `THEndscrap` (inside a scrap) or `null` (at file level). Hidden children between T and that sibling stay where they are, as parent plan §4.4 requires. For a scrap T, "after T" is after its whole `scrap … endscrap` block, whether the row is expanded or not.
- **start of scrap S:** the first movable child of S that is not being dragged, or S's `THEndscrap` when there is none.
- Skipping dragged siblings matters: hovering the lower half of the row just above a dragged row (or the upper half of a scrap whose first child is dragged) would otherwise name the dragged element as `beforeSiblingMPID`, and `validateMove` would reject the drop with `targetIsMoving` instead of treating it as the no-op it is. With the skip, `targetIsMoving` can never come from the tree, as the §3.1 table says.
- **end of scrap S:** S's `THEndscrap`.
- **start of file:** the first scrap of the file that is not being dragged, or `null` when there is none. Hidden children before the first scrap, such as the `encoding` line and header comments, stay above it.
- **end of file:** `null`.

### 5.3 Hover evaluation

On each zone change the target:

1. Rejects with `crossFile` when `payload.th2FilePath` differs from the row's file.
2. Ignores the hover (no indicator, no message) when the payload's controller is no longer the file's registered controller, or when the target row is one of the dragged elements. Hovering the dragged rows themselves is neither a valid target nor an error.
3. Calls `checkMoveElements` with the §5.2 arguments. A rejection shows the rejection feedback.
4. Otherwise calls `TH2HierarchyAux.resolveMoves`. An empty result (the drop would change nothing, for example just below the dragged row) shows no indicator and makes the drop do nothing.
5. Otherwise shows the insertion indicator.

`onWillAcceptWithDetails` returns `true` for every payload, so `onMove`/`onLeave` keep firing and the target can show rejection feedback. `onAcceptWithDetails` repeats steps 1–4 against the current model and runs the move only for step 5; a rejected or no-op drop creates no command.

The per-drag hover state (current payload, target row id, zone, semantic placement such as "end of scrap", and cached validation/move result) lives in a small `TH2ElementTreeDragController` owned by `THProjectTreeWidget` state (a `ChangeNotifier`, not MobX, because it is UI-only and short-lived). It does not store the insertion line's host row. It is reset in the `Draggable`'s `onDragStarted`, which also stores the new payload, and in `onDragEnd`, `onDraggableCanceled` and `onDragCompleted`. The cache key includes the payload (§3.2), so a result from one drag is never reused for another, even if a reset is missed.

### 5.4 Feedback

- **Insertion line:** a `mpDragDropIndicatorHeight` bar in `colorScheme.secondary`, as in the scraps dialog, drawn **over** the row edge (a `Stack` overlay, not an `AnimatedContainer` that pushes rows down, so rows do not jump while the pointer moves). It is indented to the depth of the parent that will receive the element: file depth + 1 for scraps, scrap depth + 1 for PLAs.
- **Where the line is drawn.** The line marks where the elements will land, which is not always an edge of the hovered row. On each `THProjectTreeWidget` list rebuild, derive the **host row** and edge once from the drag controller's semantic placement and that build's `visibleRows`; pass the derived location to the rows. The list rebuilds both when the drag controller changes hover state and when MobX rebuilds `visibleRows` after expansion or collapse. Do not store or cache the host row in the drag controller, and do not re-run `validateMove` or `resolveMoves` just because a scrap expanded. For "end of scrap", an expanded scrap's last child hosts the line; when collapsed, its scrap row hosts it. This recalculation moves the line after auto-expand even if the pointer stays still. `ListView.builder` only builds rows on screen, so a host row that is off screen simply draws nothing, with no visibility check. Auto-scroll shows the line once the host row scrolls into view.
  - **before T:** the hovered row's top edge, as in the scraps dialog.
  - **after a point, line or area T:** the hovered row's bottom edge.
  - **after a scrap T:** the bottom edge of the **last visible row of T**: its last child row when T is expanded, T's own row when it is collapsed. It is indented to file depth + 1, like any line for scraps, so it reads as "after this whole scrap". On a long expanded scrap it may be off screen.
  - **start of scrap:** always a line, on the bottom edge of the scrap row, indented to scrap depth + 1. On an expanded scrap this is exactly above its first child.
  - **start of file:** always a line, on the bottom edge of the file row, indented to scrap depth. On an expanded file this is exactly above its first scrap.
  - **end of file:** a line on the bottom edge of the **last visible row of the file**: the last scrap's last child row when that scrap is expanded, the last scrap row when it is collapsed, and the file row itself when the file is collapsed. It is indented to scrap depth. It is often off screen, as the end of a long file is far below its row.
  - **end of scrap:** a line on the bottom edge of the **last visible row of the scrap**: its last child row when the scrap is expanded, the scrap row itself when it is collapsed. It is indented to scrap depth + 1, like any line for points, lines and areas. After the auto-expand delay (§5.5) the scrap expands and the line moves under its last child. On a long expanded scrap the line may be off screen, like the end-of-file line.
- **Outline.** For "start of scrap", "end of scrap", "start of file" and "end of file", the hovered row also gets a `colorScheme.secondary` outline, with a trailing icon that tells the two halves apart: `Icons.vertical_align_top` for the start and `Icons.vertical_align_bottom` for the end. The outline and icon are the only visible signal when an end-of-scrap or end-of-file line is off screen, and on a collapsed scrap or file, where the start and end lines sit on the same bottom edge. Before and after a row (including a scrap row while dragging scraps) get no outline: the line is enough.
- **Rejection:** the row under the pointer gets a `colorScheme.error` outline, the feedback widget shows a `Icons.block` icon and the localized reason in `colorScheme.error`, and the row's `MouseRegion` sets `SystemMouseCursors.forbidden`. The reason text in the feedback widget is the primary signal, because desktop platforms do not always update the cursor while a button is held; the cursor is best effort.
- Nothing about rejection is shown as a `Tooltip`: tooltips do not appear while a pointer button is down.

### 5.5 Auto-expand and auto-scroll

- **Auto-expand:** while dragging points, lines or areas, hovering a **collapsed** scrap row (either half) for `mpProjectTreeDragHoverExpandDelayMilliseconds` (new constant, 700 ms) calls `toggleTH2ScrapCollapsed` to expand it. The timer is cancelled when the pointer leaves the row; moving between the two halves does not restart it. Dragging scraps never auto-expands a scrap, since a scrap cannot be dropped into one. A scrap expanded this way stays expanded after the drag; this matches file managers and avoids the tree jumping back on drop. Collapsed file rows are not auto-expanded, because both file-row zones already mean something ("start of file" and "end of file").
- **Auto-scroll:** Flutter's `EdgeDraggingAutoScroller` (not yet used anywhere in Mapiah) takes the list's `ScrollableState`, not a `ScrollController`, and the `ListView.builder` in `th_project_tree_widget.dart` does not expose it. So:
  - The drag controller creates the auto scroller when the drag starts, with `EdgeDraggingAutoScroller(Scrollable.of(context), onScrollViewScrolled: ..., velocityScalar: mpProjectTreeDragAutoScrollVelocityScalar)`. The `context` is the source row's, which is inside the list's `Scrollable`. It keeps that `ScrollableState` reference for the rest of the drag, because the source row can scroll out of view and be disposed while the drag goes on.
  - The source row records the initiating pointer id on primary `PointerDownEvent`. At `onDragStarted`, the tree-owned drag controller receives that id and installs a `GestureBinding.instance.pointerRouter` global route for the active pointer. The route records each `PointerMoveEvent`'s global position and calls `startAutoScrollIfNecessary` with a global `Rect` centred on the pointer, `mpProjectTreeDragAutoScrollEdgeExtent` tall. The scroller starts scrolling when that rect reaches past the top or bottom edge of the viewport. This route belongs to `THProjectTreeWidget` state, not the source `Draggable`: Flutter stops calling `Draggable.onDragUpdate` after its row is disposed by scrolling. `DragTarget.onMove` still evaluates drop feedback, but it is not responsible for keeping auto-scroll alive.
  - `onScrollViewScrolled` re-evaluates the hovered row and insertion indicator from the last pointer position and the current visible rows, even when the pointer has not moved. It also calls `startAutoScrollIfNecessary` again while the drag is active. This keeps feedback aligned with rows that move under a stationary pointer.
  - One idempotent drag-end method stops auto-scroll, removes the global pointer route and clears the stored pointer id and position. `onDragEnd`, `onDraggableCanceled`, `onDragCompleted` and `THProjectTreeWidget.dispose` call it. `onDraggableCanceled` and `onDragCompleted` must perform cleanup even if the source row was disposed, because Flutter does not call that row's `onDragEnd` when it is unmounted.
  - The list still gets a `ScrollController`, but only so that tests can read the scroll offset. The auto scroller does not use it.

### 5.6 Drop

On an accepted, valid, non-no-op drop:

1. `prepareTH2FileForTreeEdit(path)` (§3.5). Stop if it returns `null`. Exiting line or area creation can finalize an element and change the model after the hover check.
2. Against the returned controller's **current** model, confirm the payload still belongs to its registered controller, the target row still exists, and the §5.2 request is still valid and non-no-op. Recompute the target sibling from the current `childrenMPIDs`; do not reuse the hover's cached request or move list. Stop without issuing a move if any check fails. The tab opened in step 1 stays open: this only happens when the model changed between hover and drop (usually by the line finalized in step 1), and closing the tab again would be more surprising than leaving it open.
3. Call `elementEditController.moveElements(...)` with that current request. It validates again and returns `executed`, `noOp` or `rejected`; only `executed` proceeds to step 4.
4. Apply the §4 selection.

## 6. Context menus

### 6.1 Contents

Element and scrap rows of loaded, valid files are wrapped in the Phase 3 `THProjectTreeRowContextMenuWidget`, whose builder is called on every right-click, so the items always reflect the current model.

| Row | Items |
|---|---|
| point, line or area | Bring forward, Send backward, Bring to front, Send to back, divider, Move to scrap ▸ |
| scrap | Bring forward, Send backward, Bring to front, Send to back |
| status rows, file rows | unchanged from Phase 3 (Reload for broken and load-error files) |

- The order items act on the **menu target** (§6.2) and call `bringForward`, `sendBackward`, `bringToFront` and `sendToBack` (§3.3).
- **Move to scrap ▸** is a `SubmenuButton` listing every other scrap of the file, in file order, by its row label. The current scrap is left out. Each entry calls `moveElementsToScrap` with no `beforeSiblingMPID` (end of the target scrap). The submenu is not shown when the file has only one scrap.
- **Disabled items:** an item whose action would be a no-op (already first or last) is disabled (`onPressed: null`). An order item whose action would be rejected, for example on a mixed selection (§3.1), is disabled the same way and shows the reason in a second line, like a rejected "Move to scrap" entry. A "Move to scrap" entry that `checkMoveElements` rejects is disabled, and its label is followed by the reason in a second, smaller line. A second line is used instead of a tooltip because it is visible without hovering and also works with keyboard navigation inside the open menu.
- Icons: `Icons.flip_to_front` (bring to front), `Icons.flip_to_back` (send to back), `Icons.arrow_upward`/`Icons.arrow_downward` for forward/backward, `Icons.drive_file_move_outline` for Move to scrap. Up and down follow the tree, where later (drawn on top) is lower; so **Bring forward uses `Icons.arrow_downward`** and Send backward uses `Icons.arrow_upward`. The help page explains this, and the menu labels, not the icons, carry the meaning.
- Every action runs `prepareTH2FileForTreeEdit` first. It then checks that the menu target still exists and resolves the action against the current model, because leaving creation mode can change the file after the menu was built. It applies the §4 selection only when the action returns `executed`; a stale disabled/enabled state in the open menu cannot bypass move validation.
- Keys follow the Phase 3 convention: `ValueKey('THProjectTreeRowContextMenuBringForward|<rowId>')`, `…SendBackward|…`, `…BringToFront|…`, `…SendToBack|…`, `…MoveToScrap|<rowId>` for the submenu and `…MoveToScrap|<rowId>|<scrapMPID>` for its entries.

### 6.2 Does right-click select? (the decision Phase 3 left to Phase 4)

**Yes, for point, line and area rows, following file managers:**

- Right-click on a **selected** row keeps the whole selection; the menu acts on it.
- Right-click on an **unselected** row first applies the selection steps of the Phase 3 single tap, then opens the menu, which acts on that element. `THProjectTreeRowContextMenuWidget` gets an optional `VoidCallback? onBeforeOpen`, called in `_onSecondaryTapUp` before `menuChildrenBuilder`, so the builder sees the new selection and stays free of side effects (it is called twice per right-click: on the tap and again after the next frame). Element and scrap rows put the §6.2 selection steps in `onBeforeOpen`; rows that do not pass it behave as in Phase 3. The selection steps are `onButtonPressed(MPButtonType.select)`, `setActiveScrapByChildElement` and `setSelectedElements([element], setState: true)`. The tap's last step, which brings an open file's tab to the front with `addFileTab`, is left out. To keep the tap and the right-click from drifting apart, `_applySingleTap` is split: a new `_applySingleTapSelection(controller, element)` holds the selection steps, and `_applySingleTap` calls it and then brings the tab to the front. The right-click calls only `_applySingleTapSelection`.
- In both cases right-click **never opens or activates a tab**, not even an open file's tab. The first menu action does that (§3.5); dismissing the menu leaves the tabs as they were.
- Right-click on a **selected scrap** row keeps the scrap selection; the menu acts on every selected scrap.
- Right-click on an **unselected scrap** row changes nothing; the menu acts on that scrap only.

Rationale: the canvas shortcuts act on the selection, so the menu should too, and the user sees in the tree which elements the menu affects before choosing an item.

## 7. Canvas shortcuts

| Action | Shortcut |
|---|---|
| Bring selected elements forward | `Ctrl+]` |
| Send selected elements backward | `Ctrl+[` |
| Bring selected elements to front | `Ctrl+Shift+]` |
| Send selected elements to back | `Ctrl+Shift+[` |

- These are the parent plan's candidates. They are free: no `bracketLeft`/`bracketRight` binding exists in `lib/`, and neither the EN nor the PT keyboard-shortcuts page lists one. They match Illustrator and Affinity, which surveyors who edit maps are likely to know.
- Points, lines and areas are handled in `MPTH2FileEditStateSelectNonEmptySelection.onKeyDownEvent` (the state that owns the canvas selection), following its existing `case LogicalKeyboardKey…` pattern with Ctrl or Meta. Selected scraps are handled in `MPTH2FileEditStateSelectEmptySelection.onKeyDownEvent`, the state the editor is in while scraps are selected (§3.6), when `selectedScrapMPIDs` is not empty. Both call one shared helper, so the key handling is written once.
- **Layouts:** with Shift held, some platforms report the logical key of the shifted character (`braceRight`/`braceLeft`) instead of `bracketRight`/`bracketLeft`. The handler accepts both, and decides forward/backward by bracket side and front/back by Shift. On the Brazilian ABNT2 layout `[` and `]` are unshifted keys, so the bindings work there as they do on US layouts. Test both logical keys.
- They act on either the points, lines and areas of the canvas selection or the **one or more scraps** of the scrap selection (§3.6); the two are never non-empty at the same time. `mpSelectedElementsLogical` keeps insertion order, so the handler sorts its MPIDs into file order (their order in the parent's `childrenMPIDs`); scraps come from `selectedScrapMPIDsInFileOrder`.
- **Selected scraps** are reordered among the file's scraps with the same §3.3 semantics as points, lines and areas: runs of adjacent selected scraps step over one unselected scrap for forward/backward, and the whole selection keeps its relative order at the start or end of the file for front/back. It is one command and one undo step. Neither the active scrap nor the selection changes (§4).
- **A mixed canvas selection** (an `MPSelectedScrap` from the scraps dialog next to points, lines or areas, §3.6) is rejected with `mixedScrapsAndDrawables` (§3.1) and nothing moves, not even in part.
- They never change the selection.
- No shortcut in other states, and none in the tree, which has no keyboard focus (§2).

## 8. Localization, help and changelog

### 8.1 Strings

All in `lib/l10n/intl_en.arb` and `intl_pt.arb`, each with an `@key` description ending in `Used on: <Class>.<method>`, followed by `flutter gen-l10n`. PT uses Brazilian Portuguese; the order-action names follow the usual pt-BR drawing-software terms.

| Key | EN | PT |
|---|---|---|
| `th2ElementTreeBringForward` | `Bring forward` | `Avançar` |
| `th2ElementTreeSendBackward` | `Send backward` | `Recuar` |
| `th2ElementTreeBringToFront` | `Bring to front` | `Trazer para a frente` |
| `th2ElementTreeSendToBack` | `Send to back` | `Enviar para trás` |
| `th2ElementTreeMoveToScrap` | `Move to scrap` | `Mover para o scrap` |
| `th2ElementTreeDragCount` | `{count, plural, one {1 element} other {{count} elements}}` | `{count, plural, one {1 elemento} other {{count} elementos}}` |
| `th2MoveRejectedGeneric` | `Cannot be placed here` | `Não pode ser colocado aqui` |
| `th2MoveRejectedCrossFile` | `Elements can only be moved within their own file` | `Elementos só podem ser movidos dentro do próprio arquivo` |
| `th2MoveRejectedScrapPlacement` | `Scraps can only be placed among scraps` | `Scraps só podem ser colocados entre scraps` |
| `th2MoveRejectedDrawablePlacement` | `Points, lines and areas must be inside a scrap` | `Pontos, linhas e áreas devem ficar dentro de um scrap` |
| `th2MoveRejectedMixedScrapsAndDrawables` | `Scraps cannot be moved together with points, lines or areas` | `Scraps não podem ser movidos junto com pontos, linhas ou áreas` |
| `th2MoveRejectedLineBorderShared` | `{line} borders {area}; move every area using this border together` | `{line} é borda de {area}; mova juntas todas as áreas que usam essa borda` |
| `th2MoveRejectedAreaBorderShared` | `Border {line} also borders {area}; move every area using this border together` | `A borda {line} também pertence a {area}; mova juntas todas as áreas que usam essa borda` |
| `th2MoveRejectedAreaBorderWrongScrap` | `Border {line} is in another scrap` | `A borda {line} está em outro scrap` |
| `th2MoveRejectedAreaBorderNotLine` | `{area} has a border reference that is not a line` | `{area} tem uma referência de borda que não é uma linha` |

`{line}` and `{area}` are the elements' row labels (§3.1), for example `line wall w12`. Shortcut descriptions live in the help pages, not in `.arb` files, as for existing shortcuts.

### 8.2 Help and shortcut pages

Following the Phase 3 exception and the project rule to document a feature when it ships:

- `assets/help/en/th2_file_edit_page_help.md` and `assets/help/pt/…`: extend the project-tree section with dragging rows, drop positions (before/after a row; the start or end of a scrap when dragging points, lines or areas, and before/after it when dragging scraps; the start or end of the file), why some drops are refused, including selections that mix scraps with points, lines or areas, multi-selection with Ctrl/Shift, selecting scraps with Ctrl+click (and that plain click on a scrap only makes it active), the context menu, Move to scrap, that tree edits open the file's tab and are undone with `Ctrl+Z`, and that up in the list means drawn earlier (below).
- `assets/help/en/keyboard_shortcuts_edit.md` and `assets/help/pt/…`: the four §7 shortcuts, plus Ctrl+click on point, line, area and scrap rows and Shift+click on point, line and area rows in the project tree, each in its alphabetical position.
- Phase 6 of the parent plan then only has to cover what is still missing (broken files, remaining localization).

### 8.3 CHANGELOG

One Phase 4 entry in the unreleased section, under "New features", next to the Phase 3 entry, referencing #32 and listing the new test files.

## 9. Implementation order

1. **Model/aux** (no UI): the `MPHierarchyMoveRejection` enum with element MPIDs (§3.1), `TH2HierarchyAux.resolveMoves`/`resolveMoveGroups` and the factory refactor (§3.2–§3.3), `MPCommandFactory.moveElementGroups` and the new `_moveRelative` (§3.3). Update `t2462` and `t3941`, and add `t3947`. Everything must stay green before any widget change.
2. `MPGeneralController.prepareTH2FileForTreeEdit` (§3.5) with its tests.
3. Tree multi-selection (§3.4) and scrap selection (§3.6), with their tests.
4. Context menus (§6), with the right-click selection rule and the §4 selection after actions. At this point the feature is usable without drag and drop.
5. Canvas shortcuts (§7).
6. Drag sources, drop targets, hover evaluation and drop (§5.1–§5.3, §5.6).
7. Feedback, auto-expand and auto-scroll (§5.4, §5.5), with the new constants in `mp_constants.dart`: `mpProjectTreeDropZoneHalfFraction`, `mpProjectTreeDragHoverExpandDelayMilliseconds`, `mpProjectTreeDragAutoScrollEdgeExtent`, `mpProjectTreeDragAutoScrollVelocityScalar`.
8. Strings (§8.1) alongside steps 4–7, never as a later clean-up, so no hard-coded text is committed. Help and shortcut pages (§8.2).
9. Run the focused tests, `flutter analyze` and the full test suite. Do not run `build_runner` manually or `dart format`.
10. CHANGELOG entry (§8.3).

## 10. Expected files

| Area | Files |
|---|---|
| Aux | `lib/src/auxiliary/th2_hierarchy_aux.dart` (enum, element MPIDs, `resolveMoves`, `resolveMoveGroups`), `lib/src/auxiliary/th2_element_tree_aux.dart` (drag payload, `moveRejectionMessage`, drop-request resolution) |
| Commands | `lib/src/commands/factories/mp_command_factory.dart` (`moveElements` uses `resolveMoves`; new `moveElementGroups`) |
| Controllers | `lib/src/controllers/th2_file_edit_element_edit_controller.dart` (`MPMoveElementsResult` with the enum, new `_moveRelative`), `lib/src/controllers/mp_general_controller.dart` (`prepareTH2FileForTreeEdit`), `lib/src/controllers/th2_file_edit_selection_controller.dart` (`selectedScrapMPIDs`, clearing it when points, lines or areas are selected and in `deselectAllElements`, so Escape clears it; its `.g.dart` is regenerated by the watch) |
| State machine | `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_non_empty_selection.dart` (shortcuts for points, lines and areas), `mp_th2_file_edit_state_select_empty_selection.dart` (shortcuts for selected scraps; a click on empty canvas and leaving the state, except to `selectionWindowZoom`, clear the scrap selection) |
| Widgets | `lib/src/widgets/th2_element_tree_row_widget.dart` (drag source, drop target, multi-select, scrap selection and highlight, menu), `lib/src/widgets/th_project_tree_node_widget.dart` (file-row drop target), `lib/src/widgets/th_project_tree_widget.dart` (`ScrollController`, auto-scroll, drag controller), new `lib/src/widgets/th2_element_tree_drag_controller.dart`, `lib/src/widgets/th_project_tree_row_context_menu_widget.dart` (`onBeforeOpen` hook, order and Move-to-scrap item builders) |
| Constants | `lib/src/constants/mp_constants.dart` |
| l10n | `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb`, generated files from `flutter gen-l10n` |
| Help | `assets/help/{en,pt}/th2_file_edit_page_help.md`, `assets/help/{en,pt}/keyboard_shortcuts_edit.md` |
| Changelog | `CHANGELOG.md` |
| Tests | updated `test/t2462_commands_mpmoveelementscommand_test.dart`, `test/t3941_th2_hierarchy_aux_test.dart`, `test/t3943_th2_element_tree_widget_test.dart`; new `test/t3947_th2_move_resolution_test.dart`, `test/t3948_th2_element_tree_drag_drop_test.dart`, `test/t3949_th2_element_tree_context_menu_test.dart`, `test/t3950_th2_drawing_order_shortcuts_test.dart` |

`t3945` and `t3946` are already taken (controller disposal, border-reference parsing), so the parent plan's §7 now gives Phase 5 `t3951` and Phase 7 `t3952`.

## 11. Tests and acceptance criteria

### Move resolution (`t3947`, pure)

- Every rejection produced by `TH2HierarchyAux.validateMove` has a fixture; `lineBorderShared` and `areaBorderShared` carry the right line and the first non-moving area. A border shared by three areas verifies that the localized guidance requires **all** areas to move. `brokenFile` is tested through `TH2FileEditElementEditController.checkMoveElements` in `t2462`; `crossFile` is tested through tree drag feedback in `t3948`, because neither is returned by `validateMove`.
- `resolveMoves` returns an empty list for: before the element's own next movable sibling, after its own previous one, end of scrap for the last child, start of scrap for the first child, and a multi-selection dropped inside its own contiguous run.
- "After T" with comments between T and its next sibling places the element before that sibling and leaves the comments in place.
- The factory produces the same command as before the refactor for all existing `t2462` fixtures.
- `validateMove` rejects a mix of scraps and points, lines or areas with `mixedScrapsAndDrawables`, for a file target, a scrap target, and with or without an anchor; bring forward, send backward, bring to front and send to back on a mixed selection return that rejection and create no command.
- `validateMove` with `afterSiblingMPID`: rejected when combined with `beforeSiblingMPID` (assert), when the anchor is moving, is not a child of the target parent, or is not movable (including `THEndscrap`).
- **Order actions with several elements:** `[a, B, c, D, e]` forward → `[a, c, B, e, D]`; backward → `[B, a, D, c, e]`; `[B, c, D, e]` forward → `[c, B, e, D]`; assert that the second group's concrete insertion index uses the list after the first group; the same final order whichever order the groups are passed in; forward with a comment between `c` and `D` in `[a, B, c, D, e]` leaves the comment directly after `c` and puts `B` directly before `e`; a run already last stays while another run moves, and is not skipped as an anchor: `[a, B, c, D]` forward → `[a, c, B, D]`; all runs at the boundary is a no-op with no command; one undo restores the original `childrenMPIDs` exactly; a point brought forward past a line is written after that line's `endline`; on a broken file, bring forward and send backward return `brokenFile` and create no command.

### Tree edit preparation and multi-selection (`t3943`, updated)

- `prepareTH2FileForTreeEdit` opens and activates the tab of a tab-less valid file, returns `null` (no tab) for a broken, loading or load-error file, and finalizes an in-progress line creation on an open file.
- Ctrl+click toggles an element of the active scrap; Shift+click selects the visible range within a scrap; the Shift anchor survives a double tap and is set by a Ctrl+click; a Shift+click whose anchor was removed or is in another scrap acts as a plain click; a modified click on another scrap acts as a plain click; modified clicks never count as a double tap and never open a tab.
- A Ctrl+click and a Shift+click on an element row while a line is being drawn finalize that line first (it appears in the file and as a tree row, and is not selected), then change the selection; the Shift range is computed from the rows after that; in single-line edit, a Ctrl+click adds the clicked element to the edited line's selection.
- Scrap selection: Ctrl+click on scrap rows selects and deselects several scraps without changing the active scrap, ends line creation, and clears a point, line or area selection, leaving the editor in `selectEmptySelection`; selecting a point, line or area (tree or canvas) clears the scrap selection; a plain click and a Shift+click on a scrap row make it active and clear the scrap selection, and while a line is being drawn they finalize it first; Escape clears it; a click on empty canvas clears it; switching from `selectEmptySelection` to Add Point, Add Line or a canvas navigation state clears it, and returning to Select does not restore it; a selection-window zoom keeps it; removing a selected scrap and undoing that leave no stale id; selected scrap rows are filled, the active scrap row loses its fill while other scraps are selected, and its label is always bold.

### Drag and drop (`t3948`, widget)

Each case asserts the resulting `childrenMPIDs`, or that the undo stack is unchanged:

- reorder a point within its scrap (before and after a row);
- every row has two zones: a drop just above and just below the vertical centre of a point, line or area row lands before and after it respectively, with no dead zone;
- `B` and `D` of `[a, B, c, D, e]` dropped on the lower half of `e` give `[a, c, e, B, D]`, and on its upper half `[a, c, B, D, e]`;
- move a line into another scrap: upper half of the scrap row → start of that scrap, lower half → end, for both a collapsed and an expanded scrap;
- reorder scraps: upper half of a scrap row → before it, lower half → after its whole block, for both a collapsed and an expanded scrap, and never into it; upper half of the file row → start of file, below the `encoding` line and header comments; lower half → end of file; a scrap that is already first dropped on the upper half of the file row, and one already last dropped on the lower half, are no-ops;
- a border line reordered within its scrap is accepted;
- rejected drops: a scrap onto a point, line or area row, a PLA onto either half of the file row, a mixed selection onto any row (`mixedScrapsAndDrawables`), a border line alone into another scrap (the feedback shows the localized reason naming the area), and a drag from another file (`crossFile`);
- a no-op drop (just below the dragged row) creates no command and shows no indicator;
- hovering the upper half of an expanded file row draws the insertion line above its first scrap; the lower half draws it below the file's last visible row (the last scrap's last child when that scrap is expanded, the last scrap row when it is collapsed), and draws nothing when that row is scrolled out of view, while the file row keeps its outline and end icon; on a collapsed file, both halves draw the line on the file row's bottom edge and differ only in the icon;
- dragging PLAs over an expanded scrap: the upper half draws the line above its first child and the lower half below its last child, both at scrap depth + 1, with the scrap row outlined and the start or end icon; on a collapsed scrap both halves draw on the scrap row's bottom edge and differ only in the icon; after auto-expand, with the pointer held still, the end line moves under the last child without a second move-resolution call; collapsing the scrap again moves the line back to its row;
- dragging a scrap over an expanded scrap: the upper half draws the line on the scrap row's top edge and the lower half below its last child, both at file depth + 1 and with no outline;
- hovering the lower half of the row just above a dragged row, and the upper half of a scrap whose first child is being dragged, is a no-op, not a `targetIsMoving` rejection: no indicator and no rejection feedback;
- a second drag of different elements over the same row and zone does not reuse the first drag's cached result;
- dragging a selected row drags the whole selection in file order; dragging an unselected row drags only it and does not change the selection until the drop; the same holds for selected and unselected scrap rows and the scrap selection, which a scrap drop keeps;
- after a drop the moved PLAs are selected and their scrap is active; a scrap drop changes neither;
- a drop on a tab-less file opens and activates its tab, and one `Ctrl+Z` undoes the move;
- a hover accepted before `prepareTH2FileForTreeEdit` finalizes an in-progress line or area is rechecked against the changed model; if the move becomes a no-op or is rejected, no move command or post-drop selection change occurs;
- a drop after the file was reloaded during the drag does nothing;
- hovering either half of a collapsed scrap for the delay while dragging PLAs expands it, and moving between its halves does not restart the timer; leaving earlier does not expand it; dragging a scrap never expands one;
- rows are not draggable while the filter is active;
- broken, loading and load-error rows are never drag sources or valid targets.

Auto-scroll is covered by tests that drag to the bottom edge of a tree taller than its viewport and assert the scroll offset increased; continue moving the pointer after the source row scrolls out and assert scrolling follows its current position; hold the pointer still while rows scroll underneath and assert the hover indicator follows the row now under it; and finish or cancel after source disposal and assert scrolling stops and the next drag starts with no stale pointer route or hover state.

### Context menu (`t3949`, widget)

- Right-click on an unselected PLA row selects it before the menu items are built (a no-op item for the newly selected element is disabled) and does not open or activate a tab, including when the file has an open tab that is not the active one; on a selected row it keeps a multi-selection.
- Each order item moves the menu target and is one undo step; items that would be no-ops are disabled; on a mixed selection every order item is disabled and shows the `mixedScrapsAndDrawables` reason.
- Move to scrap lists the other scraps in file order, not the current one; it moves to the end of the target scrap, makes it active and selects the moved elements; a rejected entry is disabled and shows the reason; the submenu is absent with a single scrap.
- Scrap rows show the four order items and no Move to scrap. On a selected scrap row they act on every selected scrap, in one undo step; on an unselected one they act on that scrap only and leave the scrap selection unchanged.
- A menu action on a tab-less file opens and activates its tab.
- A menu built before preparation finalizes an in-progress line or area resolves its action again against the current model; a no-op or rejected result does not apply the §4 post-action selection.

### Shortcuts (`t3950`, widget)

- The four shortcuts move the selection as §3.3 describes, with both `bracketRight` and `braceRight` (and left variants) when Shift is held.
- With one scrap and with several (adjacent and non-adjacent) scraps selected through Ctrl+click in the tree, the four shortcuts, handled in `selectEmptySelection`, reorder them among the file's scraps as §3.3 describes, in one undo step, leaving the active scrap and the scrap selection unchanged; scraps already at the boundary are a no-op; the shortcut can be repeated.
- A selection made in an order other than file order is moved as if it had been made in file order.
- They do nothing with an empty selection or a mixed selection, and do not fire in other states.

### Acceptance

- Every edit is one undo step on the file's own stack, and undo/redo restores the file byte for byte when written.
- No edit is ever offered or performed on a broken file.
- No valid file becomes invalid through any drop, menu action or shortcut.
- `flutter analyze` is clean and the full test suite passes.
- EN and PT help and shortcut pages are updated, and no user-visible string is hard-coded.

## 12. Resolved question

- **Points, lines and areas dropped on the upper part of a scrap row.** An earlier draft mapped this to "before the scrap, under the file", which is always rejected for points, lines and areas. Scrap rows now read their zones by payload (§5.2), so for points, lines and areas the upper half means "start of this scrap", and there is no rejected zone left on a scrap row.
