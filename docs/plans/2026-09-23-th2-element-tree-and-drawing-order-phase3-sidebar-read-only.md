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
- A broken badge, and a Reload action in the context menu of broken and load-error files.
- Search matching for labels belonging to loaded, valid TH2 files.
- Element labels, existing element icons, indentation, expansion state and selection highlight.
- Tree-to-canvas selection for open files and canvas-to-tree highlight synchronization.
- Rebuilding the rows after load, undo/redo, type/subtype/id changes and controller reload via `isFileLoaded`, `isBroken`, `structureRevision` and `th2ControllersRevision`, after making those signals observable (§3.1).
- Keeping a file's controller tab-less when its tab closes while its tree row is expanded (§3.2).
- Making default expansion stop above the shallowest `.th2` file, so it never expands a TH2 row (§3.3).

### Out of scope

- Drag-and-drop, insertion indicators, auto-scroll and moving elements.
- Context-menu move actions and keyboard shortcuts.
- Loading files just to satisfy a search query.
- Showing elements from broken files.
- Pre-scanning all project files.
- Showing comments, empty lines, settings, images, line segments or area border references as rows.
- Changes to parser behavior, TH2 serialization or canvas paint order.
- Symlink resolution or case-insensitive path matching (§3.1 item 5), and changes to `MPDirectoryAux` path handling.

## 3. Existing constraints

- `THProjectNode` is the project parser's tree and must not receive TH2 model elements. Its `children` list is rebuilt by project parsing and has no safe connection to MobX file state.
- `THProjectTreeWidget` currently consumes `List<THProjectTreeVisibleNode>` and always builds `THProjectTreeNodeWidget`; the flattener and builder must become polymorphic without changing project-node behavior.
- `TH2FileNode` is currently a leaf. Its chevron must be available even before a controller exists, because expanding it is what starts lazy loading.
- `TH2FileEditController.load()` is cached. Tree loading must request the controller through `MPGeneralController` and reuse that cached future rather than starting a second parse.
- `TH2FileEditController.isLoading`, `structureRevision`, controller disposal and tab-less cleanup are already provided by Phase 2. Phase 3 adds observability for `isFileLoaded`, `isBroken`, `problems`, `loadError` and `MPGeneralController.th2ControllersRevision`. The tree must not inspect private parser state or infer loading from whether a tab exists.
- A tab-less controller is valid after tree loading. Reading a file in the tree must not call `addFileTab`, mark the file dirty or alter the active canvas tab.
- MPIDs are runtime identifiers. Row ids must include the canonical file path (§3.1 item 5) and the MPID, and stale expansion ids after reload are harmless.
- `TH2File.childrenMPIDs` and `THScrap.childrenMPIDs` include hidden source-order children. The row builder filters the supported visible element kinds while preserving the remaining elements' order; it must never use drawable-child order because areas are intentionally not drawable children.

### 3.1 Observability prerequisites

Phase 2 already added the observable `isLoading`/`structureRevision` signals, controller disposal, and tab-less cleanup. The remaining gap is that a tree `Observer` cannot yet see a load finish, a file become broken, a load failure, or a controller being created or replaced. Phase 3 adds only the observability, load-error, disposal and revision changes below, plus the tab-close rule in §3.2; it must otherwise preserve the Phase 2 behavior.

1. **Lifecycle fields become observable.** In `TH2FileEditControllerBase`:
   - `bool _isFileLoaded` becomes `@readonly bool _isFileLoaded = false;` (the hand-written `isFileLoaded` getter is removed; the generated one replaces it).
   - `bool isBroken` becomes `@readonly bool _isBroken = false;`.
   - `List<TH2FileProblem> problems` becomes `@readonly List<TH2FileProblem> _problems = const <TH2FileProblem>[];`. It is always replaced by a new unmodifiable list, never mutated in place. `TH2FileProblemKind.parseError` entries produced by `TH2FileParser._addError` remain part of this list; parser error strings returned separately for the existing error dialog are not a second tree diagnostic source.

   The public read names (`isFileLoaded`, `isBroken`, `problems`) stay the same, so readers such as `th2_file_edit_body_widget.dart` and `th2_file_tabs_page.dart` are unchanged. Every write happens inside an action. MobX's default `observed` write policy asserts in debug builds and tests when an observed field is written outside an action, and the tree observes these fields, so two existing writes need changes:
   - `_preParseInitialize` becomes `@action`. It sets `_isLoading = true` and runs synchronously inside `load()`. When `ensureTH2FileLoaded` (§5) loads a controller the tree `Observer` has already read, that write would otherwise happen outside an action.
   - `saveAsTH2File` is `async` and is not an action, so its `_isFileLoaded = true` moves into a small private `@action` (for example `_markLoadedAfterSaveAs()`) called at the same point.

2. **Load results are committed in one action, with the revision bump last.** The existing Phase 2 load path runs `_finalFilePreparations` (which resets `_isLoading`), bumps `structureRevision`, and only then marks the file loaded, while `problems`/`isBroken` are assigned earlier in `_loadOnce`. The bump therefore fires, but a synchronous reaction to it still sees `isFileLoaded == false`. The part of `_loadOnce` after `await parser.parse(...)` moves into one `@action` method that sets `_problems`, `_isBroken`, runs `_finalFilePreparations`, sets `_isFileLoaded = true`, and calls `bumpStructureRevision()` last. Observers then see one consistent transition from loading to loaded, valid or broken. Preserve the existing Phase 2 revision semantics: one load-time bump, one bump per relevant edit/undo/redo, and no bump per parsed element.

3. **Controller membership becomes observable.** `MPGeneralControllerBase` gets `@readonly int _th2ControllersRevision = 0;` and a private `@action` bump. It is bumped whenever the set of TH2 controllers or their keys changes:
   - `getTH2FileEditController` when it creates or force-replaces a controller (not when it returns an existing one);
   - `getTH2FileEditControllerForNewFile`;
   - `removeFileController` when it removed a TH2 controller;
   - `renameFileController` when it moved a TH2 controller;
   - `disposeTablessTH2Controllers` when it disposed at least one controller.

   These methods become `@action` where they are not already. `getTH2FileEditControllerIfExists` reads `th2ControllersRevision` before its lookup, so any `Observer` that resolves a controller through it rebuilds after creation, removal, rename or `reloadTH2File`. A counter is preferred to an `ObservableMap` because it keeps the existing `HashMap` and disposal code unchanged.

   Consequences for the tree:
   - Resolve the controller in build with `getTH2FileEditControllerIfExists(path)` every time. Never cache a controller reference in a row or widget, because `reloadTH2File` disposes the old instance.
   - Never create a controller inside an `Observer` build, because that writes an observable during a derivation. The lazy-load request (§5) runs from the chevron handler or a post-frame callback.

