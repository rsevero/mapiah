<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing Mode with Selection Synchronization: Implementation Plan

**Date:** 2026-09-25
**Status:** Proposed. Checked against the codebase on 2026-09-25 (`main` at `0e0ca067`). Line references updated at `83953678`, and the writer's again after `bcd28f18` (#46). Undo design revised on 2026-09-28. Saving new and broken files, the broken-file baseline's canvas setup, element back-references, tree edits in text mode, the missing unsaved-changes guard and the controller refresh on undo and redo revised on 2026-10-01, after checking against `9ec53309`. Decisions:

- text mode uses the existing `TextField` undo history; each successful apply becomes **one canvas undo step**, regardless of how many lines changed (§3.5, §4.6);
- **inside text mode**, undo and redo work as in the `thconfig`/`.th` editor, through the `TextField`'s own history (§3.5);
- redo is **`Ctrl+Shift+Z` everywhere**. The canvas no longer uses `Ctrl+Y`, and the text editor accepts both Ctrl and Cmd. This change was made on its own, ahead of this plan (§2.7);
- text that doesn't parse is **never saved** (§3.6);
- the first apply of a broken file is a **new baseline that can't be undone**, and the fixed file stays unsaved until saved (§3.7, §4.7);
- text the parser rewrites or drops is **accepted as the parser reads it**, and each such line gets an information marker before the apply (§4.12);
- a selected line point **round-trips** between the two views (§3.2, §3.3);
- the mode toggle uses **F2** instead of `Ctrl+E` (§3.1).
- an element-tree edit made while the tab is in text mode **applies the text first**, and is cancelled if the text doesn't parse (§3.8, §4.13).

