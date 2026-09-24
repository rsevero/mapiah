<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree in the Project Sidebar (Drawing Order and Hierarchy Editing): Implementation Plan

**Date:** 2026-09-23
**Status:** Proposed. Checked against the codebase on 2026-09-23 (`main` at `24c44fcc`, and again at `d8017b3c`). Revised the same day with these decisions: XTherion drawing order only; bring forward and send backward step over the next row of any type. Later the same day, the handling of files that break the hierarchy was **simplified to detect-and-warn**. Mapiah detects such a file, warns the user, and neither draws, edits, saves nor fixes it. The user fixes it outside Mapiah and reloads it. After that, **any parse error**, not only hierarchy violations, was made to mark the file broken too, so Mapiah never saves a file whose lines it failed to read. Unknown point, line and area **types** stay acceptable input, as they are today. Unknown **options** are parse errors, so they make a file broken (§6.2).
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Overview and Objectives

Issue #32 asks for two things XTherion already has: a way to **see** the relative stacking order of a drawing's objects, and a way to **change** it by moving objects up and down. In a `.th2` file the stacking order, as XTherion shows and edits it, is the file order. An object written later is drawn on top of an object written earlier.

This plan adds an expandable list of each `.th2` file's elements under that file's node in the project sidebar. It has these levels: file → scraps → points, lines and areas. The list can be reordered with drag and drop. The allowed moves follow Therion's structure rules, so an edit can never make a valid file invalid.

A file that already breaks those rules when it is read, or that has **any other parse error**, is **broken**. Mapiah detects it, shows the user what is wrong and where, and does nothing else with it: it is not drawn, not editable and not saveable. Because Mapiah never saves it, the lines its parser cannot place are never lost. The user fixes the file in a text editor outside Mapiah and reloads it.

### Key objectives

