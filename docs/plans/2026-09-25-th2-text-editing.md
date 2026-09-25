<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing Mode with Selection Synchronization: Implementation Plan

**Date:** 2026-09-25
**Status:** Proposed. Checked against the codebase on 2026-09-25 (`main` at `0e0ca067`). Revised the same day with these decisions:

- text edits become **canvas** undo steps line by line, each one closed when the cursor leaves the edited line, so the same line can give several steps in one session (§4.6);
- **inside text mode**, undo and redo work as in the `thconfig`/`.th` editor, through the `TextField`'s own history (§3.5);
- redo is **`Ctrl+Shift+Z` everywhere**. The canvas no longer uses `Ctrl+Y`, and the text editor accepts both Ctrl and Cmd. This change was made on its own, ahead of this plan (§2.7);
- text that doesn't parse is **never saved** (§3.6);
- a selected line point **round-trips** between the two views (§3.2, §3.3);
- the mode toggle uses **F2** instead of `Ctrl+E` (§3.1).

**Issue:** [#38: Simplify object options entry by allowing user to type without clicking each option](https://github.com/rsevero/mapiah/issues/38)

## 1. Overview and Objectives

Issue #38 asks for a quicker way to enter and review element options than clicking through one option dialog at a time. It points to XTherion, where options are typed as text. This plan's answer is a **text mode for `.th2` tabs**. The same tab switches between the graphical canvas and a syntax-highlighted text view of the whole file. The user can type or change any command, option or coordinate, see every option of every element at once, and then return to the canvas.

The two views are **synchronized at each switch**, not while typing:

- **Graphical → text:** the text is generated from the current model, and is exactly what Save would write. If elements are selected, the text scrolls to the **first selected element in file order** (the one nearest the top of the file), and the cursor is placed on it. A selected line point counts as an element here.
- **Text → graphical:** if the text changed, each changed line is applied to the model as **its own undoable edit**. Elements on unchanged lines are left untouched. The element on the cursor's line is then **selected on the canvas**, and its scrap becomes the active scrap. If the cursor is on a line point, the canvas opens in _Line edit_ mode with that point selected.

### Key objectives

1. **Text mode per `.th2` tab.** A toggle button and `F2` switch the active tab between canvas and text. Each tab remembers its own mode.
2. **Highlighting.** TH2 commands, options, numbers, strings, comments, multiline `comment … endcomment` blocks and `##XTHERION##`/`##MAPIAH##` settings are colored. `scrap`, `line`, `area` and `comment` blocks can be folded.
3. **Lossless generation.** The text shown on entering text mode is exactly the output of the save path (`TH2FileWriter` with `includeEmptyLines: true, useOriginalRepresentation: true`). Unchanged lines keep their original formatting.
4. **Graphical → text selection.** The first selected element or line point in file order decides the scroll position and the cursor line.
5. **Text → graphical selection.** The element owning the cursor's line is selected, as if clicked in the element tree. A line point opens _Line edit_ mode with that point selected.
6. **Line-by-line undo on the canvas.** A canvas undo step is closed each time the cursor leaves a line it changed (§4.6). Each step is one command on the file's undo stack, in the order the edits were made. Editing a line, leaving it and returning to edit it again gives two steps. Inside text mode, `Ctrl+Z`/`Ctrl+Shift+Z` behave as in the `thconfig`/`.th` editor (§3.5).
7. **Safe apply.** Text that doesn't parse cleanly is never applied and never saved. The tab stays in text mode, and each problem is marked at its line.
8. **Stable identity.** Unchanged elements keep their MPIDs, so their selection, hidden state and the element tree's collapsed scraps survive a text edit.
9. **Save, dirty state and projects.** Unsaved text edits count as unsaved changes everywhere: the Save button, the project tree's dirty dot, Save All and the unsaved-changes guard.
10. **Broken files become fixable in Mapiah.** A broken file's tab can open its **raw disk content** in text mode. Once fixed, it can be applied and saved.
11. **Complete integration.** EN/PT localization, help pages, keyboard shortcuts and CHANGELOG. Controller, parser, writer, diff and widget tests. `flutter analyze` and `flutter test` stay green.

### Non-goals (this plan)

- **Live synchronization while typing.** The canvas is not updated on every keystroke. Syncing happens at the mode switch and on Save (§3.6).
- **Split view** (canvas and text side by side). The design leaves room for it (§4.1), but it is not built here.
- **An option-entry box on the canvas** (the literal proposal in #38). Text mode covers the need. A per-element text box can be a later follow-up that reuses this plan's parser and apply path.
- **Autocompletion or option validation while typing.** Validation is the parser's, at apply time.
- **Per-keystroke undo on the canvas.** Keystrokes on one line, before the cursor leaves it, are one canvas undo step (§3.5).
- **A custom undo for the text editor.** TH2 text mode keeps the undo that `thconfig`/`.th` tabs already use (§3.5).
- **Text editing of files that are not `.th2`.** `thconfig`/`.th` files already have their own text tabs.

## 2. Grounding: Current State

### 2.1 Text editor for `thconfig`/`.th` files

- `THTextEditorWidget` (`lib/src/widgets/th_text_editor_widget.dart`, 928 lines) is a self-built editor with no code-editor dependency. It has a line-number gutter, a `TextField` with a syntax-highlighting overlay, diagnostic line markers, folding, and a find/replace bar.
- It takes a concrete `THTextEditorController` (`lib/src/controllers/th_text_editor_controller.dart`). It uses only these members: `content`, `setContent`, `isDirty`, `cursorLine`, `setCursorPosition`, `pendingScrollToLine`/`clearPendingScrollToLine`, `pendingSelectionRange`/`clearPendingSelectionRange`, `diagnostics`, `textEditorFocusNode`, `save`, `revert`, and the find members (`findQuery`, `replaceQuery`, `findCaseSensitive`, `findMatches`, `activeMatchIndex`, `isFindBarVisible`, `openFindBar`, `closeFindBar`, `findNext`, `findPrevious`, `replaceActiveMatch`, `replaceAllMatches`, `setFindQuery`, `setReplaceQuery`, `setFindCaseSensitive`).
- `THTextEditorController` is bound to `THProjectController`. It owns a project epoch/root identity, calls `registerTextContentChange` and a debounced `reparseFile`, and saves through the project. None of that applies to a `.th2` file, whose model is owned by `TH2FileEditController`.
- The widget listens to its `TextEditingController` (`_onTextEditingChanged`, `:75`) and relies on the `TextField`'s built-in undo history. That history records a step after a 500 ms pause in typing. Programmatic changes (auto-indent, block indent, Replace, Replace All, Revert) go into it too. Its shortcut map binds `Ctrl+Z`/`Cmd+Z` to `UndoTextIntent` and `Ctrl+Shift+Z`/`Cmd+Shift+Z` to `RedoTextIntent`, so both modifier keys work on every platform (§2.7).
- `diagnostics` is `List<THProjectParseError>`. The widget renders them in `_buildDiagnosticBackground` (`:749-783`) and `THTextEditorDiagnosticMarkerWidget`.
- `tokenizeTherionText` (`lib/src/auxiliary/th_text_editor_syntax_highlighter.dart`) is a stateless, per-line lexer. Its keyword set is for `thconfig`/`.th` (`survey`, `centreline`, `map`, `scrap`, `layout`, `input`, …). It has no `point`, `line`, `area`, `endline`, `endarea`, `comment`/`endcomment`. Anything from `#` to the end of the line is a comment, so `##XTHERION##` settings would be colored as comments. It keeps no state across lines, so it can't color a multiline `comment … endcomment` block.
- `buildFoldRegions` (`lib/src/auxiliary/th_text_editor_fold_aux.dart:30-34`) folds `survey`, `centreline`, `map`, `scrap` and `layout`. `line`, `area` and `comment` are not included.

### 2.2 Tabs

- `MPGeneralController` keeps `_openFileOrder` (filenames) and chooses the controller type from the filename with `isTH2Tab(filename)` (`mp_general_controller.dart:32-34`). A `.th2` tab always maps to one `TH2FileEditController`.
- `TH2FileTabsPage._buildTabContentWidget` (`lib/src/pages/th2_file_tabs_page.dart:829-880`) returns `THTextEditorTabBodyWidget` for text tabs and `TH2FileEditBodyWidget` for `.th2` tabs. `TH2FileEditBodyWidget` shows `TH2BrokenFileBodyWidget` when `controller.isBroken` (`th2_file_edit_body_widget.dart:~84`).
- The app bar's Save/Save As buttons and `_saveActiveTab` (`:1210-1242`) branch on `isTH2Tab`, and use `TH2FileEditController.enableSaveButton` as the TH2 dirty signal.

### 2.3 TH2 parser

- `TH2FileParser.parse(filename, {fileBytes, …, forceNewController})` (`th2_file_parser.dart:2983-3063`) looks up the target controller with `mpLocator.mpGeneralController.getTH2FileEditController(filename:, forceNewController:)` and fills **that controller's** `th2File` through 21 `elementEditController.executeAddElement(...)` calls. It cannot parse into a detached `TH2File` today.
- `_splitContents` (`:3316-3430`) produces `MPParseableLine`s with a 1-based `lineNumber`. A multi-line bracketed value is joined into one parseable line, which keeps the number of its first line. `_injectContents` sets `_currentLineNumber` before injecting each line (`:158`).
- Broken-file detection gives `TH2FileProblem`s, each with a `lineNumber` and `sourceLine` (`lib/src/mp_file_read_write/th2_file_problem.dart`). Some errors in `_parseErrors` (petitparser `Failure` messages) carry no line number.
- `TH2FileEditController._loadOnce` (`th2_file_edit_controller.dart:~770`) parses with `forceNewController: false` and `fileBytes: _th2File.fileBytes`. `_commitLoadResult` sets `_isBroken` when there are problems or errors.
- Parsed elements keep their source text in `originalLineInTH2File`, so writing them back with `useOriginalRepresentation: true` reproduces the parsed text.

### 2.4 TH2 writer

- `TH2FileWriter.serialize` builds the text by string concatenation, recursively through `serializeElement` and `_childrenAsString` (`th2_file_writer.dart:36-60, 232-309, 419-428`). It records no element-to-line information.
- Output is produced in the same order as the final text, but **not through one helper**. Most lines go through `_prepareLine(line, thElement)` (`:456`, which can wrap a long line into several) or `_prepareLineWithOriginalRepresentation(newText, thElement)` (`:123`). These build their chunk directly instead:
  - the synthesized `encoding` line (`:52`);
  - `_serializeEmptyLine` (`:143-149`);
  - `_serializeMultiLineCommmentContent` (`:151-160`);
  - `_serializeXTherionConfig`, `_serializeXTherionImageInsertConfig` and `_serializeMapiahImageInsertConfig` (`:~181-230`);
  - line-point option lines in `_linePointOptionsAsString` (`:535-562`), which are written for the **line segment** that owns them.
- An `originalLineInTH2File` can hold several lines.
- Saving uses `_encodedFileContents()` → `toBytes(_th2File, includeEmptyLines: true, useOriginalRepresentation: true)` (`th2_file_edit_controller.dart:1650-1659`). `toBytes` encodes with the file's encoding and line ending.

### 2.5 Model, commands and sub-controllers

- `TH2FileEditController._basicInitialization(file)` (`:671-718`) stores `_th2File` and creates about 20 sub-controllers. Many keep their own `TH2File _th2File` field (for example `MPUndoRedoController`, `TH2FileEditSelectionController`, `TH2FileEditCopyPasteController`, `TH2FileEditSearchController`, `TH2FileHideElementController`). **Replacing the `TH2File` object would leave them pointing at the old one.** All changes go through the existing element-level commands instead.
- Generic commands exist to build on. `MPAddElementCommand` (with `elementPositionInParent`, undo = `MPRemoveElementCommand`) and `MPRemoveElementCommand` (undo re-adds the removed element at its position, with its descendants). Type-specific add/remove commands exist for points, lines, areas, scraps, line segments, area border thIDs and empty lines. `MPMultipleElementsCommand` wraps several commands into **one** undo step. There is no generic "replace this element, keeping its MPID and children" command. `TH2File.substituteElement(newElement)` (`th2_file.dart:323`) does the replacement without undo.
- Elements have `copyWith(mpID:, parentMPID:, …)` (for example `THPoint.copyWith`, `th_point.dart:153`).
- Undo commands (`lib/src/commands/`) refer to elements by MPID. `enableSaveButton => !_isBroken && _hasUndo && !_th2File.isNewFile` (`:534`) is the TH2 dirty signal. `_actualSave` clears the undo/redo stack (`:1787-1794`).
- `TH2File.clear()` (`th2_file.dart:773-790`) resets the element map, children, thID registries and derived caches.
- A reaction mirrors `enableSaveButton` into `THProjectController.dirtyFilePaths` (`:1032-1049`). `THProjectController._saveTH2ProjectFile` (`th_project_controller.dart:~1535-1600`) skips a TH2 file whose `enableSaveButton` is false. `MPGeneralController.shouldKeepTablessTH2Controller` (`:181-202`) also uses it.

### 2.6 Selection and _Line edit_ mode

- `TH2FileEditSelectionController.mpSelectedElementsLogical` (`ObservableMap<int, MPSelectedElement>`) holds the selected points, lines and areas. `_selectedEndControlPoints` (`:113`) holds the selected line points in _Line edit_ mode, set with `setSelectedEndControlPoint(...)` (`:527`) and cleared with `clearSelectedEndControlPoints()` (`:540`). `selectedScrapMPIDs` holds selected scraps.
- The element tree selects an element with `controller.setActiveScrapByChildElement(element)` followed by `selectionController.setSelectedElements([element], setState: true)` (`th2_element_tree_row_widget.dart:518-533`). It leaves creation modes first with `stateController.onButtonPressed(MPButtonType.select)` (`:419-429`).
- A double-click enters _Line edit_ mode with `selectionController.setSelectedElements([parentLine])` followed by `stateController.setState(MPTH2FileEditStateType.editSingleLine)` (`mp_th2_file_edit_state_select_non_empty_selection.dart:250-261`).
- `requestZoomToFit(MPZoomToFitType.selection)` exists (`th2_file_edit_controller.dart:1501`). There is no "pan to show without zooming" helper.

### 2.7 Keyboard shortcuts

- The edit page uses only `F1` among the function keys (`th2_file_tabs_page.dart:1085`). Function keys have no default meaning in Flutter's text-editing shortcuts on any platform. `F2` is free.
- **Redo is `Ctrl+Shift+Z` everywhere.** This was changed on its own, ahead of this plan. The canvas key handler (`mp_th2_file_edit_state_key_down_mixin.dart`) maps `Ctrl/Cmd+Z` to undo and `Ctrl/Cmd+Shift+Z` to redo. `Ctrl+Y` no longer does anything. The text editor maps the same keys for both Ctrl and Cmd. The redo tooltip, the help pages and the shortcut tables say `Ctrl+Shift+Z`. It is covered by `test/t3956_redo_ctrl_shift_z_test.dart`.

## 3. User-Facing Behavior

### 3.1 Switching modes

- A **Text/Canvas toggle** is added to the top-right button group of a `.th2` tab, and bound to **`F2`** in both modes. The page-level shortcut map that already handles `F1` gets `F2`, so the key works whether the canvas or the text field has focus.
- **Entering text mode** first leaves any creation or operation state, as the element tree does (§2.6), except _Line edit_ mode, whose selected line points are used for the cursor (§3.2). An unfinished line or area being drawn is ended the same way `Esc` ends it. Open overlay windows are closed.
- **Leaving text mode** with unchanged text only maps the cursor to a selection (§3.3). Changed text is parsed and applied first (§3.4).
- A **Discard text changes** action (a button in the text view, and a choice in the "can't apply" message) drops the text edits and returns to the canvas with the model untouched.

### 3.2 Graphical → text

1. Generate the text with the save path (§4.2) and record, for each element, the lines it occupies (§4.3).
2. Collect the selected MPIDs: the selected points, lines and areas, the line segments of any selected line points, and selected scraps.
3. If that set is empty, keep the text view's last scroll position for this tab, or the top of the file the first time. In _Line edit_ mode with no line point selected, use the line being edited.
4. Otherwise, take the **smallest start line** among them. That is the first selected element or line point in file order, whatever order they were selected in. Scroll it into view, and put the cursor at its first non-blank column. Nothing is selected in the text.

### 3.3 Text → graphical (selection)

The cursor line is mapped to an element (§4.4), and then:

| Cursor is on | Result on the canvas |
|---|---|
| a `point` line, or a wrapped continuation of one | the point is selected; its scrap becomes active |
| a `line` header line or `endline` | the line is selected; its scrap becomes active |
| a line point, or one of that point's option lines (`smooth`, `subtype`, …) | _Line edit_ mode opens on the owning line with **that line point selected**; its scrap becomes active |
| an `area` header line, an area option line, a border reference or `endarea` | the area is selected; its scrap becomes active |
| `scrap`, `endscrap`, or an empty line or comment inside a scrap | that scrap becomes active; the selection is cleared |
| anything at file level (`encoding`, settings, comments, empty lines) | the selection is cleared; the active scrap is kept if it still exists, or else the first scrap is used |

Together with §3.2, this makes a selected line point **round-trip**. Going to text puts the cursor on its line, and coming back with the cursor still there selects it again in _Line edit_ mode.

If the selection is outside the visible canvas area, the canvas is centered on it at the current zoom (§4.9). Nothing is zoomed.

### 3.4 Text → graphical (apply)

- If the text is unchanged since entering text mode, nothing is parsed or applied. The line map from §3.2 is used in reverse.
- If the text changed, the whole new text is parsed into a detached model first (§4.5).
  - **Any error or problem:** nothing is applied. The tab stays in text mode. Each `TH2FileProblem` is marked at its line, and errors without a line number are listed in a message above the editor. The message offers _Keep editing_ and _Discard text changes_.
  - **No errors and no problems:** each step recorded during the session (§4.6) becomes one command on the undo stack, applied in the order the edits were made. The canvas, the element tree and the dirty state update. The cursor line is then mapped on the updated model (§4.4).

### 3.5 Undo

- **In text mode**, undo and redo work exactly as in the `thconfig`/`.th` editor: `Ctrl+Z` and `Ctrl+Shift+Z` go through the `TextField`'s own history, which groups typing by 500 ms pauses (§2.1). They reach back only to the start of the text session. The edits made before it are undone on the canvas.
- **On the canvas**, the text session gives undo steps that are closed **when the cursor leaves a line it changed**, whether by arrow keys, a click, `Enter` or `Tab`. All the changes on that line until then are one step. Coming back to the same line and changing it again starts a new step. An edit that itself spans several lines (a multi-line paste, deleting a selection across lines, a replace) is one step. An undo or redo inside text mode is recorded like any other edit: it closes a step right after it runs. Leaving text mode, saving and `F2` close the step in progress.
- The steps are commands on the file's undo stack, in the order they were made, so the last text edit is undone first. The step's description names the line, for example "Text edit (line 42)". Older, canvas-made steps below them stay valid, because unchanged elements keep their MPIDs.
- A step that leaves the text unparseable, such as a new `line` header typed before its `endline`, can't be applied to the model on its own. It is joined with the following steps until the text parses again (§4.6).

### 3.6 Save in text mode

Save (button, `Ctrl+S`, Save All) first applies the text as in §3.4, then saves through the normal TH2 path. **If the text doesn't parse, nothing is written**, and the problems are shown as in §3.4. Mapiah never writes a `.th2` file it can't read back. The tab stays in text mode after a successful save, and the text is regenerated from the saved model. The cursor line is kept.

### 3.7 Broken files

The broken-file tab body (`TH2BrokenFileBodyWidget`) gets an **Edit as text** button. It opens text mode with the **raw file content from disk**, decoded with the file's encoding. It can't use the writer, because a broken model is missing the lines the parser dropped. The problem list is shown as line markers. Applying or saving works as in §3.4 and §3.6. Once the text parses cleanly, the controller stops being broken, and the canvas becomes available.

A broken model can't be compared line by line with the fixed text, because the model doesn't match the disk text. So the first apply of a broken file is **one** whole-file step (§4.7). After that, the file is valid, and later text sessions use line steps (§4.6).

## 4. Design Decisions

### 4.1 Mode lives on `TH2FileEditController`, text state on a new `TH2TextEditController`

- `TH2FileEditController` gains `@observable TH2EditMode editMode` (`canvas`, `text`) and `@readonly TH2TextEditController? _textEditController`. The text controller is created when text mode is first entered, and dropped when the tab's controller is disposed.
- `TH2FileEditBodyWidget` shows `TH2TextEditBodyWidget` when `editMode == text`, and otherwise keeps today's canvas/broken logic. The mode is per tab, because it belongs to the tab's controller. It survives tab switches, and project-tree clicks don't reset it.
- A split view could later show both widgets. The single `editMode` value would then become two visibility flags.

### 4.2 The text source

- **Valid file:** a new `TH2FileEditController.serializeForTextMode()` returns `TH2FileWriter().serializeWithLineMap(_th2File, includeEmptyLines: true, useOriginalRepresentation: true)`, with the line ending normalized to `\n`. It shares its writer options with `_encodedFileContents()`, so the two can't drift apart. `TH2TextEditController.initialContent` keeps this text as the first checkpoint (§4.6).
- **Broken file:** the raw bytes from disk (or `_th2File.fileBytes` when it's set), decoded with the parser's encoding detection, which becomes a public static helper.
- On apply and save, the text is converted back to the file's line ending. It is encoded with the encoding its own `encoding` line names, as the parser already does on load.

### 4.3 Writer line map (model MPID → line range)

`serializeWithLineMap` returns `(String text, TH2TextLineMap lineMap)`. It uses a **line ledger**:

- A single private `_emit(THElement element, String chunk)` returns `chunk` and, in ledger mode, appends `(element.mpID, lineCount)` to the ledger. `lineCount` is the number of line endings in the chunk. This counts wrapped long lines and multi-line original representations correctly.
- **Every** output site in §2.4 returns through `_emit`: `_prepareLine`, `_prepareLineWithOriginalRepresentation`, the synthesized `encoding` line (attributed to the file), `_serializeEmptyLine`, `_serializeMultiLineCommmentContent`, the three settings serializers, and each option line in `_linePointOptionsAsString` (attributed to its line segment).
- Output order equals text order, so each ledger entry's start line is the sum of the `lineCount`s before it. An element's **own lines** are its ledger entries. Its **range** runs from its first own line to the last line of its last descendant.
- `serialize` and `toBytes` keep their signatures and their exact output. Ledger mode is off by default.
- A test checks, for every fixture in `test/auxiliary/*.th2`, that the ledger's total line count equals the number of lines in the returned text, and that `serialize`'s output is unchanged byte for byte. An output site that bypasses `_emit` makes the test fail.

`TH2TextLineMap` (new, `lib/src/auxiliary/th2_text_line_map.dart`) keeps each element's own lines and range, and a sorted `line → owning MPID` array for reverse lookup. Line numbers are 0-based here to match the editor's `cursorLine`. Conversion from the parser's 1-based numbers happens in one place.

### 4.4 Parser line map and ownership resolution

- `TH2FileParser` gains `Map<int, int> elementStartLines` (MPID → 1-based `_currentLineNumber`). It is filled by a private `_addElement(...)` helper that wraps the 21 `executeAddElement` calls. With the continuation lines of multi-line values, it gives the same own-lines information as the writer's ledger, and builds a `TH2TextLineMap` for a detached parse (§4.5).
- `TH2TextElementLocator` (new, pure, `lib/src/auxiliary/th2_text_element_locator.dart`) turns a line and a `TH2TextLineMap` into a `TH2TextLocation`, following §3.3:
  1. Find the element that owns the line (the reverse array).
  2. If it's a line segment, or a line-point option line owned by one, return `selectLinePoint(lineMPID, lineSegmentMPID, scrapMPID)`.
  3. Otherwise, walk up `parentMPID` until reaching a `THPoint`, `THLine`, `THArea` or `THScrap`, or the file.
  4. Return `selectElement(mpID, scrapMPID)`, `activateScrap(scrapMPID)` or `fileLevel`.
- The locator is pure and gets its own unit tests. `TH2FileEditController.applyTextLocation(location)` carries the result out on the canvas. It uses the tree's single-tap sequence for `selectElement`, and the double-click sequence plus `setSelectedEndControlPoint` for `selectLinePoint` (§2.6).

### 4.5 Detached parse

`TH2FileParser.parse` gains an optional `TH2FileEditController? targetController`. When it's given, the parser uses that controller instead of looking one up in `MPGeneralController`. Text mode creates a **scratch controller**, `TH2FileEditControllerBase.createForDetachedParse(filename, th2FileMPID)`. It is never registered and never gets a tab. Its `TH2File` uses the real file's MPID, so top-level `parentMPID`s already point at the real file. MPIDs come from the global counter (`nextMPIDForElements`), so they can't collide with the live model. The scratch controller is disposed after the apply.

Each closed step's text gets its own detached parse (§4.6). The parse is both the validation and the source of new elements for that step.

### 4.6 Line checkpoints, units and steps

**1. Checkpoints.** `TH2TextEditController` keeps a list of `TH2TextCheckpoint`s (text, cursor line, and the line range changed since the previous checkpoint) Checkpoint 0 is `initialContent`. It also keeps the line of the edit in progress, if any.

- A text change sets the line in progress if none is set.
- A cursor move to a different line, with the text different from the last checkpoint, **records a checkpoint**. Line numbers shift with inserted or deleted lines, so "a different line" is decided on the text after the change: `Enter` at the end of line 5 closes the edit of line 5 when the cursor lands on line 6.
- An edit that spans lines (multi-line paste, cross-line delete, replace, replace all) records a checkpoint right after it, closing any edit in progress on another line first.
- Leaving text mode, saving, `F2`, and the find/replace actions record a checkpoint for the edit in progress.
- A checkpoint equal to the last one is not recorded.

Checkpoints are only used for the canvas steps. The editor's own undo stays the `TextField`'s history (§2.1). The widget's undo/redo bindings (§2.7) call the buffer's `onUndoRedoApplied()` after the `TextField` has run the undo or redo. The TH2 buffer then records a checkpoint, as for any edit that spans lines. The `thconfig` buffer ignores the call.

**2. Diff.** `MPLineDiffAux` (new, pure, `lib/src/auxiliary/mp_line_diff_aux.dart`) compares two consecutive checkpoints' texts line by line, using Myers' O(ND) algorithm. No package is needed. It returns the matched (unchanged) line pairs and the hunks between them. Inside a hunk, lines are paired one to one as **modified** lines while both sides have lines left. The remainder are **inserted** or **deleted** lines. Consecutive checkpoints usually differ in one line, so this is fast.

**3. Parsing checkpoints.** Each checkpoint's text is parsed into a detached model (§4.5) once the user has stopped typing for `mpTH2TextCheckpointParseIdleMilliseconds`. The result (valid or not, problems, the detached model and its `TH2TextLineMap`) is cached on the checkpoint. So:
- the apply at the mode switch reuses the cached parses, and only parses checkpoints that aren't cached yet;
- the problem markers in the editor update as the user works, not only when leaving text mode.

Cached models are dropped when their checkpoint is dropped or the session ends. If more than `mpTH2TextMaxCachedCheckpointModels` are cached, the oldest models are dropped and parsed again at apply time. Their valid flag and problems are kept.

**4. Units.** Each changed line is turned into a **unit**, the smallest element that can be replaced on its own:

| Changed line (old side and/or new side) | Unit |
|---|---|
| a `point` line | the point |
| a line point or one of its option lines | the line segment |
| a `line`, `area` or `scrap` header line | the **header only**: the element is replaced keeping its MPID and its children |
| an area border reference | the `THAreaBorderTHID` |
| an empty line, comment line or setting | that element |
| `endline`, `endarea`, `endscrap`, `comment`/`endcomment`, or any change that adds or removes one of them | the smallest **whole block** (line, area, multiline comment or scrap) that contains the change on both sides; a change that moves scrap boundaries becomes the whole-file step (§4.7) |

For the pair of checkpoints *k−1 → k*, units are found through the **live** model's line map for deleted and modified lines, and through checkpoint *k*'s detached model for inserted and modified lines. The live model at that point is the result of the previous steps, and its line map comes from the check in item 7. Unchanged lines map old → new through the diff's matched pairs. The elements on them are **not touched**, so they keep their MPIDs.

**5. Steps.** Each pair of consecutive checkpoints is **one step**, containing all the units its diff touches. If checkpoint *k* doesn't parse, it is skipped: the pair *k−1 → k+1* is used instead, and so on until a checkpoint that parses. The last checkpoint is the final text, which must parse, or the apply is rejected (§3.4). Steps whose diffs cancel out (a line changed and then changed back) still apply, as two steps, because that is what the user did. The only exception is a session whose final text equals `initialContent`: nothing is applied (§3.4).

Every step replaces whole units between two valid texts, so the model is structurally valid after each step, in both undo and redo.

**6. Commands.** Each step is one command, or one `MPMultipleElementsCommand` when it has several parts (one undo step). It is built from:

- `MPRemoveElementCommand` for a removed unit (its undo re-adds it, descendants included);
- `MPAddElementCommand` for a new unit without children, with its position taken from the new text. A new unit with children uses the existing type-specific commands, which already add the children: `MPAddLineCommand` (`newLine`, `lineChildren`), `MPAddAreaCommand` and `MPAddScrapCommand` (`addScrapChildrenCommand`);
- a new `MPReplaceElementCommand(oldElement, newElement)` for a modified unit. It uses `TH2File.substituteElement` with `newElement.copyWith(mpID: old.mpID, parentMPID: old.parentMPID)`, keeping the old element's children. Its undo substitutes the old element back. It also serves header-only changes.

Each step has the description "Text edit (line N)", where N is the first changed line of the step in the checkpoint it leads to. Steps are executed in checkpoint order through `MPUndoRedoController`, so `enableSaveButton`, the dirty dot and Save All follow without changes.

**7. Check.** After **each** step, `serializeWithLineMap` on the live model must return exactly that checkpoint's text. Parsed elements carry their source text (§2.3), so this holds whenever the step is correct. The line map it returns is the one the next step uses (item 4). A mismatch is a bug. It is logged with both texts, and the steps applied so far are undone and replaced by one whole-file step (§4.7) so the user's text is never lost. Tests cover the same check over the fixture set.

**8. After applying**, the controller:
- drops selection entries, hidden elements and selected scraps whose MPIDs no longer exist;
- resets the selectable elements and refreshes snap targets;
- calls `bumpStructureRevision()` so the element tree and canvas rebuild;
- maps the cursor with the live model's line map from the last check (§4.4);
- ends the session: the checkpoints and their cached models are dropped, and the next text session starts from newly generated text.

### 4.7 Whole-file step (fallback)

`MPReplaceTH2FileContentsCommand` (new) holds two deep snapshots, `before` and `after` (`TH2File.toMap()` maps). It applies one with `TH2File.replaceContentsFrom(TH2File.fromMap(...))`. That new method clears this file's contents without touching `filename`, `mpID` or `isNewFile`, adopts the source's elements, children, thID registries, encoding and line ending, and rebuilds the derived caches with the existing `_updateSupportMaps` path. The live `TH2File` object never changes, so the sub-controllers' references (§2.5) stay valid. Undo restores `before` with its original MPIDs, so older commands stay valid.

It is used only when line steps can't be: for the first apply of a broken file (§3.7), for a step that moves scrap boundaries (§4.6), and as the recovery path for a failed check (§4.6). After it runs, `_isBroken`/`_problems` are cleared if the file was broken.

**Rejected alternative:** reusing Reload (`MPGeneralController.reloadTH2File`) to build a new controller from the text. It throws away the undo history and all per-controller view state (zoom, active scrap, overlays), and the text edits could not be undone.

### 4.8 Dirty state and saving

- `TH2FileEditController` gains `@computed bool hasUnsavedChanges => enableSaveButton || (_textEditController?.isDirty ?? false)`.
- `hasUnsavedChanges` replaces `enableSaveButton` as the **dirty** signal in the dirty-mirroring reaction (`:1032-1049`), in `shouldKeepTablessTH2Controller`, in `_saveTH2ProjectFile`'s "already saved" check, and in the app bar's Save button state and `_saveActiveTab`. `enableSaveButton` keeps its current meaning, "the model has unsaved changes".
- `saveTH2File()` in text mode runs the apply first and returns a result: `saved` or `textHasProblems`. `_saveTH2ProjectFile` maps `textHasProblems` to a new `TH2FileSaveStatus.textHasProblems`, so Save All reports the file as not saved instead of failing silently.
- A new file (`isNewFile`) in text mode: Save runs Save As, as it does today. Save As applies first, and is refused in the same way when the text doesn't parse.

### 4.9 Editor widget reuse

- Extract `THTextEditorBuffer`, an abstract class with the members listed in §2.1, plus `List<THTextEditorDiagnostic> get diagnostics`, `THTextEditorLanguage get language`, and the notifications `onCursorLineChanged(int line)` and `onUndoRedoApplied()` (§4.6). `THTextEditorController` implements them as no-ops. `THTextEditorController` and the new `TH2TextEditController` implement it. `THTextEditorWidget` takes `THTextEditorBuffer`.
- The find/replace state and logic move from `THTextEditorController` into a `THTextEditorFindMixin` used by both, so they behave the same.
- `THTextEditorDiagnostic` (line, message, severity) replaces the widget's direct use of `THProjectParseError`. `THTextEditorController` maps its project errors to it. `TH2TextEditController` maps `TH2FileProblem`s (with the localized category from `TH2FileProblemTextAux`) and line-less parser errors.
- `THTextEditorLanguage { therion, th2 }` chooses the tokenizer and fold keywords. `tokenizeTherionText(text, language:)` keeps its default, so current callers don't change.

### 4.10 TH2 highlighting and folding

- TH2 keywords: `encoding`, `scrap`, `endscrap`, `point`, `line`, `endline`, `area`, `endarea`, `comment`, `endcomment`. Option words that begin a line inside a `line` block (`smooth`, `subtype`, `orientation`, `l-size`, `size`, `mark`, `altitude`, `adjust`, `direction`, `gradient`, `height`, `border`, `reverse`, `visibility`, `place`, `clip`, `outline`, `close`, `id`) are colored as `option`.
- `##XTHERION##` and `##MAPIAH##` at the start of a line color the whole line as a new `THTextEditorTokenType.setting`, not as a comment.
- The TH2 tokenizer carries state across lines: the lines between `comment` and `endcomment` are colored as `comment`.
- Folds: `scrap`/`endscrap`, `line`/`endline`, `area`/`endarea`, `comment`/`endcomment`.
- Token colors come from the existing editor palette. One new color token is added for `setting`, for light and dark themes.

### 4.11 Centering the canvas without zooming

`TH2FileEditController.revealSelection()` (new) checks the selection's bounding box, or the selected line point, against the visible canvas rectangle. If it isn't fully visible, it moves `_canvasCenterX/Y` to its center, reusing the math in `_setCanvasCenterOnZoom` (`:1603`) but keeping the scale. Like `requestZoomToFit`, it waits for layout when the canvas hasn't been laid out yet, because it runs right after the body widget swaps back to the canvas.

## 5. Implementation Phases

Each phase ends with `flutter analyze` clean and `flutter test` green. New tests start at `t3960`.

### Phase 1: Line maps and locator (no UI)

- `TH2TextLineMap`, the writer's `_emit` ledger and `serializeWithLineMap` (§4.3).
- The parser's `elementStartLines` and the `_addElement` helper (§4.4).
- `TH2TextElementLocator` (§4.4).
- Tests:
  - `t3960`: for every fixture in `test/auxiliary/*.th2`, the ledger's line total matches the output, and `serialize`'s output is unchanged byte for byte.
  - `t3961`: own lines and ranges for points, lines, line segments with option lines, areas, border references, scraps, settings, empty lines, multiline comments, wrapped long lines and multi-line bracketed values.
  - `t3962`: the parser's map agrees with the writer's map on a round-tripped fixture (after matching MPIDs by position).
  - `t3963`: every row of the table in §3.3.

### Phase 2: Detached parse, diff and step apply

- `targetController` on `TH2FileParser.parse`, and `createForDetachedParse` (§4.5).
- `MPLineDiffAux` (§4.6).
- The unit and step builder, `MPReplaceElementCommand` with its factory entry, and the step description type and EN/PT description string (§4.6).
- `TH2File.replaceContentsFrom` and `MPReplaceTH2FileContentsCommand` (§4.7).
- `TH2FileEditController.applyTextSteps(List<TH2TextCheckpoint> checkpoints)`, which returns `applied(lineMap)` or `rejected(problems, errors)`, with the per-step check and cleanup from §4.6. The checkpoints here are built directly by the tests. Recording them from the editor comes in Phase 3.
- Tests:
  - `t3964`: a detached parse doesn't register or replace any controller in `MPGeneralController`.
  - `t3965`: `MPLineDiffAux` on insertions, deletions, modifications, mixed hunks, empty texts and identical texts.
  - `t3966`: three checkpoints give three undo steps, including two for the same line. Undoing them one by one gives back each checkpoint's text, and redo gives the final one. Older canvas-made commands still undo correctly afterwards.
  - `t3967`: unchanged elements keep their MPIDs. Changing a line's header keeps the line's MPID and its segments' MPIDs. Changing one line point replaces only that segment.
  - `t3968`: a checkpoint that doesn't parse (a `line` header without its `endline`) is joined with the next one into one step. A whole `line … endline` block pasted at once is one step. Moving an `endscrap` falls back to the whole-file step.
  - `t3969`: text with a problem or error is rejected, and the model is unchanged.
  - `t3970`: after every step in these tests, the live model serializes back to that checkpoint's text (§4.6 check).
  - `t3971`: performance guard on a large generated fixture with many checkpoints, with and without cached parses.

### Phase 3: Editor generalization and TH2 highlighting

- `THTextEditorBuffer`, `THTextEditorFindMixin`, `THTextEditorDiagnostic` and `THTextEditorLanguage` (§4.9). Refactor `THTextEditorController` and `THTextEditorWidget` onto them with no behavior change.
- The TH2 tokenizer and folds (§4.10).
- `TH2TextEditController` (MobX): `content`, `initialContent`, `isDirty` (`content != initialContent`), cursor, pending scroll/selection, diagnostics, find, the owning `TH2FileEditController`, and the checkpoints with their idle-time parsing and cache (§4.6). `save` and `revert` delegate to the owner (§3.6, discard).
- The cursor-line and undo/redo notifications in `THTextEditorWidget` (§4.6). The undo/redo bindings stay those added for `Ctrl+Shift+Z` (§2.7).
- Tests:
  - the existing text editor tests (`t3900`–`t3937`) pass unchanged;
  - `t3972`: TH2 tokens, including `##XTHERION##` lines, multiline comments, options and line-option words;
  - `t3973`: TH2 fold regions.
  - `t3982`: checkpoint recording: typing on one line and moving away records one checkpoint; returning to the line and typing again records another; `Enter`, a multi-line paste and Replace All each close a step; moving without changes records nothing.
  - `t3983`: an undo and a redo in TH2 text mode each record a checkpoint. `Ctrl+Z`/`Ctrl+Shift+Z` in text mode behave as in the `thconfig` editor, and the `thconfig` editor's undo is unchanged.

### Phase 4: Mode switching, synchronization and saving

- `editMode`, `enterTextMode()`, `leaveTextMode()`, `discardTextEdits()`, and `TH2TextEditBodyWidget` (§4.1). The toggle button and `F2` (§3.1).
- Graphical → text cursor placement (§3.2), and text → graphical selection, including _Line edit_ mode for line points, plus `revealSelection()` (§3.3, §4.4, §4.11).
- The "can't apply" message with _Keep editing_/_Discard text changes_ (§3.4).
- `hasUnsavedChanges`, and its adoption at the call sites in §4.8. Save and Save As in text mode, and `TH2FileSaveStatus.textHasProblems`.
- Tests (widget tests use the `TH2FileTabsPage` setup of `t3950`):
  - `t3974`: with two elements selected in reverse file order, text mode puts the cursor on the one nearer the top. In _Line edit_ mode, the cursor goes to the first selected line point.
  - `t3975`: returning with the cursor on each kind of line from §3.3 gives the listed result. A selected line point round-trips: canvas → text → canvas leaves the same point selected in _Line edit_ mode.
  - `t3976`: editing line 10, then line 20, then line 10 again, and returning to the canvas gives three undo steps. `Ctrl+Z` on the canvas undoes them in reverse order: the second edit of line 10, then line 20, then the first edit of line 10.
  - `t3977`: invalid text stays in text mode with markers. Discard returns with the model unchanged.
  - `t3978`: the dirty dot, Save, Save All and the unsaved-changes guard see text-only edits. Save with problems writes nothing and reports `textHasProblems`.
  - `t3979`: the mode is kept across tab switches. Tree clicks while in text mode move the cursor to the clicked element, using §3.2 with that element. `F2` toggles from both the canvas and the text field.

### Phase 5: Broken files

- _Edit as text_ on `TH2BrokenFileBodyWidget`, with the raw disk text source (§3.7, §4.2).
- The whole-file first apply, and clearing the broken state (§4.7).
- Tests:
  - `t3980`: a broken fixture opens in text mode with its problems marked at the right lines. Fixing and applying makes the canvas available. Saving writes the fixed text. The next text session uses line steps.
  - `t3981`: a broken file's text is never saved while problems remain.

### Phase 6: Documentation and localization

- EN/PT strings for the toggle tooltip, the discard action, the "can't apply" message, the step descriptions, the save status and _Edit as text_. Run `flutter gen-l10n`.
- Help: a new "Text mode" section in `th2_file_edit_page_help.md` (EN/PT), with an index entry, covering §3.1–§3.7. Update the "Top right corner" list and the "Broken files" section.
- Keyboard shortcuts: `F2` in `keyboard_shortcuts_edit.md` (EN/PT), in alphabetical order.
- CHANGELOG entry under the next release, referencing #38.

## 6. Risks and Open Questions

1. **Unit rules for unusual edits** (§4.6). The table covers the common cases. Unusual ones, such as splitting one line block into two or joining two points into one line, fall back to block steps or the whole-file step. They stay correct but give coarser undo. The `t3968` and `t3970` tests are where new cases are pinned down.
2. **References across steps.** An area's border references point at lines by thID. If the user adds a line and the area referencing it in one text session, undoing only the line's step leaves the area referring to a missing line. Mapiah already opens files in that state, so it is tolerated. The tree and canvas must not fail on it (checked in `t3966`).
3. **Diff pairing inside a hunk.** Pairing modified lines one to one inside a hunk can pair unrelated lines, for example after a large paste over several lines. The step stays correct, but it may replace more elements than needed. If it becomes a problem, pairing can prefer lines with the same first word (`point` with `point`).
5. **Parsing cost per checkpoint** (§4.6). Every checkpoint is parsed once, in idle time. For very large files this may be noticeable after each line change. The idle delay and the model cache limit are constants that can be tuned. `t3971` measures both.
6. **Different undo granularity in the two views.** Inside text mode, undo groups typing by 500 ms pauses. On the canvas, a step closes when the cursor leaves an edited line. Both are deliberate: the text editor matches the `thconfig`/`.th` editor, and the canvas follows the line rule.
4. **Memory of the whole-file step's snapshots** for very large files (§4.7). It is used rarely, and `t3971` covers the size.
