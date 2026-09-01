<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 8.5: Project Epoch, Revisioned Content & Explicit Save Result — Implementation Plan

**Date:** 2026-09-01
**Status:** Proposed — carved out of the Phase 9 plan (2026-08-31) so the project-controller lifecycle/save refactor lands and stabilizes before the multi-file find/replace UI is built on top of it.

## 1. Overview & Objectives

This document details **Phase 8.5** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It is an infrastructure-only refactor of the Phase 3 project-controller lifecycle, re-parsing pipeline, and file-save path. It ships no user-visible feature of its own; its purpose is to make immediate *edit → save* correct for every text file (including the root `thconfig`), to give callers an explicit save outcome instead of an inference from observable state, and to make every asynchronous project operation safe across a project close/open/reload.

It exists because the original Phase 9 plan folded this rewrite into a single implementation step alongside the search UI (`§6.3–6.4`, `§7.2–7.3` there). That coupled a large regression surface in core parsing/saving with new feature code. Phase 8.5 extracts it so it can be reviewed, tested, and merged on its own. **Phase 9 then consumes the contracts defined here** and adds only search-specific generations, source collection, result models, widgets, and the Replace All pipeline.

### Key objectives

1. **Correct immediate save**: an edit or single-file find/replace followed by `Ctrl/Cmd+S` must serialize the just-edited content — including a root project file — without discarding another editor's unsaved content.
2. **Explicit save result**: `THTextEditorController.save()` and the project text-save boundary return a typed, revision-aware result. Callers never infer success from `dirtyFilePaths`, `isDirty`, or a `projectErrors` diff.
3. **Two-layer flush**: drain both the editor-level `_reparseTimer` and the project-level `_reparseTimers` entry before serialization so a stale parsed node can never reach the writers.
4. **Atomic revision allocation**: `THProjectController` is the sole allocator of a monotonically increasing content revision per text path; two controllers (e.g. a temporary one and a freshly opened tab) starting from the same observed revision receive distinct revisions with deterministic supersession.
5. **Dirty-preserving full reparse**: root-file, child reference-role/expected-shape conflict, missing-parent, and reparse-error recovery rebuild the project from an immutable in-memory snapshot of all pending contents instead of re-reading disk and dropping unsaved edits.
6. **Project-epoch isolation**: a monotonically increasing `projectEpoch` is captured by every timer, reparse, flush, and save; no stale post-`await` completion or `finally` block can mutate a newly loaded project.
7. **Single-project editor isolation**: Mapiah has exactly one active project; replacing, reloading, or closing it disposes its project-owned tabs/controllers, and a text-editor controller loaded under an older epoch can never attach its buffer to the replacement project—even when the same root/path is reopened.
8. **No regressions**: the full `flutter test` suite and `flutter analyze` pass; existing tests that call the changed `loadFile` / `setContent` / `save` / `revert` / `saveProjectFile` / `saveAllModifiedFiles` / `openProject` / `reloadProject` / `closeProject` / `reparseFile` surfaces are updated.

## 2. Grounding: Current State

Verified against the codebase on 2026-09-01.

- `THTextEditorController.loadFile(String filePath)` takes only a path. It canonicalizes, reads `THProjectController.fileContentsCache[path]`, falls back to `THProjectParser.readFileContent(path).content`, and **unconditionally** sets `isDirty = false` — even when the cached text is project-owned pending content (`lib/src/controllers/th_text_editor_controller.dart:119-141`).
- `THTextEditorController.setContent(String newContent)` takes only content. It sets `content`/`isDirty = true`, then schedules an editor-level `_reparseTimer` (`mpTextEditorReparseDebounceMilliseconds`, 300 ms) whose callback calls `THProjectController.reparseFile(filePath:, updatedContent:)` (`:143-158`).
- `THTextEditorController.save()` returns `Future<void>`. It `await`s `_projectController.saveProjectFile(canonicalPath)`, then clears `isDirty` only if `!_projectController.dirtyFilePaths.contains(canonicalPath)` (`:300-307`). `replaceActiveMatch()`/`replaceAllMatches()` already route through `setContent()` (`:263`, `:286`).
- The constructor accepts an optional `THProjectController` for injection (`:32`).
- `THProjectParser.loadProject()` / `loadFileNode()` are `static` and **synchronous**, returning `THProjectLoadResult` (`lib/src/mp_file_read_write/th_project_parser.dart:123,138`). `readFileContent()` returns a `({String content, String encoding})` record (`:172`).
- `THProjectController` wraps the synchronous loaders in `await Future<THProjectLoadResult>(() => THProjectParser.loadProject(...))` inside `openProject()` and `reloadProject()` (`lib/src/controllers/th_project_controller.dart:124,165`).
- **Two** debounce layers exist. `setContent()`'s `_reparseTimer` calls `reparseFile()`; `reparseFile()` writes `fileContentsCache`/`dirtyFilePaths` synchronously, then schedules `_reparseTimers[path]` (`mpProjectReparseDebounceMilliseconds`, 300 ms) → `_performReparse(path, content)` and returns (`:209-226`). `_performReparse` is what splices the fresh node the writers serialize, and it may `await reloadProject()`.
- `_performReparse` falls back to `reloadProject()` for root-file changes, missing/detached parents, and error recovery (`:249,256,306,320`). It also contains an intended type-change check at `:278-284`, but that branch is unreachable: the shallow parse at `:263-275` explicitly supplies the existing node's config/data shape, so `freshNode.runtimeType` cannot differ from `existingNode.runtimeType`. Text `thconfig`/`.th` files have no Save As/rename operation; the real non-root shape-change case is a parent edit that changes the same child path between `source` (data) and `input` (config), which must be detected while validating reusable children during splice. `reloadProject()` re-parses from disk and calls `_applyLoadResult()`, which **reassigns** `fileContentsCache` and `dirtyFilePaths` to fresh disk-derived collections (`:428-462`). A flush that merely awaits the current `_performReparse()` path can therefore discard the pending revision and other unsaved files before serialization.
- `openProject()` calls `_cancelAllReparseTimers()` then the **public** `closeProject()` as its reset implementation (`:117-118`). `closeProject()` clears root/tree/indexes/caches/dirty state and sets `isParsing = false` (`:190-206`).
- Project close/open/reload cancels queued `_reparseTimers`, but cannot cancel a `_performReparse()` future already started by a fired timer. Such a future can resume after project B replaces project A and mutate shared indexes, diagnostics, dirty state, or `isParsing`.
- `THProjectController` has **no revision concept** today, and `isParsing` is a single unowned `bool` toggled in `finally` blocks by whichever operation finishes last.
- `saveProjectFile(String filePath)` returns `Future<void>`. It silently returns on an unknown path or a `.th2` file with no open editor, catches write errors and appends a `THProjectParseError` to `projectErrors`, and removes the path from `dirtyFilePaths` on some paths (`:327-399`). `projectErrors` is fully reassigned on every full reload and is shared with parser diagnostics, so a before/after diff is not a reliable save signal.
- `nodeByCanonicalPath(String)` is a single-path lookup returning `THProjectFileNode?`; `_nodesByCanonicalPath` is private (`:95,415`). Writable node types are `THConfigFileNode` / `THDataFileNode` (`lib/src/elements/th_project/`).
- Debounce durations live in `lib/src/constants/mp_constants.dart` (`mpTextEditorReparseDebounceMilliseconds`, `mpProjectReparseDebounceMilliseconds`).
- MobX `.g.dart` files are regenerated by an existing `build_runner` watch instance; never run `build_runner` manually (see `AGENTS.md`).
- The latest allocated test prefix is `t3919`; the repo already contains real prefix collisions (`t3172`, `t3760`, `t3918`). Phase 8.5 should begin at `t3920` after re-scanning for duplicates at implementation time. The Phase 9 plan (2026-08-31) already reserves `t3920`–`t3923` for this phase and starts its own table at `t3924`; no renumbering of Phase 9 is required, only a re-scan for duplicates before allocating.