1. **See the order.** Every `TH2FileNode` of a valid file in the project tree can be expanded to show its scraps, and each scrap can be expanded to show its points, lines and areas, in file order (XTherion's order).
2. **Reorder within a parent.** Drag a scrap to a new position among the file's scraps. Drag a point, line or area to a new position inside its scrap. Bring forward, Send backward, Bring to front and Send to back do the same without dragging.
3. **Move between scraps.** Drag a point, line or area from one scrap into another scrap in the same file.
4. **Enforce the hierarchy.** Points, lines and areas must end up inside a scrap. A scrap must end up directly under the file, never inside another scrap. The UI must reject any drop that would break this, and must say so visibly.
5. **Detect broken files and warn.** A file that breaks the hierarchy when it is read is marked broken. Hierarchy violations are points, lines or areas outside a scrap, a scrap inside a scrap, a stray `endscrap`, and a line, area or scrap missing its own `endline`/`endarea`/`endscrap`. Any other parse error (a plain syntax error such as a misspelled command, a line point with one coordinate, an invalid option, a malformed `##XTHERION##`/`##MAPIAH##` setting, or an unclosed multiline comment) also makes the file broken. A broken file is **not drawn, not editable, not saveable and not fixed by Mapiah**. Its tab and its sidebar row say it is broken and list each problem with its line number. A **Reload** action reads the file again after the user fixed it elsewhere.
6. **Undoable, file-preserving edits.** Every structural change on a valid file is one `MPCommand` on the file's own undo stack. Saving keeps each moved element's original text (`originalLineInTH2File`), so only the order changes on disk.
7. **Canvas integration.** Clicking a tree row selects that element on the canvas and makes its scrap active. The canvas repaints right away in the new order.
8. **Complete integration.** EN/PT localization, help pages and keyboard shortcuts are updated. Controller, command, parser and widget tests are added. `flutter analyze` and `flutter test` stay green.

### Non-goals (this plan)

- **Fixing broken files in Mapiah.** There is no fix dialog, no "close element" action, no lifting of nested scraps and no editing of a broken file's elements, on the canvas or in the tree.
- **Showing a broken file's elements.** Its tree node shows the broken status, not its elements.
- **Therion's own rendering order.** It may layer by symbol class and by `-place bottom/default/top`. This plan only deals with XTherion's order, which is file order. `-place` stays editable through the existing option editor.
- Moving elements **between files**.
- Showing line segments, area border references, comments, xtherion settings or images as tree rows.
- A TH2 element tree when no project is open. The broken-file tab body (§4.7) still works for a broken file opened without a project.
- Pre-scanning a project's `.th2` files when the project loads, just to detect broken files. The broken badge only appears after a file is loaded (§4.2).
- Watching files on disk for external changes. Reloading a broken file is an explicit user action.
- Telling apart "harmless" and "harmful" parse errors. Every parse error makes the file broken (§4.7), including unknown options. Unknown point, line and area types are not parse errors (§6.2).
- Supporting unknown options (keeping them in the model and writing them back).

## 2. Grounding: Current State

### 2.1 Project sidebar (`lib/src/widgets/th_project_tree_widget.dart`, `th_project_tree_node_widget.dart`, `lib/src/auxiliary/th_project_tree_flatten_aux.dart`)

- The tree is built from `THProjectNode` objects (`lib/src/elements/th_project/th_project_node.dart`). The project parser creates them. Each node has a `children` list, a string `id`, a `label`, a `sourceFilePath` and a `lineNumber`.
- `TH2FileNode` (`th2_file_node.dart`) is a **leaf**. Its doc comment says that the `.th2` contents "are intentionally not parsed by `THProjectParser`; they are loaded lazily when a canvas tab is opened". A `THScrapNode` with `isFromTH2File` exists, but the widget comments that this flag is "always false today" (`th_project_tree_node_widget.dart:106-107`).
- `flattenVisibleNodes(...)` walks `THProjectNode.children` depth first. It takes an `isExpanded(node)` callback, which the widget answers with `THProjectTreeUIController.isExpanded(node.id)`, and honors the filter. It returns `THProjectTreeVisibleNode(node, depth)` rows, which a plain `ListView.builder` renders (`th_project_tree_widget.dart:68-87`).
- `THProjectTreeNodeWidget._buildExpandControl` shows a chevron only when `node.children.isNotEmpty` (`:153-175`). A `TH2FileNode` therefore has no chevron today.
- `THProjectTreeUIController` (`th_project_tree_ui_controller.dart`) holds an `ObservableSet<String> expandedNodeIds` and has `toggleExpanded`/`expand`/`collapse`/`expandAncestorsOf` actions. It is keyed by string id. TH2 file rows keep using it through their `TH2FileNode` id. Scrap rows do not use it; their collapsed state lives in a separate `collapsedTH2ScrapIds` set (§4, Phase 3 plan §6.1).
- Tapping a `TH2FileNode` calls `getTH2FileEditController(filename:)` and `addFileTab(...)` (`th_project_tree_node_widget.dart:81-86`).

### 2.2 TH2 data model

- `TH2File` (`lib/src/elements/th2_file.dart`) mixes in `THIsParentMixin`. Its `childrenMPIDs` holds the ordered top-level children, and `_elementByMPID` holds every element. It also keeps derived caches such as `_scrapMPIDs`, `_imageMPIDs`, `_pointsMPIDs`/`_linesMPIDs`/`_areasMPIDs` and the area↔line maps. These are updated in `_updateSupportMaps` (`:390-422`) and `removeElement` (`:458-523`).
- `THIsParentMixin` (`lib/src/elements/mixins/th_is_parent_mixin.dart`) owns `childrenMPIDs` and a cached `_drawableChildrenMPIDs` (lines, points and scraps, in child order). `drawableChildElementTypes` is `{line, point, scrap}` only: **areas are not drawable children** (`:18-22`). `addElementToParent(element, elementPositionInParent:)` supports an explicit index or `mpAddChildAtEndMinusOneOfParentChildrenList`, which inserts just before the closing `endscrap`/`endline`/`endarea`. `removeElementFromParent` also **unregisters the element's thID** (`:100-118`).
- `THElement.parentMPID` is **`final`** (`th_element.dart:97`). A negative `parentMPID` means "the file" (`parent()`, `:131-136`). Changing an element's parent therefore means creating a `copyWith(parentMPID: …)` and replacing the element with `TH2File.substituteElement(...)` (`th2_file.dart:323-374`).
- `TH2File.removeElement` removes **all descendants recursively** (`:458-467`). A plain "remove, then add" would delete a line's segments or an area's border references. A move needs its own primitive.
- **Existing reorder precedent.** `TH2File.reorderScrapMPIDs({oldIndex, newIndex})` (`:846-892`) reorders scraps inside `childrenMPIDs` and leaves non-scrap children in their slots. `MPReorderScrapsCommand` (`lib/src/commands/mp_reorder_scraps_command.dart`) wraps it through `TH2FileEditElementEditController.reorderScraps`/`executeReorderScraps` (`th2_file_edit_element_edit_controller.dart:1329-1341`). The scraps dialog (`mp_available_scraps_widget.dart`) drives it with `Draggable<int>`/`DragTarget<int>` rows. `MPReorderImagesCommand` and `mp_available_images_widget.dart` follow the same pattern. This plan reuses that command, factory, description and localization pattern. It also reuses the `Draggable`/`DragTarget` pattern (the code does not use `ReorderableListView`).

### 2.3 Parser: hierarchy violations are currently dropped (data loss)

- `TH2Grammar` (`lib/src/mp_file_read_write/th2_grammar.dart:33-55`) chooses the grammar by context:
  - file level `th2Structure()`: `xtherionConfig | mapiahConfig | th2Command | fullLineComment`, where `th2Command()` is `multiLineComment | scrap`;
  - scrap level `scrapContent()`: `point | line | area | endscrap`;
  - line level `lineContent()`: segments, line options, `endline`;
  - area level `areaContent()`: `endarea`, area options, border references.
- `TH2FileParser._injectContents` (`th2_file_parser.dart:144-262`) switches `_currentParser` as scraps, lines and areas open and close. When a line does not match the current context's grammar, the result is a `Failure`. The parser then records an error with `_addError(...)` and runs `continue`. **The line never enters the model.**
- Results for each violation:
  - **Point, line or area at file level:** the `point`/`line`/`area` line fails and is dropped. For a multi-line `line … endline` every following line also fails, because the line parser was never pushed. Everything is lost.
  - **Scrap inside a scrap:** the inner `scrap` line is dropped. Its contents are silently added to the **outer** scrap. The inner `endscrap` closes the outer scrap, and the outer `endscrap` then fails at file level and is dropped. Saving writes one merged scrap.
  - **Missing `endline`/`endarea`:** the line or area parser stays active. Every following `point`, `line`, `area` or `endscrap` fails that context's grammar and is dropped, until an `endline`/`endarea` happens to appear. If none does, everything to the end of the file is lost. At the end of the file only "Multiline commmands left open at end of file" is reported (`th2_file_parser.dart:~2712-2719`).
  - **Exception in the area context:** `borderLineReference()` is `reference().end()` (`th2_grammar.dart:906-909`), so any single-word line, such as `endscrap` or a stray `endline`, *parses successfully* as a border thID reference. For example, `area … endscrap` with no `endarea` produces a `THAreaBorderTHID("endscrap")` and leaves the scrap open, with no error at that line.
  - **Missing `endscrap`:** the scrap stays open. A following `scrap` is dropped (as in the nested case), and the end-of-file "left open" error is reported.
- **Unknown types and options, checked by parsing small sample files on `d8017b3c`:**
  - Unknown point, line and area **types** (`point 1 2 foobarpoint`, `line foobarline`, `area foobararea`), unknown **subtypes** (`station:weirdsub`, `wall:weirdsub`) and user types (`u:myuser`) already parse with no error and round-trip byte for byte.
  - Unknown **options** do not. `THHasOptionsMixin` stores options in a `SplayTreeMap<THCommandOptionType, THCommandOption>` (`th_has_options_mixin.dart:6-7`), so it can hold only one option per type. `THUnrecognizedCommandOption` exists (`th_unrecognized_command_option.dart`) but has only a `value`, no name, and is never created: its factory case is commented out (`th_command_option.dart:415-416`) and `_injectUnrecognizedCommandOption` throws (`th2_file_parser.dart:2446-2452`). Results:
    - an unknown option on a `point` line (`-weirdpointopt abc`, or a flag such as `-weirdflag`) fails the whole line, which is dropped;
    - an unknown option on a `line` or `area` line fails the opening line, so the whole block cascades into errors and is dropped;
    - an unknown option on a `scrap` line fails the scrap line, and **every line up to the end of the file** is dropped;
    - an unknown line-point option line inside a line (`weirdsegopt xyz`) is reported and dropped;
    - an unknown option line inside an area (`weirdareaopt 5`) is **dropped silently, with no error**, and `isSuccessful` stays `true`. Its cause is not traced yet; Phase 1 must find it (§6.2).
- `TH2FileEditController._postParseInitialize` (`th2_file_edit_controller.dart:729-740`) copies the errors into `errorMessages`. `TH2FileEditBodyWidget` (`th2_file_edit_body_widget.dart:80-87`) then shows them with `_handleSoftLoadFailure` (a "parsing warnings" dialog), and **mounts the canvas anyway**. The file can be edited and saved. **Saving it makes the loss permanent.** This is what the broken status stops. It happens for plain syntax errors too. For example, a file with `  poin 150 250 station -name 2` (a typo for `point`) inside a scrap, and a line point `    150` with one coordinate inside a `line … endline`, reports two `petitparser returned a "Failure"` errors, both saying `"comment" expected` and neither giving a line number. It opens on the canvas, and saving it writes the file **without both lines**.

### 2.4 Canvas paint order

- `MPNonSelectedElementsWidget.addChildrenPainters` (`lib/src/widgets/mp_non_selected_elements_widget.dart:71-140`) and `mp_non_selected_scraps_widget.dart:71` iterate `parent.getDrawableChildrenMPIDs()` in child order. Mapiah therefore already paints in file order, matching XTherion. Reordering `childrenMPIDs` and clearing `_drawableChildrenMPIDs` is enough to change the stacking on screen.
- **Areas are not painted as filled shapes.** `THArea` is not a drawable child (§2.2), and only its border lines are drawn, as lines. Reordering an area therefore changes the file order (and what XTherion and Therion see) but has **no visible effect on Mapiah's canvas**. Moving an area's border lines does.
- Selected elements are painted by a separate widget, on top of everything. The tree shows file order, not the temporary "selected on top" order.

### 2.5 Writer

- `TH2FileWriter` (`lib/src/mp_file_read_write/th2_file_writer.dart:113-117, 419-428`) serializes by walking `childrenMPIDs` recursively. It writes `originalLineInTH2File` for unmodified elements. A moved element keeps its original text and is simply written in its new position. Broken files are never saved (§4.7), so the writer only ever sees valid structures, where every `end*` element closes an open block. **No writer change is needed.**

### 2.6 Controller lifecycle and dirty tracking

- `MPGeneralController.getTH2FileEditController(filename:)` creates and registers a controller whether or not a tab exists (`mp_general_controller.dart:337-361`). `forceNewController: true` replaces the registered controller. `controller.load()` parses it once and caches the future (`th2_file_edit_controller.dart:699-727`). `_finalFilePreparations` (`:742-775`) sets the active scrap and snap targets, registers the controller's reactions (`_initializeReactions()`, including the dirty mirroring below), and initializes selection, once, after the parse.
- A reaction in `TH2FileEditController` (`:~945-955`) mirrors the controller's dirty state into `THProjectController.dirtyFilePaths`. `_saveTH2ProjectFile` saves through `getTH2FileEditControllerIfExists(path)` (`th_project_controller.dart:1535-…`). A controller with no tab is therefore already counted by the dirty dot, by Save All and by the unsaved-changes guard.
- `closeProjectFileTabs(...)` only removes controllers that have an **open tab** (`mp_general_controller.dart:296-…`). A controller loaded only for the tree would leak across project open, close or reload unless cleanup is added (Phase 2).
- `TH2FileEditController` has **no `dispose()`**. `_initializeReactions()` fills `_disposers` with MobX reactions (including the dirty mirroring above), but nothing ever runs them: `removeFileController` (`mp_general_controller.dart:469-477`) and `reloadTH2File` only drop the map entry. Phase 2 adds `dispose()` and calls it from every path that drops a TH2 controller.
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

A file read with any of these rules broken is a broken file (§4.7). Tree edits on a valid file are validated so they can never break them (§4.3).

Extra rule for **areas** when moving: an area's border lines must stay in the same scrap as the area.

- Moving an **area** to another scrap also moves every referenced border line that is a child of the area's current scrap. These lines keep their relative order and go just before the area; the area and its border lines move in one command. If a referenced border line is already in another scrap, the file is structurally inconsistent for this operation and the move is rejected rather than moving or splitting that reference.
- A line can border **more than one area**. Moving area A to another scrap is rejected if any of its border lines also borders an area that is not part of the same move ("Line X is also a border of area Y"). Selecting both areas makes the move valid. `TH2File._areaMPIDByLineMPID` keeps only one area per line, so this check must scan every area's border references instead of using that map.
- Moving an **area** within the same scrap moves only the area; its border lines stay where they are.
- Moving a **line** that borders an area by itself to another scrap is rejected. The drop indicator explains why ("Line is a border of area X; move the area instead"). Moving that line within its current scrap is allowed.

A border line that is *already* in another scrap when the file is read does **not** make the file broken. Mapiah opens such files today, and this is a Therion rule about references, not a structural error that makes the parser lose lines. The move rules above simply do not make it worse.

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
  …
}
final class TH2FileStatusTreeRow extends THProjectTreeVisibleRow {
  final String th2FilePath;   // canonical path, equals TH2FileNode.absolutePath
  final TH2FileStatusTreeRowKind kind; // loading, loadError, broken
  …
}
```

- `flattenVisibleNodes(...)` gains an optional `th2ElementRowsFor(TH2FileNode node, int depth, {required bool filterActive})` callback that returns `({List<THProjectTreeVisibleRow> rows, bool hasMatch})`. With no filter active, when the callback exists and the `TH2FileNode` is expanded, the flattener adds the returned rows right after that file row. With a filter active, the rows are only the matching ones and their scrap ancestors, and `hasMatch` counts as a matching descendant of the file node (Phase 3 plan §7). `THProjectTreeVisibleNode` is renamed or wrapped as `THProjectTreeNodeRow`. Existing tests in `t3881_th_project_tree_flatten_test.dart` are updated.
- Element row ids are `th2el:<canonicalPath>:<mpID>` and status row ids are `th2status:<canonicalPath>:<kind>`. `canonicalPath` is `THProjectPathResolver.canonicalize(p.absolute(path))`, which for project files equals `TH2FileNode.absolutePath` (Phase 3 plan §3.1 item 5).
- Scrap rows can be collapsed and start expanded. Their collapsed state is kept in a separate `THProjectTreeUIController.collapsedTH2ScrapIds` set, keyed by scrap row id, not in `expandedNodeIds`, so project default-expansion seeding never sees TH2 ids. MPIDs only exist while the app runs and are never reused, so a stale id after reloading a file is harmless. Both sets are cleared on project close (Phase 3 plan §6.1).
- The builder lives in a new `lib/src/auxiliary/th2_element_tree_aux.dart`. For a valid file it walks `TH2File.childrenMPIDs` and each scrap's `childrenMPIDs`, and keeps only `THScrap`, `THPoint`, `THLine` and `THArea` rows. For a broken file it returns one `TH2FileStatusTreeRow(broken)` (§4.2). It runs inside the tree's `Observer`, so structural changes must be observable (§5.4).
- **Labels:** `<kind> <type[:subtype]?> <thID?>`. Kind and type/subtype come from the existing localized `MPTextToUser` helpers. The Therion id is shown exactly as stored, in a muted span with no `id=` prefix or brackets, for example `line wall:blocks w12` (`w12` muted), `point station` or `scrap s1`. Therion ids are free form, so the tree never validates, changes or generates them; elements without `-id` show no id. Scraps always have an id. Phase 3 labels leave out station `-name` values and other option values. Phase 5 adds the station `-name` and the `-text` of `label`/`remark` points as an extra detail part. Rows use the existing PLA type icons where they exist; Phase 7 replaces them on point, line and area rows with previews of how each type is drawn. Details: Phase 3 plan §6.2.
- **Filter:** the sidebar search filter also matches element and scrap labels of **loaded, valid** files. It follows the existing project-tree rule: a row is shown only if it or a descendant matches, so a file or scrap that matches by its own name does not reveal its non-matching children. Status rows are hidden while filtering, and no file is loaded while a filter is active. Details: Phase 3 plan §7.

### 4.2 Loading a file's elements, and the broken badge

- `TH2FileNode` rows always show a chevron. Any visible `TH2FileNode` row in the user's expansion set whose controller is missing, or neither loaded nor loading, gets a load through an idempotent `ensureTH2FileLoaded(path)` (`getTH2FileEditController(filename:)` + `load()`), run after the frame, but only while no filter is active and only if an earlier load did not fail (`loadError`). This covers a first expansion and also a row that was still expanded when its controller was disposed, for example across a project reload. While loading, one "Loading…" status row is shown. Details: Phase 3 plan §5.
- **The broken badge appears only once the file is loaded.** Loading happens when the file is expanded in the tree or opened in a tab. No project-wide pre-scan is done. After loading, a broken file's row shows a "broken" badge with the problem count and a tooltip listing the first problems. Expanding it shows a single status row, "Broken file: fix it outside Mapiah and reload". Clicking that row opens the file's tab, which shows the broken-file body (§4.7).
- Loading does **not** open a tab. Only reading the list never creates dirty state.
- **Editing from the tree opens the tab.** The first structural edit made from the tree on a file with no open tab calls `addFileTab(path)` and activates it. The command then runs. This keeps the rule "a modified TH2 file has a visible tab", so undo (`Ctrl+Z`), Save and the close-tab prompt work as they do today. Broken files have no edit actions, so this never applies to them.
- **Cleanup:** `MPGeneralController` gets `disposeTablessTH2Controllers(Iterable<String> canonicalPaths)`. `THProjectController._beginProjectLifecycleTransition()` calls it right after `closeProjectFileTabs`, so every lifecycle transition (open, reload and close) runs it. At that point the unsaved-changes guard has already run and every tabbed project controller is already gone, so it disposes **every** remaining project-owned controller, dirty or not. Keeping a dirty one would bring back edits the user chose to discard the next time the project opens.

### 4.3 Drop semantics (valid files only)

Every drop becomes one request: **move element E to parent P, just before sibling S (or at the end of P)**. The drop zone decides it:

| Hover zone on target row T | Resulting request |
|---|---|
| upper third of T | before T, under T's parent |
| lower third of T (T collapsed, or not a scrap) | after T, under T's parent |
| middle of a **scrap** row | at the **end** of that scrap |
| lower third of an **expanded** scrap row | at the **start** of that scrap |
| middle of the **file** row | at the end of the file |

Validation happens in one pure function, `TH2HierarchyAux.validateMove(th2File, elementMPIDs, newParentMPID, beforeSiblingMPID) → MPHierarchyMoveCheck` (`ok` / `rejected(reasonKey)`). It is used both while hovering, for the indicator, and in the command, as a guard. Because the file starts valid and every move lands in a valid position, the file stays valid:

- `scrap` → parent must be the file (`newParentMPID < 0`).
- `point`/`line`/`area` → parent must be a `THScrap`.
- An element cannot be dropped onto itself or into its own subtree.
- A standalone dropped line that borders an area is rejected when the drop changes its scrap (§3.1). The same line may be reordered within its current scrap.
- An area moved to another scrap is rejected when one of its border lines also borders an area that is not moving with it (§3.1).
- `beforeSiblingMPID`, when given, must be a child of the target parent and not one of the moving elements. The scrap's `THEndscrap` is accepted and means "end of scrap".
- Moving to the same position is a no-op and creates no command.

Feedback: a valid drop shows the usual insertion line (as in `mp_available_scraps_widget.dart`). An invalid drop shows a "not allowed" cursor and a tooltip with the localized reason. Invalid drops never create a command.

### 4.4 Non-tree children (comments, empty lines, settings)

Hidden children stay where they are. The move primitive resolves "before sibling S" to S's index in the **full** `childrenMPIDs`. "End of scrap" is resolved to the index of the scrap's `THEndscrap`, just before it. A comment line written right above a line in the file therefore stays at its slot when the line moves. That is the safe choice, since the code has no way to know which element a comment "belongs" to. Possible later option: "full-line comments directly above an element move with it."

### 4.5 Multi-selection

Rows support `Ctrl`/`Shift` multi-select, which mirrors the canvas selection (§4.6). Dragging a multi-selection moves all selected rows to the drop point in their current relative order, as **one** command. When the selection comes from several scraps, "current relative order" is file order: scraps in file order, then children in each scrap's order. The drop is rejected if any item fails validation.

### 4.6 Tree ↔ canvas selection sync

- Single-clicking an element row of an **open** file activates its tab, sets the active scrap (`setActiveScrap` / `setActiveScrapByChildElement`, `th2_file_edit_controller.dart:1018-1053`), and selects the element through the selection controller. Double-click also zooms to the selection (`zoomToFit(zoomFitToType: MPZoomToFitType.selection)`).
- The canvas selection is reflected back as row highlighting when the file is expanded. This is read-only and comes from `selectionController`.
- The highlight of an element row is always its file's own `selectionController` selection, tab-less or not; the tree keeps no separate highlight state.
- Single-click on a row of a **tab-less** file sets that file controller's selection and active scrap, which highlights the row, but opens no tab. Double-click also opens and activates the tab and zooms to the selection. A pending zoom request is applied on the new canvas's first layout, in place of the default zoom-to-file. Details: Phase 3 plan §8.

### 4.7 Broken-file status

**Definition.** A loaded file is *broken* when the parser recorded at least one problem: a hierarchy violation or any other parse error. The problem kinds, each with the 1-based line number in the file where it was detected:

| Violation | Detected when |
|---|---|
| `plaOutsideScrap` | a `point`/`line`/`area` line appears at file level |
| `scrapInsideScrap` | a `scrap` line appears while a scrap is open |
| `strayEndscrap` | an `endscrap` line appears at file level |
| `missingEndline` | a line is still open when a line that belongs to an enclosing context, or the end of the file, is reached |
| `missingEndarea` | the same, for an area |
| `missingEndscrap` | the same, for a scrap (at end of file) |
| `invalidBorderReference` | an area border reference names no line of the file, or names something that is not a line, after `name@survey` references and repaired line ids are resolved |
| `parseError` | anything else the parser reports today through `_addError(...)` (`th2_file_parser.dart:2454-2459`): a line that fails every applicable grammar, an option that cannot be created, a line-segment option without a segment, an `endline` without a line, a malformed `##XTHERION##`/`##MAPIAH##` setting, or a multiline comment still open at the end of the file |

