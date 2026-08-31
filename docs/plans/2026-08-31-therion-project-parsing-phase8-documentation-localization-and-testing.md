<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 8: Documentation, Localization & Testing — Implementation Plan

**Date:** 2026-08-31  
**Status:** Proposed

## 1. Overview & Objectives

This document details **Phase 8** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It follows Phases 1–7, which provide the project parser, recursive tree, live re-parsing, project sidebar, text-editor tabs/navigation, and Therion compiler diagnostics.

Phase 8 is the release-readiness pass for the complete project workflow. It makes the feature discoverable in English and Portuguese, removes stale descriptions left by the transition from single-file editing to project editing, and closes the remaining test gaps across the integrated workflow.

### Key objectives

1. **Document the project workflow**: opening a project from any `thconfig` filename, navigating the project tree, opening `.th`/`thconfig` text tabs and `.th2` canvas tabs, editing/saving files, and running Therion for the loaded project.
2. **Document diagnostics**: explain parse errors versus compiler diagnostics, tree error indicators, line navigation, stale diagnostics until the next run, and the limitations of diagnostics without a source line.
3. **Complete EN/PT localization**: audit every user-facing string introduced or changed by Phases 4–7 and add or correct translations in the ARB source files.
4. **Keep shortcut documentation accurate**: update the `Ctrl/Cmd+T` behavior and the project-aware `T` behavior without changing the existing key bindings.
5. **Strengthen automated coverage**: add focused tests for localization/documentation-facing behavior and end-to-end project interactions, then run the complete validation suite.

## 2. Grounding: Current State

The implementation and existing tests establish the following baseline:

- `THProjectController` owns one loaded project (`rootConfigPath`), its recursive tree, parse errors, compiler errors, dirty paths, and text-editor navigation state.
- `THProjectTreeWidget` provides the project sidebar, filtering, open/close actions, project loading, run-project action, diagnostics summary, and navigation into file tabs.
- `THTextEditorWidget` supports `thconfig`/`.th` content, syntax highlighting, folding, find/replace, save/revert, line navigation, and diagnostic markers.
- `TH2FileTabsPage` is the unified workspace shown from the initial window (`lib/main.dart`); it hosts project loading, mixed `.th2` canvas and project text tabs, and the project actions that an earlier `MapiahHome` widget used to own. That widget no longer exists — only the `mapiah_home_help` help page and the `mpHelpPageMapiahHome` constant remain, and several ARB `@key` descriptions still name a stale `_MapiahHomeState` call site that the localization audit must correct.
- Therion execution is now project-oriented: opening/running a project selects the project, while rerun uses the currently loaded project. `Ctrl/Cmd+T` is not an in-dialog “choose another config” action once a project is loaded.
- `THProjectParseError` is reused for both parser and compiler diagnostics. The text editor already color-splits error and warning markers; the tree uses its diagnostics-aware file indicator.
- Existing project-related tests run through `t3918`, with two files currently sharing that number (`t3918_mp_dialog_aux_close_open_project_test.dart` and `t3918_th2_file_tabs_page_therion_shortcuts_test.dart`). The next unused numeric prefix is `t3919`. New Phase 8 tests must use names that do not collide; confirm the next unused prefix again immediately before implementation.

The current help pages still contain stale text, including “Choose THConfig file and run Therion” (in EN/PT `mapiah_home_help.md`, `keyboard_shortcuts_main.md`, `keyboard_shortcuts_edit.md`, and `th2_file_edit_page_help.md`) and the run-dialog description of `Ctrl+T` (EN/PT `run_therion_help.md`). Existing Phase 4–7 localization keys are largely present, so Phase 8 should prefer auditing and correcting the current catalog over introducing duplicate keys.

## 3. Scope and Non-Goals

### In scope