4. **A failed load is recorded.** `TH2FileParser.parse` catches file-read/decode failures and records them through `_addError`; those diagnostics become `TH2FileProblemKind.parseError` entries in `problems`, so an unreadable or structurally invalid file is represented by the same broken-file diagnostic list used by the sidebar. The separate parser-error strings returned by `parse()` remain for the existing tab error dialog and are not counted a second time. `load()` therefore throws only on an unexpected exception (a Mapiah bug in parsing or in `_finalFilePreparations`). Today that leaves `_isLoading` stuck at `true`, the rejected future cached in `_loadFuture`, and no observable state recording the failure. `TH2FileEditControllerBase` gets `@readonly Object? _loadError;`:
   - `load()` wraps `_loadOnce()` in `try/catch`. On an exception it commits one `@action` that sets `_loadError = error` and `_isLoading = false`. `_isFileLoaded` stays `false`, and `_isBroken` and `_problems` are unchanged. The error is logged through `mpLocator.mpLog.e`, then rethrown, so the tab's existing `FutureBuilder` → `snapshot.hasError` → `_handleLoadFailure` path (error dialog, then close) keeps working unchanged.
   - The failed future stays cached in `_loadFuture`, so calling `load()` again on the same controller never parses again. That rules out retry loops across rebuilds.
   - The only way to retry is Reload through `reloadTH2File`, which disposes the failed controller and creates a new one with `_loadError == null`. `th2ControllersRevision` lets the tree see the replacement.
   - An exception is never turned into a broken-file problem. That would present a Mapiah bug as a defect in the user's file and tell them to fix it outside Mapiah.

5. **One definition of "canonical path".** Mapiah has two copies of one rule today: the project side uses `THProjectPathResolver.canonicalize(p.absolute(path))`, and `MPGeneralController._normalizeFilename` uses `p.normalize(File(path).absolute.path)`. Both make the path absolute against the current directory and then normalize it, so they give the same string. `TH2FileNode.absolutePath` is built through `THProjectPathResolver.resolve`, which also normalizes, so it already matches the controller map's keys.
   - **Definition.** In this plan, the *canonical path* of a file is `THProjectPathResolver.canonicalize(p.absolute(path))`: absolute and normalized, with **no** symlink resolution and **no** case folding. For a project TH2 file it equals `TH2FileNode.absolutePath`. Row ids (`th2el:<canonicalPath>:<mpID>`), status-row ids, `collapsedTH2ScrapIds` keys, `ensureTH2FileLoaded(path)` and every controller lookup from the tree use it.
   - **Refactor, no behavior change.** `_normalizeFilename` keeps its special cases (empty names and `mpNewFilePrefix…` names are returned unchanged). For every other name it returns `THProjectPathResolver.canonicalize(p.absolute(filename))` instead of repeating the rule, so the registry and the project tree share one definition.
   - **Deliberately not done.** Symlink resolution fails for missing files, which the project tree shows on purpose, and it would change the paths Mapiah shows, saves to and writes into directives. `THProjectPathResolver.canonicalize` documents this choice. Case folding on Windows and default macOS would change displayed and written paths. It would only fix the pre-existing case where the same file opened with different letter case gets two tabs, which needs case-insensitive *comparison* with the original *display* path kept. That is a separate issue. `MPDirectoryAux`'s `p.canonicalize` is used for relative image-path rebasing, not file identity, and is not changed. Its Windows lowercasing of absolute image paths in `rebaseRelativePath` is a possible existing bug to check separately.

6. **A load that finishes after disposal commits nothing.** Expanding a file row is enough to start a load, and every project reload or close calls `disposeTablessTH2Controllers`, so a controller is often disposed while its parse is still running. Today the load would then run `_finalFilePreparations` on the disposed controller, and its `_initializeReactions()` would register autoruns that nothing ever disposes.
   - The load-commit action (item 2) checks `_disposed` first. If the controller is disposed, it writes no field, registers no reaction, does not bump `structureRevision`, and only returns the result so the future completes.
   - The load-error action (item 4) does the same: a disposed controller does not set `_loadError` or `_isLoading`. `load()` still rethrows, and `ensureTH2FileLoaded` already catches the error.
   - The parser may keep writing into the disposed controller's own `TH2File` until the parse ends. Nothing reads that file afterwards, so this is harmless.

7. **Subtype edits bump `structureRevision`.** A subtype is stored as a `THSubtypeCommandOption`, and today `executeSetOptionToElement` and `executeRemoveOptionFromElement` in `th2_file_edit_element_edit_controller.dart` bump the revision only for `THCommandOptionType.id`. A subtype changed on its own, for example from the options panel, would therefore leave the row label and the label cache (§7) stale. Both methods also bump for `THCommandOptionType.subtype`. A type-and-subtype edit made through the type commands then bumps more than once inside one command; this is harmless because rows rebuild on the next frame. The rule in item 2 still holds: no bump per parsed element, because `bumpStructureRevision` does nothing while `isLoading`.

### 3.2 Keeping a controller when its tab closes

Closing a TH2 tab calls `TH2FileEditController.close()`, which disposes the controller's reactions and then calls `removeFileTab`, which calls `removeFileController` and disposes the controller. If the file's tree row is expanded, the tree would then find no controller and parse the file again tab-less. The new controller has new MPIDs, so collapsed scraps would expand again and the tree selection would be lost. The failed-load path has the same problem: `_discardFailedFileLoad` in `th2_file_tabs_page.dart` removes the failed controller, the tree loads the file again, and the load that failed is retried automatically, which §3.1 item 4 forbids.

**Rule.** When a TH2 tab closes, its controller is kept, tab-less, if all of these are true:

- the file is a TH2 file of the open project, and the id of its `TH2FileNode` is in `expandedNodeIds`. This is asked through a new `THProjectTreeUIController.isTH2FileRowExpanded(String canonicalPath)`, which returns `false` when there is no project or no `TH2FileNode` with that `absolutePath`;
- the controller has no unsaved changes (`!enableSaveButton`, the same value that drives dirty mirroring);
- it is not a new, never-saved file (`mpNewFilePrefix…`).

Otherwise the controller is disposed as it is today. A controller with unsaved changes is disposed because closing its tab discards those changes. Keeping it would show edits that are not on disk, so the tree loads the file again from disk, once.

**Mechanics:**

- `removeFileTab` makes the decision. For a TH2 tab it calls `removeFileController` only when the rule above does not keep the controller. `closeProjectFileTabs` is unchanged: it runs only during project transitions and is followed by `disposeTablessTH2Controllers` for the same paths, so kept controllers are still disposed when the project closes or reloads.
- `close()` no longer calls `_disposeReactions()` itself, so a kept controller stays fully working, including dirty mirroring and the tree's selection sync. `dispose()` already disposes the reactions when the controller is removed. `close()` still clears overlay windows and the pattern cache.
- `_discardFailedFileLoad` still drops its `_fileLoads` entry, but it calls `removeFileController` only when the same rule does not keep the controller. A failed controller kept this way keeps its `loadError`, so the tree keeps the load-error row and nothing retries. Opening the tab again shows the cached failure and the error dialog again. Reload remains the only retry (§3.1 item 4).
- Collapsing the row later does not dispose a kept controller. Tab-less controllers are disposed on project transitions, as in Phase 2.
- `th2ControllersRevision` is not bumped when a controller is kept, because the registry does not change. Removing the tab still updates `openFileOrder` as it does today.

### 3.3 Default expansion never expands TH2 rows

When a project opens with an empty expansion set, `THProjectTreeUIController._handleProjectRootChanged` seeds `expandedNodeIds` with every node shallower than the shallowest `.th2` file, as the existing t3880 test "expands all branches down to the shallowest th2 file" states. The code does not quite do that. `_firstTH2FileDepth` walks the tree depth first and returns the depth of the first `.th2` file in walk order, which is not always the smallest depth:

```
main.thconfig            depth 0
└─ cave.th               depth 1
   ├─ input north.th     depth 2
   │  └─ north.th2       depth 3   ← reached first → expansion depth 3
   └─ input cave.th2     depth 2   ← shallowest .th2, but expanded
```

