<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 4: Drag and Drop, Context Menu, Shortcuts

**Date:** 2026-09-23  
**Status:** Proposed. Checked against the codebase on 2026-09-23 (`main` at `a959868d`).  
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
- `Ctrl`/`Shift` multi-selection of element rows, which parent plan §4.5 requires and Phase 3 did not build (§3.4).
- Opening the file's tab on the first edit made from the tree (§3.5).
- Drag sources, drop targets, insertion indicator, rejection feedback, scrap auto-expand and auto-scroll (§5).
- Element-row and scrap-row context menus (§6).
- Canvas shortcuts `Ctrl+]`, `Ctrl+[`, `Ctrl+Shift+]` and `Ctrl+Shift+[` (§7).
- EN/PT strings, EN/PT help and keyboard-shortcut pages, and one CHANGELOG entry (§8).

### Out of scope

- Moving elements between files. Cross-file drops are rejected with a reason.
- Keyboard focus and keyboard navigation inside the tree, including opening the menu with Shift+F10 or the Menu key.
- Selecting scraps as elements, or multi-selecting scraps. A scrap row still only makes its scrap active.
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

- `MPHierarchyMoveCheck.rejected(rejection, {int? lineMPID, int? areaMPID})` carries the MPIDs of the elements the message names. For `lineBorderShared` and `areaBorderShared` the area is the first **non-moving** area that borders the line. It is one example of a missing area, not necessarily the only one: every area using the border must move together.
- `MPMoveElementsResult` changes the same way. Existing tests in `t2462` and `t3941` that assert string keys are updated to the enum.
- `TH2ElementTreeAux.moveRejectionMessage(check, th2File, appLocalizations)` builds the localized text (§8.1). Named elements use the row's plain label from the Phase 3 label builder (kind, type[:subtype], Therion id), so the message names them exactly as the tree shows them.

### 3.2 No-op detection only exists inside the command factory

`MPCommandFactory.moveElements` both validates and computes the effective move list (area border folding, file order), and returns `null` for a no-op. Hover feedback needs the same answer without building a command, many times per drag.

Change: move the order and folding logic out of the factory into `TH2HierarchyAux.resolveMoves(th2File, elementMPIDs:, newParentMPID:, beforeSiblingMPID:) → List<MPElementMove>`. It returns an empty list for a no-op. The factory calls it and returns `null` when it is empty. Hover calls `validateMove` and then `resolveMoves`; both are pure and read only the model. The tree caches the result per `(targetRowId, zone, structureRevision)` for the duration of a drag, so moving the pointer inside one zone does not recompute it.

### 3.3 Order actions only look at the first element

`bringForward`/`sendBackward` in `th2_file_edit_element_edit_controller.dart` use only `ids.first` to compute the target. With a non-contiguous selection, for example `[a, c]` among `[a, b, c, d]`, `bringForward` asks to move both before `c`, which `validateMove` rejects (`targetIsMoving`). `bringToFront`/`sendToBack` gather the whole selection at one end, which is already correct.

Semantics for several selected siblings (all selected elements of a canvas selection share one parent, because selection only works inside the active scrap):

- **Bring forward:** every maximal run of adjacent selected movable siblings steps over the **one** non-selected movable sibling that follows it. Runs that are already last stay. Gaps between runs are kept. Example: `[a, B, c, D, e]` with `B` and `D` selected becomes `[a, c, B, e, D]`.
- **Send backward:** the mirror image.
- **Bring to front / Send to back:** unchanged; the selection keeps its relative order and goes to the end or the start of the parent.
- The whole action is **one** command and one undo step. It is a no-op, and creates no command, when every run is already at the boundary.

Implementation:

- Add `TH2HierarchyAux.resolveMoveGroups(th2File, parentMPID:, groups:)`, where each group is `(elementMPIDs, beforeSiblingMPID)`. It copies the affected parents' **full** `childrenMPIDs` lists once, then resolves each group against those same simulated lists, removing and inserting each element before calculating the next move's index. It never mutates `th2File`. `resolveMoves` delegates its single request to this shared resolver; `MPCommandFactory.moveElementGroups` calls it once and emits one `MPMoveElementsCommand` with the resulting moves, or no command when the final movable order is unchanged. Do not call the public `resolveMoves(th2File, ...)` separately for each group: each call would start from the original order. `MPMoveElementsCommand._prepareUndoRedoInfo` simulates the already resolved moves to record inverse positions; it does not resolve the forward indices.
- For example, to move `B` and `D` forward in `[a, B, c, D, e]`, resolve `D` past `e` first, then calculate `B`'s insertion index from `[a, B, c, e, D]`. Calculating both indices from the original list can produce `[a, c, e, B, D]` instead of `[a, c, B, e, D]`. Bring forward processes runs from the last to the first, and send backward from the first to the last, so a run never steps over another run's new position.
- `_moveRelative` builds the runs from `_movableSiblingsOf(parent)` and calls it. Elements with different parents are not a valid input (assert); the tree and the canvas never produce them.

