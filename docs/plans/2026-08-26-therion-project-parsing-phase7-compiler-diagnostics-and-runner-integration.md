<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 7: Compiler Diagnostics & Runner Integration — Implementation Plan

**Date:** 2026-08-26
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 7** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It builds on:

- **Phases 1-3** — grammars/parsers/writers, `THProjectParser`, `THProjectController` (`projectErrors`, `dirtyFilePaths`, `rootConfigPath`).
- **Phase 4** — the project-tree sidebar and its per-node error dot / project-level error summary banner.
- **Phase 5** — `THTextEditorController`/`THTextEditorWidget`, including the `diagnostics` computed getter and `THTextEditorDiagnosticMarkerWidget` (whole-line background marker, no column support).
- **Phase 6** — multi-tab integration, `THProjectTreeNodeWidget`'s click-to-open-and-scroll behavior (`_openTextEditorTab`), and `THProjectController.nodeByCanonicalPath`.

Unlike Phases 1-6, Phase 7 does **not** start from nothing: Mapiah already has a complete, pre-project-feature "Run Therion" subsystem — `MPTherionRunner` (`lib/src/auxiliary/mp_therion_runner.dart`), platform-specific runners, and `MPRunTherionDialogWidget` — with buttons, an overflow-menu entry, and keyboard shortcuts (`T` / `Ctrl+T`) already wired into both `mapiah_home.dart` and `th2_file_tabs_page.dart`. Phase 7 closes the two gaps the roadmap's phase table names, while also **removing** the piece of state (`MPGeneralController.thConfigFilePath`) whose sole purpose was standing in for the project-tree's own `rootConfigPath`:

1. **"Connect `Run Therion` to project root `thconfig`"** — resolved by retiring `MPGeneralController.thConfigFilePath` outright (confirmed by grep to have no purpose besides being the Run Therion target and its button-enablement flag) and having "Rerun Therion" read `THProjectController.rootConfigPath` directly. The existing "Choose THConfig file and run Therion" button is retargeted into "Open project and run Therion": it reuses the project file-picker, starts the Therion run immediately (matching today's timing), and loads the picked file as the project *in the background*, without the run waiting on it.
2. **"Parse Therion compiler error messages and map them back to tree nodes and editor lines"** — `MPTherionRunner` already classifies output lines as warning/error (`MPTherionIssue`), but only to color the dialog's status banner and let it scroll its own output pane; `MPTherionIssue.lineIndex` is an index into the *captured output*, not a source file/line. There is no bridge today from a compiler-reported `file, line` to `THProjectParseError` (the model the tree's error dots, the tree's error summary banner, and the text editor's diagnostic markers already all render).

### Key Objectives

1. **Retire `MPGeneralController.thConfigFilePath`; `THProjectController.rootConfigPath` becomes the single source of truth for "which `thconfig` does Run Therion target."** `MPDialogAux.runTherion` takes an explicit `thConfigFilePath` parameter instead of reading it off `MPGeneralController`; every call site supplies either a freshly-picked path (the merged "open project and run Therion" flow) or `THProjectController.rootConfigPath` (the plain "Rerun Therion" flow).
2. **Merge "Choose THConfig file and run Therion" into "Open project and run Therion"**: the button/menu-entry/shortcut (`Ctrl+T`) that used to pick a standalone `thconfig` (via a plain file picker, entirely disconnected from the project tree) now picks a **project** file (the same picker `MPDialogAux.pickProjectFile` already uses) and, once picked: (a) starts the Therion run immediately — same timing as today, so the dialog appears and compilation begins with no perceptible delay — and (b) *without waiting for the run to finish*, kicks off `THProjectController.openProject` in the background so the project tree populates concurrently with the compile.
3. **"Rerun Therion" (`T`) now runs `THProjectController.rootConfigPath`** and is enabled exactly when a project is loaded (`rootConfigPath.isNotEmpty`), replacing the old `MPGeneralController.thConfigFilePath.isNotEmpty` enablement check in both `mapiah_home.dart` and `th2_file_tabs_page.dart`.
4. **Parse `therion` output + `therion.log` into `THProjectParseError`s**: a new pure parser (`th_project_therion_diagnostics_aux.dart`) extracts `(severity, filePath, lineNumber, message)` from Therion's `therion: error -- <file> [line <n>] -- <message>` / `... warning ...` diagnostic lines (per the top-level roadmap §8's own documented example format), resolving relative paths against the run's working directory and canonicalizing them the same way `THProjectController`/`THTextEditorController` already do.
5. **Feed diagnostics into the existing rendering paths without disturbing their lifecycle**: a new `THProjectController.compilerErrors` observable (populated by a new `applyTherionRunDiagnostics` action, called from `MPRunTherionDialogWidget` once a run finishes) that is merged with the existing parse-time `projectErrors` via a new `allDiagnostics` computed getter, consumed everywhere `projectErrors` currently is (tree error dots/summary, `THTextEditorController.diagnostics`) — kept as a *separate* observable specifically because `projectErrors` is already rebuilt wholesale on every `openProject`/`reloadProject`/`reparseFile`, which would silently wipe compiler diagnostics on the next keystroke if they were merged into that list directly.
6. **Tree navigation for compiler diagnostics**: file-node error dots gain a tap handler (distinct from the row's existing open-at-top tap) that opens/focuses that file's text-editor tab and scrolls to the first diagnostic's line, reusing `THProjectTreeNodeWidget`'s existing (Phase 6) `_openTextEditorTab(filePath, {lineNumber})` helper — no new navigation plumbing.
7. **Diagnostics only applied to the loaded project**: the bridge only calls `applyTherionRunDiagnostics` when the just-finished run's `thConfigFilePath` canonicalizes to the currently loaded `THProjectController.rootConfigPath`; a run against a `thconfig` that never became (or isn't yet) the loaded project leaves the tree/editor diagnostics untouched, since there is no tree to attribute them to.

### Explicit Non-Goals

