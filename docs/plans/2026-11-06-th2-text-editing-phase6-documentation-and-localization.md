<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 6: Documentation and Localization

**Date:** 2026-11-06
**Status:** Proposed. Based on `feat_38_th2_text_editing` at `17921051`, with Phases 1–5 implemented. Line numbers in §2 are from that commit.

**Revalidation rule:** Before starting a step of §5, run `git diff 17921051 -- lib/l10n assets/help CHANGELOG.md lib/src/widgets lib/src/pages`. If it changes files that step's §2 items name, recheck only those items. Whether the implementation is correct is decided by §6's tests and `flutter analyze`.

**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§3.1–§3.9, §4.12, §4.14, §4.16, §4.17 and §5 Phase 6)
**Previous phase:** [Phase 5: Broken Files](2026-11-05-th2-text-editing-phase5-broken-files.md)
**Issue:** [#38](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose and boundaries

Finish the user-facing side of TH2 text editing: review every text-mode string in EN and PT, fix the strings that earlier phases made wrong, write the help and keyboard shortcut pages, and complete the CHANGELOG entry. No behavior changes.

All work, including this plan, stays on `feat_38_th2_text_editing`, in its worktree `/home/rodrigo/devel/mapiah-worktrees/feat_38_th2_text_editing` (AGENTS.md, "Parallel Work"). Do not create a Phase 6 branch. The main checkout stays on `main`. After this phase the branch can be merged into `main` (parent §5, _Branch and merge_), but only when the user asks for it (`ccm`).

Out of scope: the native undo first-snapshot delay (Phase 7), and the older PT strings that say "scrap" instead of "croqui" outside text mode (`mpSnapToInactiveScraps`, `th2ElementTreeMoveToScrap`, the `th2MoveRejected*` strings), which predate this feature.

## 2. Current state

### 2.1 Strings

Phases 3–5 added their strings with their code (Phase 4 plan, §3 change 4; Phase 5 plan, §3 change 7). EN/PT key parity holds. The parent's Phase 6 list maps to these keys:

| Parent Phase 6 item | Key(s) |
|---|---|
| _Text_ and _Canvas_ tooltips | `th2EditModeTextTooltip`, `th2EditModeCanvasTooltip`, `th2TextLeaveBrokenFileTooltip` |
| Discard action and its toolbar tooltip | `th2TextDiscardChangesButton`, `th2TextEditorDiscardTooltip` |
| "Can't apply" message | `th2TextCantApplyBanner`, `th2TextKeepEditingButton` |
| Unsupported lone `\r` | `th2TextUnsupportedLineEndingMessage`, `th2TextDiagnosticUnsupportedLineEnding` |
| Unencodable character | `th2TextDiagnosticUnencodableCharacter` |
| "Mapiah can't read this text" (§4.5) | `th2TextDiagnosticUnreadableText`, `th2TextDiagnosticValidationFailed` |
| Apply command description | `mpCommandDescriptionReplaceTH2FileContents` |
| Normalization messages (§4.12, §4.16) | `th2TextDiagnosticRemoved*`, `th2TextDiagnosticRewrittenLine`, `th2TextDiagnosticGenericRewrite`, `th2TextDiagnosticMovedSetting`, `th2TextDiagnosticAddedLine`, `th2TextDiagnosticAddedEnding` |
| Regeneration failure (§4.17) | `th2TextEditorReopenFailedMessage` (see §3 change 1) |
| _Edit as text_ | `th2BrokenFileEditAsText`, `th2BrokenFileEditAsTextTooltip`, `th2BrokenFileExplanation`, `th2BrokenFileTextUnreadableMessage`, `th2BrokenFileTextInvalidEncodingMessage`, `th2BrokenFileTextUnknownEncodingMessage` |
| Disabled eye button (§4.14) | `th2ActiveScrapCantBeHiddenTooltip` |
| Save status | none (see §3 change 2) |

Also from these phases: `th2SaveAsTargetOpenMessage`, `th2SaveAsTargetOpenEmptiedMessage`, `mapiahTherionRunBrokenFilesWarning` (rewritten to "broken on disk") and `mapiahTherionRunBrokenFileUnsavedFix`.

Problems found:

- **`th2ElementTreeBrokenFile`** (`intl_en.arb:4870`, `intl_pt.arb:988`, shown by `th2_element_tree_row_widget.dart:989`) still says "fix it outside Mapiah and reload". Since Phase 5 the file can be fixed with _Edit as text_.
- **`th2ActiveScrapCantBeHiddenTooltip`** in PT says "scrap"; the PT help and most PT strings say "croqui" (25 against 8 in `intl_pt.arb`).
- No hardcoded user text was found in the files the branch changed. `Text(' (')`/`Text(')')` (`th2_file_tabs_page.dart:259-261`) are punctuation and `'Controller not found'` (`:846`, `:860`) predates the branch.

### 2.2 Help, `assets/help/{en,pt}/th2_file_edit_page_help.md`

- No text-mode section. Nothing mentions `F2`, the _Text_ button or text mode.
- **Index** (`:7-55`). EN and PT have their sections in different orders; both have _Broken files_ / _Arquivos com problemas_ right after the element tree section (`:13`).
- **Element tree section** (`:86-106`). Its _Undo_ bullet says every tree edit can be undone; it doesn't say tree edits are disabled in text mode.
- **Broken files** (`:108-124`) says Mapiah "cannot save" a broken file and that it must be fixed "in a text editor outside Mapiah", and that the expanded tree row says to fix it outside Mapiah. Its _Running Therion_ bullet says nothing about unsaved fixes.
- **Top right corner** (EN `:128-136`) lists the canvas buttons, without _Text_.
- **Save / Original file format** (EN `:261-270`) lists the parser's normalizations but not the settings-section layout rule (parent §4.16) that ordinary Save now follows.
- **Scrap visibility** (EN `:397-400`, PT `:251-254`) says "Hiding the active scrap activates the nearest visible one", which §4.14 made false.

### 2.3 Keyboard shortcuts, `assets/help/{en,pt}/keyboard_shortcuts_edit.md`

- No `F2` row. The table is meant to be alphabetical (AGENTS.md), with `Help | F1` at EN `:39`.
- The Save As row reads "Save file as (`.th2` canvas or `thconfig`/`.th` text tab)", which leaves out `.th2` text mode.
- The _Text file search_ list says `.th2` drawings "are never searched; they stay canvas-owned". That still holds for multi-file search (`Ctrl+Shift+F`), but `Ctrl+F` now works in a `.th2` tab's text mode, since it uses the same `THTextEditorWidget` (`th_text_editor_widget.dart:908-910`).

### 2.4 CHANGELOG

Under _1.0.2 - not yet released_, the feature branch has the Phase 1 _Changes_ entry for the Save layout and _Fixes_ entries from Phases 2–5 that point at the "TH2 text editing will use" tests. There is no _New features_ entry for text mode. The section also has a duplicated `* Changes:` heading.

### 2.5 Tests

`t3919` and `t3932` check help and string parity for earlier features. No test asserts the stale help sentences or `th2ElementTreeBrokenFile`'s text. The last test number in use is `t3999`.

## 3. Changes to the parent plan

Recorded here, and in the parent's Phase 6 entry when this plan is implemented:

1. **No regeneration-recovery strings or help.** Phase 4 (its §3 change 1) replaced the read-only recovery state with a return to the canvas and a message. There is no _Retry text editor_, _Return to canvas_ or saved/unsaved recovery text to write. The help says instead that if the text editor can't be reopened after a save, Mapiah goes back to the canvas with a message, nothing is lost, and `F2` opens the text again. Parent §3.6's last-but-one paragraph still describes the recovery view: its "Changed by Phase 4" note gets change 1 too.
2. **No save-status string.** `TH2FileSaveStatus` is never shown as text. `textHasProblems` shows the "can't apply" banner, `cancelled` shows nothing (Phase 4 plan, §3 change 10). Step 1 confirms that Save All reports nothing new for these two statuses; if it does show a status text, add the string then.
3. **The review also fixes two older strings**: `th2ElementTreeBrokenFile` (Phase 5 made it wrong) and the PT `th2ActiveScrapCantBeHiddenTooltip` (§2.1).
4. **The shortcut page's Save As row and search list are corrected** (§2.3).
5. **The help also covers** `Ctrl+F` in text mode, the disabled tree edits in the element tree section's _Undo_ bullet, and that closing or reloading a tab discards an unsaved fix without asking, as for canvas edits (Phase 5 plan, §7 risk 2).
6. **The CHANGELOG's duplicated `* Changes:` heading is merged.**

## 4. Design

### 4.1 String review

For each key in §2.1, in EN and PT:

- It says what the user sees and can do, in the help's terms: _text mode_ / _modo texto_, _canvas_, _Edit as text_ / _Editar como texto_, _Discard text changes_ / _Descartar alterações do texto_, _scrap_ / _croqui_.
- Button labels and the tooltips naming them match (`th2TextDiscardChangesButton` and `th2TextEditorDiscardTooltip`; `th2BrokenFileEditAsText` and its tooltip).
- Placeholders are the same in both locales, and no text is in all caps (coding rules).
- Diagnostics are short phrases without a final period, as the existing ones; messages and banners are sentences.

New text:

- `th2ElementTreeBrokenFile`: EN "Broken file: fix it with Edit as text, or outside Mapiah and reload". PT "Arquivo com problemas: corrija-o com Editar como texto, ou fora do Mapiah e recarregue".
- `th2ActiveScrapCantBeHiddenTooltip` PT: "O croqui ativo não pode ser ocultado".

Any other wording change found in the review is listed in the implementation notes. Run `flutter gen-l10n` after the `.arb` edits.

### 4.2 Help: new "Text mode" section

A new `## Text mode` / `## Modo texto` section right after _Broken files_ / _Arquivos com problemas_, with an index entry in the same place in both locales. Short paragraphs or bullets, in this order:

1. **Switching** (§3.1). The _Text_ button in the top right corner, or `F2`, shows the file as Therion source; the text view's _Canvas_ button, or `F2`, goes back. The canvas buttons, the last-used chips and the status bar are hidden in text mode. Switching to a tab in text mode puts the focus in the text. If an image is being inserted, the switch waits for it. A file with a carriage return without a line feed can't be opened in text mode; normalize its line endings in another editor and reload.
2. **Selection** (§3.2, §3.3). Entering puts the cursor on the first selected element, in file order. Leaving selects the element on the cursor's line: a point, line or area; a line point opens _Line edit_ with that point selected; a scrap line makes it active; a file-level line clears the selection. The canvas is centered on the selection without zooming.
3. **Applying** (§3.4). Leaving or saving with changed text checks it and, if it has no problems, applies it as one undo step. With problems, nothing is applied, the lines are marked and the banner offers _Keep editing_ and _Discard text changes_. Text that the file's encoding can't hold, text Mapiah can't read and duplicate IDs are problems too. _Discard text changes_ (banner or toolbar) drops the edits and returns to the canvas with the file unchanged.
4. **Markers while editing** (§4.12, §4.16). Information markers show lines Save will rewrite or drop (duplicate line points, lines with fewer than two points, areas without a border), settings that move up into the settings section (the marker names the line), and added lines or line endings. They don't block the apply.
5. **Undo** (§3.5). Before the first text edit, `Ctrl+Z` and `Ctrl+Shift+Z` undo and redo canvas edits, and the text follows. From the first text edit on, they act on the text only, and canvas edits can't be reached until text mode ends. Typing never deletes canvas history. Each apply is one canvas undo step.
6. **Saving** (§3.6). Save checks and applies the text first; text with problems is never written. After saving, the text shows exactly what was written, and its text history starts again. Save As checks the text before the file dialog opens and applies it after a name is chosen; cancelling changes nothing, and the text can't be edited while the dialog is open. If the text editor can't be reopened after a save, Mapiah returns to the canvas with a message; nothing is lost and `F2` opens it again (§3 change 1).
7. **Settings section** (§4.16). Comments and empty lines between the settings at the top of the file are kept. Settings found later in the file move up into the settings section, before its trailing empty lines. Ordinary Save on the canvas follows the same rule (cross-reference _Save_).
8. **The project tree in text mode** (§3.8, §3.9). A click or right-click on a row moves the text cursor to that element or scrap, following it through edits, and doesn't change the canvas selection or the active scrap. Drag and drop, drawing order, _Move to scrap_, Cut, Duplicate, Delete, _Add scrap_, _Scrap options_ and _Properties_ are disabled; go back to the canvas to use them. The encoding is changed on the `encoding` line. Copy is offered on point, line and area rows too, and copies TH2 source that can be pasted into the text; IDs are copied as written, so pasting into the same file gives duplicate IDs to fix. Scrap visibility works as on the canvas. While Mapiah is applying or saving, tree clicks are ignored.
9. **Find** (§2.3). `Ctrl+F` finds and replaces in the text, as in `thconfig` and `.th` tabs. Multi-file search doesn't include `.th2` files.

### 4.3 Help: changes to existing sections

- **Index**: the new entry (§4.2).
- **Top right corner**: a _Text_ item: "shows the file as text (see [Text mode](#text-mode)). (F2)". No image unless the button's icon already exists in `assets/help/images/`.
- **Element tree**, _Undo_ bullet: "Tree edits are disabled in text mode (see [Text mode](#text-mode))."
- **Broken files**: replace "Mapiah cannot save it … outside Mapiah" with: the canvas is unavailable, and the file can be fixed with _Edit as text_ (or `F2`) on its page, or in another editor and reloaded. Then:
  - _Edit as text_ shows the file's text as it is on disk, with the problems marked on their lines and the cursor on the first one. A file that can't be read as text, or isn't valid in its encoding, can't be opened this way; the message says what to fix.
  - Once the text has no problems, applying it (leaving text mode or saving) makes the canvas available. This first apply is not an undo step: undo can't bring back the broken file. The file is unsaved until saved; closing or reloading the tab discards the fix without asking, as for canvas edits (§3 change 5). Reload brings back the file from disk.
  - In one sentence (Phase 5 plan, §3 change 12): leaving text mode with text that fixes the file shows the canvas, with edited broken text shows the "can't apply" banner, and with untouched broken text returns to the broken-file page. While the file is broken, the text view's button says _Leave text mode_.
  - The tree bullet's "must be fixed outside Mapiah" follows the new `th2ElementTreeBrokenFile`.
  - _Running Therion_: add that a fix applied in text mode but not saved still counts as broken, because Therion reads the file on disk, and the warning marks it "(fix not saved)". The warning only covers loaded files, so after a Save As of a fix to a new name, the original file, still broken on disk, can break the run without a warning.
- **Save / Original file format**: one bullet for the settings-section rule of §4.2 item 7.
- **Scrap visibility**: replace "Hiding the active scrap activates the nearest visible one" with: the active scrap can't be hidden; its eye icon is disabled until another scrap is made active, and activating a hidden scrap shows it. In text mode, tree clicks only move the text cursor; they don't activate a scrap.

PT mirrors EN in content; anchors follow the PT headings (`#modo-texto`).

### 4.4 Keyboard shortcuts

- New row, alphabetical: EN "Switch between canvas and text mode (`.th2`)" | `F2`, placed under _S_; PT "Alternar entre canvas e modo texto (`.th2`)" | `F2`, under _A_. The column widths of the neighbor rows are kept.
- Save As row: EN "Save file as" | `Ctrl+Shift+S`, PT likewise, since it now works in every tab type.
- _Text file search_: `Ctrl+F` also works in a `.th2` tab's text mode; multi-file search still never searches `.th2` files.
- In text mode, `Ctrl+Z`/`Ctrl+Shift+Z` follow §4.2 item 5: one sentence under the table, not a new row.

### 4.5 CHANGELOG

Under _1.0.2 - not yet released_:

- **New features**: one entry, referencing #38: a `.th2` tab can be edited as Therion source in text mode (_Text_ button or `F2`), with syntax highlighting, folding, find and replace, and problem markers; the selection follows the cursor both ways; leaving or saving applies the text as one undo step, and text with problems is never applied or saved; the project tree moves the text cursor and its Copy gives pasteable source; a broken file can be fixed with _Edit as text_. List the tests the feature adds that no other entry lists yet (`t3976`–`t3984`, `t3987`, `t3988`, `t3990`).
- **Changes**: the Phase 1 Save entry already says what §4.16 does and stays as it is. Add: the active scrap can no longer be hidden, and activating a hidden scrap shows it (§4.14). Merge the duplicated `* Changes:` heading.
- **Infrastructure maintenance**: one entry for the Phase 6 plan, as earlier phases did.

## 5. Implementation sequence

Each step leaves `flutter analyze` clean and `flutter test` green (help pages are bundled assets, so they aren't doc-only). Commit only when the user asks. Do not run `dart format`.

1. **Strings (§4.1).** Review the keys, apply §4.1's changes, `flutter gen-l10n`. Confirm §3 change 2 in `th_project_controller.dart`'s Save All reporting.
2. **Help (§4.2, §4.3)**, EN then PT.
3. **Keyboard shortcuts (§4.4)**, EN and PT.
4. **Test (§6).**
5. **CHANGELOG (§4.5).**
6. **Parent plan update.** In the parent's Phase 6 entry, link this plan and list §3's changes, and add change 1 to the "Changed by Phase 4" note of §3.6. Mark Phase 6 implemented, with any implementation notes, here and in the parent. Run the whole suite.

## 6. Verification

New `test/t4000_th2_text_editing_documentation_localization_test.dart`, in the style of `t3932`:

- EN/PT key parity, and every key of §2.1 present and non-empty in both generated localizations; placeholder strings render their arguments (`th2TextDiagnosticUnencodableCharacter('ISO8859-1')`, `th2TextDiagnosticMovedSetting(3)`, `th2BrokenFileTextInvalidEncodingMessage`, `mapiahTherionRunBrokenFileUnsavedFix`).
- `th2ElementTreeBrokenFile` names _Edit as text_ in both locales; the PT `th2ActiveScrapCantBeHiddenTooltip` says "croqui".
- Both help pages have the text-mode heading and its index link, mention `F2` and _Edit as text_, and no longer contain "Hiding the active scrap activates" / "Ao ocultar o croqui ativo", "Mapiah cannot save it" or their PT forms.
- Both shortcut pages have an `F2` row, and its table rows stay in alphabetical order around it (the row before and after compare in order, case-insensitively).

Existing tests: the whole suite; `t3940` and the tree tests use the localized strings through `AppLocalizations`, so §4.1's changes shouldn't break them. If one compares literal text, update it.

Manual check: `scripts/task_run.sh feat_38_th2_text_editing run`, open the help (F1) in EN and PT, follow the new index links, and hover the eye icon of the active scrap.

## 7. Acceptance and risks

Accepted when every parent Phase 6 item is either done or recorded in §3 as no longer applying, §6's test passes with the full suite, and the help matches what the app does.

1. **Help drifting from behavior.** The help describes details that the Phase 4 and 5 plans changed from the parent (dropped requests, the locked buffer during Save As, the regeneration exit). Write it from those plans and the code, not from the parent's §3 alone.
2. **PT anchors.** Markdown anchors are derived from headings with accents; the test only checks that the link exists, so follow the link once in the manual check.
