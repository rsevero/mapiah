<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 6: Documentation and Remaining Localization

**Date:** 2026-09-24

**Status:** Proposed; checked against the code at `cf38e0d0` on 2026-09-24.

**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md) (§7, Phase 6; §4.7 broken files)

**Prerequisite:** Phases 1–5 are implemented. Phase 7 is planned separately and may change the scrap controls and standalone-file tree.
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose and current state

The Phase 1 broken-file body still contains three English literals: its explanation, `Line …: …`, and `Reload`. The sidebar already has localized `th2ElementTreeProblemLine` and `th2ElementTreeReload` strings, but both the body and the sidebar badge display the parser's `TH2FileProblem.detail` directly. That detail is an internal diagnostic and can be English or parser-specific text in a Portuguese UI. `TH2FileProblem.kind` provides eight stable categories suitable for a localized, user-facing explanation.

The EN/PT `.th2` editor help already has an **Elements in the project tree** section from Phases 3–5. It covers order, labels (including Phase 5 details), selection, dragging, menus, search, and a brief broken-file note. The EN/PT keyboard-shortcut tables already contain the four drawing-order bindings, but their rows (and the EN project-tree click rows) are wider than their neighbors. The two PT project-tree click rows (`keyboard_shortcuts_edit.md:115-116`) are not in the table at all: they sit after the **Pesquisa em arquivos de texto** list, so they do not render as table rows. The workspace help describes the project sidebar as file and logical nodes, without saying that expanding a loaded `.th2` file reveals its element tree. The current unreleased CHANGELOG already describes the Phase 1 safety change, but an older planning entry in the same unreleased section (the first TH2 element-tree plan entry) still claims broken files are saveable and fixable inside Mapiah; that entry is now factually wrong.

This phase makes the broken-file information readable in either locale, consolidates the help into the sections promised by the parent plan, and corrects the shortcut and CHANGELOG descriptions. It does not add hierarchy repair or change parsing, drawing, editing, or saving rules.

## 2. Localization design

### 2.1 User-facing problem text

Add one shared formatter, for example `TH2FileProblemTextAux.userMessage(TH2FileProblemKind kind, AppLocalizations l10n)`, with an exhaustive switch over all eight enum values. Keep it separate from `TH2FileProblem.detail`: the parser's detail remains available as diagnostic evidence, and the localized text is the primary explanation in both the broken-file body and the sidebar badge. The formatter takes no widget context and never mutates the problem.

| Kind | English message meaning | Portuguese message meaning |
|---|---|---|
| `plaOutsideScrap` | Point, line, or area outside a scrap | Ponto, linha ou área fora de um croqui |
| `scrapInsideScrap` | Scrap inside another scrap | Croqui dentro de outro croqui |
| `strayEndscrap` | `endscrap` without an open scrap | `endscrap` sem um croqui aberto |
| `missingEndline` | Line missing `endline` | Linha sem `endline` |
| `missingEndarea` | Area missing `endarea` | Área sem `endarea` |
| `missingEndscrap` | Scrap missing `endscrap` | Croqui sem `endscrap` |
| `invalidBorderReference` | Area border does not refer to a valid line | Borda de área não aponta para uma linha válida |
| `parseError` | Unrecognized or invalid TH2 content | Conteúdo TH2 não reconhecido ou inválido |

Use distinct `.arb` keys named `th2FileProblemPlaOutsideScrap` through `th2FileProblemParseError`, with EN descriptions and PT translations. The generic `parseError` message must not guess which command failed; the source line and expandable technical detail give the specifics. Do not expose enum names in the UI. For the badge, keep the existing problem count and truncation limit, but pass the localized category to `th2ElementTreeProblemLine(lineNumber, detail)`. That key's existing `detail` placeholder can hold the localized category; its description should say so and list the broken-file body as a second user.

### 2.2 Broken-file body

Add one EN/PT key for the body explanation: the file has structural or parsing errors, Mapiah cannot display, edit, or save it, and the user should fix it in a text editor and reload. Reuse `th2ElementTreeProblemLine` and `th2ElementTreeReload` for each problem row and the button. Update the `th2ElementTreeReload` description, which today names only the context menu, to also name the body button. Put the source line on its own line without trimming leading indentation; `trimRight()` may remove trailing whitespace for display only. Show the localized category in the main problem row and put `problem.detail` behind a localized **Details** disclosure. This prevents raw diagnostic text from being presented as the translated explanation while preserving it for reports. The body remains scrollable and the Reload callback behavior stays as it is.