- **No new dialog, no new keyboard shortcut, no new icon.** `T`/`Ctrl+T` and both pages' existing buttons keep their positions and glyphs; only what they *target* and (for `Ctrl+T`/"Choose THConfig...") their *picker and post-pick behavior* change. This is a repurposing of two existing entry points, not new UI surface.
- **No rewrite of `MPTherionIssue`/`_warningRegex`/`_errorRegex`.** Those exist to drive the dialog's own live status banner and output-pane auto-scroll while a run is in progress; they are orthogonal to the new post-run, file/line-addressable parser and are left exactly as they are.
- **No column-level diagnostics.** `THProjectParseError` has no column field and `THTextEditorDiagnosticMarkerWidget` already documents that it renders a whole-line background marker for exactly this reason (confirmed in its own doc comment, Phase 5). Therion's own diagnostics are file/line-addressed, not column-addressed, so this is not a new limitation Phase 7 introduces.
- **No compiler-diagnostic attribution below the file-node level.** `THProjectNode`/`THProjectFileNode` carry a single `lineNumber` (their own definition line), not a line *range*, so reliably deciding "this compiler error at line 42 belongs to the `survey` node starting at line 10 vs. the `centreline` node starting at line 30" would need new range-tracking on every logical node. Compiler-diagnostic tree dots are shown on the containing **file** node only; the text editor's line-accurate gutter marker (unaffected by node granularity) is the precise navigation surface once that file's tab is open.
- **No "Open Output PDF" / export-artifact detection.** The top-level roadmap's §8 overview mentions this, but neither of Phase 7's two roadmap phase-table bullets calls for it; it is left for a future phase, the same way Phase 5 split off multi-file find/replace and Phase 6 split off `.th2`-linked scrap-tree children.
- **No auto-opening of files/tabs when a run finishes with errors.** Diagnostics are surfaced via the existing dot/summary/gutter-marker affordances; navigating to them stays a user-initiated click (Objective 6), matching the app's existing no-surprise-focus-steal precedent (Phase 6's own rationale for `requestFocus()` only on explicit tab activation, never automatically).
- **No change to what happens when "open project and run Therion" is used with a file that isn't shaped like a `thconfig`.** `pickProjectFile` already forces `forceConfigShape: true` and surfaces shape mismatches as project parse errors; the merged flow reuses that exact call, unchanged.
- **No help-page/keyboard-shortcut-table content changes beyond wording**, and even that is deferred to Phase 8 alongside every other phase's help-page touch-ups — the *keys* (`T`, `Ctrl+T`) stay the same, only the row's description text in `keyboard_shortcuts_main.md` (en/pt) would need "Choose THConfig file and run Therion" reworded to "Open project and run Therion", a one-line wording edit left for Phase 8's documentation pass along with everything else.

---

## 2. Grounding: Current State

Verified against the codebase:

- **The Run Therion subsystem predates and is independent of the project-parsing feature.** `MPTherionRunner` (`lib/src/auxiliary/mp_therion_runner.dart`) spawns `therion` via platform-specific runners (`MPLinuxTherionRunner`/`MPMacOSTherionRunner`/`MPWindowsTherionRunner`/`MPFlatpakTherionRunner`), exposing `isRunningNotifier`, `statusNotifier` (`MPTherionRunStatus`: running/ok/warning/error), `outputLinesNotifier`, `issuesNotifier` (`List<MPTherionIssue>`), and `outputStream`. `MPTherionIssue` is `{kind, lineIndex, lineText}` where `lineIndex` indexes into the captured output buffer — there is no file/source-line extraction anywhere in this class today, confirmed by reading its `_registerOutputLine`/`_warningRegex`/`_errorRegex` in full. `MPRunTherionDialogWidget` already takes `thConfigFilePath` as a plain constructor parameter (`mp_therion_run_dialog_widget.dart:27-36`) — it does **not** read `MPGeneralController` itself, so removing that controller field touches only its *callers*, not the dialog.
- **`MPGeneralController.thConfigFilePath` has exactly one reason to exist today, and it is the one this phase removes.** A repo-wide grep for `thConfigFilePath` (excluding generated `.g.dart`/localization files) shows it used only as: (a) the value threaded into `MPRunTherionDialogWidget(thConfigFilePath: ...)` from `MPDialogAux.runTherion`, and (b) an `.isNotEmpty` gate that enables the "Run Therion" button/menu-entry in `mapiah_home.dart` (lines 205, 278) and `th2_file_tabs_page.dart` (lines 243, 433). It is never displayed, never persisted, and never read by anything else — it is purely a stand-in for "which `thconfig` should Rerun Therion use," which `THProjectController.rootConfigPath` already is for the project-tree feature.
- **Three call sites currently invoke the pick-and-run / rerun pair**, all needing their target renamed/updated: `mapiah_home.dart`'s expanded-app-bar buttons (lines ~184-222) and its compact overflow menu (`_MapiahHomeAction.openTHConfig`/`.runTherion`, lines ~312-320, ~363-366); `th2_file_tabs_page.dart`'s equivalent buttons (lines ~216-260), compact menu, and `_withShortcuts` block (~872-879); and the canvas-editing state machine's own key-down handling (`mp_th2_file_edit_state_key_down_mixin.dart:193,197` → `mp_th2_file_edit_state.dart:285-286,358-359`, via `MPButtonType.chooseTHConfigAndRunTherion`/`.runTherion`) for when a `.th2` canvas (not the tab bar) has keyboard focus. All three currently call `MPDialogAux.chooseTHConfigAndRunTherion`/`runTherionWithLastTHConfig`.
- **`MPDialogAux`'s current pick-and-run chain** (`lib/src/auxiliary/mp_dialog_aux.dart:1214-1486`): `pickTHConfigFile` (a generic file picker, `MPFilePickerType.thconfig`, sets `MPGeneralController.thConfigFilePath`) → `pickTHConfigFileAndRunTherion` (calls `pickTHConfigFile` then `runTherion`) → `chooseTHConfigAndRunTherion` (Therion-availability gate, then `pickTHConfigFileAndRunTherion`) → `runTherion` (reads `MPGeneralController.thConfigFilePath`, shows `MPRunTherionDialogWidget`, and — on the dialog popping `true`, meaning the user pressed `Ctrl+T` *inside* the dialog — recurses into `chooseTHConfigAndRunTherion` again). `runTherionWithLastTHConfig` is the separate "rerun" path (Therion-availability gate, then `runTherion` with no picker). `runTherionWithTHConfigFile(context, path)` (used by CLI startup: `--thconfig`/positional-argument launch in `mapiah_home.dart:101,129`) sets `MPGeneralController.thConfigFilePath` directly (bypassing the picker) then calls `runTherion`.
- **`pickProjectFile`** (`mp_dialog_aux.dart:1266-1317`, `MPFilePickerType.project`) is the picker the merged flow reuses: same `FilePicker.pickFile` shape/dialog title/`lastAccessedDirectory` bookkeeping as `pickTHConfigFile`, but it `await`s `THProjectController.openProject(pickedFilePath, forceConfigShape: true)` before optionally calling `ensureProjectTabsPageOpen(context)`. Today it already has several call sites — the app-bar "Open Project" button (`mapiah_home.dart:176`, `Icons.folder_open_outlined`), its overflow-menu equivalent (`mapiah_home.dart:362`), the `Ctrl+O`/`Cmd+O`/Shift variants in `mapiah_home.dart`'s `_withShortcuts` (~lines 510-525), and the project tree's own empty-state "Open Project" button (`th_project_tree_widget.dart:162`) — none of them touched by Phase 7; `pickProjectFile` stays exactly as the "load a project without also running Therion" entry point everywhere it's already wired in.
- **The run dialog has its own internal `Ctrl+T` rebind.** `MPRunTherionDialogWidget` (`mp_therion_run_dialog_widget.dart:376-402`) binds `T` → rerun (`_RerunTherionIntent`, calls `_rerunTherion()` only if not already running) and `Ctrl+T` → `_ChooseTHConfigAndRunTherionIntent`, whose handler stops the current run and pops the dialog with `Navigator.of(context).pop(true)` — which is what makes `MPDialogAux.runTherion`'s `if ((shouldChooseTHConfig == true) && context.mounted) { await chooseTHConfigAndRunTherion(context); }` re-enter the pick-and-run chain. This in-dialog `Ctrl+T` must call whatever the merged flow's entry point is renamed to (§5), so pressing `Ctrl+T` mid-run still means "pick a different project (file) and run Therion" end-to-end, consistent with the top-level buttons.
- **`THProjectController` already exposes exactly the shape Phase 7 needs to extend.** `projectErrors` is an `@observable ObservableList<THProjectParseError>`, fully **reassigned** (not mutated) inside `_applyLoadResult`/`_reindexAfterTreeChange` every time the project loads or a file reparses — i.e. anything Phase 7 adds to it directly would be silently dropped on the next edit. `THProjectParseError` (`th_project_parse_error.dart`) is `{message, severity (warning/error), filePath, lineNumber}` — already exactly the shape a parsed compiler diagnostic needs, no new model class required. `openProject` already canonicalizes its input path first thing (`THProjectPathResolver.canonicalize(p.absolute(configFilePath))`) before assigning `rootConfigPath` — the merged flow's freshly-picked path and the eventual `rootConfigPath` are therefore always compared/stored in the same canonical form.
- **`THProjectNode.parseErrors`/`hasErrors`** (`th_project_node.dart`) are a plain (non-observable) `List<THProjectParseError>` populated once during tree construction/splicing by `THProjectParser`; `collectTreeErrors()` (`th_project_reparse_aux.dart`) walks them to build the flat `projectErrors` list. Mutating `parseErrors` in place after the fact would not, by itself, trigger any MobX reaction — the existing reactivity comes entirely from `projectErrors`/`compilerErrors` being *reassigned* observables that `Observer` widgets read during `build()`.
- **Tree rendering already reads `projectErrors` inside a single `Observer`.** `THProjectTreeWidget.build()` (`th_project_tree_widget.dart:23-54`) wraps everything in one `Observer`, reading `projectRootNode`, `projectErrors`, and `dirtyFilePaths` before building the row list and the `_THProjectTreeErrorSummary` banner (lines 230-315, an `errorContainer`-colored banner keyed off `projectErrors`, currently the whole list not node-scoped). Every `THProjectTreeNodeWidget` row is built synchronously inside that same `Observer.build()` call, so any additional observable a row reads during its own `build()` (e.g. a new `compilerErrors` list) is automatically tracked by the same outer `Observer` — no extra `Observer` wrapping needed per row.
- **`THProjectTreeNodeWidget`'s error dot is node-scoped, not diagnostics-list-scoped.** `_buildErrorDot` (`th_project_tree_node_widget.dart:145-158`) reads `node.hasErrors`/`node.parseErrors.length` directly off the node instance, always in `colorScheme.error` (no warning/error color distinction). The row's `onTap`/`_onTap` (lines 73-97) already calls the Phase 6 `_openTextEditorTab(filePath, {lineNumber})` helper for file and logical nodes — exactly the helper Objective 6 reuses.
- **`THTextEditorController.diagnostics`** (`th_text_editor_controller.dart:76-79`) is a `@computed` filter of `_projectController.projectErrors` by `canonicalPath` — no stored field, so it will pick up compiler diagnostics automatically once they flow through whatever `_projectController` field/getter it reads, with a one-line change to read `allDiagnostics` instead of `projectErrors`. Rendered by `THTextEditorDiagnosticMarkerWidget` (`th_text_editor_diagnostic_marker_widget.dart`), which already color-splits by `diagnostic.severity` (error → `colorScheme.error`, warning → `colorScheme.tertiary`) — Phase 7's parsed compiler diagnostics need no new rendering code, only to reach this getter.
- **`therion.log`** (`mpTherionLogFileName = 'therion.log'`, `mp_constants.dart:336`) is written by Therion itself next to the `thconfig` (`p.join(p.dirname(thConfigFilePath), mpTherionLogFileName)`) and already read post-run by `MPRunTherionDialogWidget._readTherionLogLines` (lines 173-273+, with UTF-8/cp1252/latin1 fallback decoding) — but only to append as raw text into the dialog's output pane, inside an `if (!mpIsFlathub) { ... }` guard (line ~97) that skips the whole post-run output-flattening block on Flathub builds. This is an existing, already-decoded source of full diagnostic text Phase 7's parser can consume alongside the live `outputLinesNotifier` capture (both are parsed and de-duplicated, since Therion may emit a given diagnostic to both stdout and the log).
- **No test today parses a compiler diagnostic's file/line.** `test/t3600_mp_therion_runner_test.dart` only exercises `MPTherionIssue` classification (`'therion: error -- source file not found'` — no embedded file/line). `test/t3904_th_text_editor_diagnostics_test.dart` is the template to follow for wiring a `THProjectParseError` through to a rendered `THTextEditorWidget` diagnostic marker in a widget test (uses `THTestAux.ensureTestEnvironment()`, `th_project_controller_test_aux.dart` helpers, `THProjectPathResolver.canonicalize`).
- **Exact Therion diagnostic line format needs verification against real `therion`/`therion.log` output during implementation.** The top-level roadmap (§8) documents the target shape as `therion: error -- filename.th [line 42] -- syntax error`; the parser (§6 below) is written as an isolated, easily-adjusted pure function specifically so the regex can be corrected against real fixtures without touching any controller/widget code, the same "pure aux function, easy to unit test in isolation" pattern already used for `th_project_reparse_aux.dart`/`th_text_editor_fold_aux.dart`.
- Test numbering: the last existing test file is `test/t3910_th2_file_tabs_page_mixed_tabs_test.dart`. Phase 7 tests start at `t3911`.

---

## 3. File Organization & Architecture

```
lib/src/
 ├── auxiliary/
 │    └── mp_dialog_aux.dart                        # Existing: pick-and-run chain reworked to target a project file; thConfigFilePath param threaded explicitly
 ├── controllers/
 │    ├── mp_general_controller.dart                # Existing: thConfigFilePath/setTHConfigFilePath removed
 │    ├── th_project_controller.dart                # Existing: gains compilerErrors, allDiagnostics, applyTherionRunDiagnostics, compilerErrorsForPath
 │    ├── th_project_therion_diagnostics_aux.dart    # New: pure parser, Therion output/log text -> List<THProjectParseError>
 │    └── th_text_editor_controller.dart             # Existing: diagnostics getter reads allDiagnostics instead of projectErrors
 ├── pages/
 │    ├── mapiah_home.dart                           # Existing: button/menu wording + enablement retargeted
 │    └── th2_file_tabs_page.dart                    # Existing: same retargeting, mirrored
 ├── state_machine/mp_th2_file_edit_state_machine/
 │    ├── mp_th2_file_edit_state.dart                 # Existing: MPButtonType handlers call the renamed MPDialogAux methods
 │    └── mixins/mp_th2_file_edit_state_key_down_mixin.dart  # Existing: unchanged key bindings, renamed target methods
 └── widgets/
      ├── mp_therion_run_dialog_widget.dart           # Existing: in-dialog Ctrl+T calls the renamed pick-project-and-run flow; calls the new diagnostics bridge once a run finishes
      ├── th_project_tree_node_widget.dart            # Existing: error dot becomes diagnostics-aware (file node) + gains its own tap handler
      └── th_project_tree_widget.dart                 # Existing: error summary banner reads allDiagnostics
```

