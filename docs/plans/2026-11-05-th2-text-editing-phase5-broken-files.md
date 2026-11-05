<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 5: Broken Files

**Date:** 2026-11-05
**Status:** Proposed. Based on `feat_38_th2_text_editing` at `40ad86db`, with Phases 1–4 implemented. Line numbers in §2 are from that commit.

**Revalidation rule:** Before starting a step of §5, run `git diff 40ad86db -- lib test`. If it changes files that step's §2 items name, recheck only those items. Whether the implementation is correct is decided by §6's tests and `flutter analyze`.

**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§3.7, §4.2, §4.7, §4.8 and §5 Phase 5)
**Previous phase:** [Phase 4: Mode Switching, Synchronization and Saving](2026-10-15-th2-text-editing-phase4-mode-switching-synchronization-and-saving.md)
**Issue:** [#38](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose and boundaries

Let the user fix a broken `.th2` file in text mode. The broken-file body gets _Edit as text_, and `F2` works there too. Both open a **raw session**: the file's text as it is on disk, decoded with the file's encoding, with the parser's problems marked on their lines. Once the text parses cleanly, the first apply installs it as a **new baseline**, not an undo step. That apply clears the broken state and the undo stack and runs the canvas setup that a valid load runs. The file then counts as unsaved until it is saved. After that, the file behaves like any valid file.

This phase also covers the broken-file items that Phase 4 moved here (Phase 4 plan, §3 change 8): `F2` on the broken-file body, Save As for a broken file in text mode, and the broken-file cases of `t3980`, `t3984`, `t3987`, `t3988` and `t3990`.

All work, including this plan, stays on `feat_38_th2_text_editing`, in its worktree `/home/rodrigo/devel/mapiah-worktrees/feat_38_th2_text_editing` (AGENTS.md, "Parallel Work"). Do not create a Phase 5 branch and do not merge into `main`. The branch merges after Phase 6 at the earliest (parent §5, _Branch and merge_). The main checkout stays on `main`.

Out of scope: help pages, keyboard shortcut pages, CHANGELOG and the final review of the strings (Phase 6), and the native undo first-snapshot delay (Phase 7).

## 2. Current code and dependencies

- **Broken state.** `TH2FileEditController` has `@readonly _isBroken` (`th2_file_edit_controller.dart:182`) and `_problems` (`:186`, a `List<TH2FileProblem>`, each with `kind`, 1-based `lineNumber`, `sourceLine`, `detail`). `_commitLoadResult` (`:872`) sets both. `_finalFilePreparations` (`:918`) installs the reactions for every load, but calls `syncControllersWithModel(initialSetup: true)` only when the file isn't broken (`:921`). `enableSaveButton` is `!_isBroken && _hasUndo && !_th2File.isNewFile` (`:587`). `hasUnsavedChanges` and `canSave` (`:590-597`) build on it.
- **Phase 4 hooks for this phase.** `toggleEditMode()` (`:1884`) calls `enterTextMode()` on the canvas. `_enterTextModeGated` (`:1927`) returns early for `_isBroken` (`:1934`). `applyTextContent` (`:2668`) asserts `!_isBroken` and rejects with `unreadableText` (`:2677-2685`). `_requestCanvasHistoryGated` refuses a broken file (`:2579`). `_saveTH2FileGated` checks `if (_isBroken) return saveFailed` after the apply (`:2846`). `_saveAsTH2FileGated` refuses a broken file only without a session (`:2882-2885`). `_saveAsTH2FileBody` skips validation when the buffer equals `initialContent` (`:2907`). `_commitSave()` (`:3192`) clears the undo stack and updates the undo status.
- **Text session.** `TH2TextEditBaseline` (`th2_text_edit_controller.dart:28`) needs `content` and a `lineMap`. `installBaseline` (`:231`) doesn't start idle validation: only `setContent` schedules it (`_scheduleValidation`, `:328`). `initialLineMap` is used by `moveTextCursorToElement` (`th2_file_edit_controller.dart:2327`), `copyTextFragment` (`:2363`), `_requestCanvasHistoryGated` and the `unchanged` result of `applyTextContent`. `TH2TextLineMap` (`th2_text_line_map.dart:37`) has only `fromWriterLedger` and `fromParserStartLines`.
- **Replacement.** `TH2FileEditElementEditController.executeReplaceTH2FileContents` (`th2_file_edit_element_edit_controller.dart:629`) copies image runtime caches by MPID, calls `TH2File.replaceContentsFrom` and `syncControllersWithModel(initialSetup: false)`.
- **Raw text.** `TH2FileParser.detectEncodingFromBytes` (`th2_file_parser.dart:3033`) is public and static. The byte path of `parse` (`:3196-3217`) reads `fileBytes` or the file, detects the encoding, and decodes with the private `_decodeFile` (`:3004`, `MPEncodingAux.decode` followed by `_stripNul`, `:3020`). `MPEncodingAux.decode` (`mp_encoding_aux.dart:44`) uses the strict codecs, so invalid UTF-8 throws `FormatException`. The parser catches that, so such a file loads as broken. `TH2TextLineEndingsAux.loneCarriageReturnOffset` (`th2_text_line_endings_aux.dart:12`) finds a lone `\r`.
- **Bodies and focus.** `TH2FileEditBodyWidget` picks text, then broken, then canvas inside one `Observer` (`th2_file_edit_body_widget.dart:86-104`). It hides the chips and the status bar while broken or in text mode (`:113-121`). `TH2BrokenFileBodyWidget` (`th2_broken_file_body_widget.dart:15`) shows the explanation, the path, the problems and Reload. It has no focus node. `th2FileFocusNode` is attached only by the canvas's `MPListenerWidget` (`mp_listener_widget.dart:49`). `activeFocusNode` falls back to it (`th2_file_edit_controller.dart:1846`). The page's `F2` binding (`th2_file_tabs_page.dart:1101`) sits in a `CallbackShortcuts` around a `Focus(autofocus: true)` (`:1139-1142`).
- **Save As enablement.** The app bar's Save As is disabled for a broken file (`th2_file_tabs_page.dart:384`), and so is the overflow menu's (`:696`).
- **Run Therion.** `MPGeneralController.loadedBrokenProjectTH2FilePaths()` (`mp_general_controller.dart:468`) lists loaded project controllers with `isBroken`. `MPTherionRunDialogWidget` (`mp_therion_run_dialog_widget.dart:72`) warns about them.
- **Tree.** A broken file's tree shows a status row and no element rows (`th2_element_tree_aux.dart:206-221`). `prepareTH2FileForTreeOptions` and `prepareTH2FileForTreeRead` refuse a broken controller (`mp_general_controller.dart:127-150`). The element-edit controller refuses moves and drawing order for a broken file (`th2_file_edit_element_edit_controller.dart:1431`, `:1464`, `:1529`).
- **Reload.** `MPGeneralController.reloadTH2File` (`mp_general_controller.dart:533`) replaces the controller, so the new one starts with all flags cleared.
- **Tests.** `t3940` covers the broken-file body: it expects Save As disabled and no dirty path. `t3982` and `t3983` are free (reserved by Phase 4). `t3980`, `t3984`, `t3987`, `t3988` and `t3990` exist and get the moved broken-file cases.

## 3. Scope and changes to the parent plan

### In scope

Everything in the parent's Phase 5 entry (§5), including the items Phase 4 moved there.

### Changes to the parent plan

Record these in the parent's Phase 5 entry, and in the sections they change, when this plan is implemented (§5 step 4):

1. **Leaving an unchanged raw session returns to the broken-file body without a parse.** The parent covers Discard, but not a leave (`F2`, _Canvas_) with an unchanged buffer. The buffer then still is the disk text that loaded broken, and the parse is deterministic, so applying it could only be rejected. Showing the "can't apply" banner for text the user never touched would be noise. So it does what Discard does (§4.4).
2. **The raw session opens with its problems marked.** The parent says the problems are shown as line markers. Here the entry validates the raw buffer at once, through the session's own validation cache (§4.3), instead of converting `TH2FileProblem`s. The markers are then exactly the diagnostics an apply would give. The cursor starts on the first problem's line.
3. **Save As in a raw session always validates before the file picker.** Phase 4 treats a buffer equal to `initialContent` as valid without a parse. For a raw session that buffer is broken text. Without this change, the picker would open, empty the picked file (Phase 4 plan, §2), and only then would the apply reject the text.
4. **Unreadable raw text refuses entry with a message.** The parent assumes the disk text can always be decoded. A file that is no longer readable, or isn't valid in its encoding (invalid UTF-8 loads as broken, §2), can't be edited as text. Entry shows a localized message and keeps the broken-file body (§4.2).
5. **The broken-file body holds the canvas focus node.** Without a focused node inside the tab, tab activation focuses nothing, and `F2` isn't guaranteed to reach the page shortcuts. The body wraps its content in a `Focus` with `th2FileFocusNode`. That is safe because the canvas, which also uses the node, is never mounted together with it (§4.2).
6. **A raw session has an unowned line map.** The parent doesn't say which map describes the raw text. No element of the broken model reliably owns a line of it, so the map has no owners (§4.3). Tree navigation, Copy and canvas history traversal then do nothing in a raw session, which matches the tree: it shows no element rows for a broken file.
7. **Strings arrive with the code**, as in Phase 4 (its §3 change 4): _Edit as text_, its tooltip and the unreadable-text message (§4.7). Phase 6 reviews them.

## 4. Design

### 4.1 The raw text source

`TH2FileParser` gains `static String decodeSourceBytes(Uint8List bytes)`. It runs `detectEncodingFromBytes(bytes).encoding`, then the same decoding as `_decodeFile`, which it shares (`MPEncodingAux.decode`, then `_stripNul`). The byte path of `parse` uses the shared code, so the raw buffer is exactly the text the load parsed, and the problem lines match. It throws whatever decoding throws.

`TH2FileEditController._readBrokenFileSource()` (new, async) takes `_th2File.fileBytes` when it is set, otherwise `await File(_th2File.filename).readAsBytes()`, and returns `TH2FileParser.decodeSourceBytes(bytes)`. The bytes are those on disk, not a write of the model. This means an encoding change made through Properties on the broken-file body has no effect on the raw text (parent §4.7, baseline step 2).

### 4.2 Entering a raw session

**_Edit as text_.** `TH2BrokenFileBodyWidget` gets a button next to Reload (key `TH2BrokenFileBodyEditAsTextButton`), labeled _Edit as text_, with the tooltip "Edit as text (F2)". It calls `controller.requestEnterTextMode()`. The button is shown whenever the body is.

**Focus.** The body's `SingleChildScrollView` is wrapped in `Focus(focusNode: controller.th2FileFocusNode)`. Tab activation, Discard and the post-frame focus of Phase 4 (`activeFocusNode`) then land in the broken body, and `F2` bubbles from there to the page's binding. The body and the canvas are alternatives in the body `Observer` (§2), so the node is never attached twice. `dispose()` already defers disposing the node while it is attached.

**`F2`.** The page's binding already calls `toggleEditMode()`, which calls `enterTextMode()` on the canvas mode. Update its doc comment ("Broken files are left alone").

**`_enterTextModeGated`** drops `_isBroken` from its early return. For a broken file, it branches before the writer check (`:1943`), into `_enterBrokenTextModeGated()`:

1. `await _readBrokenFileSource()`. If it throws, log the error, show the localized message "Mapiah can't read \<file\> as text." through `_showUserMessage`, and return. The body stays the broken-file body. After the await, it returns when the controller is disposed, the tab is closed, the mode is already `text`, or the file isn't broken anymore (a reload replaces the controller, so this only guards a stale call).
2. If `TH2TextLineEndingsAux.loneCarriageReturnOffset(source)` isn't `null`, show `th2TextUnsupportedLineEndingMessage`, as a valid file's entry does, and return (parent §4.2). The user can fix the line endings outside Mapiah and reload.
3. Skip the canvas-state steps of a valid entry: a broken file has no canvas state, selection or overlay to leave.
4. The cursor goes to the first problem's line (`_problems.first.lineNumber - 1`, clamped to the text), at its first non-blank column. With no problems (a parse that threw), it goes to line 0.
5. Install `TH2TextEditBaseline(content: source, lineMap: TH2TextLineMap.unowned(lineCount: …, th2File: _th2File), cursorLine/Column, selection, selectionRequestsFocus: true)` through `_installTextSessionOnEntry`, which sets `_editMode = text` in the same action.
6. `textEditController.validateNow()` (new, §4.3), so the markers show without waiting for an edit.
7. Focus `activeFocusNode` after the frame, as a valid entry does.

The entry adds no command and no text history.

### 4.3 The raw session

A session is a **raw session** while the file is broken: `_isBroken && (_openTextSession != null)`. No other flag is needed. A raw session ends with the leave, Discard or tab close, or it is replaced after the baseline (§4.5, §4.6). So it never outlives the broken state outside the operation that clears it.

- **Line map.** `TH2TextLineMap.unowned({required int lineCount, required TH2File th2File})` (new factory) builds a map with `lineCount` lines and no owners, no removed lines, no relocations and no added endings. `firstOwnLineOf`, `rangeOf` and `ownerOfLine` return `null` for every element. So `moveTextCursorToElement` and `copyTextFragment` do nothing, and their existing early returns cover them. The broken file's tree has no element rows, and `prepareTH2FileForTreeRead` refuses a broken controller anyway (§2).
- **Validation.** `TH2TextEditController.validateNow()` (new) cancels the idle timer and runs `_validateIdle` for the current revision and edit generation, unawaited. The existing staleness checks apply. After that, idle validation runs on edits as for any session. Validation already parses detached with the live file's line ending and checks encodability against the detached model's encoding (Phase 2).
- **Canvas history.** `_requestCanvasHistoryGated` already refuses a broken file, so `Ctrl+Z` and `Ctrl+Shift+Z` before the first text edit do nothing in a raw session, even when the stack holds a Properties encoding change. The TH2 undo routing (Phase 3) consumes the key, so it doesn't fall through to native text undo.
- **Exclusive editing.** Phase 4's text-mode guards apply unchanged. Properties is disabled in text mode, and the tree's model-changing entry points refuse a broken controller and a controller in text mode.

### 4.4 Leaving and discarding a raw session

`_leaveTextModeGated`, after it takes the buffer lock:

- **Raw session with `session.content == session.initialContent`**: `_returnToCanvas()` and focus after the frame, with no apply (§3 change 1). The mode becomes `canvas`, and the body `Observer` shows the broken-file body, since `isBroken` is still true.
- **Otherwise**: the existing path. `applyTextContent` handles the raw session (§4.5). On `rejected`, the banner and diagnostics are shown, and the mode stays `text`. On `applied`, the file isn't broken anymore. `_returnToCanvas()` then shows the **canvas**, and `applyTextLocation` uses `result.lineMap` (the live writer map after the baseline) and `result.cursorLine`, as for a valid file.

`discardTextEdits()` is unchanged. In a raw session it returns to the broken-file body with the model untouched (parent §4.7, baseline step 5). The banner's _Discard text changes_ does the same.

### 4.5 The broken-file baseline in `applyTextContent`

`applyTextContent` drops its `!_isBroken` assertion and its `unreadableText` rejection. It notes `final bool isRawSession = _isBroken` at its start. For a raw session:

1. **No unchanged shortcut.** It skips both `content == session.initialContent` checks (before the parse and after normalization). They compare against broken text that the model doesn't describe. It always validates.
2. **Validation** runs as today, including the loop that revalidates a buffer that changed during the await and the staleness checks. If the result is invalid, it returns `rejected`.
3. **Valid:** it takes the lock when `lockBufferOnAccept`, maps the cursor (`result.cursorMapper.mapRawLine(session.cursorLine)`), then calls `_installBrokenFileBaseline(result.detachedFile)` instead of the identity matcher and the command. The `serializeForTextMode() == initialContent` assertion doesn't apply. It returns `TH2TextApplyApplied(liveMap, cursorLine)` from `serializeForTextMode()`, after asserting that `liveText == result.normalizedText`.

**`_installBrokenFileBaseline(TH2File detachedFile)`** (new, `@action`, so observers see a single transition), following parent §4.7 _Broken-file baseline_:

1. `_th2File.replaceContentsFrom(TH2File.fromMap(detachedFile.toMap()))`. No image runtime cache is carried over: the detached model's MPIDs are new, so none names a live image. Images load as on a valid load. No selection, hidden set or active scrap exists to preserve.
2. `_isBroken = false`, `_problems = const <TH2FileProblem>[]`.
3. `undoRedoController.clearUndoRedoStack()` and `updateUndoRedoStatus()`. This drops a Properties encoding change made on the broken-file body: the applied model's encoding comes from the text's `encoding` line. The clear is a stack edit that isn't guarded (Phase 4 plan, §3 change 3), and `replaceContentsFrom` isn't a command, so no mutation authorization is needed.
4. `syncControllersWithModel(initialSetup: true)`: active scrap (the first one), default snap targets, used types, selectable elements, `hasMultipleScraps`, `currentScrapName`, and the structure revision bump that rebuilds the tree with element rows. It doesn't install the reactions again: the broken load already did (`_finalFilePreparations`, §2).
5. `_hasUnsavedBaseline = true`.

**`@readonly bool _hasUnsavedBaseline = false`** (new). `enableSaveButton` becomes `!_isBroken && (_hasUndo || _hasUnsavedBaseline) && !_th2File.isNewFile`. `hasUnsavedChanges` and `canSave` follow through it. `_commitSave()` clears the flag after a successful write, for Save and Save As alike. A reload clears it by replacing the controller. Undo can't reach behind the baseline: the stack is empty, and later canvas edits and text sessions stack above it as usual (parent §4.7, step 6).

The dirty-mirroring reaction watches `canSave`. In a raw session with edits, `canSave` is already true through `isDirty`, so the baseline doesn't change it, and the reaction doesn't fire twice. After a leave, `isDirty` turns false, but `enableSaveButton` is true by then, so `canSave` stays true. `t3982` records the reaction's changes of `dirtyFilePaths` with a listener.

### 4.6 Saving a raw session

- **Save.** `_saveTH2FileGated` needs no new branch. The apply runs first. A rejected apply returns `textHasProblems` and writes nothing (`t3983`). An applied one clears `_isBroken`, so the `if (_isBroken)` guard lets the write through. The session is then replaced from the live model, which turns it into an ordinary session, or the regeneration-failure exit returns to the canvas (Phase 4, §4.5), which is now the canvas and not the broken-file body. A failed write keeps the fixed model, `_hasUnsavedBaseline` and the dirty mark. The retry has nothing to apply and adds no command. Save on a broken file with no session still returns `saveFailed` and writes nothing. In a raw session with an unchanged buffer, `canSave` is false, so the UI doesn't offer Save.
- **Save As.** `_saveAsTH2FileBody` validates the buffer even when it equals `initialContent` in a raw session (§3 change 3). An invalid buffer returns `textHasProblems` with the banner shown, and no picker opens. After the picker, the apply installs the baseline (§4.5), and the rest of Save As runs as for a valid file: the commit clears `_hasUnsavedBaseline`, and the session is replaced. A failure before or during the write restores the filename and the image objects, as Phase 4 does, and replaces the session from the live model, which now holds the fixed text. The broken state isn't restored, since the fixed model is valid.
- **Enablement.** The app bar's Save As (`th2_file_tabs_page.dart:384`) and the overflow menu's (`:696`) are enabled for a broken file while `editMode == text`, through the `Observer` that already builds them. Outside text mode, they stay disabled for a broken file.
- **Save All.** `_saveTH2ProjectFile` passes `textHasProblems` through without removing the dirty path, as for a valid file (Phase 4).

### 4.7 Run Therion, reload and strings

- `loadedBrokenProjectTH2FilePaths()` lists a controller when `isBroken || hasUnsavedBaseline`, keeping its other conditions. An applied but unsaved fix still leaves the broken file on disk, which is what Therion reads. After the fix is saved, the list leaves it out.
- Reload (tree context menu, broken-file body) replaces the controller and brings back the broken state from disk, with no prompt, as for any edited file today (parent §4.7, step 5).
- Closing the tab after an unsaved fix disposes the controller, as for a model with unsaved canvas changes (Phase 4 plan, §4.10). The fix is lost without a prompt, as unsaved canvas edits are today.
- EN/PT `.arb` entries, then `flutter gen-l10n`: `th2BrokenFileEditAsText` ("Edit as text"), `th2BrokenFileEditAsTextTooltip` ("Edit as text (F2)") and `th2BrokenFileTextUnreadableMessage` ("Mapiah can't read {filename} as text.", with a placeholder). Each gets a description naming where it is used, as the existing entries do.

## 5. Implementation sequence

Each step leaves `flutter analyze` clean and `flutter test` green, and can be its own commit, made when the user asks for it. After changing MobX-annotated code, run `dart run build_runner build --delete-conflicting-outputs` in the worktree (the main checkout's watch doesn't see it) and commit the regenerated `.g.dart` files. After `.arb` changes, run `flutter gen-l10n`. Do not run `dart format`.

1. **Raw source and entry (§4.1–§4.4).** `decodeSourceBytes` and the parser refactor, `_readBrokenFileSource`, `TH2TextLineMap.unowned`, `validateNow`, the broken branch of entry, the unchanged-raw leave, the _Edit as text_ button, the body's `Focus`, the `toggleEditMode` comment, and the strings. `applyTextContent` keeps rejecting a broken file in this step, so a changed raw buffer can only be discarded. Update `t3940`. Add `t3982`'s entry, marker, `F2`, lone `\r`, unreadable-text and Discard cases.
2. **Baseline and saving (§4.5–§4.7).** `_hasUnsavedBaseline`, `enableSaveButton`, the raw-session branch of `applyTextContent` and `_installBrokenFileBaseline`, the flag cleared in `_commitSave`, Save As validation and enablement, and `loadedBrokenProjectTH2FilePaths`. Add the rest of `t3982`, and `t3983`.
3. **Moved cases.** Add the broken-file cases of `t3980`, `t3984`, `t3987`, `t3988` and `t3990` (§6).
4. **Parent plan update.** In the parent's Phase 5 entry, link this plan and list §3's changes. Add a "Changed by Phase 5" note to §3.7, §4.2, §4.7 and §4.8. Mark Phase 5 implemented, with any implementation notes, here and in the parent. Run the whole suite.

## 6. Verification

### Existing tests

- `t3940` passes, updated for the new button: the body shows _Edit as text_. Its "Save As is disabled" test stays valid on the broken-file body, which is in canvas mode. It gains one assertion: Save As is enabled once _Edit as text_ has opened the raw session.
- `t3944` and `t3945` (controller lifecycle) pass unchanged: a broken load still installs the reactions once, and the baseline installs none.
- `t3976`–`t3981`, `t3984`, `t3987`, `t3988` and `t3990` pass unchanged before step 3 adds their broken-file cases. Phases 1–3 tests pass. `t3969`'s rejection for a broken controller no longer applies (Phase 2's assertion is gone). If a test asserts it, change it to the raw-session behavior of §4.5.