## 3. Scope and Non-Goals

### In scope

- `THProjectController.projectEpoch` plus the `_beginProjectLifecycleTransition()` / `_clearProjectState()` split, and removal of `openProject()`'s call to public `closeProject()`.
- Single-project lifecycle ownership for project tabs/controllers, project-identity ownership on `THTextEditorController`, and stale-controller rejection in `MPGeneralController`; canonical path alone is no longer sufficient to reuse a project-bound editor across lifecycle transitions.
- A narrow constructor-injected project-operations bundle for deterministic control of parser, serializer, reader, and writer boundaries in tests; production defaults preserve the current static parser/writer/`File` behavior.
- Epoch-scoped async activity ownership replacing the single unowned `isParsing` toggle.
- Revisioned pending-content tracking with `THProjectController` as the sole atomic allocator; a synchronous `@action` registration boundary.
- Revision-bearing parser content overrides plus authoritative per-file content snapshots on `THProjectParser.loadProject()` / `loadFileNode()` results (empty overrides for normal open/reload).
- A dedicated dirty-preserving in-memory full-project reparse path and its non-`_applyLoadResult()` result application.
- `THProjectController.flushPendingReparse(...)` (drains the project-level timer) and `THTextEditorController.flushPendingReparse()` (drains the editor-level timer, then chains into the project-level flush).
- A project-owned, revision-aware `revertTextProjectFile(...)` boundary that restores disk content without discarding a newer concurrent edit or publishing an unparsed clean revision.
- Typed text, generic project-file, TH2-adapter, and Save All results; refactor of the text-file branch of `saveProjectFile()` into a reusable `saveTextProjectFile(...)` boundary.
- Extended `THTextEditorController.loadFile()` / `setContent()` / `save()` signatures and semantics per §5–§8, and updates to every existing caller and test.
- Regression coverage for immediate save (including the root file), every save/flush status, both debounce layers, lifecycle epoch isolation, and the full-reload branches.

### Out of scope (stays in Phase 9)

- The multi-file search generation, replacement-operation generation, debounce, and stale-search suppression.
- `THProjectSearchController`, search models, source collection, result widgets, sidebar search mode, `Ctrl/Cmd+Shift+F`, and the Replace All pipeline.
- Any new public all-nodes accessor on `THProjectController` (Phase 9 adds that for source enumeration).
- The pure `findPlainTextMatches` helper extraction and the Unicode offset-drift fix.
- New user-facing strings, help pages, or shortcut-table entries beyond what a changed diagnostic message requires.
- A background isolate, a filesystem watcher, or a cross-file undo transaction.

## 4. Project Epoch Model

Expose a read-only, monotonically increasing `THProjectController.projectEpoch`. Every lifecycle transition that clears or replaces the project identity/tree (`openProject`, explicit disk `reloadProject`, `closeProject`) reserves exactly **one** new epoch **before** canceling timers or clearing state. The asynchronous load captures that epoch and its intended canonical root, and applies its result (and clears its own progress state) only if both still match.

Implement ownership with two private synchronous helpers, called inside the owning MobX `@action` before its first `await`, rather than by nesting public lifecycle methods:

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

Rules:

- `openProject()` canonicalizes the intended root, calls `_beginProjectLifecycleTransition()` **exactly once**, stores the returned epoch, calls `_clearProjectState()`, assigns the new root, and starts the load under the stored epoch. It **must no longer call public `closeProject()`**.
- `closeProject()` calls `_beginProjectLifecycleTransition()` once, then `_clearProjectState()`.
- A non-empty explicit disk `reloadProject()` snapshots the current canonical root, calls `_beginProjectLifecycleTransition()` once, retains the current tree while loading, and applies the result only under the returned epoch/root. It does not call `_clearProjectState()` merely to reload.
- A no-project `reloadProject()` remains a no-op and does not advance the epoch.
- No public lifecycle method calls another public lifecycle method. No asynchronous operation captures its epoch before `_beginProjectLifecycleTransition()` returns.
- Mapiah retains one global `THProjectController`, one `rootConfigPath`, and one `projectRootNode`; `openProject()` replaces that single active project rather than adding a second project. Before `_beginProjectLifecycleTransition()` returns, it synchronously routes the outgoing project's canonical node-path snapshot through a shared `MPGeneralController.closeProjectFileTabs(...)` helper. That helper removes and disposes every outgoing project-owned canvas/text tab/controller and cancels editor timers. Move the existing path-membership loop out of `MPDialogAux.closeOpenProject()` into this shared non-UI boundary so direct `openProject()` / `reloadProject()` / `closeProject()` calls cannot bypass cleanup. Bound controller references retained outside the registry become permanently stale and are never rebound in place; registry lookup also rejects/replaces a stale entry defensively. Opening the same root/path again therefore creates a new controller and buffer for the new epoch.

Replace the single unowned `isParsing` toggle with epoch-scoped activity ownership (for example, a per-epoch active-operation count). Increment/decrement only for the captured current epoch; derive `isParsing` from the current epoch's count so overlapping work and stale completions cannot clear another operation's progress.

The in-memory full-project reparse in §7 captures the current epoch but does **not** advance it — it is work within the same project.

## 5. Revisioned Pending Content & Atomic Allocation

Track a monotonically increasing content revision for every text path. A normal project load initializes both current-content and parsed-node revisions to `0` for each writable text node. **`THProjectController` is the sole revision allocator**; controllers never derive a new revision by incrementing a locally cached baseline (a temporary Replace All controller and a newly opened registered controller can share the same observed baseline while holding different content — a `baseline + 1` scheme would hand them equal revisions for different text).

Expose a synchronous `@action` boundary:

```dart
int registerTextContentChange({
  required String canonicalPath,
  required String content,
  required int expectedProjectEpoch,
  required String expectedRootPath,
});
```

In one project-controller mutation it: validates the captured project identity; increments that path's never-decremented allocation counter; stores the new current revision and pending content; updates `fileContentsCache` / dirty tracking; and returns the allocated revision. Dart's single-isolate synchronous execution makes this allocation atomic with respect to every open or temporary controller. Revisions are **not reused** after save, failure, supersession, or revert.