No new controller classes, no new data model (`THProjectParseError` is reused as-is), no new widget classes — this phase is entirely about removing one redundant field, retargeting existing entry points to the project-tree's own state, adding a new pure parser, and wiring already-built rendering paths to a new observable.

---

## 4. Retargeting Run Therion to the Loaded Project

### 4.1 Remove `MPGeneralController.thConfigFilePath`

Delete the `@readonly String _thConfigFilePath` field and `setTHConfigFilePath` (`mp_general_controller.dart:43,77-79`, plus its reset in `reset()` — the test-only full-state-reset method, not a `close()`; at line 247). The public `thConfigFilePath` getter is not hand-written source: it is generated by MobX's `@readonly` codegen into `mp_general_controller.g.dart`, so removing the field alone removes the getter too, but **requires re-running `dart run build_runner build`** (per this repo's own `CLAUDE.md` workflow) so the generated file stops referencing it — `flutter analyze` will fail on the stale generated getter otherwise. Nothing else in the codebase reads it once §4.2-§4.4 land (confirmed by an independent repo-wide grep — its only readers are the button-enablement checks and `MPDialogAux.runTherion`, both updated below).

### 4.2 `MPDialogAux.runTherion` takes an explicit path

```dart
static Future<void> runTherion(
  BuildContext context, {
  required String thConfigFilePath,
}) async {
  final String trimmedPath = thConfigFilePath.trim();

  if (trimmedPath.isEmpty) {
    return;
  }

  final String configuredExecutablePath = mpLocator.mpSettingsController
      .getStringWithDefault(MPSettingID.Therion_ExecutablePath)
      .trim();

  final bool? shouldPickDifferentProject = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return MPRunTherionDialogWidget(
        therionExecutablePath: configuredExecutablePath,
        thConfigFilePath: trimmedPath,
      );
    },
  );

  if ((shouldPickDifferentProject == true) && context.mounted) {
    await pickProjectFileAndRunTherion(context);
  }
}
```

Behaviorally identical to today's `runTherion`, minus the source of `thConfigFilePath` (now a parameter instead of `mpLocator.mpGeneralController.thConfigFilePath`).

### 4.3 Merged "open project and run Therion" flow

Replaces `pickTHConfigFileAndRunTherion`/`chooseTHConfigAndRunTherion`/`pickTHConfigFile` with a single method that reuses `pickProjectFile`'s own picker shape but does **not** await the project load before starting the run:

```dart
typedef MPProjectFilePicker = Future<PlatformFile?> Function();

typedef MPProjectLauncher =
    Future<void> Function(BuildContext context, String thConfigFilePath);

typedef MPProjectLoader =
    Future<void> Function(String configFilePath, {bool forceConfigShape});

typedef MPRunTherionStarter =
    Future<void> Function(
      BuildContext context, {
      required String thConfigFilePath,
    });

static Future<void> pickProjectFileAndRunTherion(
  BuildContext context, {
  MPProjectFilePicker? pickFile,
  MPProjectLauncher? launch,
}) async {
  if (!mpLocator.mpSettingsController.isTherionAvailable) {
    MPDialogAux.showHelpDialog(
      context,
      'no_therion_found',
      mpLocator.appLocalizations.mpNoTherionFound,
    );

    return;
  }

  if (_isFilePickerOpen[MPFilePickerType.project] == true) {
    return;
  }

  _isFilePickerOpen[MPFilePickerType.project] = true;

  final MPProjectFilePicker pickProjectFile =
      pickFile ??
      () => FilePicker.pickFile(
        dialogTitle:
            mpLocator.appLocalizations.projectTreeSelectProjectDialogTitle,
        type: FileType.any,
        linuxOptions: const LinuxOptions(lockParentWindow: true),
        windowsOptions: const WindowsOptions(lockParentWindow: true),
        initialDirectory:
            mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralController.lastAccessedDirectory,
      );
  final MPProjectLauncher launchProjectAndRun =
      launch ?? runTherionAndOpenProjectInBackground;

  final String? pickedFilePath;

  try {
    final PlatformFile? picked = await pickProjectFile();

    if (picked == null) {
      mpLocator.mpLog.i('No project file selected.');

      return;
    }

    pickedFilePath = picked.path;

    if (pickedFilePath == null) {
      return;
    }

    mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
      pickedFilePath,
    );
  } finally {
    _isFilePickerOpen[MPFilePickerType.project] = false;
  }

  if (!context.mounted) {
    return;
  }

  await launchProjectAndRun(context, pickedFilePath);
}
```

Notes:
- The Therion-availability gate at the *top* of this method (before the picker even opens) matches today's `chooseTHConfigAndRunTherion`, which avoids bothering the user with a file dialog for a run it already knows can't happen — collapsing three methods (`chooseTHConfigAndRunTherion`/`pickTHConfigFileAndRunTherion`/`pickTHConfigFile`) into one removes a layer of indirection that no longer does anything once the picker is shared with `pickProjectFile`.
- The actual "start the run, load the project in the background" pair is factored into `runTherionAndOpenProjectInBackground` (§4.4), shared with the CLI-startup path — see that section for why the availability check also has to live there, not just here.
- `pickProjectFile` (§2, unchanged) keeps awaiting `openProject` before opening the tabs page, because it has no concurrent run to avoid blocking; `runTherionAndOpenProjectInBackground` intentionally does not await `openProject`, but awaits `runTherion` so the run dialog still determines when the picker/CLI-startup action completes. It still opens the tabs page once the project load finishes, matching `pickProjectFile`'s own post-load behavior.
- `_isFilePickerOpen[MPFilePickerType.project]` is reused as the re-entrancy guard (shared with `pickProjectFile`, since both are now "pick a project file" pickers) — `MPFilePickerType.thconfig` and `pickTHConfigFile` are deleted as dead code.

### 4.4 Rerun and CLI-startup call sites

```dart
static Future<void> rerunTherionForOpenProject(BuildContext context) async {
  final String rootConfigPath = mpLocator.thProjectController.rootConfigPath;

  if (rootConfigPath.isEmpty) {
    return;
  }

  if (mpLocator.mpSettingsController.isTherionAvailable) {
    await runTherion(context, thConfigFilePath: rootConfigPath);
  } else {
    MPDialogAux.showHelpDialog(
      context,
      'no_therion_found',
      mpLocator.appLocalizations.mpNoTherionFound,
    );
  }
}
```

Replaces `runTherionWithLastTHConfig`.

`runTherionWithTHConfigFile(context, path)` (the CLI `--thconfig`/positional-argument startup path, `mapiah_home.dart:101,129`) is replaced by a shared helper, `runTherionAndOpenProjectInBackground`, used both by this CLI path and by §4.3's post-pick step:

```dart
static Future<void> runTherionAndOpenProjectInBackground(
  BuildContext context,
  String thConfigFilePath, {
  MPProjectLoader? projectLoader,
  MPRunTherionStarter? runTherionStarter,
}) {
  final MPProjectLoader loadProject =
      projectLoader ?? mpLocator.thProjectController.openProject;
  final MPRunTherionStarter startRun = runTherionStarter ?? runTherion;

  // Load the project in the background regardless of Therion availability
  // (and without waiting for a run that did start to finish), so "Rerun
  // Therion" becomes enabled the moment the project loads even if Therion
  // itself isn't available yet. THProjectController.openProject sets
  // rootConfigPath synchronously before its async parse even starts, so
  // rerunTherionForOpenProject's `rootConfigPath.isEmpty` guard clears
  // immediately -- this preserves runTherionWithTHConfigFile's original
  // documented intent ("Always store the path so 'Rerun Therion' is
  // enabled even if Therion is currently unavailable... The user can fix
  // the Therion path in settings and then use 'Rerun Therion' without
  // having to pick the file again"), now via an actually-loaded project
  // rather than a bare remembered path string.
  unawaited(
    loadProject(thConfigFilePath, forceConfigShape: true).then((_) {
          if (context.mounted) {
            ensureProjectTabsPageOpen(context);
          }
        }),
  );

  if (mpLocator.mpSettingsController.isTherionAvailable) {
    return startRun(context, thConfigFilePath: thConfigFilePath);
  }

  MPDialogAux.showHelpDialog(
    context,
    'no_therion_found',
    mpLocator.appLocalizations.mpNoTherionFound,
  );

  return Future<void>.value();
}
```

For the §4.3 picker flow, Therion availability was already confirmed `true` by `pickProjectFileAndRunTherion`'s own top-of-function gate before the picker even opened, so this helper's `isTherionAvailable` check is redundant-but-harmless there; for the CLI-argument flow (no picker, no prior gate) it is the only place that check happens, exactly replacing what `runTherionWithTHConfigFile` did today. `_runStartupFileActions` in `mapiah_home.dart` keeps using `await`, now as `await MPDialogAux.runTherionAndOpenProjectInBackground(context, widget.thConfigFilePath!)` (and the positional-argument equivalent). The helper returns the `runTherion` future, so CLI startup still waits for the Therion run dialog to close before the post-startup telemetry-consent/update-check block runs — exactly the existing `runTherionWithTHConfigFile` sequencing — while `openProject` still proceeds in the background.

### 4.5 Button/menu/shortcut call-site updates

In both `mapiah_home.dart` and `th2_file_tabs_page.dart`:
- The `Icons.playlist_add_check_outlined` button (`onPressed: () => MPDialogAux.chooseTHConfigAndRunTherion(context)`) becomes `onPressed: () => MPDialogAux.pickProjectFileAndRunTherion(context)`. Its tooltip string (`mapiahOpenTHConfigAndRunTherionButtonTooltip`, "Choose THConfig file and run Therion" / "Escolher ficheiro THConfig e executar Therion") is reworded to reflect the new action ("Open project and run Therion" / pt equivalent) — a string *value* change, not a new key, so it needs no `.arb` key additions (see §8).
- The `Icons.play_arrow_outlined` button's enablement (`hasTHConfig = mpLocator.mpGeneralController.thConfigFilePath.isNotEmpty`) becomes `hasOpenProject = mpLocator.thProjectController.rootConfigPath.isNotEmpty`, and its `onPressed` becomes `() => MPDialogAux.rerunTherionForOpenProject(context)`. Since `rootConfigPath` is `@observable`, the surrounding `Observer` (already present at both call sites) picks up project open/close automatically — no new reactivity plumbing.
- Both pages' compact overflow menus (`_MapiahHomeAction`/its `th2_file_tabs_page.dart` equivalent) get the same two renames; `enabled: hasTHConfig` becomes `enabled: hasOpenProject`.
- `mp_th2_file_edit_state.dart:285-286,358-359` (`MPButtonType.chooseTHConfigAndRunTherion`/`.runTherion` handlers, reached when a `.th2` canvas has keyboard focus) call `MPDialogAux.pickProjectFileAndRunTherion`/`rerunTherionForOpenProject` respectively — the `MPButtonType` enum values and the key bindings in `mp_th2_file_edit_state_key_down_mixin.dart` (`T`/`Ctrl+T`) are unchanged, only their handlers' target method names.
- `MPRunTherionDialogWidget`'s in-dialog `Ctrl+T` handler (`_ChooseTHConfigAndRunTherionIntent.onInvoke`, `mp_therion_run_dialog_widget.dart:396-401`) is unchanged in structure (still stops the runner and pops `true`); only `MPDialogAux.runTherion`'s post-pop call changes from `chooseTHConfigAndRunTherion` to `pickProjectFileAndRunTherion` (§4.2).

---

## 5. Race Between a Fast Compile and the Background Project Load

Because `runTherion` and `openProject` now run concurrently (§4.3/§4.4), a Therion run that finishes before `openProject` has finished parsing the tree will find `THProjectController.rootConfigPath` not yet equal to the run's path when the diagnostics bridge (§7) checks it — that run's diagnostics are then silently dropped rather than attributed to a tree that doesn't exist yet.

This is treated as an accepted, low-probability edge case rather than something this phase engineers around: `openProject`'s tree parse is in-process file I/O plus grammar parsing, while `therion` is an external compiler invocation (LaTeX/PDF generation, cave-loop closure, etc.) almost always slower by at least an order of magnitude for any project big enough to be worth compiling. See Risk 3 (§11) for the fallback if real-world usage shows otherwise.

---

## 6. `th_project_therion_diagnostics_aux.dart` — Parsing Therion Output

Pure functions, no MobX/locator dependency, following the `th_project_reparse_aux.dart` pattern:

```dart
final RegExp _locatedTherionIssueRegex = RegExp(
  '\\btherion\\b\\s*:\\s*($mpTherionWarningWord|$mpTherionErrorWord)\\s*--\\s*'
  '([^\\[\\]]+?)\\s*\\[\\s*(?:line\\s+)?(\\d+)\\s*\\]\\s*--\\s*(.+)\$',
  caseSensitive: false,
);

/// Parses Therion compiler output (live stdout/stderr capture and/or the
/// contents of `therion.log`) into file/line-addressable
/// [THProjectParseError]s. Lines that don't match the located-diagnostic
/// shape (e.g. summary lines, loop-closure reports) are ignored here --
/// they're already surfaced as-is in the run dialog's raw output pane.
List<THProjectParseError> parseTherionRunDiagnostics({
  required List<String> outputLines,
  required List<String> logLines,
  required String workingDirectory,
}) {
  final List<THProjectParseError> diagnostics = <THProjectParseError>[];
  final Set<String> seenKeys = <String>{};

  void collectFrom(List<String> lines) {
    for (final String line in lines) {
      final RegExpMatch? match = _locatedTherionIssueRegex.firstMatch(line);

      if (match == null) {
        continue;
      }

      final bool isError = match
          .group(1)!
          .toLowerCase() == mpTherionErrorWord;
      final String rawFilePath = match.group(2)!.trim();
      final int lineNumber = int.parse(match.group(3)!);
      final String message = match.group(4)!.trim();
      final String canonicalPath = THProjectPathResolver.canonicalize(
        p.isAbsolute(rawFilePath)
            ? rawFilePath
            : p.join(workingDirectory, rawFilePath),
      );
      final String dedupeKey =
          '$canonicalPath|$lineNumber|$isError|$message';

      if (!seenKeys.add(dedupeKey)) {
        continue;
      }

      diagnostics.add(
        THProjectParseError(
          message: message,
          severity: isError
              ? THProjectParseErrorSeverity.error
              : THProjectParseErrorSeverity.warning,
          filePath: canonicalPath,
          lineNumber: lineNumber,
        ),
      );
    }
  }

  collectFrom(outputLines);
  collectFrom(logLines);

  return diagnostics;
}
```

