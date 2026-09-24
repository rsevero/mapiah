<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 3: Read-only Sidebar

**Date:** 2026-09-23  
**Status:** Implemented  
**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md)  
**Prerequisite:** Phase 1 broken-file handling and Phase 2 model/controller revision support. Their code is in place, but their planned tests were never added; §10 step 1 adds them before any Phase 3 change (§3.5).  
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose

Expose the file order of a valid `.th2` file in the project sidebar without adding any editing operation yet. A `TH2FileNode` expands lazily to show scraps and their point, line and area children in the exact order held by `TH2File.childrenMPIDs` and each scrap's `childrenMPIDs`.

This phase provides the read-only row model and the tree-to-canvas selection connection that Phase 4 will use for drag-and-drop and context-menu moves. It must not mutate a file, create an undo command, or open a tab merely because a user expands a file row.

## 2. Scope

### In scope

- Adding the Phase 1 and Phase 2 tests that were never written, before any Phase 3 change (§3.5).
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
- Making default expansion include non-TH2 nodes through the shallowest `.th2` depth, while never autoexpanding a TH2 row (§3.3).

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

   The public read names (`isFileLoaded`, `isBroken`, `problems`) stay the same, so existing field reads need no renaming. Tab controller replacement is handled separately in §3.4.

   **Writes outside actions do not assert, but they are not batched.** In MobX 2.7.0, a generated setter for an `@observable`/`@readonly` field calls `Atom.reportWrite`, which goes through `conditionallyRunInAction`. Outside a batch, that wraps the single write in its own action *before* `enforceWritePolicy` runs (`mobx-2.7.0/lib/src/core/context_extensions.dart`). A write outside an action therefore never triggers the `observed` write-policy assertion. Today's code already writes the observed `_isLoading` outside actions without failing. What such a write does do is end its own one-write action, so reactions run immediately after it, before the next write. Consistency, not the assertion, is why multi-field transitions go through one action (item 2). For the same reason, these two existing writes become actions:
   - `_preParseInitialize` becomes `@action`, so `_isLoading = true` and the `errorMessages` reset form one transition.
   - `saveAsTH2File` is `async` and is not an action, so its `_isFileLoaded = true` and the following `setFilename` move into a small private `@action` (for example `_markLoadedAfterSaveAs()`) called at the same point.

2. **Load results are committed in one action, with the revision bump last.** The existing Phase 2 load path runs `_finalFilePreparations` (which resets `_isLoading`), bumps `structureRevision`, and only then marks the file loaded, while `problems`/`isBroken` are assigned earlier in `_loadOnce`. The bump therefore fires, but a synchronous reaction to it still sees `isFileLoaded == false`. The part of `_loadOnce` after `await parser.parse(...)` moves into one `@action` method that sets `_problems`, `_isBroken`, runs `_finalFilePreparations`, sets `_isFileLoaded = true`, and calls `bumpStructureRevision()` last. Observers then see one consistent transition from loading to loaded, valid or broken. Preserve the existing Phase 2 revision semantics: one load-time bump, one bump per relevant edit/undo/redo, and no bump per parsed element.

3. **Controller membership becomes observable.** `MPGeneralControllerBase` gets `@readonly int _th2ControllersRevision = 0;` and a private `@action` bump. It is bumped whenever the set of TH2 controllers or their keys changes:
   - `getTH2FileEditController` when it creates or force-replaces a controller (not when it returns an existing one);
   - `getTH2FileEditControllerForNewFile`;
   - `removeFileController` when it removed a TH2 controller;
   - `renameFileController` when it moved a TH2 controller;
   - `disposeTablessTH2Controllers` when it disposed at least one controller;
   - the test-only `reset()` when it cleared at least one TH2 controller. An empty reset does not bump the revision.

   These methods become `@action` where they are not already, including `reset()`, so clearing the registry and bumping its revision are one observable transition. `reloadTH2File` is `async`, so its synchronous part (removing the old controller and creating the new one) moves into one private `@action`, called before `await controller.load()`. Observers and reactions then see one change from the old controller to the new one, never an intermediate "no controller" state, and a reaction that reads `getTH2FileEditControllerIfExists(path)` runs once per Reload. `getTH2FileEditControllerIfExists` reads `th2ControllersRevision` before its lookup, so any `Observer` that resolves a controller through it rebuilds after creation, removal, rename, reset or `reloadTH2File`. A counter is preferred to an `ObservableMap` because it keeps the existing `HashMap` and disposal code unchanged.

   Consequences for the tree:
   - Resolve the controller in build with `getTH2FileEditControllerIfExists(path)` every time. Never cache a controller reference in a row or widget, because `reloadTH2File` disposes the old instance.
   - Never create a controller inside an `Observer` build. MobX itself allows the write (it forbids writes only inside computeds, not inside reactions such as an `Observer` build), but the resulting `th2ControllersRevision` bump fails Flutter's build assertion, as the next bullet explains. The lazy-load request (§5) runs from the chevron handler or a post-frame callback.
   - More generally, no registry change may happen while any widget is building. The bump runs the `Observer`s that read `th2ControllersRevision` (the tab-content `Observer` of §3.4 and the tree), and marking them for rebuild during another widget's build fails Flutter's debug assertion ("setState() or markNeedsBuild() called during build") whenever that widget is not their descendant. The existing load-failure path does exactly this and is changed in §3.4.

   **Reload completion must preserve current lifecycle ownership.** The existing `reloadTH2File` remembers `wasOpen` and calls `addFileTab` after `await controller.load()`. Remove that post-load call and its `wasOpen` snapshot: replacing a controller does not remove its tab, and the §3.4 observer already updates an open tab. Reload must neither reopen a tab closed during loading nor activate a tab after the user switches away. A tab-less Reload remains tab-less.
   - After the await, Reload only returns its result or propagates its error; it performs no tab, registry, selection or project mutation. A disposed or superseded controller may finish its future, but completion cannot restore its ownership.
   - If any post-load UI effect is needed during implementation, first verify that the registry still contains the exact replacement controller, the tab still belongs to that load, and, for a project-owned file, the captured `projectEpoch` and `rootConfigPath` still match. Perform the checks and effect synchronously, with no intervening await. A stale completion performs no effect; an old `wasOpen` value is never authorization to open a tab.
   - Cover closing the tab (both retained and disposed controller cases), closing/switching/reloading the project, closing/reopening the same project path, and overlapping Reloads completed in either order. No stale completion may reopen or activate a tab, recreate a controller, or replace the newest controller.

