<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 10: Save As for `thconfig` and `.th` Files — Implementation Plan

**Date:** 2026-09-15
**Status:** Proposed — grounded against the codebase 2026-09-15 (Phase 8.5 and Phase 9 have both landed; signatures below are the actual shipped contracts, not their own plan docs' proposed designs).

## 1. Overview & Objectives

This document details **Phase 10** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md) (§9, "Phase 10: Save As for `thconfig` and `.th` Files"). It adds Save As for text-editor tabs (`thconfig`/`.th`), the one file-identity operation the roadmap always scoped to Phase 10 and that TH2 canvas tabs have had since before this roadmap existed. Today `Ctrl/Cmd+Shift+S` and the Save As button/overflow entry are wired **only** to `TH2FileEditController.saveAsTH2File()` (`lib/src/pages/th2_file_tabs_page.dart:374,627,715-716,979,989`); a text-editor tab has no Save As at all.

Save As for a project text file is project-graph-aware, unlike TH2 Save As (which only rebases image references inside the one moved file): moving a `thconfig`/`.th` file changes both its own outgoing relative references and every other loaded file's incoming reference to it. Phase 10 must keep the project graph meaning-preserving across the move while reusing Phase 8.5's revision/epoch machinery and Phase 9's full-project reparse-with-overrides path — it deliberately does **not** invent a second parsing/reparsing mechanism.

### Key objectives