Notes:
- The regex is a plain (non-raw) string with `$mpTherionWarningWord`/`$mpTherionErrorWord` interpolated into it and every literal backslash doubled, matching the exact idiom `mp_therion_runner.dart:139-142`'s existing `_warningRegex`/`_errorRegex` already use — a Dart raw string (`r'...'`) would *not* interpolate those constants (`$mpTherionWarningWord` would match the literal 21-character text, never Therion's real output), so this must not be written as a raw string despite the temptation to use one for the heavy backslash-escaping.
- Matching is deliberately isolated to one regex/one function so it can be corrected against real `therion`/`therion.log` samples during implementation without touching `THProjectController` or any widget.
- A line that mentions "warning"/"error" but doesn't carry a `[line N]` location (e.g. a summary count, or a genuinely file-less diagnostic) is silently skipped here rather than surfaced as a project-level (line-0) diagnostic — Mapiah's own parse-time errors already use `lineNumber: 0` for genuinely unlocated failures (`openProject`/`saveProjectFile` catch blocks), but a compiler line that merely failed *this* regex is far more likely to be noise (a loop-closure report, a restated summary) than a genuine unlocated error; if real-world fixtures show otherwise during implementation, promoting unmatched warning/error lines to `lineNumber: 0` loose diagnostics is a small, contained follow-up to this same function.
- De-duplication guards against Therion printing the same diagnostic to both stdout and `therion.log` (confirmed as a realistic possibility, not verified either way — cheap enough to always de-dupe).

---

## 7. `THProjectController` Additions

```dart
@observable
ObservableList<THProjectParseError> compilerErrors =
    ObservableList<THProjectParseError>();

@computed
List<THProjectParseError> get allDiagnostics =>
    <THProjectParseError>[...projectErrors, ...compilerErrors];

@action
void applyTherionRunDiagnostics(List<THProjectParseError> diagnostics) {
  compilerErrors = ObservableList<THProjectParseError>.of(diagnostics);
}

List<THProjectParseError> compilerErrorsForPath(String canonicalPath) =>
    compilerErrors
        .where((THProjectParseError error) => error.filePath == canonicalPath)
        .toList();
```

- `applyTherionRunDiagnostics` always **replaces** the list (never appends), so calling it with the fresh full parse result at the end of every run naturally clears diagnostics that no longer reproduce — no separate "clear" action needed.
- `closeProject()` gains `compilerErrors = ObservableList<THProjectParseError>();` alongside its existing `projectErrors = ...` reset, so switching projects doesn't leak the previous project's compiler diagnostics.
- No change to `openProject`/`_applyLoadResult` is needed for the "connect to Run Therion" objective — that is now handled entirely by §4 (there is no second field to keep in sync with).

---

## 8. Bridging a Finished Run into `THProjectController`

In `MPRunTherionDialogWidget._onTherionRunFinished()` (`mp_therion_run_dialog_widget.dart:90-151`), after `therionOutputLines`/`therionLogLines` are computed (both already exist in this method today) and before they're flattened into the dialog's own display text:

```dart
final String canonicalRunConfigPath = THProjectPathResolver.canonicalize(
  p.absolute(widget.thConfigFilePath),
);

if (canonicalRunConfigPath == mpLocator.thProjectController.rootConfigPath) {
  mpLocator.thProjectController.applyTherionRunDiagnostics(
    parseTherionRunDiagnostics(
      outputLines: therionOutputLines,
      logLines: therionLogLines,
      workingDirectory: p.dirname(widget.thConfigFilePath),
    ),
  );
}
```