Every `_addError(...)` call site counts, with no allow-list. If one of them later turns out to be too strict for real files, the fix is to make the parser accept that input properly, not to let the file open with a line missing.

"Broken" is decided **once, at load**, and stored on the controller as `bool isBroken` plus `List<TH2FileProblem> problems`. It cannot change afterwards: a broken file has no edit actions, and tree edits on a valid file are validated (§4.3). Only a reload can change it.

**Behavior while broken:**

- **Not drawn.** In `TH2FileEditBodyWidget`, when the load result is broken, the `FutureBuilder` shows a new `TH2BrokenFileBodyWidget` instead of `_buildEditor(...)`, and hides the last-used PLA buttons and the bottom status bar. The panel shows:
  - an explanation: the file has structural errors, Mapiah will not display or change it, and it must be fixed in a text editor;
  - the problems list, each with its line number, the source line and a short explanation (for example "Line 42: point outside any scrap" or "Line 4: unrecognized command"), plus the expandable "Details" section;
  - the file path, with a **Copy path** button;
  - a **Reload** button.
- **Not editable, not saveable.** The canvas, its state machine and its keyboard shortcuts are never mounted for the file. The controller is never dirty, so Save and Save All skip it and closing its tab never prompts. Save As is disabled for it.
- **No load dialog.** Problems are **not** shown in today's "parsing warnings" dialog. The broken panel replaces it. Since any parse error now makes the file broken, a loaded `.th2` file is either valid with no errors or broken, so `TH2FileEditBodyWidget._handleSoftLoadFailure` (`th2_file_edit_body_widget.dart:187-210`) has no remaining caller and is removed, together with the `parsingWarnings` string if nothing else uses it. A load that **throws** (`snapshot.hasError`) keeps today's `_handleLoadFailure` dialog.
- **Readable messages.** Today's error strings are internal (`'petitparser returned a "Failure"' at '_injectContents()' …`) and have no line number. Each problem becomes a `TH2FileProblem(kind, lineNumber, sourceLine, detail)`. The panel shows the line number, the source line as written, and a localized one-line explanation per kind. The internal text goes in an expandable "Details" section, for bug reports.
- **No canvas setup.** `_postParseInitialize` still runs `_initializeReactions()`, `setFilename(...)` and clears `_isLoading` for a broken file. It skips the canvas-only part of `_finalFilePreparations` (active scrap, snap targets, selectable elements, used types). The split keeps `createFromNewTH2File` (`th2_file_edit_controller.dart:630-638`) working unchanged, since a new file is always valid.
- **Tree.** Badge and status row only (§4.2). No element rows, no context-menu actions except **Reload**.
- **Run Therion.** The run dialog lists open broken files as a warning before running. Therion would fail on them anyway.