`_expandNodesAboveDepth` then expands every node shallower than 3, including `cave.th2`. Today this does nothing, because TH2 file nodes are leaves. In Phase 3 an expanded TH2 row loads automatically (§5), so opening this project would parse `cave.th2` without the user asking.

**Fix.** Replace `_firstTH2FileDepth` with a helper that returns the minimum depth of any `TH2FileNode` in the tree (for example `_shallowestTH2FileDepth`), or `null` when there is none. No `.th2` file can then be shallower than the expansion depth, so seeding never adds a TH2 file id. The behavior for projects without `.th2` files (expand the whole tree) and the rule that seeding runs only when `expandedNodeIds` is empty do not change. Only user or programmatic expansion (§5 item 2) expands a TH2 row.

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
  final String th2FilePath; // canonical path (§3.1 item 5), equals TH2FileNode.absolutePath
  final int elementMPID;
  final THElementType elementType;
  final int depth;
  final bool isExpandable; // true only for scrap rows (§6.1)
  final bool isExpanded;   // false for non-scrap rows
}

final class TH2FileStatusTreeRow extends THProjectTreeVisibleRow {
  final String th2FilePath; // canonical path (§3.1 item 5)
  final TH2FileStatusTreeRowKind kind; // loading, loadError, broken
  final int depth;
}
```

The exact private/public split may follow project conventions, but these semantics are required:

- Project rows retain their current ids and selection behavior.
- Element ids use `th2el:<canonicalPath>:<mpID>`, where `canonicalPath` is defined in §3.1 item 5 (for project TH2 files, `TH2FileNode.absolutePath`).
- Status ids use `th2status:<canonicalPath>:<kind>` (for example `th2status:/caves/a.th2:broken`), with the same `canonicalPath` as element ids. They never include a transient future or controller identity.
- The row model carries enough information for a widget to activate a file, find the element, show its icon/label, and select it without looking up a `THProjectNode` child.
- A status row is not a movable element and has no canvas selection.

## 5. Flattening and lazy loading

Extend `flattenVisibleNodes` with an optional callback:

```dart
th2ElementRowsFor(TH2FileNode node, int depth, {required bool filterActive})
```

The full signature and the filter-active behavior are in §7. With the filter inactive, when a file row is expanded, insert the callback's rows immediately after the file row. Keep the existing depth-first behavior for all ordinary project nodes.

The callback is responsible for this state machine:

| Controller state | Rows | File-row behavior |
|---|---|---|
| No controller, or controller not loaded, not loading and `loadError == null` | one `loading` row | needs a load: the widget calls `ensureTH2FileLoaded` after the frame (see below) |
| Load in progress (`isLoading`) | one `loading` row | none; the cached `load()` future is already running |
| `loadError != null` | one `loadError` row | no load request, and no automatic retry. The file row and the load-error row offer Reload in their context menu. Tapping the row or the file label opens the tab, which shows the existing error dialog. The project row stays usable |
| Loaded and broken | one `broken` row | show broken badge and no element rows |
| Loaded and valid | element rows from the model | show scraps and their PLA children |

The callback must be invoked inside the tree `Observer`. It must resolve the controller through `getTH2FileEditControllerIfExists` (which tracks `th2ControllersRevision`) and read `isFileLoaded`, `isBroken` and `structureRevision`, so the rows rebuild after controller creation, asynchronous load, reload, undo and redo (§3.1). It may return loading before the future completes, but it must not synchronously block the build method.

Expansion behavior:

1. Tapping a `TH2FileNode` chevron toggles its project-tree expansion id.
2. Loading depends on the row's state, not on the moment it was expanded. Any TH2 file row that is visible and in the user's expansion set (`isExpanded(node.id)`), and whose controller is missing, or is neither loaded nor loading and has no `loadError`, needs a load. This covers:
   - a chevron tap;
   - an expansion id kept from before a project reload, after `disposeTablessTH2Controllers` removed the controller;
   - an expansion made by `expandAncestorsOf` or any other programmatic expansion;
   - a row that scrolls into view or is revealed when a filter is cleared.

   No row triggers a load while a filter is active, whether it is in the expansion set or shown only through filter auto-expansion (§7). Loading resumes when the filter is cleared.
3. Do not add a tab and do not select the project node merely because the chevron was tapped.
4. Tapping the file label keeps the existing behavior: select the project node and open/activate its tab.
5. A broken status row opens the file tab; its diagnostic body is responsible for displaying the detailed problems.
6. The context menu (§9.2) of a broken file, or of a file whose load failed, offers Reload on both the file row and its status row. Reload replaces the controller through the existing `reloadTH2File` path and offers no element operation. For a tab-less file, Reload keeps it tab-less, because `reloadTH2File` adds a tab only when one was already open.

Load triggering mechanism:

- Flattening stays pure. While building rows, the callback adds the path of each file that needs a load to a per-build set. It never creates a controller or calls `load()`, because doing so inside the `Observer` build would write observables during a derivation (§3.1).
- After the build, if that set is not empty, `THProjectTreeWidget` schedules one post-frame callback. The callback calls `MPGeneralController.ensureTH2FileLoaded(path)` for each path. The chevron handler may also call it directly after toggling expansion.
- `ensureTH2FileLoaded(path)` gets or creates the controller with `getTH2FileEditController(filename: path)`. If that controller is neither loaded nor loading and has no `loadError`, it calls `load()` without awaiting it. It catches the rethrown error so the unawaited future never surfaces as an unhandled async error; `loadError` already records it. It does nothing else: no `addFileTab`, no tab activation, no project-node selection, no dirty state. Because `load()` caches its future and the controller is found by path, calling it any number of times causes at most one parse per controller instance.
- The next rebuild sees either the new controller with `isLoading == true` or a loaded one, so the path is not scheduled again. A failed load sets `loadError`, so the path is not scheduled again and the load is never retried automatically. Retrying is the explicit Reload path (§3.1 item 4).
- Tests must check each of the following:
  - Repeated rebuilds, several rows needing a load in one frame, and a chevron tap together with a post-frame request cause exactly one parse per file.
  - A file row kept expanded across a project reload loads again once its row is visible.
  - While a filter is active, no file loads: neither a file shown only through filter auto-expansion nor an expanded file with no controller. After the filter is cleared, the expanded file loads once.

## 6. Element rows and labels

Add `lib/src/auxiliary/th2_element_tree_aux.dart` to build rows and labels from a loaded valid `TH2File`.

The builder walks only direct top-level children of the file and direct children of each `THScrap`:

- file children: `THScrap` rows;
- scrap children: `THPoint`, `THLine` and `THArea` rows;
- all other children are hidden but remain in their source-order slots.

Do not recurse into lines or areas. Their segments, options, border references and closing elements move with their owner in later phases but are not tree rows.

### 6.1 Scrap expansion

Scrap rows can be collapsed; point, line and area rows cannot. The parent plan's Phase 4 drop zones (§4.3: "lower third of an **expanded** scrap row", auto-expanding a collapsed scrap on drag hover) depend on this, so Phase 3 builds it now.

- **Scraps start expanded.** Expanding a file shows its whole drawing order at once. Only the exception is stored: `THProjectTreeUIController` gets `ObservableSet<String> collapsedTH2ScrapIds` with the `@action` `toggleTH2ScrapCollapsed(String scrapRowId)` and the query `isTH2ScrapCollapsed(String scrapRowId)`. The keys are the scrap's row id, `th2el:<canonicalPath>:<mpID>` (§4).
- **The set is separate from `expandedNodeIds`,** so the project-node default-expansion seeding in `_handleProjectRootChanged` never sees TH2 ids. `_handleProjectRootChanged(null)` (project close) clears both sets. Neither set is persisted.
- **Stale keys are harmless.** MPIDs are reassigned when a file loads again, so after Reload or reopening the project every scrap is expanded again. Moves and undo/redo keep MPIDs, so they keep the collapsed state. Stale ids are not pruned. They can never match a new row id, because element MPIDs come from the app-wide, only-increasing `MPGeneralController.nextMPIDForElements()`. That counter resets only in the test-only `MPGeneralController.reset()`, so tests that call it must also clear `collapsedTH2ScrapIds` (and `expandedNodeIds`) between cases.
- **Row model.** The builder sets `isExpandable` to true only for `THScrap` rows. It sets `isExpanded` from `!isTH2ScrapCollapsed(rowId)`, or to `true` when the filter forces the scrap open (§7). It emits a collapsed scrap's child rows only when the filter forces it open.
- **Chevron.** A scrap row's chevron toggles `collapsedTH2ScrapIds` and nothing else: no selection change, no active-scrap change, no tab activation. Tapping the scrap label keeps its §8 behavior (make the scrap active). PLA rows keep the same leading space as the chevron, so labels line up, as project leaf rows already do.
- **Key convention.** Scrap chevrons use `ValueKey('TH2ElementTreeScrapChevron|<rowId>')`, following the existing `THProjectTreeNodeChevron|<id>` convention.

### 6.2 Labels

Every element and scrap row uses one rule: **localized kind, localized type[:subtype] (points, lines and areas only), then the Therion id, if any, exactly as stored.**

- **Kind:** `MPTextToUser.getElementType(elementType)`.
- **Type and subtype:** the existing helpers `getPointTypeSubtypeFromPoint`, `getLineTypeSubtypeFromLine` and `getAreaTypeSubtypeFromArea`. They already localize and join type and subtype with `mpPLATypeSubtypeSeparator`. Scraps have no type part.
- **Therion id:** a scrap's `thID`, which is always present. For a point, line or area, the value of its `-id` option (`THIDCommandOption.thID`) when it has one; otherwise nothing.
- **Examples** (the helpers decide the exact text and case): a line `line wall:blocks w12`, where `w12` is muted; a point without `-id`, `point station`; a scrap `scrap s1`, where `s1` is muted.

**Therion ids are free form and shown verbatim.** Therion and Mapiah accept almost any id, so the tree never validates, normalizes, truncates (other than the row's normal ellipsis), quotes or escapes an id. It never generates or assigns one, and in particular it never calls `TH2File.getNewTHID` just to label a row. Mapiah's existing id-generation patterns (`mpScrapTHIDPrefix`, `mpAreaTHIDPrefix`, `mpLineTHIDPrefix`, the paste and split/merge prefixes) stay where they are and run only when an editing operation needs an id. An element without `-id` just has no id in its label. Several identical rows such as `line wall` are expected; their position shows drawing order, and selection sync (§8) identifies them.

**Presentation.** The row uses a `Text.rich` with two spans: kind and type[:subtype] in the normal row style, then a single space and the id in a muted style (`colorScheme.onSurfaceVariant`). There is no `id=` prefix, because it looks like Therion syntax but is not, and no brackets, because ids can contain brackets themselves. The colour alone sets the id apart, so no label template or separator word is added to the `.arb` files. The row's text, used for filtering (§7) and semantics, is the plain concatenation `<kind> <type[:subtype]> <thID>`, with empty parts and their spaces left out.

**Out of scope for Phase 3:** the station point `-name` option (for example a station `1.3`), `label`/`remark` point text, and any other option values. The parent plan's Phase 5 adds station names and label/remark text as an extra detail part between the type and the id. Phase 3 keeps the label builder and the `Text.rich` spans easy to extend with it.

**Icons.** Rows reuse icons Mapiah already has:

| Row | Icon |
|---|---|
| scrap | `Icons.map_outlined`, the icon `THProjectTreeNodeIconWidget` already uses for `THScrapNode` |
| point | `assets/icons/add_element-addPoint.png` |
| line | `assets/icons/add_element-addLine.png` |
| area | `assets/icons/add_element-addArea.png` |

The three PNGs are the ones the last-used PLA buttons show, and today their paths are only in the private `_buttonIconPath` in `th2_file_edit_last_used_pla_buttons_widget.dart`. Phase 3 moves them to `mp_constants.dart`, next to the existing `mpScrapButtonImagePath`, as `mpAddPointButtonImagePath`, `mpAddLineButtonImagePath` and `mpAddAreaButtonImagePath`. Both widgets use the constants. The row draws a PNG with `Image.asset` at `mpSmallIconSize` × `mpSmallIconSize`, and the scrap icon with `Icon` at `mpSmallIconSize`, so every row's icon slot has the same width. Icons are decorative and wrapped in `ExcludeSemantics`, because the label already names the element kind. Phase 7 of the parent plan replaces the point, line and area icons with type previews in the same slot.

Do not hardcode user-facing strings or use all-caps labels; any new strings go in the `.arb` files as described in §9.1.

### 6.3 Drawing-order tooltip

The header receives a tooltip (`th2ElementTreeDrawingOrderTooltip`, §9.1) explaining that the first row is drawn first and the last row is drawn last/on top according to XTherion file order. This is a file-order explanation only; it must not claim to represent Therion's symbol-class rendering order.

## 7. Filtering

Filtering inside a file extends the rule the project tree already has and tests (`t3881`, "filter matching an ancestor hides non-matching descendants"). While a filter is active, a row is shown only if its own label matches or one of its descendants matches. Matching a parent never shows its non-matching children. The project parser is not changed, and no temporary `THProjectNode`s are injected into the project model.

**Matching rule for TH2 rows:**

- A **file that matches by its own label** shows only its file row. Its element rows appear only if some of them match too.
- A **scrap that matches by its own label** shows only its scrap row. Its children appear only if they match.
- A **matching element** shows itself and its scrap and file ancestors. The scrap is shown expanded even when it is in `collapsedTH2ScrapIds`, and the file even when it is not in `expandedNodeIds` (§6.1).
- **Only loaded, valid files** contribute element matches. An unloaded, loading, load-error or broken file can match only by its existing project-node label.

**One matching function.** `THProjectTreeUIController.matchesFilter(THProjectNode node)` is split so that it calls a new `matchesFilterText(String label)`: case-insensitive substring match against the full row label, the same text the row displays (§6). Element and scrap rows call `matchesFilterText` directly, so project rows and TH2 rows cannot disagree about what matches.

**Filter-aware callback.** The §5 callback takes the filter state and reports whether anything matched:

```dart
({List<THProjectTreeVisibleRow> rows, bool hasMatch}) th2ElementRowsFor(
  TH2FileNode node,
  int depth, {
  required bool filterActive,
});
```

- With the filter inactive it behaves as §5 describes, and `hasMatch` is ignored.
- With the filter active, `rows` holds only the matching element rows and their scrap ancestors, and `hasMatch` says whether any element or scrap matched.
- `_collectSubtreeMatches` treats `hasMatch == true` as a matching descendant of the `TH2FileNode`, so the file row and all of its project ancestors stay visible.
- Each file's result is computed at most once per build and kept in a local map for that build. Subtree matching and row output therefore do not build a file's labels twice.

**No status rows and no loads while filtering:**

- Loading, load-error and broken status rows are hidden while a filter is active; they are not matches. The file row still appears, with its broken badge if it has one, when the file's own label matches.
- No load is triggered while a filter is active. This includes a file row in the user's expansion set that has no controller, for example after a project reload. The §5 "needs a load" rule applies only when the filter is inactive. Loading resumes on the first build after the filter is cleared.

**Label cache.** `th2_element_tree_aux.dart` caches each file's row labels, keyed by controller identity, `structureRevision` and locale. A controller replaced by Reload, a structural, type, subtype or id edit that bumps `structureRevision`, or a locale change each invalidate the cache. The existing `mpProjectTreeFilterDebounceMilliseconds` debounce limits how often filtering rebuilds.

**Expansion state is never written by filtering.** Auto-expanded files and scraps are computed per build. Nothing is added to or removed from `expandedNodeIds` or `collapsedTH2ScrapIds`, so clearing the filter restores the previous view exactly, as the existing "clearing filter restores the prior manual expansion state" test requires for project nodes. Chevron taps during filtering still toggle the stored state, as they do for project nodes today. Selection highlight and the "contains selection" dot behave as §8 describes.

## 8. Selection synchronization

### Tree to canvas

**Single source of truth.** Each file's element-row highlight is that file's own `TH2FileEditController.selectionController` selection. This is true whether or not the file has a tab. The tree keeps no selection or highlight state of its own for element rows. A tree tap therefore writes the same selection the canvas uses, and a tab that opens later shows exactly what the tree showed.

Every tap on a PLA element row of a loaded valid file first applies the selection to that file's controller:

1. `setActiveScrapByChildElement(element)`;
2. `selectionController.setSelectedElements(<THElement>[element], setState: true)`. This clears the previous selection of that file and moves its state machine to the non-empty-selection state, the same way programmatic selection works elsewhere.

Then, depending on the file and the gesture:

- **Open file (has a tab), single tap:** activate the tab with `addFileTab(path)` and apply the selection. The canvas shows it right away.
- **Open file, double tap:** as a single tap, then `requestZoomToFit(MPZoomToFitType.selection)` (see below).
- **Tab-less file, single tap:** apply the selection only. No tab is opened or activated, and nothing is dirtied. The row is highlighted because the highlight reads the controller's selection.
- **Tab-less file, double tap:** apply the selection, `addFileTab(path)` to open and activate the tab, then `requestZoomToFit(MPZoomToFitType.selection)`. The new tab shows the selection and the correct active scrap from its first frame.
- **A row in a broken, loading or load-error state** never attempts selection.
- **Scrap rows** only highlight when the active scrap changes, through `setActiveScrap`. Selecting a whole scrap from the tree is out of scope for this phase.

Selection is not a data change: it creates no command and does not affect dirty state.

**Zooming a tab that may not have a size yet.** Right after `addFileTab`, the new tab's `TH2FileWidget` has not been laid out. `_screenSize` is still unset, and on its first layout the `LayoutBuilder` calls `zoomToFit(MPZoomToFitType.file)` while `canvasScaleTranslationUndefined` is true. That would override any selection zoom made earlier. `TH2FileEditController` therefore gets `requestZoomToFit(MPZoomToFitType type)`:

- If the controller already has a non-empty screen size and a defined canvas transform, it calls `zoomToFit(zoomFitToType: type)` immediately.
- Otherwise it stores `type` in a private pending-zoom field. This field is plain, not observable, because only layout reads it.
- In `TH2FileWidget`'s `LayoutBuilder`, after `updateScreenSize(...)`, a pending zoom is consumed first and used in place of the default `MPZoomToFitType.file` zoom. The pending field is then cleared. The existing zoom-to-file on first layout applies only when no zoom is pending.
- A pending selection zoom whose selection has since become empty falls back to the existing zoom-to-file behavior, because `zoomToFit` with an empty selection does nothing.

Use the canonical path (§3.1 item 5) and MPID to resolve the controller. Do not treat a tree row as a `THProjectNode`.

### Canvas to tree

For each expanded, loaded, valid file, the highlighted element rows are the MPIDs in that file controller's `selectionController.mpSelectedElementsLogical`, an `ObservableMap`. Each row reads it in its own `Observer` (see "Row-scoped observers" below), not the tree `Observer`. This applies to the active tab, inactive tabs and tab-less files alike. Selection highlighting must not reorder rows or change expansion state.

A collapsed file shows no element highlight. A collapsed scrap is never expanded to reveal a selection. If any of its children is selected in that file's controller, the scrap row shows a "contains selection" dot instead. The dot is the size of the existing project-tree status dots, uses the selection color, has the key `TH2ElementTreeScrapContainsSelectionDot|<rowId>` and has a tooltip and semantics label from `th2ElementTreeScrapContainsSelection` (§9.1). The dot is derived from the same `mpSelectedElementsLogical` read as the row highlight, so it clears or moves with the selection. A selected element in a scrap other than the active one is still highlighted on its row; changing the active scrap is handled by existing canvas behavior. The project-node highlight (`activeSelectedNodeId`) is independent and may be visible at the same time as element-row highlights.

### Row-scoped observers

`ListView.builder` builds rows lazily, during layout, outside the tree `Observer`'s builder, so a value read while a row builds is not tracked by the tree `Observer`. Computing highlights during flattening would work, but then every selection change (a selection-window drag, repeated shift-clicks) would rebuild and re-flatten every row, although the rows and their order have not changed. Therefore:

- **The tree `Observer` tracks structure only:** which rows exist, their order, and expansion (project expansion, `collapsedTH2ScrapIds`, `isFileLoaded`, `isBroken`, `loadError`, `structureRevision`, `th2ControllersRevision` and the filter). It never reads selection or the active scrap.
- **Each row wraps only its changing parts in its own `Observer`:**
  - element rows: the selected background, from `selectionController.mpSelectedElementsLogical.containsKey(elementMPID)`;
  - scrap rows: the active-scrap highlight (`activeScrapID == elementMPID`) and, when the scrap is collapsed, the "contains selection" dot. The dot checks whether any selected element's parent is this scrap, looping over the selection rather than the scrap's children;
  - TH2 file rows in `THProjectTreeNodeWidget`: the broken badge (`isBroken`, `problems`, `loadError`). The badge then also updates while the file row is collapsed and the flattener does not read that controller, for example when the file's tab loads it as broken.
- **Resolve the controller inside the row's `Observer` builder** with `getTH2FileEditControllerIfExists(th2FilePath)` on every build (§3.1 item 3), and never keep it in the row. That call reads `th2ControllersRevision`, so the row stays correct after Reload, disposal, or a controller kept when its tab closes (§3.2). When the controller is missing or not loaded, the row shows no highlight, no dot and no badge.
- **The row shell** (indentation, chevron, icon, label, gestures, context menu) stays outside the `Observer`, so a selection change repaints only the background, dot or badge.

Only the visible rows are built, so a selection change rebuilds a few dozen small widgets. MobX's `ObservableMap` may notify every observer on any change rather than per key; at this row count that is acceptable, and no per-row `computed` is added.

## 9. Widget structure

Create `TH2ElementTreeRowWidget` for element and status rows, or use two private widgets behind that public name. It must support:

- the existing project-tree row height and indentation constants;
- PLA/scrap icons and localized labels;
- a collapse chevron on scrap rows and the "contains selection" dot on collapsed scraps (§6.1, §8);
- selected-row background matching the project row;
- row-scoped `Observer`s for the selection background, active-scrap highlight, "contains selection" dot and broken badge (§8, "Row-scoped observers");
- loading/error/broken status affordances;
- a broken badge on the file row with problem count and a tooltip containing the first problems;
- a right-click context menu with Reload for broken and load-error files (§9.2).

Keep ordinary project node rendering in `THProjectTreeNodeWidget` unless a small shared row shell reduces duplication. The refactor must preserve compiler-error dots, dirty dots, text-editor opening, project-node selection and the current empty-project UI.

### 9.1 Localization

Phase 3 adds its own EN/PT strings; it does not defer them to Phase 6 (documentation and remaining localization). Every user-visible string introduced by this phase goes in `lib/l10n/intl_en.arb` and `lib/l10n/intl_pt.arb`, followed by `flutter gen-l10n`. Widgets read the strings through `AppLocalizations`, and code without a `BuildContext` uses `mpLocator.appLocalizations`. Each entry has an `@key` description ending in `Used on: <Class>.<method>`, like the existing entries. PT uses Brazilian Portuguese ("arquivo", not "ficheiro").

| Key | EN | PT | Used by |
|---|---|---|---|
| `th2ElementTreeLoading` | `Loading…` | `Carregando…` | loading status row |
| `th2ElementTreeLoadError` | `Could not load this file` | `Não foi possível carregar este arquivo` | load-error status row |
| `th2ElementTreeBrokenFile` | `Broken file: fix it outside Mapiah and reload` | `Arquivo com problemas: corrija-o fora do Mapiah e recarregue` | broken status row |
| `th2ElementTreeBrokenBadgeTooltip` | `{count, plural, one {1 problem} other {{count} problems}}` | `{count, plural, one {1 problema} other {{count} problemas}}` | first line of the broken badge tooltip |
| `th2ElementTreeProblemLine` | `Line {lineNumber}: {detail}` | `Linha {lineNumber}: {detail}` | one problem line in the badge tooltip |
| `th2ElementTreeMoreProblems` | `{count, plural, one {…and 1 more} other {…and {count} more}}` | `{count, plural, one {…e mais 1} other {…e mais {count}}}` | last badge tooltip line when problems are truncated |
| `th2ElementTreeReload` | `Reload` | `Recarregar` | context menu of broken and load-error file and status rows |
| `th2ElementTreeScrapContainsSelection` | `Contains selected elements` | `Contém elementos selecionados` | tooltip and semantics label of the collapsed-scrap selection dot |
| `th2ElementTreeDrawingOrderTooltip` | `Rows are in file order: the top row is drawn first (bottom of the stack) and the last row is drawn last (on top).` | `As linhas seguem a ordem do arquivo: a primeira é desenhada primeiro (embaixo) e a última é desenhada por último (em cima).` | tree header tooltip |

Rules:

- Element labels are built only from the existing `MPTextToUser` kind and type/subtype strings plus the element's Therion id shown verbatim (§6.2). The id is set apart by a muted span, not by a separator word, so labels need no new `.arb` entry.
- The number of problems shown in the badge tooltip before `th2ElementTreeMoreProblems` is a new constant in `mp_constants.dart` (`mpTH2ElementTreeBadgeTooltipMaxProblems`), not a magic number.
- `problem.detail` is shown as the parser produced it. `TH2FileProblemKind.parseError` uses the same `problems` list as structural problems, so parser errors are included in the broken count and tooltip exactly once. Localizing parser details is out of scope for this phase.
- The strings that Phase 1 hard-coded in `TH2BrokenFileBodyWidget` (the explanatory sentence, `Line …:` and `Reload`) are not changed in Phase 3. Phase 6 localizes them and should reuse `th2ElementTreeProblemLine` and `th2ElementTreeReload` where the wording matches.
- No all-caps text. Help pages and the keyboard-shortcuts page are not changed in this phase; Phase 6 covers them.

### 9.2 Row context menu

Mapiah has no context menus yet; the only menu is the overflow `PopupMenuButton` in `th2_file_tabs_page.dart`. Right-drag pans the canvas, but right-click is unused in the project tree. Phase 3 introduces the pattern that Phase 4 extends with the parent plan's §4.8 actions, including the "Move to scrap… ▸" submenu.

- **Widget: `MenuAnchor`.** `showMenu`/`PopupMenuButton` cannot nest submenus, which Phase 4 needs. `MenuAnchor` supports `SubmenuButton` and keyboard navigation inside an open menu, and it opens at the pointer with `MenuController.open(position:)`.
- **One shared wrapper.** A new stateful `THProjectTreeRowContextMenuWidget` (`lib/src/widgets/th_project_tree_row_context_menu_widget.dart`) owns the `MenuController` and takes `rowId`, `child` and `List<Widget> Function() menuChildrenBuilder`.
  - It opens on `onSecondaryTapUp`, at the pointer position.
  - The builder runs when the menu opens, not when the row builds, so the items reflect the state at that moment.
  - When the builder returns an empty list, right-click does nothing; an empty menu is never shown.
  - `THProjectTreeNodeWidget` wraps TH2 file rows with it, and `TH2ElementTreeRowWidget` wraps status rows (and element rows in Phase 4).
- **Gesture: right-click only.** Mapiah ships only on desktop (`release-targets.md`), so there is no long-press variant.
  - Right-click opens the menu and has no other effect: it does not select the project node, open or activate a tab, or change the element selection, matching the chevron's side-effect-free rule (§5). Whether right-clicking an element row also selects it is a Phase 4 decision.
  - Opening the menu from the keyboard (Shift+F10, the Menu key) is out of scope, because the tree has no keyboard-focus model yet.
- **Phase 3 contents:**

  | Row | Condition | Items |
  |---|---|---|
  | TH2 file row | controller `isBroken` or `loadError != null` | Reload |
  | broken or load-error status row | always | Reload |
  | any other row (project nodes, valid or loading TH2 files, element rows) | — | none; right-click does nothing |

- **Reload action.** A `MenuItemButton` labelled `th2ElementTreeReload` (§9.1) with `Icons.refresh`.
  - It calls `MPGeneralController.reloadTH2File(path)`, the same path as the Reload button in `TH2BrokenFileBodyWidget`, with the canonical path (§3.1 item 5).
  - It catches and logs the error that `load()` rethrows (§3.1 item 4); the new controller's `loadError` row already shows it, so it is never an unhandled async error.
  - No unsaved-changes prompt is needed: Reload is offered only for broken or failed files, which cannot be edited and so are never dirty.
- **Keys:** `ValueKey('THProjectTreeRowContextMenu|<rowId>')` on the wrapper and `ValueKey('THProjectTreeRowContextMenuReload|<rowId>')` on the Reload item, following the existing `THProjectTreeNode…|<id>` convention.

## 10. Implementation order

1. Apply the remaining §3.1 observability changes on top of the Phase 2 controller/revision/disposal implementation: observable lifecycle fields, `_preParseInitialize` and the Save As write as actions, single-action load commit, `th2ControllersRevision`, `loadError`, the disposed-controller guard in the load-commit and load-error actions, subtype revision bumps, and `_normalizeFilename` delegating to `THProjectPathResolver.canonicalize`. Preserve the Phase 2 disposal, tab-less cleanup and revision behavior. Let the MobX watch process regenerate the `.g.dart` files.
2. Fix default expansion to use the shallowest TH2 depth (§3.3), with its t3880 regression test, before any TH2 row can load. Then add the sealed visible-row types and update the flattener with compatibility tests for ordinary project trees.
3. Add `th2_element_tree_aux.dart` and pure row/label tests using valid and broken controller fixtures. Add `collapsedTH2ScrapIds` to `THProjectTreeUIController` and the scrap expansion fields to the row model (§6.1).
4. Refactor `THProjectTreeWidget` to render each row kind and observe loaded-controller state/revisions.
5. Add the file-row chevron, `ensureTH2FileLoaded` and the post-frame load trigger for expanded rows that need a load (§5). Verify that expansion does not open a tab or dirty a file, and that a row kept expanded across a project reload loads again. Then add the §3.2 tab-close rule (`isTH2FileRowExpanded`, the keep-or-dispose decision in `removeFileTab` and `_discardFailedFileLoad`, and `close()` no longer disposing reactions).
6. Add status rows, broken badge, `THProjectTreeRowContextMenuWidget` with the Reload action for broken and load-error files (§9.2), and load-error handling based on `loadError`.
7. Split `matchesFilter` to add `matchesFilterText`. Add the filter-aware callback result, `hasMatch` in `_collectSubtreeMatches`, the per-build result map and the label cache (§7). Add the drawing-order tooltip.
8. Add `requestZoomToFit` and the pending-zoom handling in `TH2FileWidget`. Then wire tree-to-canvas selection through each file's own selection controller, and canvas-to-tree highlighting through row-scoped `Observer`s, including tab-less files and double-click zoom (§8).
9. Add the §9.1 EN/PT `.arb` entries and the badge constant, run `flutter gen-l10n`, and switch the new widgets to `AppLocalizations`. Do this alongside steps 6–8 rather than as a clean-up, so that no hard-coded strings are ever committed.
10. Run focused tests, `flutter analyze`, and the full test suite. Do not run `build_runner` manually or `dart format`.
11. Add one Phase 3 entry to the current unreleased section of `CHANGELOG.md` (under "New features"), referencing #32 and listing the new test files. This follows the parent plan rule that every phase ends with its own CHANGELOG entry.

## 11. Expected files

| Area | Files |
|---|---|
| Row model/flattening | `lib/src/auxiliary/th_project_tree_flatten_aux.dart`, possibly a new visible-row model file |
| TH2 row builder | new `lib/src/auxiliary/th2_element_tree_aux.dart` |
| Tree UI state | `lib/src/controllers/th_project_tree_ui_controller.dart` (`collapsedTH2ScrapIds`, `toggleTH2ScrapCollapsed`, `isTH2ScrapCollapsed`, clearing on project close; `matchesFilterText` split out of `matchesFilter`; §3.3: shallowest-TH2-depth seeding) and its regenerated `.g.dart` file |
| Widgets | `lib/src/widgets/th_project_tree_widget.dart`, `lib/src/widgets/th_project_tree_node_widget.dart`, new `lib/src/widgets/th2_element_tree_row_widget.dart`, new `lib/src/widgets/th_project_tree_row_context_menu_widget.dart`, `lib/src/widgets/th2_file_widget.dart` (consume a pending zoom on first layout), `lib/src/widgets/th2_file_edit_last_used_pla_buttons_widget.dart` (use the new icon path constants, §6.2) |
| Controllers | `lib/src/controllers/th2_file_edit_controller.dart` (§3.1: observable `_isFileLoaded`/`_isBroken`/`_problems`, `_preParseInitialize` and the Save As write as actions, single-action load commit, `_loadError` capture, disposed-controller guard; §3.2: `close()` no longer disposing reactions; §8: `requestZoomToFit` and its pending-zoom field), `lib/src/controllers/mp_general_controller.dart` (§3.1: `_th2ControllersRevision` and `_normalizeFilename` delegation; §3.2: keep-or-dispose decision in `removeFileTab`; §5: `ensureTH2FileLoaded`), `lib/src/controllers/th2_file_edit_element_edit_controller.dart` (§3.1 item 7: subtype revision bumps), `lib/src/controllers/th_project_tree_ui_controller.dart` (§3.2: `isTH2FileRowExpanded`), `lib/src/pages/th2_file_tabs_page.dart` (§3.2: `_discardFailedFileLoad`), their regenerated `.g.dart` files, selection controller files only if an adapter is required. Preserve the Phase 2 disposal and tab-less cleanup code. |
| Text/icon helpers | existing `mp_text_to_user.dart` and `th_project_tree_node_icon_widget.dart`, only where reuse requires a small extension |
| Tests | `test/t3880_th_project_tree_ui_controller_test.dart`, `test/t3881_th_project_tree_flatten_test.dart`, `test/t3883_th_project_tree_widget_test.dart`, new `test/t3942_th2_element_tree_rows_test.dart`, new `test/t3943_th2_element_tree_widget_test.dart`, new `test/t3944_th2_controller_lifecycle_observability_test.dart` |
| Localization | `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb`, generated `lib/src/generated/i18n/` files from `flutter gen-l10n`, `lib/src/constants/mp_constants.dart` (`mpTH2ElementTreeBadgeTooltipMaxProblems`; the icon paths `mpAddPointButtonImagePath`, `mpAddLineButtonImagePath` and `mpAddAreaButtonImagePath`, §6.2) |
| Changelog | `CHANGELOG.md` (one Phase 3 entry referencing #32) |

Do not edit generated `.g.dart` files manually. If the MobX watch process regenerates them after an annotated source change, include only the required generated diff.

## 12. Tests and acceptance criteria

### Controller observability tests (`t3944`)

- A MobX `reaction` on `isFileLoaded` fires once when a valid load completes, and once when a broken load completes. In the broken case `isBroken` is `true` and `problems` is non-empty when the reaction runs.
- A broken file whose parser reports a `parseError` exposes that diagnostic in `problems`, the broken count and the tooltip exactly once; parser-error strings returned for the existing tab error dialog are not double-counted.
- A `reaction` on `structureRevision` fires once per load and sees `isFileLoaded == true` and the final `isBroken`/`problems` values.
- `th2ControllersRevision` changes when `getTH2FileEditController` creates a controller, `removeFileController` removes one, `renameFileController` moves one, `disposeTablessTH2Controllers` disposes one, and `reloadTH2File` replaces one. It does not change when `getTH2FileEditController` returns an existing controller.
- A reaction that reads `getTH2FileEditControllerIfExists(path)` re-runs after the controller for `path` is created, reloaded or removed.
- Save As still leaves `isFileLoaded == true` with no MobX action-policy error.
- Calling `load()` on an existing, unloaded controller while a reaction observes its `isLoading` raises no MobX action-policy assertion.
- A controller disposed while its load is still running (for example by `disposeTablessTH2Controllers`) commits nothing when the parse ends: `isFileLoaded`, `isBroken`, `problems` and `structureRevision` are unchanged, and no reaction is registered after disposal. The same holds when the load throws after disposal: `loadError` stays `null`, and the rethrown error is not unhandled.
- Setting or removing only a subtype option bumps `structureRevision` once, and so does undoing it. Changing another non-id option does not bump it.
- When `_loadOnce` throws (for example through an injected failing parse or initialization step):
  - `loadError` is set, `isLoading` is `false` and `isFileLoaded` is `false`;
  - the future returned by `load()` completes with that error;
  - a second `load()` returns the same failed future without parsing again;
  - a reaction on `loadError` fires once.
- After a failed load, `reloadTH2File` produces a new controller with `loadError == null` that loads normally.
- `isTH2FileRowExpanded` is `true` only for a project TH2 file whose `TH2FileNode` id is in `expandedNodeIds`, and `false` with no project or for a file outside the project.
- `_normalizeFilename` still returns empty and `mpNewFilePrefix…` names unchanged. For real paths, including relative ones and ones with `./` and `../` segments, it returns the same string as `THProjectPathResolver.canonicalize(p.absolute(path))`.

### Default expansion tests (`t3880`)

- With the §3.3 tree, where a deeper `.th2` comes first in walk order, seeding expands `main.thconfig`, `cave.th` and `north.th`, and expands neither `north.th2` nor `cave.th2`.
- No seeded expansion set ever contains a `TH2FileNode` id, whatever the order of the project's children.
- The existing default-expansion tests pass unchanged.
- Opening that project in the widget tree parses no `.th2` file until the user expands one (`t3943`).

### Pure row/flattening tests (`t3942`)

- Valid files produce file → scraps → PLAs in exact source order.
- Areas are included even though they are not drawable children.
- Only scrap rows are expandable, and scraps are expanded by default. A collapsed scrap emits no child rows and does not change the order of the other rows.
- With the filter active, a collapsed scrap containing a match is emitted as expanded with only the matching rows, and `collapsedTH2ScrapIds` is unchanged.
- Comments, empty lines, settings, images, line segments and `end*` elements are excluded.
- Labels:
  - A scrap row is kind plus its `thID`.
  - A point, line or area with `-id` is kind plus type[:subtype] plus its id.
  - One without `-id` is kind plus type[:subtype] only.
  - A point's station `-name` never appears.
- Ids with unusual characters (dots, dashes, brackets, `@`, non-ASCII) appear exactly as stored.
- Building labels never changes the file: element count, options and `getNewTHID` state are the same before and after.
- The plain row text used for filtering equals the concatenation of the displayed spans, so filtering by a Therion id or by a localized kind or type name finds the row.
- A broken file produces only one broken status row.
- Loading and load-error states produce exactly one corresponding status row.
- Element row ids include canonical path and MPID and remain distinct across files.
- For a project TH2 file referenced with `./` and `../` segments, the path in its row ids, its `TH2FileNode.absolutePath` and the `MPGeneralController` key of its controller are the same string.
- A file that matches only by its own label shows its file row and no element rows.
- A matching element shows its scrap and file rows, even when the scrap is collapsed or the file is not in the expansion set.
- A scrap that matches by its own label hides its children that do not match.
- `hasMatch` keeps the file's project ancestors visible.
- An unloaded file matches only by its project-node label and is not loaded. Loading, load-error and broken status rows are hidden while filtering.
- Clearing the filter restores both `expandedNodeIds` and `collapsedTH2ScrapIds` exactly.
- The label cache is reused when nothing changed, and rebuilt after a `structureRevision` change, a controller replacement or a locale change.
- Existing project-node filtering and expansion behavior remains unchanged: `t3881` passes unmodified apart from the new row types.
- `matchesFilterText` gives the same result as `matchesFilter` for project-node labels.

### Widget tests (`t3943` and updated `t3883`)

- A file row always has an expansion affordance.
- Expanding requests one lazy load, creates no tab, changes no dirty state, and displays Loading before completion.
- Repeated rebuilds and a chevron tap plus a post-frame request cause exactly one parse per file.
- A TH2 file row kept expanded across a project reload (its controller disposed) shows Loading and loads again once, without opening a tab.
- While a filter is active, no file loads: neither a file shown only through filter auto-expansion nor an expanded file with no controller. After the filter is cleared, the expanded file loads once.
- A valid load displays rows and the broken badge is absent.
- A broken load displays the badge/count and status row, never element rows, and offers Reload.
- Reload replaces the controller and updates the row state after the future completes.
- Right-clicking (`tester.tap(..., buttons: kSecondaryButton)`) a broken file row and its status row shows Reload, and so does a load-error file row and its status row.
- Right-clicking a valid TH2 file, a loading TH2 file, an element row or an ordinary project node opens no menu.
- Right-clicking never opens or activates a tab, selects the project node, or changes the element selection.
- Choosing Reload from the menu replaces the controller, and the rows update. A Reload whose load fails again shows the load-error row, with no unhandled exception.
- A load that throws shows exactly one load-error row, schedules no further load requests across rebuilds, and offers Reload. Reload then shows the real state (element rows or broken). Opening that file's tab still shows the existing load-failure error dialog.
- Tapping an element in an open file activates its tab, selects it and activates its scrap; double-tap zooms to the selection.
- Tapping a tab-less element sets that controller's selection and active scrap and highlights the row. It opens no tab and changes no dirty state or active tab index.
- Double-tapping a tab-less element opens and activates the tab. The canvas shows the element selected with its scrap active, and the first layout zooms to the selection, not to the whole file.
- `requestZoomToFit` on a controller that is already laid out zooms immediately. With an empty selection it falls back to the default zoom-to-file on first layout.
- Canvas selection highlights the corresponding row and clears/moves the highlight when selection changes. The highlight in a tab-less or inactive-tab file follows that file's own selection.
- A canvas selection change updates the highlight of a visible element row without re-flattening: the `th2ElementRowsFor` callback count does not change.
- A collapsed TH2 file row shows the broken badge after its tab loads the file as broken, without the row being expanded.
- A scrap row's active highlight follows `setActiveScrap`, made from the canvas or from a tree tap.
- After Reload replaces a controller, row highlights read the new controller and show no stale selection.
- A scrap chevron appears on scrap rows only. Tapping it collapses or expands just that scrap, without changing selection, active scrap or tab.
- Collapsed state survives undo/redo and resets to expanded after Reload. Closing the project clears it.
- A canvas selection inside a collapsed scrap shows the "contains selection" dot without expanding the scrap. The dot clears when the selection is cleared or moves elsewhere.
- Undo/redo changes the visible order after `structureRevision` changes.
- Changing only an element's subtype updates its row label.
- Closing the tab of a file whose row is expanded and that has no unsaved changes keeps the same controller instance, tab-less and still working: no second parse, the same MPIDs, collapsed scraps and selection kept, and the row highlight still follows canvas selection changes made before closing. `th2ControllersRevision` does not change.
- Closing that tab while the file has unsaved changes, or while its row is collapsed, disposes the controller as before. With the row expanded, the tree then loads the file from disk exactly once.
- Closing or reloading the project still disposes controllers kept this way.
- For an expanded file whose load throws, opening its tab shows the error dialog, and closing it keeps the failed controller. The load-error row stays and no second parse happens. Only Reload retries.
- Each row shows its §6.2 icon: `Icons.map_outlined` for scraps and the add-element PNG for points, lines and areas.
- Existing project-file opening, compiler-error dots, dirty dots and text-editor rows remain green.
- With the PT locale, the loading, load-error and broken status rows, the badge tooltip (including singular/plural and truncation), the Reload menu entry and the header tooltip show the PT strings from §9.1.

### Acceptance

- Users can inspect XTherion file order from the sidebar without opening every file in a tab.
- Tree loading is lazy, idempotent and side-effect free apart from creating the cached tab-less controller.
- Broken files are clearly identified and never expose partially parsed elements.
- Selection state is consistent between the sidebar and canvas for valid open files.
- Every string added in this phase exists in both EN and PT `.arb` files, and no new widget contains a hard-coded user-visible string.
- `CHANGELOG.md` has a Phase 3 entry referencing #32.
- Focused tests, the full test suite and `flutter analyze` pass with no formatting-only churn.
