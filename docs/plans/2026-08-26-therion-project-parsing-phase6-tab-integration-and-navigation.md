<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 6: Multi-Tab Integration & Navigation — Implementation Plan

**Date:** 2026-08-26
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 6** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It builds on:

- **Phase 1-3** — grammars/parsers/writers, `THProjectParser`, `THProjectController`.
- **Phase 4** — the project-tree sidebar, `THProjectTreeUIController`, `.th2` node click-to-open.
- **Phase 5** — the standalone `THTextEditorController`/`THTextEditorWidget`, including its single-file find/replace follow-up.

Phase 6 wires the Phase 5 text editor into the existing tab system so `thconfig`/`.th` files open as first-class tabs alongside `.th2` canvas tabs, and makes the project tree, tab bar, and open editors navigate each other consistently: clicking any project-tree node opens or focuses the right tab (and, for logical nodes, jumps to the right line); switching tabs updates which tree node is highlighted; keyboard focus and the page-level save shortcut follow whichever tab is active.

### Key Objectives

1. **Generalize `MPGeneralController`'s tab model**: `_openFileOrder`/`_activeTabIndex` already store tabs as plain filenames with no type tag; add a parallel `THTextEditorController` registry (mirroring the existing `TH2FileEditController` one) and dispatch on file extension (`.th2` vs `thconfig`/`.th`) everywhere the controller type currently matters.
2. **`THTextEditorTabBodyWidget`**: a new widget mirroring `TH2FileEditBodyWidget`'s async-load-then-render pattern, so `TH2FileTabsPage`'s `IndexedStack` can render either body type per tab.
3. **Project-tree → tab navigation**: clicking a `THConfigFileNode`/`THDataFileNode` opens/focuses a text-editor tab; clicking a logical node (`THSurveyNode`/`THCentrelineNode`/`THMapNode`/inline `THScrapNode`) opens/focuses the text-editor tab for its `sourceFilePath` and scrolls to its `lineNumber`. `TH2FileNode` clicks are unchanged.
4. **Keyboard focus routing**: `THTextEditorController` gets a persistent `FocusNode` (mirroring `TH2FileEditController.th2FileFocusNode`); tab-switch focus routing and the page-level `Ctrl/Cmd+S` shortcut dispatch to whichever controller type is active.
5. **Tab → tree navigation**: switching the active tab (by any means — tree click, tab click, tab close) updates `THProjectController.activeSelectedNodeId` to the corresponding file node and reveals it in the tree via the existing `THProjectTreeUIController.expandAncestorsOf`.
6. **Unified dirty indicator**: mirror `TH2FileEditController`'s existing dirty state (`enableSaveButton`) into `THProjectController.dirtyFilePaths`, so the project tree's dirty dot (already rendered by Phase 4, currently only ever populated by text-editor edits) also reflects unsaved canvas edits.

### Explicit Non-Goals

