<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 9: Multi-File Find/Replace — Implementation Plan

**Date:** 2026-08-31
**Status:** Proposed — validated against the codebase 2026-08-31 (grounding seams re-checked; two-layer reparse race, missing all-nodes accessor, non-throwing `save()`, and pre-existing Unicode offset bug folded into §2/§6.2/§7.2–7.3/§13).

## 1. Overview & Objectives

This document details **Phase 9** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It builds directly on Phase 5's implemented single-file find/replace and Phase 6's mixed-tab integration. Phases 7 and 8 are not technical prerequisites, although Phase 9 must follow their localization, help, and testing conventions.

Phase 9 adds one search surface for finding plain-text matches across multiple `thconfig` and `.th` files, grouping results by file, navigating to an exact match, and replacing all matches across the selected scope. It reuses each file's `THTextEditorController` for edits and saving so replacement has the same dirty tracking, debounced parsing, project-tree updates, encoding-aware writers, and error reporting as a normal editor change.

### Key objectives

1. **Two explicit scopes**: search either all open text-editor tabs or all writable text files in the loaded project.
2. **Grouped, navigable results**: show file groups with line previews and match counts; activating a result opens or focuses the file tab and selects the exact match.
3. **Shared match semantics**: extract the existing single-file plain-substring matcher and use it for both single-file and multi-file search.
4. **Safe project-wide replacement**: precompute all changed contents, require confirmation, then apply each file through `THTextEditorController.setContent()` and `save()`.
5. **Correct save ordering**: flush a controller's pending reparse before serialization so immediate Find/Replace → Save cannot write the previous parsed model.
6. **Responsive asynchronous search**: debounce query changes, ignore superseded searches, keep result ordering deterministic, and surface per-file read failures without aborting the whole search.
7. **Complete integration**: add the project-search shortcut, EN/PT localization and help updates, focused unit/widget/integration tests, and full static analysis.

## 2. Grounding: Current State

The repository currently provides the following implementation seams:

- `THTextEditorController` owns one open text file's `content`, local find/replace state, dirty state, reparse debounce timer, save/revert behavior, focus node, and pending line navigation.
- Its `findMatches` getter performs a case-sensitive or case-insensitive, non-overlapping, left-to-right plain substring scan. Regex, whole-word, and structural search do not exist.
- `replaceActiveMatch()` and `replaceAllMatches()` already call `setContent()`, preserving the normal dirty/reparse behavior.
- `THTextEditorWidget` provides the single-file `Ctrl/Cmd+F` bar, match highlighting, active-match scrolling, case sensitivity, replacement controls, and `Esc` handling.
- `MPGeneralController` keeps normalized paths in `openFileOrder` and a private `THTextEditorController` registry. `getTextEditorController()` creates/reuses a controller, while `getTextEditorControllerIfExists()` supports read-only lookup.
- `TH2FileTabsPage` owns the workspace-level shortcut layer and mixed `.th2`/text tab strip. It is the correct place to bind a project-level shortcut without changing the editor-local `Ctrl/Cmd+F` behavior.
- `THProjectController.fileContentsCache` (public `ObservableMap<String, String>`) contains the latest text for every project `THConfigFileNode`/`THDataFileNode`, keyed by canonical path; `nodeByCanonicalPath()` is a single-path lookup that identifies writable `THConfigFileNode`/`THDataFileNode` nodes, and `saveProjectFile()` serializes the parsed model through the existing lossless writers.
- `THProjectController` exposes **no public iterator over all file nodes** — `_nodesByCanonicalPath` is private. The project-wide file set must be obtained either by walking `projectRootNode` recursively, by iterating `fileContentsCache.keys` (already populated for exactly the config/data node set by `_populateFileContentsCache`), or by adding a new public accessor. Phase 9 picks one explicitly in §6.2.
- `saveProjectFile()` does **not** throw on failure: it catches write errors and appends a `THProjectParseError` to `projectErrors`, and it silently returns on an unknown path or a `.th2` file with no open editor. `THTextEditorController.save()` returns `Future<void>` and only clears `isDirty` when the path has left `dirtyFilePaths`. Phase 9 must detect save failures by inspecting state (path still in `dirtyFilePaths` / `controller.isDirty` still true, or a `projectErrors` diff around the call), not by awaiting a throwing future.
- There are **two** reparse debounce layers, not one. `THTextEditorController.setContent()` schedules an editor-level `_reparseTimer` that calls `THProjectController.reparseFile()`; `reparseFile()` is *itself* debounced — it writes `fileContentsCache`/`dirtyFilePaths` synchronously, then schedules `_performReparse` on a project-level timer and returns. `_performReparse` is what splices the fresh node the writers serialize (and it may `await reloadProject()`). Calling `save()` before both timers drain serializes the stale node. Phase 9 must close this race across both layers before using immediate multi-file replace-and-save (see §7.3).
- Fixed dimensions and debounce durations live in `lib/src/constants/mp_constants.dart` (existing: `mpTextEditorReparseDebounceMilliseconds`, `mpProjectReparseDebounceMilliseconds`).
- The latest allocated test prefix is `t3919`; Phase 9 should begin at `t3920`, after confirming the number again at implementation time. Note the repo already contains a `t3918` collision (two files share that prefix), so the confirmation step must scan for duplicates, not just take the maximum.

