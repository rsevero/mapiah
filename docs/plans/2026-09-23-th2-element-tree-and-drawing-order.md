<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree in the Project Sidebar (Drawing Order and Hierarchy Editing): Implementation Plan

**Date:** 2026-09-23
**Status:** Proposed. Checked against the codebase on 2026-09-23 (`main` at `24c44fcc`). Revised the same day with these decisions: broken-file status instead of drawing violators on the canvas; XTherion drawing order only; the broken badge only after a file is opened; broken files can be saved; bring forward and send backward step over the next row of any type; missing `endline`/`endarea` count as violations.
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Overview and Objectives

Issue #32 asks for two things XTherion already has: a way to **see** the relative stacking order of a drawing's objects, and a way to **change** it by moving objects up and down. In a `.th2` file the stacking order, as XTherion shows and edits it, is the file order. An object written later is drawn on top of an object written earlier.

This plan adds an expandable list of each `.th2` file's elements under that file's node in the project sidebar. It has these levels: file → scraps → points, lines and areas. The list can be reordered with drag and drop. The allowed moves follow Therion's structure rules. A file that breaks those rules is loaded without losing data and gets a **broken** status. It is not drawn on the canvas until the user fixes it from the element tree or with a Fix-hierarchy dialog.

### Key objectives

