<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 9: Multi-File Find/Replace — Implementation Plan

**Date:** 2026-08-31
**Status:** Proposed — validated against the codebase 2026-08-31 (grounding seams re-checked; two-layer reparse race, in-memory full-reload requirement, project-epoch isolation, explicit revision-aware save results, missing all-nodes accessor, and pre-existing Unicode offset bug folded into §2/§6.2/§7.2–7.3/§13).

## 1. Overview & Objectives

This document details **Phase 9** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It builds directly on Phase 5's implemented single-file find/replace and Phase 6's mixed-tab integration. Phases 7 and 8 are not technical prerequisites, although Phase 9 must follow their localization, help, and testing conventions.

Phase 9 adds one search surface for finding plain-text matches across multiple `thconfig` and `.th` files, grouping results by file, navigating to an exact match, and replacing all eligible matches across the selected scope. Standalone text tabs outside the loaded project remain searchable and navigable but are excluded from Replace All because the current project-controller writer has no parsed writable node for them. For eligible project files, Phase 9 reuses each file's `THTextEditorController` for edits and saving so replacement has the same dirty tracking, debounced parsing, project-tree updates, encoding-aware writers, and error reporting as a normal editor change.

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
- `THTextEditorController` has **no revision concept today**. `loadFile(String filePath)` takes only a path (reads `fileContentsCache` then falls back to `THProjectParser.readFileContent()`), `setContent(String newContent)` takes only content, `save()` returns `Future<void>` and infers success from `dirtyFilePaths.contains(...)`, and the constructor accepts an optional `THProjectController` for injection. Phase 9 extends `loadFile`/`setContent`/`save` with the revision and project-epoch plumbing described in §7.2–7.3; the current signatures are the baseline being changed, not existing behavior to reuse.
- `THProjectParser.loadProject()`/`loadFileNode()` are `static` and synchronous (return `THProjectLoadResult`); `THProjectController` runs them inside `Future<THProjectLoadResult>(() => ...)`. The override-map extension in §7.3 adds a parameter to these synchronous methods.
- `THTextEditorWidget` provides the single-file `Ctrl/Cmd+F` bar, match highlighting, active-match scrolling, case sensitivity, replacement controls, and `Esc` handling.
- `MPGeneralController` keeps normalized paths in `openFileOrder` and a private `THTextEditorController` registry. `getTextEditorController()` creates/reuses a controller, while `getTextEditorControllerIfExists()` supports read-only lookup.
- `TH2FileTabsPage` owns the workspace-level shortcut layer and mixed `.th2`/text tab strip. It is the correct place to bind a project-level shortcut without changing the editor-local `Ctrl/Cmd+F` behavior.
- `THProjectController.fileContentsCache` (public `ObservableMap<String, String>`) contains the latest text for every project `THConfigFileNode`/`THDataFileNode`, keyed by canonical path; `nodeByCanonicalPath()` is a single-path lookup that identifies writable `THConfigFileNode`/`THDataFileNode` nodes, and `saveProjectFile()` serializes the parsed model through the existing lossless writers.
- `THProjectController` exposes **no public iterator over all file nodes** — `_nodesByCanonicalPath` is private. The project-wide file set must be obtained either by walking `projectRootNode` recursively, by iterating `fileContentsCache.keys` (already populated for exactly the config/data node set by `_populateFileContentsCache`), or by adding a new public accessor. Phase 9 picks one explicitly in §6.2.
- `saveProjectFile()` does **not** currently report a reliable outcome: it catches write errors and appends a `THProjectParseError` to `projectErrors`, silently returns on an unknown path or a `.th2` file with no open editor, and `THTextEditorController.save()` returns `Future<void>`. Inferring success from `dirtyFilePaths`, `controller.isDirty`, or a before/after `projectErrors` diff is unsafe because full reloads replace those collections, parser diagnostics share `projectErrors`, and a concurrent edit may advance the revision during a write. Phase 9 must add an explicit, revision-aware text-save result and consume it directly (see §7.2–7.3).
- There are **two** reparse debounce layers, not one. `THTextEditorController.setContent()` schedules an editor-level `_reparseTimer` that calls `THProjectController.reparseFile()`; `reparseFile()` is *itself* debounced — it writes `fileContentsCache`/`dirtyFilePaths` synchronously, then schedules `_performReparse` on a project-level timer and returns. `_performReparse` is what splices the fresh node the writers serialize (and it may `await reloadProject()`). Calling `save()` before both timers drain serializes the stale node. Phase 9 must close this race across both layers before using immediate multi-file replace-and-save (see §7.3).
- The existing full-reload branches are not safe as a flush mechanism. Root-file, type-change, missing-parent, and reparse-error paths call `reloadProject()`, which reparses from disk; `_applyLoadResult()` then replaces `fileContentsCache` and `dirtyFilePaths` with disk-derived state. Therefore a flush that merely awaits the current `_performReparse()` path can discard the pending revision and any other unsaved files before `saveProjectFile()` serializes them. Phase 9 must add an in-memory full-project reparse path whose parser reads immutable dirty-content overrides and whose result application preserves dirty contents/revisions (see §7.3).
- Project close/open/reload currently cancels queued `_reparseTimers`, but it cannot cancel `_performReparse()` after a timer has fired and asynchronous parsing has begun. Such an operation can otherwise resume after project B replaces project A and mutate shared indexes, diagnostics, dirty state, or `isParsing`. Also, `openProject()` currently calls the public `closeProject()` as its reset implementation; once both public methods become epoch-advancing lifecycle boundaries, retaining that nesting would either advance twice or invalidate an epoch captured too early. Phase 9 must add a monotonically increasing project epoch captured by every search/reparse/flush/save operation, split non-advancing state clearing from public lifecycle transitions, and reject every stale post-`await` mutation (see §6.3–6.4 and §7.3).
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
- Search and exact-match navigation for standalone open text tabs outside the loaded project; their matches are visibly excluded from Replace All.
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
- Replacing or saving standalone text tabs that do not resolve to a writable `THConfigFileNode`/`THDataFileNode`. Supporting that requires a separate standalone parse/save contract and is not introduced by Phase 9.

## 4. User Experience

### 4.1 Entry points and sidebar mode

Add a search action to the project sidebar header and bind `Ctrl/Cmd+Shift+F` at `TH2FileTabsPage`. Either action:

1. expands the project sidebar if it is collapsed;
2. switches the sidebar from tree mode to project-search mode; and
3. focuses/selects the multi-file query field.

The search view has a back/tree action. Returning to tree mode preserves the current query, options, expansion state, and results for the lifetime of the loaded project. Closing/replacing the project clears the current results regardless of scope because project-backed open-tab results have just changed replacement eligibility; the query/options remain available so open-files scope can immediately search whatever text tabs remain open.

`THProjectTreeUIController` should own the sidebar mode because it already owns sidebar expansion and project-tree presentation state. Search query/results belong to the new search controller, not the tree UI controller.