### 3.4 The tree has no multi-selection

Parent plan §4.5 says rows support `Ctrl`/`Shift` multi-select. Phase 3 only implemented plain and double taps. Drag and the menu act on the selection, so Phase 4 adds it, keeping the Phase 3 rule that a row's highlight is its file controller's own selection:

- **Ctrl+click** (Meta on macOS, via `MPInteractionAux.isCtrlPressed()`/`isMetaPressed()`, as the canvas does) on an element row of the **active scrap** toggles that element in the selection with `selectionController.addSelectedElement`/`removeSelectedElement`, and sets the selection state as the canvas does.
- **Shift+click** on an element row of the active scrap selects the range of visible element rows between the last clicked row (the anchor) and this row, inside that scrap, adding to the current selection. The anchor is the row id of the last plain or Ctrl click, kept in the shared `TH2ElementTreeTapTracker`, and is cleared when it no longer names an existing row.
- A **modified click on a row of another scrap**, or of another file, behaves as a plain click: it switches the active scrap and selects only that element. Selection cannot span scraps (parent plan §4.5 assumed it could; the selection controller does not allow it, and Phase 4 keeps that rule).
- Modified clicks never count toward a double tap.
- A modified click brings an open file's tab to the front, like a plain click, and never opens a tab.

### 3.5 No "open the tab on the first edit" helper

Parent plan §4.2 requires that the first structural edit made from the tree on a tab-less file opens and activates the tab before the command runs, so the edit is visible and `Ctrl+Z`, Save and the close-tab prompt work.

Add `MPGeneralController.prepareTH2FileForTreeEdit(String th2FilePath) → TH2FileEditController?`:

1. Resolve the controller with `getTH2FileEditControllerIfExists`; return `null` unless it is loaded, not broken and has no `loadError`.
2. `addFileTab(path)`. It opens the tab if needed and always activates it.
3. `controller.stateController.onButtonPressed(MPButtonType.select)`, the same mode exit a tree tap uses (Phase 3 plan §8), so an in-progress line or area creation is finalized before its scrap is reordered.
4. Return the controller.

Every Phase 4 edit from the tree (drop, menu item) calls it first and does nothing when it returns `null`. Canvas shortcuts do not need it: their tab is already open and active.

## 4. Where the edit lands and what is selected afterwards