The project controller keeps allocation counters and current revisions independently from its dirty pending-content records, so a successful save can drop pending content without forgetting or reusing the last written revision. It also records the revision represented by every writable parsed node.

### Extended controller signatures

Represent the project-owned state adopted by an editor as one immutable `THTextProjectContentSnapshot` value containing canonical path, content, current revision, dirty/pending status, project epoch, and root path. Snapshot lookup and construction are synchronous so those fields cannot come from different revisions or lifecycle identities. A project-bound `THTextEditorController` stores the snapshot's epoch/root as its immutable ownership identity for that controller lifetime; `loadFile()` may refresh it only within the same identity. Loading the same path under another epoch requires a new controller instance.

- `THTextEditorController.loadFile(String filePath)` obtains **one** synchronous project-content snapshot: content, current revision, dirty/pending status, project epoch, root path. When the project tracks the path, a newly created controller adopts that snapshot's content, observed revision, dirty status, and ownership identity **together** — it must not reset pending cached content to clean. A controller already bound to a different epoch/root rejects the load instead of replacing its buffer or identity. When the project does not track the path, it falls back to the encoding-aware disk reader with revision `0` and clean state and remains explicitly unbound. This applies equally to a temporary controller for an unopened file and to a normal controller materialized after a temporary save failure.
- `THTextEditorController.setContent(String newContent)` uses the controller's **stored** project epoch/root, never the project controller's current identity. It synchronously validates that ownership before changing either the editor buffer or project state, registers the content through `registerTextContentChange(...)`, and stores the returned revision. If the binding is stale, it returns/reports `projectChanged` and mutates neither project A nor project B. The editor-level debounce callback carries that already-allocated revision and stored identity when it requests parsing; it never allocates or reconstructs a revision.
- `THProjectController.reparseFile(...)` accepts only a revision previously allocated for the same epoch/path, and rejects an attempt to replace a path's pending record with an older revision or different content. A timer always reads the latest registered pending record, not content captured by an older callback.
- `THTextEditorController.revert()` does not call `loadFile()` for a project-tracked dirty path. It snapshots the editor's revision and captured project identity, cancels its editor-level timer, and delegates to the revision-aware project revert boundary in §8.1. `loadFile()` remains the operation for adopting the project's current snapshot; revert is the distinct operation for intentionally discarding one pending revision in favor of disk content.

`MPGeneralController` treats `(canonicalPath, projectEpoch, rootPath)` as the identity of a project-bound text editor even though Mapiah has only one active project and its internal registry remains path-indexed. Normal lifecycle cleanup removes the outgoing project's entries before replacement; defensively, `getTextEditorController(...)` may reuse a remaining entry only when its stored binding matches the requested current project snapshot. A stale or unbound entry is disposed and replaced before project content is loaded; the new controller receives only the current project's snapshot, never the outgoing buffer. Old controller references retained by widgets, callbacks, or tests remain permanently bound to the old epoch and fail the synchronous ownership check.

Reparse and save completion are revision-specific:

- an older reparse may finish, but must not remove or overwrite a newer pending revision;
- `save()` snapshots its requested revision, asks the flush layer for that revision, and calls `saveTextProjectFile(requestedRevision: ...)` only when the parsed-node revision matches;
- if a newer revision appears before the write begins, return `supersededBeforeWrite` without writing the older revision;
- after a successful asynchronous disk write, clear dirty state only when the path's current revision still equals the written revision; otherwise return `savedButSuperseded`, retain the newer dirty revision, and follow through with its reparse.

## 6. Project-Epoch Isolation

Every scheduled timer and asynchronous project operation captures `(projectEpoch, rootConfigPath)` in addition to path/revision: editor debounce callbacks, project reparse timers, in-flight reparse coalescing, incremental parse/splice work, dirty-preserving full reparses, flushes, and text saves.

1. Timer records and in-flight-operation keys include the captured epoch (and revision where applicable), so project B cannot reuse or clear project A's entry for the same canonical path.
2. Check epoch/root immediately on async-operation entry, after **every** `await`, and immediately before every mutation of `projectRootNode`, child lists, indexes, dependency maps, diagnostics, caches, dirty/revision maps, timer/in-flight maps, and observable progress state.
3. A stale computation returns a typed `projectChanged` / superseded outcome and discards its parsed/splice/load result. Futures are not force-canceled; they are prevented from committing stale state.
4. Cleanup in `finally` is guarded by the same epoch and operation identity. An old operation must not set project B's `isParsing`/progress to false or remove a newer in-flight entry.
5. Epoch-scoped activity ownership (see §4) replaces the single `isParsing` toggle.
6. `closeProject`, `openProject`, and non-empty explicit disk `reloadProject` each call `_beginProjectLifecycleTransition()` exactly once before state reset/replacement. `openProject()` and `closeProject()` use the separate non-advancing `_clearProjectState()`; no public lifecycle method calls another. Correctness still relies on the guards above because already-running futures may complete.
7. Editor controllers and buffers are identity-owned too. Because Mapiah is single-project, every non-no-op lifecycle transition closes/disposes the outgoing project's registered file tabs/controllers before its state is replaced; registry lookup still replaces rather than rebinds any stale controller that escaped normal ownership. Every editor entry point and delayed callback uses the controller's stored identity. Canonical-path equality—including reopening the exact same root—is never evidence that an editor belongs to the current epoch.

Use a typed flush result rather than `void`/exceptions, with statuses such as `reparsed`, `alreadyCurrent`, `superseded`, `projectChanged`, and `failed`, plus canonical path, captured epoch, expected revision, and nullable parsed revision. Only `reparsed` / `alreadyCurrent` with `parsedRevision == expectedRevision` permit the save boundary to proceed.

### 6.1 Deterministic operation seams

Add one immutable `THProjectControllerOperations` dependency bundle accepted optionally by the `THProjectController` constructor. Follow the repository's existing typedef/callback injection style. Do not introduce a general filesystem abstraction, mutable global overrides, timing sleeps, or test-only branches in production algorithms.

The bundle exposes exactly these independently replaceable operations:

- asynchronous full-project/file-node load, including expected shape, project-root directory, and content/revision overrides;
- asynchronous shallow `parseFileContent`;
- asynchronous `spliceFileNodeChildren`;
- synchronous encoding-aware file-content read;
- synchronous writable-node serialization to `Uint8List`; and
- asynchronous byte write for a canonical path.

Production defaults delegate to `THProjectParser.loadProject` / `loadFileNode` / `parseFileContent` / `spliceFileNodeChildren` / `readFileContent`, `THConfigFileWriter` / `THFileWriter`, and `File(path).writeAsBytes(bytes)`. The controller calls only the injected bundle—not those concrete APIs directly—at the lifecycle/reparse/revert/save boundaries covered by this phase. Keeping content read, serialization, and byte write separate allows tests to distinguish `readFailed`, `serializationFailed`, and `writeFailed` without relying on filesystem permissions or malformed incidental state.