## 3. Scope and Non-Goals

### In scope

- Plain-text search across all open `thconfig`/`.th` text tabs.
- Plain-text search across every unique `THConfigFileNode` and `THDataFileNode` in the loaded project, including unopened files.
- Unsaved open-editor content taking precedence over cached/disk content in both scopes.
- Case-sensitive and case-insensitive matching with the same semantics as single-file find.
- File-grouped results with relative path, match count, one-based line/column, and a single-line preview.
- Result navigation that opens/focuses a text tab, expands/selects the corresponding project-tree node through the existing tab synchronization, scrolls to the result, and selects the exact range.
- Project-wide Replace All with a localized confirmation describing affected file and match counts.
- Automatic saving of affected files after replacement, as required by the roadmap, through each controller's existing save path.
- Partial-failure reporting that identifies files that could not be read, parsed, or saved.
- `Ctrl/Cmd+Shift+F` for multi-file search while retaining `Ctrl/Cmd+F` for the active editor.
- EN/PT localization, help-page updates, and shortcut-table updates.

### Out of scope

- Searching or replacing `.th2` source text; `.th2` remains canvas-owned.
- Searching missing-file placeholders, imported binary/3D files, generated outputs, Therion logs, help assets, or files outside the loaded project/open text tabs.
- Regex, whole-word, fuzzy, semantic, symbol, or case-folding beyond Dart's existing `toLowerCase()` behavior.
- Per-result replacement, interactive replacement confirmation one match at a time, or replacement history.
- A cross-file undo transaction. The confirmation dialog and preflight are the protection for an operation that saves multiple files.
- Filesystem watching or automatically including files that are not represented in the loaded project tree.
- A background isolate in the first implementation. Search remains asynchronous and debounced; isolate work is a later optimization only if profiling demonstrates a need.
- Changing single-file `Ctrl/Cmd+F` into multi-file search.

## 4. User Experience

### 4.1 Entry points and sidebar mode

Add a search action to the project sidebar header and bind `Ctrl/Cmd+Shift+F` at `TH2FileTabsPage`. Either action:

1. expands the project sidebar if it is collapsed;
2. switches the sidebar from tree mode to project-search mode; and
3. focuses/selects the multi-file query field.

The search view has a back/tree action. Returning to tree mode preserves the current query, options, expansion state, and results for the lifetime of the loaded project. Closing/replacing the project clears project-scope results because their paths are no longer valid; open-files scope may be searched again against whatever text tabs remain open.

`THProjectTreeUIController` should own the sidebar mode because it already owns sidebar expansion and project-tree presentation state. Search query/results belong to the new search controller, not the tree UI controller.

### 4.2 Search controls

The search header contains:

- query field;
- replacement field behind the same expand/collapse affordance used by the single-file find bar;
- case-sensitivity toggle;
- scope selector: **Open text tabs** or **Project files**;
- refresh/search action;
- Replace All action, disabled when the query is empty, no matches exist, a search is running, or a replacement is running;
- progress indication while searching/replacing; and
- a compact summary such as “23 matches in 4 files”.

