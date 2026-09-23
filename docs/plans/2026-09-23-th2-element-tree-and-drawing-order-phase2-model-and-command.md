<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 2: Model Primitive and Move Command

**Date:** 2026-09-23  
**Status:** Proposed  
**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md)  
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose

Implement the data and undo/redo layer needed by the TH2 element tree. This phase makes it possible to move complete top-level TH2 elements—scraps, points, lines and areas—within a file or between valid parents while preserving the element subtree and the original text of every moved block.

The sidebar, drag-and-drop widgets and context menus are Phase 3/4. This phase exposes controller APIs that those phases can call and provides the hierarchy validator they will use for both hover feedback and command-time protection.

## 2. Current codebase constraints

- `TH2File.childrenMPIDs` and each parent’s `childrenMPIDs` are the authoritative file-order lists. `TH2File.reorderScrapMPIDs` is only suitable for scraps and preserves non-scrap slots; the new operation must work for mixed point/line/area siblings.
- `THElement.parentMPID` is final. Changing parents requires `copyWith(parentMPID: ...)` followed by `TH2File.substituteElement(...)`; the descendants retain their existing parent MPIDs and must not be removed and re-added.
- `THIsParentMixin.removeElementFromParent` unregisters THIDs. A move must therefore remove the MPID directly from the old parent list.
- Line segments, line options, area border references and `end*` elements are children of their owning line/area. Moving the owner moves its complete block automatically.
- The existing `MPCommandDescriptionType.moveElements` is already used for canvas geometry movement. The new structural command must use the same description text but get a distinct `MPCommandType` and command class; do not change the serialization shape of existing canvas move commands.
- Phase 1 already provides `TH2FileProblem`, `isBroken`, `problems`, broken-file loading behavior and `reloadTH2File`. Structural APIs must assert or reject broken files so they cannot be used to mutate the detect-only model.
- `MPGeneralController.closeProjectFileTabs` removes project-owned open tabs during project lifecycle transitions. A separately loaded, tab-less TH2 controller remains in `_t2hFileEditControllers`; Phase 2 must add cleanup for those controllers.
- `TH2FileEditController` has no `dispose()`. `_initializeReactions()` adds about ten MobX reactions to `_disposers`, including the one that mirrors the dirty state into `THProjectController.dirtyFilePaths`, and nothing ever runs them. `removeFileController` and `reloadTH2File` only drop the registry entry.
- Undo/redo is map-based: `_createUndoRedoCommand` returns `MPUndoRedoCommand(mapRedo:, mapUndo:)`, and undo rebuilds a command with `MPCommand.fromMap(mapUndo)`.
- `THArea` is not in `THIsParentMixin.drawableChildElementTypes` and areas are not painted as filled shapes. Moving an area changes file order (what XTherion and Therion see) but nothing on Mapiah's canvas.
- `TH2File._areaMPIDByLineMPID` stores a single area per line, so it cannot tell whether a line borders more than one area.

## 3. Scope and non-goals

### In scope

- A raw `TH2File.moveElementToParent` primitive.
- Drawable-child cache invalidation in `THIsParentMixin`.
- `TH2HierarchyAux.validateMove` and the result/reason model consumed by later UI phases.
- `MPMoveElementsCommand`, including multi-element moves, area-border expansion, undo/redo and command serialization.
- Controller preparation/execution APIs and bring/send convenience operations.
- Structure revision observability and the existing mutation paths needed to notify the future tree.
- `TH2FileEditController.dispose()` and its use on every path that drops a TH2 controller.
- Disposal of tab-less project TH2 controllers on project open, reload and close.
- Focused model, command, hierarchy and lifecycle tests.

### Out of scope

- Sidebar rows, lazy loading, drag targets, context menus and keyboard shortcuts.
- Parser recovery or broken-file UI changes from Phase 1.
- Moving elements between files.
- Moving comments, empty lines, settings, images, line segments or area border references independently.
- Changing Therion’s symbol-class or `-place` rendering semantics.

## 4. Design

### 4.1 Move request and concrete position

The public request is expressed in semantic terms:

```dart
moveElements({
  required List<int> elementMPIDs,
  required int newParentMPID,
  int? beforeSiblingMPID,
})
```

The command stores concrete moves, each containing `elementMPID`, `newParentMPID` and `positionInNewParent`. Resolve the position against the full `childrenMPIDs` list, including comments, empty lines, settings and closing `end*` elements. The command must not use drawable-child indices.

`positionInNewParent` is an index into the new parent's list **after** the element has been removed from its old parent. For a move within the same parent this is one less than the pre-removal index whenever the element was before the target slot.