Test implementations use explicit `Completer` gates and call recording. Each asynchronous fake exposes a started future, waits on a test-controlled release future, then either returns a supplied result, delegates to the real operation, or throws a supplied error. Tests first await the started future, perform the lifecycle transition or concurrent edit, release the operation, and await the controller result. This deterministically holds open/load, shallow parse, splice, full reparse, and byte write at their actual `await` boundaries without duration-based sleeps. A byte-write fake records whether it was invoked before blocking, so tests distinguish project change before I/O (writer never called) from project change after I/O starts (`writtenAfterProjectChange`). Synchronous serializer/read fakes throw directly to exercise their distinct statuses; they do not add artificial production `await` points.

Use a fresh operations bundle per controller/test. Production construction uses defaults, while controller unit tests inject a bundle through the constructor; no test mutates `mpLocator`, static parser state, or process-wide callbacks. Add a small reusable fake/gate helper under `test/` if multiple Phase 8.5 suites need the same started/release protocol.

## 7. In-Memory Full-Project Reparse

Do **not** implement a root/reference-role-shape-conflict flush by calling the existing disk-only `reloadProject()` and then applying `_applyLoadResult()`. Remove the impossible direct-file `freshNode.runtimeType != existingNode.runtimeType` check: incremental shallow parsing intentionally preserves the existing node's shape. Instead, extend splice reuse validation so every cached `THConfigFileNode` / `THDataFileNode` candidate is checked against the expected shape supplied by its new reference context. `source` requires data; `input` requires config. If a candidate's runtime type conflicts, `THProjectSpliceResult` reports the canonical conflict path, the controller does not apply the provisional splice, and it runs the dirty-preserving full-project reparse below. Root edits already take this full path; an auto-detected root may consequently change shape there, while a root opened with forced config shape remains config. Text files have no Save As/rename operation, and TH2 Save As is unrelated to config/data node shape.

Add the dedicated full-reparse path for pending edits:

1. Snapshot every entry currently in the project's dirty-content/revision map, including the target path. The snapshot is immutable for the lifetime of that reparse.
2. Extend `THProjectParser.loadProject()` / `loadFileNode()` with an optional canonical-path-to-immutable-`THProjectContentOverride` map (empty for normal project open/reload). Each override contains content and its allocated revision; the recursive loader consults it first and reads from disk only when no override exists. A root-file edit is thus used to build the root node, and other unsaved included files are parsed from their own pending contents during the same rebuild.
3. Parse the complete project using that override snapshot. Newly referenced files with no pending override use the normal encoding-aware disk reader.
4. Extend `THProjectLoadResult` with an immutable `contentSnapshotsByCanonicalPath` map. Each writable config/data node loaded by the recursive parser contributes exactly one `THProjectParsedContentSnapshot` containing its canonical path, the exact decoded string passed to the config/data parser, the effective encoding represented by the constructed node, provenance (`disk` or `override`), and nullable override revision. Missing and `.th2` nodes have no text-content snapshot. Record the snapshot in the same `_loadFileNode()` invocation that constructs the node; never reconstruct it from the tree or reread the path afterward.
5. After a final project-epoch/root check, apply the rebuilt tree/indexes/diagnostics through a **separate** result-application helper that does not reset dirty state. Populate newly discovered clean cache entries directly from `THProjectLoadResult.contentSnapshotsByCanonicalPath`, then reapply the latest pending contents and revisions so dirty overrides always win. Delete/retire `_populateFileContentsCache()`'s post-parse disk reads for load-result application. Paths that disappeared from the rebuilt dependency tree remain explicitly dirty until saved, reverted, or otherwise resolved; they must not be silently dropped.
6. Derive parsed-node revisions from the same authoritative records: an override-backed node receives that record's non-null override revision; a disk-backed node already known to the same in-memory project retains its existing clean parsed revision; a newly discovered disk-backed node receives baseline revision `0`. Normal open and successful explicit disk reload start a new revision state and therefore assign `0` to all disk-backed writable nodes. The controller must assert that every override-backed writable node has a matching revision-bearing snapshot and that its content equals the immutable override used for the parse.
7. If the full reparse fails, leave the prior tree, all pending contents, revisions, and dirty flags intact, log/surface the failure, and report the target revision as unflushed. `saveTextProjectFile()` must not run for an unflushed revision; `THTextEditorController.save()` returns `reparseFailed`.

The parser reads each disk-backed writable file at most once per load operation. The content cache, encoding metadata, parsed node, and parsed revision all come from that one load snapshot, preventing a disk change between parsing and cache population from creating a cache/node mismatch.

This in-memory path is used by every `_performReparse()` fallback that currently requires `reloadProject()` while pending edits exist. The existing disk-only `reloadProject()` remains the explicit reload behavior when no pending-edit preservation is requested.

## 8. Two-Layer Flush-Before-Save

Add `THProjectController.flushPendingReparse({required String canonicalPath, required int expectedRevision, required int expectedProjectEpoch, required String expectedRootPath})` that:

- cancels the matching epoch/path/revision timer record if present, without removing a newer epoch's timer;
- returns `projectChanged` without touching current state when the expected epoch/root is stale;
- awaits the actual reparse work needed for `expectedRevision`, unless a newer revision has already superseded it;
- uses the in-memory full-project reparse (§7) instead of disk-only `reloadProject()` whenever the incremental splice cannot be used;
- is a no-op when nothing is pending for that path;
- coalesces concurrent callers for the same revision while ensuring a newer revision queues/follows with its own reparse; and
- returns a typed reparse outcome identifying the parsed revision, supersession, or failure. A returned success guarantees the writable node is tagged with `expectedRevision`; it does not guarantee the revision stays current long enough to write.

Add `THTextEditorController.flushPendingReparse()` that:

- cancels the editor-level `_reparseTimer`;
- snapshots the requested editor revision and captures the current project epoch/root with it;
- if the controller is dirty, pushes that revision/content and captured identity through `THProjectController.reparseFile(...)` **and then** awaits `THProjectController.flushPendingReparse(...)` so the project-level timer is drained too; and
- is awaited at the start of `save()` before `saveTextProjectFile()` is invoked. Saving proceeds only when the typed flush outcome confirms the requested revision and project epoch; otherwise `save()` returns the corresponding `reparseFailed`, `supersededBeforeWrite`, or `projectChangedBeforeWrite` result without attempting serialization.

This fixes immediate single-file edit/replace → `Ctrl/Cmd+S`, including the root project file, without discarding another editor's unsaved content. Add regression coverage there.

### 8.1 Revision-aware revert

Add a typed `THProjectController.revertTextProjectFile({required String canonicalPath, required int requestedRevision, required int expectedProjectEpoch, required String expectedRootPath})` boundary:

```dart
enum THTextFileRevertStatus {
  reverted,
  alreadyClean,
  superseded,
  projectChanged,
  unknownPath,
  readFailed,
  reparseFailed,
}

class THTextFileRevertResult {
  final String canonicalPath;
  final int projectEpoch;
  final int requestedRevision;
  final int? reservedRevision;
  final THTextFileRevertStatus status;
  final THTextProjectContentSnapshot? snapshot;

  bool get isCurrentRevisionReverted =>
      status == THTextFileRevertStatus.reverted ||
      status == THTextFileRevertStatus.alreadyClean;
}
```

The nullable snapshot lets the editor adopt content, revision, dirty status, epoch, and root atomically. `reservedRevision` is non-null once disk content received a candidate revision, including failure or supersession after reservation, which makes the never-reuse rule observable in tests.

For a project-tracked path, revert follows this order:

1. Validate epoch/root and resolve a writable config/data path without mutating state. If the identity changed, return `projectChanged`; if the path is unknown or unsupported, return `unknownPath`.
2. Compare the project's current revision with `requestedRevision`. If they differ, return `superseded` with the latest project snapshot and do not discard the newer revision. If the requested revision has no pending dirty-content record, return `alreadyClean` with the current clean snapshot without reading or reparsing the file.
3. Read the file through the encoding-aware disk reader. On failure, log and return `readFailed`, leaving the pending content, parsed tree, revisions, cache, and dirty state unchanged.
4. Recheck epoch/root and `requestedRevision`, then reserve a fresh revision from the path's project-owned allocation counter for the disk content. Reservation consumes the revision even if the operation later fails or is superseded, but does **not** yet publish that revision as current, replace the pending record, or mark the path clean.
5. Reparse the disk content under the reserved revision. Use the incremental parse/splice path when safe. For root/reference-role-shape-conflict/missing-parent recovery, use an immutable full-project override snapshot containing every other pending revision and the target's disk content at the reserved revision; this deliberately replaces only the target's pending override for the candidate rebuild.
6. After every `await` and immediately before applying the parse result, recheck epoch/root and require the target's current revision still to equal `requestedRevision`. A stale project returns `projectChanged`; a newer edit returns `superseded` with the latest project snapshot. In either case, discard the candidate parse result and do not clear pending state.
7. Only after a successful guarded parse, atomically apply the rebuilt node/tree, set the target's current and parsed revisions to the reserved revision, cache the disk content, remove the target's pending record and dirty flag, and return `reverted` with the new clean snapshot. Other paths' latest pending contents and revisions still win during a full-reparse merge. If parsing fails, return `reparseFailed` and preserve the pre-revert tree and all pending state.

`THTextEditorController.revert()` adopts the returned snapshot. `reverted` and `alreadyClean` leave the editor clean; `superseded` adopts the newer project-owned content/revision and remains dirty when that snapshot is pending; `projectChanged`, `readFailed`, `reparseFailed`, and `unknownPath` leave the editor buffer and dirty state unchanged. For a path that is not tracked by any open project, retain the existing encoding-aware disk fallback in the editor: cancel the timer, reread disk, reset its local revision to `0`, and mark it clean without mutating project state.

## 9. Explicit Save Results

Refactor the text-file branch of `THProjectController.saveProjectFile()` into a typed, reusable boundary:

```dart
saveTextProjectFile({
  required String canonicalPath,
  required int requestedRevision,
  required int expectedProjectEpoch,
  required String expectedRootPath,
});
```

`THTextEditorController.save()` consumes the typed result directly; it never infers success from observable state or diagnostics. The generic compatibility and Save All contracts are defined separately in §9.1.

```dart
enum THTextFileSaveStatus {
  saved,
  alreadySaved,
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

  bool get isCurrentRevisionSaved =>
      status == THTextFileSaveStatus.saved ||
      status == THTextFileSaveStatus.alreadySaved;
}
```

Status meanings:

- **saved** — the exact requested/flushed revision was written and was still current when the write completed; only this status clears project/controller dirty state.
- **alreadySaved** — the exact requested revision is the current parsed revision and has no pending dirty-content record because it was loaded from disk or saved previously. No serialization or filesystem I/O is performed, `writtenRevision` is `null`, and `currentRevision` equals `requestedRevision`; the controller may remain or become clean because the project already records that revision as persisted.
- **supersededBeforeWrite** — a newer revision appeared after flush but before serialization/write; no stale write is attempted.
- **savedButSuperseded** — the requested revision reached disk, but a newer edit appeared while the asynchronous write was in progress; the newer revision remains dirty and the operation is reported as incomplete.
- **projectChangedBeforeWrite** — the captured epoch/root no longer matches before filesystem I/O starts; no write is attempted and no current-project state is touched.
- **writtenAfterProjectChange** — the project changed after filesystem I/O had already started and the bytes reached disk; the result records that side effect, but the stale operation does not mutate the new project's dirty/revision/diagnostic state.
- **reparseFailed** — no parsed node representing the requested revision is safe to serialize.
- **unknownPath / unsupportedNode** — the canonical path has no writable config/data node or resolves to another node type.
- **serializationFailed / writeFailed** — writer construction/serialization and filesystem I/O are caught separately, logged with path/stack trace, and returned with the corresponding status.

`saveTextProjectFile()` validates in this order before causing I/O:

1. require captured `expectedProjectEpoch` and canonical root to match, else return `projectChangedBeforeWrite` without consulting or mutating the new project;
2. resolve the canonical path; return `unknownPath` / `unsupportedNode` explicitly;
3. verify the node's recorded parsed revision equals `requestedRevision`, else `reparseFailed`;
4. inspect the current and pending revision records atomically: if the current revision differs, return `supersededBeforeWrite`; if the current revision equals `requestedRevision` and no pending dirty-content record exists, return `alreadySaved` without serialization or filesystem I/O; otherwise require the pending revision to equal `requestedRevision`;
5. serialize synchronously in its own `try` (`serializationFailed` on error), then recheck epoch/root immediately before starting I/O;
6. write bytes in a separate `try`. On error return `writeFailed`; append current-project diagnostics only if epoch/root still match, otherwise log without mutating the new project;
7. after the awaited write, check epoch/root before reading or mutating controller state. If the project changed, return `writtenAfterProjectChange` with `writtenRevision` set and mutate nothing. Otherwise compare the latest revision: `saved` (clear dirty) on an exact match, else `savedButSuperseded` (leave the newer revision dirty).

Every return path populates canonical path, captured epoch, and requested/written revision; `currentRevision` is nullable when reading it would cross a project-epoch boundary. No skipped/unknown/unsupported/stale-project path returns a successful result, and no failure is represented only by a log entry. `projectErrors` is **not** part of save-result detection.

`THTextEditorController.save()` returns `Future<THTextFileSaveResult>`. Update the editor save control to await it; project-level mixed-file Save All uses the generic aggregate contract below rather than routing through editor instances. Update the revert control to consume the typed §8.1 outcome instead of routing through `loadFile()`.

### 9.1 Generic save and Save All compatibility