**Why the canvas must not see a broken file.** Several canvas paths assume that a PLA's parent is a scrap: active scrap, selection, snapping and the non-selected-elements painter. `addElementToParent`'s default insertion assumes the closing `end*` exists (§2.2). The parser has also dropped or misplaced lines while reading it (§2.3), so any save would lose data. Keeping broken files out of the editor entirely avoids both problems.

**Reload.** `MPGeneralController.reloadTH2File(canonicalPath)` replaces the controller with `getTH2FileEditController(filename:, forceNewController: true)`, disposes the old one (with the `dispose()` added in Phase 2; Phase 1 only removes it from the registry), and calls `load()`. An open tab rebinds to the new controller and shows either the canvas or the broken panel again. The sidebar row updates its badge. Reload is only offered for broken files, which are never dirty, so no changes can be lost. Reloading a *valid* file is out of scope.

### 4.8 Keyboard and context-menu actions (non-drag equivalents, valid files only)

Every row with a PLA or scrap element has a context menu:

- **Bring forward / Send backward** swaps the element with the **next or previous visible sibling row in the same parent, whatever its type**. For example, a point steps over the adjacent line. A sibling is always stepped over **as a whole**. Bringing a point forward past a line moves it past the entire `line … endline` block, including all its segments, options and the `endline`. An area is passed as its whole `area … endarea` block in the same way. The model gives this for free, because segments, options, border references and the `end*` element are children of the `THLine`/`THArea`, not siblings. The move only reorders the scrap's own `childrenMPIDs`, so the point can never land inside another element's block. The element being moved also carries its own block with it (§5.1). Hidden children (comments, empty lines) are stepped over. **Bring to front / Send to back** moves the element to the end or start of its parent. Scraps use the same actions among scraps. These are the literal requests from issue #32. They also get canvas keyboard shortcuts working on the current selection. The key bindings are chosen in Phase 4, after checking for conflicts in the keyboard shortcuts page. The candidates are `Ctrl+]`/`Ctrl+[` and `Ctrl+Shift+]`/`Ctrl+Shift+[`.
- **Move to scrap… ▸ <scrap list>** for PLAs.

## 5. Model and Command Layer

### 5.1 `TH2File` primitive

Add to `TH2File`:

```dart
/// Moves [elementMPID] (with its whole subtree) to [newParentMPID], inserting
/// it at [positionInNewParent] in the parent's full childrenMPIDs. Does not
/// validate hierarchy.
void moveElementToParent({
  required int elementMPID,
  required int newParentMPID,
  required int positionInNewParent,
});
```

Implementation:

1. `oldParent.childrenMPIDs.remove(mpID)` directly. It does **not** call `removeElementFromParent`, because that unregisters the thID (§2.2).
2. Only when the parent changes: `newElement = element.copyWith(parentMPID: newParentMPID)`, then `substituteElement(newElement)`. Checked: `THScrap`, `THPoint`, `THLine` and `THArea` `copyWith` accept `parentMPID`, and parent types copy `childrenMPIDs` into the new instance, so the subtree survives the substitution. A reorder within the same parent keeps the existing instance.
3. Insert into `newParent.childrenMPIDs` at the given index. **The index refers to the list after step 1**: for a move within the same parent, the element has already been removed. `moveElementToParent` inserts by itself, not through `addElementToParent`, so callers always pass a concrete index: for "end of scrap", the index of the scrap's `THEndscrap`; for "end of file", `childrenMPIDs.length`.
4. Invalidate caches: both parents' `_drawableChildrenMPIDs` (add a public `invalidateDrawableChildrenCache()` on `THIsParentMixin`), the affected `THScrap` per-type caches (`_areasMPIDs`, `_linesMPIDs`, `_pointsMPIDs`), `_scrapMPIDs` when a scrap moves at file level, and the bounding boxes of both old and new parents (`clearBoundingBox()`). The file-level type sets and `_imageMPIDs` retain the same membership and relative filtered order for these supported moves; document that they do not need clearing. `_areaMPIDByLineMPID`/`_areaMPIDByLineTHID` and each area's line caches are keyed by MPID/thID for the whole file, not by scrap, so a move does not make them stale and they do not need clearing.

The children's `parentMPID` points at the element's unchanged MPID, so the subtree does not need rewriting.

`TH2File.moveElementToParent` is the raw model primitive. `executeMoveElements` wraps it at controller level. It does what `TH2FileEditElementEditController.substituteElement` (`:505-533`) does after a substitution: `addUpdateSelectableElement`, `updateSelectedElementLogicalClone` and the station-cache invalidation. When an element changes scrap, it also calls `selectionController.resetSelectableElements()`, because selectable elements depend on the active scrap. A selected element that leaves the active scrap is deselected, since selection only works inside the active scrap. A selected element that stays in the active scrap stays selected, with its logical clone refreshed.