The only parents a move can target are the file and scraps. For an end-of-parent request, resolve the index of the scrap's `THEndscrap` (inserting just before it); for the file, use the end of the file list. `beforeSiblingMPID` may be the scrap's `THEndscrap`, which means the same as end of scrap. Preserve hidden children at their existing slots as far as the requested insertion position permits.

The simplest correct resolution is anchor-based: in the simulated list after the removal, the target index is the current index of `beforeSiblingMPID`, or the end-of-parent index described above.

### 4.2 Raw model primitive

Add `TH2File.moveElementToParent`:

```dart
void moveElementToParent({
  required int elementMPID,
  required int newParentMPID,
  required int positionInNewParent,
});
```

The primitive deliberately does not validate hierarchy. It should:

1. Resolve the old parent and remove only the element MPID from its full child list.
2. Only when the parent changes: copy the moved element with the new `parentMPID` and substitute that copy in the file registry. A reorder within the same parent keeps the existing instance.
3. Insert the MPID at the supplied concrete index in the new parent. The index refers to the list after step 1 (§4.1).
4. Invalidate drawable-child caches for both parents, clear the bounding boxes of both parents, and invalidate the scrap cache when a scrap changes order.

The area-to-line support maps (`_areaMPIDByLineMPID`, `_areaMPIDByLineTHID`) and each area's line caches are keyed by MPID/thID across the whole file, not by scrap. A move does not make them stale, so they do not need clearing.

Do not call `removeElement`, `removeElementFromParent` or `addElementToParent`: those paths either recursively delete descendants or unregister THIDs. Assert valid MPIDs, parent existence and insertion bounds at this low-level boundary.

### 4.3 Hierarchy validation

Create `lib/src/auxiliary/th2_hierarchy_aux.dart` with a pure validator:

```dart
MPHierarchyMoveCheck validateMove(
  TH2File th2File, {
  required List<int> elementMPIDs,
  required int newParentMPID,
  int? beforeSiblingMPID,
})
```

Use a typed result with at least `ok` and `rejected(reasonKey)` states. Validate:

- scraps can only have the file as parent;
- points, lines and areas can only have a scrap as parent;
- no element can be dropped onto itself or into its own subtree;
- every selected element is a supported movable top-level kind;
- `beforeSiblingMPID`, when present, belongs to the requested parent and is not one of the moving elements;
- `beforeSiblingMPID` may be the target scrap's `THEndscrap`, meaning end of scrap;
- a standalone line that borders an area cannot change scraps;
- a move to the current effective position is a no-op;
- an area moved across scraps expands to include all referenced border lines, and every such line is movable under the area rule;
- an area moved across scraps is rejected when one of its border lines also borders another area that is not part of the same move. Selecting both areas makes the move valid.

The validator must not mutate the file and must be usable during drag-hover before a command exists. Keep reason keys stable for Phase 4 localization. Add a helper for finding an area’s referenced border-line MPIDs (`THArea.getLineMPIDs`) and a helper returning **all** areas that reference a given line. The second one must scan every area's border references, because `_areaMPIDByLineMPID` keeps only one area per line. The command uses these helpers instead of repeating the traversal.

### 4.4 Command and sequential resolution

Add `lib/src/commands/mp_move_elements_command.dart` as a `part` of `mp_command.dart`.

The command accepts a list of concrete `MPElementMove` records, or an equivalent immutable value type, and executes them in order. For multi-selection, preserve the current relative order of the selected elements. When they come from several parents, that order is file order: scraps in file order, then children in each scrap's order. Area moves across scraps are expanded during preparation to move the area and its referenced border lines as one undoable command; area moves within the same scrap move only the area.

Indices must be resolved sequentially. Simulate the affected parent lists while preparing the command so the second move sees the list left by the first. This is required for adjacent siblings and for several elements entering the same parent. Record each move’s original `(parentMPID, index)` immediately before that move, in `_prepareUndoRedoInfo`. Undo applies inverse moves in reverse order, restoring both child-list order and parent MPIDs exactly. Following the map-based pattern, `_createUndoRedoCommand` builds `mapUndo` as the `toMap()` of another `MPMoveElementsCommand` holding those inverse moves in reverse order. The original index uses the same after-removal convention as §4.1, so the inverse move is also a valid move.

Register the command in all existing command plumbing:

- add a distinct structural value to `MPCommandType`;
- add the `part` declaration and `MPCommand.fromMap` case;
- add the factory method in `MPCommandFactory`;
- implement `toMap`, `fromMap`, `fromJson`, `copyWith`, equality and hash code following `MPReorderScrapsCommand` conventions;
- preserve `MPCommandDescriptionType.moveElements` and add only the required user-facing description/localization if the existing description cannot be reused.