Change `THProjectController.saveProjectFile(String filePath)` from `Future<void>` to `Future<THProjectFileSaveResult>`, where `THProjectFileSaveResult` is a sealed result with text and TH2 variants:

- `THProjectTextFileSaveResult` wraps the authoritative `THTextFileSaveResult` without translating or collapsing its statuses.
- `THProjectTH2FileSaveResult` carries canonical path, captured project epoch/root, and a `TH2FileSaveStatus` of `saved`, `alreadySaved`, `projectChanged`, `noOpenEditor`, or `saveFailed`. TH2 serialization/write remain owned by `TH2FileEditController.saveTH2File()` and are represented as one `saveFailed` status because that existing boundary does not separate serialization from I/O.
- `THProjectRejectedFileSaveResult` represents a generic request that cannot be classified as a tracked writable text node or registered TH2 editor, with `unknownPath` / `unsupportedNode`; it does not invent a text requested revision merely to construct a result.
- All variants expose `isComplete`: text delegates to `isCurrentRevisionSaved`; TH2 returns true only for `saved` / `alreadySaved`; rejected requests are never complete.

Generic text save uses project-owned state and does not require an editor controller:

1. Canonicalize the path and synchronously snapshot its current revision plus current epoch/root. Unknown/unsupported generic requests return `THProjectRejectedFileSaveResult`.
2. Call `flushPendingReparse(...)` for that snapshot revision. This is sufficient even when an editor-level timer has not fired because `setContent()` registers content/revision synchronously with the project controller. If no project reparse timer exists yet, flush starts the required parse directly from the registered pending record.
3. Call `saveTextProjectFile(...)` only after an exact successful flush. A newer revision returns the existing superseded status rather than silently switching the request to newer content.
4. If a registered editor has the same path, epoch/root, and revision, cancel its redundant editor timer before flushing and apply the final typed result back to it. Only `saved` / `alreadySaved` make that matching editor clean. A different/stale/newer editor is untouched. `reparseFile(...)` also treats a late callback for an already-parsed, already-saved revision as idempotent and must not recreate pending/dirty state.

Generic TH2 save snapshots epoch/root and the currently registered `TH2FileEditController` identity. It returns `projectChanged` if project identity changed before the synchronous save, `noOpenEditor` if no controller exists, `alreadySaved` when that controller is not dirty, `saved` only after `saveTH2File()` returns normally, and `saveFailed` after logging a caught exception. It removes/mirrors project dirty state only on `saved` / `alreadySaved`; no text revision or flush API is involved.

Change `saveAllModifiedFiles()` to return `Future<THSaveAllModifiedFilesResult>`. At entry it creates an immutable, canonical-path-sorted list of save descriptors from the then-current `dirtyFilePaths`. A text descriptor captures path, epoch/root, and requested revision; a TH2 descriptor captures path, epoch/root, and controller identity. It processes that fixed list sequentially through the same private helpers used by `saveProjectFile()`, continues after every failure/non-complete result, and never upgrades a descriptor to a newer revision that appears after the snapshot. Newly dirty paths and superseding revisions remain dirty for a later invocation.

`THSaveAllModifiedFilesResult` contains the ordered per-file results and a final immutable `remainingDirtyPaths` snapshot. Its `isComplete` is true only when every captured descriptor returned a complete result; `remainingDirtyPaths` is reporting context, not a proxy for any individual result (it may include edits created after Save All began). Empty Save All returns an empty, complete aggregate without I/O.

UI ownership remains narrow in Phase 8.5: `THTextEditorController.save()` interprets its typed result and updates its own dirty state; `THTextEditorWidget._handleSaveIntent()` awaits it directly. `TH2FileTabsPage._saveActiveTab()` returns `Future<void>`, awaits the relevant controller operation internally, and handles/logs any unexpected thrown exception; `CallbackShortcuts` invokes that fully handling future with an explicit `unawaited(...)` because its binding requires `VoidCallback`. These UI paths do not infer outcomes or add new messages. Logged/localized save diagnostics remain the failure surface. Project-level Save All callers must inspect the aggregate; tests no longer assert success only from `dirtyFilePaths`.

## 10. Implementation Sequence

1. Reconfirm the next unused test prefix (scan for duplicates, not just the max).
2. Add the constructor-injected `THProjectControllerOperations` bundle and route existing load/parse/splice/read/serialize/write calls through its production defaults before adding concurrency behavior.
3. Add `THProjectController.projectEpoch`, `_beginProjectLifecycleTransition()`, the non-advancing `_clearProjectState()`, and epoch-scoped activity/in-flight ownership. Remove `openProject()`'s call to public `closeProject()`; give each non-no-op public lifecycle entry point exactly one transition allocation.
4. Add revisioned pending/parsed-content tracking and the atomic `registerTextContentChange(...)` allocator. Extract the existing project-tab cleanup from `MPDialogAux.closeOpenProject()` into `MPGeneralController.closeProjectFileTabs(...)` and invoke it for every non-no-op lifecycle transition; make project-bound editor ownership immutable for a controller lifetime; add identity-aware stale-controller rejection/replacement; extend `loadFile()` / `setContent()` semantics and signatures; update callers.
5. Add revision-bearing parser content overrides and authoritative `THProjectParsedContentSnapshot` records to `loadProject()` / `loadFileNode()` results; make recursive loading override-first and remove post-parse cache rereads from controller result application.
6. Add the dirty-preserving in-memory full-project reparse and its non-`_applyLoadResult()` result-application helper; route the `_performReparse()` fallbacks through it.
7. Add `THProjectController.flushPendingReparse(...)` (drains the project-level timer) and `THTextEditorController.flushPendingReparse()` (drains the editor-level timer, then chains into the project-level flush).
8. Add the typed `revertTextProjectFile(...)` boundary and update `THTextEditorController.revert()` so a successful revert publishes a freshly allocated, parsed, clean disk revision while stale/failing reverts preserve pending content.
9. Add `THTextFileSaveResult` / `THTextFileSaveStatus`; refactor the text-file branch into `saveTextProjectFile(...)`; add sealed generic text/TH2/rejected results and the aggregate Save All result; make editor, generic, and Save All entry points flush/save fixed requested revisions and return their typed outcomes; make active-tab UI callers await without inferring status.
10. Update every existing test that exercises `loadFile` / `setContent` / `save` / `revert` / `saveProjectFile` / `saveAllModifiedFiles` / `openProject` / `reloadProject` / `closeProject` / `reparseFile`. Explicitly include `t3870_th_project_controller_test.dart` (lifecycle/reparse signatures), `t3872_th_project_controller_incremental_reparse_test.dart` (allocated-revision reparse contract), and `t3873_th_project_controller_save_test.dart` (generic/Save All typed results), then audit `t3902`, `t3906`, `t3907`, `t3909`, `t3913`, `t3914`, `t3918`, and any others found by a repository-wide call-site scan. Keep `t3905` passing as the find/replace regression suite.
11. Add the new focused tests in §11 using operation-bundle fakes and explicit started/release gates rather than timing sleeps for in-flight work.
12. Run focused tests, the full `flutter test` suite, and `flutter analyze`; resolve every warning/error.
13. Review the diff for direct parser/writer/`File` calls that bypass the injected operations bundle, stale-epoch mutation paths, and changes outside this refactor's scope.