Default to **Project files** when a project is loaded and **Open text tabs** when there is no loaded project. If project scope is selected after the project closes, automatically fall back to open-tabs scope and clear stale project results.

Query, case, and scope changes trigger a short debounce. Submitting the query or pressing the refresh action searches immediately.

### 4.3 Results

Results are ordered deterministically:

1. files by project-relative path using case-insensitive comparison with canonical path as the tie-breaker;
2. matches within a file by ascending UTF-16 offset.

Each file group shows its relative path (or canonical path for an open tab outside the project), match count, and an expand/collapse control. Each match row shows one-based line and column plus a trimmed one-line preview. The matching portion of the preview is visually emphasized without altering the source text.

Empty and exceptional states are distinct and localized:

- empty query;
- no open text tabs;
- no project loaded for project scope;
- no matches;
- search completed with one or more unreadable files; and
- replacement completed with one or more failed files.

### 4.4 Navigation

Activating a match:

1. validates that the result range still contains the query under the selected case rule;
2. if stale, refreshes the search and resolves the nearest current match in the same file, or reports that the match no longer exists;
3. gets/creates the target `THTextEditorController`;
4. records a pending exact selection range;
5. opens or focuses the tab through `MPGeneralController.addFileTab()`; and
6. lets existing tab-to-tree synchronization select and reveal the file node.

Add `pendingSelectionRange`/`revealRange(TextRange range)` to `THTextEditorController`, analogous to `pendingScrollToLine`. `THTextEditorWidget` consumes it after content is loaded, updates the text selection, scrolls both axes as needed, requests editor focus, and clears the pending value. This avoids mutating the single-file `findQuery` merely to navigate from a project result.

## 5. Search Models and Pure Matching Logic

### 5.1 File organization

```text
lib/src/
 ├── auxiliary/
 │    └── th_text_search_aux.dart                 # Shared pure matcher, line/preview helpers
 ├── controllers/
 │    ├── th_project_search_controller.dart       # Multi-file search/replace orchestration
 │    ├── th_project_search_controller.g.dart     # Generated by the existing watch process
 │    ├── th_project_tree_ui_controller.dart      # Sidebar tree/search mode
 │    └── th_text_editor_controller.dart          # Shared matcher + flush/reveal additions
 ├── elements/th_project_search/
 │    ├── th_project_search_scope.dart
 │    ├── th_project_search_match.dart
 │    ├── th_project_search_file_result.dart
 │    └── th_project_search_failure.dart
 ├── widgets/
 │    ├── th_project_search_widget.dart            # Controls, grouped results, empty/error states
 │    ├── th_project_search_result_widget.dart     # File group and match rows
 │    ├── th_project_tree_widget.dart              # Header entry/switch to search mode
 │    └── th_text_editor_widget.dart               # Consumes pending exact selection
 ├── pages/
 │    └── th2_file_tabs_page.dart                  # Ctrl/Cmd+Shift+F binding
 └── auxiliary/mp_locator.dart                     # Lazy project-search controller
```

The exact split of the small immutable result model files may be collapsed during implementation if keeping them together improves readability. Generated `.g.dart` output is never edited manually and `build_runner` is not run manually.

### 5.2 Shared matcher

Extract the existing algorithm from `THTextEditorController.findMatches` into a pure helper:

```dart
List<TextRange> findPlainTextMatches({
  required String content,
  required String query,
  required bool caseSensitive,
});
```

The helper preserves current behavior exactly:

- empty query returns no matches;
- matches are non-overlapping and left-to-right;
- offsets are UTF-16 offsets compatible with Flutter `TextRange`/`TextSelection`; and
- the loop is bounded by the content length and advances by the non-empty query length after every match.

`THTextEditorController.findMatches` delegates to this helper. Multi-file search calls the same helper for every source snapshot. Existing `t3905` tests remain the compatibility suite; new pure-helper tests cover line/column and preview derivation.

#### Case-insensitive matching without offset drift