### 5.2 `MPMoveElementsCommand`

New file `lib/src/commands/mp_move_elements_command.dart` (a `part of 'mp_command.dart'`, like the rest):

- Fields: `List<MPElementMove> moves` (`elementMPID`, `newParentMPID`, `positionInNewParent`), resolved at prepare time into concrete indices, applied in order.
- **Indices are resolved sequentially.** Each move's source index and target index are computed against the state left by the **previous moves in the same command**, not against the state before the command. The resolver simulates the moves on a copy of the affected `childrenMPIDs` lists. Example: a scrap has `[a, b, c, E]`, and `[a, b]` is moved to another scrap. If the source indices were recorded up front (`a@0`, `b@1`), undoing in reverse would give `[a, c, b, E]`. Recorded sequentially (`a@0`, then `b@0`), undo restores `[a, b, c, E]`. The same applies to target indices when several elements land in one parent, or leave and re-enter the same parent.
- `_prepareUndoRedoInfo` records each element's `(parentMPID, index)` as it was just before *its own* move. Undo applies the inverse moves in **reverse** order. This follows `MPRemoveElementCommand._prepareUndoRedoInfo`'s pattern.
- Undo follows the map-based `MPUndoRedoCommand(mapRedo:, mapUndo:)` pattern: `mapUndo` is the `toMap()` of another `MPMoveElementsCommand` whose moves are the recorded inverse moves in reverse order, built in `_createUndoRedoCommand` from the data recorded in `_prepareUndoRedoInfo`. Undoing a move is therefore itself a move command.
- `_actualExecute` → `elementEditController.executeMoveElements(moves)` (`@action`). It calls `TH2File.moveElementToParent` for each move, bumps `_structureRevision`, and redraws the canvas.
- `toMap`/`fromMap`/`copyWith`/`==`/`hashCode` follow `MPReorderScrapsCommand`.
- Register `MPCommandType.moveElements`, the factory `MPCommandFactory.moveElements(...)` and the `mp_command.dart` `fromMap` switch. Reuse the existing `MPCommandDescriptionType.moveElements`, which is already localized in `MPTextToUser` and the `.arb` files ("Move elements"); no new strings are needed for the command description.
- Scrap-only reorders from the new tree also use `MPMoveElementsCommand`. `MPReorderScrapsCommand` stays, because the scraps dialog uses it and it appears in saved undo maps.
- Area moves between scraps expand into the area plus all of its referenced border lines inside the same command (§3.1), in the prepare step. Area moves within one scrap include only the area.

### 5.3 Controller API

In `TH2FileEditElementEditController`:

- `MPHierarchyMoveCheck checkMoveElements({required List<int> elementMPIDs, required int newParentMPID, int? beforeSiblingMPID})`, a pure wrapper over `TH2HierarchyAux.validateMove`.
- `void moveElements({required List<int> elementMPIDs, required int newParentMPID, int? beforeSiblingMPID})` checks, resolves positions, builds the command and runs `_th2FileEditController.execute(...)`.
- Convenience methods used by the context menu and shortcuts:
  - `bringForward`, `sendBackward`, `bringToFront` and `sendToBack` (operating on `List<int>`, stepping over one visible sibling row of any type, §4.8);
  - `moveElementsToScrap(List<int>, int scrapMPID)`.

All of them assert that the file is not broken.

### 5.4 Observability

The tree must update after a move, undo or redo. `TH2File` is not a MobX store. Add a `@readonly int _structureRevision` to `TH2FileEditController`. It is bumped by `executeMoveElements`, `executeAddElement`, `executeRemoveElement…`, `executeReorderScraps` and element substitutions that change a label (type or thID edits, including `executeSetOptionToElement` and `executeRemoveOptionFromElement` for the `id` option). `executeAddElement` and `executeRemoveElement…` bump it only for elements the tree shows (scraps, points, lines and areas). `executeAddLineSegment` goes through `executeAddElement`, and bumping for every segment would rebuild the tree while a line is being drawn. Undo and redo also go through these `execute*` methods, so they update the tree too. The tree's `Observer` reads it.

`TH2FileParser` adds **every parsed line** through `executeAddElement` (for example `_injectScrap` and `_injectEndScrap`). The bump must be skipped while `_isLoading` is true, with a single bump in `_postParseInitialize`. Otherwise a large file triggers one MobX notification per line during load.

`isBroken` and `problems` are set once in `_postParseInitialize`, before `_isFileLoaded` becomes true, so the tree and the tab body never see a loaded file with an unknown status. `_isFileLoaded` must be observable for the tree's badge. It is a plain field today (`th2_file_edit_controller.dart:116`), so it becomes `@readonly`.

## 6. Parser Changes

### 6.1 Detecting hierarchy violations

The parser only has to **detect and locate** violations, not build a usable model of a broken file: that model is never drawn, edited or saved. The requirements are:

- report every violation of §4.7 with the right line number;
- never throw, whatever the input;
- stay in sync with the file's real structure after a violation, so later violations are reported at the right lines instead of as a cascade of unrelated errors.

Changes in `th2_grammar.dart` and `th2_file_parser.dart`:

1. **Classify a failing line against the enclosing contexts.** When a line fails the current context's grammar, the parser tries it against the contexts on the parser stack, innermost first, and then the scrap-content grammar at file level:
   - In a **line or area** context, if the line parses in the enclosing scrap or file context, the open line or area is closed implicitly: record `missingEndline`/`missingEndarea` at the line that closed it, pop the parent and parser **without** adding a `THEndline`/`THEndarea`, and re-dispatch the same line in the enclosing context.
   - At **file level**, a line that parses as `point`/`line`/`area` records `plaOutsideScrap`. A `line`/`area` pushes its content parser so its body is consumed without further errors. It is injected with the file as parent. The model is discarded anyway, so this only keeps the parser state right.
   - At **file level**, an `endscrap` records `strayEndscrap` and is skipped. `_injectEndScrap` is not called, so there is no parent cast and no parser-stack underflow.
   - In a **scrap** context, a `scrap` line records `scrapInsideScrap` and opens the nested scrap as usual (`_injectScrap` already pushes the scrap parser), so the inner `endscrap` closes the inner scrap, not the outer one.
   - Anything else records a `parseError` at that line and drops the line, as today. Dropping is harmless now, because the model of a broken file is discarded.
2. **Area-context keyword guard.** In the area context, `borderLineReference()` accepts any single word (§2.3), so a structural keyword would never fail there. Before dispatching a line in the area context, the parser checks whether the line is exactly `endscrap`, `endline` or a `scrap …` line that parses in the enclosing context. If so, it treats the line as closing the area implicitly, as in step 1, instead of creating a `THAreaBorderTHID` named after the keyword. The grammar could reject these keywords in `borderLineReference()` instead, but that would change how valid files that happen to use such a thID are parsed. The pre-dispatch check leaves them alone.
3. **End of file.** Every line, area or scrap still open records its `missing*` violation at the line where it was opened. That replaces the generic "Multiline commmands left open" error for these three element kinds (multiline comments keep that error).
4. **Ambiguity: nested scrap vs missing `endscrap`.** `scrap A … scrap B … endscrap` (EOF) is reported as B nested in A (`scrapInsideScrap`) and A missing its `endscrap`. Both messages point at the lines the user has to look at, which is all a detect-only parser needs.
5. **Line numbers for every problem.** `_injectContents` already iterates `_splittedContents`. The parser keeps the current 1-based line number (counting the lines of multi-line constructs as they are read), and `_addError(...)` records it with the source line. The end-of-file checks use the number of the line that opened the unclosed element.
6. **Result.** `TH2FileParser.parse` returns the problems in a new `problems` list (`List<TH2FileProblem>`) next to today's `errors` strings, which stay for existing callers and tests. `TH2FileEditControllerCreateResult` gains `isBroken` and `problems`. `isBroken` is `problems.isNotEmpty`, and a file is broken exactly when today's `isSuccessful` would be `false` or a hierarchy violation was found.
7. **No silent drops.** Every non-empty source line must end up either in the model or as a problem. The `weirdareaopt 5` case in §2.3 shows that today this is not always true. A parser-level invariant test checks it for every fixture (§7, Phase 1).

### 6.2 Unknown types are accepted, unknown options are not