4. **A failed load is recorded.** `TH2FileParser.parse` catches file-read/decode failures and records them through `_addError`; those diagnostics become `TH2FileProblemKind.parseError` entries in `problems`, so an unreadable or structurally invalid file is represented by the same broken-file diagnostic list used by the sidebar. The separate parser-error strings returned by `parse()` remain for the existing tab error dialog and are not counted a second time. `load()` therefore throws only on an unexpected exception (a Mapiah bug in parsing or in `_finalFilePreparations`). Today that leaves `_isLoading` stuck at `true`, the rejected future cached in `_loadFuture`, and no observable state recording the failure. `TH2FileEditControllerBase` gets `@readonly Object? _loadError;`:
   - `load()` wraps `_loadOnce()` in `try/catch`. On an exception it commits one `@action` that sets `_loadError = error` and `_isLoading = false`. `_isFileLoaded` stays `false`, and `_isBroken` and `_problems` are unchanged. The error is logged through `mpLocator.mpLog.e`, then rethrown, so the tab's existing `FutureBuilder` → `snapshot.hasError` → `_handleLoadFailure` path (error dialog, then close) keeps working unchanged.
   - The failed future stays cached in `_loadFuture`, so calling `load()` again on the same controller never parses again. That rules out retry loops across rebuilds.
   - The only way to retry is Reload through `reloadTH2File`, which disposes the failed controller and creates a new one with `_loadError == null`. `th2ControllersRevision` lets the tree see the replacement.
   - An exception is never turned into a broken-file problem. That would present a Mapiah bug as a defect in the user's file and tell them to fix it outside Mapiah.

5. **One definition of "canonical path".** Mapiah has two copies of one rule today: the project side uses `THProjectPathResolver.canonicalize(p.absolute(path))`, and `MPGeneralController._normalizeFilename` uses `p.normalize(File(path).absolute.path)`. Both make the path absolute against the current directory and then normalize it, so they give the same string. `TH2FileNode.absolutePath` is built through `THProjectPathResolver.resolve`, which also normalizes, so it already matches the controller map's keys.
   - **Definition.** In this plan, the *canonical path* of a file is `THProjectPathResolver.canonicalize(p.absolute(path))`: absolute and normalized, with **no** symlink resolution and **no** case folding. For a project TH2 file it equals `TH2FileNode.absolutePath`. Row ids (`th2el:<canonicalPath>:<mpID>`), status-row ids, `collapsedTH2ScrapIds` keys, `ensureTH2FileLoaded(path)` and every controller lookup from the tree use it.
   - **Refactor, no behavior change.** `_normalizeFilename` keeps its special cases (empty names and `mpNewFilePrefix…` names are returned unchanged). For every other name it returns `THProjectPathResolver.canonicalize(p.absolute(filename))` instead of repeating the rule, so the registry and the project tree share one definition.
   - **Deliberately not done.** Symlink resolution fails for missing files, which the project tree shows on purpose, and it would change the paths Mapiah shows, saves to and writes into directives. `THProjectPathResolver.canonicalize` documents this choice. Case folding on Windows and default macOS would change displayed and written paths. It would only fix the pre-existing case where the same file opened with different letter case gets two tabs, which needs case-insensitive *comparison* with the original *display* path kept. That is a separate issue. `MPDirectoryAux`'s image-path rebasing is about relative image paths, not file identity, and is not changed; it already avoids `p.canonicalize` so Windows paths keep their case.

6. **A load that finishes after disposal commits nothing.** Expanding a file row is enough to start a load, and every project reload or close calls `disposeTablessTH2Controllers`, so a controller is often disposed while its parse is still running. Today the load would then run `_finalFilePreparations` on the disposed controller, and its `_initializeReactions()` would register autoruns that nothing ever disposes.
   - The load-commit action (item 2) checks `_disposed` first. If the controller is disposed, it writes no field, registers no reaction, does not bump `structureRevision`, and only returns the result so the future completes.
   - The load-error action (item 4) does the same: a disposed controller does not set `_loadError` or `_isLoading`. `load()` still rethrows, and `ensureTH2FileLoaded` already catches the error.
   - The parser may keep writing into the disposed controller's own `TH2File` until the parse ends. Nothing reads that file afterwards, so this is harmless.
   - **`load()` works only on the registered controller.** `TH2FileParser.parse` is not handed a controller. It resolves its target synchronously, before its first `await`, through `getTH2FileEditController(filename: …, forceNewController: false)`. `load()` therefore parses into whatever controller is registered at that path when it starts. Every Phase 3 path respects this: the tab builder, `ensureTH2FileLoaded` (§5) and `reloadTH2File` all call `load()` on the controller they just read from, or created in, the registry, with no `await` in between. A parse already running keeps the controller it captured, so a Reload or disposal that happens during the parse is handled by the guards above. Never call `load()` on a controller that is not currently registered at its path: the parser would create a new registry entry and fill that one instead.

7. **Subtype edits bump `structureRevision`.** A subtype is stored as a `THSubtypeCommandOption`, and today `executeSetOptionToElement` and `executeRemoveOptionFromElement` in `th2_file_edit_element_edit_controller.dart` bump the revision only for `THCommandOptionType.id`. A subtype changed on its own, for example from the options panel, would therefore leave the row label and the label cache (§7) stale. Both methods also bump for `THCommandOptionType.subtype`. A type-and-subtype edit made through the type commands then bumps more than once inside one command; this is harmless because rows rebuild on the next frame. The rule in item 2 still holds: no bump per parsed element, because `bumpStructureRevision` does nothing while `isLoading`.

### 3.2 Keeping a controller when its tab closes

Closing a TH2 tab calls `TH2FileEditController.close()`, which disposes the controller's reactions and then calls `removeFileTab`, which calls `removeFileController` and disposes the controller. If the file's tree row is expanded, the tree would then find no controller and parse the file again tab-less. The new controller has new MPIDs, so collapsed scraps would expand again and the tree selection would be lost. The failed-load path has the same problem: `_discardFailedFileLoad` in `th2_file_tabs_page.dart` removes the failed controller, the tree loads the file again, and the load that failed is retried automatically, which §3.1 item 4 forbids.

**Rule.** When a TH2 tab closes, its controller is kept, tab-less, if all of these are true:

- the file is a TH2 file of the open project, and the id of its `TH2FileNode` is in `expandedNodeIds`. This is asked through a new `THProjectTreeUIController.isTH2FileRowExpanded(String canonicalPath)`, which returns `false` when there is no project or no `TH2FileNode` with that `absolutePath`. It uses the existing public index `THProjectController.nodeByCanonicalPath`, whose keys are canonical paths (§3.1 item 5) and which already holds `TH2FileNode`s, so no tree walk and no new project-controller API are needed:

  ```dart
  bool isTH2FileRowExpanded(String canonicalPath) {
    final THProjectFileNode? node =
        _projectController.nodeByCanonicalPath(canonicalPath);

    return (node is TH2FileNode) && expandedNodeIds.contains(node.id);
  }
  ```

  `_clearProjectState` clears the index, so with no project the lookup returns `null` and the answer is `false`. While `reloadProject` is parsing, the index still describes the outgoing tree, like `projectRootNode`. Any controller kept during that transition is disposed right afterwards by `disposeTablessTH2Controllers`;