**Issue:** [#38: Simplify object options entry by allowing user to type without clicking each option](https://github.com/rsevero/mapiah/issues/38)

## 1. Overview and Objectives

Issue #38 asks for a quicker way to enter and review element options than clicking through one option dialog at a time. It points to XTherion, where options are typed as text. This plan's answer is a **text mode for `.th2` tabs**. The same tab switches between the graphical canvas and a syntax-highlighted text view of the whole file. The user can type or change any command, option or coordinate, see every option of every element at once, and then return to the canvas.

The two views are **synchronized at each switch**, not while typing:

- **Graphical → text:** the text is generated from the current model, and is exactly what Save would write. If elements are selected, the text scrolls to the **first selected element in file order** (the one nearest the top of the file), and the cursor is placed on it. A selected line point counts as an element here.
- **Text → graphical:** if the text changed, the final valid text is applied to the model as **one undoable edit**. Clearly matched unchanged elements keep their MPIDs. The element on the cursor's line is then **selected on the canvas**, and its scrap becomes the active scrap. If the cursor is on a line point, the canvas opens in _Line edit_ mode with that point selected.

### Key objectives

1. **Text mode per `.th2` tab.** A toggle button and `F2` switch the active tab between canvas and text. Each tab remembers its own mode.
2. **Highlighting.** TH2 commands, options, numbers, strings, comments, multiline `comment … endcomment` blocks and `##XTHERION##`/`##MAPIAH##` settings are colored. `scrap`, `line`, `area` and `comment` blocks can be folded.
3. **Lossless generation.** The text shown on entering text mode is exactly the output of the save path (`TH2FileWriter` with `includeEmptyLines: true, useOriginalRepresentation: true`). Unchanged lines keep their original formatting. Typed text is kept as the parser reads it. Where the parser rewrites or drops a line, the user is told before the apply (§4.12).
4. **Graphical → text selection.** The first selected element or line point in file order decides the scroll position and the cursor line.
5. **Text → graphical selection.** The element owning the cursor's line is selected, as if clicked in the element tree. A line point opens _Line edit_ mode with that point selected.
6. **Undo in both views.** In text mode, `Ctrl+Z`/`Ctrl+Shift+Z` use the same `TextField` history as the `thconfig`/`.th` editor. Applying the final text creates one command on the canvas undo stack (§3.5, §4.6).
7. **Safe apply.** Text that doesn't parse cleanly is never applied and never saved. The tab stays in text mode, and each problem is marked at its line.
8. **Stable identity.** An apply keeps the MPIDs of elements that can be matched unambiguously (§4.7), so their selection, hidden state and the element tree's collapsed scraps survive where possible.
9. **Save, dirty state and projects.** Unsaved text edits count as unsaved changes everywhere: the Save button and the overflow menu's Save item, the project tree's dirty dot, Save All, and the rule that keeps a tab-less controller only for a saved file (§4.8).
10. **Broken files become fixable in Mapiah.** A broken file's tab can open its **raw disk content** in text mode. Once fixed, it can be applied and saved.
11. **Complete integration.** EN/PT localization, help pages, keyboard shortcuts and CHANGELOG. Controller, parser, writer, diff and widget tests. `flutter analyze` and `flutter test` stay green.

### Non-goals (this plan)

- **Live synchronization while typing.** The canvas is not updated on every keystroke. Syncing happens at the mode switch and on Save (§3.6).
- **Split view** (canvas and text side by side). The design leaves room for it (§4.1), but it is not built here.
- **An option-entry box on the canvas** (the literal proposal in #38). Text mode covers the need. A per-element text box can be a later follow-up that reuses this plan's parser and apply path.
- **Autocompletion or option suggestions.** Parser diagnostics update after an idle delay, and apply validates the final content (§4.6).
- **Per-line or per-keystroke undo on the canvas.** Each successful apply is one canvas undo step (§3.5).
- **A custom undo for the text editor.** TH2 text mode keeps the undo that `thconfig`/`.th` tabs already use (§3.5).
- **Text editing of files that are not `.th2`.** `thconfig`/`.th` files already have their own text tabs.

## 2. Grounding: Current State

### 2.1 Text editor for `thconfig`/`.th` files

- `THTextEditorWidget` (`lib/src/widgets/th_text_editor_widget.dart`, 948 lines) is a self-built editor with no code-editor dependency. It has a line-number gutter, a `TextField` with a syntax-highlighting overlay, diagnostic line markers, folding, and a find/replace bar.
- It takes a concrete `THTextEditorController` (`lib/src/controllers/th_text_editor_controller.dart`). It uses only these members: `content`, `setContent`, `isDirty`, `cursorLine`, `setCursorPosition`, `pendingScrollToLine`/`clearPendingScrollToLine`, `pendingSelectionRange`/`clearPendingSelectionRange`, `diagnostics`, `textEditorFocusNode`, `save`, `revert`, and the find members (`findQuery`, `replaceQuery`, `findCaseSensitive`, `findMatches`, `activeMatchIndex`, `isFindBarVisible`, `openFindBar`, `closeFindBar`, `findNext`, `findPrevious`, `replaceActiveMatch`, `replaceAllMatches`, `setFindQuery`, `setReplaceQuery`, `setFindCaseSensitive`).
- `THTextEditorController` is bound to `THProjectController`. It owns a project epoch/root identity, calls `registerTextContentChange` and a debounced `reparseFile`, and saves through the project. None of that applies to a `.th2` file, whose model is owned by `TH2FileEditController`.
- The widget listens to its `TextEditingController` (`_onTextEditingChanged`, `:121`, added as a listener at `:75`) and relies on the `TextField`'s built-in undo history. That history records a step after a 500 ms pause in typing. Programmatic changes (auto-indent, block indent, Replace, Replace All, Revert) go into it too. Its shortcut map binds `Ctrl+Z`/`Cmd+Z` to `UndoTextIntent` and `Ctrl+Shift+Z`/`Cmd+Shift+Z` to `RedoTextIntent`, so both modifier keys work on every platform (§2.7).
- `diagnostics` is `List<THProjectParseError>`. The widget renders them in `_buildDiagnosticBackground` (`:769-798`) and `THTextEditorDiagnosticMarkerWidget`. It keys them by line (`:775`), so only **one diagnostic per line** is drawn.
- Auto-indent (`_computeAutoIndent`) adds two spaces after a line that opens a block. The openers are a fixed Therion set (`_thTextEditorBlockOpeners`, `:14-20`: `survey`, `centreline`, `map`, `scrap`, `layout`).
- `tokenizeTherionText` (`lib/src/auxiliary/th_text_editor_syntax_highlighter.dart`) is a stateless, per-line lexer. Its keyword set is for `thconfig`/`.th` (`survey`, `centreline`, `map`, `scrap`, `layout`, `input`, …). It has no `point`, `line`, `area`, `endline`, `endarea`, `comment`/`endcomment`. Anything from `#` to the end of the line is a comment, so `##XTHERION##` settings would be colored as comments. It keeps no state across lines, so it can't color a multiline `comment … endcomment` block.
- `buildFoldRegions` (`lib/src/auxiliary/th_text_editor_fold_aux.dart:30-34`) folds `survey`, `centreline`, `map`, `scrap` and `layout`. `line`, `area` and `comment` are not included.

### 2.2 Tabs

- `MPGeneralController` keeps `_openFileOrder` (filenames) and chooses the controller type from the filename with `isTH2Tab(filename)` (`mp_general_controller.dart:32-34`). A `.th2` tab always maps to one `TH2FileEditController`.
- `TH2FileTabsPage._buildTabContentWidget` (`lib/src/pages/th2_file_tabs_page.dart:829-880`) returns `THTextEditorTabBodyWidget` for text tabs and `TH2FileEditBodyWidget` for `.th2` tabs. `TH2FileEditBodyWidget` shows `TH2BrokenFileBodyWidget` when `controller.isBroken` (`th2_file_edit_body_widget.dart:~84`).
- The app bar's Save/Save As buttons and `_saveActiveTab` (`:1210-1242`) branch on `isTH2Tab`, and use `TH2FileEditController.enableSaveButton` as the TH2 dirty signal. So do the overflow menu's Save item (`_buildFileMenuEntries`, `:681`) and the canvas `Ctrl+S` handler (`mp_th2_file_edit_state_key_down_mixin.dart:178-188`). The app bar's Save As button (`:380-383`) and the overflow menu's Save As item (`:687-689`) are disabled for a broken file (`isBroken`).
- `enableSaveButton` is false for a new file (`isNewFile`), so **Save is disabled for a new file** and only Save As works. `saveTH2File()` itself doesn't check `isNewFile`: called on a new file, it would write to the placeholder name (`mpNewFilePrefix`, `NEW_TH2_FILE…`) returned by `_localFile()`.

### 2.3 TH2 parser

- `TH2FileParser.parse(filename, {fileBytes, …, forceNewController})` (`th2_file_parser.dart:2992-3071`) looks up the target controller with `mpLocator.mpGeneralController.getTH2FileEditController(filename:, forceNewController:)` and fills **that controller's** `th2File` through 21 `elementEditController.executeAddElement(...)` calls. It cannot parse into a detached `TH2File` today.
- `_splitContents` (`:3325-3440`) produces `MPParseableLine`s with a 1-based `lineNumber`. A **multi-line value** is joined into one parseable line, which keeps the number of its first line: a value inside square brackets or double quotes that continues on the next line, or a line ending with `\` (`updateContinuationDelimiter`, `_slashJoinLine`). Line breaks are found by `_findLineBreak`, which only knows `\n` and `\r\n`: a lone `\r` doesn't end a line for the parser, and line numbers count `\n`s. `_injectContents` sets `_currentLineNumber` before injecting each line (`:158`).
- Broken-file detection gives `TH2FileProblem`s, each with a `lineNumber` and `sourceLine` (`lib/src/mp_file_read_write/th2_file_problem.dart`). Some errors in `_parseErrors` (petitparser `Failure` messages) carry no line number.
- `TH2FileEditController._loadOnce` (`th2_file_edit_controller.dart:~770`) parses with `forceNewController: false` and `fileBytes: _th2File.fileBytes`. `_commitLoadResult` sets `_isBroken` when there are problems or errors.
- Parsed elements keep their source text in `originalLineInTH2File`, so writing them back with `useOriginalRepresentation: true` reproduces most of the parsed text, **but not all of it**. After injecting the lines, `parse` runs three clean-up passes (`:3049-3051`):
  - `_cleanOriginalLinesInFile` (`:3091`) clears the source text of the elements flagged at 7 call sites (`:1003`, `:1083`, `:1517`, …). Examples are a border reference whose text the grammar rewrote, a scrap with a changed option, and `subtype` on a line with fewer than 2 points. The writer then generates new text for them. No problem is reported.
  - `_linesCleanUp` (`:3127`) removes a duplicate line point that has no options, and a line left with fewer than 2 points, together with its area border reference. No problem is reported.
  - `_areasCleanUp` (`:3276`) first resolves each border reference with `_resolveBorderReference` (`:3247`). When a reference spells the invalid id of a line that Mapiah rewrote (for example `-id b@1`, stored as `b_1`), it rewrites the reference the same way and clears its source text, so the writer generates a new line for it. No problem is reported. It then reports a border reference that names no line or names a non-line (`_reportUnresolvedBorder`), which makes the file broken, and removes an area left with no borders, which isn't reported by itself.
- The writer also adds text of its own. When the file's first child isn't an `encoding` line, it writes one (`th2_file_writer.dart:51-56`).
- The writer also **rewrites image lines**. Since #46 (`bcd28f18`), `_serializeMapiahImageInsertConfig` (`th2_file_writer.dart:219-241`) writes an image whose transform is a pure translation (`MPImageInsertConfig.isXTherionRepresentable`: not SVG, scale 1 and rotation 0 within tolerance) as a `##XTHERION## xth_me_image_insert` line, even when it was read as a `##MAPIAH##` line. It builds a temporary `THXTherionImageInsertConfig` with `fromMapiahImageInsertConfig` for that write. The temporary element has no stored source text, so the line is always generated, and it reuses the original element's MPID (`th_xtherion_image_insert_config.dart:306-321`).
- The writer also **moves settings lines**. Settings (`##XTHERION##`, `##MAPIAH##`) can only appear at file level: the grammar accepts them only among the top-level commands (`th2_grammar.dart:35`), not inside a scrap (`:40-41`), where such a line is read as a comment. The parser adds each setting at the end of the file's children, in text order (`th2_file_parser.dart:567`, `:633`). The writer writes all of them together at the position of the first one, and the others write nothing (`th2_file_writer.dart:87-111`). When every setting is new, the group goes right after the `encoding` line (`:64-85`). A setting typed away from the others is therefore written in the settings block, and its position in the text differs from its position among the file's children.
- So for a text *T*, "parse, then write" can give a different text. The plan calls it the **normalized text** *N(T)* (§4.12).

### 2.4 TH2 writer

- `TH2FileWriter.serialize` builds the text by string concatenation, recursively through `serializeElement` and `_childrenAsString` (`th2_file_writer.dart:35-60, 243-320, 429-439`). It records no element-to-line information.
- Output is produced in the same order as the final text, but **not through one helper**. Some functions produce text (the **leaves**) and others only assemble what leaves return (the **composers**):
  - `_elementOriginalLineRepresentation(element)` (`:322`) returns the stored source text, or `''` when there is none or `useOriginalRepresentation` is false. With `useOriginalRepresentation: true`, which text mode and Save always use, **most lines come from here**. `_serializeScrap`, `_serializeArea`, `_serializeLine`, `_serializePoint`, `_serializeLineSegment`, the three settings serializers and `_serializeMultiLineCommmentContent` call it directly, not through `_prepareLineWithOriginalRepresentation`.
  - `_prepareLine(line, thElement)` (`:467`) generates a line, and can wrap a long line into several. It is used only for elements with no stored text, meaning ones created or changed in Mapiah.
  - `_prepareLineWithOriginalRepresentation(newText, thElement)` (`:123`) is a composer: it returns `_elementOriginalLineRepresentation`, or `_prepareLine` when that is empty.
  - These leaves build their chunk without either helper:
    - the synthesized `encoding` line (`:52`);
    - both branches of `_serializeEmptyLine` (`:143-149`), which reads `originalLineInTH2File` directly;
    - the generated branches of `_serializeMultiLineCommmentContent` (`:151-160`), `_serializeXTherionConfig`, `_serializeXTherionImageInsertConfig` and `_serializeMapiahImageInsertConfig` (`:181-241`). For an image that XTherion can represent, `_serializeMapiahImageInsertConfig` only delegates to `_serializeXTherionImageInsertConfig` with the temporary element (§2.3), so that call is the leaf;
    - line-point option lines in `_linePointOptionsAsString` (`:546-573`), from `_commandOptionOriginalLineRepresentation` (`:542`) or generated. They are written for the **line segment** that owns them.
  - The other composers are `serializeElement`, `_childrenAsString`, `_serializeAllXTherionConfigs` and `_trySerializeXTherionConfig`. Each appends its leaves' results in the order it calls them, and never discards or reorders one.
- An `originalLineInTH2File` can hold several lines. It keeps each line's original ending (`\r\n`, `\n` or `\r`), and the writer returns it as is (`_serializeEmptyLine` returns it whole). The `lineEnding` parameter of `serialize` only applies to generated lines.
- Saving uses `_encodedFileContents()` → `toBytes(_th2File, includeEmptyLines: true, useOriginalRepresentation: true)` (`th2_file_edit_controller.dart:1650-1659`). `toBytes` encodes with the file's encoding and line ending.

### 2.5 Model, commands and sub-controllers

- `TH2FileEditController._basicInitialization(file)` (`:671-718`) stores `_th2File` and creates about 20 sub-controllers. It installs no reactions. The reactions, including the dirty-mirroring one, are installed by `_initializeReactions()`, which `_finalFilePreparations` calls (`:829-842`) at the end of a load or for a new file. Many keep their own `TH2File _th2File` field (for example `MPUndoRedoController`, `TH2FileEditSelectionController`, `TH2FileEditCopyPasteController`, `TH2FileEditSearchController`, `TH2FileHideElementController`). **Replacing the `TH2File` object would leave them pointing at the old one.** The apply command replaces its contents in place (§4.7).
- **A broken load skips most of `_finalFilePreparations`** (`:829-866`). When `_isBroken`, it doesn't set `_activeScrapID`, call `updateHasMultipleScraps()` or `snapController.setSnapTargets(...)`; and it returns right after `_initializeReactions()`, before `selectionController.clearIsSelected()`/`setIsSelected(...)`, `resetSelectableElements()`, `updateEnableSelectButton()` and `elementEditController.initializeUsedTypes()`. A broken file's controller has never run that canvas setup.
- **Elements point back at their file.** `MPTH2FileReferenceMixin` keeps a `TH2File? th2File` on every element and option; `TH2File.addElement` sets it (`th2_file.dart:382-388`). `TH2File.forCWJM`, and so `fromMap` and `copyWith`, adds elements to the map **without** setting it. `setTH2File` of `THScrap`, `THArea` and `THLine` returns early when `this.th2File == th2File` (`th_scrap.dart:336-345`, `th_area.dart:331-340`, `th_line.dart:509-521`), before passing the file to options and children. `TH2File.==` is a **deep value comparison** of mpID, filename, encoding, children and elements (`th2_file.dart:158-171`), not identity. So two different `TH2File` objects with the same MPID, filename and elements count as the same file there.
- **Line ending.** The parser sets `TH2File.lineEnding` from the first line break it sees while reading the `encoding` line (`_isEncodingDelimiter`, `th2_file_parser.dart:2973-2987`). Otherwise it stays at the platform default. The writer uses it only for generated lines (§2.4).
- Generic commands exist to build on. `MPAddElementCommand` (with `elementPositionInParent`, undo = `MPRemoveElementCommand`) and `MPRemoveElementCommand` (undo re-adds only the removed element at its position, not its recursively removed descendants). Type-specific add/remove commands exist for points, lines, areas, scraps, line segments, area border thIDs and empty lines. `MPMultipleElementsCommand` wraps several commands into **one** undo step. There is no generic "replace this element, keeping its MPID and children" command. `TH2File.substituteElement(newElement)` (`th2_file.dart:323`) does the replacement without undo.
- Elements have `copyWith(mpID:, parentMPID:, …)` (for example `THPoint.copyWith`, `th_point.dart:153`).
- Undo commands (`lib/src/commands/`) refer to elements by MPID. `enableSaveButton => !_isBroken && _hasUndo && !_th2File.isNewFile` (`:534`) is the TH2 dirty signal. `_actualSave` clears the undo/redo stack (`:1787-1794`).
- **Undo and redo don't refresh controller state.** `TH2FileEditController.execute(command)` (`:1808-1813`) runs `updateControllersAfterElementEditPartial`/`Final` after a command. `MPUndoRedoController.undo()` and `redo()` (`mp_undo_redo_controller.dart:115-170`) don't: they run the stored command, set the state to `selectEmptySelection` and redraw. Existing commands get their refresh another way: each `_actualExecute` calls an `execute*` method of the element edit controller that refreshes what it changed itself. For example, `MPMoveElementsCommand` calls `executeMoveElements` (`th2_file_edit_element_edit_controller.dart:1397-1434`), which updates the selection, the selectable elements, the snap targets and the station cache, redraws and bumps the structure revision. Undo runs the inverse command's `_actualExecute`, so the refresh happens in both directions.
- `initializeUsedTypes()` (`th2_file_edit_element_edit_controller.dart:133-166`) adds every element's type to the used-type counts and resets the type for new elements. It isn't idempotent: running it again counts every type again.
- `TH2File.clear()` (`th2_file.dart:773-790`) resets the element map, children, thID registries and derived caches.
- A reaction mirrors `enableSaveButton` into `THProjectController.dirtyFilePaths` (`:1032-1049`). `THProjectController._saveTH2ProjectFile` (`th_project_controller.dart:~1535-1600`) skips a TH2 file whose `enableSaveButton` is false. `MPGeneralController.shouldKeepTablessTH2Controller` (`:181-202`) also uses it.
- **There is no unsaved-changes guard.** Nothing asks before unsaved edits are dropped. Closing a tab disposes its controller unless `shouldKeepTablessTH2Controller` keeps it (`removeFileTab`, `mp_general_controller.dart:152-174`), and it never keeps a file with unsaved changes. Closing the window only saves its placement (`MPWindowPlacementController.saveAndClose`, `mp_window_placement_controller.dart:216`). Reload replaces the controller without asking (`reloadTH2File`, `:468-476`). `THProjectController.hasUnsavedChanges` exists but only tests read it. This applies today to canvas edits and to `thconfig`/`.th` tabs alike.

### 2.6 Selection and _Line edit_ mode

- `TH2FileEditSelectionController.mpSelectedElementsLogical` (`ObservableMap<int, MPSelectedElement>`) holds the selected points, lines and areas. `_selectedEndControlPoints` (`:113`) holds the selected line points in _Line edit_ mode, set with `setSelectedEndControlPoint(...)` (`:527`) and cleared with `clearSelectedEndControlPoints()` (`:540`). `selectedScrapMPIDs` holds selected scraps.
- The element tree selects an element with `controller.setActiveScrapByChildElement(element)` followed by `selectionController.setSelectedElements([element], setState: true)` (`th2_element_tree_row_widget.dart:518-533`). It leaves creation modes first with `stateController.onButtonPressed(MPButtonType.select)` (`:419-429`).
- A double-click enters _Line edit_ mode with `selectionController.setSelectedElements([parentLine])` followed by `stateController.setState(MPTH2FileEditStateType.editSingleLine)` (`mp_th2_file_edit_state_select_non_empty_selection.dart:250-261`).
- `requestZoomToFit(MPZoomToFitType.selection)` exists (`th2_file_edit_controller.dart:1501`). There is no "pan to show without zooming" helper.
- **Element-tree edits.** The tree changes the model in three ways: drag and drop (`th2_element_tree_drag_controller.dart:286-315`, `moveElements`), the drawing-order actions and _Move to scrap_ of a row's context menu (`th2_element_tree_row_widget.dart:665-705`, `bringForward`/`sendBackward`/`bringToFront`/`sendToBack` and `moveElementsToScrap`). All three first call `MPGeneralController.prepareTH2FileForTreeEdit(th2FilePath)` (`mp_general_controller.dart:111-121`). It returns `null` to refuse the edit (no loaded controller, a broken file, a load error), and otherwise activates the file's tab and leaves creation modes. Each caller returns without doing anything on `null`.
- The edits validate their MPIDs against the **current** model when they run. `moveElements` re-runs `checkMoveElements` (`th2_file_edit_element_edit_controller.dart:1374-1394`), whose `TH2HierarchyAux.validateMove` rejects an unknown element or target parent. `previewDrawingOrderAction` rejects an unknown element (`:1469-1474`). The row actions compute their MPIDs after the gate (`_menuSelection`, `th2_element_tree_row_widget.dart:564-579`), and check that the row's element still exists. So an MPID that disappears before the edit runs makes it a rejection, not a crash.

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

- If the text is unchanged since entering text mode, nothing is parsed or applied; the line map from §3.2 is used in reverse. If the text changed but normalizes back to the initial text (§4.12), for example after typing a duplicate line point, nothing is applied, but the raw cursor line is mapped to the initial writer text before resolving selection.
- If the text changed, the whole new text is parsed into a detached model first (§4.5).
  - **Any error or problem:** nothing is applied. The tab stays in text mode. Each `TH2FileProblem` is marked at its line, and errors without a line number are listed in a message above the editor. The message offers _Keep editing_ and _Discard text changes_.
  - **No errors and no problems:** the final normalized text becomes one command on the canvas undo stack (§4.6). The canvas, the element tree and the dirty state update. The cursor line is then mapped on the updated model (§4.4, §4.12).
- Lines the parser will rewrite or drop don't block the apply. They carry information markers while the user edits (§4.12), and the model gets the normalized text.

### 3.5 Undo

- **In text mode**, undo and redo work as in the `thconfig`/`.th` editor: `Ctrl+Z` and `Ctrl+Shift+Z` use the `TextField`'s own history, which groups typing by 500 ms pauses (§2.1). They reach back only to the start of the text session, or to the last save (§3.6). Neither action changes the canvas model until an apply.
- **On the canvas**, one successful text apply is one undo step, regardless of how many lines were changed, how often the cursor moved, or how many text-editor undo/redo actions occurred. `Ctrl+Z` restores the exact model from before that apply; `Ctrl+Shift+Z` restores its result. Older canvas commands remain below it on the same undo stack (§4.7).
- Leaving text mode or saving applies the current final text once. If it is unchanged, or normalizes to the initial text, no canvas command is added. If it does not parse, nothing is applied and the editor remains open (§3.4).

### 3.6 Save in text mode

Save (button, `Ctrl+S`, Save All) first applies the text as in §3.4, then saves through the normal TH2 path. **If the text doesn't parse, nothing is written**, and the problems are shown as in §3.4. Mapiah never writes a `.th2` file it can't read back. The tab stays in text mode after a successful save, and the text is regenerated from the saved model. This is the normalized text, exactly what was written, so lines the parser rewrote or dropped show their saved form. The cursor line is kept through the mapping in §4.12.

The regenerated text **starts a new text session**. It must not enter the `TextField`'s undo history: setting it programmatically would add it as one more entry, and `Ctrl+Z` right after the save would bring back the text from before the save. The history can't be cleared through a public API, so `TH2TextEditBodyWidget` keys `THTextEditorWidget` with the text session's number. A new session builds a new `TextField` with an empty history, and the cursor line is restored through `pendingScrollToLine`/`pendingSelectionRange`.

### 3.7 Broken files

The broken-file tab body (`TH2BrokenFileBodyWidget`) gets an **Edit as text** button. It opens text mode with the **raw file content from disk**, decoded with the file's encoding. It can't use the writer, because a broken model is missing the lines the parser dropped. The problem list is shown as line markers. Applying or saving works as in §3.4 and §3.6. Save applies the text before the check that today refuses to save a broken file (§4.8). Once the text parses cleanly, the controller stops being broken, and the canvas becomes available.

A broken model can't be compared line by line with the fixed text, because the model doesn't match the disk text. So the first apply of a broken file replaces the whole model. That replacement is a **new baseline, not an undo step**, like a file load (§4.7). A canvas `Ctrl+Z` can never bring back the broken, incomplete model, because Save would then write a file that is missing the lines the parser dropped. The fixed file counts as unsaved until it is saved. To go back to the broken state, the user reloads the file from disk. After that, the file is valid, and later text sessions each apply as one canvas undo step (§4.6).

### 3.8 Element-tree edits in text mode

The element tree stays usable while a tab is in text mode. Its edits (drag and drop, drawing order, _Move to scrap_) change the model, which the text doesn't show yet. So a tree edit **applies the text first**:

1. If the text changed, it is applied as when leaving text mode (§3.4): one canvas undo step.
2. If the text doesn't parse, nothing is applied and the tree edit is **cancelled**. The tab stays in text mode with the problems marked and the "can't apply" message (§3.4), so the user sees why the drop or the menu action did nothing.
3. Otherwise, the tree edit runs on the applied model, as its own canvas undo step. An element the edit names that the apply removed or replaced (§4.7) makes the edit a no-op, as for any stale tree row.
4. The tab stays in text mode. The text is regenerated from the edited model, as after a save (§3.6), and starts a new text session. The cursor stays on the element it was on, or the nearest line if that element is gone. The selection the tree sets after the edit then moves the cursor as a tree click does (`t3981`).

A tree edit made with unchanged text skips steps 1 and 2.

## 4. Design Decisions

### 4.1 Mode lives on `TH2FileEditController`, text state on a new `TH2TextEditController`

- `TH2FileEditController` gains `@observable TH2EditMode editMode` (`canvas`, `text`) and `@readonly TH2TextEditController? _textEditController`. The text controller is created when text mode is first entered, and dropped when the tab's controller is disposed.
- `TH2FileEditBodyWidget` shows `TH2TextEditBodyWidget` when `editMode == text`, and otherwise keeps today's canvas/broken logic. The mode is per tab, because it belongs to the tab's controller. It survives tab switches, and project-tree clicks don't reset it.
- A split view could later show both widgets. The single `editMode` value would then become two visibility flags.

### 4.2 The text source

- **Valid file:** a new `TH2FileEditController.serializeForTextMode()` returns `TH2FileWriter().serializeWithLineMap(_th2File, includeEmptyLines: true, useOriginalRepresentation: true)`, with the line ending normalized to `\n`. Passing `lineEnding: '\n'` to the writer isn't enough, because the source text of parsed elements keeps its own endings (§2.4). So the method normalizes the writer's output itself, turning every `\r\n` and lone `\r` into `\n`. It shares its writer options with `_encodedFileContents()`, so the two can't drift apart. `TH2TextEditController.initialContent` keeps this text for dirty and no-op checks (§4.6).
- **Broken file:** the raw bytes from disk (or `_th2File.fileBytes` when it's set), decoded with the parser's encoding detection, which becomes a public static helper.
- Before any parse of editor text (idle validation or apply in §4.6), the text is converted back to the file's line ending (`TH2File.lineEnding`, §2.5). It is encoded with the encoding its own `encoding` line names, as the parser already does on load. Elements parsed from the text then carry the file's line ending in their source text.
- An apply replaces the whole model with the one parsed from the text (§4.6), so **every** line, changed or not, then carries the file's line ending. A file with mixed line endings is unified to the ending of its first line on its first apply, and a save writes it that way. Before an apply, nothing changes: the save path keeps each line's original ending, as today. This is accepted: Therion reads any of them, and mixed endings are almost always accidental.
- A lone `\r` is a line ending in the editor (it becomes `\n` above), but not for the parser (§2.3). So a lone `\r` in a stored line shows as a line break in text mode, and after an apply it is a real line break in the file. This is accepted too: a lone `\r` inside a TH2 line is almost certainly damage.
- Every comparison between writer output and editor text is made on `\n`-normalized text. This includes the apply check in §4.6 and the "text unchanged" test in §3.4. A file with mixed line endings therefore doesn't count as changed.

### 4.3 Writer line map (model MPID → line range)

`serializeWithLineMap` returns `(String text, TH2TextLineMap lineMap)`. It uses a **line ledger**:

- A single private `_emit(int mpID, String chunk)` returns `chunk`. In ledger mode, when `chunk` isn't empty, it appends `(mpID, startOffset, chunk.length)` to the ledger, where `startOffset` is the total length of earlier emitted chunks. The offset is in the writer's original output, before the `\n` normalization in §4.2. This also records a final line with no line ending, which counting line endings alone would miss.
- `_emit` goes in the **leaf producers only** (§2.4):

  | Leaf | Attributed to |
  |---|---|
  | `_elementOriginalLineRepresentation(element)` | the element |
  | `_prepareLine(line, element)`, including every part of a wrapped line | the element |
  | `_commandOptionOriginalLineRepresentation(option)` and the generated option line in `_linePointOptionsAsString` | the line segment (`option.parentMPID`) |
  | the generated branches of `_serializeXTherionConfig`, `_serializeXTherionImageInsertConfig`, `_serializeMapiahImageInsertConfig` and `_serializeMultiLineCommmentContent` | the element. An image written in XTherion format goes through `_serializeXTherionImageInsertConfig` with the temporary element (§2.3), whose MPID is the model element's, so its line is attributed correctly |
  | both branches of `_serializeEmptyLine` | the empty line |
  | the synthesized `encoding` line | the file |

- Composers (`_prepareLineWithOriginalRepresentation`, `serializeElement`, `_childrenAsString`, `_serializeAllXTherionConfigs`, `_trySerializeXTherionConfig` and the per-type serializers) get **no** `_emit`. `_prepareLineWithOriginalRepresentation` in particular only delegates, so an `_emit` there would count every generated line twice.
- **Rule**, stated in a comment on `_emit`: a leaf's result is appended to the output exactly once, in the order the leaf was called, and never thrown away or reordered. The current writer follows it: every composer computes a header before its children, and a line segment before its option lines.
- **MPID check.** In ledger mode, `_emit` asserts that `mpID` names an element of the file being written, or the file itself. A future temporary element built with a fresh MPID, instead of reusing the model element's as the #46 image conversion does, then fails the fixture test instead of producing lines that belong to no element.
- **Length check.** In ledger mode, `serializeWithLineMap` asserts that the ledger's offset spans are contiguous and their lengths add up to the output's length. This catches a chunk that bypasses `_emit` without a line ending (such as one part of a wrapped line), a chunk that is counted twice, or a chunk that is recorded but never appended.
- Output order equals text order. Scan the output once for line starts, treating `\r\n`, `\n` and a lone `\r` as one line ending. Each nonempty ledger span owns the lines containing its characters; an ending belongs to the line before it. Thus a final chunk without an ending still owns its final line, while a trailing ending doesn't create another owned line. Convert these lines to 0-based editor lines after `\n` normalization (§4.2). An element's **own lines** are the lines of its ledger spans. Its **range** runs from its first own line to the last line of its last descendant.
- `serialize` and `toBytes` keep their signatures and their exact output. Ledger mode is off by default.
- A test checks that the ledger's spans cover the returned text exactly, including a final unterminated line, and that `serialize`'s output is unchanged byte for byte. Loaded fixtures only run the "stored text" branches, so the test covers the generated ones too:
  - every fixture in `test/auxiliary/*.th2`, written with `useOriginalRepresentation` both `true` and `false`;
  - a model built with commands, whose elements have no stored text. It includes new settings elements (the `_trySerializeXTherionConfig` path), a file with no `encoding` line, a line long enough to wrap, line-point options with no stored text, and a `##MAPIAH##` image that XTherion can represent, next to one it can't (rotated or scaled).

  An output site that bypasses `_emit`, or an `_emit` in a composer, makes the test fail.

`TH2TextLineMap` (new, `lib/src/auxiliary/th2_text_line_map.dart`) keeps each element's own lines and range, and a sorted `line → owning MPID` array for reverse lookup. Line numbers are 0-based here to match the editor's `cursorLine`. Conversion from the parser's 1-based numbers happens in one place.

### 4.4 Parser line map and ownership resolution

- `TH2FileParser` gains `Map<int, int> elementStartLines` (MPID → 1-based `_currentLineNumber`). It is filled by a private `_addElement(...)` helper that wraps the 21 `executeAddElement` calls. It records only where each element **starts**. Some lines aren't element starts:
  - the continuation lines of a multi-line value: a bracketed or quoted value that continues on the next line, or a line ending with `\` (a joined parseable line keeps the number of its first line, §2.3);
  - line-point option lines (`smooth`, `subtype`, …), which become options of the preceding line segment and have no `executeAddElement` call of their own.

  So an element's own lines are derived: they run from its start line up to the line before the next recorded start line, in file order. A parent's own lines stop before its first child's start line. This attributes continuation lines to the element they continue, and option lines to their line segment, as the writer's ledger does (§4.3). Entries for elements that the clean-up passes remove (`_linesCleanUp`, `_areasCleanUp`) are dropped before the own lines are derived. The resulting map gives the **raw-text** lines of a detached model's elements. It is used for the line numbers of normalization records (§4.12), and `t3962` checks it against the writer's map, including option lines and multi-line values. The comparison runs on `\n`-normalized text, because the parser doesn't break lines at a lone `\r` (§2.3) while the editor does (§4.2). The apply uses the writer's map of the normalized text for selection and identity matching (§4.6, §4.7).
- `TH2TextElementLocator` (new, pure, `lib/src/auxiliary/th2_text_element_locator.dart`) turns a line and a `TH2TextLineMap` into a `TH2TextLocation`, following §3.3:
  1. Find the element that owns the line (the reverse array).
  2. If it's a line segment, or a line-point option line owned by one, return `selectLinePoint(lineMPID, lineSegmentMPID, scrapMPID)`.
  3. Otherwise, walk up `parentMPID` until reaching a `THPoint`, `THLine`, `THArea` or `THScrap`, or the file.
  4. Return `selectElement(mpID, scrapMPID)`, `activateScrap(scrapMPID)` or `fileLevel`.
- The locator is pure and gets its own unit tests. `TH2FileEditController.applyTextLocation(location)` carries the result out on the canvas. It uses the tree's single-tap sequence for `selectElement`, and the double-click sequence plus `setSelectedEndControlPoint` for `selectLinePoint` (§2.6).

### 4.5 Detached parse

`TH2FileParser.parse` gains an optional `TH2FileEditController? targetController`. When it's given, the parser uses that controller instead of looking one up in `MPGeneralController`. Text mode creates a **scratch controller**, `TH2FileEditControllerBase.createForDetachedParse(filename, th2FileMPID)`. It is never registered and never gets a tab. Its `TH2File` uses the real file's MPID, so top-level `parentMPID`s already point at the real file. The `TH2File()` constructor always takes a new MPID from `nextMPIDForTH2Files()` (`th2_file.dart:80-82`), so `TH2File` gains a named constructor, `TH2File.withMPID(int mpID)`, that sets `_mpID` to the given value instead. Because the scratch file has the real file's MPID and filename, it can be `==` to the live file (§2.5). §4.7 therefore never adopts the scratch file's element objects into the live file. MPIDs come from the global counter (`nextMPIDForElements`), so they can't collide with the live model. The scratch controller is disposed after each parse; the detached file result may be cached independently (§4.6).

`createForDetachedParse` runs only `_create()` and `_basicInitialization`. It never calls `_finalFilePreparations` or `_initializeReactions` (§2.5). The scratch controller shares the real file's filename, so the dirty-mirroring reaction (`:1034-1049`) would otherwise add or remove the real file's path in `THProjectController.dirtyFilePaths`. A doc comment on the factory states this, and an `assert` in `_initializeReactions` rejects a detached controller.

The current editor content gets a detached parse after an idle delay and again at apply if the cached result is stale (§4.6). The parse validates the final text and supplies the replacement model.

### 4.6 Current-buffer validation and one apply

`TH2TextEditController` holds the current `content`, `initialContent`, cursor position and diagnostics. The `TextField` owns its undo history. No canvas checkpoints are recorded on cursor moves, typing, find/replace, or text-editor undo/redo.

After a change, debounce a detached parse of the **current buffer** by `mpTH2TextValidationIdleMilliseconds`. Cache its result with the exact content string it parsed: validity, problems, normalization records, normalized text *N(T)* and writer line map. If the content changes again, discard the stale result. This gives current problem and normalization markers even when the cursor stays on one line. At apply or Save, reuse the cache only if its content still equals the current buffer; otherwise parse the current buffer before proceeding. A parser error or problem blocks the apply and leaves the model and canvas undo stack untouched (§3.4).

`MPLineDiffAux` (new, pure) compares lines with Myers' O(ND) algorithm. It supplies matched pairs and hunks for the raw-text ↔ normalized-text notices and cursor mapping (§4.12), and for unambiguous element identity matching between the live and detached writer outputs (§4.7). There is no per-line command construction.

If the final normalized text equals `initialContent`, the apply creates no canvas command. Otherwise, take a deep `before` snapshot of the live file, match unambiguous unchanged MPIDs into the detached model (§4.7), and take an `after` snapshot. Assert that the remapped model still serializes to *N(T)*. Execute one `MPReplaceTH2FileContentsCommand` through `MPUndoRedoController`, with a localized description such as "Text edit". The command uses `TH2File.replaceContentsFrom` to update the existing live `TH2File`; undo and redo restore the two snapshots. This makes the final model valid after either action, even if the user passed through incomplete syntax while typing.

The controller refresh (stale selection and hidden MPIDs, selectable elements, active scrap, snap targets, structure revision) is not a step of the apply. It runs inside the command (§4.7), so apply, undo and redo all get it. After a successful apply, the apply itself only maps the final raw cursor line through *N(T)* to the live writer line map and ends the text session. The next entry to text mode starts from newly serialized content.

### 4.7 Whole-file apply command and broken-file baseline

`MPReplaceTH2FileContentsCommand` (new) holds two deep snapshots, `before` and `after` (`TH2File.toMap()` maps). Add `lineEnding` to `TH2File.toMap()` and require it in `fromMap()`. Update `TH2File.forCWJM` and `copyWith()` to carry the value too, so copying a file doesn't silently reset its line ending. The command's `_actualExecute` calls a new `elementEditController.executeReplaceTH2FileContents(Map<String, dynamic> snapshot)`, following the pattern of the other commands (§2.5). That method runs `TH2File.replaceContentsFrom(TH2File.fromMap(snapshot))` and then `syncControllersWithModel(initialSetup: false)` (below). Apply, undo and redo all run the same `_actualExecute`, with the `after` or `before` snapshot, so all three refresh the controllers in the same way, without any change to `MPUndoRedoController`. The live `TH2File` object never changes, so the sub-controllers' references (§2.5) stay valid. Undo restores `before` with its original MPIDs, so older commands stay valid.

`TH2File.replaceContentsFrom(TH2File source)` (new):

1. Clears the same registries and caches as `clear()` (element map, children, thID registries, type sets, scrap/image/setting lists, area-line maps, bounding box). Unlike `clear()`, it keeps `filename`, `fileBytes`, `mpID` and `isNewFile`.
2. Takes the source's `encoding` and `lineEnding`.
3. Puts **all** of the source's elements into the element map, and copies its `childrenMPIDs`.
4. Only then calls `element.setTH2File(this)` on **every** element, and `_updateSupportMaps(element)`. All elements must be in the map first, because `setTH2FileToChildren` looks children up through the file (`th_is_parent_mixin.dart:82-86`). Calling it on every element, not only the top-level ones, doesn't depend on the parents passing it down.

**Element back-references (§2.5).** The source must be a **fresh `fromMap` copy** whose elements belong to no file (`th2File == null`). Then the early return in the `setTH2File` of `THScrap`, `THArea` and `THLine` can't fire, since `null` never equals the live file. Elements still pointing at another `TH2File` would be the problem: if that file has the live file's MPID and filename, as the scratch file does (§4.5), the deep `==` can find them equal and skip the children and options, which would keep pointing at the scratch file. So:

- No path passes the scratch file, or any element object from it, to `replaceContentsFrom`. The apply command already uses its snapshot maps. The broken-file baseline below uses `TH2File.fromMap(detached.toMap())` as well.
- `replaceContentsFrom` asserts that every source element and option has `th2File == null` on entry, and that every element and option has `identical(th2File, this)` on exit. Both checks use identity, not `==`.

**Controller refresh.** `TH2FileEditController.syncControllersWithModel({required bool initialSetup})` (new) brings every sub-controller in line with the current model. It is the **only** place this is done: a valid load, the broken-file baseline below, and every apply, undo and redo of `MPReplaceTH2FileContentsCommand` call it. In order:

1. **Selection.** Drop the MPIDs that no longer exist from the logical selection, the selected line points (`_selectedEndControlPoints`), the selected scraps (`selectedScrapMPIDs`) and the `isSelected` flags. Then `resetSelectableElements()` and `updateSelectableEndAndControlPoints()`. On a load nothing is selected yet, so this does what `clearIsSelected()`/`setIsSelected(..., false)` do there today.
2. **Hidden elements.** Drop the MPIDs that no longer exist from the hide controller's `_hiddenElementMPIDs` and `_hiddenScrapMPIDs`.
3. **Active scrap.** Keep it if it still exists, otherwise use the first scrap (the same rule as the file-level row of §3.3). Then `updateHasMultipleScraps()`. A file with no scrap keeps today's load behavior: no active scrap is set.
4. **Snap targets.** With `initialSetup`, and when the file has a scrap, set the load defaults (`setSnapTargets(point, linePoint, [shot])`, today `:835-839`). Then `updateSnapTargets()` recomputes the targets from the model in every case, keeping the snap choices the user made.
5. **Station cache.** Without `initialSetup`, mark the Therion station cache dirty (`_markTherionStationPointNameCoordinateCacheDirty`), since any point may have changed.
6. **Used types.** Only with `initialSetup`, run `initializeUsedTypes()`. It counts every type again each time it runs (§2.5), so an undo or redo must not run it. Types that only a text apply introduces are counted when the user next uses them, as for any other element.
7. `updateEnableSelectButton()`, `triggerAllElementsRedraw()`, and finally `bumpStructureRevision()`, so the element tree rebuilds from the refreshed state.

A valid load calls it with `initialSetup: true` from `_finalFilePreparations`, which keeps only `_initializeReactions()`, `setFilename` and `_isLoading` (§2.5). The method now runs after the reactions are installed. The reactions are autoruns that re-run whenever their inputs change, so they end in the same state either way. The existing load tests check this.

Before taking the `after` snapshot, match unchanged elements in the live and detached models through the matched line pairs in the diff of their normalized writer outputs (§4.6). Reuse a live MPID only when all of the element's own lines match all of one detached element's own lines, both elements have the same type, and the match is unique in both directions. An arbitrary diff pairing must not disambiguate duplicate elements with identical own lines; leave those and changed elements with their detached MPIDs. Remap every MPID reference in the detached model consistently (element-map keys, parent and child MPIDs, option owners and other element references), then rebuild the thID and derived registries. Assert that serialization still equals the target normalized text. This keeps identity for clearly matched elements even when a scrap boundary moves; if identical lines make a match ambiguous, identity for those elements may change during an apply.

Every successful apply of a valid file uses this command once. Its `before` snapshot is a valid live model, so undo safely restores it before any older canvas command can run.

**Broken-file baseline.** The first apply of a broken file (§3.7) doesn't use this command:

1. Once the text parses cleanly, `TH2File.replaceContentsFrom(TH2File.fromMap(detached.toMap()))` puts a fresh copy of the detached model in place directly, with no command. `_isBroken` and `_problems` are cleared.
2. `undoRedoController.clearUndoRedoStack()` (`mp_undo_redo_controller.dart:110`) then runs, as `_actualSave` does. Nothing below this point can be undone, so the partial model is gone for good. Nothing else is lost: the stack is already empty. A broken file starts with an empty stack, and its tab shows the broken-file body instead of the canvas, so no canvas command can run. The element tree's moves and drawing-order actions also refuse a broken file (`th2_file_edit_element_edit_controller.dart:1397`, `:1462`).
3. **Canvas setup.** A broken load skipped the canvas setup in `_finalFilePreparations` (§2.5), so it runs now: the broken apply calls `syncControllersWithModel(initialSetup: true)` after step 2. That sets the active scrap, the default snap targets and the used types for the first time, as a valid load does. It doesn't run `_initializeReactions()` again: the broken load already installed the reactions (`:842`), and installing them twice would mirror the dirty state twice.
4. With an empty stack, `enableSaveButton` would be false, and the Save button, the dirty dot and Save All would treat the fixed file as saved. So the controller gains `@readonly bool _hasUnsavedBaseline`, which the broken apply sets. `enableSaveButton` becomes `!_isBroken && (_hasUndo || _hasUnsavedBaseline) && !_th2File.isNewFile`, and `hasUnsavedChanges` (§4.8) follows. `_actualSave` and a reload clear the flag.
5. The way back is the existing paths. Before the apply, _Discard text changes_ (§3.1) returns to the broken-file body with the model untouched. After the apply, Reload (`MPGeneralController.reloadTH2File`, on the project tree's context menu and on the broken-file body) reads the file from disk again. The broken state then comes back from the file itself, not from a stored partial model. Reload doesn't ask before it drops an unsaved fix, as it doesn't for any edited file today (§2.5). Until it is saved, the fix shows as unsaved (item 4), so the dirty dot and the Save button make that visible.
6. Canvas edits and later text sessions stack up above the baseline as usual. Undoing all of them stops at the fixed text.

**Rejected alternative:** making the broken apply an undoable command that sets `_isBroken`/`_problems` back on undo. A canvas `Ctrl+Z` would then swap the canvas for the broken-file body, and redo would have to run from a screen with no canvas key handling. The command would own controller state outside the model. And it would give nothing useful: the disk file already holds the broken state.

**Rejected alternative:** reusing Reload (`MPGeneralController.reloadTH2File`) to build a new controller from the text. It throws away the undo history and all per-controller view state (zoom, active scrap, overlays), and the text edits could not be undone.

### 4.8 Dirty state and saving

- `TH2FileEditController` gains `@computed bool hasUnsavedChanges => enableSaveButton || (_textEditController?.isDirty ?? false)`.
- `hasUnsavedChanges` replaces `enableSaveButton` as the **dirty** signal in the dirty-mirroring reaction (`:1032-1049`), in `shouldKeepTablessTH2Controller` and in `_saveTH2ProjectFile`'s "already saved" check. `enableSaveButton` keeps its current meaning, "the model has unsaved changes".
- **Save's enabled state** is a new `@computed bool canSave => hasUnsavedChanges && !_th2File.isNewFile`. It replaces `enableSaveButton` at every place that enables or runs Save (§2.2): the app bar's Save button, the overflow menu's Save item, `_saveActiveTab`, and the canvas `Ctrl+S` handler. The `!isNewFile` term keeps today's rule that **Save is disabled for a new file** (§2.2), which only Save As can write. Without it, text edits in a new file would enable Save, and `saveTH2File()` would write to the placeholder name.
- `saveTH2File()` also gets its own guard: on a new file, it returns without applying or writing. This covers the text editor's own `Ctrl+S` (`th_text_editor_widget.dart:489-492`), which calls `TH2TextEditController.save` and so the owner's `saveTH2File()` without going through `canSave`. In a new file, `Ctrl+S` in text mode therefore does nothing, as on the canvas today, and `Ctrl+Shift+S` (page level) opens Save As.
- `saveTH2File()` in text mode runs the apply first and returns a result: `saved` or `textHasProblems`. The apply runs **before** the existing `if (_isBroken) return;` guard at the top of `saveTH2File()` (`:1661`). For a broken file, a successful apply clears `_isBroken` and sets `_hasUnsavedBaseline` (§4.7), so the guard then lets the save through. A failed apply returns `textHasProblems` without reaching the guard. Outside text mode, the guard is unchanged, so a broken file with no text session still can't be saved. `_saveTH2ProjectFile` maps `textHasProblems` to a new `TH2FileSaveStatus.textHasProblems`, so Save All reports the file as not saved instead of failing silently.
- **Save As in text mode** applies first, before the file picker opens and before the `if (_isBroken) return;` guard at the top of `saveAsTH2File()` (`:1674-1677`). When the text doesn't parse, it is refused in the same way as Save, and no picker opens. A successful apply on a broken file clears `_isBroken` (§4.7), so the guard lets it through. The app bar's Save As button and the overflow menu's Save As item, both disabled today for a broken file (§2.2), are enabled for a broken file in text mode.

### 4.9 Editor widget reuse

- Extract `THTextEditorBuffer`, an abstract class with the members listed in §2.1, plus `List<THTextEditorDiagnostic> get diagnostics` and `THTextEditorLanguage get language`. `THTextEditorController` and the new `TH2TextEditController` implement it. `THTextEditorWidget` takes `THTextEditorBuffer`.
- The find/replace state and logic move from `THTextEditorController` into a `THTextEditorFindMixin` used by both, so they behave the same.
- `THTextEditorDiagnostic` (line, message, severity) replaces the widget's direct use of `THProjectParseError`. `THTextEditorController` maps its project errors to it. `TH2TextEditController` maps `TH2FileProblem`s (with the localized category from `TH2FileProblemTextAux`), line-less parser errors, and normalization records (§4.12). Severity gains an `information` level, drawn with its own marker color, that never blocks an apply or a save.
- **One marker per line.** The widget draws one diagnostic per line (§2.1), and a line can now get both a problem and an information marker. So `_buildDiagnosticBackground` groups diagnostics by line instead of keeping the last one, and `THTextEditorDiagnosticMarkerWidget` takes the line's list. It uses the color of the most severe one (error, then warning, then information), and its tooltip lists them all, most severe first, so none is hidden.
- `THTextEditorLanguage { therion, th2 }` chooses the tokenizer, the fold keywords and the auto-indent block openers (§2.1). For `th2`, the openers are `scrap`, `line`, `area` and `comment`, matching its folds (§4.10). `tokenizeTherionText(text, language:)` keeps its default, so current callers don't change.

### 4.10 TH2 highlighting and folding

- TH2 keywords: `encoding`, `scrap`, `endscrap`, `point`, `line`, `endline`, `area`, `endarea`, `comment`, `endcomment`. Option words that begin a line inside a `line` block (`smooth`, `subtype`, `orientation`, `l-size`, `size`, `mark`, `altitude`, `adjust`, `direction`, `gradient`, `height`, `border`, `reverse`, `visibility`, `place`, `clip`, `outline`, `close`, `id`) are colored as `option`.
- `##XTHERION##` and `##MAPIAH##` at the start of a line color the whole line as a new `THTextEditorTokenType.setting`, not as a comment.
- The TH2 tokenizer carries state across lines: the lines between `comment` and `endcomment` are colored as `comment`.
- Folds: `scrap`/`endscrap`, `line`/`endline`, `area`/`endarea`, `comment`/`endcomment`.
- Token colors come from the existing editor palette. One new color token is added for `setting`, for light and dark themes.

### 4.11 Centering the canvas without zooming

`TH2FileEditController.revealSelection()` (new) checks the selection's bounding box, or the selected line point, against the visible canvas rectangle. If it isn't fully visible, it moves `_canvasCenterX/Y` to its center, reusing the math in `_setCanvasCenterOnZoom` (`:1603`) but keeping the scale. Like `requestZoomToFit`, it waits for layout when the canvas hasn't been laid out yet, because it runs right after the body widget swaps back to the canvas.

### 4.12 Parser normalization

Parsing a text *T* and writing the result back can give a different text (§2.3). Making the parser lossless was rejected: the clean-up passes keep the model valid (a line needs 2 points, an area needs a border), and they run on every file load, so changing them would change how existing files open. Rejecting text the parser would change was rejected too: it would turn harmless input, such as a duplicate point, into errors, although Mapiah accepts that input when loading a file. Instead, text mode accepts the parser's result and works on it:

- **Normalized text.** For the current text *T*, *N(T)* = `serializeWithLineMap` of its detached model, with the same options and line-ending handling as §4.2. It is the text Save would write. The no-op and apply checks use *N(T)*, not *T* (§4.6).
- **Normalization records.** Each clean-up pass records what it did as a `TH2FileNormalization` (raw line, kind), next to `problems`. The kinds are `rewrittenLine` (`_cleanOriginalLinesInFile`, and `_resolveBorderReference` when it repairs a border reference, §2.3), `removedDuplicateLinePoint` and `removedShortLine` (`_linesCleanUp`), and `removedEmptyArea` (`_areasCleanUp`). Moved and added lines aren't records: they come from the diff in the next item. Their line numbers come from the parser's start lines (§4.4). Loading a file ignores the records, so loading behaves as today.
- **Other differences.** Some changes don't come from the parser. The writer adds an `encoding` line when the first line isn't one, and it writes a `##MAPIAH##` image line that XTherion can represent as a `##XTHERION##` line (§2.3). To catch them, the current text *T* is diffed against *N(T)* with `MPLineDiffAux`. Each raw line with no match and no record gets a generic "Mapiah will rewrite this line" marker. A line that exists only in *N(T)* gets a "Mapiah will add: …" marker on the raw line before which it would be inserted. First, though, each unmatched *T* line is paired with an identical unmatched *N(T)* line, if there is one. Such a pair is one line that the writer relocated, like a setting typed away from the settings block (§2.3). It gets a single "Mapiah will move this line to line X" marker, with X counted in *N(T)*, and no rewrite or add marker. In debug builds, an unmatched line with no record is also logged, so that a new clean-up pass that doesn't record its changes gets noticed.
- **Markers.** Records and unmatched lines become `information` diagnostics (§4.9), with one localized message per kind. The user sees each rewrite at its line while editing, before leaving text mode, and nothing is blocked.
- **Cursor mapping.** A raw line of the final *T* is taken to *N(T)* through the matched pairs of the *T* ↔ *N(T)* diff. A line with no match goes to the nearest matched line above it. This is used after an apply (§4.6) and after a save, when the editor shows *N(T)* (§3.6).

### 4.13 Tree edits in text mode

- **Apply step in the gate.** `prepareTH2FileForTreeEdit` (§2.6) gains the apply step of §3.8, after it activates the tab, so the "can't apply" message shows on the right tab. When the controller is in text mode, it calls a new `TH2FileEditController.applyTextBeforeExternalEdit()`. That runs `applyTextContent` with the current buffer (§4.6), shows the "can't apply" message on `rejected`, and returns whether the edit may go on. On `rejected`, the gate returns `null`, so the three callers cancel the edit without changes. The apply happens in one place for every current tree edit, and any future tree edit that uses the gate gets it too.
- **Stale MPIDs.** The apply may give changed elements new MPIDs (§4.7), and the callers hold MPIDs from the pre-apply tree. They need no change: the edits validate their MPIDs against the current model when they run (§2.6), so a stale MPID is a rejection or a no-op, and the tree rebuilds from the structure revision the apply bumped. Elements whose lines didn't change keep their MPIDs, so the usual case, moving an element the user didn't edit, works.
- **Regenerating the text.** While `editMode == text`, `TH2FileEditController.execute(command)` (`:1808`) tells the text controller to start a new session after the command runs, except for the text apply's own `MPReplaceTH2FileContentsCommand`. In text mode the canvas is hidden, so any other command comes from outside the text editor, today only from the tree. The new session works as after a save (§3.6): the text is serialized again, `THTextEditorWidget` is rebuilt with a fresh `TextField` history, and the cursor is restored through `pendingScrollToLine`/`pendingSelectionRange`. The cursor's element is found through the line map from before the command, and its line through the new one.
- **Undo.** The text apply and the tree edit are two canvas undo steps. `Ctrl+Z` in the text field still only undoes typing (§3.5), and its history starts again at the regenerated text.
- **Broken files.** The gate already refuses a broken file, so a broken file in text mode allows no tree edit until its text is applied (§3.7).

## 5. Implementation Phases

Each phase ends with `flutter analyze` clean and `flutter test` green. New tests start at `t3960`.

### Phase 1: Line maps and locator (no UI)

- `TH2TextLineMap`, the writer's `_emit` ledger and `serializeWithLineMap` (§4.3).
- The parser's `elementStartLines` and the `_addElement` helper (§4.4).
- `TH2TextElementLocator` (§4.4).
- Tests:
  - `t3960`: the ledger's offset spans cover the output exactly, every nonempty output line has an owner, and `serialize`'s output is unchanged byte for byte. This is checked for every fixture in `test/auxiliary/*.th2` that parses cleanly, with `useOriginalRepresentation` both `true` and `false`, and for a command-built model with no stored text (§4.3). Some fixtures are deliberately broken, for the broken-file tests: a fixture whose parse reports problems or errors is skipped, and the test asserts that at least one fixture was checked.
  - `t3961`: own lines and ranges for points, lines, line segments with option lines, areas, border references, scraps, settings, empty lines, multiline comments, wrapped long lines, multi-line values (bracketed, quoted and `\`-continued), and a final line without a line ending. Reverse lookup of that final line returns its element.
  - `t3962`: on a round-tripped fixture, the parser's map of the parsed model agrees with the writer's map of the same model. Both use that model's MPIDs, so they are compared directly.
  - `t3963`: every row of the table in §3.3.

### Phase 2: Detached parse, diff and one apply command

- `targetController` on `TH2FileParser.parse`, and `createForDetachedParse` (§4.5).
- `MPLineDiffAux` (§4.6).
- `TH2FileNormalization` records in the three clean-up passes, *N(T)* and the *T* ↔ *N(T)* line mapping (§4.12).
- `TH2File.withMPID` (§4.5), `TH2File.replaceContentsFrom` and `MPReplaceTH2FileContentsCommand`, with its factory entry and localized description (§4.7).
- `elementEditController.executeReplaceTH2FileContents` and `syncControllersWithModel({initialSetup})`. `_finalFilePreparations` is moved onto it (§4.7).
- `TH2FileEditController.applyTextContent(String content)`, which returns `applied(lineMap)`, `unchanged(lineMap)` or `rejected(problems, errors)`. It uses the final detached parse, MPID matching and one snapshot command (§4.6).
- Tests:
  - the controller lifecycle tests `t3944` and `t3945` pass unchanged: scratch controllers are never registered and are disposed after use;
  - `t3964`: a detached parse doesn't register or replace any controller in `MPGeneralController`, and leaves `THProjectController.dirtyFilePaths` unchanged;
  - `t3965`: `MPLineDiffAux` on insertions, deletions, modifications, mixed hunks, empty texts and identical texts;
  - `t3966`: editing several lines in one session creates one canvas undo step. Undo restores the exact pre-apply text; redo restores the final normalized text. An older canvas command still undoes and redoes correctly afterwards. Separate successful text sessions create separate steps;
  - `t3985`: the controllers stay in line with the model through apply, undo and redo. Undoing an apply that added a scrap while that scrap is active makes the first scrap active, and `hasMultipleScraps` follows. An element that the undo removes, which was selected, hidden or a selected line point, leaves its MPID in neither the selection, the hidden sets, the `isSelected` flags nor the selectable elements. Redo gives the same controller state as the apply. Snap targets and the station cache reflect the restored model. Used-type counts don't change on undo or redo. A valid load gives the same controller state as before the change;
  - `t3967`: clearly matched unchanged elements keep their MPIDs through apply and redo; ambiguous duplicate lines need not. Added points, lines and scraps have valid parent and child MPIDs, and area border references resolve after apply, undo and redo. After each of them, every element and option of the live file has `identical(th2File, liveFile)`, including the children of scraps, lines and areas, and `replaceContentsFrom` rejects a source whose elements still point at a file;
  - `t3968`: a session with temporarily invalid text applies once when its final text is valid. A moved `endscrap` also applies once. For a CRLF file, apply, undo and redo preserve `lineEnding` and serialized bytes; `TH2File.copyWith()` preserves CRLF. A file with mixed line endings is unified to its first line's ending by the first apply (§4.2);
  - `t3969`: text with a problem or error is rejected, and the model and undo stack are unchanged;
  - `t3970`: the live model serializes to the final normalized text. Cover a duplicate line point, a short line, an empty area, a rewritten scrap option, a repaired border reference (`b@1` for a line stored as `b_1`), a deleted `encoding` line, moved settings, a setting typed inside a scrap, and a representable `##MAPIAH##` image. Check normalization markers and cursor mapping. A final text that normalizes to the initial text gives no canvas step;
  - `t3971`: a large fixture measures idle validation and one apply, including cached and uncached final parses.

### Phase 3: Editor generalization and TH2 highlighting

- `THTextEditorBuffer`, `THTextEditorFindMixin`, `THTextEditorDiagnostic` and `THTextEditorLanguage` (§4.9). Refactor `THTextEditorController` and `THTextEditorWidget` onto them with no behavior change.
- The TH2 tokenizer and folds (§4.10).
- `TH2TextEditController` (MobX): `content`, `initialContent`, `isDirty` (`content != initialContent`), cursor, pending scroll/selection, diagnostics, find, the owning `TH2FileEditController`, and current-buffer idle validation with its content-keyed cache (§4.6). `save` and `revert` delegate to the owner (§3.6, discard).
- The `information` diagnostic severity and its marker color, and per-line diagnostic grouping (§4.9, §4.12).
- Keep the existing `TextField` undo/redo bindings for `Ctrl+Shift+Z` (§2.7); no checkpoint notifications are needed.
- Tests:
  - the existing tests that use the text editor (in `t3900`–`t3937`), and `t3956` (the `Ctrl+Shift+Z` redo shortcut), pass unchanged;
  - `t3972`: TH2 tokens, including `##XTHERION##` lines, multiline comments, options and line-option words;
  - `t3973`: TH2 fold regions and auto-indent openers. `information` diagnostics render with their own marker. A line with both an error and an information diagnostic shows the error's color, and its tooltip lists both. A `therion` editor still auto-indents only after its own openers;
  - `t3974`: idle validation tracks the current buffer even while the cursor stays on one line. A stale parse result cannot replace diagnostics for newer text; apply reparses when the cache is stale.
  - `t3975`: `Ctrl+Z`/`Ctrl+Shift+Z` in TH2 text mode behave as in the `thconfig` editor, and the `thconfig` editor's undo is unchanged. Text undo/redo changes the current buffer and its diagnostics, without touching the canvas model.

### Phase 4: Mode switching, synchronization and saving

- `editMode`, `enterTextMode()`, `leaveTextMode()`, `discardTextEdits()`, and `TH2TextEditBodyWidget` (§4.1). The toggle button and `F2` (§3.1).
- Graphical → text cursor placement (§3.2), and text → graphical selection, including _Line edit_ mode for line points, plus `revealSelection()` (§3.3, §4.4, §4.11).
- The "can't apply" message with _Keep editing_/_Discard text changes_ (§3.4).
- Tree edits in text mode: the apply step in `prepareTH2FileForTreeEdit` through `applyTextBeforeExternalEdit()`, and the new text session after any other command executed in text mode (§3.8, §4.13).
- `hasUnsavedChanges` and `canSave`, and their adoption at the call sites in §4.8, with the new-file guard in `saveTH2File()`. Save and Save As in text mode, each starting a new text session with a fresh `TextField` history (§3.6), and `TH2FileSaveStatus.textHasProblems`.
- Tests (widget tests use the `TH2FileTabsPage` setup of `t3950`):
  - `t3976`: with two elements selected in reverse file order, text mode puts the cursor on the one nearer the top. In _Line edit_ mode, the cursor goes to the first selected line point.
  - `t3977`: returning with the cursor on each kind of line from §3.3 gives the listed result. A selected line point round-trips: canvas → text → canvas leaves the same point selected in _Line edit_ mode.
  - `t3978`: editing line 10, then line 20, then line 10 again gives one canvas undo step when returning to the canvas. One `Ctrl+Z` restores the pre-session model; one redo restores the final text. Another session creates a second step.
  - `t3979`: invalid text stays in text mode with markers. Discard returns with the model unchanged.
  - `t3980`: the dirty dot, Save and Save All see text-only edits. Save with problems writes nothing and reports `textHasProblems`. After saving text that the parser normalizes, the editor shows the saved text and the cursor stays on the matching line. `Ctrl+Z` right after a save in text mode doesn't bring back the text from before the save. In a new file, text edits leave Save disabled (button, overflow menu, `Ctrl+S` in the text field and on the canvas) and write nothing, while Save As applies and writes. Save As with problems opens no file picker. Save As is enabled for a broken file in text mode.
  - `t3981`: the mode is kept across tab switches. Tree clicks while in text mode move the cursor to the clicked element, using §3.2 with that element. `F2` toggles from both the canvas and the text field.
  - `t3984`: in text mode, with an edited but valid text, a drag and drop, a drawing-order action and _Move to scrap_ each apply the text first and then run. That gives two canvas undo steps, text apply then tree edit. The tab stays in text mode with the regenerated text, a fresh `TextField` history, and the cursor on the moved element. With text that doesn't parse, each one is cancelled: the model, the undo stack and the text are unchanged, and the problems are shown. A tree edit naming an element that the apply replaced is a no-op. With unchanged text, the tree edit runs without an apply step.

### Phase 5: Broken files

- _Edit as text_ on `TH2BrokenFileBodyWidget`, with the raw disk text source (§3.7, §4.2).
- The broken-file baseline: the first apply without a command, clearing the broken state and the undo stack, a call to `syncControllersWithModel(initialSetup: true)`, and `_hasUnsavedBaseline` in `enableSaveButton` (§4.7).
- Tests:
  - `t3940` (broken-file body widget) passes, updated only for the new _Edit as text_ button;
  - `t3982`: a broken fixture opens in text mode with its problems marked at the right lines. Fixing and applying makes the canvas available, with the canvas setup a valid load does: the first scrap is active, `hasMultipleScraps` is right, points and lines are selectable, and snapping works. The dirty-mirroring reaction runs once per change, not twice. Saving writes the fixed text, and Save goes through even though the controller was broken when it started. Save on a broken file that has no text session still writes nothing. After the apply, `Ctrl+Z` on the canvas does nothing, and the file shows as unsaved (Save button, dirty dot). Reload brings back the broken state from disk. A canvas edit made after the apply undoes back to the fixed text, not further. The next text session creates one canvas step on apply.
  - `t3983`: a broken file's text is never saved while problems remain.

### Phase 6: Documentation and localization

- EN/PT strings for the toggle tooltip, the discard action, the "can't apply" message, the apply command description, the save status, the normalization messages (§4.12) and _Edit as text_. Run `flutter gen-l10n`.
- Help: a new "Text mode" section in `th2_file_edit_page_help.md` (EN/PT), with an index entry, covering §3.1–§3.7. Update the "Top right corner" list and the "Broken files" section.
- Keyboard shortcuts: `F2` in `keyboard_shortcuts_edit.md` (EN/PT), in alphabetical order.
- CHANGELOG entry under the next release, referencing #38.

## 6. Risks and Open Questions

1. **Coarser canvas undo.** All edits in one text session become one canvas step. Users can still undo typing within text mode using the existing `TextField` history. Separate applies create separate canvas steps.
2. **Identity matching.** A whole-file apply can keep clearly matched unchanged MPIDs, but identical repeated elements may be ambiguous. Those elements can receive new MPIDs, which may reset their selection or hidden state. `t3967` covers this.
3. **Idle parsing cost.** Large files may make current-buffer validation noticeable. Debounce it, ignore stale results, and measure cached and uncached apply in `t3971`.
4. **Snapshot size.** Each canvas apply stores two deep file snapshots. `t3971` measures the cost on a large fixture.
5. **No unsaved-changes guard.** Unsaved text edits are lost without a prompt when the tab is closed, the app quits or the file is reloaded, as canvas edits are today (§2.5). An app-wide guard for tab close, quit, Reload and project switch, covering every file type, is left to a separate issue. It can use this plan's `hasUnsavedChanges`, which already counts text edits and an unsaved broken-file fix (§4.7, §4.8).