- **Undo location:** the file's own `MPUndoRedoController`, as for any canvas edit. Because the tab is active after §3.5, `Ctrl+Z` undoes the tree edit right away.
- **Selection after an executed drop or menu action on points, lines and areas:** the active scrap becomes the target scrap and the moved elements become the selection (`setActiveScrap`, then `setSelectedElements(..., setState: true)`). A rejected or no-op result does not apply this selection change. The user sees where executed moves went, on the canvas and in the tree. Border lines folded into an area move (Phase 2) are not added to the selection.
- **Scrap moves** change neither the active scrap nor the selection.
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
    final bool isScrap;
  }
  ```

- **What is dragged:**
  - a point, line or area row that is **selected**: the whole selection of its file, in file order;
  - a point, line or area row that is **not selected**: that element only. Starting the drag does not change the selection; the drop does (§4);
  - a scrap row: that scrap only.
- **Feedback widget:** a `Material` with `mpDragFeedbackOpacity`, showing the dragged row's icon and label, plus "N elements" (`th2ElementTreeDragCount`) when more than one element moves. It also shows the current rejection reason, if any (§5.4).
- **Dragged rows** are drawn dimmed (the same `Opacity` as the scraps dialog uses for the dragged row) until the drag ends.
- **No drag while filtering.** With a filter active, the visible rows hide most siblings, so an insertion line between two visible rows would not show where the element really lands. Rows are not draggable while `THProjectTreeUIController` has a filter; the context menu still works.

### 5.2 Drop targets and zones

Every element row and every TH2 file row is a `DragTarget<TH2ElementTreeDragPayload>`. Other project rows are not targets, so hovering them shows no indicator.

The zone comes from the pointer's local y inside the row, from `DragTargetDetails.offset` converted with the row's `RenderBox.globalToLocal`, in `onMove`. The fractions are constants, not magic numbers: `mpProjectTreeDropZoneEdgeFraction = 1 / 3`.

The request is exactly parent plan §4.3:

| Hover zone on target row T | Request |
|---|---|
| upper third of T | before T, under T's parent |
| lower third of T (T is a collapsed scrap, or not a scrap) | after T, under T's parent |
| middle of a **scrap** row | at the end of that scrap |
| lower third of an **expanded** scrap row | at the start of that scrap |
| middle of the **file** row | at the end of the file |
| upper or lower third of the **file** row | rejected (`drawableParentMustBeScrap` for PLAs, generic for scraps) |

Translating a request into `validateMove` arguments:

- **before T:** `beforeSiblingMPID = T`.
- **after T:** `beforeSiblingMPID` = the next **movable** sibling of T in the full `childrenMPIDs` (scrap, point, line or area), or, if there is none, the scrap's `THEndscrap` (inside a scrap) or `null` (at file level). Hidden children between T and that sibling stay where they are, as parent plan §4.4 requires.
- **start of scrap S:** the first movable child of S, or S's `THEndscrap` when it has none.
- **end of scrap S:** S's `THEndscrap`. **End of file:** `null`.

### 5.3 Hover evaluation

On each zone change the target:

1. Rejects with `crossFile` when `payload.th2FilePath` differs from the row's file.
2. Ignores the hover (no indicator, no message) when the payload's controller is no longer the file's registered controller, or when the target row is one of the dragged elements. Hovering the dragged rows themselves is neither a valid target nor an error.
3. Calls `checkMoveElements` with the §5.2 arguments. A rejection shows the rejection feedback.
4. Otherwise calls `TH2HierarchyAux.resolveMoves`. An empty result (the drop would change nothing, for example just below the dragged row) shows no indicator and makes the drop do nothing.
5. Otherwise shows the insertion indicator.

`onWillAcceptWithDetails` returns `true` for every payload, so `onMove`/`onLeave` keep firing and the target can show rejection feedback. `onAcceptWithDetails` repeats steps 1–4 against the current model and runs the move only for step 5; a rejected or no-op drop creates no command.

The per-drag hover state (target row id, zone, cached result) lives in a small `TH2ElementTreeDragController` owned by `THProjectTreeWidget` state (a `ChangeNotifier`, not MobX, because it is UI-only and short-lived). It is reset in `onDragEnd`, `onDraggableCanceled` and `onDragCompleted`.

### 5.4 Feedback

- **Insertion line:** a `mpDragDropIndicatorHeight` bar in `colorScheme.secondary`, as in the scraps dialog, drawn **over** the row edge (a `Stack` overlay, not an `AnimatedContainer` that pushes rows down, so rows do not jump while the pointer moves). It is indented to the depth of the parent that will receive the element: file depth + 1 for scraps, scrap depth + 1 for PLAs.
- **"Into scrap" and "end of file":** the target row gets a `colorScheme.secondary` outline instead of a line.
- **Rejection:** the row under the pointer gets a `colorScheme.error` outline, the feedback widget shows a `Icons.block` icon and the localized reason in `colorScheme.error`, and the row's `MouseRegion` sets `SystemMouseCursors.forbidden`. The reason text in the feedback widget is the primary signal, because desktop platforms do not always update the cursor while a button is held; the cursor is best effort.
- Nothing about rejection is shown as a `Tooltip`: tooltips do not appear while a pointer button is down.

### 5.5 Auto-expand and auto-scroll

- **Auto-expand:** hovering the middle zone of a **collapsed** scrap row for `mpProjectTreeDragHoverExpandDelayMilliseconds` (new constant, 700 ms) calls `toggleTH2ScrapCollapsed` to expand it. The timer is cancelled when the pointer leaves the row or the zone. A scrap expanded this way stays expanded after the drag; this matches file managers and avoids the tree jumping back on drop. Collapsed file rows are not auto-expanded, because the file-row middle zone already means "end of file".
- **Auto-scroll:** the tree's `ListView.builder` gets a `ScrollController`, and an `EdgeDraggingAutoScroller` on its `Scrollable` is fed the pointer position from every `onMove` and from the `Draggable`'s `onDragUpdate`. It scrolls when the pointer is within `mpProjectTreeDragAutoScrollEdgeExtent` of the top or bottom edge, and stops on drag end. `mpProjectTreeDragAutoScrollVelocityScalar` sets the speed.

### 5.6 Drop

On an accepted, valid, non-no-op drop:

1. `prepareTH2FileForTreeEdit(path)` (§3.5). Stop if it returns `null`. Exiting line or area creation can finalize an element and change the model after the hover check.
2. Against the returned controller's **current** model, confirm the payload still belongs to its registered controller, the target row still exists, and the §5.2 request is still valid and non-no-op. Recompute the target sibling from the current `childrenMPIDs`; do not reuse the hover's cached request or move list. Stop without issuing a move if any check fails.
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
- **Disabled items:** an item whose action would be a no-op (already first or last) is disabled (`onPressed: null`). A "Move to scrap" entry that `checkMoveElements` rejects is disabled, and its label is followed by the reason in a second, smaller line. A second line is used instead of a tooltip because it is visible without hovering and also works with keyboard navigation inside the open menu.
- Icons: `Icons.flip_to_front` (bring to front), `Icons.flip_to_back` (send to back), `Icons.arrow_upward`/`Icons.arrow_downward` for forward/backward, `Icons.drive_file_move_outline` for Move to scrap. Up and down follow the tree, where later (drawn on top) is lower; so **Bring forward uses `Icons.arrow_downward`** and Send backward uses `Icons.arrow_upward`. The help page explains this, and the menu labels, not the icons, carry the meaning.
- Every action runs `prepareTH2FileForTreeEdit` first. It then checks that the menu target still exists and resolves the action against the current model, because leaving creation mode can change the file after the menu was built. It applies the §4 selection only when the action returns `executed`; a stale disabled/enabled state in the open menu cannot bypass move validation.
- Keys follow the Phase 3 convention: `ValueKey('THProjectTreeRowContextMenuBringForward|<rowId>')`, `…SendBackward|…`, `…BringToFront|…`, `…SendToBack|…`, `…MoveToScrap|<rowId>` for the submenu and `…MoveToScrap|<rowId>|<scrapMPID>` for its entries.

### 6.2 Does right-click select? (the decision Phase 3 left to Phase 4)

**Yes, for point, line and area rows, following file managers:**

- Right-click on a **selected** row keeps the whole selection; the menu acts on it.
- Right-click on an **unselected** row first applies the Phase 3 single-tap selection (Select tool, active scrap, select only this element), then opens the menu, which acts on that element.
- In both cases right-click **never opens or activates a tab**. The first menu action does that (§3.5); dismissing the menu leaves the tabs as they were.
- Right-click on a **scrap** row changes nothing; the menu acts on that scrap.

Rationale: the canvas shortcuts act on the selection, so the menu should too, and the user sees in the tree which elements the menu affects before choosing an item.

## 7. Canvas shortcuts

| Action | Shortcut |
|---|---|
| Bring selected elements forward | `Ctrl+]` |
| Send selected elements backward | `Ctrl+[` |
| Bring selected elements to front | `Ctrl+Shift+]` |
| Send selected elements to back | `Ctrl+Shift+[` |

- These are the parent plan's candidates. They are free: no `bracketLeft`/`bracketRight` binding exists in `lib/`, and neither the EN nor the PT keyboard-shortcuts page lists one. They match Illustrator and Affinity, which surveyors who edit maps are likely to know.
- They are handled in `MPTH2FileEditStateSelectNonEmptySelection.onKeyDownEvent` (the state that owns the current selection), following its existing `case LogicalKeyboardKey…` pattern with Ctrl or Meta.
- **Layouts:** with Shift held, some platforms report the logical key of the shifted character (`braceRight`/`braceLeft`) instead of `bracketRight`/`bracketLeft`. The handler accepts both, and decides forward/backward by bracket side and front/back by Shift. On the Brazilian ABNT2 layout `[` and `]` are unshifted keys, so the bindings work there as they do on US layouts. Test both logical keys.
- They act on `mpSelectedElementsLogical` in file order. They never move scraps (scraps are not selectable) and never change the selection.
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
| `th2MoveRejectedLineBorderShared` | `{line} borders {area}; move every area using this border together` | `{line} é borda de {area}; mova juntas todas as áreas que usam essa borda` |
| `th2MoveRejectedAreaBorderShared` | `Border {line} also borders {area}; move every area using this border together` | `A borda {line} também pertence a {area}; mova juntas todas as áreas que usam essa borda` |
| `th2MoveRejectedAreaBorderWrongScrap` | `Border {line} is in another scrap` | `A borda {line} está em outro scrap` |
| `th2MoveRejectedAreaBorderNotLine` | `{area} has a border reference that is not a line` | `{area} tem uma referência de borda que não é uma linha` |

`{line}` and `{area}` are the elements' row labels (§3.1), for example `line wall w12`. Shortcut descriptions live in the help pages, not in `.arb` files, as for existing shortcuts.

### 8.2 Help and shortcut pages

Following the Phase 3 exception and the project rule to document a feature when it ships:

- `assets/help/en/th2_file_edit_page_help.md` and `assets/help/pt/…`: extend the project-tree section with dragging rows, drop positions (before/after a row, into a scrap, end of file), why some drops are refused, multi-selection with Ctrl/Shift, the context menu, Move to scrap, that tree edits open the file's tab and are undone with `Ctrl+Z`, and that up in the list means drawn earlier (below).
- `assets/help/en/keyboard_shortcuts_edit.md` and `assets/help/pt/…`: the four §7 shortcuts, plus Ctrl+click and Shift+click on element rows in the project tree, each in its alphabetical position.
- Phase 6 of the parent plan then only has to cover what is still missing (broken files, remaining localization).

### 8.3 CHANGELOG

One Phase 4 entry in the unreleased section, under "New features", next to the Phase 3 entry, referencing #32 and listing the new test files.

## 9. Implementation order

1. **Model/aux** (no UI): the `MPHierarchyMoveRejection` enum with element MPIDs (§3.1), `TH2HierarchyAux.resolveMoves`/`resolveMoveGroups` and the factory refactor (§3.2–§3.3), `MPCommandFactory.moveElementGroups` and the new `_moveRelative` (§3.3). Update `t2462` and `t3941`, and add `t3947`. Everything must stay green before any widget change.
2. `MPGeneralController.prepareTH2FileForTreeEdit` (§3.5) with its tests.
3. Tree multi-selection (§3.4) and its tests.
4. Context menus (§6), with the right-click selection rule and the §4 selection after actions. At this point the feature is usable without drag and drop.
5. Canvas shortcuts (§7).
6. Drag sources, drop targets, hover evaluation and drop (§5.1–§5.3, §5.6).
7. Feedback, auto-expand and auto-scroll (§5.4, §5.5), with the new constants in `mp_constants.dart`: `mpProjectTreeDropZoneEdgeFraction`, `mpProjectTreeDragHoverExpandDelayMilliseconds`, `mpProjectTreeDragAutoScrollEdgeExtent`, `mpProjectTreeDragAutoScrollVelocityScalar`.
8. Strings (§8.1) alongside steps 4–7, never as a later clean-up, so no hard-coded text is committed. Help and shortcut pages (§8.2).
9. Run the focused tests, `flutter analyze` and the full test suite. Do not run `build_runner` manually or `dart format`.
10. CHANGELOG entry (§8.3).

## 10. Expected files

| Area | Files |
|---|---|
| Aux | `lib/src/auxiliary/th2_hierarchy_aux.dart` (enum, element MPIDs, `resolveMoves`, `resolveMoveGroups`), `lib/src/auxiliary/th2_element_tree_aux.dart` (drag payload, `moveRejectionMessage`, drop-request resolution) |
| Commands | `lib/src/commands/factories/mp_command_factory.dart` (`moveElements` uses `resolveMoves`; new `moveElementGroups`) |
| Controllers | `lib/src/controllers/th2_file_edit_element_edit_controller.dart` (`MPMoveElementsResult` with the enum, new `_moveRelative`), `lib/src/controllers/mp_general_controller.dart` (`prepareTH2FileForTreeEdit`) |
| State machine | `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_select_non_empty_selection.dart` (shortcuts) |
| Widgets | `lib/src/widgets/th2_element_tree_row_widget.dart` (drag source, drop target, multi-select, menu), `lib/src/widgets/th_project_tree_node_widget.dart` (file-row drop target), `lib/src/widgets/th_project_tree_widget.dart` (`ScrollController`, auto-scroll, drag controller), new `lib/src/widgets/th2_element_tree_drag_controller.dart`, `lib/src/widgets/th_project_tree_row_context_menu_widget.dart` (order and Move-to-scrap item builders) |
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
- **Order actions with several elements:** `[a, B, c, D, e]` forward → `[a, c, B, e, D]`; backward → `[B, a, D, c, e]`; assert that the second group's concrete insertion index uses the list after the first group; a run already last stays while another run moves; all runs at the boundary is a no-op with no command; one undo restores the original `childrenMPIDs` exactly; a point brought forward past a line is written after that line's `endline`.

### Tree edit preparation and multi-selection (`t3943`, updated)

- `prepareTH2FileForTreeEdit` opens and activates the tab of a tab-less valid file, returns `null` (no tab) for a broken, loading or load-error file, and finalizes an in-progress line creation on an open file.
- Ctrl+click toggles an element of the active scrap; Shift+click selects the visible range within a scrap; a modified click on another scrap acts as a plain click; modified clicks never count as a double tap and never open a tab.

### Drag and drop (`t3948`, widget)

Each case asserts the resulting `childrenMPIDs`, or that the undo stack is unchanged:

- reorder a point within its scrap (before and after a row);
- move a line into another scrap (middle of the scrap row → end; lower third of an expanded scrap → start);
- reorder scraps (before/after a scrap row, middle of the file row → end of file);
- a border line reordered within its scrap is accepted;
- rejected drops: a scrap into a scrap, a PLA onto the file row, a border line alone into another scrap (the feedback shows the localized reason naming the area), and a drag from another file (`crossFile`);
- a no-op drop (just below the dragged row) creates no command and shows no indicator;
- dragging a selected row drags the whole selection in file order; dragging an unselected row drags only it and does not change the selection until the drop;
- after a drop the moved PLAs are selected and their scrap is active; a scrap drop changes neither;
- a drop on a tab-less file opens and activates its tab, and one `Ctrl+Z` undoes the move;
- a hover accepted before `prepareTH2FileForTreeEdit` finalizes an in-progress line or area is rechecked against the changed model; if the move becomes a no-op or is rejected, no move command or post-drop selection change occurs;
- a drop after the file was reloaded during the drag does nothing;
- hovering the middle of a collapsed scrap for the delay expands it; leaving earlier does not;
- rows are not draggable while the filter is active;
- broken, loading and load-error rows are never drag sources or valid targets.

Auto-scroll is covered by a test that drags to the bottom edge of a tree taller than its viewport and asserts the scroll offset increased.

### Context menu (`t3949`, widget)

- Right-click on an unselected PLA row selects it and does not open or activate a tab; on a selected row it keeps a multi-selection.
- Each order item moves the menu target and is one undo step; items that would be no-ops are disabled.
- Move to scrap lists the other scraps in file order, not the current one; it moves to the end of the target scrap, makes it active and selects the moved elements; a rejected entry is disabled and shows the reason; the submenu is absent with a single scrap.
- Scrap rows show the four order items and no Move to scrap.
- A menu action on a tab-less file opens and activates its tab.
- A menu built before preparation finalizes an in-progress line or area resolves its action again against the current model; a no-op or rejected result does not apply the §4 post-action selection.

### Shortcuts (`t3950`, widget)

- The four shortcuts move the selection as §3.3 describes, with both `bracketRight` and `braceRight` (and left variants) when Shift is held.
- They do nothing with an empty selection, and do not fire in other states.

### Acceptance

- Every edit is one undo step on the file's own stack, and undo/redo restores the file byte for byte when written.
- No edit is ever offered or performed on a broken file.
- No valid file becomes invalid through any drop, menu action or shortcut.
- `flutter analyze` is clean and the full test suite passes.
- EN and PT help and shortcut pages are updated, and no user-visible string is hard-coded.

## 12. Open question

- **PLA dropped on the upper third of a scrap row.** Parent plan §4.3 maps it to "before the scrap, under the file", which is rejected for PLAs. Visually, the insertion line there sits right under the previous scrap's last child, so users may expect "end of the previous scrap". This plan keeps the parent rule (a clear rejection message, and the lower third of the previous scrap's last row does the expected thing). If user testing shows confusion, map that zone to the end of the previous scrap in a follow-up; it only changes the §5.2 table and one test.