- Updates to the existing English and Portuguese help pages under `assets/help/en/` and `assets/help/pt/`, including `mapiah_home_help.md`, `run_therion_help.md`, and `th2_file_edit_page_help.md`.
- Updates to `assets/help/en/keyboard_shortcuts_main.md`, `keyboard_shortcuts_edit.md`, and their Portuguese counterparts.
- Audit and changes to `lib/l10n/intl_en.arb` and `lib/l10n/intl_pt.arb`, followed by `flutter gen-l10n`.
- Tests for user-visible project states, localized labels, shortcut behavior, diagnostics navigation, and complete project lifecycle scenarios.
- Documentation of platform-neutral behavior and the supported release targets (Linux AppImage/Flatpak, macOS, and Windows).

### Out of scope

- New parser, controller, widget, runner, or tab-management features.
- Changing shortcut assignments; only their descriptions and applicability are documented.
- Multi-file find/replace, which remains Phase 9.
- Adding a separate help page for every node type when the existing project/home and editor pages can explain the behavior clearly.
- Reworking Flathub process execution or the existing limitation around post-run `therion.log` processing.

## 4. Documentation Plan

### 4.1 `mapiah_home_help.md`

Update the initial-window workflow to describe:

- **Open Project** as the entry point for a Therion project, including projects whose root configuration file has no `.thconfig` extension.
- The distinction between opening a project and opening a standalone `.th2` file.
- The single-project model: loading another project replaces the loaded project tree, while file tabs have their existing lifecycle behavior.
- The project-aware Run Therion actions: the empty state can open a project and run it; a loaded project is rerun directly.
- What the sidebar contains and how project/file/logical nodes relate to source files.
- CLI startup behavior for `--thconfig` and positional configuration paths, including that the project tree is loaded for the selected configuration.

Use the existing image assets where they still represent the UI. If an icon screenshot no longer matches the final label or action, either update the asset reference as part of this phase or remove the misleading image rather than documenting obsolete controls.

### 4.2 `th2_file_edit_page_help.md`

This page still documents a `Ctrl+T` toolbar control as _"Choose THConfig file and run Therion"_ and references the `assets/help/images/iconChooseTHConfigAndRunTherion.png` screenshot. Update it to:

- Describe the toolbar action in project terms: opening a project and running Therion when no project is loaded, and rerunning the loaded project otherwise — consistent with the wording used in `mapiah_home_help.md` and `run_therion_help.md`.
- Replace or remove the `iconChooseTHConfigAndRunTherion.png` reference if the icon, label, or action no longer matches the shipped UI; do not leave a screenshot of an obsolete control.
- Keep the rest of the canvas-editing documentation on this page unchanged; only the Therion-run entry is in scope.

Apply the same change to the Portuguese `th2_file_edit_page_help.md`.

### 4.3 New or expanded project-tree help

Prefer adding a dedicated `project_tree_help.md` in both languages if the existing home page would become difficult to scan. It should cover:

- Sidebar search/filter and expand/collapse behavior.
- Persisted sidebar width/collapsed state.
- File-node actions and logical-node navigation.
- Dirty markers and the meaning of parse/compiler error indicators.
- Click behavior for `.th2` files, `thconfig`/`.th` files, scraps, surveys, maps, and centrelines.
- Missing-file and circular-reference diagnostics.

If a dedicated page is added, register its identifier in `mp_constants.dart` and expose it through the same help-button/page-loading path used by the existing help pages. Keep the page names and links synchronized in EN/PT.

### 4.4 `run_therion_help.md`

Correct the run-dialog documentation to explain:

- A run uses the loaded project’s root configuration file.
- `T` reruns that same project when no run is active.
- `Ctrl/Cmd+T` is an app-level open-project-and-run action only when no project is loaded; it is not a way to switch configuration from inside an active run dialog.
- Output problems may be linked to a project file and source line. Clicking a diagnostic or the relevant tree indicator opens the appropriate text tab where supported.
- Compiler diagnostics remain until a subsequent run replaces them; editing alone does not prove that a compiler error is fixed.

Keep the description of the existing output pane, status values, log section, and Therion availability behavior accurate.

### 4.5 Keyboard shortcut tables

There are two tables: `keyboard_shortcuts_main.md` (workspace/global actions — currently 6 entries, no save/find rows) and `keyboard_shortcuts_edit.md` (canvas-editing actions). Update both languages while preserving alphabetical ordering and the current keys. Re-sort any row whose label text changes so the alphabetical order still holds (for example, relabeling `Ctrl+T` from “Choose THConfig…” to “Open project…” moves it into the O group).

