<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 3: Read-only Sidebar

**Date:** 2026-09-23  
**Status:** Proposed  
**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md)  
**Prerequisite:** Phase 1 broken-file handling and Phase 2 model/controller revision support  
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose

Expose the file order of a valid `.th2` file in the project sidebar without adding any editing operation yet. A `TH2FileNode` expands lazily to show scraps and their point, line and area children in the exact order held by `TH2File.childrenMPIDs` and each scrap's `childrenMPIDs`.

This phase provides the read-only row model and the tree-to-canvas selection connection that Phase 4 will use for drag-and-drop and context-menu moves. It must not mutate a file, create an undo command, or open a tab merely because a user expands a file row.

## 2. Scope

### In scope

- A sealed visible-row model that can represent project nodes, TH2 element rows and TH2 loading/broken status rows.
- Lazy loading of a file's existing `TH2FileEditController` when its file row is expanded.
- Rendering file → scrap → point/line/area hierarchy in file order.
- Loading, load-error and broken-file status rows.
- A broken badge and reload action from the broken file row's context menu.
- Search matching for labels belonging to loaded, valid TH2 files.
- Element labels, existing element icons, indentation, expansion state and selection highlight.
- Tree-to-canvas selection for open files and canvas-to-tree highlight synchronization.
- Rebuilding the rows after load, undo/redo, type/id changes and controller reload via `isFileLoaded` and `structureRevision`.

### Out of scope

- Drag-and-drop, insertion indicators, auto-scroll and moving elements.
- Context-menu move actions and keyboard shortcuts.
- Loading files just to satisfy a search query.
- Showing elements from broken files.
- Pre-scanning all project files.
- Showing comments, empty lines, settings, images, line segments or area border references as rows.
- Changes to parser behavior, TH2 serialization or canvas paint order.

## 3. Existing constraints

- `THProjectNode` is the project parser's tree and must not receive TH2 model elements. Its `children` list is rebuilt by project parsing and has no safe connection to MobX file state.
- `THProjectTreeWidget` currently consumes `List<THProjectTreeVisibleNode>` and always builds `THProjectTreeNodeWidget`; the flattener and builder must become polymorphic without changing project-node behavior.
- `TH2FileNode` is currently a leaf. Its chevron must be available even before a controller exists, because expanding it is what starts lazy loading.
- `TH2FileEditController.load()` is cached. Tree expansion must request the existing controller through `MPGeneralController` and await that cached future rather than starting a second parse.
- `TH2FileEditController.isFileLoaded`, `isBroken`, `problems` and `structureRevision` are the observable lifecycle/data signals. The tree must not inspect private parser state or infer loading from whether a tab exists.
- A tab-less controller is valid after tree loading. Reading a file in the tree must not call `addFileTab`, mark the file dirty or alter the active canvas tab.
- MPIDs are runtime identifiers. Row ids must include the canonical file path and MPID, and stale expansion ids after reload are harmless.
- `TH2File.childrenMPIDs` and `THScrap.childrenMPIDs` include hidden source-order children. The row builder filters the supported visible element kinds while preserving the remaining elements' order; it must never use drawable-child order because areas are intentionally not drawable children.

## 4. Row model

Create a sealed visible-row hierarchy in `th_project_tree_flatten_aux.dart` or a small adjacent model file:

```dart
sealed class THProjectTreeVisibleRow {
  int get depth;
  String get rowId;
}

final class THProjectTreeNodeRow extends THProjectTreeVisibleRow {
  final THProjectNode node;
  // depth and rowId delegate to the project-tree identity.
}

final class TH2ElementTreeRow extends THProjectTreeVisibleRow {
  final String th2FilePath;
  final int elementMPID;
  final THElementType elementType;
  final int depth;
}

final class TH2FileStatusTreeRow extends THProjectTreeVisibleRow {
  final String th2FilePath;
  final TH2FileStatusTreeRowKind kind;
  final int depth;
}
```

The exact private/public split may follow project conventions, but these semantics are required:

- Project rows retain their current ids and selection behavior.
- Element ids use `th2el:<canonicalPath>:<mpID>`.
- Status ids use a stable file-based prefix and status kind, not a transient future identity.
- The row model carries enough information for a widget to activate a file, find the element, show its icon/label, and select it without looking up a `THProjectNode` child.
- A status row is not a movable element and has no canvas selection.

## 5. Flattening and lazy loading