### New tests

Widget tests use `t3950`'s `TH2FileTabsPage` setup, with a broken file written to a temporary directory, as `t3940` does.

| File | Coverage |
| --- | --- |
| `t3982_th2_text_mode_broken_file_test.dart` | Parent `t3982`. _Edit as text_ opens text mode on the decoded disk text, byte for byte (mixed endings and an unterminated last line kept), with the cursor on the first problem's line and its problems marked at the right lines after `validateNow`, before any edit. `F2` on the broken-file body does the same, with the focus in the body after the tab is activated (the test presses the key, it doesn't only check `hasFocus`). A broken file whose source holds a lone `\r` stays on the broken-file body with the unsupported-line-ending message. A file that can't be decoded (invalid UTF-8), or whose file was deleted after the load, stays there with the unreadable-text message. `F2` with an unchanged raw buffer returns to the broken-file body with no parse and no banner. An edited invalid buffer shows the banner, and Discard returns to the body with the model untouched. Fixing and applying makes the canvas available: leaving shows the canvas, not the broken-file body, with the last-used chips and the status bar, the first scrap active, its name in the status bar, `hasMultipleScraps` right, points and lines selectable and snapping working, and the tree showing element rows. The leave's cursor selects the element on its line. The dirty-mirroring reaction changes `dirtyFilePaths` once per change (recorded with a listener). After the apply, `Ctrl+Z` on the canvas does nothing, and the file shows as unsaved (Save button, dirty dot, `hasUnsavedBaseline`). The _Run Therion_ list (`loadedBrokenProjectTH2FilePaths`) still has the file while the fix is unsaved, and doesn't after it is saved. Save writes the fixed text, though the controller was broken when the Save started, and leaves the session an ordinary one on the valid model. Save on a broken file with no session writes nothing and returns `saveFailed`. Reload brings back the broken state from disk. A canvas edit made after the apply undoes back to the fixed text, not further. An encoding change made through Properties on the broken-file body, before _Edit as text_, is dropped by the baseline: the applied model's encoding comes from the text's `encoding` line, and `Ctrl+Z` still does nothing. The next text session creates one canvas step on apply. |
| `t3983_th2_text_mode_broken_file_save_test.dart` | Parent `t3983`: a broken file's text is never saved while problems remain. Save, the text view's toolbar Save, `Ctrl+S` and Save All with an invalid edited raw buffer return `textHasProblems` (or report nothing in the UI), write no bytes and keep the dirty path. Save As with an invalid buffer, edited or not, opens no picker. Save As with an unchanged raw buffer opens no picker either (§3 change 3). Save in a raw session with an unchanged buffer is disabled (`canSave` false). A forced write failure after a valid raw apply keeps the fixed model, `hasUnsavedBaseline`, the dirty mark and the canvas, and a retry writes without another apply. |