| Current entry | Table | Required documentation |
| --- | --- | --- |
| `Ctrl+T` | main + edit | “Open project and run Therion” when no project is loaded; explain the unavailable/rebound behavior when a project is already loaded. |
| `T` | main | “Run/rerun Therion for the current project” and identify the run-dialog context where applicable. |
| `Ctrl+O` / `Ctrl+Shift+O` | main | Describe opening a project in the workspace, while preserving any existing context-specific meaning. |
| `Ctrl+S` | new row in a text-editor section | Saving the active `thconfig`/`.th` text file. This shortcut is text-editor-scoped, so add it under a clearly labeled “Text editor” subsection (in `keyboard_shortcuts_main.md`, or a new shared section) rather than implying it is a global workspace action. |
| `Ctrl+F` | new row in the same text-editor section | The existing single-file text-editor find/replace behavior; do not imply Phase 9 project-wide search. |

`Ctrl+S` and `Ctrl+F` are net-new documentation rows; place them together in one text-editor-scoped block and keep that block consistent between EN and PT. Use “Ctrl” in the tables according to the existing convention and retain the note that Ctrl and Meta/Command are interchangeable.

### 4.6 Text-editor and project diagnostics documentation

Add concise sections to the project/editor help page(s) covering syntax highlighting, folding, debounced parsing, save/revert, line-targeted navigation, and the difference between:

- parser diagnostics generated while editing/loading; and
- compiler diagnostics generated by running Therion.

Explicitly document that compiler diagnostics without a recognized file/line remain visible in the run output but cannot be mapped to a specific tree line.

## 5. Localization Plan

### 5.1 Source files and conventions

The localization sources are `lib/l10n/intl_en.arb` and `lib/l10n/intl_pt.arb`. The English file is the metadata/template source; follow the existing convention for `@key` descriptions and placeholders. Do not edit generated files under `lib/src/generated/i18n/` by hand.

Audit strings used by:

- `TH2FileTabsPage` project actions (the unified workspace — there is no separate `MapiahHome` widget; treat any ARB `@key` description that still points at `_MapiahHomeState` as stale and repoint it at the real call site);
- `THProjectTreeWidget`, `THProjectTreeNodeWidget`, and `THProjectTreeUIController` (sidebar collapsed/width state and any labels it exposes, e.g. the `mpSettingsSettingProjectTreeSidebar*` keys);
- `THTextEditorWidget` and find/replace controls;
- `MPRunTherionDialogWidget` and diagnostic markers;
- project loading, missing-file, error-summary, and load-failure states.

### 5.2 Required localization checks

- Search source code for hardcoded user-facing strings in all Phase 4–7 files.
- Reuse an existing key when its meaning is unchanged; remove orphaned keys only when no source or help reference remains.
- Add matching EN/PT values for every new key. Preserve identical placeholder names and plural/select structure in both files.
- Keep terminology consistent: “project”, “project tree”, “text editor”, “scrap”, “survey”, “centreline”, “warning”, “error”, and “Run Therion”.
- Check capitalization against the project rule that UI text must not be all-caps.
- Run `flutter gen-l10n` after ARB edits and verify the generated getters compile.
- Test at least English and Portuguese widget builds for the principal project/tree/editor/run states.

No new localization key should be added solely to make a help page’s Markdown prose dynamic; help content remains localized as assets.

## 6. Testing Plan

### 6.1 Existing regression suites

Run the existing focused suites for:

- path resolution, parser/tree loading, logical nodes, incremental re-parsing, and saving;
- tree flattening, filtering, resize/collapse, icons, and node navigation;
- text syntax highlighting, folding, editing, find/replace, scrolling, and mixed tabs;
- project-oriented Therion actions, diagnostics parsing/merging, runner bridging, and shortcut gating.

The duplicated `t3918` prefix must be left untouched unless a test rename is explicitly needed; Phase 8 additions must not overwrite either file.

### 6.2 New focused tests