- **No linked-`.th2` scrap children in the tree.** `THScrapNode.isFromTH2File` exists but is always `false` today (see Phase 2's own grounding note pointing at "Phase 6"); populating it requires parsing every linked `.th2` file's scrap headers, which either means a full `TH2FileEditController.load()` per node (expensive, pulls in the whole canvas element graph just to list scrap ids) or a second, parallel lightweight scrap-header parser (risks drifting from the real grammar). Given Phase 6's own roadmap bullet ("extend `MPGeneralController`... implement seamless cross-navigation") doesn't itself require this, it's left as a follow-up once there's a concrete need, the same way Phase 5 split off multi-file find/replace.
- **No "New thconfig/.th file" creation flow.** Text-editor tabs are only opened from existing project-tree nodes in this phase; `Ctrl+O`/the toolbar "Open file" button remain `.th2`-only.
- **No unsaved-changes confirmation dialog on tab close.** `TH2FileEditController.close()` already closes unconditionally with no prompt; text-editor tabs match that existing behavior rather than introducing a new one.
- **No Therion compiler diagnostics wiring** — Phase 7.
- **No help-page/keyboard-shortcut-table updates** — Phase 8, per the top-level roadmap (same exception already used by Phases 4 and 5).
- **No changes to `THTextEditorWidget`'s own editing/highlighting/find-replace behavior** — Phase 6 only adds a scroll-to-line entry point and a focus node to the controller; the editing surface itself is unchanged.

---

## 2. Grounding: Current State

Verified against the codebase:

- **Single-project model**: Mapiah supports at most one open Therion project at a time (`THProjectController` is a locator singleton; `openProject` replaces any previously-loaded project). "Multi-tab" in this phase means multiple *files* — `thconfig`, `.th`, `.th2` — open as tabs within that one project, not multiple projects; nothing in this plan introduces or requires tracking which project a tab "belongs to". See the top-level roadmap's "Single-Project Model" note.
- `MPGeneralControllerBase` (`lib/src/controllers/mp_general_controller.dart`) stores tabs as a flat `ObservableList<String> _openFileOrder` of normalized absolute filenames plus `int _activeTabIndex`, with a single `HashMap<String, TH2FileEditController> _t2hFileEditControllers` keyed the same way. Every tab-affecting method (`addFileTab`, `removeFileTab`, `setActiveTab`, `reorderFileTabs`, `_clearActiveTabOverlayWindows`) assumes every open filename has a `TH2FileEditController`. `_normalizeFilename` (`p.normalize(File(filename).absolute.path)`, with a `mpNewFilePrefix` passthrough for in-memory new files) already produces the same normalized-absolute-path shape as `THProjectPathResolver.canonicalize`, so both systems already agree on path keys with no extra reconciliation.
- `TH2FileTabsPage` (`lib/src/pages/th2_file_tabs_page.dart`) renders the tab strip and an `IndexedStack` body purely off `mpGeneralController.openFileOrder`/`activeTabIndex`; `_buildTabContentWidget` unconditionally calls `getTH2FileEditControllerIfExists` and returns "Controller not found" text for anything else — this is the one place that needs real branching by tab type. `MPFileTabWidget` (the actual tab chip) is already filename/callback-generic (no `TH2FileEditController` dependency) except for its "Properties" info button, whose `onProperties` callback needs to become optional/hidden for text-editor tabs (there is no text-editor equivalent of `TH2FilePropertiesPage`).
- `_withShortcuts` in the same file installs a page-level `CallbackShortcuts` with a hard-coded `Ctrl/Cmd+S` binding that calls `_getActiveTH2FileEditController(...)?.enableSaveButton`/`saveTH2File()`; for a text-editor tab this currently resolves to `null` and silently no-ops (safe, but wrong — the intent is for it to fall back to the focused `THTextEditorController`, which handles its own `Ctrl/Cmd+S` via its own `Shortcuts`/`Actions` when focused. Flutter's keyboard dispatch bubbles from the focused leaf up through ancestors, so `THTextEditorWidget`'s own binding — closer to the focus — is consulted first; the page-level one is the fallback for when focus is elsewhere).
- `TH2FileEditController.close()` (`lib/src/controllers/th2_file_edit_controller.dart:1376`) already calls `mpLocator.mpGeneralController.removeFileTab(filename: ...)`, which in turn calls `removeFileController` — currently only clearing the TH2 map. `TH2FileEditController` already has a `List<ReactionDisposer> _disposers` pattern (populated in its setup, drained by `_disposeReactions()`, called from `close()`) that a new dirty-mirroring reaction can plug into with no new lifecycle plumbing.
- `TH2FileEditController.enableSaveButton` is `@computed` (`_hasUndo && !_th2File.isNewFile`); nothing currently writes into `THProjectController.dirtyFilePaths` for `.th2` files, so the tree's dirty dot (rendered generically off that set by `THProjectTreeWidget`/`THProjectTreeNodeWidget` since Phase 4) never lights up for unsaved canvas edits today — confirmed by grep, not just absence of a test.
- `THProjectController.saveProjectFile` (`lib/src/controllers/th_project_controller.dart:298`) already special-cases `.th2` paths (delegates to `TH2FileEditController.saveTH2File()` and removes from `dirtyFilePaths`), so once something *adds* a `.th2` path to `dirtyFilePaths`, the removal side is already correct and requires no new code.
- `THProjectTreeNodeWidget._onTap` (`lib/src/widgets/th_project_tree_node_widget.dart:65`) is the only place that currently reacts to node clicks; today it calls `THProjectController.selectNode(node.id)` unconditionally and only special-cases `TH2FileNode` (open/focus canvas tab). This is the exact insertion point for the new `THConfigFileNode`/`THDataFileNode`/logical-node branches.
- `THProjectNode` (the common base for both file and logical nodes) already carries `sourceFilePath`/`lineNumber` on every node — for a *file* node these describe the `source`/`input` directive's location in the *including* file (verified against `THProjectParser._createConfigFileNode`/`_createDataFileNode`, which pass through the caller's `sourceFilePath`/`lineNumber`, not a location inside the file's own content), so file-node clicks correctly open at the top with no scroll target. For *logical* nodes (`THSurveyNode`, `THCentrelineNode`, `THMapNode`, inline `THScrapNode`), `sourceFilePath`/`lineNumber` describe the block's own position inside the file currently being walked (verified against `THProjectParser._buildDataElements`, e.g. `sourceFilePath: canonicalPath, lineNumber: element.lineNumber`) — exactly the "scroll to this line" target needed.
- `THProjectTreeUIController.expandAncestorsOf(THProjectNode node)` (`lib/src/controllers/th_project_tree_ui_controller.dart:102`) already exists (built for Phase 4's filter auto-expand) and does exactly what tab→tree reverse navigation needs: walk `node.parent` and add every ancestor id to `expandedNodeIds`. No new tree-reveal logic is needed, only calling it from the right place.
- `THProjectController.nodeByCanonicalPath(String canonicalPath)` (`lib/src/controllers/th_project_controller.dart:383`) already resolves a canonical path back to its `THProjectFileNode`, which is what tab→tree sync needs to turn an open filename back into a node to select/reveal.
- There is **no existing `THTextEditorTabBodyWidget`** or any generalization of `MPGeneralController`'s tab storage. `THTextEditorController` (Phase 5) has no `FocusNode` and no "scroll to a given line" entry point yet — `setCursorPosition` only records the reported cursor line/column, it does not move the actual `TextField` selection.
- Test numbering: the last Phase 5 test file is `test/t3905_th_text_editor_find_replace_test.dart`. Phase 6 tests start at `t3906`.

---

## 3. File Organization & Architecture

```
lib/src/
 ├── controllers/
 │    ├── mp_general_controller.dart          # Existing: generalized tab storage/dispatch
 │    ├── th2_file_edit_controller.dart        # Existing: gains a dirty-mirroring reaction
 │    └── th_text_editor_controller.dart       # Existing: gains textEditorFocusNode + scrollToLine
 └── widgets/
      ├── th_text_editor_tab_body_widget.dart  # New: async-load wrapper, mirrors TH2FileEditBodyWidget
      ├── th_text_editor_widget.dart           # Existing: consumes pendingScrollToLine
      ├── mp_file_tab_widget.dart              # Existing: onProperties becomes optional
      └── th_project_tree_node_widget.dart     # Existing: gains file/logical-node open branches

lib/src/pages/
 └── th2_file_tabs_page.dart                   # Existing: IndexedStack + shortcuts dispatch by tab type
```

No new controller classes and no new data model — this phase is entirely about wiring already-built pieces together.

---

## 4. `MPGeneralController` Generalization

### 4.1 Design decision: extension dispatch, not a tab-kind wrapper

`_openFileOrder` stays a flat `ObservableList<String>` of normalized paths. A tab's *kind* is derived from its extension wherever needed (`.th2` → canvas, everything else opened through this system → text editor), the same technique `THProjectController.saveProjectFile` already uses (`p.extension(canonicalPath).toLowerCase() == '.th2'`). This is a deliberately minimal change: introducing a discriminated-union tab model would touch every call site that reads `openFileOrder` (including the drag-reorder and scroll-position code in `TH2FileTabsPage`, which is filename-list-shaped throughout) for no behavioral gain over an extension check, since `.th2` vs `thconfig`/`.th` is already how the rest of the project-parsing feature (Phases 1-5) distinguishes file kinds.

```dart
bool isTH2Tab(String filename) =>
    p.extension(filename).toLowerCase() == '.th2';
```

(A small private/file-local helper, or a static method on `MPGeneralController` — placement TBD during implementation; used by both `MPGeneralController` and `TH2FileTabsPage`.)

### 4.2 New text-editor controller registry

Mirrors the existing `_t2hFileEditControllers` map one-to-one:

```dart
final HashMap<String, THTextEditorController> _textEditorControllers =
    HashMap<String, THTextEditorController>();

THTextEditorController? getTextEditorControllerIfExists(String filename) {
  final String normalizedFilename = _normalizeFilename(filename);
  return _textEditorControllers[normalizedFilename];
}

THTextEditorController getTextEditorController(String filename) {
  final String normalizedFilename = _normalizeFilename(filename);

  return _textEditorControllers.putIfAbsent(
    normalizedFilename,
    () => THTextEditorController(),
  );
}
```

`getTextEditorController` does not itself call `loadFile` — matching `getTH2FileEditController`'s split between "get/create the controller" and "load its content", loading is triggered by `THTextEditorTabBodyWidget` (§5), the same place `TH2FileEditBodyWidget` triggers `TH2FileEditController.load()`.

### 4.3 Generalizing the shared tab-lifecycle methods

- **`_clearActiveTabOverlayWindows`**: overlay windows are a canvas-only concept (`TH2FileEditOverlayWindowController`); guard the existing body with `if (isTH2Tab(outgoingFilename))` and leave it a no-op for text-editor tabs.
- **`setActiveTab`**: after the existing `_clearActiveTabOverlayWindows` call, branch on `isTH2Tab(incomingFilename)` to call either `_t2hFileEditControllers[incomingFilename]?.th2FileFocusNode.requestFocus()` (existing) or `_textEditorControllers[incomingFilename]?.textEditorFocusNode.requestFocus()` (new). Also call `_syncProjectTreeSelectionToActiveTab(incomingFilename)` here (§8).
- **`removeFileTab`**: `removeFileController` currently only clears the TH2 map; generalize it to also `_textEditorControllers.remove(normalizedFilename)?.dispose()` (calling `THTextEditorController.dispose()`, which cancels its debounce `Timer` — matching the leak the Phase 5 tests had to guard against). Both removals are unconditional/idempotent (`HashMap.remove` on an absent key is a no-op), so no branching is needed here — simpler than threading a "kind" parameter through.
- **`reorderFileTabs`**: unchanged — it only reorders the flat filename list, agnostic to tab kind.
- **`reset()`** (test-only): also clear `_textEditorControllers` (calling `dispose()` on each first, same as `removeFileController`, to avoid leaking pending timers across tests — this is exactly the pattern the Phase 5 tests (`t3902`-`t3905`) had to hand-roll per test file; centralizing it in `reset()` removes that duplication for any future test that opens text-editor tabs through the full tab system rather than constructing a bare `THTextEditorController`).

---

## 5. `THTextEditorTabBodyWidget`

Mirrors `TH2FileEditBodyWidget`'s `FutureBuilder`-over-a-cached-future pattern (`_fileLoads`/`_TH2FileLoad` in `TH2FileTabsPage`), but text-editor loading is much simpler: `THTextEditorController.loadFile(String filePath)` is already a plain `Future<void>` with no result payload (content is read into an observable field as a side effect; there is no analogue of `TH2FileEditControllerCreateResult`'s per-line error list because `loadFile` reads already-parsed content from `THProjectController.fileContentsCache` or disk, not through a fallible grammar pass at load time — parse errors surface later, asynchronously, through `THProjectController.projectErrors`/`controller.diagnostics`, already rendered by `THTextEditorWidget`'s existing diagnostic markers).

```dart
class THTextEditorTabBodyWidget extends StatefulWidget {
  final THTextEditorController controller;
  final String filePath;

  const THTextEditorTabBodyWidget({
    super.key,
    required this.controller,
    required this.filePath,
  });
}
```

`_THTextEditorTabBodyWidgetState` caches one in-flight `Future<void>` per `(controller, filePath)` pair (keyed similarly to `TH2FileTabsPage._fileLoads`, but scoped locally to this widget instance rather than the whole page, since — unlike TH2 tabs — nothing outside this widget needs to observe the text-editor load future), calling `widget.controller.loadFile(widget.filePath)` once in `initState`/`didUpdateWidget` when the pair changes, and rendering:

- While pending: a centered `CircularProgressIndicator` (matching `TH2FileEditBodyWidget`'s loading state).
- On error (e.g. the file was deleted after the project tree loaded but before the tab opened): a centered error message using a new localized string, no retry affordance (matches `TH2FileEditBodyWidget`'s `onLoadFailed` only in spirit — there's no `MPGeneralController.removeFileController`-driven cleanup needed here since an empty/missing-content controller is harmless to leave registered, unlike a half-constructed `TH2File`).
- On success: `THTextEditorWidget(controller: widget.controller)`.

---

## 6. Project-Tree Click → Tab Navigation

`THProjectTreeNodeWidget._onTap` gains branches after the existing `selectNode` call:

```dart
void _onTap() {
  mpLocator.thProjectController.selectNode(node.id);

  final THProjectNode tappedNode = node;

  if (tappedNode is TH2FileNode) {
    mpLocator.mpGeneralController.getTH2FileEditController(
      filename: tappedNode.absolutePath,
    );
    mpLocator.mpGeneralController.addFileTab(tappedNode.absolutePath);
  } else if (tappedNode is THConfigFileNode || tappedNode is THDataFileNode) {
    _openTextEditorTab((tappedNode as THProjectFileNode).absolutePath);
  } else if (tappedNode is THSurveyNode ||
      tappedNode is THCentrelineNode ||
      tappedNode is THMapNode ||
      (tappedNode is THScrapNode && !tappedNode.isFromTH2File)) {
    _openTextEditorTab(tappedNode.sourceFilePath, lineNumber: tappedNode.lineNumber);
  }
  // THMissingFileNode, and THScrapNode.isFromTH2File (always false today,
  // see the Explicit Non-Goals section): no-op, matches current behavior.
}

void _openTextEditorTab(String filePath, {int? lineNumber}) {
  final THTextEditorController controller =
      mpLocator.mpGeneralController.getTextEditorController(filePath);

  mpLocator.mpGeneralController.addFileTab(filePath);

  if (lineNumber != null) {
    controller.scrollToLine(lineNumber);
  }
}
```

`addFileTab` needs no changes for this — it already just adds/activates a filename in `_openFileOrder`, agnostic to what kind of controller backs it.

---

## 7. `THTextEditorController` Additions

```dart
final FocusNode textEditorFocusNode = FocusNode();

@observable
int? pendingScrollToLine;

@action
void scrollToLine(int lineNumber) {
  pendingScrollToLine = lineNumber - 1; // THProjectNode.lineNumber is 1-based
}

@action
void clearPendingScrollToLine() {
  pendingScrollToLine = null;
}
```

`dispose()` also disposes `textEditorFocusNode`.

`THTextEditorWidget`'s build-time `Observer` gains a check symmetrical to the Phase 5 find/replace follow-up's `_applyActiveMatch`/`_lastAppliedActiveMatchIndex` handling: when `pendingScrollToLine != null`, move `_textEditingController.selection` to the start of that line, `jumpTo` the scroll controllers there (same line-height math already used by `_applyActiveMatch`/`_buildDiagnosticBackground`), then call `widget.controller.clearPendingScrollToLine()`. `Focus`'s `child` gains `focusNode: widget.controller.textEditorFocusNode` in place of `autofocus: true` (autofocus only fires once per widget lifetime, which is wrong for an `IndexedStack` tab that's built once but revisited many times — the same reason TH2 tabs need `th2FileFocusNode.requestFocus()` calls rather than relying on `autofocus`).

---

## 8. Tab → Tree Navigation (Reverse Sync)

New private helper in `MPGeneralController` (or a small pure aux function taking the needed controllers as parameters, for testability without the locator):

```dart
void _syncProjectTreeSelectionToActiveTab(String filename) {
  final THProjectFileNode? node =
      MPLocator().thProjectController.nodeByCanonicalPath(filename);

  if (node == null) {
    return;
  }

  MPLocator().thProjectController.selectNode(node.id);
  MPLocator().thProjectTreeUIController.expandAncestorsOf(node);
}
```

Called from `setActiveTab` (§4.3) so it fires for every path that changes the active tab: tree clicks (already call `selectNode` directly, so this is a harmless redundant no-op-ish re-selection of the same node), tab-strip clicks, and `removeFileTab`'s "select the next tab" fallback. `nodeByCanonicalPath` returns `null` for a `.th2` file that isn't itself a tree leaf under the currently-open project (e.g. a canvas file opened directly via "Open file", unrelated to any loaded `thconfig`) — the no-op return handles that existing case (project-tree-less canvas editing) without special-casing it.

---

## 9. Unified Dirty Indicator

In `TH2FileEditControllerBase`'s existing reaction-setup block (next to the `_selectionHandleLineThicknessOnCanvas` `autorun` at `th2_file_edit_controller.dart:931`):

```dart
_disposers.add(
  reaction(
    (_) => enableSaveButton,
    (bool isDirty) {
      final THProjectController projectController =
          mpLocator.thProjectController;
      final String canonicalPath = THProjectPathResolver.canonicalize(
        p.absolute(_th2File.filename),
      );

      if (isDirty) {
        projectController.dirtyFilePaths.add(canonicalPath);
      } else {
        projectController.dirtyFilePaths.remove(canonicalPath);
      }
    },
  ),
);
```

`enableSaveButton` is already `false` for new, unsaved files (`isNewFile` guard), so this reaction naturally does nothing for them until a real path exists (Save As). `THProjectController.saveProjectFile`'s existing `.th2` branch already removes the path from `dirtyFilePaths` on save, so this reaction only needs to *add*, not duplicate the removal — though the `else` branch above also handles undo-back-to-clean without a save, which the existing `saveProjectFile` path doesn't cover.

No changes are needed in `THProjectTreeWidget`/`THProjectTreeNodeWidget` — they already render dirty dots generically off `THProjectController.dirtyFilePaths` (Phase 4); this section only makes sure `.th2` edits actually populate that set.

---

## 10. `MPFileTabWidget` — Optional Properties Button

```dart
class MPFileTabWidget extends StatelessWidget {
  final String filename;
  final bool isActive;
  final VoidCallback onClose;
  final VoidCallback? onProperties; // was required

  ...
}
```

In `build()`, the "info" `IconButton` (currently always shown) is wrapped in `if (onProperties != null)`. `TH2FileTabsPage._buildDraggableTab` passes `onProperties: null` when `!isTH2Tab(filename)` instead of the current unconditional `TH2FilePropertiesPage` push (which requires a `TH2FileEditController` the text-editor tab doesn't have).

---

## 11. `TH2FileTabsPage` Dispatch by Tab Type

- **`_buildTabContentWidget(String filename)`**: branch on `isTH2Tab(filename)`; the existing body stays for `.th2`, and the `else` branch calls `mpGeneralController.getTextEditorControllerIfExists(filename)` and returns a `THTextEditorTabBodyWidget` (or the existing "Controller not found" fallback text if somehow absent, matching current defensive behavior).
- **`_activeTabFocusReaction`** (init-time reaction on `activeTabIndex`): branch the same way as `MPGeneralController.setActiveTab` (§4.3) to request focus on whichever controller type is active. (Both this reaction and `setActiveTab` requesting focus is existing, intentional redundancy per the comment already in the code — "ensures focus is correct even in contexts where the page is not yet mounted" — Phase 6 keeps that redundancy for text-editor tabs rather than removing it.)
- **`_withShortcuts`**: the `Ctrl/Cmd+S` (and `Ctrl/Cmd+Shift+S` Save As) bindings gain a fallback: if the active tab is a text-editor tab, call `getTextEditorControllerIfExists(activeFilename)?.save()` (Save As has no text-editor equivalent — it stays TH2-only, silently doing nothing for a text-editor active tab, matching how it already silently no-ops when `_getActiveTH2FileEditController` returns `null` today).
- **`_buildDraggableTab`**: `onProperties` becomes conditional per §10; `onClose` branches to call the right controller's teardown — `TH2FileEditController.close()` (existing) or a new equivalent one-liner for text editor tabs: `mpGeneralController.getTextEditorControllerIfExists(filename)?.dispose(); mpGeneralController.removeFileTab(filename: filename);` (there is no `THTextEditorController.close()` today; adding one that mirrors `TH2FileEditController.close()`'s two-line shape, rather than inlining both calls at the tab-widget call site, keeps the "how to close this kind of tab" logic next to the controller it belongs to — mirrors where `TH2FileEditController.close()` already lives).

---

## 12. Step-by-Step Implementation Sequence

```
Step 1: Generalize MPGeneralController (registry, dispatch helpers, removeFileTab/reset)
   │
   ▼
Step 2: Add THTextEditorController.textEditorFocusNode + scrollToLine/pendingScrollToLine
   │
   ▼
Step 3: Add THTextEditorController.close() + wire THTextEditorWidget to consume pendingScrollToLine
   │
   ▼
Step 4: Add THTextEditorTabBodyWidget
   │
   ▼
Step 5: Make MPFileTabWidget.onProperties optional
   │
   ▼
Step 6: Wire TH2FileTabsPage: IndexedStack body dispatch, focus reaction, shortcuts, tab close/properties
   │
   ▼
Step 7: Wire THProjectTreeNodeWidget._onTap: file-node and logical-node branches
   │
   ▼
Step 8: Add MPGeneralController._syncProjectTreeSelectionToActiveTab, call from setActiveTab
   │
   ▼
Step 9: Add the TH2FileEditController dirty-mirroring reaction
   │
   ▼
Step 10: Add localized strings (load-error message; no new user-facing labels otherwise)
   │
   ▼
Step 11: Unit and widget tests
   │
   ▼
Step 12: flutter analyze / flutter test
```

---

## 13. Test Plan

Test numbering continues at `t3906`:

| Test file | Coverage |
| :--- | :--- |
| `test/t3906_mp_general_controller_text_editor_tabs_test.dart` | `getTextEditorController`/`getTextEditorControllerIfExists` create/reuse/normalize; `addFileTab`/`removeFileTab`/`setActiveTab` work for a mix of `.th2` and `.th`/`thconfig` filenames in the same `openFileOrder`; `removeFileTab` disposes and clears the text-editor controller; `reset()` clears and disposes both registries. |
| `test/t3907_th_text_editor_controller_scroll_to_line_test.dart` | `scrollToLine` sets `pendingScrollToLine` to the 0-based equivalent; `clearPendingScrollToLine` resets it; `textEditorFocusNode`/timer cleanup on `dispose()`. |
| `test/t3908_th_project_tree_node_widget_open_tab_test.dart` | Widget test: clicking a `THConfigFileNode`/`THDataFileNode` opens a text-editor tab via `MPGeneralController`; clicking a logical node (survey/centreline/map/inline scrap) opens the containing file's tab and sets `pendingScrollToLine`; clicking `TH2FileNode` is unchanged; clicking `THMissingFileNode` is a no-op. |
| `test/t3909_th2_file_edit_controller_dirty_mirroring_test.dart` | `THProjectController.dirtyFilePaths` gains the `.th2` path when `enableSaveButton` becomes true and loses it when undone back to clean or saved; no entry is added for a new, unsaved file. |
| `test/t3910_th2_file_tabs_page_mixed_tabs_test.dart` | Page-level widget test: a mixed tab strip (one `.th2`, one `.th`) renders the right body widget per tab via the `IndexedStack`; switching tabs moves keyboard focus to the right controller's focus node and updates `THProjectController.activeSelectedNodeId`/tree expansion; `Ctrl/Cmd+S` saves whichever controller type is active; the Properties button is hidden for the text-editor tab. |

Representative scenarios:

1. **Mixed tab strip round-trip**: open a `.th2` tab, then a `.th` tab via the tree, switch between them repeatedly — each switch shows the right body, moves focus correctly, and re-selects the right tree node.
2. **Logical-node scroll target**: clicking a `THSurveyNode` two levels deep in a `.th` file opens that file's tab (creating it if not already open) with `pendingScrollToLine` set to its 0-based line, distinct from clicking the file node itself (which opens with no pending scroll).
3. **Dirty-dot parity**: editing a scrap on the canvas shows the same tree dirty dot behavior a text-editor edit already shows; saving (via the page shortcut or the canvas's own save button) clears it.
4. **Closing a text-editor tab** disposes its controller (no dangling debounce `Timer`, matching the Phase 5 test-teardown lesson) and, if it's not the last tab, keeps the tree/tab selection consistent with whichever tab becomes active.

---

## 14. Localization & Documentation Touches

- One new string: a load-error message for `THTextEditorTabBodyWidget` (e.g. `textEditorTabLoadFailedMessage`), added to `intl_en.arb`/`intl_pt.arb` following the existing `textEditor*` key convention from Phase 5.
- No all-caps UI text.
- Help pages and keyboard-shortcut tables remain deferred to Phase 8, per the top-level roadmap (same exception already used by Phases 4 and 5).

---

## 15. Risks & Open Questions

1. **`IndexedStack` keeps every tab's widget subtree alive simultaneously.** Adding a second, heavier widget type (a `RichText`-based syntax overlay per open `.th`/`thconfig` tab) to the same `IndexedStack` as canvas tabs means more concurrently-live widgets than today. Mitigation: this mirrors the existing `.th2` canvas cost (also kept alive per open tab today) and Phase 5's own large-file tokenization mitigation (debounced content snapshot, cached tokens) already bounds the per-tab cost; revisit only if real usage shows a problem.
2. **Reverse tree sync on every `setActiveTab` call could fight the user's manual tree scroll/collapse state** if they collapse a branch right after switching tabs and then switch tabs again. Mitigation: `expandAncestorsOf` only *expands* (never collapses) and is idempotent, matching the existing filter auto-expand behavior from Phase 4 that users are already used to; no new collapse-fighting behavior is introduced.
3. **`THTextEditorController.textEditorFocusNode` conflicting with the widget's own internal Tab/Escape key handling** (`_handleKeyEvent` in `THTextEditorWidget`, from Phase 5) if the outer `Focus` node and an inner one both claim key events. Mitigation: Phase 5's `Focus(onKeyEvent: _handleKeyEvent)` is the *outermost* Focus in the widget already (wrapping the `Row` that contains the `TextField`); swapping its `autofocus: true` for `focusNode: controller.textEditorFocusNode` doesn't change its position in the tree, only how it receives focus, so existing key handling is unaffected.
4. **`dirtyFilePaths` mirroring reaction firing during `close()`'s teardown ordering.** `_disposeReactions()` cancels the reaction before `removeFileTab` runs, so no stale write can land after a tab is gone; verified against the existing `close()` body order (`_disposeReactions()` before `removeFileTab`).
