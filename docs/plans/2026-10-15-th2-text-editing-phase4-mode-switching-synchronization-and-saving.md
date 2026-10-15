<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 4: Mode Switching, Synchronization and Saving

**Date:** 2026-10-15
**Status:** Proposed. Grounded in `feat_38_th2_text_editing` at `ff083b22`, with Phases 1–3 implemented.
**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§3.1–§3.9, §4.1, §4.6, §4.8, §4.11, §4.13–§4.15, §4.17 and §5 Phase 4)
**Previous phase:** [Phase 3: Editor Generalization and TH2 Highlighting](2026-10-13-th2-text-editing-phase3-editor-generalization-and-highlighting.md)
**Issue:** [#38](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose and boundaries

Expose text mode in `.th2` tabs. Connect Phase 3's `TH2TextEditController` to `TH2FileEditController` through `TH2TextEditOwner`, and add everything around it that the parent lists for Phase 4: the per-controller operation gate, mode entry and exit, Discard, selection in both directions, Save and Save As in text mode, dirty state, canvas history traversal before the first text edit, atomic session replacement with regeneration recovery, exclusive text editing in the element tree, tree navigation in text mode, the always-visible active scrap, and closing a tab in text mode.

All work, including this plan and its later validation, stays on `feat_38_th2_text_editing`, in `/home/rodrigo/devel/mapiah-worktrees/feat_38_th2_text_editing`. Do not create a separate Phase 4 branch or merge this phase into `main`. The feature branch merges only after Phase 6 at the earliest.

Out of scope: broken-file raw sessions, _Edit as text_, `F2` on the broken-file body and the broken-file baseline (Phase 5); help pages, keyboard shortcut pages, CHANGELOG and the final review of the strings (Phase 6); the native undo first-snapshot delay (Phase 7). Phase 4 still writes the code paths Phase 5 plugs into: `applyTextContent` keeps its Phase 2 assertion that the file isn't broken, and every operation here treats `isBroken` with no text session exactly as today.

The phase is large, so it is implemented as several commits on the branch, in the order of §6. Each commit leaves `flutter analyze` clean and `flutter test` green.

## 2. Current code and dependencies

Line numbers are at `ff083b22`.

- **Phase 3 provides** `TH2TextEditController` (`lib/src/controllers/th2_text_edit_controller.dart`), with `installBaseline(TH2TextEditBaseline)` (`:238`), `endSession()` (`:268`), `enterRecoveryReadOnly()` (`:292`), `lockBuffer()` (`:358`), `save()`, `revert()` and `requestCanvasHistory()` delegating to the owner, and idle validation. `TH2TextEditOwner` (`lib/src/controllers/th2_text_edit_owner.dart`) declares `filename`, `th2FileMPID`, `defaultLineEnding`, `isDisposed`, observable `canSave` and `isBufferLocked`, `acquireBufferLock()`, `releaseBufferLock()`, `save()`, `discardTextEdits()` and `requestCanvasHistory({required bool redo})`. No production class implements it yet. `THTextEditorWidget` already takes `leadingToolbarActions`, routes TH2 undo/redo, and remounts the main field on a new `baselineRevision`.
- **Phase 2 provides** `serializeForTextMode()` (`th2_file_edit_controller.dart:1740`), which throws `TH2UnsupportedLineEndingException` for a lone `\r`, and `applyTextContent(content, {session, lockBufferOnAccept})` (`:1758`), which asserts the file isn't broken, never ends a session and calls `session.lockBuffer()` on an accepted result. It has no gate assertion yet. `syncControllersWithModel({initialSetup})` (`:875`), `TH2FileHideElementController.ensureScrapVisible` (`:61`), `TH2TextElementLocator.locate` and `TH2TextLineMap` (`firstOwnLineOf`, `rangeOf`, `ownerOfLine`) exist.
- **Saving.** `saveTH2File()` (`:1864`) is synchronous and returns `void`; `saveAsTH2File()` (`:1877`) returns `Future<void>`. `_actualSave` (`:1990`) clears the undo/redo stack **before** `writeAsBytesSync`. Save As calls `renameFileController` and sets `_th2File.filename` and rebases image paths (`_rebaseImportedImagePathsForSaveAs`, which uses `substituteElement` with no command) before the write, and when the chosen path lacks `.th2` it renames the picker's file on disk (`selectedFile.renameSync`) before all of them. `TH2FileSaveStatus` (`th_text_file_save_result.dart:83`) has `saved`, `alreadySaved`, `projectChanged`, `noOpenEditor` and `saveFailed`. `_saveTH2ProjectFile` (`th_project_controller.dart:1548`) checks `enableSaveButton` (`:1574`) and calls `saveTH2File()` synchronously (`:1586`). Tests calling `saveTH2File()`/`saveAsTH2File()` are `t3909` and `t3944`.
- **Save callers.** The app bar's Save (`th2_file_tabs_page.dart:366-371`) and Save As (`:380-383`), the overflow menu (`_buildFileMenuEntries`, `:681`, `:689`; `_handleOverflowMenuAction`, `:795-798`), `_saveActiveTabAs` (`:1184`, synchronous, no `try/catch`) and `_saveActiveTab` (`:1210`, `try/catch`, `enableSaveButton` at `:1227`). The canvas key handler's `keyS` case (`mp_th2_file_edit_state_key_down_mixin.dart:178-188`) also saves.
- **Dirty mirroring** is a `reaction` on `enableSaveButton` (`th2_file_edit_controller.dart:1103-1119`). `enableSaveButton` is at `:539`. `TH2File.isNewFile` is a plain field. `shouldKeepTablessTH2Controller` uses `enableSaveButton` (`mp_general_controller.dart:204`).
- **Command paths.** Every model mutation by command goes through `MPCommand.execute` (`mp_command.dart:103`): from `MPUndoRedoController.execute`, `executeSubstitutingLastUndo`, `undo`, `revertLastUndoWithoutRedo` and `redo` (`mp_undo_redo_controller.dart:102-173`), from `TH2FileEditController.executeMPCommandList` (`th2_file_edit_controller.dart:2117`), and nested inside other commands (`mp_move_area_command.dart:65`, `mp_add_scrap_command.dart:60`, the pre/pos command mixins, …) and in `th2_file_edit_element_edit_controller.dart:1002`. `MPUndoRedoController.undo()` removes the entry before executing it, so an exception there loses the entry.
- **Image insertion.** `addImage()` (`th2_file_edit_element_edit_controller.dart:1329`) awaits the picker, then `_warmAddedImageBounds`, then executes. It is called from `mp_th2_file_edit_state.dart:307` and the key handler (`:114`), both unawaited.
- **Body.** `TH2FileEditBodyWidget` picks the broken body from `snapshot.data!.problems.isNotEmpty || isBroken` (`th2_file_edit_body_widget.dart:83-84`) outside an `Observer`, and hides the last-used chips and the status bar only for a broken file (`:100-105`).
- **Focus at tab activation**: `addFileTab` (`mp_general_controller.dart:152`), the active-tab setter (`:257`) and the page's post-frame callback (`th2_file_tabs_page.dart:127-133`) request `th2FileFocusNode`.
- **Tree.** `prepareTH2FileForTreeEdit`/`prepareTH2FileForTreeOptions` (`mp_general_controller.dart:112-128`). Row handlers in `th2_element_tree_row_widget.dart`: `_validControllerFor` (`:119`), drag (`:197-241`), `_isHighlighted` (`:273`), the eye button (`:392-416`), `_onTap` (`:493`), `_applyDoubleTapExtras` (`:598`), `_onBeforeOpenMenu` (`:609`), `_menuSelection` (`:626`), scrap menu items (`:719-740`), `_executeScrapEdit` (`:747`), `_showScrapOptions` (`:766`), drawing order and _Move to scrap_ (`:797`, `:824`). The file row's _Add scrap_ and _Hide all but active_ (`th_project_tree_node_widget.dart:131-143`). The context menu wrapper calls `onBeforeOpen` (`th_project_tree_row_context_menu_widget.dart:115`) and opens in a post-frame callback (`:133`); its `MenuAnchor` (`:103`) has no `onClose`.
- **Visibility.** `setScrapsHidden` (`th2_file_hide_element_controller.dart:73`) and `toggleScrapVisibility` (`:118`) call `_setActiveScrapForVisibilityHide` (`:132`). `setActiveScrap` (`th2_file_edit_controller.dart:1181`) returns early for the same ID and never shows the scrap.
- **Properties.** `MPFileTabWidget.onProperties` (`mp_file_tab_widget.dart:12`, shown when non-null at `:74`); `prepareSetEncoding` (`th2_file_properties_controller.dart:23`).
- **Canvas Copy.** `TH2FileEditCopyPasteController.copySelectedElements` (`:38`) and `copyScraps` (`:347`) build Mapiah's structured clipboard through `_buildCopyResult`, which adds border lines before their areas.
- Test numbers `t3976`–`t3984`, `t3987`, `t3988` and `t3990` are free. `t3985`, `t3986`, `t3989` and `t3991`–`t3995` are taken.

## 3. Scope and changes to the parent plan

### In scope

Everything in the parent's Phase 4 entry (§5), except what §1 lists as out of scope.

### Changes to the parent plan

Recorded here, and in the parent's Phase 4 entry when this plan is implemented:

1. **Recovery retires the buffer instead of freezing it.** Phase 3's `enterRecoveryReadOnly()` keeps the stale session open and read-only. Parent §4.17 asks for the stale session to be retired and its source kept in an immutable record on the owner, shown by a recovery view that doesn't use the buffer interface. So recovery calls `endSession()` and stores a `TH2TextRegenerationRecovery` record on `TH2FileEditController` (§4.5). `enterRecoveryReadOnly()` and `_isRecoveryReadOnly` are removed from `TH2TextEditController`; its `canSave` and `isReadOnly` drop the recovery term, since a closed session already refuses every mutation and the recovery view never shows the buffer. Parent §4.9's "remains true in regeneration recovery" is then satisfied by the closed session.
2. **The gate is a zone-scoped mutex.** Parent §4.6 asks for a non-reentrant gate and an assertion in `applyTextContent` that its caller holds it. Both are made checkable by running each gated operation's body in a `Zone` that carries the gate's owner (§4.1).
3. **One mutation guard at the command choke point.** Parent §4.13 lists the entry points to guard. All of them reach `MPCommand.execute`, so the guard is one check there, plus checks at the `MPUndoRedoController` entry points before they touch a stack (§4.1).
4. **Strings arrive with the code.** The coding rules forbid hardcoded user text, so the EN/PT strings this phase displays are added here, as Phase 3 did for its own. Parent Phase 6 keeps the help pages, keyboard shortcut pages, CHANGELOG and a review of every text-mode string.
5. **`t3944` also awaits Save.** Besides `t3909`, `t3944` calls `saveTH2File()`; it changes only to await it.
6. **The picker's file rename isn't rolled back.** When the chosen Save As path lacks `.th2`, today's code renames the picker's file before writing. It stays where it is (after the apply, before the write), and a failed write doesn't rename it back: it is the picker's placeholder, not the user's file.

## 4. Design

### 4.1 Operation gate and mutation authorization

**`TH2FileOperationGate`** (new, `lib/src/controllers/th2_file_operation_gate.dart`), one per `TH2FileEditController`:

- `Future<T?> run<T>(Future<T> Function() body)`: queues behind the running operation, FIFO, then runs `body` inside `runZoned(..., zoneValues: {_gateKey: this})` and releases in `finally`. It returns `null` without running `body` when the owner was disposed while waiting.
- `bool get isHeldByCurrentZone => identical(Zone.current[_gateKey], this)`. `run` asserts `!isHeldByCurrentZone` on entry: an operation calling another gated operation fails in debug instead of waiting for itself. In release it logs and returns `null`.
- An observable `hasPendingOperation` (a MobX `Observable<bool>`, true from the first `run` call until the queue drains), which tree navigation and Copy read to ignore clicks (parent §3.8).

Gated operations: `enterTextMode()`, `leaveTextMode()`, `discardTextEdits()`, `saveTH2File()` (also from Save All), `saveAsTH2File()`, `requestCanvasHistory()`, `retryTextEditor()`, `returnToCanvasFromRecovery()` and `addImage()`. Every gated body rechecks `isDisposed`, controller registration (`mpGeneralController.getTH2FileEditControllerIfExists(filename)` identical to `this`) and the mode or session it expects, after admission and after each await.

`applyTextContent` gains `assert(_operationGate.isHeldByCurrentZone)`. The text controller's idle validation doesn't call it, so nothing else changes there.

**Buffer lock.** `TH2FileEditController` implements `isBufferLocked` as an `Observable<bool>`, `acquireBufferLock()` and `releaseBufferLock()`, idempotent, as Phase 3's owner contract says. Each gated text operation releases it in its `finally`, whether or not it was acquired.

**Mutation authorization.** `TH2FileEditController` gains `bool get isModelMutationAllowed => (_editMode == TH2EditMode.canvas) || (_authorizedMutationDepth > 0)` and `T runAuthorizedMutation<T>(T Function() body)`, which increments the depth around a synchronous body. Only two callers use it: the accepted apply (`execute(MPReplaceTH2FileContentsCommand(...))` in `applyTextContent`) and the canvas traversal's `undo()`/`redo()` (§4.7). Checks:

- `MPCommand.execute` returns before `_execPrePrepareUndoRedoInfo` when `!th2FileEditController.isModelMutationAllowed`, after an `assert(false, …)` and an `mpLog.e` naming the command type. Nested commands run inside an authorized parent's depth, so they inherit it.
- `MPUndoRedoController.execute`, `executeSubstitutingLastUndo`, `undo`, `redo`, `revertLastUndoWithoutRedo` and `clearUndoRedoStack` check first and return without touching a stack. `clearUndoRedoStack` is allowed from a save's commit (§4.6) through `runAuthorizedMutation` too.
- `TH2FileEditController.undo()`/`redo()` called while in text mode and not authorized go to the TH2 history handler instead: they call `requestCanvasHistory(redo: …)` unawaited with error logging, so the canvas buttons, hidden in text mode anyway, can't bypass the routing.

The text mode flag flips inside the gate (§4.3, §4.4), so commands run while leaving the canvas state on entry, such as finishing a line being drawn, still run in canvas mode.

### 4.2 Edit mode, text controller and body

`TH2FileEditController` gains:

- `enum TH2EditMode { canvas, text }` and `@readonly TH2EditMode _editMode = canvas`.
- `@readonly TH2TextEditController? _textEditController`, created on the first entry and disposed in `dispose()` or by `onTabClosed()` (§4.10). The controller implements `TH2TextEditOwner`: `filename`, `th2FileMPID`, `defaultLineEnding` (`_th2File.lineEnding`), `isDisposed`, `canSave` (§4.6), the buffer lock (§4.1), `save()` (logging wrapper around `saveTH2File()`, as `_saveActiveTab` does), `discardTextEdits()` and `requestCanvasHistory()`.
- `@readonly TH2TextRegenerationRecovery? _textRegenerationRecovery` and `bool get isTextRegenerationRecoveryRequired` (§4.5).
- `@readonly TH2TextApplyRejected? _textApplyRejection`, the result shown by the "can't apply" banner (§4.4), cleared by _Keep editing_, by the next accepted buffer change and by any session end or replacement.
- `toggleEditMode()`: `enterTextMode()` on the canvas, `leaveTextMode()` in text mode, `returnToCanvasFromRecovery()` in recovery. Broken files are Phase 5: on a broken file with no text session it does nothing.
- `FocusNode get activeFocusNode`: the text controller's `textFieldFocusNode` while `editMode == text` and a session is open, `th2FileFocusNode` otherwise. The three tab-activation sites (§2) use it.

**`TH2FileEditBodyWidget`**, once the load future has data, decides inside one `Observer`: `editMode == text` → `TH2TextEditBodyWidget`; else `isBroken` → `TH2BrokenFileBodyWidget`; else the canvas. The `snapshot.data!.problems.isNotEmpty` test is removed (parent §4.1). The last-used chips and the status bar are built in the same `Observer`, only when `!isBroken && editMode == canvas`.

**`TH2TextEditBodyWidget`** (new, `lib/src/widgets/th2_text_edit_body_widget.dart`), inside an `Observer`:

- In recovery, the recovery view (§4.5).
- Otherwise a `Column`: the "can't apply" banner when `textApplyRejection != null` (§4.4), then `THTextEditorWidget(buffer: textEditController, leadingToolbarActions: [canvasButton])`. The _Canvas_ button calls `toggleEditMode()` through an error-logging handler, with the tooltip "Canvas (F2)".

**Mode buttons and `F2`.** `TH2FileEditActionButtonsWidget` gets a _Text_ button (tooltip "Text (F2)") calling `enterTextMode()`. The page's `CallbackShortcuts` gains `SingleActivator(LogicalKeyboardKey.f2)`, which calls the active TH2 tab's `toggleEditMode()` through the same handler, and does nothing on a `thconfig`/`.th` tab. The text field doesn't handle `F2`, so it bubbles to the page from both views.

### 4.3 Entering text mode

`enterTextMode()`:

1. Runs gated (§4.1), so a pending image insertion or a canvas Save As finishes first. After admission, it returns when disposed, unregistered, already in text mode, or broken (Phase 5).
2. Asserts `!isInteractiveLineSimplificationDialogOpen.value` (parent §4.13).
3. Serializes with `serializeForTextMode()`. On `TH2UnsupportedLineEndingException`, it shows the localized unsupported-line-ending message (a `SnackBar` through `mpLocator.mpNavigatorKey`, with an error log) and returns, before changing any state, so the canvas, state and selection stay as they were (parent §3.1, `t3976`).
4. Computes the cursor (parent §3.2): the smallest `firstOwnLineOf` among the selected points, lines and areas, the line segments of `_selectedEndControlPoints` and `selectedScrapMPIDs`; in _Line edit_ mode with no selected line point, the edited line. Its first non-blank column comes from the text. With no selection, the cursor is the text controller's last position and `lastScrollOffset` is kept.
5. Leaves the canvas state as the tree does, `stateController.onButtonPressed(MPButtonType.select)`, except in _Line edit_ mode. An unfinished line or area is finished as `Esc` does. Overlay windows are closed with `overlayWindowController.clearOverlayWindows()`. These may run commands; the mode is still `canvas`.
6. Serializes again if step 5 executed a command (`undoCount` changed), so the session describes the final model, and recomputes the cursor.
7. Creates the text controller if needed, installs the baseline (`TH2TextEditBaseline` with content, map, cursor and a pending selection at the cursor, `selectionRequestsFocus: true`), and sets `_editMode = text`. Step 7's assignments run in one MobX action.
8. After the frame, focuses `activeFocusNode`.

Entry adds no command and no text history.

### 4.4 Leaving text mode, Discard and selection on the canvas

**`leaveTextMode()`**, gated:

1. Rechecks the session. In recovery it delegates to the recovery path (§4.5).
2. Awaits `applyTextContent(session.content, session: session, lockBufferOnAccept: true)`.
3. `rejected`: sets `_textApplyRejection` and returns; the buffer stays editable, the mode stays `text`. `cancelled`: returns.
4. `applied` or `unchanged`: maps `result.cursorLine` with `TH2TextElementLocator.locate` against `result.lineMap` and the live file, calls `endSession()`, sets `_editMode = canvas`, then `applyTextLocation(location)` and, after the canvas is laid out, `revealSelection()`, then focuses `th2FileFocusNode`.
5. `finally`: releases the buffer lock.

**`applyTextLocation(TH2TextLocation)`** follows parent §3.3:

- `selectElement`: `setActiveScrap(scrapMPID)`, then `selectionController.setSelectedElements([element], setState: true)`, as a tree single tap.
- `selectLinePoint`: as the double-click (`setSelectedElements([line])`, `stateController.setState(editSingleLine)`), then `setSelectedEndControlPoint` on the segment.
- `activateScrap`: `setActiveScrap`, then clear the selection.
- `fileLevel`: clear the selection; keep the active scrap if it exists, else the first scrap (already ensured by the apply's refresh).

`setActiveScrap` shows a hidden scrap (§4.9), so selection inside a hidden scrap shows it.

**`revealSelection()`** (parent §4.11): the selection's bounding box, or the selected line point's position, is compared with the visible canvas rectangle; when not fully inside, `_canvasCenterX/Y` move to its center at the current scale, with `_setCanvasCenterOnZoom`'s math. When the canvas has no size yet, it waits for layout the way `requestZoomToFit` does.

**`discardTextEdits()`**, gated: returns when no session is open; otherwise acquires the buffer lock, calls `endSession()`, clears `_textApplyRejection`, sets `_editMode = canvas` and focuses the canvas; `finally` releases the lock. The model is untouched, and canvas traversals made in the session stay in effect (parent §4.15). The toolbar's Revert (the text controller's `revert()`) and the banner's _Discard text changes_ both await it. The banner's button is only reachable after the rejecting operation has released the gate, since the banner is set inside that operation and shown afterwards.

**The "can't apply" banner** shows "The text has problems and can't be applied. Fix the marked lines, or discard the text changes." with _Keep editing_ (clears `_textApplyRejection` and focuses the field) and _Discard text changes_. Its line-less errors are already in the editor's line-less row (Phase 3). It is also set by Save and Save As when they return `textHasProblems`.

### 4.5 Session replacement and regeneration recovery

**`_prepareTextSession({required int rawCursorLine, TH2TextCursorMapper? mapper})`** builds a `TH2TextEditBaseline` from the live model without touching the installed session: `serializeForTextMode()`, the cursor line through the given mapping (parent §4.12) clamped to the new text, its first non-blank column, and a pending selection without changing focus requests. It throws whatever serialization throws.

**`_replaceTextSession(...)`** runs inside a gated operation that holds the buffer lock: it captures `isDisposed` and identity, prepares the candidate, rechecks, then calls `installBaseline` in one action. `installBaseline` already ends the old session's state and advances both revisions, so no frame shows an empty session. Used by Save, Save As and canvas traversal.

**Recovery.** When preparation throws after an accepted apply and a write attempt (Save or Save As only):

1. Log the exception and stack trace.
2. Build `TH2TextRegenerationRecovery` (new, immutable): the retired buffer's text and cursor, the write outcome (`saved` or `writeFailed`), and the regeneration error's message.
3. Call `endSession()` on the text controller, then set `_textRegenerationRecovery`. `editMode` stays `text`.
4. The original write exception, if any, is rethrown after this; a regeneration exception never replaces it.

`TH2TextRegenerationRecoveryWidget` (new) shows the source in a read-only, selectable `TextField` (its own `TextEditingController`, `readOnly: true`), a localized message saying that the editor couldn't be prepared and whether the file was saved or the changes still need saving, and two buttons:

- _Retry text editor_ → `retryTextEditor()`, gated: prepares a session from the live model, with the recorded cursor line clamped; on success installs it, clears the record and focuses the field; on failure keeps the record and logs.
- _Return to canvas_ → `returnToCanvasFromRecovery()`, gated: clears the record, sets `_editMode = canvas`, focuses the canvas. `F2` and the recovery view's Canvas action do the same.

In recovery: `canSave` keeps following the model (§4.6), but the app bar and menu Save and Save As check `!isTextRegenerationRecoveryRequired`; `saveTH2File({bool allowRecoveryModelSave = false})` returns `cancelled` in recovery unless the flag is set, in which case it writes the model with no apply and updates the record's write outcome; Save As returns `cancelled` before any picker. `_saveTH2ProjectFile` passes `allowRecoveryModelSave: true`. Tree navigation and Copy check for an open session, so they do nothing. A later normal `enterTextMode()` clears the record only once its new session is installed.

### 4.6 Dirty state, Save and Save As

**Observables.**

- `TH2File.isNewFile` is backed by an `Observable<bool>`; the getter and setter keep their names, the setter writes in `runInAction` (parent §4.8). `toMap`, `fromMap` and `replaceContentsFrom` don't carry it.
- `@computed bool get hasUnsavedChanges => enableSaveButton || (_textEditController?.isDirty ?? false)`.
- `@computed bool get canSave => hasUnsavedChanges && !_th2File.isNewFile`. It implements the owner's `canSave`.
- The dirty-mirroring reaction watches `canSave` instead of `enableSaveButton`. `shouldKeepTablessTH2Controller` uses `hasUnsavedChanges`. `_saveTH2ProjectFile`'s "already saved" check uses `canSave`.
- `enableSaveButton` keeps its formula; `_hasUnsavedBaseline` is Phase 5.

**`TH2FileSaveStatus`** gains `textHasProblems` and `cancelled`; its doc comment is updated (parent §4.8).

**`_actualSave` split.** `_writeFile(File file)` encodes and writes with `flush: true`; `_commitSave()` then runs, authorized, `undoRedoController.clearUndoRedoStack()` and `updateUndoRedoStatus()`. Nothing is cleared when the write throws.

**`Future<TH2FileSaveStatus> saveTH2File({bool allowRecoveryModelSave = false})`**, gated:

1. A new file returns `saveFailed` with nothing applied or written.
2. In recovery, see §4.5.
3. In text mode with an open session: awaits `applyTextContent(..., lockBufferOnAccept: true)`. `rejected` sets `_textApplyRejection` and returns `textHasProblems`; `cancelled` returns `cancelled`. Remembers whether an apply ran, the result's cursor line, and its mapper.
4. `if (_isBroken) return saveFailed;`, after the apply, as the parent orders (Phase 5 makes the apply clear it).
5. `_writeFile`, then `_commitSave()`, `isNewFile = false`, `closeAutoDismissOverlayWindows()`.
6. In text mode after step 3, whether the write succeeded or threw: `_replaceTextSession` from the live model (§4.5), with recovery on failure. A write exception is rethrown after it.
7. `finally`: releases the lock. Returns `saved`.

**`Future<TH2FileSaveStatus> saveAsTH2File()`**, gated for its whole length, including the picker:

1. Recovery returns `cancelled`. Outside text mode the broken-file guard is unchanged.
2. In text mode: validates the current buffer through `session.validationCache.validate` (cached when current). Invalid → `_textApplyRejection`, `textHasProblems`, no picker.
3. Awaits the picker. Dismissed → `cancelled`; nothing changed, the session and its text history are kept.
4. In text mode: `applyTextContent(..., lockBufferOnAccept: true)`; `rejected` → `textHasProblems`, `cancelled` → `cancelled`, with nothing written.
5. The `.th2` renaming of the picked path, as today.
6. Records `previousFilename`, the image elements before rebasing; sets `_th2File.filename`, rebases image paths.
7. `_writeFile`. On failure: restores the filename and substitutes the original image elements back, then in text mode prepares a new session from that rolled-back model (§4.5), and rethrows. The controller stays registered under the old path, with its dirty mark.
8. On success, in this order (parent §4.8): `renameFileController`, `_commitSave()`, in text mode `_replaceTextSession` (or recovery), `isNewFile = false`, `_markLoadedAfterSaveAs()`, `lastAccessedDirectory`, `closeAutoDismissOverlayWindows()`. A regeneration failure doesn't skip the steps after it.
9. `finally`: releases the lock. Returns `saved`.

**Callers.**

- The app bar's Save and the overflow menu's Save call `_saveActiveTab`; the app bar's Save As and the menu's Save As call `_saveActiveTabAs`. Both page methods are `async`, await inside `try/catch` and log; `_saveActiveTab` checks `canSave` and `!isTextRegenerationRecoveryRequired`. When either returns `textHasProblems`, the banner already shows it, and nothing else is reported; `cancelled` reports nothing.
- Save's enabled state everywhere is `canSave && !isTextRegenerationRecoveryRequired`. Save As is enabled for a non-broken file not in recovery (Phase 5 enables it for a broken file in text mode).
- The canvas key handler's whole `keyS` case is removed (parent §4.8).
- `_saveTH2ProjectFile` awaits `saveTH2File(allowRecoveryModelSave: true)`, maps `textHasProblems` and `cancelled` through unchanged, and removes the dirty path only after `saved`.
- `TH2TextEditController.save()` keeps its Phase 3 behavior through the owner's `save()`.

### 4.7 Canvas history traversal before the first text edit

`requestCanvasHistory({required bool redo})`, gated:

1. Rechecks the controller, an open session, `!hasTextEdits`, no recovery and not broken. Otherwise returns.
2. Returns when there's nothing to undo or redo.
3. Acquires the buffer lock. Takes a checkpoint: `before = _th2File.toMap()` and `MPUndoRedoController.checkpoint()` (new: copies of the `_undos` and `_redos` lists; their entries are immutable), and the cursor line and column.
4. Runs `undo()`/`redo()` under `runAuthorizedMutation`. They already run `_undoRedoDone()` (status and empty selection).
5. `syncControllersWithModel(initialSetup: false)`.
6. Prepares and installs a new baseline (§4.5), with the cursor at the same MPID's line and own-line offset when the owner of the old cursor line survives, otherwise the old line and column clamped. `hasTextEdits` stays false, and the installation's new baseline revision remounts the field with an empty native history and invalidates pending idle validation.
7. On an exception in steps 4–6: restores the model with `_th2File.replaceContentsFrom(TH2File.fromMap(before))` (a fresh copy, parent §4.7), `MPUndoRedoController.restore(checkpoint)`, `updateUndoRedoStatus()`, `syncControllersWithModel(initialSetup: false)`, keeps the old session, and logs. If the rollback itself throws: logs, ends the session and enters recovery with the write outcome "not saved" (§4.5), so editing stays disabled until _Return to canvas_ and a Reload.
8. `finally`: releases the lock and refocuses the text field.

### 4.8 Exclusive text mode, Properties, tree Copy and the image gate

**Disabled tree actions.** `prepareTH2FileForTreeOptions` returns `null` when the controller's `editMode == text`, before `addFileTab`; `prepareTH2FileForTreeEdit` calls it first, so both refuse. In `th2_element_tree_row_widget.dart` and `th_project_tree_node_widget.dart`, inside their `Observer`s:

- drawing-order items, _Move to scrap_, Cut, Duplicate, Delete, _Scrap options_ and _Add scrap_ get a `null` `onPressed` while the row's controller is in text mode;
- `Draggable` is replaced by the plain row (no drag source) while the controller is in text mode, and drop targets reject payloads whose source or target controller is in text mode (`onWillAcceptWithDetails`), rechecked in `onAcceptWithDetails`;
- callbacks of a menu opened before entry recheck `editMode` before acting.

**Properties.** `MPFileTabWidget` gains `bool propertiesEnabled = true`; when false, the button stays visible with `onPressed: null`. The page builds each TH2 tab's widget in an `Observer` and passes `propertiesEnabled: controller.editMode == TH2EditMode.canvas`. `prepareSetEncoding` returns when its controller is in text mode.

**Tree Copy in text mode.** `_executeScrapEdit('copy')` is split off into `_copyFromTree()`:

- On the canvas it calls `prepareTH2FileForTreeEdit` and `copyScraps(ids)` as today.
- In text mode it calls a new `MPGeneralController.prepareTH2FileForTreeRead(path)`, which activates the tab only, then, if no operation is pending and a session is open, `controller.copyTextFragment(ids)`.
- Element rows get a Copy item in text mode only (§3.8 of the parent), using `_menuSelection`.

`TH2FileEditController.copyTextFragment(List<int> mpIDs)` (new) builds the fragment synchronously from the session's `initialContent` and `initialLineMap`: it orders the requested MPIDs by `rangeOf(...).first`, drops any MPID inside the range of another requested one, adds before each area the border lines that the canvas copy adds (`_buildCopyResult`'s rule, extracted into a helper that returns MPIDs), deduplicated, and concatenates each block's text from its range, keeping its line endings, adding `_th2File.lineEnding` between blocks only where a block ends unterminated. It then awaits `Clipboard.setData(ClipboardData(text: fragment))` with the captured string, logs failures, and never touches the controller after the await. The internal clipboard is not touched. The tree's Copy item shows no error dialog on failure, only the log.