The factory must reject invalid requests before constructing a command, return no command for a no-op, and make all area-border expansion decisions deterministic.

### 4.5 Controller API and redraws

In `TH2FileEditElementEditController`, add:

- `checkMoveElements(...)`, a pure wrapper around `TH2HierarchyAux.validateMove`;
- `moveElements(...)`, which validates, resolves/expands the request, creates the command and submits it through `TH2FileEditController.execute`. The name follows the existing `reorderScraps`/`executeReorderScraps` pair, not the `prepare*` wording;
- `executeMoveElements(...)`, an `@action` that applies the prepared moves through the raw model primitive;
- `moveElementsToScrap(...)`;
- `bringForward`, `sendBackward`, `bringToFront` and `sendToBack`.

The bring/send methods operate on visible movable siblings but resolve positions in the full child lists. Forward means the next sibling of any supported type; backward means the previous sibling. A line or area is crossed as one subtree, so no move may insert a point between an owner and its `end*`. Front/back means the first/last valid position in the parent, not the first/last drawable index. For areas, these operations change only file order and have no visible canvas effect (§2).

Each structural execution must:

- assert that the controller is not broken;
- refresh selection state after each move: call `selectionController.updateSelectedElementLogicalClone` for moved elements that stay selected, call `resetSelectableElements()` when any element enters or leaves the active scrap, and deselect a selected element that leaves the active scrap (selection only works inside the active scrap);
- invalidate/redraw non-selected elements and any affected images/area support state;
- mark the file dirty through the normal command path;
- increment the structure revision exactly once per command execution, including undo and redo.

### 4.6 Structure revision

Add an observable `@readonly int _structureRevision` to `TH2FileEditController`. Increment it after structural changes from `executeMoveElements`, `executeAddElement`, `executeRemoveElement...`, `executeReorderScraps`, and substitutions that change a tree-visible label such as type or THID. The label paths include the type edit commands and `executeSetOptionToElement`/`executeRemoveOptionFromElement` when the option is `id`.

`executeAddElement` and `executeRemoveElement...` increment only for elements the tree shows (scraps, points, lines and areas). `executeAddLineSegment` goes through `executeAddElement`, and incrementing for each segment would rebuild the tree while a line is being drawn.

Parser insertion must not notify once per element. While `_isLoading` is true, defer increments and perform one increment during `_postParseInitialize`. The same revision must be restored/advanced through undo and redo because those operations call the execute methods. Phase 3 will observe this value when rebuilding rows.

## 5. Controller disposal and tab-less cleanup

### 5.1 `TH2FileEditController.dispose()`

Add `dispose()` to `TH2FileEditController`. It runs and clears every entry in `_disposers` and releases anything else the controller owns that needs explicit release (focus node, timers). Calling it twice is harmless. Call it from:

- `MPGeneralController.removeFileController`, so closing a tab disposes its controller;
- `MPGeneralController.reloadTH2File`, for the replaced controller;
- `getTH2FileEditController(forceNewController: true)`, for the replaced controller;
- the tab-less cleanup below.

### 5.2 Tab-less cleanup

Add `MPGeneralController.disposeTablessTH2Controllers(Iterable<String> canonicalPaths)`.

For each target path, dispose and remove its TH2 controller when no open tab represents it. **Dirty controllers are disposed too.** The rule that a modified file always has a visible tab only arrives in Phase 4 ("open the tab on the first edit"), so it cannot be relied on here. More importantly, the cleanup runs after the unsaved-changes guard, when `closeProjectFileTabs` has already removed tabbed controllers whether they were dirty or not. Keeping a dirty tab-less controller would bring back edits the user chose to discard the next time the project opens. Normalize paths using the existing `_normalizeFilename` helper and iterate over a copy of the controller map keys.

Call this method from `THProjectController._beginProjectLifecycleTransition()`, right after `closeProjectFileTabs(outgoingPaths)`. That one place covers every lifecycle transition: `openProject` (replacing an open project), `reloadProject` and `closeProject`. It must leave standalone `.th2` controllers outside the outgoing project untouched. Ensure a disposed controller cannot be returned by a subsequent tree expansion; it must be recreated and loaded normally.

## 6. Implementation order

1. Add/confirm model helpers and cache invalidation; write direct model tests first.
2. Add `MPHierarchyMoveCheck` and `TH2HierarchyAux` with no UI dependencies; write the complete validation matrix.
3. Add the command value type, sequential simulation, area-border expansion, undo/redo and serialization registration.
4. Add controller prepare/execute and bring/send APIs; wire revision, selection and redraw updates.
5. Add `TH2FileEditController.dispose()`, wire it into every removal path, then add tab-less controller cleanup and lifecycle tests.
6. Run the focused tests, then `flutter analyze` and the full test suite. Do not run `build_runner` manually or `dart format`.