Case-insensitive mode must **not** simply scan a fully lowercased haystack and reuse the lowercase offsets (the current single-file behavior — see §13.4). `String.toLowerCase()` follows Unicode default case mapping, which is not guaranteed 1:1 in UTF-16 code units (`İ` U+0130 → `i` + U+0307, 1 unit → 2). One such character before a match shifts every later offset, so the returned `TextRange` points at the wrong span of the original text.

The helper takes a fast path plus an offset-mapped slow path:

1. Compute `lowerContent = content.toLowerCase()` and `lowerQuery = query.toLowerCase()` (case-insensitive mode already pays one `toLowerCase()` today, so no new cost here).
2. **Fast path** — when `lowerContent.length == content.length` *and* `lowerQuery.length == query.length`, every fold was 1:1, so run the existing bounded `indexOf` loop over `lowerContent`; its ranges are already valid against `content`. This covers all ASCII and Latin-1 text.
3. **Slow path** — otherwise, rebuild the lowercase haystack rune-by-rune (iterate code points via `content.runes`, not code units, because Adlam/Deseret are cased and non-BMP), lowercasing each rune and appending to a `StringBuffer` while pushing that rune's original UTF-16 start offset once per produced code unit into a parallel `List<int>` (`toOrig`), with a trailing sentinel of `content.length`. Fold the query the same rune-by-rune way (`_foldPerRune`) for consistency (e.g. Greek sigma). Run `indexOf` over the rebuilt string; for each hit at `found`, emit `TextRange(start: toOrig[found], end: toOrig[found + foldedQuery.length])` and advance `start` by `foldedQuery.length` (non-overlapping).

`toOrig` is transient; use `Uint32List`-backed growth only if profiling on a very large file shows it matters. Case-sensitive mode is unchanged (plain scan over `content`).

### 5.3 Result models

Use immutable result snapshots. A representative shape is:

```dart
enum THProjectSearchScope { openTextTabs, projectFiles }

class THProjectSearchMatch {
  final String canonicalPath;
  final TextRange range;
  final int lineNumber;
  final int columnNumber;
  final String linePreview;
  final TextRange previewMatchRange;
}

class THProjectSearchFileResult {
  final String canonicalPath;
  final String displayPath;
  final String searchedContent;
  final List<THProjectSearchMatch> matches;
}
```

Keeping the searched content snapshot with each file result enables stale-result validation and one-pass Replace All without rereading a file between preview and replacement. Do not expose mutable controller content through result models.

Failures carry canonical/display path and a logged technical message. UI text uses localized summaries; raw exception details stay in logs unless the existing error-dialog convention explicitly displays them.

## 6. `THProjectSearchController`

### 6.1 Responsibilities and observable state

Create a lazy singleton in `MPLocator`, matching the app's single-project model. The controller owns:

- `query` and `replacement`;
- `caseSensitive`;
- `scope`;
- `isSearchVisible`, `isSearching`, and `isReplacing`;
- immutable/observable file results and failures;
- expanded result-file paths;
- a debounce timer;
- a monotonically increasing search generation; and
- the project root path associated with the current project-scope result snapshot.

The controller does not own editor widgets, `TextEditingController`s, tabs, parsing, or disk serialization.

### 6.2 Source collection

For **Open text tabs**:

- iterate `MPGeneralController.openFileOrder`;
- exclude `isTH2Tab(path)` entries;
- obtain existing controllers without creating new ones;
- skip/loading-report a controller whose file has not completed loading; and
- use `controller.content`, which includes unsaved changes.

For **Project files**:

- enumerate the project's text-file set. `THProjectController` has no public all-nodes iterator today, so Phase 9 **adds one** — a public accessor returning the canonical paths (or nodes) of every `THConfigFileNode`/`THDataFileNode` — rather than reaching into private state or relying on `fileContentsCache.keys` alone (the cache can lag a freshly added include until its reparse completes). Walking `projectRootNode` recursively is the fallback if a dedicated accessor is rejected in review;
- include only `THConfigFileNode` and `THDataFileNode`;
- deduplicate by canonical path because the same included file may appear more than once in the dependency tree;
- if an open controller exists, use its content first;
- otherwise use `THProjectController.fileContentsCache`;
- only fall back to `THProjectParser.readFileContent()` when the cache has no entry; and
- handle one file's read failure as a `THProjectSearchFailure` while continuing with all remaining files.