### 4.2 Search controls

The search header contains:

- query field;
- replacement field behind the same expand/collapse affordance used by the single-file find bar;
- case-sensitivity toggle;
- scope selector: **Open text tabs** or **Project files**;
- refresh/search action;
- Replace All action, disabled when the query is empty, no replace-eligible matches exist, a search is running, or a replacement is running;
- progress indication while searching/replacing; and
- a compact summary such as “23 matches in 4 files”.

Default to **Project files** when a project is loaded and **Open text tabs** when there is no loaded project. If project scope is selected after the project closes, automatically fall back to open-tabs scope and clear stale project results.

Query, case, and scope changes trigger a short debounce. Submitting the query or pressing the refresh action searches immediately.

### 4.3 Results

Results are ordered deterministically:

1. files by project-relative path using case-insensitive comparison with canonical path as the tie-breaker;
2. matches within a file by ascending UTF-16 offset.

Each file group shows its relative path (or canonical path for an open tab outside the project), match count, and an expand/collapse control. Each match row shows one-based line and column plus a trimmed one-line preview. The matching portion of the preview is visually emphasized without altering the source text.

An open text tab whose canonical path does not currently resolve to a `THConfigFileNode` or `THDataFileNode` is a standalone search-only result. Its file group shows a localized search-only indicator/tooltip explaining that navigation is available but Replace All will not modify or save that file. Search totals include these matches; Replace All eligibility and confirmation/completion counts include only matches in writable project nodes. If every match is search-only, Replace All is disabled with the same localized explanation.

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
 ├── elements/th_project/
 │    ├── th_project_reparse_result.dart            # Revision/epoch-aware flush outcome
 │    └── th_text_file_save_result.dart             # Explicit revision-aware save outcome
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

The helper preserves the current structural behavior while fixing invalid Unicode source offsets:

- empty query returns no matches;
- matches are non-overlapping and left-to-right;
- offsets are UTF-16 offsets compatible with Flutter `TextRange`/`TextSelection`; and
- every returned source range is non-empty, ordered, and non-overlapping; and
- each scan loop is bounded by the searched representation's UTF-16 length and advances by the non-empty query length after every candidate match.

`THTextEditorController.findMatches` delegates to this helper. Multi-file search calls the same helper for every source snapshot. Existing `t3905` tests remain the compatibility suite; new pure-helper tests cover line/column and preview derivation.

#### Case-insensitive matching without offset drift

Case-insensitive mode must **not** simply scan a fully lowercased haystack and reuse the lowercase offsets (the current single-file behavior — see §13.4). `String.toLowerCase()` follows Unicode default case mapping, which is not guaranteed 1:1 in UTF-16 code units (`İ` U+0130 → `i` + U+0307, 1 unit → 2). One such character before a match shifts every later offset, so the returned `TextRange` points at the wrong span of the original text.

Use one rune-by-rune lowercase definition for both paths so optimization cannot change semantics:

1. Fold both content and query with `_foldPerRune`: iterate Unicode code points via `.runes`, create the string for each complete rune, call Dart's `toLowerCase()` on that rune string, and append the result. This supports cased non-BMP characters such as Adlam/Deseret and gives content/query identical folding rules. If the folded query is empty, return no matches defensively.
2. While folding, record whether every rune produced exactly the same number of UTF-16 code units as its original rune. A total-string length equality check is **not** sufficient evidence of aligned offsets; length preservation must hold for every rune.
3. **Fast path** — when both content and query are per-rune length-preserving, run the existing bounded `indexOf` loop over the folded content. Folded offsets then equal original UTF-16 offsets. This covers ASCII, Latin-1, and ordinary non-expanding Unicode mappings.
4. **Mapped path** — when any content rune changes UTF-16 length, rebuild the folded content together with two parallel arrays. For each UTF-16 code unit produced by an original rune, append that rune's original UTF-16 start to `sourceStarts` and its exclusive original UTF-16 end to `sourceEnds`. For a folded hit `[found, foldedEnd)`, project it back as:

   ```dart
   TextRange(
     start: sourceStarts[found],
     end: sourceEnds[foldedEnd - 1],
   )
   ```

   Thus searching for plain `i` in original `İ` returns `[0, 1]`, never `[0, 0]`. A candidate that touches only part of a multi-unit lowercase expansion intentionally consumes the complete originating rune for highlighting and replacement.
5. Advance the folded search cursor by `foldedQuery.length` after every candidate. Because different folded candidates can project onto the same original rune/range, accept a projected range only when it is non-empty and its start is at or after the previous accepted range's end; skip duplicate or overlapping projected ranges. This preserves left-to-right, non-overlapping source ranges safe for `substring`, highlighting, and Replace All.

If only the query changes length, the content's folded offsets still align with original offsets, so no content map is needed; scanning uses the folded query and direct content offsets. `sourceStarts`/`sourceEnds` are transient; use typed-array-backed growth only if profiling on a very large file demonstrates a need. Case-sensitive mode is unchanged (plain scan over `content`).

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
  final int? searchedRevision;
  final bool isReplaceEligible;
  final List<THProjectSearchMatch> matches;
}
```

Keeping the searched content/revision snapshot with each file result enables stale-result validation and one-pass Replace All without rereading a file between preview and replacement. Do not expose mutable controller content through result models.

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
- a monotonically increasing replacement-operation generation; and
- the project epoch and root path associated with the current result snapshot.

The controller does not own editor widgets, `TextEditingController`s, tabs, parsing, or disk serialization.

### 6.2 Source collection

For **Open text tabs**:

- iterate `MPGeneralController.openFileOrder`;
- exclude `isTH2Tab(path)` entries;
- obtain existing controllers without creating new ones;
- skip/loading-report a controller whose file has not completed loading; and
- use `controller.content`, which includes unsaved changes; and
- mark the file result replace-eligible only when `THProjectController.nodeByCanonicalPath(path)` currently returns a `THConfigFileNode` or `THDataFileNode`. Otherwise retain it as a standalone search-only result.

For **Project files**:

- enumerate the project's text-file set. `THProjectController` has no public all-nodes iterator today, so Phase 9 **adds one** — a public accessor returning the canonical paths (or nodes) of every `THConfigFileNode`/`THDataFileNode` — rather than reaching into private state or relying on `fileContentsCache.keys` alone (the cache can lag a freshly added include until its reparse completes). Walking `projectRootNode` recursively is the fallback if a dedicated accessor is rejected in review;
- include only `THConfigFileNode` and `THDataFileNode`;
- deduplicate by canonical path because the same included file may appear more than once in the dependency tree;
- if an open controller exists, use its content first;
- otherwise use `THProjectController.fileContentsCache`;
- only fall back to `THProjectParser.readFileContent()` when the cache has no entry; and
- handle one file's read failure as a `THProjectSearchFailure` while continuing with all remaining files.

Source collection must snapshot path/content/revision triples before matching. For a project-tracked file, `searchedRevision` is the project-controller-owned current revision associated with exactly `searchedContent`; standalone results use `null`. Read the content and revision through one synchronous snapshot boundary so a registered edit cannot produce a new revision between the two reads. A search never reads mutable controller state halfway through scanning a file.

### 6.3 Debounce and stale searches

Increment the search generation whenever a new search starts or state is cleared. At search start, also capture `THProjectController.projectEpoch` and `rootConfigPath`. After each asynchronous source read and before publishing results, require all three identities to remain current: search generation, project epoch, and project root path. A superseded search or changed project exits without modifying visible results, failures, progress state owned by a newer run, or replacement eligibility.

Increment the replacement-operation generation whenever Replace All begins and whenever replacement/search state is cleared or invalidated. Only the run that still owns that generation may mutate a target or clear `isReplacing`; a canceled or stale run cannot clear a newer run's progress in `finally`.

Search query changes use a constant defined in `mp_constants.dart`; submitting runs immediately and cancels the pending timer. Do not use an unbounded periodic task.

The first implementation may scan snapshots on the UI isolate. Publish `isSearching` before asynchronous reads so the UI remains honest. If profiling later shows unacceptable pauses on real projects, the pure matcher and immutable snapshots are already suitable for isolate extraction.

### 6.4 Project lifecycle

Expose a read-only monotonically increasing `THProjectController.projectEpoch`. Every lifecycle transition that clears or replaces the project identity/tree (`openProject`, explicit disk `reloadProject`, and `closeProject`) reserves exactly one new epoch **before** canceling timers or clearing state. The asynchronous load captures that epoch and intended canonical root; it applies its result and clears its own progress state only if both still match. The dirty-preserving in-memory full reparse in §7.3 is work within the same project and does not advance the epoch.

Implement that ownership with two private helpers rather than nesting public lifecycle methods:

```dart
int _beginProjectLifecycleTransition() {
  projectEpoch++;
  _cancelAllReparseTimers();
  _detachInFlightOperationsFromOlderEpochs();
  _resetActivityOwnershipForCurrentEpoch();

  return projectEpoch;
}