1. **See the order.** Every `TH2FileNode` in the project tree can be expanded to show its scraps, and each scrap can be expanded to show its points, lines and areas, in file order (XTherion's order).
2. **Reorder within a parent.** Drag a scrap to a new position among the file's scraps. Drag a point, line or area to a new position inside its scrap. Bring forward, Send backward, Bring to front and Send to back do the same without dragging.
3. **Move between scraps.** Drag a point, line or area from one scrap into another scrap in the same file.
4. **Enforce the hierarchy.** Points, lines and areas must end up inside a scrap. A scrap must end up directly under the file, never inside another scrap. The UI must reject any drop that would break this, and must say so visibly.
5. **Broken-file status.** A file that breaks the hierarchy loads **without data loss** and is marked broken. Hierarchy violations are points, lines or areas outside a scrap, a scrap inside a scrap, a stray `endscrap`, and a line, area or scrap missing its own `endline`/`endarea`/`endscrap`. A broken file is not drawn on the canvas. Its elements appear only in the sidebar tree, where the user moves or closes the offending elements until the file is valid. The file then switches to the normal canvas automatically.
6. **Undoable, file-preserving edits.** Every structural change is one `MPCommand` on the file's own undo stack. Saving keeps each moved element's original text (`originalLineInTH2File`), so only the order, plus any added `end*` lines, changes on disk. Broken files can be saved at any point.
7. **Canvas integration.** For a valid file, clicking a tree row selects that element on the canvas and makes its scrap active. The canvas repaints right away in the new order.
8. **Complete integration.** EN/PT localization, help pages and keyboard shortcuts are updated. Controller, command, parser and widget tests are added. `flutter analyze` and `flutter test` stay green.

### Non-goals (this plan)

- **Therion's own rendering order.** It may layer by symbol class and by `-place bottom/default/top`. This plan only deals with XTherion's order, which is file order. `-place` stays editable through the existing option editor.
- Moving elements **between files**.
- Showing line segments, area border references, comments, xtherion settings or images as tree rows.
- A TH2 element tree when no project is open. The broken-file tab body (§4.8) still lets such a file be fixed with the Fix-hierarchy dialog.
- Pre-scanning a project's `.th2` files when the project loads, just to detect broken files. The broken badge only appears after a file is loaded (§4.2).
- Other parse errors (plain syntax errors), which keep today's behavior. The line is reported in the load-error dialog and dropped.

## 2. Grounding: Current State

### 2.1 Project sidebar (`lib/src/widgets/th_project_tree_widget.dart`, `th_project_tree_node_widget.dart`, `lib/src/auxiliary/th_project_tree_flatten_aux.dart`)

- The tree is built from `THProjectNode` objects (`lib/src/elements/th_project/th_project_node.dart`). The project parser creates them. Each node has a `children` list, a string `id`, a `label`, a `sourceFilePath` and a `lineNumber`.
- `TH2FileNode` (`th2_file_node.dart`) is a **leaf**. Its doc comment says that the `.th2` contents "are intentionally not parsed by `THProjectParser`; they are loaded lazily when a canvas tab is opened". A `THScrapNode` with `isFromTH2File` exists, but the widget comments that this flag is "always false today" (`th_project_tree_node_widget.dart:106-107`).
- `flattenVisibleNodes(...)` walks `THProjectNode.children` depth first. It honors `THProjectTreeUIController.isExpanded(node.id)` and the filter. It returns `THProjectTreeVisibleNode(node, depth)` rows, which a plain `ListView.builder` renders (`th_project_tree_widget.dart:68-87`).
- `THProjectTreeNodeWidget._buildExpandControl` shows a chevron only when `node.children.isNotEmpty` (`:153-175`). A `TH2FileNode` therefore has no chevron today.
- `THProjectTreeUIController` (`th_project_tree_ui_controller.dart`) holds an `ObservableSet<String> expandedNodeIds` and has `toggleExpanded`/`expand`/`collapse`/`expandAncestorsOf` actions. It is keyed by string id, so new row kinds can use it as is.
- Tapping a `TH2FileNode` calls `getTH2FileEditController(filename:)` and `addFileTab(...)` (`th_project_tree_node_widget.dart:81-86`).

### 2.2 TH2 data model

- `TH2File` (`lib/src/elements/th2_file.dart`) mixes in `THIsParentMixin`. Its `childrenMPIDs` holds the ordered top-level children, and `_elementByMPID` holds every element. It also keeps derived caches such as `_scrapMPIDs`, `_imageMPIDs`, `_pointsMPIDs`/`_linesMPIDs`/`_areasMPIDs` and the area↔line maps. These are updated in `_updateSupportMaps` (`:388-422`) and `removeElement` (`:458-523`).
- `THIsParentMixin` (`lib/src/elements/mixins/th_is_parent_mixin.dart`) owns `childrenMPIDs` and a cached `_drawableChildrenMPIDs` (lines, points and scraps, in child order). `addElementToParent(element, elementPositionInParent:)` supports an explicit index or `mpAddChildAtEndMinusOneOfParentChildrenList`, which inserts just before the closing `endscrap`/`endline`/`endarea`. **That default assumes the closing element exists.** If it doesn't, the new child lands before the last real child. This is one reason a file with a missing `end*` must not be edited on the canvas (§4.8). `removeElementFromParent` also **unregisters the element's thID** (`:96-98`).
- `THElement.parentMPID` is **`final`** (`th_element.dart:95`). A negative `parentMPID` means "the file" (`parent()`, `:126-136`). Changing an element's parent therefore means creating a `copyWith(parentMPID: …)` and replacing the element with `TH2File.substituteElement(...)` (`th2_file.dart:322-…`).
- `TH2File.removeElement` removes **all descendants recursively** (`:459-467`). A plain "remove, then add" would delete a line's segments or an area's border references. A move needs its own primitive.
- **Existing reorder precedent.** `TH2File.reorderScrapMPIDs({oldIndex, newIndex})` (`:846-892`) reorders scraps inside `childrenMPIDs` and leaves non-scrap children in their slots. `MPReorderScrapsCommand` (`lib/src/commands/mp_reorder_scraps_command.dart`) wraps it through `TH2FileEditElementEditController.reorderScraps`/`executeReorderScraps` (`th2_file_edit_element_edit_controller.dart:1329-1341`). The scraps dialog (`mp_available_scraps_widget.dart`) drives it with `Draggable<int>`/`DragTarget<int>` rows. `MPReorderImagesCommand` and `mp_available_images_widget.dart` follow the same pattern. This plan reuses that command, factory, description and localization pattern. It also reuses the `Draggable`/`DragTarget` pattern (the code does not use `ReorderableListView`).

### 2.3 Parser: hierarchy violations are currently dropped (data loss)

- `TH2Grammar` (`lib/src/mp_file_read_write/th2_grammar.dart:33-55`) chooses the grammar by context:
  - file level `th2Structure()`: `xtherionConfig | mapiahConfig | multiLineComment | scrap | fullLineComment`;
  - scrap level `scrapContent()`: `point | line | area | endscrap`;
  - line level `lineContent()`: segments, line options, `endline`;
  - area level `areaContent()`: `endarea`, area options, border references.
- `TH2FileParser._injectContents` (`th2_file_parser.dart:~145-262`) switches `_currentParser` as scraps, lines and areas open and close. When a line does not match the current context's grammar, the result is a `Failure`. The parser then records an error with `_addError(...)` and runs `continue`. **The line never enters the model.**
- Results for each violation:
  - **Point, line or area at file level:** the `point`/`line`/`area` line fails and is dropped. For a multi-line `line … endline` every following line also fails, because the line parser was never pushed. Everything is lost.
  - **Scrap inside a scrap:** the inner `scrap` line is dropped. Its contents are silently added to the **outer** scrap. The inner `endscrap` closes the outer scrap, and the outer `endscrap` then fails at file level and is dropped. Saving writes one merged scrap.
  - **Missing `endline`/`endarea`:** the line or area parser stays active. Every following `point`, `line`, `area` or `endscrap` fails that context's grammar and is dropped, until an `endline`/`endarea` happens to appear. If none does, everything to the end of the file is lost. At the end of the file only "Multiline commmands left open at end of file" is reported (`th2_file_parser.dart:~2712-2719`).
  - **Missing `endscrap`:** the scrap stays open. A following `scrap` is dropped (as in the nested case), and the end-of-file "left open" error is reported.
- `_injectEndLine` (`:1061-…`) and `_injectEndArea` (`:1045-1059`) pop the parent and parser. `TH2FileWriter` can generate a fresh `endline`/`endarea` line for a new `THEndline`/`THEndarea` with an empty `originalLineInTH2File` (`th2_file_writer.dart:253-270`). This is what the "close element" fix needs (§5.3).
- `TH2FileEditController._postParseInitialize` (`th2_file_edit_controller.dart:729-740`) copies the errors into `errorMessages`, and the file still opens and can be saved. **Saving it makes the loss permanent.**

### 2.4 Canvas paint order

- `MPNonSelectedElementsWidget.addChildrenPainters` (`lib/src/widgets/mp_non_selected_elements_widget.dart:71-140`) and `mp_non_selected_scraps_widget.dart:71` iterate `parent.getDrawableChildrenMPIDs()` in child order. Mapiah therefore already paints in file order, matching XTherion. Reordering `childrenMPIDs` and clearing `_drawableChildrenMPIDs` is enough to change the stacking on screen.
- Selected elements are painted by a separate widget, on top of everything. The tree shows file order, not the temporary "selected on top" order.

### 2.5 Writer

- `TH2FileWriter` (`lib/src/mp_file_read_write/th2_file_writer.dart:114, 421`) serializes by walking `childrenMPIDs` recursively. It writes `originalLineInTH2File` for unmodified elements. A moved element keeps its original text and is simply written in its new position. A file-level PLA or a nested scrap is written where it is in the tree, so a broken file round-trips as it was read. **No writer change is expected.** Round-trip tests confirm it (Phase 1).

### 2.6 Controller lifecycle and dirty tracking

- `MPGeneralController.getTH2FileEditController(filename:)` creates and registers a controller whether or not a tab exists (`mp_general_controller.dart:337-361`). `controller.load()` parses it once and caches the future (`th2_file_edit_controller.dart:~696-727`). `_finalFilePreparations` (`:742-775`) sets the active scrap and snap targets, and initializes selection, once, after the parse.
- A reaction in `TH2FileEditController` (`:~945-955`) mirrors the controller's dirty state into `THProjectController.dirtyFilePaths`. `_saveTH2ProjectFile` saves through `getTH2FileEditControllerIfExists(path)` (`th_project_controller.dart:1535-…`). A controller with no tab is therefore already counted by the dirty dot, by Save All and by the unsaved-changes guard.
- `closeProjectFileTabs(...)` only disposes controllers that have an **open tab** (`mp_general_controller.dart:296-…`). A controller loaded only for the tree would leak across project close or reload unless cleanup is added (Phase 2).
- Undo/redo is per `TH2FileEditController` (`MPUndoRedoController`). `Ctrl+Z` reaches it only while that file's tab is active.

## 3. Rules This Feature Enforces

### 3.1 Structure rules

| Element | Allowed parent | Must be closed by |
|---|---|---|
| `scrap` | the `.th2` file, never another scrap | its own `endscrap` |
| `point` | a `scrap` | n/a |
| `line` | a `scrap` | its own `endline` |
| `area` | a `scrap` | its own `endarea` |
| line segments, line/area options, area border references | their line or area | n/a (they always move with their owner) |
| comments, empty lines, `##XTHERION##`/`##MAPIAH##` settings, `encoding` | anywhere they already are | n/a (never moved by tree operations, §4.4) |

Extra rule for **areas**: an area's border lines must be in the same scrap as the area.

- Moving an **area** to another scrap also moves every existing border line it references by thID, wherever those lines currently live. These lines keep their relative order and go just before the area. The area and its border lines move in one command.
- Moving an **area** within the same scrap moves only the area; its border lines stay where they are.
- Moving a **line** that borders an area by itself to another scrap is rejected. The drop indicator explains why ("Line is a border of area X; move the area instead"). Moving that line within its current scrap is allowed.

### 3.2 Drawing order

The only order this plan deals with is **XTherion's, which is file order**. Mapiah's canvas already paints in that order (§2.4). The tree shows it **top to bottom = drawn first to drawn last**, so the top row is at the bottom of the stack. That is how XTherion's object list in the issue reads, and it matches the text editor. The tree header gets a small tooltip ("Top of list is drawn first (bottom)"). Therion's own rendering order is explicitly out of scope.

## 4. Design Decisions

### 4.1 Tree rows: a separate row kind, not injected `THProjectNode`s

TH2 elements are not added to `THProjectNode.children`. That tree is rebuilt by project reparses and has no link to a `TH2File` or its MobX state. The visible-row model becomes a sealed type instead:

```dart
sealed class THProjectTreeVisibleRow { int get depth; String get rowId; }
final class THProjectTreeNodeRow extends THProjectTreeVisibleRow { final THProjectNode node; … }
final class TH2ElementTreeRow extends THProjectTreeVisibleRow {
  final String th2FilePath;   // canonical path, equals TH2FileNode.absolutePath
  final int elementMPID;
  final THElementType elementType;
  final List<THHierarchyViolation> violations; // empty for a valid element
  …
}
```

- `flattenVisibleNodes(...)` gains an optional `th2ElementRowsFor(TH2FileNode node, int depth)` callback. When the callback exists and the `TH2FileNode` is expanded, the flattener adds the element rows right after that file row. `THProjectTreeVisibleNode` is renamed or wrapped as `THProjectTreeNodeRow`. Existing tests in `t3881_th_project_tree_flatten_test.dart` are updated.
- Element row ids are `th2el:<canonicalPath>:<mpID>`, so expansion state goes through the same `expandedNodeIds`. MPIDs only exist while the app runs. A stale id after reloading a file is harmless and gets pruned on project close.
- The builder lives in a new `lib/src/auxiliary/th2_element_tree_aux.dart`. It walks `TH2File.childrenMPIDs` and each scrap's `childrenMPIDs`, recursing into nested scraps. It keeps only `THScrap`, `THPoint`, `THLine`, `THArea` and stray `THEndscrap` rows. It runs inside the tree's `Observer`, so structural changes must be observable (§5.5).
- **Labels:** `<type> <subtype?> <thID?>`, for example `line wall:blocks id=w12` or `point station (1.3)`. Type and subtype names are localized with the existing `MPTextToUser` helpers. Scraps show their thID. Rows use the existing PLA type icons where they exist. A row with violations gets a warning icon and a tooltip listing them, such as "Outside any scrap" or "Missing endline".
- **Filter:** the sidebar search filter also matches element labels of **loaded** files. It does not load files just to search them.

### 4.2 Loading a file's elements, and the broken badge

- `TH2FileNode` rows always show a chevron. Expanding one calls `getTH2FileEditController(filename:)` and `load()` if it is not loaded yet. While loading, one "Loading…" row is shown.
- **The broken badge appears only once the file is loaded.** Loading happens when the file is expanded in the tree or opened in a tab. No project-wide pre-scan is done. After loading, a broken file's row shows a "broken" badge with the violation count. The badge updates live as violations are fixed or brought back by undo.
- Loading does **not** open a tab. Only reading the list never creates dirty state.
- **Editing from the tree opens the tab.** The first structural edit made from the tree on a file with no open tab calls `addFileTab(path)` and activates it. The command then runs. This keeps the rule "a modified TH2 file has a visible tab", so undo (`Ctrl+Z`), Save and the close-tab prompt work as they do today. For a broken file, the tab shows the broken-file body (§4.8), not the canvas.
- **Cleanup:** `MPGeneralController` gets `disposeTablessTH2Controllers(Iterable<String> canonicalPaths)`. `THProjectController` calls it on close and reload, together with `closeProjectFileTabs`. Dirty controllers always have a tab, so this only ever disposes clean, read-only controllers.

### 4.3 Drop semantics

Every drop becomes one request: **move element E to parent P, just before sibling S (or at the end of P)**. The drop zone decides it:

| Hover zone on target row T | Resulting request |
|---|---|
| upper third of T | before T, under T's parent |
| lower third of T (T collapsed, or not a scrap) | after T, under T's parent |
| middle of a **scrap** row, or lower third of an expanded scrap | at the **end** of that scrap, or the start when expanded |
| middle of the **file** row | at the end of the file |

Validation happens in one pure function, `TH2HierarchyAux.validateMove(th2File, elementMPIDs, newParentMPID, beforeSiblingMPID) → MPHierarchyMoveCheck` (`ok` / `rejected(reasonKey)`). It is used both while hovering, for the indicator, and in the command, as a guard. Moves must always land in a **valid position**, in valid and broken files alike. A broken element can be moved *out* to a valid place, but nothing can be moved *into* an invalid one:

- `scrap` → parent must be the file (`newParentMPID < 0`).
- `point`/`line`/`area` → parent must be a `THScrap`, and that scrap must not itself be nested in another scrap.
- An element cannot be dropped onto itself or into its own subtree.
- A standalone dropped line that borders an area is rejected when the drop changes its scrap (§3.1). The same line may be reordered within its current scrap.
- An element missing its `end*` cannot be moved until it is closed (§5.3). Its extent in the file is uncertain, so the "close" action comes first. The row's reject tooltip says so.
- Moving to the same position is a no-op and creates no command.

Feedback: a valid drop shows the usual insertion line (as in `mp_available_scraps_widget.dart`). An invalid drop shows a "not allowed" cursor and a tooltip with the localized reason. Invalid drops never create a command.

### 4.4 Non-tree children (comments, empty lines, settings)

Hidden children stay where they are. The move primitive resolves "before sibling S" to S's index in the **full** `childrenMPIDs`. "End of scrap" is resolved to `mpAddChildAtEndMinusOneOfParentChildrenList`, just before `endscrap`. A comment line written right above a line in the file therefore stays at its slot when the line moves. That is the safe choice, since the code has no way to know which element a comment "belongs" to. Possible later option: "full-line comments directly above an element move with it."

### 4.5 Multi-selection

Rows support `Ctrl`/`Shift` multi-select, which mirrors the canvas selection for valid files (§4.6). Dragging a multi-selection moves all selected rows to the drop point in their current relative order, as **one** command. The drop is rejected if any item fails validation.

### 4.6 Tree ↔ canvas selection sync (valid files only)

- Single-clicking an element row of an **open, valid** file activates its tab, sets the active scrap (`setActiveScrap` / `setActiveScrapByChildElement`, `th2_file_edit_controller.dart:1018-1047`), and selects the element through the selection controller. Double-click also zooms to the selection (`zoomToFit(zoomFitToType: MPZoomToFitType.selection)`).
- The canvas selection is reflected back as row highlighting when the file is expanded. This is read-only and comes from `selectionController`.
- Single-click on a row of a **tab-less** file only highlights the row. Double-click opens the tab.
- For a **broken** file, rows are tree-only. Clicking highlights the row, and the canvas is not involved.

### 4.7 Keyboard and context-menu actions (non-drag equivalents)

Every row with a PLA or scrap element has a context menu:

- **Bring forward / Send backward** swaps the element with the **next or previous visible sibling row in the same parent, whatever its type**. For example, a point steps over the adjacent line. A sibling is always stepped over **as a whole**. Bringing a point forward past a line moves it past the entire `line … endline` block, including all its segments, options and the `endline`. An area is passed as its whole `area … endarea` block in the same way. The model gives this for free, because segments, options, border references and the `end*` element are children of the `THLine`/`THArea`, not siblings. The move only reorders the scrap's own `childrenMPIDs`, so the point can never land inside another element's block. The element being moved also carries its own block with it (§5.1). Hidden children (comments, empty lines) are stepped over. **Bring to front / Send to back** moves the element to the end or start of its parent. Scraps use the same actions among scraps. These are the literal requests from issue #32. They also get canvas keyboard shortcuts working on the current selection (valid files only). The key bindings are chosen in Phase 4, after checking for conflicts in the keyboard shortcuts page. The candidates are `Ctrl+]`/`Ctrl+[` and `Ctrl+Shift+]`/`Ctrl+Shift+[`.
- **Move to scrap… ▸ <scrap list>** for PLAs.
- For violators:
  - **Move to scrap…** for a PLA outside any scrap;
  - **Move to file level** for a nested scrap, which lifts it to right after its enclosing scrap;
  - **Close line**, **Close area** and **Close scrap** for an element missing its `end*` (§5.3);
  - **Remove** for a stray `endscrap`.

### 4.8 Broken-file status

**Definition.** A loaded file is *broken* when `TH2HierarchyAux.findViolations(th2File)` is not empty. The violation kinds are:

| Violation | Detected when |
|---|---|
| `plaOutsideScrap(mpID)` | a `THPoint`/`THLine`/`THArea` has the file as parent |
| `scrapInsideScrap(mpID, enclosingScrapMPID)` | a `THScrap` has a scrap as parent |
| `strayEndscrap(mpID)` | a `THEndscrap` has the file as parent |
| `missingEndline(lineMPID)` | a `THLine`'s last child is not a `THEndline` |
| `missingEndarea(areaMPID)` | a `THArea`'s last child is not a `THEndarea` |
| `missingEndscrap(scrapMPID)` | a `THScrap`'s last child is not a `THEndscrap` |
| `areaBorderInOtherScrap(areaMPID, lineMPID)` | a border line's scrap differs from its area's scrap |

"Broken" is **computed, not stored**. A MobX `@computed bool isBroken` / `List<THHierarchyViolation> hierarchyViolations` on `TH2FileEditController` derives it from the `_structureRevision` observable (§5.5). Undo and redo therefore move a file between broken and valid automatically.

**Behavior while broken:**

- **Not drawn.** The file's tab replaces `TH2FileEditBodyWidget`'s canvas with a `TH2BrokenFileBodyWidget` panel. The panel shows:
  - an explanation and the violations list, where clicking a violation reveals and highlights its row in the sidebar tree;
  - a **Fix hierarchy…** button;
  - Undo/Redo and Save buttons.

  It holds keyboard focus so `Ctrl+Z`, `Ctrl+Shift+Z`/`Ctrl+Y` and `Ctrl+S` keep working. Canvas-only toolbar actions and state-machine shortcuts are disabled.
- **Tree only.** Its elements are visible and editable only in the sidebar tree (§4.3, §4.7).
- **Saveable.** Save, Save As and Save All work. The writer round-trips the partly fixed structure faithfully (§2.5), so a large file can be fixed across several sessions.
- **Load notice.** Hierarchy violations are reported as **warnings** (a new `parseWarnings` list on the parse result), not load errors. Instead of the load-error dialog, the file shows the broken badge and the broken panel. Plain syntax errors keep today's dialog.
- **Run Therion.** The run dialog lists open broken files as a warning before running. Therion would fail on them anyway.

**Why the canvas must not see a broken file.** Several canvas paths assume that a PLA's parent is a scrap: active scrap, selection, snapping and the non-selected-elements painter. `addElementToParent`'s default insertion assumes the closing `end*` exists (§2.2). Keeping broken files off the canvas avoids having to harden all of these paths.

**Fix-hierarchy dialog.** It is reachable from the broken panel and from the file row's context menu. It lists the violations with a proposed fix for each:

- orphan PLAs → move into [existing scrap ▾], or a **new scrap** placed after the last scrap (`MPAddScrapCommand` with an auto-generated thID);
- nested scraps → lift to file level right after their enclosing scrap;
- stray `endscrap` → remove;
- missing `endline`/`endarea`/`endscrap` → close;
- an area border in another scrap → move the line into the area's scrap.

The dialog runs everything as one `MPMultipleElementsCommand`, so one undo reverts it. It uses `MPDialogBottomWidget` for its buttons. This dialog is also the way to fix a broken file opened **without a project**, when there is no sidebar tree.

**Switching between broken and valid.** When `isBroken` changes:

- **broken → valid:** clear selection, run the same setup `_finalFilePreparations` does (active scrap = first scrap, `updateHasMultipleScraps`, snap targets, selectable elements, used types, `initializeUsedTypes`), then mount the canvas body. That setup is split out of `_finalFilePreparations` into `prepareCanvasForValidFile()`, so load and this switch share one code path.
- **valid → broken** (only through undo or redo of a fix): reset the state machine to the empty-selection state, clear selection, and unmount the canvas.

## 5. Model and Command Layer

### 5.1 `TH2File` primitive

Add to `TH2File`:

```dart
/// Moves [elementMPID] (with its whole subtree) to [newParentMPID], inserting
/// it at [positionInNewParent] in the parent's full childrenMPIDs (or
/// mpAddChildAtEndMinusOneOfParentChildrenList). Does not validate hierarchy.
void moveElementToParent({
  required int elementMPID,
  required int newParentMPID,
  required int positionInNewParent,
});
```

Implementation:

1. `oldParent.childrenMPIDs.remove(mpID)` directly. It does **not** call `removeElementFromParent`, because that unregisters the thID (§2.2).
2. `newElement = element.copyWith(parentMPID: newParentMPID)`, then `substituteElement(newElement)`. Phase 2 checks that every moved type's `copyWith` accepts `parentMPID` (`THScrap.copyWith` at `th_scrap.dart:111`).
3. Insert into `newParent.childrenMPIDs` at the resolved index.
4. Invalidate caches: both parents' `_drawableChildrenMPIDs` (add a public `invalidateDrawableChildrenCache()` on `THIsParentMixin`), `_scrapMPIDs` when a scrap moves, the scrap bounding boxes of both old and new parent (`clearBoundingBox()`), and `_areaMPIDByLineMPID`/`_areaMPIDByLineTHID` when an area or border line moves.

The children's `parentMPID` points at the element's unchanged MPID, so the subtree does not need rewriting.

### 5.2 `MPMoveElementsCommand`

New file `lib/src/commands/mp_move_elements_command.dart` (a `part of 'mp_command.dart'`, like the rest):

- Fields: `List<MPElementMove> moves` (`elementMPID`, `newParentMPID`, `positionInNewParent`), resolved at prepare time into concrete indices, applied in order.
- `_prepareUndoRedoInfo` records each element's original `(parentMPID, index)`. Undo applies the inverse moves in **reverse** order. This follows `MPRemoveElementCommand._prepareUndoRedoInfo`'s pattern.
- `_actualExecute` → `elementEditController.executeMoveElements(moves)` (`@action`). It calls `TH2File.moveElementToParent` for each move, bumps `_structureRevision`, and redraws the canvas when the file is valid.
- `toMap`/`fromMap`/`copyWith`/`==`/`hashCode` follow `MPReorderScrapsCommand`.
- Register `MPCommandType.moveElements`, `MPCommandDescriptionType.moveElements`, the factory `MPCommandFactory.moveElements(...)`, the `mp_command.dart` `fromMap` switch, and `MPTextToUser` + `.arb` strings ("Move elements" / "Mover elementos").
- Scrap-only reorders from the new tree also use `MPMoveElementsCommand`. `MPReorderScrapsCommand` stays, because the scraps dialog uses it and it appears in saved undo maps.
- Area moves between scraps expand into the area plus all of its referenced border lines inside the same command (§3.1), in the prepare step. Area moves within one scrap include only the area.

### 5.3 Closing elements with a missing `end*`

**Where the parser closes them (§6).** The parser closes an unterminated line, area or scrap **implicitly**, at the first line that doesn't belong to it. So the element's children are exactly the lines that were valid content for it, and it has no `THEndline`/`THEndarea`/`THEndscrap` child.

**What "Close" does.** It adds the missing closing element as the **last child** with the existing `MPAddElementCommand`. It uses `elementPositionInParent: mpAddChildAtEndOfParentChildrenList`, **not** the end-minus-one default, and a new `THEndline`/`THEndarea`/`THEndscrap` with an empty `originalLineInTH2File`. The writer then generates `endline`/`endarea`/`endscrap` on its own line right after the element's last child (§2.3). No new command type is needed. The description reuses "Add element", or gets a specific "Close element" description type if that reads better in the undo menu (decided in Phase 5).

### 5.4 Controller API

In `TH2FileEditElementEditController`:

- `MPHierarchyMoveCheck checkMoveElements({required List<int> elementMPIDs, required int newParentMPID, int? beforeSiblingMPID})`, a pure wrapper over `TH2HierarchyAux.validateMove`.
- `void moveElements({required List<int> elementMPIDs, required int newParentMPID, int? beforeSiblingMPID})` checks, resolves positions, builds the command and runs `_th2FileEditController.execute(...)`.
- Convenience methods used by the context menu and shortcuts:
  - `bringForward`, `sendBackward`, `bringToFront` and `sendToBack` (operating on `List<int>`, stepping over one visible sibling row of any type, §4.7);
  - `moveElementsToScrap(List<int>, int scrapMPID)`;
  - `liftScrapToFileLevel(int scrapMPID)`;
  - `closeElement(int mpID)`;
  - `removeStrayEndscrap(int mpID)`.
- `fixHierarchy(TH2HierarchyFixPlan plan)` builds one `MPMultipleElementsCommand`.

### 5.5 Observability

The tree and the broken status must update after a move, undo or redo. `TH2File` is not a MobX store. Add a `@readonly int _structureRevision` to `TH2FileEditController`. It is bumped by `executeMoveElements`, `executeAddElement`, `executeRemoveElement…`, `executeReorderScraps` and element substitutions that change a label (type or thID edits). Undo and redo also go through these `execute*` methods, so they update the tree too. The tree's `Observer` and the `@computed hierarchyViolations`/`isBroken` read it.

## 6. Lenient Parsing

Changes in `th2_grammar.dart` and `th2_file_parser.dart`:

1. **File level:** `th2Structure()` also accepts `point() | line() | area() | endscrap()`. The inject methods already use `_currentParent`, which is the file at this level. `line`/`area` already push their child parsers, so their bodies parse correctly at file level too. A file-level `endscrap` is kept as a `THEndscrap` child of the file (`strayEndscrap`). `_injectEndScrap` must special-case `TH2File` as the current parent: add the `THEndscrap`, record the warning, leave `_currentParent` unchanged, and return without calling `_returnToParentParser()`. The normal close-and-pop behavior remains unchanged for an `endscrap` belonging to a real scrap. This prevents a root-level stray `endscrap` from causing a parent cast or parser-stack underflow.
2. **Scrap level:** `scrapContent()` also accepts `scrap()`. `_injectScrap` already pushes the scrap parser and makes the new scrap `_currentParent`, and `_injectEndScrap` pops. Nested scraps therefore produce a `THScrap` whose `parentMPID` is the enclosing scrap.
3. **Implicit closing of unterminated line/area (missing `endline`/`endarea`):** when the current context is a line or area and a line fails that context's grammar, the parser checks it against the **enclosing** context. If it parses there (for example `point`, `line`, `area`, `endscrap` or `scrap`), the parser:
   - records `missingEndline`/`missingEndarea` for the open element;
   - calls `setCurrentParent(parent)` and `_returnToParentParser()` **without** adding a `THEndline`/`THEndarea`;
   - re-dispatches the same source line in the parent context.

   If it doesn't parse there either, today's error-and-drop behavior applies. At end of file, every line, area or scrap still open is closed implicitly the same way, with its `missing*` violation. That replaces the generic "Multiline commmands left open" error for these three element kinds (multiline comments keep that error).
4. **Ambiguity: nested scrap vs missing `endscrap`.** `scrap A … scrap B … endscrap` (EOF) is read as B nested in A, with A missing its `endscrap`. The standard fixes (lift B to file level, then close A) give a valid file, and the user can reorder afterwards. The alternative reading, "A closed just before B", would need guesswork and is not attempted.
5. Each accepted violation adds a **warning** (`parseWarnings`), not an error, so the load-error dialog stays for real syntax errors.
6. **Writer:** no change expected. A broken file round-trips as it was read. Missing `end*` lines stay missing until closed.

## 7. Implementation Phases

Each phase ends with `flutter analyze` clean, `flutter test` green, and a CHANGELOG entry.

### Phase 1: Lenient parser, violations and broken status

- Grammar and parser changes from §6.
- New `lib/src/auxiliary/th2_hierarchy_aux.dart` with `findViolations` and `validateMove`.
- `_structureRevision`, `@computed hierarchyViolations`/`isBroken`, `prepareCanvasForValidFile()` split out of `_finalFilePreparations`, `TH2BrokenFileBodyWidget` (violations list, Undo/Redo/Save, focus and shortcuts), and body switching in `th2_file_tabs_page.dart`. Save works for broken files.
- Tests:
  - `t39xx_th2_file_parser_hierarchy_violations_test.dart`. Cases:
    - PLA at file level;
    - multi-line `line…endline` and `area…endarea` at file level;
    - nested scrap with contents;
    - stray `endscrap`;
    - stray file-level `endscrap` followed by another top-level element (no parser exception, source line retained, warning recorded, and write-back preserved);
    - missing `endline` followed by `point`/`line`/`endscrap`;
    - missing `endarea`;
    - missing `endscrap` at EOF;
    - missing `endline` at EOF.

    Each case asserts the model shape, the violations and warnings, **no dropped source lines**, and a **byte-identical write-back**.
  - `t39xx_th2_hierarchy_aux_test.dart`: `findViolations` for every kind, and the `validateMove` matrix (every element type × every parent type, self-subtree, area-border rule, unclosed element).
  - `t39xx_th2_broken_file_body_widget_test.dart`: a broken file shows the panel and not the canvas, Save works, and switching to valid mounts the canvas with an active scrap.

### Phase 2: Model primitive and `MPMoveElementsCommand`

- `TH2File.moveElementToParent`, `THIsParentMixin.invalidateDrawableChildrenCache`, `MPMoveElementsCommand` with its registration, localization and factory, `prepareMoveElements`/`executeMoveElements`, close and remove-stray helpers (§5.3), and the convenience methods from §5.4.
- `MPGeneralController.disposeTablessTH2Controllers` and the call from project close and reload.
- Tests:
  - `t24xx_commands_mpmoveelementscommand_test.dart` (next to `t2460_commands_mpreorderimagescommand_test.dart`): reorder within a scrap, move between scraps, scrap reorder, an area moved within its scrap without moving border lines, an area moved across scraps together with its border lines, multi-element move, and undo/redo returning `childrenMPIDs` and `parentMPID` exactly. Also `toMap`/`fromMap` round-trip, thID registry unchanged, and a written file that differs only in line order.
  - Bring forward/backward/front/back: stepping over a sibling of another type, stepping over hidden comments, already first or last. A point brought forward past a multi-segment line must be written **after that line's `endline`**, and a point sent backward past an area must be written **before its `area` line**, never between an element's opening and `end*` lines.
  - Close element: the written file gains exactly one `endline`/`endarea`/`endscrap` line in the right place. Undo removes it. Broken-to-valid switching after the last fix, and back to broken on undo.

### Phase 3: Element tree in the sidebar (read-only)

- Sealed row model, flattener callback, `th2_element_tree_aux.dart` row builder, and `TH2ElementTreeRowWidget` (icon, label, violation marker, selection highlight).
- Chevron on `TH2FileNode`, lazy load on expand with loading and error rows, and the broken badge after loading (§4.2).
- Filter matching of loaded element labels, and the header order tooltip.
- Tree → canvas selection sync and canvas → tree highlight for valid files (§4.6).
- Tests:
  - update `t3881_th_project_tree_flatten_test.dart` and `t3883_th_project_tree_widget_test.dart`;
  - `t39xx_th2_element_tree_rows_test.dart`: hidden children are excluded, violators are included and flagged, nested scraps recurse, order is preserved;
  - `t39xx_th2_element_tree_widget_test.dart`: expanding loads without opening a tab, the badge appears only after load, a row tap selects on the canvas, the tree rebuilds after undo.

### Phase 4: Drag and drop, context menu, shortcuts

- `Draggable<List<int>>` on element rows (payload = the selected MPIDs of the same file) and a `DragTarget` on every row using the §4.3 zones, following `mp_available_scraps_widget.dart`.
- An insertion-line indicator, reject feedback with a localized reason, auto-expand of a collapsed scrap after hovering for `mpProjectTreeDragHoverExpandDelayMilliseconds` (new constant), and auto-scroll near the list edges.
- Cross-file drag payloads are rejected with a clear reason.
- Opening the tab on the first edit of a tab-less file (§4.2).
- Row context menu (§4.7) and canvas shortcuts for forward/backward/front/back on the current selection.
- Tests:
  - widget drag tests: valid reorder, valid move between scraps, same-scrap border-line reorder, and rejected drops (scrap into scrap, PLA onto the file row, border line alone across scraps, unclosed element). Each asserts the resulting `childrenMPIDs` or that no command was pushed;
  - menu actions;
  - shortcuts.

### Phase 5: Fix-hierarchy dialog

- The dialog from §4.8, reachable from the broken panel and the file row menu.
- Tests: the dialog turns every Phase 1 fixture into a valid file (`findViolations` empty), a single undo reverts it, and it works on a broken file opened without a project.

### Phase 6: Documentation and localization

- EN/PT `.arb` strings for every new label, reason, badge, violation, menu item, dialog, panel and tooltip, followed by `flutter gen-l10n`.
- Help pages (EN/PT):
  - a new section "Drawing order and element tree";
  - a new section "Broken files", covering which violations exist and how to fix them;
  - a mention in the project-sidebar section.
- Keyboard shortcuts page with the new shortcuts in alphabetical order.
- CHANGELOG entry that references #32.

## 8. Files Touched (expected)

| Area | Files |
|---|---|
| Model | `lib/src/elements/th2_file.dart`, `lib/src/elements/mixins/th_is_parent_mixin.dart` |
| Parser | `lib/src/mp_file_read_write/th2_grammar.dart`, `th2_file_parser.dart` |
| Commands | new `lib/src/commands/mp_move_elements_command.dart`, `mp_command.dart`, `factories/mp_command_factory.dart`, `types/mp_command_type.dart`, `types/mp_command_description_type.dart` |
| Controllers | `th2_file_edit_element_edit_controller.dart`, `th2_file_edit_controller.dart` (`_structureRevision`, `isBroken`, `prepareCanvasForValidFile`), `mp_general_controller.dart` (tab-less cleanup, open-on-edit helper), `th_project_controller.dart` (cleanup call) |
| Aux | new `lib/src/auxiliary/th2_hierarchy_aux.dart`, new `th2_element_tree_aux.dart`, `th_project_tree_flatten_aux.dart`, `mp_text_to_user.dart` |
| Widgets / pages | `th_project_tree_widget.dart`, `th_project_tree_node_widget.dart`, new `th2_element_tree_row_widget.dart`, new `th2_broken_file_body_widget.dart`, new Fix-hierarchy dialog widget, `th2_file_edit_body_widget.dart` / `th2_file_tabs_page.dart` (body switching), `mp_therion_run_dialog_widget.dart` (broken-file warning) |
| Constants | `mp_constants.dart` (drag hover delay, drop-zone fractions) |
| l10n / docs | `lib/l10n/intl_en.arb`, `intl_pt.arb`, help pages EN/PT, keyboard-shortcuts page, `CHANGELOG.md` |

## 9. Risks and Open Questions

1. **Implicit-close heuristics (§6.3-§6.4).** The re-dispatch rule is simple but decides where an unterminated element ends. The fixtures in Phase 1 pin the behavior down. Any ambiguous case is resolved toward keeping every source line in the model, never dropping one.
2. **Switching between broken and valid (§4.8).** Remounting the canvas mid-session must leave no stale state (selection, active scrap, state machine, overlay windows). Mitigation: one shared `prepareCanvasForValidFile()` and widget tests covering both directions.
3. **Code paths that assume a scrap parent.** These are avoided rather than fixed, because broken files never reach the canvas. Any new canvas feature must keep checking `isBroken` before mounting.
4. **Comments next to moved elements (§4.4).** Leaving comments in place can separate a comment from the element it describes. This is acceptable for v1.
5. **Performance on large files.** Rebuilding rows on every `_structureRevision` bump is O(visible rows) and only happens for expanded files. If needed, cache the row list per `(path, revision)`. `findViolations` is O(elements) and only runs on structural changes.
6. **Tab-less controllers.** These use memory for files that were only browsed. Mitigation: cleanup on project close. A possible later step is to dispose a clean, tab-less controller when its file row collapses.
7. **Undo location.** The undo for a tree edit lives on the file's own stack. Opening and activating the tab on the first edit (§4.2) keeps `Ctrl+Z` natural. Edits made while another file's tab is active switch tabs, which is intentional and visible.