Source collection must snapshot path/content pairs before matching. A search never reads mutable controller state halfway through scanning a file.

### 6.3 Debounce and stale searches

Increment the generation whenever a new search starts or state is cleared. After each asynchronous source read and before publishing results, compare the captured generation to the current generation. A superseded search exits without modifying visible results or errors.

Search query changes use a constant defined in `mp_constants.dart`; submitting runs immediately and cancels the pending timer. Do not use an unbounded periodic task.

The first implementation may scan snapshots on the UI isolate. Publish `isSearching` before asynchronous reads so the UI remains honest. If profiling later shows unacceptable pauses on real projects, the pure matcher and immutable snapshots are already suitable for isolate extraction.

### 6.4 Project lifecycle

Expose `clearForClosedProject()` and call it from the same close/open-project flow that clears project-tree state. It cancels pending work, invalidates the generation, clears project results/failures/expanded groups, and switches project scope to open-tabs scope when appropriate.

Tests must prove that a late result from project A cannot appear after project B is loaded.

## 7. Replace All Pipeline

### 7.1 Confirmation and preflight

Replace All is available only for a non-empty query and a current, completed result set. Before any mutation:

1. re-run search immediately to eliminate stale snapshots;
2. build every replacement string in memory using the shared non-overlapping ranges, from the end of the file toward the start or via one `StringBuffer` pass;
3. discard unchanged files;
4. verify every affected path still resolves to a writable `THConfigFileNode`/`THDataFileNode` (or an already-open out-of-project text controller when open-tabs scope is selected);
5. verify unopened project files can be read and every target's parent location is writable according to the repository's existing I/O conventions; and
6. show a localized confirmation with match count, file count, scope, and a warning that the operation saves the affected files and cannot be undone as one cross-file action.

Cancellation makes no changes. A preflight failure makes no changes and leaves the current results visible with failure details.

### 7.2 Applying through editor controllers

For an already-open file, reuse its registered controller. For an unopened project file, create a temporary `THTextEditorController` injected with the existing `THProjectController`, load it, apply/save, and dispose it in `finally`; do not add hidden controllers to `MPGeneralController` and do not open every changed file as a side effect.

For each affected file, in deterministic path order:

1. call `setContent(replacedContent)` exactly once;
2. call `save()` and await it, then determine success explicitly — `save()` never throws and `saveProjectFile()` swallows write errors into `projectErrors`. Treat the file as failed if its canonical path is still in `THProjectController.dirtyFilePaths` (equivalently `controller.isDirty`) after the await, or if `projectErrors` gained an entry for that path during the call;
3. retain the controller and updated visible content when it belongs to an open tab; and
4. dispose only temporary controllers.

Do not call `File.writeAsString`, `THConfigFileWriter`, or `THFileWriter` from the search controller. All writes remain visible through the existing editor/project-controller boundary.

### 7.3 Flush-before-save prerequisite

The race spans **two** debounce layers (see §2), so awaiting `THProjectController.reparseFile()` is not sufficient — it only schedules the project-level timer and returns before `_performReparse` runs. Both layers must drain.

Add an awaitable `THProjectController.flushPendingReparse(String canonicalPath)` that:

- cancels `_reparseTimers[canonicalPath]` if present;
- awaits the actual reparse work for that path directly (invoke the same code path `_performReparse` runs, including its possible `await reloadProject()`), using the latest `fileContentsCache[canonicalPath]` / pending content;
- is a no-op when nothing is pending for that path; and
- coalesces concurrent callers so one content revision is not reparsed twice.

Then add an awaitable `THTextEditorController.flushPendingReparse()` that:

- cancels the editor-level `_reparseTimer`;
- if the controller is dirty, pushes current `content` through `THProjectController.reparseFile(...)` **and then** awaits `THProjectController.flushPendingReparse(canonicalPath)` so the project-level timer is drained too; and
- is awaited at the start of `save()` before `saveProjectFile()` is invoked.

Track a content revision or pending-content snapshot so an edit that arrives while a flush is running schedules a subsequent reparse instead of being marked saved accidentally. This behavior also fixes immediate single-file edit/replace → `Ctrl/Cmd+S`; add regression coverage there.