Formatting and `.g.dart` regeneration remain automatic; do not run `dart format` or `build_runner` manually.

## 11. Test Plan

Confirm numbering immediately before implementation; renumber if `t3920` is taken. Representative allocation:

| Test file | Required coverage |
| --- | --- |
| `test/t3920_th_text_editor_save_flush_test.dart` | Immediate edit/replace then save reparses before serialization across **both** debounce layers (editor `_reparseTimer` and project `_reparseTimers`); project-controller-owned atomic revision allocation; simultaneous temporary and registered controllers starting from the same observed revision receive distinct revisions and cannot associate equal revisions with different content; allocation counters never decremented or reused after save/failure/revert; `loadFile()` atomically adopts project-owned cached content/current revision/dirty status and does not mark pending content clean; disk fallback uses revision `0` and clean state; tracked revert reserves a fresh never-reused revision, reparses disk content before atomically publishing it as clean, preserves every pending edit on read/reparse failure, cannot discard a newer concurrent revision, and uses a dirty-preserving full-project override snapshot for root/reference-role-shape-conflict fallback; untracked revert retains its local encoding-aware disk fallback; root-file and reference-role-shape-conflict flushes rebuild from immutable in-memory overrides rather than stale disk; changing a parent reference for one canonical child path from `source` to `input` or vice versa rejects the incompatible cached child, does not apply the provisional splice, and rebuilds the child with the required config/data type while preserving every pending override; direct incremental parsing retains the existing node type and contains no impossible runtime-type comparison; another file's unsaved content/revision survives that full rebuild; full-reparse failure preserves the old tree and all dirty state and returns `reparseFailed` without serialization; timer cancellation; same-epoch/revision save coalescing; explicit `saved`, `alreadySaved`, `supersededBeforeWrite`, `savedButSuperseded`, `projectChangedBeforeWrite`, `writtenAfterProjectChange`, `unknownPath`, `unsupportedNode`, `serializationFailed`, `writeFailed`; saving an unchanged loaded or previously saved revision returns `alreadySaved` without serialization or filesystem I/O; injected read/serializer/write failures reach only their matching typed status; a gated writer proves it is never invoked for `projectChangedBeforeWrite` and distinguishes an invoked in-flight write that yields `writtenAfterProjectChange`; edit during a gated write remains dirty and is reparsed later; only exact `saved` clears pending project dirty state, while `alreadySaved` confirms that no pending state exists and lets the requesting editor become clean; result detection never inspects `projectErrors`. |
| `test/t3921_th_project_async_epoch_isolation_test.dart` | Every `openProject`, non-empty explicit disk `reloadProject`, and `closeProject` advances the epoch by exactly one even when its load later fails; no-project reload is a no-op; opening does not invoke an additional public close transition; each load captures the epoch returned by `_beginProjectLifecycleTransition()` after allocation. Hold outgoing-project open/load, incremental reparse, full reparse, splice, and flush futures across closing/replacing it and loading/reloading the single current project (including the same root path under a newer epoch); prove late results and `finally` cleanup cannot mutate the current root/children, indexes, dependencies, diagnostics, caches, dirty/current/parsed revision maps, `isParsing` activity ownership, timers, or epoch-scoped in-flight entries. Stale entry cleanup cannot remove a newer operation with the same path/revision. Verify direct lifecycle calls use the shared project-tab cleanup, dispose outgoing project-owned controllers, and cancel their timers; reopening the same root/path creates a distinct controller loaded only from the current snapshot; retained references and already-fired editor callbacks from the outgoing epoch cannot call `setContent`, reparse, flush, save, or revert against the current project. Prove there is still only one root/tree/project controller throughout replacement. Use injected started/release gates—not elapsed-time delays—to hold every load/parse/splice/full-reparse/write operation at the intended await boundary. |
| `test/t3922_th_project_full_reparse_override_test.dart` | `loadProject()` / `loadFileNode()` with an empty override map behaves exactly as today while returning an authoritative content snapshot for every writable config/data node; a non-empty revision-bearing override map builds the root and included nodes from pending contents while newly referenced files without an override read from disk; snapshot content/encoding/provenance/revision exactly match what constructed each node; each disk file is read once per load and controller application performs no second read; override nodes receive their override revisions, existing clean disk nodes retain their parsed revisions, newly discovered/normal-load disk nodes receive `0`; the dirty-preserving result-application helper consumes result snapshots, then lets newer pending contents/revisions win; paths that leave the rebuilt dependency tree stay explicitly dirty; a failed full reparse leaves prior tree + all dirty state intact and reports the target revision unflushed. |
| `test/t3923_th_project_generic_save_contract_test.dart` | Generic text save snapshots the current project revision, starts/drains project reparse even when the editor timer has not fired, delegates to the exact typed text result, synchronizes only a matching registered editor, and treats a later callback for an already-saved revision as idempotent; stale/newer editors remain dirty. Generic TH2 save returns explicit `saved`, `alreadySaved`, `projectChanged`, `noOpenEditor`, and `saveFailed` outcomes while delegating bytes to `TH2FileEditController`; rejected generic paths return `unknownPath` / `unsupportedNode` without a fabricated text revision. Save All snapshots a canonical-path-sorted descriptor list once, handles mixed text/TH2 targets, continues after failures, never upgrades a captured text revision, excludes newly dirty paths from the active batch, preserves superseding/new dirty state, returns ordered per-file results plus `remainingDirtyPaths`, and returns an empty complete aggregate for an empty target set. The editor widget awaits saves; the shortcut's `VoidCallback` uses explicit `unawaited` only around `_saveActiveTab()`, which awaits internally and handles unexpected exceptions; neither UI path consults dirty/error observables for operation success. Update the direct compatibility regressions in `t3873`. |

Retain and run `t3905_th_text_editor_find_replace_test.dart` unchanged.

### End-to-end scenarios

1. Edit an open `.th`, immediately press `Ctrl/Cmd+S`, and confirm the just-typed bytes are on disk while a second dirty editor's content is untouched.
2. Edit the root `thconfig`, immediately save, and confirm the root node was serialized from the in-memory revision, not stale disk text, and other unsaved included files stay dirty.
3. Pause project A during incremental/full reparse and during a save write, close it, load project B, then release A's futures; verify B is byte-for-byte and state-for-state unchanged. The pre-write save performs no I/O; an already-started successful write is reported `writtenAfterProjectChange` without updating B.
4. Start a save, let a newer edit land while the async write is in flight, and confirm the result is `savedButSuperseded`, the newer revision stays dirty, and its reparse follows through.

## 12. Acceptance Criteria