Extend `flattenVisibleNodes` with an optional callback:

```dart
th2ElementRowsFor(TH2FileNode node, int depth)
```

When a file row is expanded, insert the callback's rows immediately after the file row. Keep the existing depth-first behavior for all ordinary project nodes.

The callback is responsible for this state machine:

| Controller state | Rows | File-row behavior |
|---|---|---|
| No controller or load in progress | one `loading` row | request `getTH2FileEditController(...).load()` once |
| Load throws | one `loadError` row | keep the project row usable; opening the file tab remains the existing error path |
| Loaded and broken | one `broken` row | show broken badge and no element rows |
| Loaded and valid | element rows from the model | show scraps and their PLA children |

The callback must be invoked inside the tree `Observer`, and must read `isFileLoaded`, `isBroken` and `structureRevision` so the rows rebuild after asynchronous load, reload, undo and redo. It may return loading before the future completes, but it must not synchronously block the build method.

Expansion behavior:

1. Tapping a `TH2FileNode` chevron toggles its project-tree expansion id.
2. On the transition to expanded, request the controller and call `load()` if it is not loaded.
3. Do not add a tab and do not select the project node merely because the chevron was tapped.
4. Tapping the file label keeps the existing behavior: select the project node and open/activate its tab.
5. A broken status row opens the file tab; its diagnostic body is responsible for displaying the detailed problems.
6. A broken file's context menu offers Reload. Reload replaces the controller through the existing `reloadTH2File` path and does not offer any element operation.

Avoid starting the load from a pure flattening callback if that would cause repeated side effects during rebuilds. Use a small tree/controller helper or an idempotent `ensureTH2FileControllerLoading` method in `THProjectTreeWidget`/`MPGeneralController`; tests must verify that repeated rebuilds produce one load request.

## 6. Element rows and labels

Add `lib/src/auxiliary/th2_element_tree_aux.dart` to build rows and labels from a loaded valid `TH2File`.

The builder walks only direct top-level children of the file and direct children of each `THScrap`:

- file children: `THScrap` rows;
- scrap children: `THPoint`, `THLine` and `THArea` rows;
- all other children are hidden but remain in their source-order slots.

Do not recurse into lines or areas. Their segments, options, border references and closing elements move with their owner in later phases but are not tree rows.

Labels follow the parent plan: localized type/subtype text, followed by the Therion id when present. Examples are `line wall:blocks id=w12` and `point station (1.3)`. Reuse the existing `MPTextToUser` and element icon mappings. Do not hardcode user-facing strings or use all-caps labels.

The header receives a tooltip explaining that the first row is drawn first and the last row is drawn last/on top according to XTherion file order. This is a file-order explanation only; it must not claim to represent Therion's symbol-class rendering order.

## 7. Filtering

Extend the visible-row filtering without changing the project parser:

- A project file node matches as it does today.
- A loaded, valid file's element labels participate in descendant matching.
- A matching element causes its file and scrap ancestors to remain visible and expanded in the filtered result.
- Filtering does not load an unopened file. An unloaded file can match only by its existing project-node label.
- Broken, loading and load-error status text is not treated as an element label; the file remains visible if the file node itself matches.
- Preserve the caller's explicit expansion set while auto-showing matching ancestors, as current project filtering does.

Implement this through row-aware subtree matching rather than by injecting temporary `THProjectNode`s into the project model.

## 8. Selection synchronization

### Tree to canvas

- Tapping an element row in an open valid file activates the file tab, makes its scrap active with `setActiveScrapByChildElement`, and selects the element through the existing selection controller.
- Double-tapping also performs the existing selection zoom (`zoomToFit` with selection).
- Tapping an element in a tab-less valid file only highlights the row. Double-tapping opens/activates its tab, then applies the selection.
- A row in a broken/loading/error state never attempts canvas selection.

Use the canonical path and MPID to resolve the controller. Do not treat a tree row as a `THProjectNode` or add a second selection source of truth.

### Canvas to tree

When the file is expanded, derive the selected row from the active file controller's selection controller. Highlight only the matching element row. Selection highlighting must not reorder rows or change expansion state.

If the selected element is in another file or the file is not expanded, no element row is highlighted. A selected element in a different active scrap remains represented by its row; changing the active scrap is handled by existing canvas behavior.

## 9. Widget structure

Create `TH2ElementTreeRowWidget` for element and status rows, or use two private widgets behind that public name. It must support:

- the existing project-tree row height and indentation constants;
- PLA/scrap icons and localized labels;
- selected-row background matching the project row;
- loading/error/broken status affordances;
- a broken badge on the file row with problem count and a tooltip containing the first problems;
- a context menu entry for Reload only when the file is broken.

Keep ordinary project node rendering in `THProjectTreeNodeWidget` unless a small shared row shell reduces duplication. The refactor must preserve compiler-error dots, dirty dots, text-editor opening, project-node selection and the current empty-project UI.

## 10. Implementation order

1. Add the sealed visible-row types and update the flattener with compatibility tests for ordinary project trees.
2. Add `th2_element_tree_aux.dart` and pure row/label tests using valid and broken controller fixtures.
3. Refactor `THProjectTreeWidget` to render each row kind and observe loaded-controller state/revisions.
4. Add the file-row chevron and idempotent lazy-load trigger; verify that expansion does not open a tab or dirty a file.
5. Add status rows, broken badge, Reload context action and load-error handling.
6. Add loaded-element filtering and the drawing-order tooltip.
7. Wire tree-to-canvas selection and canvas-to-tree highlight, including tab-less files and double-click zoom.
8. Run focused tests, `flutter analyze`, and the full test suite. Do not run `build_runner` manually or `dart format`.
9. Add a CHANGELOG entry for the completed phase, as required by the parent plan.

## 11. Expected files

| Area | Files |
|---|---|
| Row model/flattening | `lib/src/auxiliary/th_project_tree_flatten_aux.dart`, possibly a new visible-row model file |
| TH2 row builder | new `lib/src/auxiliary/th2_element_tree_aux.dart` |
| Widgets | `lib/src/widgets/th_project_tree_widget.dart`, `lib/src/widgets/th_project_tree_node_widget.dart`, new `lib/src/widgets/th2_element_tree_row_widget.dart` |
| Controllers | `lib/src/controllers/th2_file_edit_controller.dart` (observable lifecycle/revision consumption only), `lib/src/controllers/mp_general_controller.dart` (idempotent load/reload helper if needed), selection controller files only if an adapter is required |
| Text/icon helpers | existing `mp_text_to_user.dart` and `th_project_tree_node_icon_widget.dart`, only where reuse requires a small extension |
| Tests | `test/t3881_th_project_tree_flatten_test.dart`, `test/t3883_th_project_tree_widget_test.dart`, new `test/t3942_th2_element_tree_rows_test.dart`, new `test/t3943_th2_element_tree_widget_test.dart` |
| Changelog | `CHANGELOG.md` |

Do not edit generated `.g.dart` files manually. If the MobX watch process regenerates them after an annotated source change, include only the required generated diff.

## 12. Tests and acceptance criteria

### Pure row/flattening tests (`t3942`)

- Valid files produce file → scraps → PLAs in exact source order.
- Areas are included even though they are not drawable children.
- Comments, empty lines, settings, images, line segments and `end*` elements are excluded.
- A broken file produces only one broken status row.
- Loading and load-error states produce exactly one corresponding status row.
- Element row ids include canonical path and MPID and remain distinct across files.
- Filter matching includes loaded element labels, preserves ancestors, and does not load unopened files.
- Existing project-node filtering and expansion behavior remains unchanged.

### Widget tests (`t3943` and updated `t3883`)

- A file row always has an expansion affordance.
- Expanding requests one lazy load, creates no tab, changes no dirty state, and displays Loading before completion.
- A valid load displays rows and the broken badge is absent.
- A broken load displays the badge/count and status row, never element rows, and offers Reload.
- Reload replaces the controller and updates the row state after the future completes.
- Tapping an element in an open file selects it and activates its scrap; double-tap zooms to selection.
- Tapping a tab-less element only highlights it; double-tap opens the tab and selects it.
- Canvas selection highlights the corresponding row and clears/moves the highlight when selection changes.
- Undo/redo changes the visible order after `structureRevision` changes.
- Existing project-file opening, compiler-error dots, dirty dots and text-editor rows remain green.

### Acceptance

- Users can inspect XTherion file order from the sidebar without opening every file in a tab.
- Tree loading is lazy, idempotent and side-effect free apart from creating the cached tab-less controller.
- Broken files are clearly identified and never expose partially parsed elements.
- Selection state is consistent between the sidebar and canvas for valid open files.
- Focused tests, the full test suite and `flutter analyze` pass with no formatting-only churn.