### 7.4 Failure behavior

Multi-file disk writes are not transactional. All targets are prepared before the first mutation, but a later I/O failure can still occur after earlier files were saved. Therefore:

- continue or stop according to a single documented policy; use **continue and collect failures** so independent files can complete;
- leave any failed open controller dirty with its replacement content intact;
- preserve a failed temporary controller's replacement by keeping the corresponding content in `THProjectController.fileContentsCache`/dirty tracking rather than silently discarding it, or explicitly restore its pre-operation snapshot if that is safer with the final controller implementation;
- log each exception with path and stack trace;
- report saved file/match counts and failed file paths in a localized completion dialog; and
- re-run search against the resulting in-memory state after all attempts finish.

The implementation must choose and test the exact temporary-controller failure preservation branch before coding the UI; no failure may be swallowed.

## 8. Widget and Shortcut Integration

### 8.1 `THProjectSearchWidget`

Build the search view as a normal sidebar child under an `Observer`. Keep query/replacement `TextEditingController`s and field `FocusNode`s in widget state, synchronized with the MobX controller using the same guarded-listener pattern as `THTextEditorWidget`.

Use constants in `mp_constants.dart` for debounce and any new fixed dimensions. All strings come from `mpLocator.appLocalizations`. File paths and source previews are data, not localizable strings.

Keep action buttons visible while result rows scroll. Any confirmation/completion dialog with scrolling content uses `MPDialogBottomWidget` for its persistent bottom actions.

### 8.2 Keyboard behavior

- `Ctrl/Cmd+Shift+F`: open/focus multi-file search from anywhere in `TH2FileTabsPage`.
- `Ctrl/Cmd+F`: unchanged; opens the active `THTextEditorWidget`'s single-file bar.
- `Enter` in the project query field: run immediately.
- `Escape`: return focus to the search results/editor as appropriate; it must not close unrelated dialogs or the project.
- Arrow/Enter activation for result rows should follow Flutter's standard focus/activation behavior rather than a custom global key handler.

Ensure the page-level shortcut does not steal `Ctrl/Cmd+Shift+F` while a modal dialog or editable control has a more specific binding.

### 8.3 Exact-range navigation in `THTextEditorWidget`

Consume `pendingSelectionRange` after controller content is synchronized into the widget's `TextEditingController`. Clamp the range to content length, apply a `TextSelection`, scroll to its line using the existing line-height logic, horizontally reveal the selected text where possible, request the controller's focus node, then clear the pending request.

Keep the existing `pendingScrollToLine` path for tree/diagnostic navigation. If both requests are present, exact selection wins and clears only its own request; define this precedence in tests.

## 9. Localization and Documentation

Add EN/PT localization keys for:

- sidebar search/tree actions and title;
- query/replacement hints;
- scope labels;
- case-sensitive, refresh, Replace All, and close/back tooltips;
- match/file summary plurals;
- empty/no-project/no-tabs/no-results states;
- searching/replacing progress;
- Replace All confirmation and irreversible multi-file warning;
- read/preflight/save failure summaries; and
- completion counts, including partial success.

Keep placeholder names and plural/select structures identical in `intl_en.arb` and `intl_pt.arb`. Run `flutter gen-l10n`; never edit generated localization files manually.

Update English and Portuguese help pages to explain:

- `Ctrl/Cmd+F` searches the active text file;
- `Ctrl/Cmd+Shift+F` searches multiple files;
- the difference between open-tabs and project scopes;
- `.th2` exclusion;
- navigation and stale-result refresh behavior; and
- Replace All confirmation, automatic saving, and lack of one-step cross-file undo.

Add the shortcut to the appropriate keyboard-shortcut table in alphabetical order in both languages. If Phase 8 created a dedicated project-tree help page, extend it; otherwise update the final project/text-editor help page chosen by Phase 8 rather than creating a competing page.

## 10. Implementation Sequence