1. **Unknown point, line and area types and subtypes** (including `u:` user types) already parse with no error and round-trip byte for byte (§2.3). They stay accepted and are **not** problems. No change; Phase 1 adds regression tests so they keep working.
2. **Unknown options are parse errors**, so a file with one is broken (§4.7). No grammar fallback is added for them, and `THUnrecognizedCommandOption` stays unused.
3. **Report them clearly, once.** Today an unknown option on a `scrap`, `line` or `area` line makes the whole opening line fail, so the parser never opens the block, and the rest of the block (or, for a scrap, the rest of the file) turns into a cascade of unrelated errors (§2.3). For a readable problem list, the parser recovers:
   - when a `scrap`, `line` or `area` line fails the grammar, the parser tries a relaxed recovery rule that only matches the command keyword and its first argument (`scrap <id> …`, `line <type> …`, `area <type> …`);
   - if that matches, it records **one** `parseError` at that line ("unrecognized option or invalid option value"), opens the block as usual so its body and `end*` line are consumed normally, and carries on. The model is discarded anyway, because the file is broken;
   - a `point` line fails on its own and needs no recovery.
4. **Unknown option lines inside a line or an area** (`weirdsegopt xyz`, `weirdareaopt 5`) are reported as a `parseError` at that line. The implicit-close check of §6.1 step 1 runs first, so a `point`/`line`/`area`/`scrap`/`endscrap` line still closes an unclosed element instead of being reported as an unknown option.
5. **Fix the silent drop.** Today `weirdareaopt 5` inside an area is dropped with no error (§2.3). Phase 1 traces the cause and makes it a `parseError`, so the file is correctly reported as broken. The no-silent-drops check of §6.1 step 7 guards against similar cases.

## 7. Implementation Phases

Each phase ends with:

- `flutter analyze` clean and `flutter test` green;
- its own CHANGELOG entry in the current unreleased section, referencing #32. Phase 6 adds an entry only for its own documentation and localization work;
- from Phase 3 on, EN/PT `.arb` entries for every user-visible string the phase introduces, followed by `flutter gen-l10n`, so that no phase from Phase 3 on commits hard-coded UI text. Phase 1 hard-coded the broken-file body text before this rule existed; Phase 6 localizes it.

### Phase 1: Violation detection and the broken-file body

- Parser changes from §6.
- `TH2FileProblem` type (§4.7), line tracking in the parser, `isBroken`/`problems` on the controller and the load result, and the split of `_finalFilePreparations` into the always-run part and the canvas-only part (§4.7).
- `TH2BrokenFileBodyWidget` and the switch in `TH2FileEditBodyWidget`; no dirty state, Save/Save As/Save All skip or disable broken files; `MPGeneralController.reloadTH2File` and tab rebinding.
- Run-Therion warning for open broken files.
- Tests:
  - `t3939_th2_file_parser_hierarchy_violations_test.dart`. Cases, each asserting the violation kinds and line numbers, no exception, and that the load is reported broken:
    - PLA at file level;
    - multi-line `line…endline` and `area…endarea` at file level (one violation each, no cascade from their bodies);
    - nested scrap with contents;
    - stray `endscrap`, including a stray file-level `endscrap` followed by another top-level element;
    - missing `endline` followed by `point`/`line`/`endscrap`;
    - missing `endarea` followed by `line`/`point`;
    - missing `endarea` followed directly by `endscrap` (reports `missingEndarea`, not a border reference named `endscrap`);
    - missing `endscrap` at EOF;
    - missing `endline` at EOF;
    - a valid file with a border thID that is an ordinary word is still valid;
    - unknown types are **not** problems and round-trip byte for byte: an unknown point, line and area type, an unknown point and line subtype, and a `u:` user type;
    - unknown options **are** problems (§6.2): an unknown option, with an argument and as a flag, on a `point`, `line`, `area` and `scrap` line, each reported as **one** `parseError` at that line with no cascade from the block's body or the rest of the file; an unknown line-point option line; an unknown option line inside an area (today's silent drop);
    - an unknown option line inside an unclosed line or area does not hide a following `point`/`line`/`endscrap`, which still closes the element and is reported as a missing `end*`;
    - **no silent drops:** for every Phase 1 fixture, every non-empty source line is either in the model or reported as a problem (§6.1 step 7);
    - plain syntax errors, each reported as `parseError` with the right line number and source line: a misspelled command (`poin …`) inside a scrap, a line point with one coordinate inside a line, a line-segment option with no segment, a malformed `##XTHERION##` image setting, and an unclosed multiline comment at EOF.
  - Existing parser tests stay green: valid files are parsed exactly as before.
  - `t3940_th2_broken_file_body_widget_test.dart`: a broken file shows the panel and not the canvas, lists the problems (hierarchy violations and plain syntax errors) with line numbers, never opens the "parsing warnings" dialog, is never dirty, Save As is disabled, closing its tab does not prompt, and Reload after fixing the file on disk mounts the canvas with an active scrap.

### Phase 2: Model primitive and `MPMoveElementsCommand`

- `TH2File.moveElementToParent`, `THIsParentMixin.invalidateDrawableChildrenCache`, `MPMoveElementsCommand` with its registration and factory, `moveElements`/`executeMoveElements` (following the existing `reorderScraps`/`executeReorderScraps` naming), `_structureRevision` (§5.4), and the convenience methods from §5.3.
- `TH2FileEditController.dispose()`, running `_disposers`, called from `removeFileController`, `reloadTH2File` and the tab-less cleanup.
- `TH2HierarchyAux.validateMove` in a new `lib/src/auxiliary/th2_hierarchy_aux.dart`.
- `MPGeneralController.disposeTablessTH2Controllers` and the call from `_beginProjectLifecycleTransition()` (project open, reload and close).
- Tests:
  - `t2462_commands_mpmoveelementscommand_test.dart` (next to `t2460_commands_mpreorderimagescommand_test.dart`; `t2461` is taken): reorder within a scrap, move between scraps, scrap reorder, an area moved within its scrap without moving border lines, an area moved across scraps together with its border lines, multi-element move (including several adjacent siblings from one parent, §5.2), and undo/redo returning `childrenMPIDs` and `parentMPID` exactly. Also `toMap`/`fromMap` round-trip, thID registry unchanged, a written file that differs only in line order, and a selected element keeping a consistent selection after a move.
  - `t3941_th2_hierarchy_aux_test.dart`: the `validateMove` matrix (every element type × every parent type, self-subtree, area-border rule, a border line shared by two areas, `beforeSiblingMPID` set to the `THEndscrap`, no-op move).
  - Bring forward/backward/front/back: stepping over a sibling of another type, stepping over hidden comments, already first or last. A point brought forward past a multi-segment line must be written **after that line's `endline`**, and a point sent backward past an area must be written **before its `area` line**, never between an element's opening and `end*` lines.
  - `_structureRevision` is bumped once per load, not once per parsed element, and not when a line segment is added.
  - Lifecycle: tab-less project controllers, dirty or clean, are disposed (their reactions run) on project open, reload and close; standalone controllers outside the project are untouched.

### Phase 3: Element tree in the sidebar (read-only)

- Sealed row model, flattener callback, `th2_element_tree_aux.dart` row builder, `TH2ElementTreeRowWidget` (icon, label, selection highlight) and the status row (loading, load error, broken).
- Chevron on `TH2FileNode`, lazy load on expand, and the broken badge after loading (§4.2). Reload from the right-click context menu of broken and load-error file rows and their status rows, through the shared `MenuAnchor`-based `THProjectTreeRowContextMenuWidget` (Phase 3 plan §9.2).
- Filter matching of loaded element labels, and the header order tooltip.
- Tree → canvas selection sync and canvas → tree highlight (§4.6).
- EN/PT strings for the loading, load-error and broken status rows, the broken badge tooltip, the Reload menu entry and the header order tooltip (Phase 3 plan §9.1).
- CHANGELOG entry for Phase 3, referencing #32.
- Tests:
  - update `t3881_th_project_tree_flatten_test.dart` and `t3883_th_project_tree_widget_test.dart`;
  - `t3942_th2_element_tree_rows_test.dart`: hidden children are excluded, order is preserved, a broken file yields only its status row;
  - `t3943_th2_element_tree_widget_test.dart`: expanding loads without opening a tab, the badge appears only after load, a broken file shows the badge and status row, a row tap selects on the canvas, the tree rebuilds after undo.

### Phase 4: Drag and drop, context menu, shortcuts