- the controller has no unsaved changes (`!enableSaveButton`, the same value that drives dirty mirroring);
- it is not a new, never-saved file (`mpNewFilePrefix…`).

Otherwise the controller is disposed as it is today. A controller with unsaved changes is disposed because closing its tab discards those changes. Keeping it would show edits that are not on disk, so the tree loads the file again from disk, once.

**Mechanics:**

- `removeFileTab` makes the decision. For a TH2 tab it calls `removeFileController` only when the rule above does not keep the controller. `closeProjectFileTabs` is unchanged: it runs only during project transitions and is followed by `disposeTablessTH2Controllers` for the same paths, so kept controllers are still disposed when the project closes or reloads.
- `close()` no longer calls `_disposeReactions()` itself, so a kept controller stays fully working, including dirty mirroring and the tree's selection sync. `dispose()` already disposes the reactions when the controller is removed. `close()` still clears overlay windows and the pattern cache.
- `_discardFailedFileLoad` still drops its `_fileLoads` entry, but it calls `removeFileController` only when the same rule does not keep the controller. It runs after the frame, never during a build (§3.4). A failed controller kept this way keeps its `loadError`, so the tree keeps the load-error row and nothing retries. Opening the tab again shows the cached failure and the error dialog again. Reload remains the only retry (§3.1 item 4).
- Collapsing the row later does not dispose a kept controller. Tab-less controllers are disposed on project transitions, as in Phase 2.
- `th2ControllersRevision` is not bumped when a controller is kept, because the registry does not change. Removing the tab still updates `openFileOrder` as it does today.

### 3.3 Default expansion never expands TH2 rows

When a project opens with an empty expansion set, default expansion must include every non-TH2 node at or above the shallowest `.th2` depth. TH2 files themselves must never be autoexpanded. The current code differs in two ways: `_expandNodesAboveDepth` excludes nodes at the cutoff depth, and `_firstTH2FileDepth` walks the tree depth first and returns the depth of the first `.th2` file in walk order, which is not always the smallest depth:

```
main.thconfig            depth 0
└─ cave.th               depth 1
   ├─ input north.th     depth 2
   │  └─ north.th2       depth 3   ← reached first → expansion depth 3
   └─ input cave.th2     depth 2   ← shallowest .th2, but expanded
```

`_expandNodesAboveDepth` then expands every node shallower than 3, including `cave.th2`. Today this does nothing, because TH2 file nodes are leaves. In Phase 3 an expanded TH2 row loads automatically (§5), so opening this project would parse `cave.th2` without the user asking.

**Fix.** Replace `_firstTH2FileDepth` with a helper that returns the minimum depth of any `TH2FileNode` in the tree (for example `_shallowestTH2FileDepth`), or `null` when there is none. Update the expansion helper to include non-TH2 nodes whose depth is less than or equal to that minimum, and explicitly skip every `TH2FileNode`. Non-TH2 nodes deeper than the cutoff stay collapsed. In the example, `main.thconfig`, `cave.th` and `north.th` are expanded; `cave.th2` and `north.th2` are visible but collapsed. The behavior for projects without `.th2` files (expand the whole tree) and the rule that seeding runs only when `expandedNodeIds` is empty do not change. Only user or programmatic expansion (§5 item 2) expands a TH2 row.

### 3.4 Replacing the controller of an open tab on Reload

`TH2FileTabsPage._buildTabContentWidget` currently keys `TH2FileEditBodyWidget` by filename. Its state captures the controller in a `late final` field during `initState`, so replacing the controller at the same path preserves a body that still reads the disposed instance. Sidebar Reload must update both the tree and any open tab.