- The equality check is what keeps diagnostics scoped to the loaded project (Objective 7): a run whose `thconfig` never becomes (or isn't yet, per §5) the loaded project does not touch `compilerErrors` — there would be no tree/editor tabs to attribute them to anyway.
- Also call `mpLocator.thProjectController.applyTherionRunDiagnostics(const <THProjectParseError>[])` at the start of a run (in `initState`, right after `_therionRunner` is constructed) so stale diagnostics from a previous run don't linger on screen for the whole duration of a new one that turns out clean — guarded by the same path-equality check, for symmetry.
- This bridge call sits inside the existing `if (!mpIsFlathub) { ... }` guard in `_onTherionRunFinished` (it needs `therionLogLines`, only computed there) — Flathub builds keep the live status banner but do not get tree/editor compiler diagnostics, an existing platform limitation this phase does not change (see Risk 4).
- This is the only change to `mp_therion_run_dialog_widget.dart` beyond §4.5's `Ctrl+T` retarget; `MPTherionIssue`/`issuesNotifier`/the dialog's own rendering are untouched.

---

## 9. `THTextEditorController.diagnostics` — One-Line Change

```dart
@computed
List<THProjectParseError> get diagnostics => _projectController.allDiagnostics
    .where((THProjectParseError error) => error.filePath == canonicalPath)
    .toList();
```

`.projectErrors` → `.allDiagnostics`. Nothing else in the text-editor stack changes: `THTextEditorDiagnosticMarkerWidget` already renders whatever `diagnostics` returns, already severity-colored, already whole-line (§1 non-goals).

---

## 10. Project Tree: Diagnostics-Aware Error Dot + Its Own Tap Target

### 10.1 `THProjectTreeWidget` error summary banner

`THProjectTreeWidget.build()` (`th_project_tree_widget.dart:30-54`) currently reads `projectErrors` into a local, gates the banner with `if (projectErrors.isNotEmpty)`, and passes that local to `_THProjectTreeErrorSummary`. All three points must switch to `mpLocator.thProjectController.allDiagnostics`, not just the call at line 54. Concretely:

```dart
final List<THProjectParseError> allDiagnostics =
    mpLocator.thProjectController.allDiagnostics;

// ...

if (allDiagnostics.isNotEmpty)
  _THProjectTreeErrorSummary(
    errors: allDiagnostics,
    appLocalizations: appLocalizations,
  ),
```

Reading `allDiagnostics` in the outer `Observer.build()` is what lets compiler-only diagnostics both show the summary banner and invalidate the tree when `compilerErrors` is reassigned. The banner's own rendering (count + newline-joined tooltip of messages) needs no changes — it is already list-agnostic.

### 10.2 `THProjectTreeNodeWidget` error dot

```dart
List<THProjectParseError> _errorsForNode(THProjectNode currentNode) {
  if ((currentNode is THConfigFileNode) ||
      (currentNode is THDataFileNode)) {
    return <THProjectParseError>[
      ...currentNode.parseErrors,
      ...mpLocator.thProjectController.compilerErrorsForPath(
        currentNode.absolutePath,
      ),
    ];
  }

  return currentNode.parseErrors;
}
```

- `build()`'s `if (node.hasErrors) _buildErrorDot(context)` becomes `if (nodeErrors.isNotEmpty) _buildErrorDot(context, nodeErrors)` where `nodeErrors = _errorsForNode(node)` is computed once per `build()`.
- Per §1's non-goal, compiler diagnostics are attached only at text-editor file nodes (`THConfigFileNode`/`THDataFileNode`); logical nodes (`THSurveyNode`/`THCentrelineNode`/`THMapNode`/inline `THScrapNode`), `TH2FileNode`, and `THMissingFileNode` keep showing only their existing parse-time `parseErrors` — unchanged from today.
- `_buildErrorDot` gains its own `onTap`, separate from the row's `_onTap` (which still just opens the file at the top, unchanged for a plain row click):
  ```dart
  Widget _buildErrorDot(BuildContext context, List<THProjectParseError> nodeErrors) {
    return GestureDetector(
      key: ValueKey('THProjectTreeNodeErrorDot|${node.id}'),
      onTap: () => _onErrorDotTap(nodeErrors),
      child: Tooltip(
        message: '${nodeErrors.length}',
        child: Container(/* unchanged decoration */),
      ),
    );
  }

  void _onErrorDotTap(List<THProjectParseError> nodeErrors) {
    mpLocator.thProjectController.selectNode(node.id);

    if ((node is! THConfigFileNode) && (node is! THDataFileNode)) {
      return;
    }

    if (nodeErrors.isEmpty) {
      return;
    }

    final THProjectFileNode fileNode = node as THProjectFileNode;
    final List<THProjectParseError> compilerErrors =
        mpLocator.thProjectController.compilerErrorsForPath(
          fileNode.absolutePath,
        );
    final int targetLine = compilerErrors.isNotEmpty
        ? compilerErrors.first.lineNumber
        : nodeErrors.first.lineNumber;

    _openTextEditorTab(fileNode.absolutePath, lineNumber: targetLine);
  }
  ```
  Reuses the exact `_openTextEditorTab` helper already added in Phase 6 (§6 of that phase's plan) — no new tab/navigation code. `GestureDetector.onTap` must call `mpLocator.thProjectController.selectNode(node.id)` itself; the row's outer `InkWell` does not reliably fire for a nested dot tap, so the dot handler is responsible for both selecting the node and opening/scrolling to the diagnostic line.
- The dot's fill color stays `colorScheme.error` regardless of whether the mix contains only warnings (matches today's existing behavior — Phase 7 does not add warning/error color-splitting to the tree dot, only to the text editor's marker, which already had it).

---

## 11. Risks & Open Questions

1. **The exact Therion diagnostic line format is unverified against a real `therion` binary in this environment.** The regex targets the top-level roadmap's own documented example (`therion: error -- filename.th [line 42] -- syntax error`); if real output differs (e.g. no `line ` keyword inside the brackets, a different `--`/`:` separator, or the file path quoted), `t3911`'s fixtures need updating and the regex adjusted — contained entirely to `th_project_therion_diagnostics_aux.dart` and its own test file, touching nothing else. Mitigation: implementation should run `therion` against a real fixture project and capture actual stdout/`therion.log` output before finalizing the regex, rather than relying solely on the roadmap's illustrative example.
2. **File-node-only compiler-diagnostic attribution (§1 non-goal) may feel coarse for a large `.th` file with many surveys.** Mitigation: the text editor's line-accurate gutter marker is the real navigation surface once the tab is open (one click away via the file-node dot); revisit only if user feedback shows the file-level dot isn't enough of a signal to justify opening the file.
3. **The fast-compile-vs-background-load race (§5).** If real-world use shows Therion regularly finishing before `openProject` (e.g. a trivial one-file `thconfig` with a slow-to-parse but structurally huge `.th` tree), a contained fix is for `_onTherionRunFinished` to also retry the diagnostics bridge once after `THProjectController.isParsing` transitions back to `false`, rather than only checking once at run-finish time — not implemented in this phase since it adds a reaction/listener for a scenario judged unlikely (§5's reasoning).
4. **`_onTherionRunFinished`'s existing `mpIsFlathub` guard** (see §8) means Flathub builds will not get tree/editor compiler diagnostics from this phase, only the existing live status banner — an existing, pre-Phase-7 platform limitation (Flathub already skips the `therion.log`-derived post-run output section entirely) that this phase does not change.
5. **Stale compiler diagnostics after an edit.** Editing a file does not clear its compiler diagnostics (only a rerun does, since `applyTherionRunDiagnostics` only runs at the end of a run) — this is intentional (Mapiah cannot verify a fix without recompiling), matching how any IDE with a separate compile step behaves; no special "stale" UI treatment is added in this phase.
6. **Deleting `MPGeneralController.thConfigFilePath` is a breaking change for anything outside this plan's grep sweep that might read it** (e.g. a test file not touched by the grounding pass, or telemetry). Mitigation: `flutter analyze` after removal will surface any remaining reference as a compile error, since Dart has no silent-fallback for a removed field/getter — this is a self-checking removal, not a risk that can hide.

---

## 12. Step-by-Step Implementation Sequence

```
Step 1: MPDialogAux — runTherion takes an explicit thConfigFilePath param
   │
   ▼
Step 2: MPDialogAux — add pickProjectFileAndRunTherion, rerunTherionForOpenProject,
        runTherionAndOpenProjectInBackground; delete pickTHConfigFile /
        pickTHConfigFileAndRunTherion / chooseTHConfigAndRunTherion /
        runTherionWithLastTHConfig / runTherionWithTHConfigFile
   │
   ▼
Step 3: Remove MPGeneralController.thConfigFilePath / setTHConfigFilePath;
        MPFilePickerType.thconfig no longer referenced, remove it too;
        re-run `dart run build_runner build` to regenerate
        mp_general_controller.g.dart (the removed field's getter is
        MobX-generated, not hand-written)
   │
   ▼
Step 4: Update call sites: mapiah_home.dart, th2_file_tabs_page.dart (buttons +
        compact menus + _withShortcuts), mp_th2_file_edit_state.dart /
        mp_th2_file_edit_state_key_down_mixin.dart, MPRunTherionDialogWidget's
        in-dialog Ctrl+T handler, mapiah_home.dart's _runStartupFileActions;
        remove the orphaned mapiahTherionSelectTHConfigDialogTitle .arb key
   │
   ▼
Step 5: Add th_project_therion_diagnostics_aux.dart (parseTherionRunDiagnostics)
   │
   ▼
Step 6: Add THProjectController.compilerErrors / allDiagnostics /
        applyTherionRunDiagnostics / compilerErrorsForPath; closeProject resets
        compilerErrors
   │
   ▼
Step 7: THTextEditorController.diagnostics reads allDiagnostics
   │
   ▼
Step 8: THProjectTreeWidget error summary banner reads allDiagnostics
   │
   ▼
Step 9: THProjectTreeNodeWidget: diagnostics-aware error dot + its own tap handler
   │
   ▼
Step 10: Wire MPRunTherionDialogWidget._onTherionRunFinished (+ initState) to call
         the diagnostics bridge, gated on rootConfigPath match
   │
   ▼
Step 11: Unit and widget tests
   │
   ▼
Step 12: flutter analyze / flutter test
```

---

## 13. Test Plan

Test numbering continues at `t3911`:

| Test file | Coverage |
| :--- | :--- |
| `test/t3911_mp_dialog_aux_run_therion_retargeting_test.dart` | `rerunTherionForOpenProject` no-ops when `THProjectController.rootConfigPath` is empty and runs `MPRunTherionDialogWidget` with that path when set; `pickProjectFileAndRunTherion` uses injected `pickFile`/`launch` seams and passes the picked path to `launch`; `runTherionAndOpenProjectInBackground` uses injected `projectLoader`/`runTherionStarter` seams, calls `projectLoader` before `runTherionStarter`, does not await `projectLoader`, and waits for the `runTherionStarter` future so CLI/picker callers complete when the run dialog closes. |
| `test/t3912_th_project_therion_diagnostics_aux_test.dart` | `parseTherionRunDiagnostics`: matches the documented `therion: error -- file [line N] -- message` / `warning` shape; ignores unlocated lines; resolves relative paths against `workingDirectory` and canonicalizes them; de-duplicates identical diagnostics seen in both `outputLines` and `logLines`; case-insensitive `error`/`warning` matching. |
| `test/t3913_th_project_controller_compiler_diagnostics_test.dart` | `applyTherionRunDiagnostics` replaces (not appends to) `compilerErrors`; `allDiagnostics` merges `projectErrors` + `compilerErrors`; `compilerErrorsForPath` filters correctly; `closeProject` clears `compilerErrors`. |
| `test/t3914_th_text_editor_controller_compiler_diagnostics_test.dart` | A `THProjectController.compilerErrors` entry for an open editor's `canonicalPath` appears in `THTextEditorController.diagnostics` and renders via the existing `THTextEditorDiagnosticMarkerWidget` path (mirrors `t3904`'s harness). |
| `test/t3915_th_project_tree_node_widget_compiler_error_dot_test.dart` | A compiler diagnostic on a `THDataFileNode`/`THConfigFileNode` shows the error dot with the combined (parse + compiler) count; a compiler diagnostic on a file with no static parse errors still shows the dot; a `TH2FileNode` compiler diagnostic does not gain a dot or text-editor navigation; logical child nodes (survey/centreline/map) do not gain a dot from a compiler diagnostic in their file; tapping the dot selects the file node, opens/focuses its text-editor tab, and sets `pendingScrollToLine` to the first compiler diagnostic when one exists, otherwise to the first parse error. |
| `test/t3916_mp_therion_run_dialog_widget_diagnostics_bridge_test.dart` | Using an injected `MPTherionRunner` (constructor already supports `therionRunner:` injection) that surfaces known output/log lines: when the run's `thConfigFilePath` canonicalizes to the loaded project's `rootConfigPath`, `THProjectController.compilerErrors` is populated after the run finishes; when it does not match (no project loaded, or a different project), `compilerErrors` stays empty; a second run with different diagnostics fully replaces the first run's set. |
| `test/t3917_mapiah_home_run_therion_buttons_test.dart` | Widget test: "Run Therion" button is disabled with no project loaded and enabled once one is, and calls `rerunTherionForOpenProject`; "Open project and run Therion" button calls `pickProjectFileAndRunTherion`; both the compact overflow menu and the expanded app-bar variants agree. |

Representative scenarios:

1. **"Open project and run Therion" starts the compile before the tree exists.** Picking a project file immediately shows `MPRunTherionDialogWidget` (Therion output starts streaming) while `THProjectController.isParsing` is still `true`/`projectRootNode` is still the *previous* project's (or `null`) — the tree only updates once `openProject`'s background `Future` resolves, independent of whether the dialog is still open.
2. **"Rerun Therion" targets whatever project is currently loaded**, with no picker step, and is disabled with no project loaded — verified across both `mapiah_home.dart` and `th2_file_tabs_page.dart`.
3. **A `[line N]`-located compiler error lights up the right file's dot** and, once that file's tab is opened (by clicking the dot or the file node itself), the corresponding line in the text editor shows the same whole-line diagnostic marker style already used for parse-time errors.
4. **Editing the file after a run clears its parse-time errors but not its compiler errors** (they're independent lists) — an edit that fixes the actual Therion error only clears from the tree/editor once the user reruns Therion and the fresh (now error-free) diagnostic set replaces the stale one; exercised by the "second run fully replaces the first" case in `t3916`.
5. **CLI startup (`--thconfig path` / positional argument) still starts Therion immediately**, exactly as before, and now also loads that path as the open project in the background (a behavior change from today, where the CLI-argument path never touched the project tree at all) — this is the intended unification, not a regression, since it makes CLI-launched sessions get the same tree/diagnostics wiring as a manually-picked one.

---

## 14. Localization & Documentation Touches

- `mapiahOpenTHConfigAndRunTherionButtonTooltip`'s en/pt string *values* are reworded from "Choose THConfig file and run Therion"/"Escolher ficheiro THConfig e executar Therion" to reflect the new "open project and run Therion" behavior — same `.arb` keys, no additions/removals, so `AppLocalizations` code generation is unaffected.
- Deleting `pickTHConfigFile` (§4.3) orphans `mapiahTherionSelectTHConfigDialogTitle` (`lib/l10n/intl_en.arb:258-260`, `intl_pt.arb:68`, whose own doc comment says "Used on: MPDialogAux.pickTHConfigFile"). An unused `.arb` key doesn't break `flutter gen-l10n` or `flutter analyze`, so leaving it is not a correctness issue, but it should be deleted alongside the method it documents rather than left behind as a dangling string nothing references. `mpNoTherionFound`'s doc comment (`intl_en.arb:1136`, "Used on: MPDialogAux.chooseTHConfigAndRunTherion, MPDialogAux.runTherionWithLastTHConfig, ...") is similarly a doc-comment-only reference that goes stale once those methods are renamed — update it to name `pickProjectFileAndRunTherion`/`rerunTherionForOpenProject` instead, purely cosmetic (doc comments aren't compiled/checked).
- The error dot's tooltip and the diagnostic marker's tooltip need no new strings (count and Therion's own message text, respectively, exactly as before).
- Help pages (`assets/help/en/run_therion_help.md`, `mapiah_home_help.md`, and the keyboard-shortcuts tables' description text for the now-reworded button) are deferred to Phase 8, per the top-level roadmap (same exception already used by Phases 4-6) — the keys `T`/`Ctrl+T` themselves are unchanged, so the shortcut *tables* remain technically accurate even before that pass; only their prose descriptions of what the shortcut does become slightly stale until Phase 8.