- Each non-no-op public project lifecycle transition advances `projectEpoch` exactly once through `_beginProjectLifecycleTransition()`; `openProject()` never calls public `closeProject()`; `_clearProjectState()` never advances the epoch.
- No load, reparse, flush, save completion, or `finally` block captured under an older epoch can mutate the current project's tree, indexes, diagnostics, caches, dirty/revision state, in-flight ownership, or progress flags.
- Mapiah remains a single-project application with one global project controller/root/tree. Every lifecycle replacement disposes the outgoing project's tabs/controllers through the shared non-UI cleanup boundary; project-bound editor controllers remain owned by their loaded epoch/root for their entire lifetime, same-path reopening creates a new controller and buffer, and a retained stale reference cannot register content or otherwise act on the current project.
- `THProjectController` atomically allocates every text-content revision; open and temporary controllers can never assign the same revision to different content; revision numbers are never reused.
- Reverting a tracked dirty text file is revision-aware: disk content is parsed under a freshly allocated revision and becomes current/clean only if the requested revision is still current; read/reparse failure, project replacement, or a newer edit preserves pending content. Reverting an untracked text file retains the editor-local disk fallback.
- Immediate single-file save after editing/replacement — including the root `thconfig` — serializes the latest content and never restores stale disk text or clears another file's unsaved revision.
- Flushing/saving a root file or a parent edit whose child reuse has a reference-role/expected-shape conflict reparses from an immutable in-memory dirty-content snapshot. Direct shallow reparse preserves the existing file-node shape; no text Save As/rename or content-only runtime-type inference is assumed.
- Every project load/full reparse returns the exact content, effective encoding, provenance, and override revision used to construct each writable node. Result application populates caches and parsed revisions from that authoritative snapshot without rereading disk; override content and revision metadata cannot diverge.
- `THTextEditorController.save()` and `saveTextProjectFile()` return a typed, revision-aware result. Save success is determined only from `THTextFileSaveResult`; observable dirty state and `projectErrors` are never used as proxy return values; `saved` records a completed write, `alreadySaved` records a clean current revision without performing I/O, and a write superseded by a newer edit is reported without clearing that edit.
- Generic `saveProjectFile()` returns a sealed text/TH2/rejected result. Generic text save flushes one captured project revision without depending on an editor timer; TH2 keeps its controller-owned write path with explicit adapter outcomes; unknown/unsupported requests cannot appear successful.
- `saveAllModifiedFiles()` returns an ordered aggregate for one immutable initial descriptor snapshot, continues after failures, never chases newer revisions or newly dirty paths, and reports final remaining dirty paths separately from per-file authority. Matching editor dirty state is updated only from an exact typed save result.
- A project change before text-file I/O prevents the write; a change after I/O starts is reported explicitly and the stale completion never mutates the newly loaded project.
- Controller tests deterministically pause load/parse/splice/full-reparse/write operations through constructor-injected per-test gates and force read/serialization/write failures independently; no lifecycle race test relies on duration sleeps, filesystem permissions, static overrides, or process-global hooks.
- `isParsing` is derived from epoch-scoped activity ownership; a stale project-A completion cannot clear project B's progress.
- The full `flutter test` suite and `flutter analyze` pass with no warnings; all pre-existing controller tests are updated to the new signatures.

## 13. Risks and Decisions to Verify During Implementation

1. **Signature churn.** `loadFile` / `setContent` / `save` gain revision/epoch plumbing and `save()`'s return type changes. Audit and update every caller and test in step 10—including the explicitly affected `t3870`, `t3872`, and `t3873` Phase 3 suites—before adding new coverage; do not rely on production call sites alone because widget tests construct controllers directly.
2. **Full-reparse snapshot consistency.** Root/reference-role-shape-conflict/error fallback reparses must use one immutable snapshot of all dirty contents. `THProjectLoadResult` must carry the exact content/encoding/provenance/revision used by parsing so result application never performs a second disk read. Applying the rebuilt project must merge those authoritative records against the still-current revision map so edits made while parsing remain dirty; the generic disk-only `_applyLoadResult()` is never used for this path.
3. **Project lifecycle races.** Canceling a `Timer` does not cancel a future already started by that timer. Every async project operation carries epoch/root identity and guards all post-`await` mutation and cleanup. A disk write already in progress cannot be recalled, so its explicit `writtenAfterProjectChange` result records the side effect without touching the new project.
4. **Revision allocation ownership.** A controller-local `baseline + 1` scheme is invalid because a temporary controller and a newly opened registered controller may share the same baseline while holding different content. Only `THProjectController` allocates, and allocation atomically registers the associated pending content under the captured epoch/path. Tests must force the two-controller race and prove unique, ordered revisions with deterministic supersession.
5. **Save-result authority.** Logs, diagnostics, and dirty observables remain useful UI state but are not operation return values. `saved` and `alreadySaved` count as complete through `isCurrentRevisionSaved`, but only `saved` means filesystem I/O occurred; `savedButSuperseded` truthfully records that disk changed but newer editor content remains unsaved.
6. **Revert races.** Revert cannot reuse `loadFile()` because project-tracked cached content may itself be the pending edit being discarded. Reserve a new revision for disk content without publishing it, parse under the captured epoch/root, and atomically publish it as clean only while the requested revision remains current. A consumed candidate revision is never reused after failure or supersession.
7. **Single-project lifecycle versus stale instances.** Mapiah never holds two active project trees, but `Ctrl/Cmd+O` can call `openProject()` while one is loaded, and the current controller-level reset bypasses `MPDialogAux.closeOpenProject()`'s tab cleanup. Extract that cleanup into `MPGeneralController` and call it from every non-no-op controller lifecycle transition before state replacement. Immutable epoch/root ownership and guards on the old instance remain mandatory because closing registry entries cannot retract references or callbacks already held elsewhere.
8. **Test seam scope.** Inject only controller-owned operation boundaries through an immutable per-controller bundle. Keep the parser and writer APIs independently testable as concrete classes, keep production defaults behaviorally identical, and avoid a repository-wide filesystem interface. Explicit started/release gates are required for race ordering; arbitrary delays are not proof of an in-flight state.
9. **Generic and aggregate save authority.** Generic text save must snapshot a revision and use the same flush/save helpers as editor save; it cannot infer an editor's unscheduled content because registration is already synchronous. Save All snapshots descriptors once, continues through non-complete results, and does not silently switch to revisions created after entry. TH2 remains a separate controller-owned write with an explicit adapter result; aggregate callers inspect results rather than assuming an emptied dirty set means every captured save succeeded.
10. **Phase 9 coupling.** Phase 9's plan (2026-08-31) has already been aligned with this split: it carries a **Prerequisite** header pointing here, reframes its §7.3 as an "expected post-Phase-8.5 contract", makes its §10 step 3 "Delivered by Phase 8.5 … not by Phase 9", reserves `t3920`–`t3923` for this phase, and renumbers its own test table to start at `t3924`. Its §6.4 / §7.2–7.3 deliberately retain the descriptive detail as consuming context. When Phase 8.5 lands, re-check that those sections still match the contracts as finally implemented, and fix any drift; no prerequisite wiring or test renumbering remains to be done.