- `Draggable<List<int>>` on element rows (payload = the selected MPIDs of the same file) and a `DragTarget` on every row using the §4.3 zones, following `mp_available_scraps_widget.dart`.
- An insertion-line indicator, reject feedback with a localized reason, auto-expand of a collapsed scrap after hovering for `mpProjectTreeDragHoverExpandDelayMilliseconds` (new constant), and auto-scroll near the list edges.
- Cross-file drag payloads are rejected with a clear reason.
- Opening the tab on the first edit of a tab-less file (§4.2).
- Row context menu (§4.8) and canvas shortcuts for forward/backward/front/back on the current selection. Element-row menu items go into Phase 3's `THProjectTreeRowContextMenuWidget`; the "Move to scrap… ▸" list uses `SubmenuButton`. Phase 4 decides whether right-clicking an element row also selects it.
- EN/PT strings for every drop-rejection reason, context-menu item and other text this phase introduces.
- CHANGELOG entry for Phase 4, referencing #32.
- Tests (details: [Phase 4 plan](2026-09-23-th2-element-tree-and-drawing-order-phase4-drag-drop-and-menu.md) §11):
  - `t3947_th2_move_resolution_test.dart`: typed rejection reasons, no-op detection and multi-element bring forward/send backward;
  - `t3948_th2_element_tree_drag_drop_test.dart`: valid reorder, valid move between scraps, same-scrap border-line reorder, and rejected drops (scrap into scrap, PLA onto the file row, border line alone across scraps). Each asserts the resulting `childrenMPIDs` or that no command was pushed;
  - `t3949_th2_element_tree_context_menu_test.dart`: menu actions;
  - `t3950_th2_drawing_order_shortcuts_test.dart`: shortcuts.

### Phase 5: Station names and label/remark text in element labels

Phase 3 labels are `<kind> <type[:subtype]> <thID?>` (Phase 3 plan §6.2). This phase adds one extra *detail* part for three point types, so surveyors can recognize stations and text points in the tree without selecting them:

| Point type | Detail source | Example row |
|---|---|---|
| `station` | the `-name` option (`THCommandOptionType.station`, `THStationNameCommandOption.name`) | `point station` *`1.3@main`* `s12` |
| `label` | the `-text` option (`THCommandOptionType.text`, `THTextCommandOption.text.content`) | `point label` *`Main entrance`* |
| `remark` | the `-text` option | `point remark` *`Unsurveyed lead`* |

In the examples, italics show the detail span and the trailing muted part is the Therion id.

- **Format:** `<kind> <type[:subtype]> <detail?> <thID?>`. The detail is shown in *italics* in the normal text colour, between the type and the muted Therion id. There are no quotes, brackets or prefixes such as `name=`/`text=`, for the same reasons Phase 3 gives for ids. Points with no `-name`/`-text`, or with an empty value after trimming, show no detail. Every other point type, every line (including line `label -text`), every area and every scrap is unchanged. The `-text` of `continuation` points and other option values (`-value`, `-altitude`, dates, dimensions) stay out of scope.
- **Values are shown as stored.** A station name is shown verbatim (for example `1.3@main`), without resolving survey namespaces or checking that the station exists. Label and remark text reuse the canvas rule in `MPLabelTextAux`: `MPLabelTextAux.resolve(point)` returns the text split on `<br>` into trimmed lines. The tree joins those lines with a single space so the row stays on one line, and leaves every other Therion text tag (`<center>`, `<size:N>`, font switches, `<rtl>`, `<lang:XX>`, `<thsp>`) as literal text, exactly as the canvas does today. The row's normal ellipsis handles long text. When a label or remark row has a detail, the row tooltip shows the full text with one `<br>` line per tooltip line.
- **No new translatable strings.** The detail is user data, and the kind and type parts already come from `MPTextToUser`.
- **Filtering:** the row's plain text used for filtering (Phase 3 plan §7) becomes `<kind> <type[:subtype]> <detail> <thID>`, with empty parts left out, so searching for a station name or for words from a label or remark finds the point. As before, only loaded, valid files are searched.
- **Keeping labels current.** Today `executeSetOptionToElement` and `executeRemoveOptionFromElement` in `th2_file_edit_element_edit_controller.dart` call `bumpStructureRevision()` only for `THCommandOptionType.id`. This phase extends that to `THCommandOptionType.station` and `THCommandOptionType.text`, for any element type (checking the element type is not worth it, since these edits are rare). This covers edits from the options dialog, undo/redo of those commands, and commands wrapped in `MPMultipleElementsCommand`. Changing a point's type to or from `station`/`label`/`remark` already bumps the revision through the type-edit commands (Phase 2). The Phase 3 label cache, keyed by `structureRevision`, then picks up the new detail.
- **Row data:** the row builder in `th2_element_tree_aux.dart` computes the detail next to the rest of the label, and `TH2ElementTreeRowWidget` renders it as a third span in the existing `Text.rich`.
- CHANGELOG entry for Phase 5, referencing #32.
- Tests (`t3951_th2_element_tree_label_details_test.dart`):
  - a station with `-name` shows the name verbatim, including `@` and dots; a station without `-name` shows no detail;
  - label and remark points with `-text` show the text; `<br>` becomes a single space in the row and a line break in the tooltip; other tags stay literal; empty or whitespace-only text shows no detail;
  - a line `label` with `-text`, a `continuation` point with `-text`, and points of other types show no detail;
  - with a Therion id, the order is kind, type, detail, then id, and only the id span is muted;
  - setting, changing and removing `-name`/`-text` through `MPSetOptionToElementCommand`/`MPRemoveOptionFromElementCommand` bumps `structureRevision` and updates the row, and undo/redo restores the previous row text;
  - filtering by a station name or by a word from a label or remark finds the row and shows its scrap and file ancestors;
  - building labels never changes the file.

### Phase 6: Documentation and remaining localization

- Localize the strings Phase 1 hard-coded in `TH2BrokenFileBodyWidget` (the explanatory sentence, the `Line …:` problem line and `Reload`) and the user-visible problem-kind names, followed by `flutter gen-l10n`. Reuse the Phase 3 keys `th2ElementTreeProblemLine` and `th2ElementTreeReload` where the wording matches.
- Check that no hard-coded user-visible string from Phases 1–5 remains.
- Help pages (EN/PT):
  - a new section "Drawing order and element tree", including how rows are labelled: kind, type, the station name or label/remark text (Phase 5), and the Therion id;
  - a new section "Broken files", covering which violations exist, that Mapiah does not display or change such files, and how to fix them in a text editor and reload;
  - a mention in the project-sidebar section.
- Keyboard shortcuts page with the new shortcuts in alphabetical order.
- CHANGELOG entry for Phase 6 (help pages, shortcuts page, remaining localization), referencing #32. Also check that the CHANGELOG as a whole calls out the broken-file behavior change (§9, risk 1); if Phase 1's entry does not, Phase 6's entry does.

### Phase 7: Type preview icons on element rows

Each point, line and area row in the sidebar tree starts with a small icon that previews how that element's type (and subtype) is drawn on the canvas. It replaces the generic element-kind icon that Phase 3 uses for these rows. Scrap rows keep their Phase 3 icon, and file, status and project rows are unchanged.

**Icon content.** Each icon is a preview of the element's type and subtype, not of that particular element, so it uses only `type` and `subtype`. Everything else is ignored: `-orient`, `-scale`, `-reverse`, `-clip`, `-visibility`, `-id`, the actual geometry, and selection or highlight state. The same type always gets the same icon.

- **Points:** the symbol the canvas would draw for that point type and subtype, drawn with `MPInteractionAux.drawPoint` and the paint from `MPVisualController.getDefaultPointPaint(point)`, centred and scaled to fit the icon box, with no frame. For label-mode point types (`label`, `remark`, `altitude`, `date`, `height`, `passage-height`, `dimensions`), the canvas draws the element's own text, which would be unreadable at this size and is not a type preview. These types use their `mapiahPlaceholder` shape instead.
- **Lines:** a small rectangle frame (`colorScheme.outline`, 1 logical pixel) with a short curved sample line inside: a single cubic Bézier S-curve from the left edge to the right edge of the frame's inner area. The curve is drawn with the line type's canvas paint (`getDefaultLinePaintByTypeSubtype`), decorator (`getLineDecorator`) and decorator color (`getLineDecoratorColor`), so dash patterns, ticks and other decorations appear as on the canvas. Line-direction ticks are not drawn.
- **Areas:** the same rectangle frame with a small oval inside, a closed ellipse path drawn with the area type's canvas paint (`getDefaultAreaPaint`), including its fill or pattern, as the canvas draws an area.
- **Background:** inside the frame, and behind point symbols, the icon paints the canvas background colour for the current brightness (white in light mode, black in dark mode, as in `TH2FileWidget`), so the preview has the same contrast as on the canvas.
- **Visualization method:** icons follow the current `tH2EditVisualizationMethod` setting and the selected Therion symbol set, exactly as the canvas does. Placeholder mode shows placeholder previews; Therion modes show that set's symbols.