1. **Text-editor Save As**: `THTextEditorController.saveAs()` owns file-picker interaction; `THProjectController.saveTextProjectFileAs(...)` owns validation, serialization, path/reference migration, reparsing, and an explicit typed result. A cancelled picker changes nothing.
2. **Filename rules**: a `thconfig` file keeps any filename/extension (Therion's own rule); a `.th` file requires the `.th` extension, appended when omitted. The destination is canonicalized before any collision check.
3. **Flush before snapshot**: both editor and project debounce layers are drained (reusing Phase 8.5's `flushPendingReparse`) before the Save As content snapshot is taken, so a stale revision is never written.
4. **Graph-preserving move**: this file's own relative `source`/`input` (config) or `input`/`import` (data) directives are rewritten to keep resolving to their pre-move targets; every loaded file with an incoming reference to the old canonical path (via `THProjectController.dependentsOf(...)`) is rewritten to a relative path reaching the new location.
5. **Copy semantics, not move**: the old file is retained on disk untouched. The active editor/project adopt the new path. Rewritten referencing files become dirty and are saved only through the normal Save/Save All path — Save As never silently commits an unrelated pending edit.
6. **Root-aware**: a root `thconfig`/`.th` Save As sets `rootConfigPath` to the destination and rebuilds the project via the existing dirty-preserving in-memory full reparse (content overrides), never a disk-only `reloadProject()`. A non-root Save As performs the same override-based reparse without touching `rootConfigPath`.
7. **Tab identity migration**: extend `MPGeneralController.renameFileController(...)` so it also migrates the `THTextEditorController` registry entry and `openFileOrder`, preserving active index/selection; TH2's existing use of the same method is unaffected.
8. **Fail-safe staging**: validate and serialize before any destination write; on write or post-write rebuild failure, retain the old identity/dirty content and report a typed failure. Never delete a pre-existing destination as rollback.
9. **UI routing by active-tab type**: the Save As button, compact overflow entry, and `Ctrl/Cmd+Shift+S` route to `THTextEditorController.saveAs()` for a text tab and continue to route to `saveAsTH2File()` for a `.th2` tab.
10. **Complete integration**: EN/PT localization, help/keyboard-shortcut updates, and full controller/widget test coverage; `flutter analyze` and `flutter test` stay green.

## 2. Grounding: Current State

Verified by reading the code on 2026-09-15, after Phase 8.5 and Phase 9 both landed (see `CHANGELOG.md` and `git log`).

### 2.1 `THProjectController` (`lib/src/controllers/th_project_controller.dart`, 1559 lines)

- `_projectEpoch` (`@readonly`, exposed as `projectEpoch`) is advanced by exactly one inside `_beginProjectLifecycleTransition()` (`:264-277`), called once by each of `openProject` (`:168`), `reloadProject` (`:216`), and `closeProject` (`:255`). `_clearProjectState()` (`:281-300`) never advances the epoch. `_isCurrent(epoch, rootPath)` (`:305-306`) is the standard staleness guard used everywhere below.
- Revisioned pending content: `_allocationCounter`, `_currentRevision`, `_parsedRevision`, `_pendingContent` (`:132-143`), all keyed by canonical path. `registerTextContentChange({required canonicalPath, required content, required expectedProjectEpoch, required expectedRootPath})` (`:343-364`) is the sole synchronous atomic allocator, returning `-1` on a stale identity.
- `textContentSnapshot(String canonicalPath)` (`:370-394`) returns an immutable `THTextProjectContentSnapshot` (content, current revision, dirty flag, `projectEpoch`, `rootPath`, `isProjectTracked`), or `.untracked(...)` for a path with no `THConfigFileNode`/`THDataFileNode`.
- `reparseFile({required filePath, required updatedContent, required revision, required expectedProjectEpoch, required expectedRootPath})` (`:416-...`) is the editor-timer entry point; it schedules the project-level debounce that drains into `flushPendingReparse`.
- `flushPendingReparse({required canonicalPath, required expectedRevision, required expectedProjectEpoch, required expectedRootPath})` (`:483-...`) returns a `THProjectReparseFlushResult` with `.canProceedToSave` and `.status` (`reparsed`/`alreadyCurrent`/`superseded`/`projectChanged`/`failed`, per `th_project_reparse_flush_result.dart`).
- `revertTextProjectFile({required canonicalPath, required requestedRevision, required expectedProjectEpoch, required expectedRootPath})` (`:805-...`) returns a `THTextFileRevertResult` (statuses in `th_text_file_revert_result.dart`), reserving a fresh never-reused revision for disk content.
- `saveTextProjectFile({required canonicalPath, required requestedRevision, required expectedProjectEpoch, required expectedRootPath})` (`:949-1083`) is the exact contract from the Phase 8.5 plan: validates epoch/root/node-type/parsed-revision/current-revision in order, serializes via `_operations.serializeNode(node)`, writes via `_operations.writeBytes(path, bytes)`, and returns a `THTextFileSaveResult` (`saved`/`alreadySaved`/`supersededBeforeWrite`/`savedButSuperseded`/`projectChangedBeforeWrite`/`writtenAfterProjectChange`/`reparseFailed`/`unknownPath`/`unsupportedNode`/`serializationFailed`/`writeFailed`).
- `saveProjectFile(String filePath)` (`:1087-1156`) is the generic per-file entry point returning a sealed `THProjectFileSaveResult` (`THProjectTextFileSaveResult` / `THProjectTH2FileSaveResult` / `THProjectRejectedFileSaveResult`). It looks up a matching registered editor via `mpLocator.mpGeneralController.textEditorHandleForProjectSave(path, epoch, root, requestedRevision)` (`:1114-1116`) and applies the final result back to it through `editor?.applyExternalSaveResult(saveResult)` (`:1153`) — the exact seam Phase 10 must also use for a Save As destination's registered editor.
- `saveAllModifiedFiles()` (`:1225-1296`) snapshots a sorted `dirtyFilePaths` list into immutable `_SaveDescriptor`s and processes them sequentially; unaffected by Phase 10 except that it will now also observe rewritten-referencing-file dirty entries after a Save As.
- `nodeByCanonicalPath(String)` (`:1303-1304`), and the **Phase-9-added public accessor** `writableTextFileCanonicalPaths()` (`:1311-1318`) enumerating every `THConfigFileNode`/`THDataFileNode` canonical path, deduplicated — reusable by Phase 10 for target/collision enumeration instead of walking the tree again.
- **Dependency graph**: `_fileDependencies` / `_reverseDependencies` (`Map<String, Set<String>>`, `:110-113`), exposed read-only via `dependenciesOf(String canonicalPath)` (`:1320-1321`) and **`dependentsOf(String canonicalPath)`** (`:1323-1325`). `dependentsOf(oldCanonicalPath)` is exactly the "every loaded file with an incoming reference to X" lookup Phase 10 needs; it returns canonical paths of files that currently `source`/`input`/`import` the target, not line/column detail — Phase 10 must still walk each dependent file's own parsed elements to find the specific directive(s) referencing the moved path (a file can reference the same target more than once, e.g. two `input` lines, or via both `source` and a nested `input`).
- **`THProjectControllerOperations`** bundle (constructor-injected, `th_project_controller_operations.dart`): `loadProject(canonicalPath, {expectedShape, contentOverrides})`, `parseFileContent(...)`, `spliceFileNodeChildren(...)`, synchronous `readFileContent(...)`, synchronous `serializeNode(THProjectFileNode) → Uint8List`, and asynchronous `writeBytes(String path, Uint8List bytes)`. Phase 10's new destination write must go through `_operations.writeBytes(...)`, never a direct `File(...).writeAsBytes(...)` call, matching every other write path in this controller.
- No existing "Save As" or path-mutation method exists on `THProjectController` today; Phase 10 adds `saveTextProjectFileAs(...)` as new surface, following the exact validation-ordering discipline of `saveTextProjectFile(...)`.
- No TH2-adapter "Save As" result type exists on the project controller (`_saveTH2ProjectFile` only handles TH2 normal Save); Phase 10 does not need to add one, because `saveAsTH2File()` remains entirely on `TH2FileEditController` and is not routed through `THProjectController` at all (see §2.4) — this mirrors the current split, not something Phase 10 must reconcile.

### 2.2 `THTextEditorController` (`lib/src/controllers/th_text_editor_controller.dart`, 632 lines)

- `loadFile(String filePath)` (`:165-224`) resolves a canonical path, calls `textContentSnapshot(...)`, and — the important invariant for Phase 10 — **rejects rebinding**: "a controller already bound to a different project identity must never rebind or replace its buffer" (`:172-182`); a controller's `(_ownedProjectEpoch, _ownedRootPath)` is immutable for its lifetime once bound (class doc comment `:41-45`). Save As must therefore **not** call `loadFile()` on the existing controller with the new path; it must adopt the new canonical path/identity as part of one atomic Save As success path (see §5) while the controller instance itself is reused (unlike `openProject`/`closeProject`, Save As does not want a new controller instance and a torn-down tab).
- `setContent(String newContent)` (`:240-284`) captures `_ownedProjectEpoch!`/`_ownedRootPath!`, calls `registerTextContentChange(...)`, and schedules the editor-level `_reparseTimer`.
- `save()` (`:466-518`) awaits `flushPendingReparse()` (`:430-463`, which drains the editor timer then chains into the project-level flush) and then `saveTextProjectFile(...)`; applies the typed result via `_applySaveResult(...)` (`:525-534`).
- `revert()` (`:537-590`) delegates to `_projectController.revertTextProjectFile(...)` for a project-tracked dirty path and to `_revertUntrackedFromDisk()` (`:592-608`) otherwise.
- `canonicalPath` is an `@observable String` (`:55`), not `final` — it is already mutable at the field level (set once today, in `loadFile()`, `:184`). Phase 10 can assign it again as part of Save As, but must do so only inside the one atomic success transition described in §5, together with `_ownedProjectEpoch`/`_ownedRootPath`, `observedRevision`, and `isDirty`.
- `THTextEditorLoadState { notLoaded, loading, loaded, failed }` (`:31`) is unrelated to Save As status; Phase 10 does not touch it.
- Constructor: `THTextEditorControllerBase({THProjectController? projectController})` (`:51-52`), injectable exactly like the project controller's own operations bundle — useful for Save As controller tests.
- **No rename/path-mutation hook exists today** on `THTextEditorController`. Confirmed: the only path assignment sites are the constructor default (`canonicalPath = ''`, `:55`) and `loadFile()` (`:184`). Phase 10 adds the first one, as part of `saveAs()`.

### 2.3 `MPGeneralController` (`lib/src/controllers/mp_general_controller.dart`, 556 lines)

- `_openFileOrder` (`ObservableList<String>`, exposed read-only as `openFileOrder`, `:44`) and `_activeTabIndex` (`:47`) are the tab-order/selection state. `_textEditorControllers` is a plain `HashMap<String, THTextEditorController>` keyed by normalized path (`:52-53`); `_t2hFileEditControllers` is the parallel TH2 map (`:49-50`).
- `getTextEditorController(String filename)` (`:251-274`) defensively disposes and replaces a stale project-bound entry before handing out a controller, then `putIfAbsent`s a **new** controller for an unregistered path — it does not look up by any secondary key, so Save As migrating a controller's canonical path must also move its **map entry** (old key → new key), not just mutate the controller in place, or a subsequent `getTextEditorController(newPath)` call would construct a second, unrelated controller for the same file.
- `getTextEditorControllerIfExists(String filename)` (`:245-249`) is the read-only counterpart used by widgets (`th2_file_tabs_page.dart:746-748`).
- **`renameFileController({required oldFilename, required newFilename})` already exists (`:403-423`) but is TH2-only in practice today**: it moves the `_t2hFileEditControllers` map entry (`:410-416`) and rewrites the matching `_openFileOrder` entry in place (`:418-422`), but it never touches `_textEditorControllers`. This is exactly the "extend `MPGeneralController.renameFileController(...)`" the roadmap blurb (§9, Phase 10 bullet 6) anticipated needing; Phase 10 extends this one method (see §6) rather than adding a parallel type-neutral API, because its existing shape (rewrite one `_openFileOrder` entry + move one registry map entry) already generalizes to a text controller with only the addition of a `_textEditorControllers` move and index/selection preservation.
- `closeProjectFileTabs(Iterable<String> canonicalPaths)` (`:283-295`, added in Phase 8.5) removes/disposes every open tab whose canonical path is in the outgoing set; unaffected by Phase 10 except that if a Save As target happens to coincide with an outgoing project's tab (impossible in practice, since Save As only runs against the currently loaded project), no special-casing is needed.
- `textEditorHandleForProjectSave(canonicalPath, epoch, rootPath, revision)` (`:301-316`) returns the registered controller only when `controller.matchesProjectSaveRequest(...)` — Phase 10's generic-save-adjacent Save As should follow the same "only touch a controller whose stored identity matches" discipline, but Save As is editor-initiated (never a generic/Save-All path), so it can call `applyExternalSaveResult`-style updates directly on `this` rather than looking the controller up by path.
- `isTH2Tab(String filename)` (top-level function, `:29-31`) is `filename.startsWith(mpNewFilePrefix) || p.extension(filename).toLowerCase() == '.th2'`. Used by `th2_file_tabs_page.dart` to route Save/Save As by active-tab type; Phase 10 reuses it unchanged.

### 2.4 TH2 Save As precedent (`lib/src/controllers/th2_file_edit_controller.dart:1531-1594`, `lib/src/pages/th2_file_tabs_page.dart`)

- `saveAsTH2File()` (`:1531-1594`): computes an initial directory/filename, calls `FilePicker.saveFile(...)` with `allowedExtensions: ['th2']`, appends `.th2` if the chosen name lacks it (`:1554-1563`, including an odd rename-in-place of an existing same-named file — see §12 risk 6), calls `mpGeneralController.renameFileController(oldFilename: _th2File.filename, newFilename: filePath)` (`:1569-1572`), reassigns `_th2File.filename = filePath` (`:1573`), rebases imported image paths (`_rebaseImportedImagePathsForSaveAs`, `:1596-1633`, using `MPDirectoryAux.relativePathFromReferencePath`/`rebaseRelativePath`), updates `lastAccessedDirectory`, and only then calls `_actualSave(File(filePath))` (`:1586`). **TH2 Save As is not project-graph-aware**: it never touches `THProjectController`, never checks node collisions, and never rewrites any other file's references, because a `.th2` file's own project identity (if any) is resolved purely by the `.th` files that `input` it, and `.th2` content itself carries no outgoing `source`/`input` directives Mapiah currently rewrites for a move. Phase 10's `.th`/`thconfig` Save As is a materially bigger operation and cannot reuse this method's body — only its picker-interaction shape (compute default name/dir → `FilePicker.saveFile` → extension normalization) is a template.
- **UI routing** — all three entry points currently call `saveAsTH2File()` unconditionally, without checking `isTH2Tab`:
  - App-bar expanded action, `th2_file_tabs_page.dart:369-376` (`IconButton` calling `controller?.saveAsTH2File()`, where `controller` is a `TH2FileEditController?` obtained at `:351-353` — this block only exists inside a builder that reads TH2 controllers, so today a text tab's Save As button, if visible at all, would resolve `controller` to `null` and no-op silently).
  - Compact overflow menu: `_buildFileMenuEntries(...)` (`:616-632`) and `_handleOverflowMenuAction(...)` (`:708-742`, case `saveAs` at `:715-716`) — both work from `_getActiveController()` (`:690-705`), which is typed `TH2FileEditController?` and returns `null` for a text tab.
  - Keyboard shortcut: `Ctrl/Cmd+Shift+S` (`_withShortcuts`, `:970-990`) calls `_getActiveTH2FileEditController(generalController)` (`:1065-1080`) and no-ops for a text tab, with an explicit comment "Save As has no text-editor equivalent, so it stays TH2-only" (`:1082-1084`) — this comment is the exact sentence Phase 10 must falsify.
  - Compare with `_saveActiveTab(MPGeneralController)` (`:1085-...`), the existing `Ctrl/Cmd+S` handler, which **already** branches on `isTH2Tab(activeFilename)` (`:1098`) to call the TH2 or text-editor save path — Phase 10's Save As routing should follow this exact existing pattern, not the Save As handlers' current TH2-only shape.

### 2.5 Writers, parser, and directive-path mutability (`lib/src/mp_file_read_write/`, `lib/src/elements/th_config/`, `lib/src/elements/th_data/`)

- `THConfigFileWriter.serialize(...)` (`th_config_file_writer.dart:19-46`) and `THFileWriter.serialize(...)` (`th_file_writer.dart:23-51`) both follow the identical "unchanged, unmodified line reuses `element.originalLine` verbatim; otherwise regenerate the line from the element's typed fields" rule (config: `:32-38`; data: `:36-42` plus the `THSurvey`-always-regenerated special case at `:37,91-109`, and a nested per-element `!element.isModified && element.originalLine.isNotEmpty` short-circuit at `:111-113`). This is the exact mechanism Phase 10 needs for "rewrite just the path token, preserve everything else": mark only the rewritten directive element's `isModified` so its own line is regenerated by `_serializeElement(...)`, while every sibling element (including comments, blank lines, and continuation-joined lines) still round-trips via `originalLine`.
- **Directive path fields are `final`, not mutable**: `THConfigSource.filePath` (`th_config_source.dart:7`), `THConfigInput.filePath` (`th_config_input.dart:7`), `THDataInput.rawPath` (`th_data_input.dart:7`), `THImport.filePath` (`th_import.dart:7`) are all declared `final`. There is no `copyWith` on any of these four classes today (confirmed by reading each file in full — only field + constructor). Rewriting a directive's path therefore means **constructing a new element instance** with the new path, the same `lineNumber`, `originalLine: ''`, and `isModified: true`, then **replacing it by index** in the containing `THConfigFile.elements` / `THDataFile.elements` list. Both lists are non-`final`-content `final List<...> elements` (mutable contents, e.g. `th_config_file.dart:20`, `th_data_file.dart:22`) — direct `elements[i] = newElement` is the natural mechanism; there is no existing `substituteElement`-style helper on `THConfigFile`/`THDataFile` (unlike `TH2File.substituteElement` used by `_rebaseImportedImagePathsForSaveAs`, `th2_file_edit_controller.dart:1631`). Phase 10 should add a small `_ThDirectiveRewrite` helper (see §6) rather than four inline copy-construct-and-replace call sites.
- `THProjectPathResolver.resolve({required rawPath, required includingFileAbsolutePath, String? defaultExtension})` (`th_project_path_resolver.dart:8-30`) is the one-shot forward-resolution helper (raw directive path + containing file's absolute path → resolved absolute path, applying a default extension when the raw path has none). It has no inverse; Phase 10 needs the inverse (absolute target path + new containing-file directory → a relative path string to write back) and should use `MPDirectoryAux.relativePathFromReferencePath`/`rebaseRelativePath` (already used by `TH2FileEditController._rebaseImportedImagePathsForSaveAs`, `th2_file_edit_controller.dart:1605-1613`) rather than inventing a second relative-path helper — confirm at implementation time whether `MPDirectoryAux`'s existing helpers operate on file-to-file (not file-to-directory) reference paths compatibly with `THProjectPathResolver.resolve`'s directory-of-containing-file semantics.
- `THProjectPathResolver.canonicalize(String absolutePath)` (`:33-36`) is `p.normalize`, deliberately not symlink-resolving; this is the canonical-path space every controller map (`_nodesByCanonicalPath`, `_fileDependencies`, `_currentRevision`, etc.) is keyed in, and the space Phase 10's destination-collision check must canonicalize into before comparing against `writableTextFileCanonicalPaths()` and every open tab's `canonicalPath`.
- `THProjectContentOverride` (`th_project_parser.dart:42-53`) is the override-map value type Phase 8.5 added: content + revision, keyed by canonical path, consumed first by `loadProject`/`loadFileNode` (`:196-245`) before falling back to disk (`:415-426`). `THProjectLoadResult.contentSnapshotsByCanonicalPath` (`:78-98`) records exactly what content/encoding/provenance/revision built each node. This is the exact mechanism Phase 10's in-memory rebuild (§5) must drive: an override map containing (a) the target's new canonical path → its own (possibly self-rewritten) content, and (b) every rewritten referencing file's existing canonical path → its rewritten content — then a full reparse via `_operations.loadProject(rootConfigPath, contentOverrides: ...)` (root case) or the existing non-root dirty-preserving full-reparse path already used by `_performReparse()`'s fallbacks (non-root case), not a bespoke tree-splice.
- `THProjectFileNode.absolutePath` and `relativePathToProjectRoot` are **both `final`** (`th_project_file_node.dart:7,9`), and `THConfigFileNode`/`THDataFileNode` wrap an immutable `configFile`/`dataFile` reference with no setters (`th_config_file_node.dart`, `th_data_file_node.dart`). **No project node can be mutated in place to represent a new path.** This confirms Phase 10 cannot "rename a node"; it must always go through a rebuild (full reparse with overrides), exactly matching the roadmap's own phrasing ("rebuild the project from an immutable in-memory content snapshot" for the root case, "performs the same dirty-preserving reparse" for the non-root case) rather than requiring a design decision.
- `THConfigFile.filename` / `THDataFile.filename` (mutable `String`, `th_config_file.dart:14`, `th_data_file.dart:18`) exist on the *content* model but are metadata only (not consulted by the writer, not the source of `THProjectFileNode.absolutePath`); do not rely on mutating this field for anything.

### 2.6 Localization and help/shortcut docs

- `lib/l10n/intl_en.arb` / `intl_pt.arb` (not `app_en.arb`/`app_pt.arb` — correct the roadmap's shorthand). Existing conventions to follow:
  - TH2 Save As strings: `th2FileEditPageSaveAs` ("Save as (Shift+Ctrl+S)"), `th2FileEditPageSaveAsDialogTitle` ("Save TH2 file as") (`intl_en.arb:2416-2427`).
  - Project-level failure strings use a `thProject*Failed` family with an `{error}`/`{path}` placeholder: `thProjectOpenFailed`, `thProjectReloadFailed`, `thProjectSaveFailed` (`:4534-4551`). Phase 10 should add `thProjectSaveAsFailed`-shaped keys in the same family for logging/diagnostics-facing text, per the Phase 8.5/9 convention that **typed statuses, not new dialog copy, are the primary failure surface** — no `THTextFileSaveStatus`-equivalent status currently has a dedicated user-facing arb string (grep for `writeFailed`/`serializationFailed` as description text found nothing), so Phase 10 should not over-invent new dialog strings beyond what §9's confirmation/error UI actually needs.
  - Multi-file search strings use a flat `projectSearch*` prefix, no `th` prefix (`intl_en.arb:4559+`, e.g. `projectSearchTitle`, `projectSearchOpenTooltip`). Phase 10's new user-facing strings (picker dialog titles, collision/extension error text) should use a `projectSaveAs*` or `thTextEditorSaveAs*` prefix — confirm the more idiomatic choice at implementation time by checking which existing widget-scoped prefix family (`th2FileEditPage*` vs `projectSearch*`) Phase 10's new widget code sits closest to; this doc does not mandate one over the other.
- Help/shortcut docs: `assets/help/en/keyboard_shortcuts_edit.md:77` already lists "Save file as | Ctrl+Shift+S" (TH2-only today); `:105` documents Ctrl+Shift+F for multi-file search as an example of how Phase 9 added its own shortcut-table row. Phase 10 updates the existing Save-As row's description to cover both tab types rather than adding a second row, since the shortcut itself does not change.

### 2.7 Test prefix

- Current max allocated prefix is `t3932` (`t3932_phase9_documentation_localization_test.dart`). Confirmed duplicates exist at `t3172`, `t3760`, and `t3918` (two files each) — the existing tree already has this issue; Phase 10 must re-scan for duplicates (not just take the max) immediately before allocating, per the convention both prior phase docs used. Provisional starting point: **`t3933`**.

## 3. Scope and Non-Goals

### In scope

- `THTextEditorController.saveAs()`: file-picker interaction, extension/shape rules, delegating to the project controller, and adopting the returned success identity.
- `THProjectController.saveTextProjectFileAs(...)`: canonicalization, collision checks, flush-before-snapshot, serialization of the destination, incoming/outgoing reference rewriting, root-vs-non-root rebuild, and a typed result.
- Extending `MPGeneralController.renameFileController(...)` to migrate `_textEditorControllers` and active-tab/selection state atomically, in addition to its existing TH2 behavior.
- Routing the Save As button (expanded app bar), compact overflow entry, and `Ctrl/Cmd+Shift+S` by active-tab type (`isTH2Tab`), continuing to call `saveAsTH2File()` for a `.th2` tab and calling the new text path otherwise.
- Localized picker titles and the minimum failure copy actually needed by the confirmation/error UI (extension rule, destination-collision, write failure).
- EN/PT localization, help-page, and keyboard-shortcut-table updates.
- Controller and widget test coverage per §11.

### Out of scope

- Any change to `saveAsTH2File()`'s own behavior, image-path rebasing, or its lack of project-graph awareness.
- Renaming/moving a `.th2` file's project-tree identity as a `source`/`input`-target rewrite target of a *text* file's Save As — a `.th2` file is never itself the file being "Saved As" by this phase (only `thconfig`/`.th` are), but it **can** appear as the target of a rewritten `input`/`import`... no: `.th2` files are `input`-included by `.th`, so if a `.th` file that itself contains `input somefile.th2` is moved, that `input` line is one of "this file's own relative path-bearing directives" in scope for §7. The `.th2` file itself is not moved, renamed, or otherwise touched.
- Multi-file batch Save As, or Save As for more than one file per invocation.
- Automatically saving referencing files that became dirty from reference rewriting — that remains the user's normal Save/Save All action, per objective 5.
- A new generic type-neutral tab-identity API replacing `renameFileController` — Phase 10 extends the existing method (see §2.3, §6) rather than replacing it, since nothing else in this phase needs a broader API.
- Filesystem-level move/rename of the old file, symlink resolution, or any change to `THProjectPathResolver.canonicalize`'s non-symlink-resolving behavior.
- Undo/redo integration for the reference-rewrite side effects (rewritten referencing files are ordinary dirty text edits and already participate in the app's existing text-editor state, but no cross-file "undo the whole Save As" transaction is introduced).

## 4. User Experience

### 4.1 Entry points

Reuse the three existing Save As entry points, now branching by active-tab type exactly as `_saveActiveTab(...)` already does for `Ctrl/Cmd+S` (`th2_file_tabs_page.dart:1085-1098`):

1. App-bar expanded action (`:369-376`): change the `Row`'s `controller` lookup to also resolve a `THTextEditorController?` for a text tab, and route the `save_as_outlined` `IconButton`'s `onPressed` to `textController.saveAs(context)` (or an equivalent non-`BuildContext`-owning call — see §4.2) when the active tab is not a `.th2` tab.
2. Compact overflow entry (`_buildFileMenuEntries`/`_handleOverflowMenuAction`, `:616-632`, `:708-742`): same branch, mirroring `_getActiveController()`'s TH2-only shape with a new type-neutral active-controller resolution (or two parallel nullable lookups, matching `_saveActiveTab`'s existing style at `:1097-1099`).
3. `Ctrl/Cmd+Shift+S` (`_withShortcuts`, `:970-990`): replace the unconditional `_getActiveTH2FileEditController(...)` calls with a branch on `isTH2Tab(activeFilename)`, calling `saveAsTH2File()` for TH2 and the new text path otherwise. Delete or rewrite the misleading comment at `:1082-1084`.

### 4.2 Picker interaction and cancellation

`THTextEditorController.saveAs()` follows `saveAsTH2File()`'s existing shape for the picker call itself (`th2_file_tabs_page.dart` imports `FilePicker.saveFile` the same way TH2 does):

1. Flush both debounce layers (`flushPendingReparse()`) before doing anything picker-related, so the eventual snapshot is current. If the flush reports `projectChanged`/a superseded/failed status, abort with a typed `projectChangedBeforeWrite`/`reparseFailed`-style result and open no picker.
2. Compute an initial directory (`mpGeneralController.lastAccessedDirectory`, falling back to `p.dirname(canonicalPath)`) and an initial filename (`p.basename(canonicalPath)`).
3. Call `FilePicker.saveFile(...)` with a localized dialog title distinguishing `thconfig` (any/no required extension — pass no `allowedExtensions` restriction, or an empty/permissive one, since Therion allows any filename for the root config) from `.th` (`allowedExtensions: ['th']`, matching how TH2 passes `['th2']`).
4. A cancelled picker (`null` result) returns a typed `cancelled` status immediately: no write, no controller/tab mutation, no project mutation, no dirty-state change, no tab-order change. This governs both this method's own result and — because `saveAs()` is the only caller of the project boundary — `saveTextProjectFileAs(...)` is never invoked at all for a cancellation; the cancellation is handled entirely client-side in the picker step, unlike TH2's flow which is also fully client-side for cancellation (`saveAsTH2File()`'s `if (filePath != null) { ... }` guard, `:1553`).
5. On a chosen path, apply the extension rule from §4.3, then call `THProjectController.saveTextProjectFileAs(...)` (§5) and adopt its result.

### 4.3 Filename and extension rules

- `thconfig`-shaped file (a `THConfigFileNode`, or — for an as-yet-untracked path being Saved As, see §5.6 — the source controller's currently loaded shape): keep the user's chosen filename/extension verbatim, matching Therion's own "any filename or extension" rule for the root configuration file (already stated in the roadmap overview §2.1 table). Do not force or suggest `.th`/`.thconfig`.
- `.th`-shaped file (a `THDataFileNode`): if the chosen filename has no extension, append `.th` (mirroring the roadmap bullet 2's exact wording and `THProjectPathResolver.resolve`'s own `defaultExtension` convention for directive-path resolution, §2.5). If it has a *different* extension (e.g. the user typed `foo.txt`), accept it as-is — Phase 10 does not second-guess a deliberate non-`.th` data-file name, matching the general lenience Therion itself has for `input`-included files with any extension.
- Canonicalize the destination (`THProjectPathResolver.canonicalize(p.absolute(chosenPath))`) before any collision check in §4.4, so `./foo.th`, `foo.th`, and an absolute equivalent path are recognized as the same target.

### 4.4 Collision and same-path rules

1. **Same path as current**: if the canonicalized destination equals the controller's current `canonicalPath`, delegate to normal `save()` instead of Save As (no picker re-prompt needed at this point since the picker already ran; simply call the existing `save()` path and surface its result as the Save As outcome). This matches "choosing the current path delegates to normal Save" from the roadmap bullet 2.
2. **Destination already a project node**: if `THProjectController.nodeByCanonicalPath(destination)` returns a non-null `THConfigFileNode`/`THDataFileNode`/`TH2FileNode`/`THMissingFileNode`, reject with a localized collision error — "choosing a path already represented by another project node ... is rejected ... instead of merging controllers" (roadmap bullet 2). No write occurs.
3. **Destination already an open tab**: if `mpLocator.mpGeneralController.getTextEditorControllerIfExists(destination)` or the TH2 equivalent is non-null (i.e. some other open tab already owns that canonical path, even if it is not part of the current project — e.g. a standalone open text tab), reject the same way. This additional check exists because a project node collision alone would miss a standalone open tab occupying the same path.
4. A destination that exists on disk but is **not** currently tracked as any project node or open tab (an ordinary overwrite-an-untracked-file Save As) is allowed — Phase 10 does not add a new "confirm overwrite" prompt beyond what the OS-native `FilePicker.saveFile` dialog already provides (matching TH2's existing behavior, which also does not add a second confirmation).

## 5. `THProjectController.saveTextProjectFileAs(...)`

### 5.1 Signature and result

```dart
Future<THTextFileSaveAsResult> saveTextProjectFileAs({
  required String oldCanonicalPath,
  required String newCanonicalPath,
  required int requestedRevision,
  required int expectedProjectEpoch,
  required String expectedRootPath,
});
```

```dart
enum THTextFileSaveAsStatus {
  saved,
  supersededBeforeWrite,
  projectChangedBeforeWrite,
  writtenAfterProjectChange,
  reparseFailed,
  unknownPath,
  unsupportedNode,
  destinationCollision,
  serializationFailed,
  writeFailed,
  rebuildFailed,
}

class THTextFileSaveAsResult {
  final String oldCanonicalPath;
  final String newCanonicalPath;
  final int projectEpoch;
  final int requestedRevision;
  final int? writtenRevision;
  final THTextFileSaveAsStatus status;
  final bool isRootChange;

  bool get isComplete => status == THTextFileSaveAsStatus.saved;
}
```

No `cancelled` status appears here — cancellation is handled entirely inside `THTextEditorController.saveAs()` before this boundary is ever called (§4.2 point 4), matching the roadmap's "a cancelled picker returns without changing disk, controller identity, dirty state, tab order, selection, or project state" as a client-side guarantee, not a project-controller status.

### 5.2 Validation order (mirrors `saveTextProjectFile`'s discipline exactly)

1. Canonicalize both paths. Require `expectedProjectEpoch`/`expectedRootPath` to still match; else `projectChangedBeforeWrite`.
2. Resolve `oldCanonicalPath` to a node; require it to be a `THConfigFileNode`/`THDataFileNode`; else `unknownPath`/`unsupportedNode`.
3. Require the node's `_parsedRevision` to equal `requestedRevision`; else `reparseFailed` (the caller is responsible for having flushed first — see §5.3; this mirrors `saveTextProjectFile`'s step 3 exactly, so a caller that skips flushing gets the same failure shape as normal Save).
4. Require the *current* revision to equal `requestedRevision`; else `supersededBeforeWrite` (mirrors `saveTextProjectFile`'s step 4, but Save As never returns an `alreadySaved`-equivalent — a Save As always performs a write to the new destination even when the source has no pending edit, because the destination itself is new).
5. Re-run the destination collision checks from §4.4 points 2–3 against the **current** project/tab state (not a snapshot taken before any `await`) — a project mutation could have introduced a new node/tab at the destination path while the picker dialog was open. On collision, return `destinationCollision` without mutating anything.
6. Build the rewrite plan (§7): this file's own outgoing directive rewrites (if its directory changed) and every dependent file's incoming directive rewrite(s), all as **in-memory content strings**, without mutating any controller or the live project tree yet.
7. Serialize the **destination**'s bytes from the (possibly self-rewritten) content — not from `_operations.serializeNode(node)` on the still-old node, since the node's own `absolutePath` is unrelated to serialization (the writer serializes content, not a path) but the directive-rewrite step already produced the exact string to write; encode it via the same encoding rules `THConfigFileWriter.serializeToBytes`/`THFileWriter.serializeToBytes` already apply (reuse those methods with the rewritten in-memory `THConfigFile`/`THDataFile`, not hand-rolled encoding). On failure, `serializationFailed`.
8. Recheck epoch/root immediately before I/O; `projectChangedBeforeWrite` on mismatch.
9. `await _operations.writeBytes(newCanonicalPath, destinationBytes)`. On failure, log and return `writeFailed`, leaving the old file, old node, and all pending state untouched. **Never write to `oldCanonicalPath`** — the old file is retained unmodified as the classic Save As copy-semantics guarantee (roadmap bullet 5).
10. After the awaited write, recheck epoch/root. If stale, return `writtenAfterProjectChange` (bytes are on disk at the new path, but the stale operation must not mutate the current project) — note this leaves an orphaned, un-tracked file at the destination; this is the same class of outcome `saveTextProjectFile`'s `writtenAfterProjectChange` already accepts for ordinary saves, so Phase 10 is not introducing a new risk category.
11. Apply the rewrite plan's referencing-file content as *pending* edits via `registerTextContentChange(...)` for each dependent path (so they become dirty exactly like a normal edit, per objective 5) — but do this only as part of the same rebuild step (12), since the rebuild is what actually needs those contents.
12. Rebuild the project in one atomic step (§5.4): root case re-runs `_operations.loadProject(destinationOrExistingRoot, contentOverrides: ...)`; non-root case runs the existing dirty-preserving in-memory full-project reparse the same way a reference-role-shape conflict already does today (Phase 8.5 §7). On rebuild failure, return `rebuildFailed`, and **restore** the pre-Save-As tree/dirty state (§5.5) rather than leaving the project half-migrated.
13. On rebuild success: clear the moved file's pending/dirty record (it is now clean at the new path, since its bytes were just written and its content is exactly what was serialized), leave every rewritten dependent file dirty, and return `saved` with `writtenRevision` set.

### 5.3 Caller's flush responsibility

`saveTextProjectFileAs(...)` does **not** itself call `flushPendingReparse(...)` — exactly like `saveTextProjectFile(...)` does not either; flushing is `THTextEditorController.save()`'s/`saveAs()`'s responsibility (see `save()`'s own `await flushPendingReparse()` before calling `saveTextProjectFile(...)`, `th_text_editor_controller.dart:482`). `THTextEditorController.saveAs()` must call its own `flushPendingReparse()` first (§4.2 point 1) and pass the flushed revision through, for exact symmetry with `save()`.

### 5.4 Root vs. non-root rebuild

- **Root** (`oldCanonicalPath == rootConfigPath`): after a successful destination write, set `rootConfigPath = newCanonicalPath` and rebuild via `_operations.loadProject(newCanonicalPath, expectedShape: ..., contentOverrides: overridesIncludingEveryOtherPendingEditAndTheNewRootsOwnContent)`. This is the *same* override-carrying rebuild Phase 8.5 built for "root-file changes" (§7 there) — Phase 10 does not add a second root-rebuild mechanism, it just also changes `rootConfigPath` as part of one lifecycle-adjacent (but not epoch-advancing — see below) mutation. Preserve every other dirty buffer exactly as an ordinary root-file-edit full reparse already does (Phase 8.5 §7 point 5: "reapply the latest pending contents and revisions so dirty overrides always win").
- **Non-root**: `rootConfigPath` is untouched. Run the existing non-root dirty-preserving full-project reparse (the same one `_performReparse()`'s reference-role-shape-conflict/missing-parent fallback already uses) with an override map containing the new destination path's content plus every rewritten dependent's content. The old canonical path simply disappears from the rebuilt tree (its parent's `source`/`input` line no longer points at it); per Phase 8.5 §7 point 5, "paths that disappeared from the rebuilt dependency tree remain explicitly dirty until saved, reverted, or otherwise resolved" — but here the old path is not "disappeared-and-still-dirty", it is "disappeared-and-intentionally-retired": Phase 10 must explicitly clear the old path's revision/pending-content bookkeeping (`_allocationCounter`/`_currentRevision`/`_parsedRevision`/`_pendingContent` entries for `oldCanonicalPath`) as part of successful rebuild application, distinct from the generic "still dirty" fallback, so a later `saveAllModifiedFiles()` does not try to save a path that no longer has a node.
- Neither case advances `projectEpoch`. Save As is a within-project structural change (new node added at the destination path, one node removed at the old path, N dependent nodes content-changed), analogous to how the in-memory full reparse in Phase 8.5 §7 is "work within the same project" and does not advance the epoch — an epoch bump would incorrectly invalidate every other currently-open, unrelated editor's `matchesCurrentProject()` check.

### 5.5 Failure rollback

Per objective 8 and the roadmap's explicit rollback rule: "if the subsequent in-memory graph rebuild fails, report the error without pretending Save As completed and retain enough staged state to restore the old project/editor identity. Never delete a pre-existing destination as rollback."

- Stage the rewrite plan (§7) and the destination bytes *before* any mutation of `_nodesByCanonicalPath`, `_fileDependencies`/`_reverseDependencies`, `_currentRevision`/`_pendingContent`, or `rootConfigPath`. This is naturally satisfied by validation order §5.2 (steps 6–7 build/serialize before step 9 writes, and step 9 writes before step 12 rebuilds) — no additional staging structure beyond local variables is needed inside the one `@action` method body.
- If the destination write (step 9) fails: nothing has been mutated yet; simply return `writeFailed`. The already-existing destination file (if any, from an earlier partial attempt) is left exactly as the failed write left it — Phase 10 does not attempt to detect/clean up a partial write, matching `saveTextProjectFile`'s own `writeFailed` handling, which also does not roll back a partial `writeBytes`.
- If the rebuild (step 12) fails: the destination file physically exists on disk (the write succeeded), but the project must behave as if Save As did not happen: keep `rootConfigPath` unchanged (root case: do not commit the `rootConfigPath` reassignment until the rebuild has already succeeded — i.e. reassign `rootConfigPath` and call `_operations.loadProject` together, and revert the field assignment on failure since MobX `@action` reentrant field writes are synchronous and cheap to undo), keep the old node bound to `oldCanonicalPath`, keep the old file's revision/dirty bookkeeping untouched, and discard the rewrite-plan content changes (do not call `registerTextContentChange` for dependents until *after* the rebuild has succeeded, reordering step 11 to follow step 12's success rather than precede it — revise §5.2 accordingly: build the rewrite plan as pure strings first, attempt the rebuild using those strings as one-shot overrides passed directly to `loadProject`/the full-reparse helper without going through `registerTextContentChange` at all, and only call `registerTextContentChange` for each dependent — to make them visibly dirty — after the rebuild has been applied). Return `rebuildFailed`. The now-orphaned destination file on disk is a known, accepted residue (documented in a code comment and in §12 risk 2), exactly parallel to `writtenAfterProjectChange`'s already-accepted residue for ordinary saves.

### 5.6 Untracked-source edge case

If `oldCanonicalPath` is **not** currently a project node (e.g. Save As on a standalone open text tab outside the loaded project, or Save As before the project has ever tracked this file) — return `unknownPath`/`unsupportedNode` from `saveTextProjectFileAs(...)` and let `THTextEditorController.saveAs()` fall back to a plain disk write via `_operations.writeBytes(...)` plus updating its own `canonicalPath`/local buffer (no project-graph rewriting, since there is no project graph entry to rewrite and no dependents to retarget). This mirrors `loadFile()`'s existing untracked fallback (`:195-201`) and keeps "Save As for a standalone text tab" working even with no project loaded, without inventing a second controller-level API — `saveAs()` branches once on `isProjectBound`, matching `setContent()`'s and `save()`'s existing top-of-method branch on the same flag.

## 6. `MPGeneralController.renameFileController(...)` extension

Extend the existing method (`:403-423`) rather than adding a new one:

```dart
void renameFileController({
  required String oldFilename,
  required String newFilename,
}) {
  final String normalizedOldFilename = _normalizeFilename(oldFilename);
  final String normalizedNewFilename = _normalizeFilename(newFilename);

  if (_t2hFileEditControllers.containsKey(normalizedOldFilename)) {
    final TH2FileEditController controller =
        _t2hFileEditControllers.remove(normalizedOldFilename)!;
    _t2hFileEditControllers[normalizedNewFilename] = controller;
  }

  if (_textEditorControllers.containsKey(normalizedOldFilename)) {
    final THTextEditorController controller =
        _textEditorControllers.remove(normalizedOldFilename)!;
    _textEditorControllers[normalizedNewFilename] = controller;
  }

  final int index = _openFileOrder.indexOf(normalizedOldFilename);
  if (index >= 0) {
    _openFileOrder[index] = normalizedNewFilename;
  }
}
```

This is a minimal, additive change: it adds one more `containsKey`/`remove`/reinsert block, symmetric with the existing TH2 block, and does not alter the method's existing `_openFileOrder` rewrite (which already preserves position, hence active index, since `_activeTabIndex` is an index into `_openFileOrder`, not a filename — no separate "preserve active index" step is needed beyond what already exists). Selection/expansion state on the project-tree side (`THProjectTreeUIController`) is keyed by node id, not canonical path, and is naturally invalidated/reselected by the rebuild's normal node-selection flow (`selectNode`/`expandAncestorsOf`, already used by `_syncProjectTreeSelectionToActiveTab`, `mp_general_controller.dart:167-177`) — Phase 10 does not need to special-case tree selection beyond calling that existing sync after Save As completes, the same way `removeFileTab`/`setActiveTab` already do.

**Not migrated by this method** (owned by the controller itself, not by the registry): cursor/selection/fold/scroll/find state on `THTextEditorController` are preserved automatically because `renameFileController` moves the *same controller instance* to a new map key — it never disposes or recreates the controller. `THTextEditorController.saveAs()` itself is what mutates `canonicalPath`/`_ownedProjectEpoch`/`_ownedRootPath`/`observedRevision`/`isDirty` on that surviving instance (§8), so no separate "restore cursor position" step exists — there is nothing to restore.

## 7. Directive Rewriting

### 7.1 What gets rewritten

- **This file's own outgoing directives** (only relevant when the destination directory differs from the source directory): every `THConfigSource`/`THConfigInput` element in a moved `thconfig`, or every `THDataInput`/`THImport` element in a moved `.th`, whose `filePath`/`rawPath` is a *relative* path (an absolute directive path is unaffected by the move and needs no rewrite). Recompute the relative path from the **new** containing-file directory to the same resolved absolute target the old relative path pointed to (using `THProjectPathResolver.resolve(...)` against the *old* absolute path to get the target, then a reference-path helper against the *new* directory — see §7.3).
- **Every dependent file's incoming directive(s)**: for each canonical path in `dependentsOf(oldCanonicalPath)`, walk that file's own parsed elements (`THConfigSource`/`THConfigInput` for a `THConfigFileNode`, `THDataInput`/`THImport` for a `THDataFileNode`) and find every element whose *resolved* absolute path (via `THProjectPathResolver.resolve(rawPath: element.filePath/rawPath, includingFileAbsolutePath: dependentAbsolutePath, defaultExtension: ...)`) equals the old canonical path. A file can reference the same target more than once (two separate `input` lines, or a `source` and a nested `input` reaching the same file through different relative spellings) — rewrite **every** matching element, not just the first.

### 7.2 Rewrite mechanics (per §2.5)

Add a small helper, e.g. `_rewriteDirectivePath(THConfigFile|THDataFile file, int elementIndex, String newRawPath)`, that:

1. reads the element at `elementIndex`;
2. constructs a new instance of the same runtime type with `filePath`/`rawPath: newRawPath`, the same `lineNumber`, `originalLine: ''`, `isModified: true` (for `THConfigSource`, also preserve `isMultiLine`/`inlineCommands`; a multi-line `source ... endsource` block's path is on its own header line — confirm at implementation time exactly how a multi-line source's path token is represented, since `THConfigSource.filePath` may be empty/unused for `isMultiLine: true` and the actual per-line paths live in `inlineCommands` instead, per `th_config_file_writer.dart:86-94`'s dedicated multi-line branch; if so, rewriting a multi-line `source` block's paths requires rewriting matching entries inside `inlineCommands`, not the top-level `filePath` field);
3. replaces `file.elements[elementIndex] = rewritten;`.

This keeps every other element's `originalLine` untouched, so `THConfigFileWriter`/`THFileWriter` round-trips everything except the rewritten line(s) byte-for-byte, per objective 4/§2.5 and the roadmap's explicit "preserving quoting, comments, continuation layout, and unrelated formatting" requirement (bullet 4). Note the per-line quoting/escaping the original grammar may have applied to a path token (e.g. quoted paths with spaces) is **not** re-derived by this helper — confirm at implementation time whether `THConfigGrammar`/`THGrammar` already strip quotes into a bare `filePath`/`rawPath` (in which case the writer's plain `'input ${element.filePath}'` construction, `th_config_file_writer.dart:99`, would already lose quoting even for ordinary edits today, a pre-existing property Phase 10 inherits rather than introduces) or preserve them (in which case the rewrite helper must re-apply quoting when the new path contains a space or other Therion-meaningful character).

### 7.3 Relative path computation

Use `MPDirectoryAux`'s existing file-to-file reference-path helpers (`relativePathFromReferencePath`, `rebaseRelativePath` — both already used by `TH2FileEditController._rebaseImportedImagePathsForSaveAs`, §2.4) rather than `path.relative(...)` directly, so Phase 10's path style (separator, `./` prefix behavior, trailing-slash handling) matches the one existing precedent in the codebase for "a file moved, keep another file's reference to it correct." Confirm at implementation time that these helpers' semantics (they operate against a *file* reference path, not a bare directory, per their use for `image.filename` relative to a `.th2` file's own path) compose correctly with `THProjectPathResolver.resolve`'s directory-of-containing-file semantics — if there is an impedance mismatch (e.g. one expects a trailing filename component and the other a bare directory), add a thin adapter in the new directive-rewrite helper rather than changing either existing helper's contract, since both are used by unrelated existing call sites (TH2 image rebasing; every directive resolution during normal project loading).

## 8. `THTextEditorController.saveAs()`

```dart
Future<THTextFileSaveAsResult> saveAs() async {
  final THProjectReparseFlushResult flush = await flushPendingReparse();
  if (!flush.canProceedToSave) { /* map to a save-as-shaped early-return result; no picker */ }

  // Compute initial directory/filename; call FilePicker.saveFile(...).
  // On null (cancelled): return a client-side `cancelled` outcome, no further calls.
  // On chosen path: apply extension rule (§4.3); canonicalize.

  if (!isProjectBound) {
    // §5.6 fallback: plain disk write + local identity update, no project call.
  }

  final THTextFileSaveAsResult result = await _projectController.saveTextProjectFileAs(
    oldCanonicalPath: canonicalPath,
    newCanonicalPath: destination,
    requestedRevision: observedRevision,
    expectedProjectEpoch: _ownedProjectEpoch!,
    expectedRootPath: _ownedRootPath!,
  );

  if (result.isComplete) {
    mpLocator.mpGeneralController.renameFileController(
      oldFilename: canonicalPath,
      newFilename: destination,
    );
    canonicalPath = destination;
    // _ownedProjectEpoch/_ownedRootPath are unchanged for a non-root Save As
    // (same project, same epoch); for a root Save As, _ownedRootPath must be
    // refreshed to the new rootConfigPath even though _ownedProjectEpoch is
    // unchanged, since root identity is (epoch, rootPath) and rootPath moved.
    observedRevision = result.writtenRevision!;
    isDirty = false;
    lastAccessedDirectory update (mirrors saveAsTH2File's own bookkeeping);
  }
  // Non-complete statuses: controller identity, dirty state, and tab
  // order/selection are all left exactly as they were (objective 8).

  return result;
}
```

Renaming the controller's registry entry (via `renameFileController`) must happen only *after* `saveTextProjectFileAs(...)` reports success — never before, and never speculatively — because a failed Save As (collision, write failure, rebuild failure) must leave `mpLocator.mpGeneralController.getTextEditorController(canonicalPath)` still resolving to this same controller under its old path, with its old dirty content intact (objective 8, and the roadmap's "retain the old editor/project identity and dirty content" bullet).

The exact early-return shape for a failed pre-picker flush, and for `!isProjectBound`, needs a small amount of result-type reuse (either a shared status enum with `saveTextProjectFile`'s statuses, or `THTextFileSaveAsResult` accepting the untracked-fallback outcomes directly) — resolve this by implementation time rather than prescribing the exact enum union here; the important invariant is that `saveAs()` never fabricates a `saved` result without either a successful project-controller round trip or (untracked case) a successful direct `writeBytes`.

## 9. UI Routing, Confirmation, and Errors

### 9.1 Routing

Update the three call sites in §4.1 to branch on `isTH2Tab(activeFilename)`, matching `_saveActiveTab(...)`'s existing branch (`th2_file_tabs_page.dart:1098`) exactly. No new widget is required beyond the branching itself — the existing `save_as_outlined` icon/menu entry/shortcut stays, only its target controller type changes per active tab.

### 9.2 Errors surfaced to the user

Per §2.6, keep new user-facing copy minimal and localized:

- Picker dialog title(s) distinguishing `thconfig` vs `.th` Save As (or a single shared title if the distinction adds no user value — decide at implementation time by checking whether `saveAsTH2File`'s single `th2FileEditPageSaveAsDialogTitle` precedent argues for one shared "Save file as" string with no per-type variant).
- A localized destination-collision error (§4.4 points 2–3).
- A localized write/rebuild failure notice — reuse the existing `thProject*Failed`-family convention (§2.6) rather than a bespoke dialog, consistent with Phase 8.5/9's "logged/localized save diagnostics remain the failure surface" principle; do not add a modal per `THTextFileSaveAsStatus` value.

No confirmation dialog is required for Save As itself (unlike Phase 9's Replace All, which needs one because it silently saves multiple files) — Save As is a single explicit user action per file, and the picker itself is already the confirmation surface, matching TH2's own no-extra-confirmation precedent (§4.4 point 4).

## 10. Implementation Sequence

1. Re-confirm the next unused test prefix (scan for duplicates, not just the max); provisional `t3933`.
2. Add `THTextFileSaveAsStatus`/`THTextFileSaveAsResult` (or fold into an existing result-types file, matching the repo's existing one-small-file-per-result-type style, e.g. `th_text_file_save_as_result.dart` beside `th_text_file_save_result.dart`).
3. Add the directive-rewrite helper (§7.2) and the inverse relative-path computation (§7.3), with focused pure-function tests before wiring them into the controller (round-trip: rewrite a directive, reserialize, confirm only the target line changed).
4. Add `THProjectController.saveTextProjectFileAs(...)` (§5), reusing `_operations.writeBytes`/serializer methods and the existing non-root full-reparse-with-overrides path; do not duplicate Phase 8.5's flush/revision machinery.
5. Extend `MPGeneralController.renameFileController(...)` (§6).
6. Add `THTextEditorController.saveAs()` (§8), including the untracked-source fallback (§5.6).
7. Wire the three UI entry points (§9.1) and update the misleading comment at `th2_file_tabs_page.dart:1082-1084`.
8. Add EN/PT localization strings and update `assets/help/en|pt/keyboard_shortcuts_edit.md` (and any TH2-file-edit help page cross-reference, if the help text explicitly says "Save As is TH2-only" anywhere — grep for it at implementation time).
9. Add the focused tests in §11.
10. Run `flutter analyze` and the full `flutter test` suite; resolve every warning/error.
11. Review the diff for: direct `File(...)`/writer calls bypassing `_operations`, any node mutated in place instead of rebuilt, any epoch bump introduced by the Save As path, and any UI call site still hard-routed to `saveAsTH2File()` regardless of tab type.

Formatting and `.g.dart` regeneration remain automatic; do not run `dart format` or `build_runner` manually.

## 11. Test Plan

Confirm numbering immediately before implementation; renumber if `t3933` is taken.

| Test file | Required coverage |
| --- | --- |
| `test/t3933_th_directive_rewrite_aux_test.dart` | Pure rewrite-plan helper: relative outgoing-directive rewrite when a file's own directory changes; incoming-directive rewrite for one and multiple dependents; a single dependent referencing the target through more than one directive (two `input` lines, or `source` + nested `input`); absolute directive paths left untouched; comments/blank lines/unrelated directives byte-for-byte unchanged after rewrite+reserialize; multi-line `source ... endsource` path rewriting (or confirmation that Phase 10 explicitly does not support rewriting a multi-line source's inline paths, if §7.2's investigation finds that infeasible within scope — record the decision here). |
| `test/t3934_th_project_controller_save_as_test.dart` | `saveTextProjectFileAs(...)` full validation order: `projectChangedBeforeWrite`, `unknownPath`/`unsupportedNode`, `reparseFailed` (unflushed revision), `supersededBeforeWrite`, `destinationCollision` against a project node and against a standalone open tab, `serializationFailed`, `writeFailed` (old file untouched, no project mutation), `rebuildFailed` with full rollback (root and non-root), `writtenAfterProjectChange`, and `saved` for both root and non-root targets. Root case: `rootConfigPath` updated only on success; every other pending dirty buffer preserved through the rebuild. Non-root case: old path's revision/pending bookkeeping fully retired on success; dependent files become dirty with exactly the rewritten content and nothing else; a dependent referencing the target twice gets both directives rewritten. Old source file's bytes remain byte-identical on disk after a successful Save As. Injected `_operations` fakes (per Phase 8.5's gate/Completer pattern) prove no I/O occurs before a `destinationCollision`/`projectChangedBeforeWrite` short-circuit. |
| `test/t3935_th_text_editor_controller_save_as_test.dart` | `saveAs()` cancellation (no disk write, no controller/tab mutation — assert via a fake picker returning `null`); pre-flush failure short-circuits before any picker call; extension-rule application for `thconfig` (verbatim) vs `.th` (append when missing, accept other extensions); same-path Save As delegates to `save()`; untracked/standalone-source fallback writes directly and updates local identity without a project-controller call; successful Save As updates `canonicalPath`/`observedRevision`/`isDirty` and leaves them untouched on any failure status; root Save As refreshes `_ownedRootPath` while leaving `_ownedProjectEpoch` unchanged. |
| `test/t3936_mp_general_controller_rename_text_controller_test.dart` | `renameFileController(...)` migrates a registered `THTextEditorController`'s map entry, preserves the same controller instance (identity check) and its cursor/fold/find state, rewrites the matching `_openFileOrder` entry in place, preserves `activeTabIndex` when the active tab is the one being renamed, and leaves an unrelated TH2 controller/tab entry untouched; confirm the pre-existing TH2 rename behavior is unaffected (regression). |
| `test/t3937_th2_file_tabs_page_save_as_routing_test.dart` | App-bar button, compact overflow entry, and `Ctrl/Cmd+Shift+S` each route to the text-editor Save As path for a `thconfig`/`.th` active tab and continue to route to `saveAsTH2File()` for a `.th2` active tab; localized dialog title/collision/failure text renders for the text path; no regression to existing TH2 Save As widget behavior. |

### End-to-end scenarios

1. Save As a non-root included `.th` file to a new subdirectory; confirm its own relative `input`/`import` lines are rewritten to still resolve, its parent's `input`/`source` line is rewritten to the new relative location and becomes dirty (but unsaved until the user saves it), the old file remains on disk unchanged, and the moved file's tab shows the new path with no unsaved indicator.
2. Save As the root `thconfig` to a different directory; confirm `rootConfigPath` moves, every previously dirty included file's pending edit survives the rebuild, and the project tree reflects the new root location.
3. Attempt Save As to a path already open as an unrelated standalone tab; confirm rejection with no disk write and no mutation to either tab.
4. Force a rebuild failure (injected `_operations.loadProject` failure) after a successful destination write; confirm the destination file exists on disk (documented residue) but the live project/editor identity is fully unchanged from before the Save As attempt.
5. Cancel the picker; confirm zero observable side effects anywhere (disk, controller, tab order, dirty state, project tree selection).

## 12. Risks and Decisions to Verify During Implementation

1. **Directive-path quoting fidelity.** Confirm whether `THConfigGrammar`/`THGrammar` preserve or strip quoting around a path token containing spaces, and whether the writer's plain string-interpolation reconstruction (`th_config_file_writer.dart:95,99`; `th_file_writer.dart:142,164`) already has this limitation for ordinary (non-Save-As) edits today. If so, Phase 10 inherits an existing gap rather than introducing one — document this explicitly rather than silently shipping a regression-looking behavior.
2. **Orphaned destination residue.** A `rebuildFailed` or `writtenAfterProjectChange` outcome leaves bytes on disk at the new path with no corresponding project node. This mirrors `saveTextProjectFile`'s already-accepted `writtenAfterProjectChange` residue; confirm the team is comfortable with the same tradeoff for Save As specifically, since a Save As residue is a *new* file (not an overwrite of existing tracked content) and therefore slightly more surprising to a user who might not expect a file to appear.
3. **Multi-line `source ... endsource` rewriting.** `THConfigSource.isMultiLine`'s per-line paths live in `inlineCommands` (raw strings), not in the typed `filePath` field (per `th_config_file_writer.dart:86-94`). If a moved root `thconfig` (or one of its dependents) uses this form and needs an outgoing/incoming rewrite, the rewrite helper needs a dedicated multi-line-aware branch, or Phase 10 explicitly declines to rewrite multi-line `source` blocks and documents that as a known limitation (likely acceptable, since multi-line `source` is a rarer form) — decide before implementation, not during.
4. **Relative-path helper composition.** `MPDirectoryAux.relativePathFromReferencePath`/`rebaseRelativePath` were written for `.th2` image references relative to a `.th2` file's own path; confirm their exact contract composes with `THProjectPathResolver.resolve`'s containing-file-directory semantics for `thconfig`/`.th` directives without surprising edge cases (trailing slash, same-directory `./` prefix, Windows separator normalization).
5. **`rootConfigPath` reassignment ordering under failure.** §5.5 requires reverting a synchronous `rootConfigPath` write if the subsequent rebuild fails, inside one `@action`. Confirm MobX's `@action` batching semantics make this safe (i.e. no observer sees the transient reassigned value before the method returns) — likely fine given MobX's synchronous action-batching model, but verify against how `_clearProjectState()`/`_applyFreshLoadResult()` already handle multi-field atomic-looking updates within one action.
6. **TH2 Save As's own existing same-name-rename quirk.** `saveAsTH2File()`'s extension-normalization branch (`th2_file_edit_controller.dart:1554-1563`) renames an *existing* file at the extension-less chosen path to add `.th2`, which looks like a pre-existing, unrelated oddity (renaming a file the user did not ask to rename, if one happens to already exist at that exact extension-less path). Do not copy this pattern into the text-editor Save As extension rule (§4.3) — simply append the extension to the *chosen path string* before ever touching disk, never rename an unrelated existing file.
7. **Test-prefix confirmation.** Re-scan `test/` immediately before implementation; `t3933` is provisional and the repo has a known history of prefix collisions.