The parent plan's §4.7 also specifies the file path and a **Copy path** button, but the current body has neither. Add both as part of completing that user guidance. Use a selectable path, `Clipboard.setData`, and a localized button/tooltip label; do not add a success toast unless a matching established pattern is found. The path comes from `controller.th2File.filename`, and the button is available for a broken file opened without a project. Use existing `mpLocator.appLocalizations` access as the project convention requires. Do not hard-code any displayed English or Portuguese string.

The sidebar row should continue to show its broken badge and expanded status row, while an open tab shows the broken-file body. Keep the current Save/Save As/Save All protections untouched. If a load throws rather than returning `TH2FileProblem`s, keep its existing handling: `_handleLoadFailure` shows `MPErrorDialog` and closes the tab, and Reload stays available only from the tree row's context menu. The eight category messages apply only to parsed problems.

### 2.3 String audit and generated files

Search the Phase 1–5 affected UI paths for string literals that reach `Text`, `Tooltip`, `Semantics`, menu items, `SnackBar`, or dialogs. At minimum inspect `TH2BrokenFileBodyWidget`, `THProjectTreeNodeWidget`, `TH2ElementTreeRowWidget`, `TH2ElementTreeDragController`, `THProjectTreeWidget`, and the row context menu. (No Therion-run warning mentions broken files today; `mp_therion_runner.dart` uses the word only for a broken pipe. The parent plan's §4.7 asks the run dialog to warn about open broken files, but that was never implemented. Adding it is new behavior, not localization, so it is out of scope here; the parent plan's Phase 8 now owns it. Do not describe the warning in the help until Phase 8 adds it.) Ignore code keys, log messages, source data, and tests; localize any newly found user-facing literal. Preserve existing Phase 3–4 keys where wording fits. Add matching EN/PT `.arb` values and EN placeholder descriptions, then run `flutter gen-l10n`. Do not edit generated localization files by hand.

## 3. Help and shortcut pages

### 3.1 `.th2` editor help, EN and PT

Split the existing **Elements in the project tree** material into a dedicated **Drawing order and element tree** section and a dedicated **Broken files** section, and update the index anchors. Also add the missing index links to the existing **Project text editor** / **Editor de texto do projeto** section; both the EN and PT indexes lack it. Move and refine the current bullets instead of copying them, so the help does not give two competing explanations. Cover:

- Expand a `.th2` file to load and see scraps, then points, lines, and areas; collapsing a scrap hides its rows. Loaded standalone files are described only after Phase 7 implements its planned standalone section. A file opened outside a project can still show the broken-file body even without a tree row.
- Rows follow XTherion file order, first drawn at the bottom and last on top. Therion's own rendered layering may differ. Selected elements are temporarily painted above others on Mapiah's canvas, and changing an area's row order alone may have no visible canvas effect: areas are not drawable children (`th_is_parent_mixin.dart:17-21`), and each area's fill is painted together with its border line (`mp_line_painting_mixin.dart:153-165`). Moving the border line's row is what changes where the fill is layered.
- Row label: kind, type and optional subtype, optional station `-name` or label/remark `-text` detail, and optional Therion id. Search matches the full label; a multiline label or remark has a tooltip.
- Click, Ctrl/Shift selection, active scrap, double-click zoom, drag upper/lower drop zones, Move to scrap, invalid-drop feedback, and the four order actions. Order actions move whole sibling elements, including a line or area's internal content, and edits are undoable. Comments and settings are not tree rows and stay at their file positions. Moving an area between scraps carries its border lines; moves that would leave a border line in a different scrap from any area using it are rejected.
- A loaded file with any parse or hierarchy problem is marked broken; its element rows and canvas editor are unavailable, and Mapiah cannot save it. Give examples (outside-scrap elements, nested scraps, stray/missing `end*`, invalid area border reference, malformed or unknown option/command). The badge lists problem line numbers, while the body also shows source lines; fix the source in a text editor outside Mapiah, then use Reload in the body or the tree context menu. Unknown point/line/area *types* alone remain accepted; unknown *options* are errors. Explain that Mapiah does not repair the file.

Keep the help aligned with the actual UI when Phase 6 is implemented. In particular, do not claim a standalone-file tree section until Phase 7 lands, and do not imply that Therion's symbol layering equals XTherion file order. Check any existing **Scraps** subsection for descriptions of the current dialog; Phase 7 is responsible for removing or rewriting those when its controls change.

### 3.2 Project-sidebar mention

