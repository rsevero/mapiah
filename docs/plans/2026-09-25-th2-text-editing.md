<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing Mode with Selection Synchronization: Implementation Plan

**Date:** 2026-09-25
**Status:** Proposed. Checked against the codebase on 2026-09-25 (`main` at `0e0ca067`).
**Issue:** [#38: Simplify object options entry by allowing user to type without clicking each option](https://github.com/rsevero/mapiah/issues/38)

## 1. Overview and Objectives

Issue #38 asks for a quicker way to enter and review element options than clicking through one option dialog at a time. It points to XTherion, where options are typed as text. This plan's answer is a **text mode for `.th2` tabs**. The same tab switches between the graphical canvas and a syntax-highlighted text view of the whole file. The user can type or change any command, option or coordinate, see every option of every element at once, and then return to the canvas.

The two views are **synchronized at each switch**, not while typing:

- **Graphical → text:** the text is generated from the current model, and is exactly what Save would write. If elements are selected, the text scrolls to the **first selected element in file order** (the one nearest the top of the file), and the cursor is placed on it.
- **Text → graphical:** if the text changed, it is parsed and replaces the model as **one undoable edit**. The element on the cursor's line is then **selected on the canvas**, and its scrap becomes the active scrap.

### Key objectives

1. **Text mode per `.th2` tab.** A toggle button and a keyboard shortcut switch the active tab between canvas and text. Each tab remembers its own mode.
2. **Highlighting.** TH2 commands, options, numbers, strings, comments, multiline `comment … endcomment` blocks and `##XTHERION##`/`##MAPIAH##` settings are colored. `scrap`, `line`, `area` and `comment` blocks can be folded.
3. **Lossless generation.** The text shown on entering text mode is exactly the output of the save path (`TH2FileWriter` with `includeEmptyLines: true, useOriginalRepresentation: true`). Unchanged lines keep their original formatting.
4. **Graphical → text selection.** The first selected element in file order decides the scroll position and the cursor line. This also covers selected line points in _Line edit_ mode.
5. **Text → graphical selection.** The element owning the cursor's line is selected, as if clicked in the element tree.
6. **Safe apply.** Text that doesn't parse cleanly is never applied. The tab stays in text mode, and each problem is marked at its line. Applying valid text is one command on the file's undo stack, so `Ctrl+Z` on the canvas restores the model as it was before the text edit.
7. **Save, dirty state and projects.** Unsaved text edits count as unsaved changes everywhere: the Save button, the project tree's dirty dot, Save All and the unsaved-changes guard.
8. **Broken files become fixable in Mapiah.** A broken file's tab can open its **raw disk content** in text mode. Once fixed, it can be applied and saved.
9. **Complete integration.** EN/PT localization, help pages, keyboard shortcuts and CHANGELOG. Controller, parser, writer and widget tests. `flutter analyze` and `flutter test` stay green.

### Non-goals (this plan)

- **Live synchronization while typing.** The canvas is not updated on every keystroke. Syncing happens at the mode switch (and on Save, §4.6).
- **Split view** (canvas and text side by side). The design leaves room for it (§4.1), but it is not built here.
- **An option-entry box on the canvas** (the literal proposal in #38). Text mode covers the need. A per-element text box can be a later follow-up that reuses this plan's parser and apply path.
- **Keeping element MPIDs across a text apply** (§4.5).
- **Autocompletion or option validation while typing.** Validation is the parser's, at apply time.
- **Text editing of files that are not `.th2`.** `thconfig`/`.th` files already have their own text tabs.

## 2. Grounding: Current State

### 2.1 Text editor for `thconfig`/`.th` files

- `THTextEditorWidget` (`lib/src/widgets/th_text_editor_widget.dart`, 928 lines) is a self-built editor with no code-editor dependency. It has a line-number gutter, a `TextField` with a syntax-highlighting overlay, diagnostic line markers, folding, and a find/replace bar.
- It takes a concrete `THTextEditorController` (`lib/src/controllers/th_text_editor_controller.dart`). It uses only these members: `content`, `setContent`, `isDirty`, `cursorLine`, `setCursorPosition`, `pendingScrollToLine`/`clearPendingScrollToLine`, `pendingSelectionRange`/`clearPendingSelectionRange`, `diagnostics`, `textEditorFocusNode`, `save`, `revert`, and the find members (`findQuery`, `replaceQuery`, `findCaseSensitive`, `findMatches`, `activeMatchIndex`, `isFindBarVisible`, `openFindBar`, `closeFindBar`, `findNext`, `findPrevious`, `replaceActiveMatch`, `replaceAllMatches`, `setFindQuery`, `setReplaceQuery`, `setFindCaseSensitive`).
- `THTextEditorController` is bound to `THProjectController`. It owns a project epoch/root identity, calls `registerTextContentChange` and a debounced `reparseFile`, and saves through the project. None of that applies to a `.th2` file, whose model is owned by `TH2FileEditController`.
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

### 2.4 TH2 writer

- `TH2FileWriter.serialize` builds the text by string concatenation, recursively through `serializeElement` and `_childrenAsString` (`th2_file_writer.dart:36-60, 232-309, 419-428`). It records no element-to-line information.
- Every emitted line goes through `_prepareLine(line, thElement)` (`:456`) or `_prepareLineWithOriginalRepresentation(newText, thElement)` (`:123`), which both know the element. `_prepareLine` can break a long line into several lines (`mpMaxFileLineLength`), and an `originalLineInTH2File` can hold several lines. The calls happen in the same order as the text they produce.
- Saving uses `_encodedFileContents()` → `toBytes(_th2File, includeEmptyLines: true, useOriginalRepresentation: true)` (`th2_file_edit_controller.dart:1650-1659`). `toBytes` encodes with the file's encoding and line ending.

### 2.5 Model, undo and sub-controllers

- `TH2FileEditController._basicInitialization(file)` (`:671-718`) stores `_th2File` and creates about 20 sub-controllers. Many keep their own `TH2File _th2File` field (for example `MPUndoRedoController`, `TH2FileEditSelectionController`, `TH2FileEditCopyPasteController`, `TH2FileEditSearchController`, `TH2FileHideElementController`). **Replacing the `TH2File` object would leave them pointing at the old one.** The contents must be replaced in place.
- `TH2File.clear()` (`th2_file.dart:773-790`) already resets the element map, children, thID registries and derived caches. It also resets `filename` and `encoding`.
- Undo commands (`lib/src/commands/`) refer to elements by MPID. `MPUndoRedoController` keeps `_undos`/`_redos`. `enableSaveButton => !_isBroken && _hasUndo && !_th2File.isNewFile` (`:534`) is the TH2 dirty signal. `_actualSave` clears the undo/redo stack (`:1787-1794`).
- `TH2File.toMap()`/`fromMap()` exist and are used in tests as a deep clone (`test/t1140_actions_set_point_id_test.dart`).
- A reaction mirrors `enableSaveButton` into `THProjectController.dirtyFilePaths` (`:1032-1049`). `THProjectController._saveTH2ProjectFile` (`th_project_controller.dart:~1535-1600`) skips a TH2 file whose `enableSaveButton` is false. `MPGeneralController.shouldKeepTablessTH2Controller` (`:181-202`) also uses it.

### 2.6 Selection

- `TH2FileEditSelectionController.mpSelectedElementsLogical` (`ObservableMap<int, MPSelectedElement>`) holds the selected points, lines and areas. `_selectedEndControlPoints` holds the selected line points in _Line edit_ mode. `selectedScrapMPIDs` holds selected scraps.
- The element tree selects an element with `controller.setActiveScrapByChildElement(element)` followed by `selectionController.setSelectedElements([element], setState: true)` (`th2_element_tree_row_widget.dart:518-533`). It leaves creation modes first with `stateController.onButtonPressed(MPButtonType.select)` (`:419-429`). Text mode reuses both.
- `requestZoomToFit(MPZoomToFitType.selection)` exists (`th2_file_edit_controller.dart:1501`). There is no "pan to show without zooming" helper.

### 2.7 Keyboard shortcuts

`Ctrl+E` is not used by the edit page (`assets/help/en/keyboard_shortcuts_edit.md`). Mapiah treats Ctrl and Meta as the same key.

## 3. User-Facing Behavior

### 3.1 Switching modes

- A **Text/Canvas toggle** is added to the top-right button group of a `.th2` tab, and bound to `Ctrl+E` in both modes. While the text field has focus, the text editor's own shortcut map must handle `Ctrl+E`, because the canvas key handler doesn't get the key.
- **Entering text mode** first leaves any creation or operation state, as the element tree does (§2.6). An unfinished line or area being drawn is ended the same way `Esc` ends it. Open overlay windows are closed.
- **Leaving text mode** with unchanged text only maps the cursor to a selection (§3.3). Changed text is parsed and applied first (§3.4).
- A **Discard text changes** action (a button in the text view, and a choice in the "can't apply" message) drops the text edits and returns to the canvas with the model untouched.

### 3.2 Graphical → text

1. Generate the text with the save path (§4.2) and record, for each element, the line it starts on (§4.3).
2. Collect the selected MPIDs: the selected points, lines and areas, plus the line segments of any selected line points, plus selected scraps.
3. If that set is empty, keep the text view's last scroll position for this tab, or the top of the file the first time.
4. Otherwise, take the **smallest start line** among them. That is the first selected element in file order, whatever order the elements were selected in. Scroll it into view, and put the cursor at its first non-blank column. Nothing is selected in the text.

### 3.3 Text → graphical (selection)

The cursor line is mapped to an element (§4.4), and then:

| Cursor is on | Result on the canvas |
|---|---|
| a `point`, `line` or `area` line, or a wrapped continuation of one | that element is selected; its scrap becomes active |
| a line point, `smooth`/`subtype`/other line option line, or `endline` | the owning **line** is selected |
| an area border reference, an area option line, or `endarea` | the owning **area** is selected |
| `scrap`, `endscrap`, or an empty line or comment inside a scrap | that scrap becomes active; the selection is cleared |
| anything at file level (`encoding`, settings, comments, empty lines) | the selection is cleared; the active scrap is kept if it still exists, or else the first scrap is used |

If the selected element is outside the visible canvas area, the canvas is centered on it at the current zoom (§4.8). Nothing is zoomed.

### 3.4 Text → graphical (apply)

- If the text is unchanged since entering text mode, nothing is parsed. The line map from §3.2 is used in reverse, so the model and its MPIDs stay as they are.
- If the text changed, it is parsed into a detached model (§4.5). Then:
  - **No errors and no problems:** the file's contents are replaced by one `MPReplaceTH2FileContentsCommand` (§4.5). The canvas, the element tree and the dirty state update, and the cursor line is mapped with the **parser's** line map (§4.4).
  - **Any error or problem:** nothing is applied. The tab stays in text mode. Each `TH2FileProblem` is marked at its line, and errors without a line number are listed in a message above the editor. The message offers _Keep editing_ and _Discard text changes_.

### 3.5 Undo in text mode

The `TextField`'s own undo history handles `Ctrl+Z`/`Ctrl+Y` while typing. Back on the canvas, the whole text session is **one** undo step. Undoing it restores the model as it was before the text edit.

### 3.6 Save in text mode

Save (button, `Ctrl+S`, Save All) first applies the text as in §3.4. It then saves through the normal TH2 path. If the text can't be applied, nothing is written, and the problems are shown as in §3.4. **Mapiah never writes a `.th2` file it can't read back.** The tab stays in text mode after a successful save, and the text is regenerated from the saved model. The cursor line is kept.

### 3.7 Broken files

The broken-file tab body (`TH2BrokenFileBodyWidget`) gets an **Edit as text** button. It opens text mode with the **raw file content from disk**, decoded with the file's encoding. It can't use the writer, because a broken model is missing the lines the parser dropped. The problem list is shown as line markers. Applying or saving works as in §3.4 and §3.6. Once the text parses cleanly, the controller stops being broken, and the canvas becomes available.

## 4. Design Decisions

### 4.1 Mode lives on `TH2FileEditController`, text state on a new `TH2TextEditController`

- `TH2FileEditController` gains `@observable TH2EditMode editMode` (`canvas`, `text`) and `@readonly TH2TextEditController? _textEditController`. The text controller is created when text mode is first entered, and dropped when the tab's controller is disposed.
- `TH2FileEditBodyWidget` shows `TH2TextEditBodyWidget` when `editMode == text`, and otherwise keeps today's canvas/broken logic. The mode is per tab, because it belongs to the tab's controller. It survives tab switches, and project-tree clicks don't reset it.
- A split view could later show both widgets. The single `editMode` value would then become two visibility flags.

### 4.2 The text source

- **Valid file:** a new `TH2FileEditController.serializeForTextMode()` returns `TH2FileWriter().serializeWithLineMap(_th2File, includeEmptyLines: true, useOriginalRepresentation: true)`, with the line ending normalized to `\n`. It shares its writer options with `_encodedFileContents()`, so the two can't drift apart.
- **Broken file:** the raw bytes from disk (or `_th2File.fileBytes` when it's set), decoded with the parser's encoding detection, which becomes a public static helper.
- On apply and save, the text is converted back to the file's line ending. It is encoded with the encoding its own `encoding` line names, as the parser already does on load.

### 4.3 Writer line map (model MPID → start line)

`serializeWithLineMap` returns `(String text, TH2TextLineMap lineMap)`. It uses a **line ledger** instead of rewriting the writer:

- `_prepareLine` and `_prepareLineWithOriginalRepresentation` append `(mpID, lineCount)` to a ledger when ledger mode is on. `lineCount` is the number of line endings in the chunk they return. This counts wrapped long lines and multi-line original representations correctly.
- The calls happen in output order (§2.4), so an element's start line is the sum of the `lineCount`s before its **first** ledger entry. Its end line is the start line of the next ledger entry that doesn't belong to it or to a descendant, minus one.
- `serialize` and `toBytes` keep their signatures and their exact output. Ledger mode is off by default.
- A debug assertion and a test check that the ledger's total line count equals the number of lines in the returned text for every fixture in `test/auxiliary/*.th2`. If a code path emits text without passing through the two helpers, the test fails, and that path is routed through them. If that turns out to be too fragile, the fallback is a `StringBuffer`-based writer that tracks the current line directly, covered by the same round-trip tests.

`TH2TextLineMap` (new, `lib/src/auxiliary/th2_text_line_map.dart`) keeps `startLineByMPID` and a sorted `(startLine, mpID)` list for reverse lookup. Line numbers are 0-based here to match the editor's `cursorLine`. Conversion from the parser's 1-based numbers happens in one place.

### 4.4 Parser line map (line → parsed MPID) and ownership resolution

- `TH2FileParser` gains `Map<int, int> elementStartLines` (MPID → 1-based `_currentLineNumber`). It is filled by a private `_addElement(...)` helper that wraps the 21 `executeAddElement` calls. The map is also useful for the element tree and search later.
- `TH2TextElementLocator` (new, pure, `lib/src/auxiliary/th2_text_element_locator.dart`) turns a line and a `TH2TextLineMap` into a `TH2TextLocation`, following the rules in §3.3:
  1. Find the element with the greatest start line ≤ the cursor line (binary search).
  2. Walk up `parentMPID` until reaching a `THPoint`, `THLine`, `THArea` or `THScrap`, or the file.
  3. Return `selectElement(mpID, scrapMPID)`, `activateScrap(scrapMPID)` or `fileLevel`.
- Both directions use `TH2TextLineMap`. Graphical → text uses the writer's map. Text → graphical uses the writer's map when the text is unchanged, and the parser's map after an apply. The locator is pure and gets its own unit tests.

### 4.5 Detached parse and in-place, undoable replace

**Detached parse.** `TH2FileParser.parse` gains an optional `TH2FileEditController? targetController`. When it's given, the parser uses that controller instead of looking one up in `MPGeneralController`. Text mode creates a **scratch controller**, `TH2FileEditControllerBase.createForDetachedParse(filename, th2FileMPID)`. It is never registered and never gets a tab. Its `TH2File` uses the real file's MPID, so top-level `parentMPID`s already point at the real file. MPIDs come from the global counter (`nextMPIDForElements`), so they can't collide with the live model. The scratch controller is disposed after the apply.

**In-place replace.** `TH2File.replaceContentsFrom(TH2File source)` clears this file's contents without touching `filename`, `mpID` or `isNewFile`. It then adopts `source`'s elements, children, thID registries, encoding and line ending, and rebuilds the derived caches with the existing `_updateSupportMaps` path. The live `TH2File` object never changes, so the sub-controllers' references (§2.5) stay valid.

**Command.** `MPReplaceTH2FileContentsCommand` (new, `lib/src/commands/`) holds two deep snapshots, `before` and `after` (`TH2File.toMap()` maps), and applies one with `replaceContentsFrom(TH2File.fromMap(...))`. Undo restores `before` with **its original MPIDs**, so every older command on the stack stays valid. Newer commands refer to the `after` MPIDs, which redo restores. The command goes through `MPUndoRedoController` like any other, so `enableSaveButton`, the dirty dot and Save All follow without changes. Snapshots cost memory, but only one pair is kept per text session. A test checks a 5,000-element fixture for time and size.

**After a replace**, the controller:
- clears the selection, hidden elements and selected scraps, whose MPIDs no longer exist;
- resets the selectable elements and snap targets, and sets the active scrap (§3.3);
- calls `bumpStructureRevision()` so the element tree and canvas rebuild;
- clears `_isBroken`/`_problems` when the file was broken (§3.7).

**Why not keep MPIDs?** Matching unchanged elements between two parses (by thID, or by parent path plus `originalLineInTH2File`) would keep hidden elements and the tree's collapsed scraps. But it is heuristic, and wrong matches would corrupt the undo stack. The `before`/`after` snapshots make undo exact without any matching. MPID matching can be a later improvement that only touches the scratch parse.

**Rejected alternative:** reusing Reload (`MPGeneralController.reloadTH2File`) to build a new controller from the text. It throws away the undo history and all per-controller view state (zoom, active scrap, overlays). It also makes the text session impossible to undo.

### 4.6 Dirty state and saving

- `TH2FileEditController` gains `@computed bool hasUnsavedChanges => enableSaveButton || (_textEditController?.isDirty ?? false)`.
- `hasUnsavedChanges` replaces `enableSaveButton` as the **dirty** signal in the dirty-mirroring reaction (`:1032-1049`), in `shouldKeepTablessTH2Controller`, in `_saveTH2ProjectFile`'s "already saved" check, and in the app bar's Save button state and `_saveActiveTab`. `enableSaveButton` keeps its current meaning, "the model has unsaved changes".
- `saveTH2File()` in text mode runs `applyTextEdits()` first and returns a result: `saved`, `textHasProblems`, or `broken`. `_saveTH2ProjectFile` maps `textHasProblems` to a new `TH2FileSaveStatus.textHasProblems`, so Save All reports the file as not saved instead of failing silently.
- A new file (`isNewFile`) in text mode: Save runs Save As, as it does today. Save As applies first.

### 4.7 Editor widget reuse

- Extract `THTextEditorBuffer`, an abstract class with the members listed in §2.1, plus `List<THTextEditorDiagnostic> get diagnostics` and `THTextEditorLanguage get language`. `THTextEditorController` and the new `TH2TextEditController` implement it. `THTextEditorWidget` takes `THTextEditorBuffer`.
- The find/replace state and logic move from `THTextEditorController` into a `THTextEditorFindMixin` used by both, so they behave the same.
- `THTextEditorDiagnostic` (line, message, severity) replaces the widget's direct use of `THProjectParseError`. `THTextEditorController` maps its project errors to it. `TH2TextEditController` maps `TH2FileProblem`s (with the localized category from `TH2FileProblemTextAux`) and line-less parser errors.
- `THTextEditorLanguage { therion, th2 }` chooses the tokenizer and fold keywords. `tokenizeTherionText(text, language:)` keeps its default, so current callers don't change.

### 4.8 TH2 highlighting and folding

- TH2 keywords: `encoding`, `scrap`, `endscrap`, `point`, `line`, `endline`, `area`, `endarea`, `comment`, `endcomment`. Line-level option words that begin a line inside a `line` block (`smooth`, `subtype`, `orientation`, `l-size`, `size`, `mark`, `altitude`, `adjust`, `direction`, `gradient`, `height`, `border`, `reverse`, `visibility`, `place`, `clip`, `outline`, `close`, `id`) are colored as `option`.
- `##XTHERION##` and `##MAPIAH##` at the start of a line color the whole line as a new `THTextEditorTokenType.setting`, not as a comment.
- The TH2 tokenizer carries state across lines: the lines between `comment` and `endcomment` are colored as `comment`.
- Folds: `scrap`/`endscrap`, `line`/`endline`, `area`/`endarea`, `comment`/`endcomment`.
- Token colors come from the existing editor palette. One new color token is added for `setting`, for light and dark themes.

### 4.9 Centering the canvas without zooming

`TH2FileEditController.revealSelection()` (new) checks the selection's bounding box against the visible canvas rectangle. If the box isn't fully visible, it moves `_canvasCenterX/Y` to its center, reusing the math in `_setCanvasCenterOnZoom` (`:1603`) but keeping the scale. Like `requestZoomToFit`, it waits for layout when the canvas hasn't been laid out yet, because it runs right after the body widget swaps back to the canvas.

## 5. Implementation Phases

Each phase ends with `flutter analyze` clean and `flutter test` green. New tests start at `t3960`.

### Phase 1: Line maps and locator (no UI)

- `TH2TextLineMap`, and the writer's ledger mode with `serializeWithLineMap` (§4.3).
- The parser's `elementStartLines` and the `_addElement` helper (§4.4).
- `TH2TextElementLocator` (§4.4).
- Tests:
  - `t3960`: the ledger's line total matches the output for every fixture in `test/auxiliary/*.th2`. `serialize`'s output is unchanged byte for byte.
  - `t3961`: start lines for points, lines, line segments, areas, border references, scraps, wrapped long lines and multi-line bracketed values.
  - `t3962`: the parser's `elementStartLines` agrees with the writer's map on a round-tripped fixture (after matching MPIDs by position).
  - `t3963`: every row of the table in §3.3.

### Phase 2: Detached parse and undoable replace

- `targetController` on `TH2FileParser.parse`, and `createForDetachedParse` (§4.5).
- `TH2File.replaceContentsFrom`, and `MPReplaceTH2FileContentsCommand` with its factory entry, description type and EN/PT description string.
- `TH2FileEditController.applyText(String text)`, which returns `applied(lineMap)` or `rejected(problems, errors)`. It also does the post-replace cleanup (§4.5).
- Tests:
  - `t3964`: a detached parse doesn't register or replace any controller in `MPGeneralController`.
  - `t3965`: apply, then undo, gives the original `TH2File` by value, and older commands on the stack still undo correctly. Redo gives the applied state.
  - `t3966`: text with a problem or error is rejected, and the model is unchanged.
  - `t3967`: sub-controllers see the new contents after a replace. Selection, hidden elements and active scrap are reset as described.
  - `t3968`: performance guard on a large generated fixture.

### Phase 3: Editor generalization and TH2 highlighting

- `THTextEditorBuffer`, `THTextEditorFindMixin`, `THTextEditorDiagnostic` and `THTextEditorLanguage` (§4.7). Refactor `THTextEditorController` and `THTextEditorWidget` onto them with no behavior change.
- The TH2 tokenizer and folds (§4.8).
- `TH2TextEditController` (MobX): `content`, `initialContent`, `isDirty` (`content != initialContent`), cursor, pending scroll/selection, diagnostics, find, and the owning `TH2FileEditController`. `save` and `revert` delegate to the owner (§3.6, discard).
- Tests:
  - the existing text editor tests (`t3900`–`t3937`) pass unchanged;
  - `t3969`: TH2 tokens, including `##XTHERION##` lines, multiline comments, options and line-option words;
  - `t3970`: TH2 fold regions.

### Phase 4: Mode switching, synchronization and saving

- `editMode`, `enterTextMode()`, `leaveTextMode()`, `discardTextEdits()`, and `TH2TextEditBodyWidget` (§4.1). The toggle button and the `Ctrl+E` shortcut in both the canvas key handler and the editor's shortcut map (§3.1).
- Graphical → text cursor placement (§3.2), and text → graphical selection plus `revealSelection()` (§3.3, §4.9).
- The "can't apply" message with _Keep editing_/_Discard text changes_ (§3.4).
- `hasUnsavedChanges`, and its adoption at the call sites in §4.6. Save and Save As in text mode, and `TH2FileSaveStatus.textHasProblems`.
- Tests (widget tests use the `TH2FileTabsPage` setup of `t3950`):
  - `t3971`: with two elements selected in reverse file order, text mode puts the cursor on the one nearer the top. The same for a selected line point in _Line edit_ mode.
  - `t3972`: returning with the cursor on each kind of line from §3.3 selects the right element and activates its scrap. Unchanged text keeps MPIDs.
  - `t3973`: typing a new option and returning applies it. Undo on the canvas removes it.
  - `t3974`: invalid text stays in text mode with markers. Discard returns with the model unchanged.
  - `t3975`: the dirty dot, Save, Save All and the unsaved-changes guard see text-only edits. Save with problems writes nothing and reports `textHasProblems`.
  - `t3976`: the mode is kept across tab switches. Tree clicks while in text mode move the cursor to the clicked element, using §3.2 with that element.

### Phase 5: Broken files

- _Edit as text_ on `TH2BrokenFileBodyWidget`, with the raw disk text source (§3.7, §4.2).
- Clearing the broken state after a successful apply.
- Tests:
  - `t3977`: a broken fixture opens in text mode with its problems marked at the right lines. Fixing and applying makes the canvas available. Saving writes the fixed text.
  - `t3978`: a broken file's text mode never offers Save while problems remain.

### Phase 6: Documentation and localization

- EN/PT strings for the toggle tooltip, the discard action, the "can't apply" message, the command description, the save status and _Edit as text_. Run `flutter gen-l10n`.
- Help: a new "Text mode" section in `th2_file_edit_page_help.md` (EN/PT), with an index entry, covering §3.1–§3.7. Update the "Top right corner" list and the "Broken files" section.
- Keyboard shortcuts: `Ctrl+E` in `keyboard_shortcuts_edit.md` (EN/PT), in alphabetical order.
- CHANGELOG entry under the next release, referencing #38.

## 6. Risks and Open Questions

1. **Save in text mode with parse problems.** This plan blocks it, so Mapiah never writes a file it can't read (§3.6). The alternative is to write the text as typed and mark the file broken. That never loses typed text, but it leaves a broken file on disk. **Decision needed.**
2. **Selecting a line point from the text.** This plan selects the owning line when the cursor is on a line-point line (§3.3). The alternative is to enter _Line edit_ mode with that point selected. That is more precise, but it is a bigger change in state. It could be a follow-up.
3. **Placement of the toggle and the shortcut.** The plan uses the top-right button group and `Ctrl+E`. On macOS, `Ctrl+E` inside a `TextField` means "end of line" in Flutter's default text shortcuts. Because Mapiah treats Ctrl and Meta as the same key, the editor's shortcut map must take priority there. Otherwise a different key is needed.
4. **Writer ledger completeness** (§4.3). The fixture test protects it. If the ledger turns out to be fragile, the `StringBuffer` fallback costs a larger writer diff.
5. **Lost view state after an apply.** Hidden elements and the tree's collapsed scraps are keyed by MPID and are reset after a text apply (§4.5). This is acceptable for a first version. MPID matching can recover it later.
6. **Memory of the undo snapshots** for very large files (§4.5, `t3968`). If needed, the `before`/`after` snapshots can be stored as the serialized text plus an MPID list that the detached parse reuses.