- **Key the body by controller identity.** Replace `ValueKey<String>(filename)` on the TH2 body with `ObjectKey(controller)`. A new controller creates fresh body state, including the controller reference and `_loadFailureHandled == false`. Ordinary rebuilds with the same controller preserve the state. No `didUpdateWidget` controller reassignment is needed, and the text-editor body keeps its existing key.
- **Observe replacement where tab content is built.** Ensure the `Observer` that builds TH2 tab content reads `th2ControllersRevision`, directly or through `getTH2FileEditControllerIfExists(filename)` inside its tracked builder. A read in an untracked deferred builder is insufficient. Reload from the sidebar must rebuild an open tab without relying on the tab body's Reload callback calling `setState` or on the active tab index changing.
- **Keep the existing load-cache identity check.** `_fileLoads[filename]` already compares its controller with the current instance and replaces the cached future when they differ. Retain that behavior so the new body receives the new controller's load future.
- **Handle both Reload entry points.** The tab body's Reload callback must catch and log errors from `reloadTH2File`, just as the sidebar menu does (§9.2), rather than leaving its current `unawaited` future unhandled. The new body's `FutureBuilder` remains responsible for the error dialog and close behavior; the Reload callback must not show a second dialog. A failure is handled once per body/controller instance. The callback's current `setState(() {})` is no longer needed, because the `Observer` sees the replacement.
- **Move load-failure cleanup out of the build.** Today `TH2FileEditBodyWidget._handleLoadFailure` runs inside the `FutureBuilder` builder and calls `widget.onLoadFailed()` synchronously, so `_discardFailedFileLoad` calls `removeFileController` during a build. Once `removeFileController` bumps `th2ControllersRevision` (§3.1 item 3), that marks the tab-content `Observer`, an ancestor of the body, for rebuild during the body's build and fails Flutter's debug assertion. `_handleLoadFailure` keeps setting `_loadFailureHandled` and logging synchronously, but calls `widget.onLoadFailed()` at the start of its existing post-frame callback, before `showDialog`. It is called even when the body is no longer mounted, so the failed load's cleanup is never skipped; only the dialog depends on `mounted`.
- **Cost of observing replacement.** The tab-content `Observer` also builds the sidebar, so each bump rebuilds the workspace: every tab body in the `IndexedStack` plus the tree. Controller creation by a tree load and load completion (the builder reads each tab's now-observable `isFileLoaded`) therefore rebuild the workspace once each. This is expected; the bodies keep their state because their keys do not change. The builder's existing `controller.load()` call now writes `_isLoading` in an action during this build. That is allowed only because every widget observing it, including the tree, is a descendant of this `Observer`. If the sidebar is ever moved outside it, start that load after the frame instead.

Regression coverage must exercise sidebar Reload with an already-open tab, including broken-to-valid, broken-to-broken with changed diagnostics, and an unexpected load exception. Also exercise the tab body's Reload button for the exception case, and a tab whose load throws while its file row is collapsed, so that the failed controller is removed: no build-phase assertion, one error dialog, and the tab closes.

### 3.5 Missing Phase 1 and Phase 2 tests

Phase 1 and Phase 2 code is in place (broken-file detection and body, `reloadTH2File`, `MPMoveElementsCommand`, `TH2HierarchyAux`, `structureRevision`, controller disposal and tab-less cleanup), but the tests their plans require were never added. The Phase 2 commit (`68b95ef4`) has no test files, and only `t3203_ui_reopen_file_after_parse_failure_test.dart` touches this code. Phase 3 changes the load path, disposal and the tab-close rule on top of this code, so the existing behavior must be pinned down first.

Before any Phase 3 change (§10 step 1), add these tests exactly as the earlier plans specify them, against the **current** code:

| Test file | Specification |
|---|---|
| `test/t3939_th2_file_parser_hierarchy_violations_test.dart` | Parent plan, Phase 1 tests (hierarchy violations, unknown types vs. unknown options, no silent drops, plain syntax errors) |
| `test/t3940_th2_broken_file_body_widget_test.dart` | Parent plan, Phase 1 tests (broken panel, no dirty state, Save As disabled, Reload after fixing on disk) |
| `test/t2462_commands_mpmoveelementscommand_test.dart` | Phase 2 plan §7.1 |
| `test/t3941_th2_hierarchy_aux_test.dart` | Phase 2 plan §7.2 |
| existing lifecycle/revision test files, or a focused new one | Phase 2 plan §7.3 (disposal paths, tab-less cleanup, `structureRevision` bumps) |

Rules:

- Rescan `test/` for duplicate numeric prefixes first; the numbers above are still free today.
- These tests describe Phase 1/2 behavior. A test that fails because the code does not do what the earlier plan says is a Phase 1/2 bug. Fix it in the smallest possible change, in its own commit, and record it under "Fixed bugs" in `CHANGELOG.md`. Do not weaken the test to match the code.
- Where Phase 3 later changes a behavior on purpose, update the test in the same step as the change. The known cases are §3.2 (closing a tab whose row is expanded keeps its controller; the Phase 2 §7.3 case "closing a tab disposes its controller" still holds when the row is collapsed) and §3.1 item 4 (a failed load records `loadError`).
- They need their own commit, before the Phase 3 changes, so later regressions are visible.

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

   No row triggers a load while a filter is active, whether it is in the expansion set or shown only through filter auto-expansion (§7). Automatic tree loads also wait while the project controller's `isParsing` is true, so a project reload cannot load files from the outgoing tree retained during parsing. Loading resumes when filtering and project parsing have finished.
3. Do not add a tab and do not select the project node merely because the chevron was tapped.
4. Tapping the file label keeps the existing behavior: select the project node and open/activate its tab.
5. A broken status row opens the file tab; its diagnostic body is responsible for displaying the detailed problems.
6. The context menu (§9.2) of a broken file, or of a file whose load failed, offers Reload on both the file row and its status row. Reload replaces the controller through `reloadTH2File` and offers no element operation. Reload never adds or activates a tab: an existing tab observes the replacement, and a tab-less file stays tab-less (§3.1 item 3).

Load triggering mechanism:

- Flattening stays pure. While building rows, the callback adds the path of each file that needs a load to a per-build set. It never creates a controller or calls `load()`, because doing so inside the `Observer` build would write observables during a derivation (§3.1).
- After the build, if that set is not empty, `THProjectTreeWidget` schedules one post-frame callback, capturing the project's `projectEpoch` and `rootConfigPath` along with the candidate paths. Capturing the epoch is required even when the root path stays the same, because Reload and closing/reopening the same project start a new lifecycle.
- **Revalidate before loading.** For each candidate, immediately before calling `MPGeneralController.ensureTH2FileLoaded(path)`, check that the widget's build context is still mounted, the captured epoch and root path still match the current project, a project root exists, `isParsing` is false, and `filterText` is empty. Resolve the path against the current project tree: it must still belong to a `TH2FileNode`, that node must still be in `expandedNodeIds`, and its project ancestors must still be expanded so the row remains visible. The first two checks are `isTH2FileRowExpanded(path)` (§3.2). For the third, get the node with `nodeByCanonicalPath(path)` and follow its `parent` chain up to the root, as `expandAncestorsOf` does, requiring every ancestor to be in `expandedNodeIds`. Resolve the current controller again and skip it if it is loaded, loading or has `loadError`. Failed checks simply discard the candidate; they never create a controller or schedule a retry. There must be no `await` between these checks and the load request.
- The tree `Observer` reads `projectEpoch`, `isParsing` and the existing tree/filter/expansion signals, so a current build can schedule fresh candidates when the project finishes parsing, a row becomes visible again or filtering ends. An obsolete callback cannot recreate controllers after project cleanup. The chevron handler may request a load directly only when expanding and only through the same eligibility checks, using the current project lifecycle.
- `ensureTH2FileLoaded(path)` gets or creates the controller with `getTH2FileEditController(filename: path)`. If that controller is neither loaded nor loading and has no `loadError`, it calls `load()` without awaiting it. It catches the rethrown error so the unawaited future never surfaces as an unhandled async error; `loadError` already records it. It does nothing else: no `addFileTab`, no tab activation, no project-node selection, no dirty state. Because `load()` caches its future and the controller is found by path, calling it any number of times causes at most one parse per controller instance.
- The next rebuild sees either the new controller with `isLoading == true` or a loaded one, so the path is not scheduled again. A failed load sets `loadError`, so the path is not scheduled again and the load is never retried automatically. Retrying is the explicit Reload path (§3.1 item 4).
- Tests must check each of the following:
  - Repeated rebuilds, several rows needing a load in one frame, and a chevron tap together with a post-frame request cause exactly one parse per file.
  - A file row kept expanded across a project reload loads again once its row is visible.
  - While a filter is active, no file loads: neither a file shown only through filter auto-expansion nor an expanded file with no controller. After the filter is cleared, the expanded file loads once.
  - A project close, switch or reload between scheduling and callback execution invalidates the old request, including closing/reopening the same root path. No controller is created and no parse starts from that request.
  - Collapsing the file or one of its ancestors, removing the file from the current tree, activating a filter, or unmounting the tree before callback execution cancels that request. Restoring eligibility lets a fresh build load the file once.

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

The three PNGs are the ones the last-used PLA buttons show, and today their paths are only in the private `_buttonIconPath` in `th2_file_edit_last_used_pla_buttons_widget.dart`. Phase 3 moves them to `mp_constants.dart`, next to the existing `mpScrapButtonImagePath`, as `mpAddPointButtonImagePath`, `mpAddLineButtonImagePath` and `mpAddAreaButtonImagePath`. Both widgets use the constants. The row draws a PNG with `Image.asset` at `mpSmallIconSize` × `mpSmallIconSize`, and the scrap icon with `Icon` at `mpSmallIconSize`, so every row's icon slot has the same width. Icons are decorative and wrapped in `ExcludeSemantics`, because the label already names the element kind. Phase 8 of the parent plan replaces the point, line and area icons with type previews in the same slot.

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

Every tap on a PLA element row of a loaded valid file first applies the selection to that file's controller. A tree tap does exactly what pressing the canvas Select tool and then clicking the element does, whatever mode the file's state machine is in:

1. `stateController.onButtonPressed(MPButtonType.select)`. The file leaves its current mode exactly as the Select tool makes it leave: the base state handles that button with `selectionController.setSelectionState()`, and the current state's `onStateExit` cleans up. Going through the button path, rather than setting the state directly, also applies any state-specific override of the Select button. This step runs first, so no exit hook can clear the new selection.
2. `setActiveScrapByChildElement(element)`;
3. `selectionController.setSelectedElements(<THElement>[element], setState: true)`. This clears the previous selection of that file and moves its state machine to the non-empty-selection state, the same way programmatic selection works elsewhere.

**Leaving the current mode:**

- **Add line or area.** Leaving the mode calls `finalizeNewLineCreation` or `finalizeNewAreaCreation`. These only clear the in-progress state and refresh derived state. The segments were already committed as commands while the user drew, so ending the creation adds no command and no undo entry.
- **Edit single line, image operations and element rotate** already have exit hooks for a transition to a selection state.
- **Drag states need no guard.** The moving-elements, moving-control-point, selection-window and rotate drags exist only while the mouse button is held down on the canvas, so a tree click cannot happen during one.
- **Tab-less controllers are safe.** An in-progress line or area already has undo entries, so its file is dirty, and §3.2 never keeps a dirty controller tab-less. A tab-less controller, whether kept by §3.2 or loaded by the tree, is at most in an idle creation mode with nothing pending, and leaving that mode changes nothing.

Then, depending on the file and the gesture:

- **Open file (has a tab), single tap:** activate the tab with `addFileTab(path)` and apply the selection. The canvas shows it right away.
- **Open file, double tap:** as a single tap, then `requestZoomToFit(MPZoomToFitType.selection)` (see below).
- **Tab-less file, single tap:** apply the selection only. No tab is opened or activated, and nothing is dirtied. The row is highlighted because the highlight reads the controller's selection.
- **Tab-less file, double tap:** apply the selection, `addFileTab(path)` to open and activate the tab, then `requestZoomToFit(MPZoomToFitType.selection)`. The new tab shows the selection and the correct active scrap from its first frame.

**Tap and double-tap detection.** Every double-tap result above is the single-tap result plus extra steps. The first tap can therefore act at once, and the second tap only adds to it; nothing is ever undone.

- Element rows register only `onTap`, never `onDoubleTap`. With both registered, Flutter holds every single tap until `kDoubleTapTimeout` (300 ms) has passed, which would make every ordinary click in the tree feel slow.
- Each tap first checks whether it completes a double tap: the previous tap was on the same row id, less than `kDoubleTapTimeout` ago, and within `kDoubleTapSlop` of this tap's position. The tracker (row id, time, position) is kept in one small helper shared by the tree, so two quick taps on different rows are never taken as a double tap, including after the rows rebuild.
- **The first tap** runs the whole single-tap work immediately: the three steps above, plus `addFileTab(path)` for an open file.
- **The second tap** runs only the extra steps: `addFileTab(path)` when the file is tab-less, then `requestZoomToFit(MPZoomToFitType.selection)`. It does not repeat the Select-tool transition or the selection, so nothing is repainted without need. It then resets the tracker, so a third tap starts a new sequence.
- **What the user sees.** For a tab-less file, the canvas appears once, already zoomed to the selection, because the pending zoom applies on the new tab's first layout. For an open file, the selection appears at the current viewport and the zoom follows on the second tap. This is a visible two-step, not a flicker: nothing reverts, and canvas double-clicks and file managers behave the same way.
- If the element no longer exists or its file is no longer loaded and valid when the second tap arrives, the second tap does nothing. For example, a Reload finished between the two taps.
- **A row in a broken, loading or load-error state** never attempts selection.
- **Scrap rows** only highlight when the active scrap changes, through `setActiveScrap`. Selecting a whole scrap from the tree is out of scope for this phase.

Selection is not a data change: it creates no command and does not affect dirty state. A tap may end an in-progress line or area creation, exactly as the Select tool does, but that adds no command either (see "Leaving the current mode").

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
- No all-caps text. **Explicit exception to the parent plan’s assignment of documentation to Phase 6:** EN/PT help for the features introduced in Phase 3 must be updated in Phase 3, following the project’s general rule to document new features when they ship. Update `assets/help/en/th2_file_edit_page_help.md` and `assets/help/pt/th2_file_edit_page_help.md` to explain file/scrap expansion, lazy loading without opening tabs, filtering only loaded valid files, selection synchronization, the single- and double-click behavior for open and tab-less files, selection zoom, and Reload for broken or failed files. Include the file-order distinction from Therion rendering order. Phase 6 remains responsible for documentation of the remaining features. The EN/PT UI localization above is also required in Phase 3.
- Phase 3 introduces no keyboard shortcut, so the keyboard-shortcuts pages need no entry. If implementation introduces one, update both EN/PT shortcut pages in alphabetical order in the same change.

### 9.2 Row context menu

Mapiah has no context menus yet; the only menu is the overflow `PopupMenuButton` in `th2_file_tabs_page.dart`. Right-drag pans the canvas, but right-click is unused in the project tree. Phase 3 introduces the pattern that Phase 4 extends with the parent plan's §4.8 actions, including the "Move to scrap… ▸" submenu.

- **Widget: `MenuAnchor`.** `showMenu`/`PopupMenuButton` cannot nest submenus, which Phase 4 needs. `MenuAnchor` supports `SubmenuButton` and keyboard navigation inside an open menu, and it opens at the pointer with `MenuController.open(position:)`. That position is relative to the `MenuAnchor`'s child, so pass `TapUpDetails.localPosition` from `onSecondaryTapUp`, not `globalPosition`.
- **One shared wrapper.** A new stateful `THProjectTreeRowContextMenuWidget` (`lib/src/widgets/th_project_tree_row_context_menu_widget.dart`) owns the `MenuController` and takes `rowId`, `child` and `List<Widget> Function() menuChildrenBuilder`.
  - On `onSecondaryTapUp`, call `menuChildrenBuilder` to resolve the current controller state. If it returns an empty list, do nothing. Otherwise close any open menu, store the returned children with `setState`, and schedule a post-frame callback. `MenuAnchor.menuChildren` is supplied during widget build; `MenuController.open` does not invoke a builder, so opening in the same handler would use the previous children.
  - In the callback, open at the captured `TapUpDetails.localPosition` only if the wrapper is still mounted, its `rowId` still matches the tapped row, and this is still the latest pending request. Recheck `menuChildrenBuilder` before opening; if it is now empty, discard the request. A later right-click makes a fresh request. This prevents a menu for a row that became valid or disappeared before the next frame.
  - Menu contents are computed for each right-click, not when the ordinary row builds. The wrapper's build passes the stored children to `MenuAnchor`; an empty menu is never opened.
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

1. Add the missing Phase 1 and Phase 2 tests (§3.5) against the current code, fix any Phase 1/2 bug they expose in its own small change, and commit them before any Phase 3 change.
2. Apply the remaining §3.1 observability changes on top of the Phase 2 controller/revision/disposal implementation: observable lifecycle fields, `_preParseInitialize` and the Save As write as actions, single-action load commit, `th2ControllersRevision`, `loadError`, the disposed-controller guard in the load-commit and load-error actions, subtype revision bumps, `reloadTH2File`'s single replacement action and removal of post-load tab activation (with the lifecycle regression tests in §12), and `_normalizeFilename` delegating to `THProjectPathResolver.canonicalize`. In the same step, move `_handleLoadFailure`'s `onLoadFailed()` call into its post-frame callback (§3.4), because the `removeFileController` bump would otherwise fail the existing load-failure tests. Preserve the Phase 2 disposal, tab-less cleanup and revision behavior. Let the MobX watch process regenerate the `.g.dart` files.
3. Fix default expansion to include non-TH2 nodes through the shallowest TH2 depth and explicitly skip TH2 nodes (§3.3), updating the t3880 expectations and adding regression tests before any TH2 row can load. Then add the sealed visible-row types and update the flattener with compatibility tests for ordinary project trees.
4. Add `th2_element_tree_aux.dart` and pure row/label tests using valid and broken controller fixtures. Add `collapsedTH2ScrapIds` to `THProjectTreeUIController` and the scrap expansion fields to the row model (§6.1).
5. Refactor `THProjectTreeWidget` to render each row kind and observe loaded-controller state/revisions.
6. Add the file-row chevron, `ensureTH2FileLoaded` and the post-frame load trigger for expanded rows that need a load (§5), including lifecycle capture and execution-time eligibility checks shared with direct chevron requests. Verify that stale requests cannot recreate controllers after cleanup, expansion does not open a tab or dirty a file, and a row kept expanded across a project reload loads again from a fresh build. Then add the §3.2 tab-close rule (`isTH2FileRowExpanded`, the keep-or-dispose decision in `removeFileTab` and `_discardFailedFileLoad`, and `close()` no longer disposing reactions).
7. Add status rows, broken badge, `THProjectTreeRowContextMenuWidget` with the Reload action for broken and load-error files (§9.2), and load-error handling based on `loadError`. Apply §3.4: key the TH2 tab body with `ObjectKey(controller)`, observe controller replacement in the tab-content builder, preserve the load-cache identity check, and catch errors at both Reload entry points. Add the open-tab Reload regression tests alongside these changes.
8. Split `matchesFilter` to add `matchesFilterText`. Add the filter-aware callback result, `hasMatch` in `_collectSubtreeMatches`, the per-build result map and the label cache (§7). Add the drawing-order tooltip.
9. Add `requestZoomToFit` and the pending-zoom handling in `TH2FileWidget`. Then wire tree-to-canvas selection through each file's own selection controller, and canvas-to-tree highlighting through row-scoped `Observer`s, including tab-less files and double-click zoom (§8).
10. Add the §9.1 EN/PT `.arb` entries and the badge constant, run `flutter gen-l10n`, and switch the new widgets to `AppLocalizations`. Do this alongside steps 7–9 rather than as a clean-up, so that no hard-coded strings are ever committed. Update the EN/PT editor help in Phase 3 with the feature documentation specified in §9.1, as an explicit exception to the parent plan’s assignment of documentation to Phase 6. Update the EN/PT keyboard-shortcuts pages only if a shortcut is introduced, keeping entries alphabetical.
11. Run focused tests, `flutter analyze`, and the full test suite. Do not run `build_runner` manually or `dart format`.
12. Add one Phase 3 entry to the current unreleased section of `CHANGELOG.md` (under "New features"), referencing #32 and listing the new test files. This follows the parent plan rule that every phase ends with its own CHANGELOG entry.

## 11. Expected files

| Area | Files |
|---|---|
| Row model/flattening | `lib/src/auxiliary/th_project_tree_flatten_aux.dart`, possibly a new visible-row model file |
| TH2 row builder | new `lib/src/auxiliary/th2_element_tree_aux.dart` |
| Tree UI state | `lib/src/controllers/th_project_tree_ui_controller.dart` (`collapsedTH2ScrapIds`, `toggleTH2ScrapCollapsed`, `isTH2ScrapCollapsed`, clearing on project close; `matchesFilterText` split out of `matchesFilter`; §3.3: shallowest-TH2-depth seeding) and its regenerated `.g.dart` file |
| Widgets | `lib/src/widgets/th_project_tree_widget.dart`, `lib/src/widgets/th_project_tree_node_widget.dart`, new `lib/src/widgets/th2_element_tree_row_widget.dart`, new `lib/src/widgets/th_project_tree_row_context_menu_widget.dart`, `lib/src/widgets/th2_file_widget.dart` (consume a pending zoom on first layout), `lib/src/widgets/th2_file_edit_last_used_pla_buttons_widget.dart` (use the new icon path constants, §6.2) |
| Controllers | `lib/src/controllers/th2_file_edit_controller.dart` (§3.1: observable `_isFileLoaded`/`_isBroken`/`_problems`, `_preParseInitialize` and the Save As write as actions, single-action load commit, `_loadError` capture, disposed-controller guard; §3.2: `close()` no longer disposing reactions; §8: `requestZoomToFit` and its pending-zoom field), `lib/src/controllers/mp_general_controller.dart` (§3.1: `_th2ControllersRevision`, `reloadTH2File`'s single replacement action and removal of post-load tab activation, and `_normalizeFilename` delegation; §3.2: keep-or-dispose decision in `removeFileTab`; §5: `ensureTH2FileLoaded`), `lib/src/controllers/th2_file_edit_element_edit_controller.dart` (§3.1 item 7: subtype revision bumps), `lib/src/controllers/th_project_tree_ui_controller.dart` (§3.2: `isTH2FileRowExpanded`), `lib/src/pages/th2_file_tabs_page.dart` (§3.2: `_discardFailedFileLoad`), their regenerated `.g.dart` files, selection controller files only if an adapter is required. Preserve the Phase 2 disposal and tab-less cleanup code. |
| Text/icon helpers | existing `mp_text_to_user.dart` and `th_project_tree_node_icon_widget.dart`, only where reuse requires a small extension |
| Open-tab Reload | `lib/src/pages/th2_file_tabs_page.dart` (§3.4: `ObjectKey(controller)` on the TH2 body, observed controller replacement, and caught Reload errors). `TH2FileEditBodyWidget` keeps its existing controller capture and initializes fresh state for each replacement controller. |
| Prerequisite tests (§3.5) | new `test/t3939_th2_file_parser_hierarchy_violations_test.dart`, new `test/t3940_th2_broken_file_body_widget_test.dart`, new `test/t2462_commands_mpmoveelementscommand_test.dart`, new `test/t3941_th2_hierarchy_aux_test.dart`, and the Phase 2 §7.3 lifecycle/revision tests (in existing lifecycle test files or a focused new one); Phase 1/2 source files only if these tests expose a bug |
| Load-failure cleanup | `lib/src/widgets/th2_file_edit_body_widget.dart` (§3.4: `onLoadFailed()` moved into the post-frame callback) |
| Tests | `test/t3203_ui_reopen_file_after_parse_failure_test.dart` (must stay green after §3.4), `test/t3880_th_project_tree_ui_controller_test.dart`, `test/t3881_th_project_tree_flatten_test.dart`, `test/t3883_th_project_tree_widget_test.dart`, new `test/t3942_th2_element_tree_rows_test.dart`, new `test/t3943_th2_element_tree_widget_test.dart`, new `test/t3944_th2_controller_lifecycle_observability_test.dart` |
| Localization | `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb`, generated `lib/src/generated/i18n/` files from `flutter gen-l10n`, `lib/src/constants/mp_constants.dart` (`mpTH2ElementTreeBadgeTooltipMaxProblems`; the icon paths `mpAddPointButtonImagePath`, `mpAddLineButtonImagePath` and `mpAddAreaButtonImagePath`, §6.2) |
| Changelog | `CHANGELOG.md` (one Phase 3 entry referencing #32) |
| Help | `assets/help/en/th2_file_edit_page_help.md`, `assets/help/pt/th2_file_edit_page_help.md` (§9.1: expansion, filtering, selection, double-click opening/zoom, Reload and drawing order). These updates belong to Phase 3 as an exception to Phase 6’s documentation responsibility. EN/PT keyboard-shortcuts pages change only if a shortcut is introduced. |

Do not edit generated `.g.dart` files manually. If the MobX watch process regenerates them after an annotated source change, include only the required generated diff.

## 12. Tests and acceptance criteria

### Controller observability tests (`t3944`)

- A MobX `reaction` on `isFileLoaded` fires once when a valid load completes, and once when a broken load completes. In the broken case `isBroken` is `true` and `problems` is non-empty when the reaction runs.
- A broken file whose parser reports a `parseError` exposes that diagnostic in `problems`, the broken count and the tooltip exactly once; parser-error strings returned for the existing tab error dialog are not double-counted.
- A `reaction` on `structureRevision` fires once per load and sees `isFileLoaded == true` and the final `isBroken`/`problems` values.
- Tests that count `th2ControllersRevision` changes read the value right before and right after the action under test, never from a fixed initial value. `TH2FileParser.parse` defaults to `forceNewController: true`, and many existing tests call it directly or call `getTH2FileEditController`. Each of those calls creates or replaces a controller and so bumps the revision. This is harmless, and those tests need no change.
- `th2ControllersRevision` changes when `getTH2FileEditController` creates a controller, `removeFileController` removes one, `renameFileController` moves one, `disposeTablessTH2Controllers` disposes one, `reloadTH2File` replaces one, or test-only `reset()` clears a non-empty TH2 registry. It does not change when `getTH2FileEditController` returns an existing controller or when `reset()` finds no TH2 controller.
- A reaction that reads `getTH2FileEditControllerIfExists(path)` re-runs after the controller for `path` is created, reloaded or removed.
- A reaction that reads `getTH2FileEditControllerIfExists(path)` re-runs once after `reset()` clears that controller and sees `null`; an empty reset does not rerun it.
- Save As of a new file leaves `isFileLoaded == true`. A reaction on `isFileLoaded` runs once for the Save As transition and already sees the new `th2File.filename` and the updated current scrap name.
- Calling `load()` on an existing, unloaded controller while a reaction observes its `isLoading` runs that reaction once for the pre-parse transition.
- A controller disposed while its load is still running (for example by `disposeTablessTH2Controllers`) commits nothing when the parse ends: `isFileLoaded`, `isBroken`, `problems` and `structureRevision` are unchanged, and no reaction is registered after disposal. The same holds when the load throws after disposal: `loadError` stays `null`, and the rethrown error is not unhandled.
- Setting or removing only a subtype option bumps `structureRevision` once, and so does undoing it. Changing another non-id option does not bump it.
- When `_loadOnce` throws (for example through an injected failing parse or initialization step):
  - `loadError` is set, `isLoading` is `false` and `isFileLoaded` is `false`;
  - the future returned by `load()` completes with that error;
  - a second `load()` returns the same failed future without parsing again;
  - a reaction on `loadError` fires once.
- After a failed load, `reloadTH2File` produces a new controller with `loadError == null` that loads normally.
- During `reloadTH2File`, a reaction that reads `getTH2FileEditControllerIfExists(path)` runs exactly once and sees the new controller; it never sees `null` in between.
- With a Reload load held pending, closing its tab prevents completion from reopening or activating it, whether the controller is retained by §3.2 or disposed. Closing, switching or reloading the project, including reopening the same root path, likewise prevents stale completion from creating a tab or controller. Two overlapping Reloads completed in either order leave only the newest controller registered; neither completion changes tab ownership or activation.
- `isTH2FileRowExpanded` is `true` only for a project TH2 file whose `TH2FileNode` id is in `expandedNodeIds`, and `false` with no project or for a file outside the project.
- `_normalizeFilename` still returns empty and `mpNewFilePrefix…` names unchanged. For real paths, including relative ones and ones with `./` and `../` segments, it returns the same string as `THProjectPathResolver.canonicalize(p.absolute(path))`.

### Default expansion tests (`t3880`)

- With the §3.3 tree, where a deeper `.th2` comes first in walk order, seeding expands `main.thconfig`, `cave.th` and `north.th`, and expands neither `north.th2` nor `cave.th2`.
- No seeded expansion set ever contains a `TH2FileNode` id, whatever the order of the project's children.
- Non-TH2 nodes at the shallowest TH2 depth are expanded; deeper non-TH2 nodes remain collapsed. Update the existing t3880 "expands all branches down to the shallowest th2 file" test to expect `siblingChild` to be expanded, since it is at the same depth as `th2Node`.
- Existing tests for projects without TH2 files and preservation of a non-empty expansion set pass unchanged.
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
- Schedule a deferred load, then close, switch or reload the project before it executes: the stale callback creates no controller and starts no parse. Include closing/reopening the same root path to verify the epoch guard.
- Schedule a deferred load, then collapse the file or an ancestor, remove the file from the project tree, activate a filter, or unmount the tree: the callback performs no load. Once eligible again, a fresh build loads the file exactly once.
- While a project reload is parsing and the outgoing tree is still present, no automatic tree load starts. After parsing finishes, only eligible files in the current tree load.
- A TH2 file row kept expanded across a project reload (its controller disposed) shows Loading and loads again once, without opening a tab.
- While a filter is active, no file loads: neither a file shown only through filter auto-expansion nor an expanded file with no controller. After the filter is cleared, the expanded file loads once.
- A valid load displays rows and the broken badge is absent.
- A broken load displays the badge/count and status row, never element rows, and offers Reload.
- Reload replaces the controller and updates the row state after the future completes.
- Start Reload in an open tab, then switch to another tab before it completes: the new active tab remains active. Close the reloading tab or transition to another project before completion: it stays closed and no stale body appears. Repeat with a retained tab-less controller and with overlapping Reloads; only the current controller's state is rendered.
- With a broken file already open in a tab, fixing it on disk and choosing sidebar Reload replaces the body state and displays a valid canvas bound to the new controller; no widget continues using the disposed controller. The update does not require switching tabs.
- Reloading an open broken file into another broken file displays the new controller's diagnostics. An ordinary rebuild with the same controller preserves the body state.
- An unexpected load exception during Reload of an open tab shows the error dialog once and follows the existing close behavior, with no unhandled async exception. Cover both sidebar Reload and the tab body's Reload button, and verify a replacement body starts with a fresh `_loadFailureHandled` flag.
- Right-clicking (`tester.tap(..., buttons: kSecondaryButton)`) a broken file row and its status row shows Reload, and so does a load-error file row and its status row.
- Right-clicking a valid TH2 file, a loading TH2 file, an element row or an ordinary project node opens no menu.
- After a file row has already built, changing its controller from valid to broken before a right-click shows Reload on that first right-click. If it becomes valid or its row disappears between the right-click and the deferred open, no stale menu opens. Two right-clicks before the deferred open use only the latest request.
- Right-clicking never opens or activates a tab, selects the project node, or changes the element selection.
- Choosing Reload from the menu replaces the controller, and the rows update. A Reload whose load fails again shows the load-error row, with no unhandled exception.
- A tab whose load throws while its file row is collapsed (or with no project open) shows the error dialog once, removes the failed controller after the frame, closes the tab, and raises no "markNeedsBuild() called during build" assertion. The existing `t3203` cases stay green.
- A load that throws shows exactly one load-error row, schedules no further load requests across rebuilds, and offers Reload. Reload then shows the real state (element rows or broken). Opening that file's tab still shows the existing load-failure error dialog.
- Tapping an element in an open file activates its tab, selects it and activates its scrap; double-tap zooms to the selection.
- A single tap on an element row applies its effect without waiting for the double-tap timeout: the selection, active scrap and, for an open file, tab activation are visible after one `pump()` with no added delay.
- Two taps on the same row within `kDoubleTapTimeout` and `kDoubleTapSlop` run the double-tap extras once. The second tap does not call `setSelectedElements` again and does not change the state-machine state.
- Two quick taps on different rows are two single taps: each selects its own element and neither zooms. Two taps on the same row further apart than `kDoubleTapTimeout` are also two single taps. A third quick tap after a double tap starts a new sequence and does not zoom again.
- A second tap that arrives after a Reload replaced the file's controller, or after the element was removed, does nothing and raises no exception.
- Tapping a tab-less element sets that controller's selection and active scrap and highlights the row. It opens no tab and changes no dirty state or active tab index.
- Double-tapping a tab-less element opens and activates the tab. The canvas shows the element selected with its scrap active, and the first layout zooms to the selection, not to the whole file.
- Tapping an element row while its open tab is in add-line mode with a line in progress ends the line creation as the Select tool would. The undo stack is unchanged, the state is non-empty selection, and only the tapped element is selected. Repeat for add-area mode with an area in progress.
- Tapping an element row while its open tab is in edit-single-line mode leaves that mode through its normal exit. Only the tapped element is selected, in the non-empty-selection state.
- Tapping an element row of a tab-less controller left in add-point mode switches it to the non-empty-selection state with the tapped element selected. No tab opens and the file does not become dirty.
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

### Prerequisite tests (§3.5)

- `t3939`, `t3940`, `t2462`, `t3941` and the Phase 2 §7.3 lifecycle/revision tests exist, cover the cases their plans list, and pass against the code as it was before Phase 3. They are committed before any Phase 3 change.
- Any Phase 1/2 bug they exposed is fixed in its own change and listed under "Fixed bugs" in `CHANGELOG.md`.
- They still pass at the end of Phase 3, changed only where §3.2 or §3.1 item 4 changes behavior on purpose.

### Acceptance

- The Phase 1 and Phase 2 tests from §3.5 exist and pass.
- Users can inspect XTherion file order from the sidebar without opening every file in a tab.
- Tree loading is lazy, idempotent and side-effect free apart from creating the cached tab-less controller.
- Broken files are clearly identified and never expose partially parsed elements.
- Selection state is consistent between the sidebar and canvas for valid open files.
- Every string added in this phase exists in both EN and PT `.arb` files, and no new widget contains a hard-coded user-visible string.
- EN/PT editor help describes the Phase 3 expansion, filtering, selection, double-click opening/zoom, Reload and drawing-order behavior. These updates are required for Phase 3 acceptance as an explicit exception to the parent plan’s assignment of documentation to Phase 6 (§9.1). Any new keyboard shortcuts are documented in both languages in alphabetical order.
- Completing Reload after a tab close, project transition or newer Reload cannot reopen or activate a tab, recreate a controller or replace the current controller.
- `CHANGELOG.md` has a Phase 3 entry referencing #32.
- Focused tests, the full test suite and `flutter analyze` pass with no formatting-only churn.