**Zoom-independent rendering.** Canvas painting reads zoom-dependent values from `TH2FileEditController`: `canvasScale`, `lineThicknessOnCanvas`, `pointRadiusOnCanvas`, `lineDirectionTickLengthOnCanvas` and `scaleScreenToCanvas`. Icons must look the same at every zoom level, so:

- The path-drawing core of `THLinePainter.paint` (base path from the decorator, fill, dash or continuous stroke, decorator pass) moves into a static helper that takes the canvas, `Path`, `THLinePaint`, optional decorator and decorator color, `MPSymbolUnit`, and line thickness as explicit arguments. `THLinePainter` calls it with values from the controller, so canvas output is unchanged; the icon painter calls it with fixed preview values. `MPInteractionAux.drawPoint` already takes an explicit `MPSymbolUnit` and needs no change.
- Preview sizes are new constants in `mp_constants.dart`: `mpTH2ElementTreeTypeIconWidth`, `mpTH2ElementTreeTypeIconHeight` (the frame, wider than tall and fitting within `mpProjectTreeRowHeight`), `mpTH2ElementTreeTypeIconSymbolUnitScale`, `mpTH2ElementTreeTypeIconLineThickness` and `mpTH2ElementTreeTypeIconPointRadius`. No magic numbers go in the painter.
- Paints are resolved through the row's own file controller's `visualController`, which exists for tab-less controllers too, and their stroke widths are then replaced with the preview constants through `copyWith`. The canvas's paint objects are never modified; the icon code works on copies.

**Widget and caching.**

- A new `TH2ElementTypeIconWidget` (`lib/src/widgets/th2_element_type_icon_widget.dart`) draws the icon with a `CustomPaint` and a new `TH2ElementTypeIconPainter`, wrapped in `ExcludeSemantics`, because the row label already describes the element.
- Rendering each icon from scratch for every row in a long file would be slow, so rendered icons are cached as `ui.Picture`s in a small app-wide cache. The key is the element kind, type, subtype, visualization method, symbol set, brightness and device pixel ratio. The cache is cleared when any setting that affects symbols changes, and its size is bounded (least recently used entries dropped first; limit in `mp_constants.dart`).
- The row keeps its existing leading space. The icon replaces the Phase 3 icon in the same slot, so labels still line up with scrap rows and the chevron column (Phase 3 plan §6.1).
- Area pattern fills use the same pattern source as the canvas (`MPPatternCache`). If a pattern image is not ready yet, the icon draws the area's plain fill and repaints when the pattern arrives; it never blocks the build.

**Keeping icons current.** A type edit bumps `structureRevision` through the type-edit commands (Phase 2), and a subtype set or removed as an option bumps it too (Phase 3 plan §3.1 item 7), so the row rebuilds with the new key. A change of visualization method or symbol set clears the cache and rebuilds the tree.

- **Localization:** no new strings, since icons are decorative and excluded from semantics.
- **Help pages (EN/PT):** Phase 6 comes earlier, so this phase updates the "Drawing order and element tree" help section itself, to mention the type preview icons.
- CHANGELOG entry for Phase 7, referencing #32.
- Tests (`t3952_th2_element_type_icon_test.dart`):
  - golden tests, following the existing Therion symbol golden tests (`t3764`–`t3766`), in light and dark mode, for:
    - a point with a Therion symbol (for example `station`);
    - a label-mode point (placeholder fallback);
    - a continuous line (`wall`);
    - a decorated line (for example `pit` or `contour`);
    - a plain-fill area (for example `water`);
    - a patterned area (for example `debris`).

    Each golden is captured under at least placeholder mode and one Therion symbol set.
  - two elements with the same type and subtype but different `-orient`, `-scale`, `-reverse` or geometry produce identical icons and one cache entry;
  - changing canvas zoom does not change any icon;
  - after the `THLinePainter` refactor, existing line and area canvas golden tests pass unchanged;
  - changing a point's type through the type-edit command updates the row icon; changing the visualization method or symbol set updates every visible icon;
  - scrap rows keep their Phase 3 icon, and icon size and label alignment match the row layout;
  - the icon is excluded from semantics, and the row's semantics label is unchanged.

## 8. Files Touched (expected)

| Area | Files |
|---|---|
| Model | `lib/src/elements/th2_file.dart`, `lib/src/elements/mixins/th_is_parent_mixin.dart` |
| Parser | `lib/src/mp_file_read_write/th2_grammar.dart` (recovery rules for `scrap`/`line`/`area` lines), `th2_file_parser.dart` |
| Commands | new `lib/src/commands/mp_move_elements_command.dart`, `mp_command.dart`, `factories/mp_command_factory.dart`, `types/mp_command_type.dart`, `types/mp_command_description_type.dart` |
| Controllers | `th2_file_edit_element_edit_controller.dart` (Phase 5: revision bump for `station`/`text` option edits), `th2_file_edit_controller.dart` (`_structureRevision`, `isBroken`, `problems`, `_finalFilePreparations` split, `dispose()`), `mp_general_controller.dart` (tab-less cleanup, open-on-edit helper, `reloadTH2File`), `th_project_controller.dart` (cleanup call, skip broken files on save) |
| Aux | new `lib/src/auxiliary/th2_hierarchy_aux.dart`, new `th2_element_tree_aux.dart` (Phase 5: label details), `th_project_tree_flatten_aux.dart`, `mp_text_to_user.dart`, `mp_label_text_aux.dart` (reused as is in Phase 5) |
| Widgets / pages | `th_project_tree_widget.dart`, `th_project_tree_node_widget.dart`, new `th2_element_tree_row_widget.dart`, new `th2_element_type_icon_widget.dart` (Phase 7), new `th2_broken_file_body_widget.dart`, `th2_file_edit_body_widget.dart`, `th2_file_tabs_page.dart` (Save As disabled for broken files), `mp_therion_run_dialog_widget.dart` (broken-file warning) |
| Constants | `mp_constants.dart` (drag hover delay, drop-zone fractions; Phase 7: type-icon sizes, preview symbol scale, line thickness, point radius and cache limit) |
| Painters | Phase 7: `lib/src/painters/th_line_painter.dart` (path-drawing core moved into a static helper with explicit symbol unit and thickness), new `lib/src/painters/th2_element_type_icon_painter.dart` |
| l10n | `lib/l10n/intl_en.arb`, `intl_pt.arb`, updated in each phase from Phase 3 on for that phase's strings, and in Phase 6 for the Phase 1 strings |
| Docs | help pages EN/PT and keyboard-shortcuts page (Phase 6) |
| Changelog | `CHANGELOG.md`, one entry per phase |

## 9. Risks and Open Questions

1. **Behavior change for existing users.** Files with hierarchy violations or any other parse error open today on the canvas, with lines silently dropped. After this change they no longer open for editing, even when the only problem is one unknown option or one malformed `##XTHERION##` line. Files that use options from a newer Therion version, or custom options, are affected too. This is intended, since editing and saving them loses data, but it must be called out in the CHANGELOG and the help page.
2. **Implicit-close heuristics (§6.1, steps 1-2).** They decide at which line a missing `end*` is reported. The Phase 1 fixtures pin that down. A wrong guess only moves a line number in a warning; it cannot damage data, because the file is not saved.
3. **Parser gaps become blocking.** Any input the parser does not support yet, even valid Therion, now stops a file from opening instead of losing one line. That is the safer failure, but a gap reported by a user needs a parser fix before they can open the file in Mapiah again. The "Details" section (§4.7) gives them something to report.
4. **Code paths that assume a scrap parent.** These are avoided rather than fixed, because broken files never reach the canvas and tree edits cannot create violations. Any new canvas feature must keep checking `isBroken` before mounting.
5. **Comments next to moved elements (§4.4).** Leaving comments in place can separate a comment from the element it describes. This is acceptable for v1.
6. **Performance on large files.** Rebuilding rows on every `_structureRevision` bump is O(visible rows) and only happens for expanded files. If needed, cache the row list per `(path, revision)`.
7. **Tab-less controllers.** These use memory for files that were only browsed. Mitigation: cleanup on project close. A possible later step is to dispose a clean, tab-less controller when its file row collapses.
8. **Undo location.** The undo for a tree edit lives on the file's own stack. Opening and activating the tab on the first edit (§4.2) keeps `Ctrl+Z` natural. Edits made while another file's tab is active switch tabs, which is intentional and visible.