void _clearProjectState() {
  // Clear root/tree, indexes, diagnostics, caches, dirty/revision state,
  // selection, and loose errors. Do not advance the epoch or cancel work.
}
```

Both helpers are synchronous and are called inside the owning MobX action before its first `await`. `openProject()` canonicalizes the intended root, calls `_beginProjectLifecycleTransition()` exactly once, stores its returned epoch, calls `_clearProjectState()`, assigns the new root, and starts the load under that stored epoch. It must no longer call public `closeProject()`. `closeProject()` calls `_beginProjectLifecycleTransition()` once and then `_clearProjectState()`. A non-empty explicit disk `reloadProject()` snapshots the existing canonical root, calls `_beginProjectLifecycleTransition()` once, retains the current tree while loading, and applies the result only under the returned epoch/root; it does not call `_clearProjectState()` merely to reload. A no-project `reloadProject()` remains a no-op and does not advance the epoch.

Skipped numeric epoch values would not themselves violate identity comparisons, but the one-transition/one-increment rule prevents capture-order bugs and duplicate lifecycle reactions. In particular, no public lifecycle method calls another public lifecycle method, and no asynchronous operation captures its epoch before `_beginProjectLifecycleTransition()` returns.

Have `THProjectSearchController` react to `(projectEpoch, rootConfigPath)` and call `clearForProjectChange()`, including explicit reloads as well as close/open. It cancels pending work, invalidates both search and replacement-operation generations, clears results/failures/expanded groups regardless of scope (project-backed open-tab eligibility and source snapshots may have changed), and switches project scope to open-tabs scope when no project remains. Preserve the query/options so the user can immediately search again. Dispose this lifecycle reaction in tests/controller disposal.

Tests must prove that neither a late search result nor a late load/reparse/flush from project A can mutate any observable, index, dirty/revision map, progress flag, or result after project B is loaded.

## 7. Replace All Pipeline

### 7.1 Confirmation and preflight

Replace All is available only for a non-empty query and a current, completed result set containing at least one replace-eligible match. A file is replace-eligible only when its canonical path currently resolves to a writable `THConfigFileNode` or `THDataFileNode`; merely having an open `THTextEditorController` is not sufficient. Standalone open-tab matches remain in the visible search results but never enter the replacement candidate set.

Before any mutation:

1. re-run search immediately to eliminate stale snapshots;
2. discard every standalone/search-only file, then build every eligible replacement string in memory using the shared non-overlapping ranges, from the end of the file toward the start or via one `StringBuffer` pass;
3. discard unchanged files;
4. verify every affected path still resolves to a writable `THConfigFileNode`/`THDataFileNode`; if a formerly eligible path became standalone after the refreshed search, exclude it and update the eligibility/counts rather than attempting to save it;
5. perform read-only structural I/O checks for every eligible target: the canonical target must still exist and resolve to a regular file, its parent must still exist and resolve to a directory, and an unopened target must still be readable through `THProjectParser.readFileContent()`; and
6. create an immutable replacement snapshot containing a newly allocated replacement-operation generation, search generation, project epoch/root, query, replacement, case rule, scope, and every target's canonical path, searched content/revision, replacement content, and match count; and
7. show a localized confirmation with the **eligible** match count, eligible file count, scope, and a warning that the operation saves the affected project files and cannot be undone as one cross-file action. When the visible result set also contains standalone matches, state how many matches/files are excluded.

If the refreshed search contains no eligible matches, stop before confirmation and leave Replace All disabled with the localized search-only explanation. Cancellation makes no changes. A preflight failure makes no changes and leaves the current results visible with failure details.

After confirmation returns and **before the first `setContent()`**, validate the entire immutable replacement snapshot again. The replacement-operation/search generations, project epoch/root, query/replacement/options, target node eligibility, and each target's current content/revision must still match. If any check fails, abort the whole operation without mutation, invalidate or refresh the stale results, and show a localized reason. Modal UI and disabled controls reduce the likelihood of such a change but are not correctness boundaries; lifecycle calls, tests, or another controller may still change state while the confirmation future is pending.

Preflight does **not** claim to prove filesystem writability. Do not create a probe file, temporarily rewrite a target, or rely on an advisory permission-bit/access check: those approaches either cause side effects or remain subject to a time-of-check/time-of-use race. The authoritative outcome is the typed `saveTextProjectFile()` result from §7.2. A target may pass the read-only checks and still return `writeFailed` because permissions, mounts, locks, disk capacity, or filesystem state changed before/during the write; this is handled by the documented partial-failure policy in §7.4.

In this plan, “writable node” means a parsed node type supported by the lossless project writers (`THConfigFileNode`/`THDataFileNode`); it does not assert current operating-system write permission.

### 7.2 Applying through editor controllers

For an already-open file, reuse its registered controller. For an unopened project file, construct a temporary `THTextEditorController(projectController: <existing THProjectController>)`, `await` its `loadFile(canonicalPath)` (which adopts the observed revision per §7.3), apply/save, and dispose it in `finally`; do not add hidden controllers to `MPGeneralController` and do not open every changed file as a side effect. Create/load that temporary controller only when its target is reached, and repeat the global and per-target checks below after the `await` and immediately before `setContent()`.

#### Explicit text-save result

Refactor the text-file branch of `THProjectController.saveProjectFile()` into a typed, reusable `saveTextProjectFile({required canonicalPath, required requestedRevision, required expectedProjectEpoch, required expectedRootPath})` boundary. The existing generic method may delegate to it for compatibility, but `THTextEditorController.save()` and multi-file replacement consume the typed result directly; they never infer success from observable state or diagnostics.

A representative contract is:

```dart
enum THTextFileSaveStatus {
  saved,
  supersededBeforeWrite,
  savedButSuperseded,
  projectChangedBeforeWrite,
  writtenAfterProjectChange,
  reparseFailed,
  unknownPath,
  unsupportedNode,
  serializationFailed,
  writeFailed,
}