1. Reconfirm the post-Phase-8 source/help layout and the next unused test prefix.
2. Extract `findPlainTextMatches` and line/preview helpers; redirect single-file find to the shared helper. Behavior is unchanged except the case-insensitive path gains the offset-drift fix from §5.2 (fast path is identical to today; slow path only engages on length-changing folds).
3. Add `THProjectController.flushPendingReparse(canonicalPath)` (drains the project-level timer) and `THTextEditorController.flushPendingReparse()` (drains the editor-level timer, then chains into the project-level flush); make `save()` await the editor-side flush. Cover immediate-save races across both layers before multi-file replacement work.
4. Add `pendingSelectionRange`/`revealRange()` and exact-range consumption in `THTextEditorWidget`.
5. Add immutable search models and `THProjectSearchController` source collection, debounce, generation cancellation, ordering, and project-lifecycle reset.
6. Register the controller lazily in `MPLocator` and add tree/search mode to `THProjectTreeUIController`.
7. Build grouped-results widgets and integrate them into the project sidebar.
8. Wire result activation through existing tab opening/focus/tree synchronization.
9. Implement Replace All preflight, confirmation, temporary-controller handling, sequential setContent/flush/save, failure collection, and result refresh.
10. Add the `Ctrl/Cmd+Shift+F` page shortcut and verify single-file `Ctrl/Cmd+F` remains unchanged.
11. Add EN/PT localization, run `flutter gen-l10n`, and update EN/PT help/shortcut documentation.
12. Run focused tests, the complete `flutter test` suite, and `flutter analyze`; resolve every warning/error.
13. Review the final diff for accidental `.th2` inclusion, direct file writes, stale-result races, unlocalized UI text, EN/PT parity, and changes outside Phase 9.

Formatting remains automatic on commit; do not run `dart format` manually.

## 11. Test Plan

Confirm numbering immediately before implementation. With the current tree, use:

| Test file | Required coverage |
| --- | --- |
| `test/t3920_th_text_search_aux_test.dart` | Shared plain matcher compatibility, non-overlap, empty/long queries, case modes, bounded progression, line/column calculation, preview trimming/highlighting. **Offset-drift coverage**: `İ` (U+0130) before the search term — corrected range covers the right span, not shifted by +1; mixed `İ`/`i`/`I` case-insensitive hit/miss and ranges; non-BMP cased text (Adlam U+1E900–U+1E943 or Deseret) case-insensitive to prove rune iteration; ASCII and Latin-1 (`é`, `ñ`, `ç`) identical to pre-refactor `t3905` expectations (fast path untouched). |
| `test/t3921_th_text_editor_save_flush_test.dart` | Immediate edit/replace then save reparses before serialization across **both** debounce layers (editor `_reparseTimer` and project `_reparseTimers`); `flushPendingReparse` drains a pending `reloadProject()` path; timer cancellation; concurrent save coalescing; edit during flush remains dirty and is reparsed later. |
| `test/t3922_th_text_editor_reveal_range_test.dart` | Pending range survives load, clamps safely, selects and scrolls exact match, takes precedence over line-only navigation, then clears. |
| `test/t3923_th_project_search_controller_test.dart` | Open-tabs/project source collection, unsaved controller precedence, canonical deduplication, `.th2`/missing exclusion, deterministic ordering, no-project/no-tabs states, file read failures. |
| `test/t3924_th_project_search_stale_generation_test.dart` | Debounce, immediate submit, superseded async search suppression, query changes, project close/replacement, no result leakage from an old project. |
| `test/t3925_th_project_search_widget_test.dart` | Controls, scope selection, grouped rows, counts/plurals, expand/collapse, empty/error/loading states, keyboard focus, EN/PT smoke rendering. |
| `test/t3926_th_project_search_navigation_test.dart` | Existing/new tab activation, exact selection, out-of-project open tab, project-tree selection/ancestor expansion, stale-match refresh and disappeared match. |
| `test/t3927_th_project_search_replace_all_test.dart` | Confirmation/cancel, one setContent per file, open and temporary controllers, flush-before-save, automatic save, case semantics, empty replacement, partial failures, disposal, refreshed results. |
| `test/t3928_th2_file_tabs_page_project_search_shortcut_test.dart` | `Ctrl/Cmd+Shift+F` opens/focuses project search; collapsed sidebar expands; `Ctrl/Cmd+F` remains editor-local; shortcut behavior with canvas/text tabs and dialogs. |
| `test/t3929_phase9_documentation_localization_test.dart` | EN/PT key parity, registered help assets, both shortcut descriptions, no claim that `.th2` is searched, and documented Replace All save/undo behavior. |