Broken-file cases added to existing files (step 3):

| File | Added cases |
| --- | --- |
| `t3980_th2_text_mode_save_test.dart` | Save As is enabled for a broken file in text mode (app bar and overflow menu) and disabled on the broken-file body. A confirmed Save As of a fixed raw buffer writes the target, clears `hasUnsavedBaseline` and leaves neither path dirty. A failed write restores the filename and image objects and keeps the fixed model. |
| `t3984_th2_text_mode_exclusive_tree_test.dart` | With unchanged, edited valid and edited invalid raw text: Properties, `prepareTH2FileForTreeEdit` and `prepareTH2FileForTreeOptions` change nothing. `copyTextFragment` in a raw session copies nothing and leaves the clipboard unchanged. |
| `t3987_th2_text_mode_operation_gate_test.dart` | In a raw session, `F2`, Save, Save As and Discard requested while another operation runs are dropped. Copy and tree navigation do nothing. The buffer refuses typing while a raw apply validates. A reload while a raw entry reads the file leaves the new controller untouched. |
| `t3988_th2_text_mode_canvas_history_test.dart` | A raw session never traverses canvas history: `Ctrl+Z` and `Ctrl+Shift+Z` before the first text edit, with a Properties command on the stack, change neither the model, the stack nor the buffer. |
| `t3990_th2_text_mode_regeneration_failure_test.dart` | A raw buffer fixed and saved, with a forced preparation failure after the write: the file is saved and clean, the canvas shows (not the broken-file body) with the message, `hasUnsavedBaseline` is false and the Run Therion list leaves the file out. With a failed write, the write exception reaches the caller, the file stays dirty and the canvas shows. |