class THTextFileSaveResult {
  final String canonicalPath;
  final int projectEpoch;
  final int requestedRevision;
  final int? writtenRevision;
  final int? currentRevision;
  final THTextFileSaveStatus status;

  bool get isCurrentRevisionSaved => status == THTextFileSaveStatus.saved;
}
```

`THTextEditorController.save()` returns `Future<THTextFileSaveResult>`. The contract distinguishes:

- **saved** — the exact requested/flushed revision was written and was still current when the write completed; only this status clears project/controller dirty state and counts as a successful Replace All file;
- **superseded before write** — a newer revision appeared after flush but before serialization/write, so no stale write is attempted;
- **saved but superseded** — the requested revision reached disk, but a newer edit appeared while the asynchronous write was in progress; the newer revision remains dirty and the operation is reported as incomplete rather than falsely clean;
- **project changed before write** — the captured project epoch/root no longer matches before filesystem I/O starts, so no write is attempted and no current-project state is touched;
- **written after project change** — the project changed after filesystem I/O had already started and the requested bytes reached disk; the result records that external side effect, but the stale operation does not mutate the new project's dirty/revision/diagnostic state and is reported as incomplete;
- **reparse failed** — no parsed node representing the requested revision is safe to serialize;
- **unknown/unsupported target** — the canonical path has no writable config/data node or resolves to another node type; and
- **serialization/write failure** — writer construction/serialization and filesystem I/O are caught separately, logged with path/stack trace, and returned with the corresponding status.

Raw exceptions remain in logs and existing localized diagnostics may still be appended for the normal project UI, but `projectErrors` is not part of save-result detection. The result is the sole authority for whether the requested revision was written and whether the current editor revision is clean.

`saveTextProjectFile()` validates in this order before causing I/O:

1. require the captured `expectedProjectEpoch` and canonical root to match, otherwise return `projectChangedBeforeWrite` without consulting or mutating the new project;
2. resolve the canonical path and return `unknownPath`/`unsupportedNode` explicitly;
3. verify that the node's recorded parsed revision equals `requestedRevision`, otherwise return `reparseFailed`;
4. verify that the latest pending revision still equals `requestedRevision`, otherwise return `supersededBeforeWrite`;
5. serialize synchronously inside its own `try` block, returning `serializationFailed` on error, then recheck the epoch/root immediately before starting I/O;
6. write the bytes inside a separate `try` block. On error, return `writeFailed`; append current-project diagnostics only if epoch/root still match, and otherwise log without mutating the new project; and
7. after the awaited write, check epoch/root before reading or mutating controller state. If the project changed, return `writtenAfterProjectChange` with `writtenRevision` set and perform no state mutation. Otherwise compare the latest revision: return `saved` and clear dirty state only for an exact match, or return `savedButSuperseded` and leave the newer revision dirty.

Every return path populates the canonical path, captured project epoch, and requested/written revision fields; `currentRevision` is nullable when reading it would cross a project-epoch boundary. No skipped/unknown/unsupported/stale-project path returns a successful result, and no failure is represented only by a log entry.

For each affected file, in deterministic path order:

1. recheck the replacement-operation/search generations and project epoch/root before touching the target. If this global identity is stale, stop processing all remaining files without touching the current/new project;
2. obtain the registered controller or load a temporary controller for this target;
3. after any controller-loading `await`, recheck the global identity, re-resolve the target node, and re-read its current content/revision through the same synchronous snapshot boundary used by search. This per-target check must be the final operation before `setContent()` because saving an earlier root or included file can change the dependency tree, another editor controller can register a newer revision, or the temporary load itself can yield while state changes;
4. if the node is no longer a writable `THConfigFileNode`/`THDataFileNode`, or its content/revision no longer equals the immutable replacement snapshot, do **not** call `setContent()` or `save()` for it. Record a typed replacement-pipeline outcome such as `eligibilityChanged` or `contentChanged` and continue with still-independent targets;
5. call `setContent(replacedContent)` exactly once;
6. call `save()` and await its `THTextFileSaveResult`; count the file as saved only when `isCurrentRevisionSaved` is true, otherwise collect the returned status for localized partial-failure/incomplete reporting;
7. retain the controller and updated visible content when it belongs to an open tab; and
8. dispose only temporary controllers.

Replacement-pipeline outcomes (`searchSuperseded`, `projectChanged`, `eligibilityChanged`, and `contentChanged`) are distinct from `THTextFileSaveStatus`: they describe targets intentionally skipped before `setContent()`/save rather than pretending a save was attempted. If an earlier replacement changes an include/source directive and removes a later target from the current project tree, that later target is reported as `eligibilityChanged` and remains byte-for-byte and controller-content unchanged.

Do not call `File.writeAsString`, `THConfigFileWriter`, or `THFileWriter` from the search controller. All writes remain visible through the existing editor/project-controller boundary.

### 7.3 Flush-before-save prerequisite

The race spans **two** debounce layers (see §2), so awaiting `THProjectController.reparseFile()` is not sufficient — it only schedules the project-level timer and returns before `_performReparse` runs. Both layers must drain.

#### Revisioned pending content

Track a monotonically increasing content revision for every text path. A normal project load initializes both current-content and parsed-node revisions to `0` for each writable text node. `THProjectController` is the **sole revision allocator**: controllers never derive a new revision by incrementing a locally cached baseline. Expose a synchronous `@action` boundary such as `registerTextContentChange({required canonicalPath, required content, required expectedProjectEpoch, required expectedRootPath})` that, in one project-controller mutation, validates the captured project identity, increments that path's never-decremented allocation counter, stores the new current revision and pending content, updates `fileContentsCache`/dirty tracking, and returns the allocated revision. Dart's single-isolate synchronous execution makes this allocation atomic with respect to every open or temporary controller. Revisions are not reused after save, failure, supersession, or revert.

`THTextEditorController.loadFile(String filePath)` today takes only a path and has no revision concept; Phase 9 extends it so that, after it resolves the canonical path and loads content, it reads the project controller's current content revision for that path (`0` when the project tracks none) and stores it only as the controller's observed revision. This applies equally to a temporary controller created for an unopened file. `THTextEditorController.setContent()` today takes only `newContent`; Phase 9 extends it to capture the current `(projectEpoch, rootConfigPath)`, synchronously register the content through the project-controller boundary above, and store the returned revision. The editor-level debounce callback carries that already-allocated revision and identity when it requests parsing; it never allocates or reconstructs a revision itself.

The project controller keeps allocation counters and current revisions independently from its dirty pending-content records, so a successful save can remove pending content without forgetting or reusing the last written revision. It also records the revision represented by every writable parsed node. `reparseFile()` accepts only a revision previously allocated for the same epoch/path and rejects an attempt to replace a path's pending record with an older revision or different content. A timer always reads the latest registered pending record rather than content captured by an older callback. Full-reparse result application tags nodes built from overrides with their override revisions and leaves unchanged disk-backed nodes at their existing/baseline revisions.

This central allocation is required even though `MPGeneralController` normally registers one open controller per path: Replace All can own a temporary controller for an unopened file while user navigation creates the regular tab controller for the same path. Two controllers starting from the same observed revision must receive distinct revisions, and whichever change registers later must supersede the earlier content deterministically rather than producing equal revision numbers for different text.

Reparse and save completion are revision-specific:

- an older reparse may finish, but it must not remove or overwrite a newer pending revision;
- every accepted edit obtains its unique revision atomically from `THProjectController`, including edits racing between temporary and registered controllers for the same path;
- the project controller records the revision represented by each parsed writable node, separately from the latest pending revision;
- `save()` snapshots its requested revision, asks the flush layer for that revision, and calls `saveTextProjectFile(expectedRevision: ...)` only when the parsed-node revision matches;
- if a newer revision appears before the write begins, return `supersededBeforeWrite` without writing the older revision; and
- after a successful asynchronous disk write, clear dirty state only when the path's current revision still equals the written revision. Otherwise return `savedButSuperseded`, retain the newer dirty revision, and schedule/follow through with its reparse.

#### Project-epoch isolation

Every scheduled timer and asynchronous project operation captures `(projectEpoch, rootConfigPath)` in addition to path/revision. This applies to editor debounce callbacks, project reparse timers, in-flight reparse coalescing, incremental parse/splice work, dirty-preserving full reparses, flushes, and text saves.

Use the following lifecycle rules:

1. Timer records and in-flight-operation keys include the captured epoch (and revision where applicable), so project B cannot reuse or clear project A's entry for the same canonical path.
2. Check epoch/root immediately on async-operation entry, after **every** `await`, and immediately before every mutation of `projectRootNode`, child lists, indexes, dependency maps, diagnostics, caches, dirty/revision maps, timer/in-flight maps, and observable progress state.
3. A stale computation returns a typed `projectChanged`/superseded outcome and discards its parsed/splice/load result. Futures need not be force-canceled; they are prevented from committing stale state.
4. Cleanup in `finally` is guarded by the same epoch and operation identity. An old operation must not set project B's `isParsing`/search progress to false or remove a newer in-flight entry.
5. Replace the single unowned `isParsing` toggle with epoch-scoped activity ownership (for example, a current-epoch active-operation count). Increment/decrement only for the captured current epoch; derive `isParsing` from the current epoch's count so overlapping work and stale completions cannot clear another operation's progress.
6. `closeProject`, `openProject`, and non-empty explicit disk `reloadProject` each call `_beginProjectLifecycleTransition()` exactly once before state reset/replacement. `openProject()` and `closeProject()` use the separate non-advancing `_clearProjectState()` helper; no public lifecycle method calls another. They cancel queued timers and detach in-flight entries for the old epoch, but correctness relies on the guards above because already-running futures may still complete.

The in-memory full-project reparse below captures the current epoch but does not advance it. Its result applies atomically only after a final epoch/root check; if stale, the prior/new project's state is left exactly as owned by its current lifecycle.

Use a typed flush result rather than `void`/exceptions, with statuses such as `reparsed`, `alreadyCurrent`, `superseded`, `projectChanged`, and `failed`, plus canonical path, captured epoch, expected revision, and nullable parsed revision. Only `reparsed`/`alreadyCurrent` with `parsedRevision == expectedRevision` permit the save boundary to proceed.

#### In-memory full-project reparse

Do **not** implement a root/type-change flush by calling the existing disk-only `reloadProject()` and then applying `_applyLoadResult()`. Add a dedicated full-reparse path for pending edits:

1. Snapshot every entry currently in the project's dirty-content/revision map, including the target path. The snapshot is immutable for the lifetime of that reparse.
2. Extend `THProjectParser.loadProject()`/`loadFileNode()` with an optional canonical-path-to-content override map (empty for normal project open/reload). The recursive loader consults the override first and reads from disk only when no override exists. Thus a root-file edit is used to build the root node, and other unsaved included files are parsed from their own pending contents during the same rebuild.
3. Parse the complete project using that override snapshot. Newly referenced files that have no pending override continue to use the normal encoding-aware disk reader.
4. After a final project-epoch/root check, apply the rebuilt tree/indexes/diagnostics through a separate result-application helper that does not reset dirty state. Merge newly discovered disk contents into `fileContentsCache`, then reapply the latest pending contents and revisions so dirty overrides always win. Paths that disappeared from the rebuilt dependency tree remain explicitly dirty until saved, reverted, or otherwise resolved; they must not be silently dropped.
5. If the full reparse fails, leave the prior tree, all pending contents, revisions, and dirty flags intact, log/surface the failure, and report the target revision as unflushed. `saveTextProjectFile()` must not run for an unflushed revision; `THTextEditorController.save()` returns `reparseFailed`.

This in-memory path is used by every `_performReparse()` fallback that currently requires `reloadProject()` while pending edits exist: root-file changes, detected type changes, missing/detached parents, and error recovery. The existing disk-only `reloadProject()` remains the explicit reload behavior when no pending-edit preservation is requested.

Add an awaitable `THProjectController.flushPendingReparse({required String canonicalPath, required int expectedRevision, required int expectedProjectEpoch, required String expectedRootPath})` that:

- cancels the matching epoch/path/revision timer record if present, without removing a newer epoch's timer;
- returns `projectChanged` without touching current state when the expected epoch/root is stale;
- awaits the actual reparse work needed for `expectedRevision`, unless a newer revision has already superseded it;
- uses the in-memory full-project reparse above instead of disk-only `reloadProject()` whenever the incremental splice cannot be used;
- is a no-op when nothing is pending for that path; and
- coalesces concurrent callers for the same revision while ensuring that a newer revision queues/follows with its own reparse; and
- returns a typed reparse outcome identifying the parsed revision, supersession, or failure. A returned success guarantees that the writable node is tagged with `expectedRevision`; it does not by itself guarantee that the revision remains current long enough to write.

Then add an awaitable `THTextEditorController.flushPendingReparse()` that:

- cancels the editor-level `_reparseTimer`;
- accepts/snapshots the requested editor revision;
- captures the current project epoch/root together with that revision;
- if the controller is dirty, pushes that revision/content and captured project identity through `THProjectController.reparseFile(...)` **and then** awaits `THProjectController.flushPendingReparse(canonicalPath: ..., expectedRevision: ..., expectedProjectEpoch: ..., expectedRootPath: ...)` so the project-level timer is drained too; and
- is awaited at the start of `save()` before `saveTextProjectFile()` is invoked. Saving proceeds only when the typed flush outcome confirms the requested revision and project epoch; otherwise `save()` returns the corresponding `reparseFailed`, `supersededBeforeWrite`, or `projectChangedBeforeWrite` result without attempting serialization.

This behavior fixes immediate single-file edit/replace → `Ctrl/Cmd+S`, including the root project file, without discarding another editor's unsaved content; add regression coverage there.

### 7.4 Failure behavior

Multi-file disk writes are not transactional. All targets are prepared before the first mutation, but a later I/O failure can still occur after earlier files were saved. Therefore:

- continue or stop according to a single documented policy; use **continue and collect failures** so independent files can complete;
- stop all remaining work when the replacement/search generation or project epoch/root changes, because no remaining target belongs to the validated operation identity;
- skip only the affected target and continue when its node eligibility or content/revision changes within the same operation identity; never mutate that stale target;
- leave any failed, superseded-before-write, saved-but-superseded, or project-changed open controller dirty when it still belongs to the current project; a stale operation never mutates the replacement project's controllers/state;
- preserve a failed temporary controller's replacement by keeping the corresponding content in `THProjectController.fileContentsCache`/dirty tracking rather than silently discarding it, or explicitly restore its pre-operation snapshot if that is safer with the final controller implementation;
- log each exception with path and stack trace;
- report exact-saved file/match counts, incomplete (`supersededBeforeWrite`/`savedButSuperseded`/project/search-changed) files, skipped (`eligibilityChanged`/`contentChanged`) files, and failed file paths/statuses in a localized completion dialog; and
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
- completion counts, including partial success; and
- explicit save-result summaries for superseded, project-changed, reparse, unknown/unsupported, serialization, and write outcomes; and
- replacement-pipeline summaries for confirmation-time invalidation, search/project supersession, changed target eligibility, and changed target content; and
- standalone/search-only result indicator, exclusion explanation, and Replace All disabled/excluded counts.

Keep placeholder names and plural/select structures identical in `intl_en.arb` and `intl_pt.arb`. Run `flutter gen-l10n`; never edit generated localization files manually.

Update English and Portuguese help pages to explain:

- `Ctrl/Cmd+F` searches the active text file;
- `Ctrl/Cmd+Shift+F` searches multiple files;
- the difference between open-tabs and project scopes;
- `.th2` exclusion;
- standalone open tabs being searchable/navigable but excluded from Replace All;
- navigation and stale-result refresh behavior; and
- Replace All confirmation, automatic saving, and lack of one-step cross-file undo.

Add the shortcut to the appropriate keyboard-shortcut table in alphabetical order in both languages. If Phase 8 created a dedicated project-tree help page, extend it; otherwise update the final project/text-editor help page chosen by Phase 8 rather than creating a competing page.

## 10. Implementation Sequence

1. Reconfirm the post-Phase-8 source/help layout and the next unused test prefix.
2. Extract `findPlainTextMatches` and line/preview helpers; redirect single-file find to the shared helper. Behavior is unchanged except the case-insensitive path gains the offset-drift fix from §5.2 (fast path is identical to today; slow path only engages on length-changing folds).
3. Add `THProjectController.projectEpoch`, `_beginProjectLifecycleTransition()`, the separate non-advancing `_clearProjectState()`, and epoch-scoped async activity/in-flight ownership; remove `openProject()`'s call to public `closeProject()` and give each non-no-op public lifecycle entry point exactly one transition allocation. Then add `THTextFileSaveResult`, revisioned pending/parsed-content tracking, parser content overrides, the dirty-preserving in-memory full-project reparse, `THProjectController.flushPendingReparse(canonicalPath, expectedRevision, expectedProjectEpoch, expectedRootPath)` (drains the matching project-level timer), and `THTextEditorController.flushPendingReparse()` (drains the editor-level timer, then chains into the project-level flush). Refactor the project text-save boundary to return explicit outcomes and make `save()` serialize only the successfully flushed requested revision for the captured project. Cover immediate-save races, every save status, both debounce layers, lifecycle changes, and full-reload branches before multi-file replacement work.
4. Add `pendingSelectionRange`/`revealRange()` and exact-range consumption in `THTextEditorWidget`.
5. Add immutable search models and `THProjectSearchController` source collection, standalone/project-backed replacement eligibility, search-generation plus project-epoch cancellation, ordering, and project-lifecycle reset.
6. Register the controller lazily in `MPLocator` and add tree/search mode to `THProjectTreeUIController`.
7. Build grouped-results widgets and integrate them into the project sidebar.
8. Wire result activation through existing tab opening/focus/tree synchronization.
9. Implement Replace All preflight, immutable operation snapshots, post-confirmation and immediate pre-target revalidation, temporary-controller handling, sequential setContent/flush/save, topology/content-change outcomes, failure collection, and result refresh.
10. Add the `Ctrl/Cmd+Shift+F` page shortcut and verify single-file `Ctrl/Cmd+F` remains unchanged.
11. Add EN/PT localization, run `flutter gen-l10n`, and update EN/PT help/shortcut documentation.
12. Run focused tests, the complete `flutter test` suite, and `flutter analyze`; resolve every warning/error.
13. Review the final diff for accidental `.th2` inclusion, direct file writes, stale-result races, unlocalized UI text, EN/PT parity, and changes outside Phase 9.

Formatting remains automatic on commit; do not run `dart format` manually.

## 11. Test Plan

Confirm numbering immediately before implementation. With the current tree, use:

| Test file | Required coverage |
| --- | --- |
| `test/t3920_th_text_search_aux_test.dart` | Shared plain matcher compatibility, non-overlap, empty/long queries, case modes, bounded progression, line/column calculation, preview trimming/highlighting. **Offset-mapping coverage**: `İ` (U+0130) before the search term — corrected later range is not shifted; searching plain `i` in `İ` returns the non-empty original `[0, 1]` range; searching U+0307 alone in `İ` uses the documented whole-origin-rune range; repeated/adjacent expansions never emit duplicate or overlapping source ranges; replacement using every returned range succeeds; mixed `İ`/`i`/`I` hit/miss and ranges; query-only expansion against decomposed content; non-BMP cased text (Adlam U+1E900–U+1E943 or Deseret) proves rune iteration; ASCII and Latin-1 (`é`, `ñ`, `ç`) remain identical to pre-refactor `t3905` expectations; every returned range satisfies `0 <= start < end <= content.length`. |
| `test/t3921_th_text_editor_save_flush_test.dart` | Immediate edit/replace then save reparses before serialization across **both** debounce layers (editor `_reparseTimer` and project `_reparseTimers`); project-controller-owned atomic revision allocation; simultaneous temporary and registered controllers starting from the same observed revision receive distinct revisions and cannot associate equal revisions with different content; allocation counters are never decremented or reused after save/failure/revert; root-file and type-change flushes rebuild from immutable in-memory overrides rather than stale disk; another file's unsaved content/revision survives that full rebuild; full-reparse failure preserves the old tree and all dirty state and returns `reparseFailed` without serialization; timer cancellation; same-epoch/revision save coalescing; explicit `saved`, `supersededBeforeWrite`, `savedButSuperseded`, `projectChangedBeforeWrite`, `writtenAfterProjectChange`, `unknownPath`, `unsupportedNode`, `serializationFailed`, and `writeFailed` results; project change before I/O prevents the write; project change during I/O records the old-project disk write without touching new-project state; edit during flush/write remains dirty and is reparsed later; only exact `saved` marks the controller/project revision clean; result detection does not inspect `projectErrors`. |
| `test/t3922_th_text_editor_reveal_range_test.dart` | Pending range survives load, clamps safely, selects and scrolls exact match, takes precedence over line-only navigation, then clears. |
| `test/t3923_th_project_search_controller_test.dart` | Open-tabs/project source collection, unsaved controller precedence, canonical deduplication, `.th2`/missing exclusion, standalone open-tab search results marked ineligible for replacement, eligibility invalidation when a project closes/changes, deterministic ordering, no-project/no-tabs states, file read failures. |
| `test/t3924_th_project_search_stale_generation_test.dart` | Debounce, immediate submit, superseded async search suppression, query changes, project close/reload/replacement, epoch-reaction cleanup, and no search result/progress leakage from an old project. |
| `test/t3925_th_project_search_widget_test.dart` | Controls, scope selection, grouped rows, search totals versus replace-eligible totals, localized standalone/search-only indicator and tooltip, Replace All disabled when only standalone matches exist, expand/collapse, empty/error/loading states, keyboard focus, EN/PT smoke rendering. |
| `test/t3926_th_project_search_navigation_test.dart` | Existing/new tab activation, exact selection, out-of-project open tab, project-tree selection/ancestor expansion, stale-match refresh and disappeared match. |
| `test/t3927_th_project_search_replace_all_test.dart` | Confirmation/cancel, standalone open tabs excluded without `setContent()`/save while project-backed open tabs are replaced, eligible/excluded confirmation counts, immutable replacement snapshot, and full generation/epoch/root/query/options/target-content/revision revalidation after confirmation but before the first mutation; project/query/replacement/content changes while the confirmation future is held abort without any mutation; read-only preflight rejection for a missing/non-regular target, missing/non-directory parent, and unreadable unopened file without any probe write or mutation; a target that passes preflight but fails the actual write returns/reports `writeFailed`; exactly one `setContent()` per still-valid applied file and none for skipped files; per-target revalidation immediately before `setContent()` and after temporary-controller loading; an earlier root/include replacement that removes a later target reports `eligibilityChanged` and leaves it untouched; a concurrent edit reports `contentChanged` and is not overwritten; global operation/project identity changes stop all remaining targets; open and temporary controllers, flush-before-save, root `thconfig` replacement serialized from its in-memory revision, simultaneous dirty included-file contents preserved during a full rebuild, automatic save, case semantics, empty replacement, each non-`saved` typed outcome (including project-changed and pre-save replacement-pipeline statuses) mapped to incomplete/failure reporting without consulting dirty/error collections, partial failures, disposal, refreshed results. |
| `test/t3928_th2_file_tabs_page_project_search_shortcut_test.dart` | `Ctrl/Cmd+Shift+F` opens/focuses project search; collapsed sidebar expands; `Ctrl/Cmd+F` remains editor-local; shortcut behavior with canvas/text tabs and dialogs. |
| `test/t3929_phase9_documentation_localization_test.dart` | EN/PT key parity, registered help assets, both shortcut descriptions, no claim that `.th2` is searched, documented standalone search/navigation versus replacement exclusion, and documented Replace All save/undo behavior. |
| `test/t3930_th_project_async_epoch_isolation_test.dart` | Verify every `openProject`, non-empty explicit disk `reloadProject`, and `closeProject` invocation advances the epoch by exactly one even when its load later fails; no-project reload is a no-op; opening does not invoke an additional public close transition; and each load captures the epoch returned by `_beginProjectLifecycleTransition()` after allocation. Hold project-A open/load, incremental reparse, full reparse, splice, and flush futures across closing A and loading/reloading project B (including the same root path under a newer epoch); prove late results and `finally` cleanup cannot mutate B's root/children, indexes, dependencies, diagnostics, caches, dirty/current/parsed revision maps, `isParsing` activity ownership, timers, or epoch-scoped in-flight entries. Verify stale entry cleanup cannot remove a newer operation with the same path/revision. |

Retain and run `t3905_th_text_editor_find_replace_test.dart` as a regression suite after extracting the matcher.

### End-to-end scenarios

1. Load a project with nested/repeated includes, leave one `.th` unopened, edit another open `.th` without saving, search project scope, and see each canonical file exactly once with the unsaved match included.
2. Activate a result in an unopened file and land on the exact match in a new text tab while the project tree selects/reveals that file.
3. Start a slow project search, close/open another project, and verify no old result or failure appears in the new project.
4. Replace a case-insensitive query across open and unopened project files, confirm once, save through controllers/writers, refresh the tree/parser state, and observe zero old matches.
5. Force one target save to fail and verify successful files remain saved, the failed file is clearly reported and recoverable/dirty according to the chosen policy, and no error is swallowed.
6. Search open-tabs scope with one project-backed editor and one standalone editor containing matches, navigate in both, then Replace All and verify only the project-backed file changes/saves while the standalone controller content and disk file remain untouched.
7. Pause project A during incremental/full reparse and during a save write, close it, and load project B. Release A's futures and verify B remains byte-for-byte/state-for-state unchanged; the pre-write save performs no I/O, while an already-started successful write is reported as `writtenAfterProjectChange` without updating B.

## 12. Acceptance Criteria

- `Ctrl/Cmd+Shift+F` opens a localized multi-file search surface without changing single-file `Ctrl/Cmd+F`.
- Users can search open text tabs or all loaded-project `thconfig`/`.th` files; `.th2` and missing/imported non-text files never appear.
- Standalone open text tabs appear in search results and support exact navigation, but are visibly search-only, never contribute to Replace All counts, and are never mutated or saved by multi-file replacement.
- Unsaved open-editor content is searched instead of stale cache/disk content.
- Results are deterministic, grouped by file, show accurate line/column previews, and navigate to/select the exact current match.
- Case-insensitive Unicode matches always map to ordered, non-empty, non-overlapping UTF-16 ranges in the original content; highlighting and replacement never use offsets from the folded string directly.
- Repeated project references are deduplicated by canonical path.
- Search remains correct when queries change rapidly or a project closes/changes during asynchronous work.
- Each non-no-op public project lifecycle transition advances the project epoch exactly once through `_beginProjectLifecycleTransition()`; `openProject()` never calls public `closeProject()`, and `_clearProjectState()` never advances the epoch. No load, search, reparse, flush, save completion, or `finally` block captured under an older epoch can mutate the current project's tree, indexes, diagnostics, caches, dirty/revision state, in-flight ownership, or progress flags.
- Multi-file Replace All requires confirmation, computes all eligible project-file changes before mutation, captures an immutable operation/search/project/content-revision snapshot, revalidates the complete snapshot after confirmation, and revalidates each target immediately before mutation. A stale or no-longer-eligible target is never passed to `setContent()`/save; global identity changes stop all remaining work, while per-target topology/content changes are reported and independent targets may continue.
- Replace All preflight performs only read-only existence/type/readability checks and makes no claim that a later write will succeed; actual writability is determined exclusively by the typed save result.
- Immediate single-file save after editing/replacement also serializes the latest content.
- Flushing/saving a root or type-changing file reparses from an immutable in-memory dirty-content snapshot; it never restores stale disk text or clears another file's unsaved revision.
- Read/parse/save failures are logged and surfaced per file; successful and failed counts are unambiguous.
- Save success is determined only from `THTextFileSaveResult`; observable dirty state and `projectErrors` are never used as proxy return values, and a write superseded by a newer edit is reported without clearing that edit.
- `THProjectController` atomically allocates every text-content revision; open and temporary controllers can never assign the same revision to different content, and revision numbers are never reused.
- A project change before text-file I/O prevents the write; a change after I/O starts is reported explicitly, and the stale completion never mutates the newly loaded project.
- Open controllers remain open and synchronized; temporary controllers are disposed on every success/failure path.
- New UI strings and help/shortcut documentation are complete and equivalent in English and Portuguese.
- Focused tests, the full test suite, and `flutter analyze` pass with no warnings.

## 13. Risks and Decisions to Verify During Implementation

1. **Save semantics after replacement**: the roadmap explicitly calls for `setContent`/`save`, so this plan auto-saves after confirmation. The confirmation must make that behavior unmistakable, especially when an affected open editor already contains unsaved edits.
2. **Temporary-controller save failure**: disposing a failed temporary controller can discard the only editor-owned replacement snapshot. Resolve this by either retaining the failed content in project dirty/cache state or restoring the original snapshot, then lock the policy with tests before widget work.
3. **Large-project responsiveness**: full scans are linear in total text plus match count. Debouncing, snapshotting, stale-generation cancellation, and bounded matcher progress are required; isolate extraction waits for profiling evidence.
4. **Unicode case conversion**: the shipped single-file `findMatches` lowercases the whole haystack (`content.toLowerCase()`) before matching, so any length-changing lowercase mapping (`İ` U+0130 → `i` + U+0307) already yields `TextRange` offsets that are wrong against the original `content`. Extracting the helper preserves this latent bug rather than introducing it, and the existing `t3905` suite contains no length-changing cases. Phase 9 fixes it as a **fix beyond parity** using the per-rune semantics and dual `sourceStarts`/`sourceEnds` mapping specified in §5.2. A partial hit inside one expanded lowercase rune deliberately maps to that whole original rune; duplicate/overlapping projected ranges are discarded. The `t3920` tests lock this behavior for plain `i` and U+0307 in `İ`, expansions before later matches, repeated expansions, replacement safety, query-only expansion, non-BMP casing, and ASCII/Latin-1 parity.
5. **External file changes**: no filesystem watcher is added. Result activation validates its snapshot, and explicit refresh/new query reads current sources; files modified externally after project parsing remain subject to the existing project reload behavior.
6. **Cross-file undo**: Flutter's per-widget editing history cannot provide an atomic undo across open and temporary controllers. Confirmation, preflight, and explicit automatic-save wording are mandatory until a future command/transaction layer is designed for text files.
7. **Full-reparse snapshot consistency**: root/type-change/error fallback reparses must use one immutable snapshot of all dirty contents. Applying the rebuilt project must merge against the still-current revision map so edits made while parsing remain dirty; the generic disk-only `_applyLoadResult()` is never used for this path.
8. **Standalone tabs**: open-tabs scope is broader for search/navigation than for replacement. A tab without a current writable project node is always search-only; Phase 9 must not infer writability from the presence of an editor controller or add a direct disk writer to make it eligible.
9. **Save-result authority**: logs, diagnostics, and dirty observables remain useful UI state but are not operation return values. Every text save returns the requested/written/current revisions and a status; only exact `saved` counts as complete, while `savedButSuperseded` truthfully records that disk changed but newer editor content remains unsaved.
10. **Project lifecycle races**: canceling a `Timer` does not cancel a future already started by that timer. Every async project operation therefore carries epoch/root identity and guards all post-`await` mutation and cleanup. Each public lifecycle entry point calls `_beginProjectLifecycleTransition()` once and uses a separate non-advancing reset helper, preventing `openProject()` from capturing an epoch that an internally called public `closeProject()` immediately supersedes. Epoch-scoped activity/in-flight ownership prevents a stale project-A completion from clearing project B's progress or removing B's work; a disk write already in progress cannot be recalled, so its explicit `writtenAfterProjectChange` result records the side effect without touching B's state.
11. **Filesystem preflight limits**: existence, entity-type, parent-directory, and readability checks catch structural failures without mutation, but no portable preflight can guarantee a later write. Do not probe-write or treat permission bits as authoritative; preserve the all-content-in-memory preparation and confirmation guarantees, then rely on `THTextFileSaveResult.writeFailed` plus §7.4 partial-failure reporting for time-of-check/time-of-use changes.
12. **Revision allocation ownership**: a controller-local `baseline + 1` scheme is invalid because a temporary Replace All controller and a newly opened registered controller may share the same baseline while holding different content. Only `THProjectController` allocates revisions, and allocation atomically registers the associated pending content under the captured epoch/path. Tests must force this two-controller race and prove unique, ordered revisions and deterministic supersession.
13. **Confirmation and topology races**: the confirmation dialog is an asynchronous boundary, and each earlier replacement/save may reparse directives that change the project tree before a later target is reached. Replace All therefore revalidates the complete immutable operation snapshot after confirmation and revalidates node eligibility plus exact content/revision before each `setContent()`. Global generation/project changes abort the remainder; a target removed by an earlier include/source edit or superseded by another controller is skipped and reported without mutation.