Add a short EN/PT paragraph to `assets/help/{en,pt}/mapiah_home_help.md` under **Project workflow**. State that expanding a `.th2` file row loads its scrap/element list without opening a tab, the list shows file drawing order, and the editor help's **Drawing order and element tree** and **Broken files** sections contain details. Avoid saying all project files are eagerly parsed.

### 3.3 Keyboard shortcuts

Review both `assets/help/{en,pt}/keyboard_shortcuts_edit.md` tables against the actual state-machine bindings. The bindings are `Ctrl+]` (forward), `Ctrl+[` (backward), `Ctrl+Shift+]` (front), and `Ctrl+Shift+[` (back); `handleDrawingOrderShortcut` also accepts Meta instead of Ctrl on every platform (document it as Cmd on macOS) and ignores the keys while Alt is pressed. Keep all four rows once each, format them like neighboring rows, and place them alphabetically by their **Function/Ação** label. Some unrelated rows are already out of order (for example EN **Redo** after the **Scale** rows); do not reorder rows this work did not add. In the editor help, explain that the shortcuts act in the active canvas tab on selected drawing elements or on scraps selected in the tree; they require keyboard focus in that tab. Give the Ctrl/Shift-click tree-selection rows the same formatting and order, and move the two PT rows from after the text-search list into the table. This is a documentation correction, not a shortcut change.

## 4. CHANGELOG

Add one entry in the current unreleased section, referencing #32, for the localized broken-file body/problem categories, EN/PT help sections, shortcut-table cleanup, and the source-line/detail presentation. Check that the existing Phase 1 entries explicitly say broken files are neither drawn, edited, nor saved and must be fixed externally. Correct the older planning entry that says they are saveable and repairable in Mapiah; leave its historical plan context clear without leaving a false claim in the changelog that will be released. Do not repeat all Phase 1–5 feature entries.

## 5. Implementation order and expected files

1. Add the EN/PT problem-kind, body, Details, and Copy path keys; give EN entries useful descriptions and placeholders.
2. Add the exhaustive problem-kind formatter and use it in the body and badge. Add the path, Copy path, and Details controls; keep parser diagnostics separate.
3. Add focused localization/widget coverage, then run `flutter gen-l10n` and `flutter analyze`.
4. Audit the remaining Phase 1–5 user-facing literals and localize any found.
5. Consolidate both editor help pages, add the project-workflow mention in both workspace help pages, and correct both keyboard-shortcut tables.
6. Update the unreleased CHANGELOG and its obsolete planning statement.
7. Run the focused tests, `flutter analyze`, and `flutter test`.

| Area | Expected files |
|---|---|
| Localization | `lib/l10n/intl_en.arb`, `intl_pt.arb`; generated `lib/src/generated/i18n/app_localizations*.dart` |
| Problem presentation | new `lib/src/auxiliary/th2_file_problem_text_aux.dart`, `lib/src/widgets/th2_broken_file_body_widget.dart`, `th_project_tree_node_widget.dart` |
| Help | `assets/help/{en,pt}/th2_file_edit_page_help.md`, `mapiah_home_help.md`, `keyboard_shortcuts_edit.md` |
| Release notes | `CHANGELOG.md` |
| Tests | a focused new `test/t3954_th2_file_problem_localization_test.dart` (`t3951` is Phase 5, `t3952` is reserved for Phase 8 and `t3953` for Phase 7), or additions to `t3940` and `t3943` if those fixtures cover both surfaces cleanly |

No MobX annotations or `.g.dart` files should change.

## 6. Verification and acceptance

- In EN and PT, a broken-file body shows the localized explanation, every problem's line number and localized category, its source line, and a localized Reload button; Details reveals the original parser diagnostic. Copy path copies the exact filename. The body works for both project-owned and standalone broken files.
- The project-tree badge tooltip uses the same localized categories, still limits the visible problem list, and preserves the correct problem count. Neither surface shows `problem.detail` as its primary explanation in PT.
- A valid `.th2` file still opens normally. A broken file still cannot be drawn, edited, or saved. Reload after an external fix still opens the canvas. No parser or model behavior changes are required.
- The EN/PT help pages describe the controls as implemented, their index links resolve, all four order shortcuts appear once in alphabetic order in each shortcuts table, and the PT project-tree click rows render inside the table.
- Generated localization accessors compile, `flutter analyze` is clean, and `flutter test` passes. Tests should assert both locale outputs and at least one problem of each kind through the pure formatter; widget checks should cover line/source/detail separation and the Copy path action, without retesting the parser's full hierarchy matrix.