Commands, from the feature worktree:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

User preview, from the main checkout: `scripts/task_run.sh feat_38_th2_text_editing run`. Open a broken `.th2` file, press _Edit as text_ or `F2`, fix the marked lines, and press `F2` again.

## 7. Acceptance and risks

- A broken file opens in text mode from its body, with the button or `F2`, showing the disk text with its problems marked.
- A fix applies as a new baseline: the canvas appears, set up as after a valid load, the file is unsaved, and undo can't bring back the broken model.
- Text with problems is never applied or saved. Save As with problems opens no picker.
- An unsaved fix still counts as broken for Run Therion. Reload brings back the broken file from disk.
- Analyzer and full test suite pass.

Risks:

1. **Raw text vs. parsed text.** The markers and the cursor are right only if the raw buffer is exactly the parsed text. The shared decoder (§4.1) keeps them equal, NUL stripping included. Saving a fixed file therefore drops the NULs, as a Save of a valid file with NULs does today.
2. **Unsaved fix lost on close.** Closing the tab or reloading after an unsaved fix discards it without a prompt (§4.7), as for unsaved canvas edits. The dirty dot and the Save button show it, and Phase 6's help documents it.
3. **Images after the baseline.** The baseline carries no image runtime cache (§4.5), so images referenced by the fixed text load from disk, as on a valid load. An unreadable XVI file shows its load-failure dialog once, as on a load.
4. **Picker truncation.** Save As can still empty a picked file if the write fails after the picker (Phase 4 plan, §8 risk 6). §3 change 3 only keeps the picker from opening for text that can't be applied.