**Image gate.** `addImage()` runs gated: after admission it returns unless the controller is live, registered and in canvas mode; it rechecks identity and disposal after the picker and after `_warmAddedImageBounds`, before `execute`. The picker's `BuildContext` lookup moves inside the gated body. An exception from `_warmAddedImageBounds` is logged and propagates to the two callers, which now call it through `unawaited(...catchError(log))`.

**Canvas Save and Save As** use the same gate (§4.6), so a Save As picker open on the canvas delays text-mode entry until its write ends.

### 4.9 Tree navigation in text mode and the always-visible active scrap

**`_onTap`.** After `_validControllerFor`, when `editMode == text`: reset the tap tracker, bring the tab to the front as today, call `controller.moveTextCursorToElement(row.elementMPID)` (the scrap's MPID on a scrap row) and return.

**`_onBeforeOpenMenu`.** In text mode: `moveTextCursorToElement(mpID, requestFocus: false)` and return. `THProjectTreeRowContextMenuWidget` gains `VoidCallback? onAfterClose`, passed to `MenuAnchor.onClose`; the TH2 row passes one that requests `textFieldFocusNode` when the tab is still in text mode with an open session.

**`moveTextCursorToElement(int mpID, {bool requestFocus = true})`**: returns when an operation is pending, no session is open or recovery is active. Takes `initialLineMap.firstOwnLineOf(mpID)`; returns when `null`. When the buffer differs from `initialContent`, maps it through `lineTracker` (Phase 2's lookup, giving the nearest unedited line above, or line 0). Sets the pending scroll and a pending selection at the line's first non-blank column, with `pendingSelectionRequestsFocus: requestFocus`.

**Highlighted rows** keep following the live canvas selection; nothing in text mode changes it.

**Active scrap always visible** (parent §3.9, §4.14):

- `setActiveScrap(id)` calls `hideElementController.ensureScrapVisible(id)` first, before its same-ID early return.
- `toggleScrapVisibility` does nothing when asked to hide the active scrap; `setScrapsHidden(ids, true)` skips the active scrap. `_setActiveScrapForVisibilityHide` is removed.
- The active scrap row's eye button has `onPressed: null` while visible, with the tooltip "The active scrap can't be hidden".
- The scrap menu's item reads Hide only when one of its scraps other than the active one is visible; otherwise Show (for the hidden ones). On the active scrap alone, Hide is disabled.
- `syncControllersWithModel` already shows the active scrap (Phase 2).

### 4.10 Tab close, reload and disposal

- `onTabClosed()` (new): returns on the canvas; otherwise ends the session if open, clears the recovery record and the rejection, disposes the text controller, sets `_editMode = canvas`. It applies nothing. `removeFileTab` calls it on a controller it keeps without a tab. A kept controller had no unsaved changes, so the session was clean.
- `dispose()` disposes the text controller. Pending gated operations find `isDisposed` after their next await and return, so nothing runs against a disposed or replacement controller (`reloadTH2File` replaces the controller).

### 4.11 Strings

EN and PT `.arb` entries, then `flutter gen-l10n`: the _Text_ and _Canvas_ button tooltips, the "can't apply" banner text, _Keep editing_, _Discard text changes_, the unsupported line ending message, the recovery message in its saved and not-saved variants, _Retry text editor_, _Return to canvas_, and "The active scrap can't be hidden". Phase 3 already added the TH2 Revert tooltip and the diagnostic texts.

## 5. Phase 3 contract changes

- `TH2TextEditController`: remove `enterRecoveryReadOnly()` and `_isRecoveryReadOnly`; `canSave => _owner.canSave`; `isReadOnly => _owner.isBufferLocked` (§3, change 1). `t3974`'s fake owner and any test using `enterRecoveryReadOnly` are updated.
- `TH2TextEditBaseline` gains nothing: entry, replacement and traversal pass content, map, cursor and selection as it already allows.

## 6. Implementation sequence

Each step is one commit on the branch, with `flutter analyze` clean and `flutter test` green. After changing MobX-annotated code, run `dart run build_runner build --delete-conflicting-outputs` in the worktree; after `.arb` changes, `flutter gen-l10n`.

1. **Gate and authorization (§4.1).** `TH2FileOperationGate`, the buffer lock on `TH2FileEditController`, `isModelMutationAllowed`/`runAuthorizedMutation`, the `MPCommand.execute` and `MPUndoRedoController` checks, `checkpoint()`/`restore()`, the gate assertion in `applyTextContent` (update `t3966`–`t3971` and `t3985` to call it inside a gated test helper), and the gated `addImage()` (§4.8). No visible change on the canvas.
2. **Save pipeline (§4.6).** Observable `isNewFile`, `hasUnsavedChanges`, `canSave`, the reaction and call-site changes, the new statuses, `_writeFile`/`_commitSave`, the asynchronous gated Save and Save As with rollback, the page callers, removing the `keyS` case, and `_saveTH2ProjectFile`. Update `t3909` and `t3944` to await. Add `t3980`'s canvas cases (exactly-once `Ctrl+S`/`Ctrl+Shift+S`, write failure, Save As rollback, dirty paths).
3. **Active scrap always visible (§4.9).** Hide controller, `setActiveScrap`, eye button, scrap menu. Replace `t3670`'s active-scrap test.
4. **Mode switching (§4.2–§4.4, §4.10).** `TH2EditMode`, the owner implementation, `enterTextMode`, `leaveTextMode`, `discardTextEdits`, `toggleEditMode`, `TH2TextEditBodyWidget` with its banner, the body `Observer`, buttons, `F2`, `activeFocusNode` at the three focus sites, `applyTextLocation`, `revealSelection`, `onTabClosed`, Properties, the §4.11 strings, and the Phase 3 contract change (§5). Text-mode Save and Save As become reachable here. Add `t3976`–`t3979`, the text-mode cases of `t3980`, and `t3978`.
5. **Exclusive tree and navigation (§4.8, §4.9).** Disabled tree actions and drag/drop, `prepareTH2FileForTreeRead`, `copyTextFragment`, the `_onTap`/`_onBeforeOpenMenu` branches, `moveTextCursorToElement`, `onAfterClose`. Add `t3981`, `t3984`.
6. **History and recovery (§4.5, §4.7).** `requestCanvasHistory` with checkpoint rollback, `TH2TextRegenerationRecovery`, the recovery widget and actions, `allowRecoveryModelSave`. Add `t3987`, `t3988`, `t3990`.
7. **Parent plan update.** Record §3's changes in the parent's Phase 4 entry and named sections, mark Phase 4 implemented, and run the whole suite.

Do not run `dart format`.

## 7. Verification

### Existing tests

- `t3909` and `t3944` pass, changed only to await `saveTH2File()`.
- `t3948`, `t3949` and `t3953` (tree drag/drop, context menu, scrap actions) pass unchanged on the canvas.
- `t3670`: its test that hiding the active scrap moves to the nearest visible scrap is replaced by one where `toggleScrapVisibility` on the active scrap leaves it visible and active, with the selection unchanged.
- `t3940` (broken-file body) passes unchanged; Phase 5 adds _Edit as text_.
- Phases 1–3 tests (`t3960`–`t3975`, `t3985`, `t3986`, `t3989`) pass; the apply tests run `applyTextContent` inside the gate.

### New tests

Widget tests use `t3950`'s `TH2FileTabsPage` setup. The parent's Phase 4 entry (§5) describes each one in full; this table lists them with what this plan adds.

| File | Coverage |
| --- | --- |
| `t3976_th2_text_mode_entry_test.dart` | Parent `t3976`: cursor on the selected element nearest the top, the first selected line point in _Line edit_ mode; a lone `\r` in the writer output keeps the canvas with the message and changes nothing. Also: entry finishes a line being drawn as `Esc` does and the text includes it; overlay windows close; entry adds no command. |
| `t3977_th2_text_mode_selection_test.dart` | Parent `t3977`: each row of parent §3.3; line point round-trip. Also: `revealSelection` moves the center without changing the scale only when the selection is outside the view; a cursor in a hidden scrap shows it. |
| `t3978_th2_text_mode_undo_steps_test.dart` | Parent `t3978`, plus `t3966`'s "returning to the canvas" assertion moved from Phase 2. |
| `t3979_th2_text_mode_rejection_test.dart` | Parent `t3979`; the banner's _Keep editing_ and _Discard text changes_. |
| `t3980_th2_text_mode_save_test.dart` | Parent `t3980`, plus `t3969`'s Save and Save As assertions moved from Phase 2. |
| `t3981_th2_text_mode_tree_navigation_test.dart` | Parent `t3981`. |
| `t3982`, `t3983` | Reserved for Phase 5. |
| `t3984_th2_text_mode_exclusive_tree_test.dart` | Parent `t3984`, including the `MPCommand.execute` and `MPUndoRedoController` guards and `copyTextFragment`. |
| `t3987_th2_text_mode_operation_gate_test.dart` | Parent `t3987` with its history, image-entry and Discard cases. Also: a gated operation calling another gated one fails its assertion; `applyTextContent` outside the gate fails its assertion; `hasPendingOperation` is true from the first queued request until the queue drains. |
| `t3988_th2_text_mode_canvas_history_test.dart` | Parent `t3988`. |
| `t3990_th2_text_mode_regeneration_recovery_test.dart` | Parent `t3990`. Regeneration failures are injected through a `@visibleForTesting` hook on `_prepareTextSession`, like Phase 2's static test hooks. |

Commands, from the feature worktree:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

User preview after implementation, from the main checkout: `scripts/task_run.sh feat_38_th2_text_editing run`. Open a `.th2` file, press `F2` or the _Text_ button, edit, and press `F2` again.

## 8. Acceptance and risks

- A `.th2` tab switches between canvas and text with the buttons and `F2`; each tab keeps its mode; the selection maps both ways, including a line point.
- Text edits apply once per session as one canvas undo step; invalid text never applies or saves.
- Save and Save As work from every entry point in both modes, exactly once, logging failures, with the dirty dot, Save All and the tab-less controller rule following `hasUnsavedChanges`/`canSave`.
- In text mode, only the text apply and the canvas traversal before the first text edit change the model; the tree navigates and copies text instead of editing.
- The active scrap is always visible.
- Analyzer and full test suite pass.

Risks:

1. **Gate deadlocks.** A gated operation awaiting another gated one, or a UI handler awaiting Discard while the rejecting operation still holds the gate, would hang. The zone assertion (§4.1) catches the first in debug; the banner is set inside the operation but acted on later, which avoids the second. `t3987` covers both.
2. **Save ordering.** Save As's rename, commit, new session and `isNewFile` order decides the dirty path; `t3980` records `dirtyFilePaths` changes with a listener.
3. **Rollback completeness.** Save As's failure rollback restores the filename and the image elements; the traversal rollback restores the model and both stacks. Both are tested with injected failures.
4. **Guard false positives.** A canvas feature that executes a command from a timer or callback while the tab is in text mode is now rejected and logged. The interactive line simplification dialog is modal; the image insertion is gated. `t3984` exercises the known paths; any new rejection log during the full test suite is investigated before the phase is marked implemented.
5. **Focus.** Remounting the field and swapping bodies at mode switches can lose focus; tests type characters to check focus, not only `hasFocus`.