## 7. Tests

Before allocating names, scan the test tree for duplicate numeric prefixes. The roadmap proposes `t2462` for the command suite (`t2461` is occupied) and `t3941` for hierarchy validation; retain those only if still free.

### 7.1 Command/model suite

`t2462_commands_mpmoveelementscommand_test.dart` should cover:

- reorder point, line and area siblings within one scrap;
- move a point/line/area between scraps;
- reorder scraps at file level;
- move an area within its scrap without moving border lines;
- move an area between scraps with all referenced border lines, preserving their relative order;
- reject moving an area between scraps when one of its border lines also borders another area, and accept it when both areas move together;
- move several adjacent siblings as one command;
- move several elements from different scraps into one scrap, keeping file order;
- move to end of scrap through `beforeSiblingMPID` set to the `THEndscrap`;
- bring/send across a sibling of another type and across hidden comments/empty lines;
- no-op, first/last boundary and invalid-command behavior;
- undo and redo restoring `childrenMPIDs`, `parentMPID`, THID lookup and subtree membership exactly;
- selected elements remaining consistent after an intra-scrap move, and a selected element leaving the active scrap being deselected;
- command `toMap`/`fromMap` and JSON round trips;
- writer output differing only in block order, with each moved element retaining its original line text.

Explicitly assert that a point moved forward past a multi-segment line is written after that line’s `endline`, and a point moved backward past an area is written before the area opening line.

### 7.2 Validator suite

`t3941_th2_hierarchy_aux_test.dart` should cover every movable element type against file, scrap, line and area parents; self/subtree targets; invalid sibling IDs; `THEndscrap` as `beforeSiblingMPID`; no-op moves; line-border restrictions; area-border expansion; a border line shared by two areas; mixed multi-selection; and preservation of hidden children.

### 7.3 Lifecycle/revision coverage

Extend the nearest existing `MPGeneralController`/project lifecycle tests, or add a focused test if no suitable seam exists, to prove that:

- a tab-less project controller is disposed on close, with its reactions disposed;
- it is disposed on reload and recreated on next access;
- it is disposed when another project is opened in place of the current one;
- a dirty tab-less project controller is disposed too, and the next access loads the file from disk;
- closing a tab disposes its controller, and `reloadTH2File` disposes the replaced one;
- unrelated standalone controllers remain untouched;
- `_structureRevision` advances once after load and once per move/undo/redo, not once per parsed element, and not when a line segment is added.

## 8. Expected files

| Area | Files |
|---|---|
| Model | `lib/src/elements/th2_file.dart`, `lib/src/elements/mixins/th_is_parent_mixin.dart` |
| Command | new `lib/src/commands/mp_move_elements_command.dart`, `lib/src/commands/mp_command.dart`, `lib/src/commands/types/mp_command_type.dart`, `lib/src/commands/factories/mp_command_factory.dart` |
| Controllers | `lib/src/controllers/th2_file_edit_element_edit_controller.dart`, `lib/src/controllers/th2_file_edit_controller.dart` (`_structureRevision`, `dispose()`), `lib/src/controllers/mp_general_controller.dart`, `lib/src/controllers/th_project_controller.dart` (cleanup call in `_beginProjectLifecycleTransition()`) |
| Auxiliary | new `lib/src/auxiliary/th2_hierarchy_aux.dart`, possibly `lib/src/auxiliary/mp_text_to_user.dart` for command description/reason mapping |
| Localization | `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb` only if a new command description is needed |
| Tests | `test/t2462_commands_mpmoveelementscommand_test.dart`, `test/t3941_th2_hierarchy_aux_test.dart`, existing lifecycle/revision test files as appropriate |

Generated `.g.dart` files may be updated by the existing watch process; do not edit them manually.

## 9. Acceptance criteria

- A valid TH2 file can reorder or reparent supported top-level elements only through one undoable command.
- Invalid hierarchy moves are rejected before mutation, and the validator is pure.
- Areas moved across scraps carry their referenced border lines; lines cannot be separated from an area by a cross-scrap move, including lines shared by two areas.
- Comments and other hidden children remain in the full source order; no element subtree is split.
- THIDs, original line text, selection state, canvas order and writer output remain consistent.
- Undo/redo and command persistence round-trip exact structure and parent relationships.
- TH2 controllers are disposed, reactions included, whenever they are dropped, and tab-less project controllers do not leak across project open, reload or close.
- Focused tests pass, full tests pass, `flutter analyze` is clean, and the diff contains no formatting-only churn.