Retain and run `t3905_th_text_editor_find_replace_test.dart` as a regression suite after extracting the matcher.

### End-to-end scenarios

1. Load a project with nested/repeated includes, leave one `.th` unopened, edit another open `.th` without saving, search project scope, and see each canonical file exactly once with the unsaved match included.
2. Activate a result in an unopened file and land on the exact match in a new text tab while the project tree selects/reveals that file.
3. Start a slow project search, close/open another project, and verify no old result or failure appears in the new project.
4. Replace a case-insensitive query across open and unopened project files, confirm once, save through controllers/writers, refresh the tree/parser state, and observe zero old matches.
5. Force one target save to fail and verify successful files remain saved, the failed file is clearly reported and recoverable/dirty according to the chosen policy, and no error is swallowed.

## 12. Acceptance Criteria

- `Ctrl/Cmd+Shift+F` opens a localized multi-file search surface without changing single-file `Ctrl/Cmd+F`.
- Users can search open text tabs or all loaded-project `thconfig`/`.th` files; `.th2` and missing/imported non-text files never appear.
- Unsaved open-editor content is searched instead of stale cache/disk content.
- Results are deterministic, grouped by file, show accurate line/column previews, and navigate to/select the exact current match.
- Repeated project references are deduplicated by canonical path.
- Search remains correct when queries change rapidly or a project closes/changes during asynchronous work.
- Multi-file Replace All requires confirmation, computes all changes before mutation, uses one `setContent()` per affected file, flushes parsing before save, and never introduces a direct writer path in the search controller.
- Immediate single-file save after editing/replacement also serializes the latest content.
- Read/parse/save failures are logged and surfaced per file; successful and failed counts are unambiguous.
- Open controllers remain open and synchronized; temporary controllers are disposed on every success/failure path.
- New UI strings and help/shortcut documentation are complete and equivalent in English and Portuguese.
- Focused tests, the full test suite, and `flutter analyze` pass with no warnings.

## 13. Risks and Decisions to Verify During Implementation

1. **Save semantics after replacement**: the roadmap explicitly calls for `setContent`/`save`, so this plan auto-saves after confirmation. The confirmation must make that behavior unmistakable, especially when an affected open editor already contains unsaved edits.
2. **Temporary-controller save failure**: disposing a failed temporary controller can discard the only editor-owned replacement snapshot. Resolve this by either retaining the failed content in project dirty/cache state or restoring the original snapshot, then lock the policy with tests before widget work.
3. **Large-project responsiveness**: full scans are linear in total text plus match count. Debouncing, snapshotting, stale-generation cancellation, and bounded matcher progress are required; isolate extraction waits for profiling evidence.
4. **Unicode case conversion**: the shipped single-file `findMatches` lowercases the whole haystack (`content.toLowerCase()`) before matching, so any length-changing case fold (`İ` U+0130 → `i` + U+0307) already yields `TextRange` offsets that are wrong against the original `content`. Extracting the helper preserves this latent bug rather than introducing it, and the existing `t3905` suite contains no length-changing cases, so it will not catch a regression here. Phase 9 fixes it as a **fix beyond parity** using the fast-path + offset-mapped slow-path algorithm specified in §5.2 ("Case-insensitive matching without offset drift"), gated by the offset-drift tests listed for `t3920` in §11 (U+0130 before the term, mixed `İ`/`i`/`I`, non-BMP cased text, ASCII/Latin-1 parity).
5. **External file changes**: no filesystem watcher is added. Result activation validates its snapshot, and explicit refresh/new query reads current sources; files modified externally after project parsing remain subject to the existing project reload behavior.
6. **Cross-file undo**: Flutter's per-widget editing history cannot provide an atomic undo across open and temporary controllers. Confirmation, preflight, and explicit automatic-save wording are mandatory until a future command/transaction layer is designed for text files.