Allocate the next unused numeric prefixes at implementation time. Suggested coverage:

| Test area | Required scenarios |
| --- | --- |
| Localization smoke tests | EN/PT app builds expose all project/tree/editor/run labels; placeholders render; no missing translation causes a fallback or exception. |
| Project workflow widget tests | Empty state, loaded state, project replacement, tree filtering, file-node navigation, `.th2` canvas opening, and text-tab line navigation. |
| Run/shortcut documentation behavior | `T` reruns the loaded project; `Ctrl/Cmd+T` opens-and-runs only in the empty-project state; labels/tooltips match the documented actions. |
| Diagnostics integration | Parser and compiler diagnostics coexist, counts/colors are correct, clicking a diagnostic targets the right file/line, and a later run replaces stale compiler diagnostics. |
| Text editor lifecycle | Edit → debounce/reparse → dirty state → save/revert; localized empty/load-error/find/replace states render in both locales. |
| Help-page availability | Every registered help-page identifier resolves to EN and PT assets, including any new project-tree page; links do not point to removed pages. |
| Full project scenario | Load a root config with nested `.th`, `.th2`, missing, and cyclic references; edit a text file; navigate from tree to editor/canvas; run Therion; observe diagnostics; save and reload. |

Tests should use existing fixture and environment helpers under `test/auxiliary/`, inject runner/picker seams where available, and avoid depending on a locally installed Therion for unit/widget tests. A real Therion fixture run may be added as an opt-in integration test only if the repository’s test conventions support it.

### 6.3 Documentation consistency checks

Add a lightweight validation step (test or repository script, following existing project conventions) that checks:

- every help page exists in both languages;
- every help-page constant maps to an asset;
- keyboard shortcut tables contain the documented project/run actions;
- no obsolete “choose THConfig” wording remains where the action now means opening a project.

Do not build a general Markdown linter unless the focused checks cannot be implemented with existing tooling.

## 7. Implementation Sequence

1. Re-read the final Phase 4–7 behavior and run a source/help grep to produce the stale-string and stale-documentation inventory.
2. Confirm the next unused test prefix and record the chosen names before creating tests.
3. Update EN/PT help pages and keyboard shortcut tables, including any required image references or project-tree page registration.
4. Audit `intl_en.arb`/`intl_pt.arb`; add, correct, or remove keys and metadata as needed.
5. Run `flutter gen-l10n` and resolve generated-code or placeholder issues.
6. Add focused localization, help-asset, workflow, shortcut, and lifecycle tests.
7. Run focused project/text-editor/Therion tests, then the complete test suite.
8. Run `flutter analyze`; resolve all warnings and errors.
9. Review the final diff for EN/PT parity, stale terminology, broken help links, generated localization changes, and accidental changes outside Phase 8.

Formatting remains automatic on commit; do not run `dart format` manually.

## 8. Acceptance Criteria

- A new user can learn how to open a project, navigate its files/logical nodes, edit/save source files, open drawings, and run Therion from the localized help.
- EN and PT help pages describe the same behavior and contain no stale single-THConfig workflow instructions.
- All Phase 4–7 user-facing strings are localized, have matching placeholders, and compile through generated `AppLocalizations`.
- Keyboard shortcut tables remain alphabetically ordered, retain the existing key bindings, and accurately describe project-aware behavior.
- Focused tests cover the empty/loaded project states, mixed tabs, diagnostics navigation, localization, help-page assets, and the full project workflow.
- `flutter test` passes, `flutter analyze` reports no warnings/errors, and no generated localization file was hand-edited.
- The Phase 9 multi-file find/replace scope remains separate and is not accidentally documented as available functionality.

## 9. Deliverables

- Updated `assets/help/en/` and `assets/help/pt/` project, editor, run, home, and keyboard-shortcut documentation.
- Updated `lib/l10n/intl_en.arb` and `lib/l10n/intl_pt.arb`, plus generated localization output from `flutter gen-l10n`.
- New Phase 8 unit/widget/integration-level tests using non-colliding numeric prefixes.
- A passing full validation run and a final diff summary suitable for the release/commit review.
