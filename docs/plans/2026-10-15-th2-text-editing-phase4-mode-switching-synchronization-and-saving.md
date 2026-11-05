<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 4: Mode Switching, Synchronization and Saving

**Date:** 2026-10-15
**Status:** Proposed, not implemented. Grounded in `feat_38_th2_text_editing` at `ff083b22`, with Phases 1–3 implemented. `lib/` and `test/` are unchanged from `ff083b22` to `6d498737`, so the line numbers in §2 are current at both.

**Validation record:** Validated against the code at `adf2c190` (2026-10-15), `7f8353a0` (2026-10-26), `fc28795a` (2026-11-03) and `cf90cbb8` (2026-11-03). A simplification pass at `6d498737` (2026-11-05) rechecked the design against the code and removed safeguards for failures that can't realistically happen or that the canvas doesn't guard against today: regeneration recovery, the traversal checkpoint and rollback, Save As's transactional failure boundary, the zone-scoped gate tokens, the tab-lifecycle generation and registration rechecks, deferred text controller disposal and the guard on clearing the undo stack (§3 changes 1, 2, 3, 6, 7, 9 and 11). With `rollbackFailed` gone, the tab-close retention rule that `onTabClosed()` defeated by clearing the record first is gone too, and §4.10 now states what retention does with unsaved text. These contracts supersede conflicting parent-plan details until §6 step 7 updates the parent.

**Revalidation rule:** No further full validation of this document is needed. Before implementing a step of §6, run `git diff 6d498737 -- lib test`. If it shows changes to files that step's §2 items name, recheck only those items. Whether the implementation is correct is decided by §7's tests and `flutter analyze`, not by reviewing this plan again.

**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§3.1–§3.9, §4.1, §4.6, §4.8, §4.11, §4.13–§4.15, §4.17 and §5 Phase 4)
**Previous phase:** [Phase 3: Editor Generalization and TH2 Highlighting](2026-10-13-th2-text-editing-phase3-editor-generalization-and-highlighting.md)
**Issue:** [#38](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose and boundaries

Expose text mode in `.th2` tabs. Connect Phase 3's `TH2TextEditController` to `TH2FileEditController` through `TH2TextEditOwner`, and add everything around it that the parent lists for Phase 4: the per-controller operation gate, mode entry and exit, Discard, selection in both directions, Save and Save As in text mode, dirty state, canvas history traversal before the first text edit, session replacement after saving and traversal, exclusive text editing in the element tree, tree navigation in text mode, the always-visible active scrap, and closing a tab in text mode.

All work, including this plan and its later validation, stays on `feat_38_th2_text_editing`. Do not create a separate Phase 4 branch or merge this phase into `main`. The feature branch merges only after Phase 6 at the earliest. Work in its task worktree, `/home/rodrigo/devel/mapiah-worktrees/feat_38_th2_text_editing` (AGENTS.md, "Parallel Work"); the main checkout stays on `main`.

Out of scope: broken-file raw sessions, _Edit as text_, `F2` on the broken-file body and the broken-file baseline, with every broken-file case of the parent's Phase 4 tests (Phase 5, §3 change 8); help pages, keyboard shortcut pages, CHANGELOG and the final review of the strings (Phase 6); the native undo first-snapshot delay (Phase 7). Phase 4 still writes the code paths Phase 5 plugs into: `applyTextContent` keeps its Phase 2 assertion that the file isn't broken, and every operation here treats `isBroken` with no text session exactly as today.

The phase is large, so it is implemented as several commits on the branch, in the order of §6. Each commit leaves `flutter analyze` clean and `flutter test` green.

## 2. Current code and dependencies

Historical line numbers are at `ff083b22`; use the named symbols to locate code at the validation baseline.

- **Phase 3 provides** `TH2TextEditController` (`lib/src/controllers/th2_text_edit_controller.dart`), with `installBaseline(TH2TextEditBaseline)` (`:238`), `endSession()` (`:268`), `enterRecoveryReadOnly()` (`:292`), `lockBuffer()` (`:358`), `save()`, `revert()` and `requestCanvasHistory()` delegating to the owner, and idle validation. `TH2TextEditOwner` (`lib/src/controllers/th2_text_edit_owner.dart`) declares `filename`, `th2FileMPID`, `defaultLineEnding`, `isDisposed`, observable `canSave` and `isBufferLocked`, `acquireBufferLock()`, `releaseBufferLock()`, `save()`, `discardTextEdits()` and `requestCanvasHistory({required bool redo})`. No production class implements it yet. `THTextEditorWidget` already takes `leadingToolbarActions`, routes TH2 undo/redo, and remounts the main field on a new `baselineRevision`.
- **Phase 2 provides** `serializeForTextMode()` (`th2_file_edit_controller.dart:1740`), which throws `TH2UnsupportedLineEndingException` for a lone `\r`, and `applyTextContent(content, {session, lockBufferOnAccept})` (`:1758`), which asserts the file isn't broken, never ends a session and calls `session.lockBuffer()` on an accepted result. It has no gate assertion yet. `syncControllersWithModel({initialSetup})` (`:875`), `TH2FileHideElementController.ensureScrapVisible` (`:61`), `TH2TextElementLocator.locate` and `TH2TextLineMap` (`firstOwnLineOf`, `rangeOf`, `ownerOfLine`) exist.
- **Saving.** `saveTH2File()` (`:1864`) is synchronous and returns `void`; `saveAsTH2File()` (`:1877`) returns `Future<void>`. `_actualSave` (`:1990`) clears the undo/redo stack **before** `writeAsBytesSync`. Save As calls `renameFileController` and sets `_th2File.filename` and rebases image paths (`_rebaseImportedImagePathsForSaveAs`, which uses `substituteElement` with no command) before the write, and when the chosen path lacks `.th2` it renames the picker's file on disk (`selectedFile.renameSync`) before all of them. Save As records `previousFilename` as `''` for a new file, as the reference for rebasing image paths; the controller's registry key is then the placeholder name in `_th2File.filename`. `FilePicker.saveFile` writes the `bytes` it is given (`Uint8List(0)`) to the chosen path before it returns (`file_picker_linux` 2.0.2, `file_picker_linux.dart:285`), so an existing file picked for overwriting is already empty when the picker returns. `TH2FileSaveStatus` (`th_text_file_save_result.dart:83`) has `saved`, `alreadySaved`, `projectChanged`, `noOpenEditor` and `saveFailed`. `_saveTH2ProjectFile` (`th_project_controller.dart:1548`) checks `enableSaveButton` (`:1574`) and calls `saveTH2File()` synchronously (`:1586`). `t3909` calls `saveTH2File()`; `t3944` already awaits `saveAsTH2File()`.
- **Save callers.** The app bar's Save (`th2_file_tabs_page.dart:366-371`) and Save As (`:380-383`), the overflow menu (`_buildFileMenuEntries`, `:681`, `:689`; `_handleOverflowMenuAction`, `:795-798`), `_saveActiveTabAs` (`:1184`, synchronous, no `try/catch`) and `_saveActiveTab` (`:1210`, `try/catch`, `enableSaveButton` at `:1227`). The canvas key handler's `keyS` case (`mp_th2_file_edit_state_key_down_mixin.dart:178-188`) also saves.
- **Dirty mirroring** is a `reaction` on `enableSaveButton` (`th2_file_edit_controller.dart:1103-1119`). `enableSaveButton` is at `:539`. `TH2File.isNewFile` is a plain field. `shouldKeepTablessTH2Controller` uses `enableSaveButton` (`mp_general_controller.dart:204`).
- **Command paths.** Every model mutation by command goes through `MPCommand.execute` (`mp_command.dart:103`): from `MPUndoRedoController.execute`, `executeSubstitutingLastUndo`, `undo`, `revertLastUndoWithoutRedo` and `redo` (`mp_undo_redo_controller.dart:102-173`), from `TH2FileEditController.executeMPCommandList` (`th2_file_edit_controller.dart:2117`), and nested inside other commands (`mp_move_area_command.dart:65`, `mp_add_scrap_command.dart:60`, the pre/pos command mixins, …) and in `th2_file_edit_element_edit_controller.dart:1002`, which then pushes their combined command with a direct `undoRedoController.add` (`:1028`). `MPUndoRedoController.undo()` removes the entry before executing it, so an exception there loses the entry. `undo()` and `redo()` also set the state to `selectEmptySelection`.
- **Image insertion.** `addImage()` (`th2_file_edit_element_edit_controller.dart:1329`) awaits the picker, then `_warmAddedImageBounds`, then executes. It is called from `mp_th2_file_edit_state.dart:307` and the key handler (`:114`), both unawaited. It lives in another library than `TH2FileEditController`, so it can't reach that class's private members.
- **Body.** `TH2FileEditBodyWidget` picks the broken body from `snapshot.data!.problems.isNotEmpty || isBroken` (`th2_file_edit_body_widget.dart:83-84`) outside an `Observer`, and hides the last-used chips and the status bar only for a broken file (`:100-105`).
- **Focus at tab activation**: `addFileTab` (`mp_general_controller.dart:152`), the active-tab setter (`:257`) and the page's post-frame callback (`th2_file_tabs_page.dart:127-133`) request `th2FileFocusNode`.
- **Loading and tabs.** A controller can exist before its file is loaded (`isFileLoaded`, `loadError`), and `removeFileTab` (`mp_general_controller.dart:161`) keeps a clean controller without a tab when its tree row is expanded. `TH2FileEditController.dispose()` defers disposing `th2FileFocusNode` to a post-frame callback while the node is still attached (`th2_file_edit_controller.dart:1604-1610`).
- **Tree.** `prepareTH2FileForTreeEdit`/`prepareTH2FileForTreeOptions` (`mp_general_controller.dart:112-128`). Row handlers in `th2_element_tree_row_widget.dart`: `_validControllerFor` (`:119`), drag (`:197-241`), `_isHighlighted` (`:273`), the eye button (`:392-416`), `_onTap` (`:493`), `_applyDoubleTapExtras` (`:598`), `_onBeforeOpenMenu` (`:609`), `_menuSelection` (`:626`), scrap menu items (`:719-740`), `_executeScrapEdit` (`:747`), `_showScrapOptions` (`:766`), drawing order and _Move to scrap_ (`:797`, `:824`). The file row's _Add scrap_ and _Hide all but active_ (`th_project_tree_node_widget.dart:131-143`). The context menu wrapper calls `onBeforeOpen` (`th_project_tree_row_context_menu_widget.dart:115`), then builds the items once and stores them (`_menuChildren`), so they are not rebuilt by an `Observer` while the menu is open; it opens in a post-frame callback (`:133`), and its `MenuAnchor` (`:103`) has no `onClose`.
- **Visibility.** `setScrapsHidden` (`th2_file_hide_element_controller.dart:73`) and `toggleScrapVisibility` (`:118`) call `_setActiveScrapForVisibilityHide` (`:132`). `setActiveScrap` (`th2_file_edit_controller.dart:1181`) returns early for the same ID and never shows the scrap; with a different ID it sets the state to `selectEmptySelection`. Only the active scrap's elements can be selected on the canvas: the tree's single tap activates the element's scrap before selecting it (`th2_element_tree_row_widget.dart:587-590`). Snap targets include the active scrap whether it is hidden or not, and other scraps only when they are visible and inactive-scrap snapping is on (`th2_file_edit_snap_controller.dart:181-190`). Undoing a scrap's removal re-adds it through `afterAddScrap`, which makes it active (`th2_file_edit_element_edit_controller.dart:809`). `syncControllersWithModel` makes the first scrap active when the active one no longer exists, and shows it (`th2_file_edit_controller.dart:885-891`).
- **Properties.** `MPFileTabWidget.onProperties` (`mp_file_tab_widget.dart:12`, shown when non-null at `:74`); `prepareSetEncoding` (`th2_file_properties_controller.dart:23`).
- **Canvas Copy.** `TH2FileEditCopyPasteController.copySelectedElements` (`:38`) and `copyScraps` (`:347`) build Mapiah's structured clipboard through `_buildCopyResult`, which adds border lines before their areas.
- Test numbers `t3976`–`t3984`, `t3987`, `t3988` and `t3990` are free. `t3985`, `t3986`, `t3989` and `t3991`–`t3995` are taken.

## 3. Scope and changes to the parent plan

### In scope

Everything in the parent's Phase 4 entry (§5), except what §1 lists as out of scope.

### Changes to the parent plan

Recorded here, and in the parent's Phase 4 entry when this plan is implemented:

1. **A regeneration failure returns to the canvas.** Parent §4.17 keeps text mode open in a regeneration recovery state, with an immutable record of the retired buffer, a read-only recovery view, _Retry text editor_, _Return to canvas_ and a model-only Save All path. Preparing a replacement session can only fail on a writer bug: the applied text is the writer's own output (`applyTextContent` asserts that the live model writes `normalizedText`), and serialization's only known exception, a lone `\r`, can't come from a parse. So when preparation fails after Save, Save As or a canvas traversal, the operation logs the failure, ends the session, returns to the canvas and shows a localized message (§4.5). The model already holds the applied text, so nothing is lost; `F2` enters text mode again. There is no recovery record, recovery view, _Retry_, _Return to canvas_, `allowRecoveryModelSave` or recovery focus node. Phase 3's `enterRecoveryReadOnly()` and `_isRecoveryReadOnly` are removed, since nothing uses them (§5). Parent §4.9's "remains true in regeneration recovery" and every recovery check in parent §4.15 and §4.17 no longer apply.
2. **The gate is a plain try-lock.** Parent §4.6 asks for a non-reentrant gate and an assertion in `applyTextContent` that its caller holds it. The gate is one `isBusy` flag per controller, and `applyTextContent` asserts `isBusy` (§4.1). The assertion doesn't tell which operation holds the gate; nothing outside a gated operation calls `applyTextContent`, so that distinction would only guard a hypothetical caller.
3. **One mutation guard at the command choke point.** Parent §4.13 lists the entry points to guard. Every model mutation by command reaches `MPCommand.execute`, so the guard is one check there, plus checks at the `MPUndoRedoController` entry points that change a stack: `add`, `execute`, `executeSubstitutingLastUndo`, `undo`, `redo` and `revertLastUndoWithoutRedo` (§4.1). `clearUndoRedoStack`, called only by a save's commit, isn't guarded, and neither are direct model edits such as Save As's image rebasing, so neither needs authorization.
4. **Strings arrive with the code.** The coding rules forbid hardcoded user text, so the EN/PT strings this phase displays are added here, as Phase 3 did for its own. Parent Phase 6 keeps the help pages, keyboard shortcut pages, CHANGELOG and a review of every text-mode string.
5. **Save As locks the buffer when it is requested.** The file picker writes an empty file at the chosen path before it returns (§2), so an existing file picked for overwriting is already empty then. The parent lets the user type while the picker is open, and a buffer made invalid there makes Save As return `textHasProblems` after the picker and write nothing, which would leave that file empty. So in text mode, Save As takes the buffer lock in the same step as the gate, before its validation, and holds it until the operation ends (§4.6), as every text-mode operation does (change 10). The text applied after the picker is then the text validated before it. This changes parent §3.6 and §4.8 ("Typing isn't gated", "Editing remains available … while the Save As picker is open") and their tests: `t3980`'s "text made invalid while the picker is open" and `t3987`'s "edits during … the picker remain accepted" become "the buffer is read-only while the picker is open". Closing or reloading the tab while the picker is open still leaves the emptied file, as a failed write does today (§8). When the chosen path lacks `.th2`, the picker's file is renamed after the apply and before the write, and a failed write doesn't rename it back.
6. **Save As restores only what it changed before writing.** Parent §4.8 and §4.17 ask a failed Save As to preserve the rolled-back original filename, registration and image paths. Here the registry migration and the commit run only after a successful write, so a failure in the extension rename, the image rebasing, the encoding or the write leaves the registry untouched, and the failure path only restores `_th2File.filename` and the captured image element objects, then rethrows (§4.6). Nothing handles a failure after a successful write or a failed restoration, beyond logging: today's Save As has no rollback at all, and neither `renameFileController` nor `_commitSave` is expected to throw.
7. **A traversal failure returns to the canvas.** Parent §4.15 restores a model and stack checkpoint after a failed canvas traversal, and blocks editing until Reload when that rollback fails. Canvas undo and redo have no rollback today. Here a failed traversal logs the failure, ends the session and returns to the canvas with the message of change 1 (§4.7). A command that threw midway leaves the model as the same failure leaves it on the canvas. No checkpoint, runtime-state capture, `MPUndoRedoController.checkpoint()`/`restore()`, `rollbackFailed` state or Reload-only view is built.
8. **Broken-file items move to Phase 5.** The parent's Phase 4 entry lists `F2` on the broken-file body, and its tests include broken-file cases: Save As enabled for a broken file in text mode (`t3980`), broken-file text in `t3984`, Copy in a broken-file raw session (`t3984`, `t3987`), a broken raw session never traversing (`t3988`) and a broken-file fix (`t3990`). They need Phase 5's raw sessions, so they move to its entry.
9. **Tab close cleans up at once and keeps the text controller.** Parent §4.1 has `removeFileTab` call `onTabClosed()` synchronously on a kept controller. Here it is called for every closing TH2 tab, before the retention decision. It ends the session and returns the mode to `canvas` at once, even while a gated operation runs; that operation finds the closed session after its await and returns `cancelled`. The text controller isn't disposed then: it stays with its owner, the next entry reuses it, and `dispose()` disposes it (§4.10). A reopened tab therefore always shows the canvas, as the parent requires.
10. **Requests made while an operation runs are dropped.** Parent §4.6 serializes the operations through a queue: a second request waits and rechecks the buffer after the first finishes. Here the gate is a try-lock: while one gated operation runs, every other gated request for that controller (mode switches, Discard, Save, Save As, canvas undo/redo, image insertion, and Save All's save of that file) is dropped and returns `cancelled`, with nothing changed and nothing reported (§4.1). Every text-mode operation also takes the buffer lock in the same step as the gate and holds it until it ends, so typing is blocked for the whole operation, validation included; this changes parent §4.6's "Typing remains available while validation awaits". No request waits for another. Reload and disposal aren't requests: a running operation stops at its next check of `isDisposed`. This changes the parent's `t3987` cases where a request waits behind a pending one (§7).
11. **Lifetime checks are disposal and the session.** Parent §4.6, §4.15 and §4.17 ask operations to recheck controller identity after each await. Reload disposes the replaced controller and a tab close ends the session, so after each await a gated operation checks `isDisposed` and, when it works on a text session, that the session is still open (§4.1). No registration recheck or tab-lifecycle generation is added. A canvas Save As or image insertion whose clean tab was closed while its picker was open completes on the tab-less controller (§8). Deferred focus and reveal callbacks check `!isDisposed` and the expected mode. Save All's project save rechecks the project epoch after its new await (§4.6). Another live editor still may not be replaced at a Save As target path (§4.6).

Carry changes 1–11 into the parent during §6 step 7.

## 4. Design

### 4.1 Operation gate and mutation authorization

**`TH2FileOperationGate`** (new, `lib/src/controllers/th2_file_operation_gate.dart`), one per `TH2FileEditController`:

- `Future<T?> run<T>(Future<T> Function() body)`: when an operation is running or the owner is disposed, returns `null` at once without running `body` (§3 change 10). Otherwise it sets `isBusy`, awaits `body` and clears `isBusy` in `finally`. Callers that return a `TH2FileSaveStatus` map `null` to `cancelled`.
- An observable `isBusy` (a MobX `Observable<bool>`, true while an operation runs), which tree navigation and Copy read to ignore clicks (parent §3.8).

Gated operations: `enterTextMode()`, `leaveTextMode()`, `discardTextEdits()`, `saveTH2File()` (also from Save All), `saveAsTH2File()`, `requestCanvasHistory()` and `addImage()`. No gated operation calls another one; one that did would be dropped. Every gated body checks the mode or session it expects after admission, and after each await checks `isDisposed` and, when it works on a text session, that the session is still open (§3 change 11). Reload disposes the replaced controller, and a tab close ends the session (§4.10), so these two checks see both. A stale operation returns `cancelled` before any further apply, filename, registry or write side effect.

**Deferred UI work.** Every scheduled focus or reveal callback captures the controller and the mode it expects, and does nothing when the controller is disposed or the mode changed. Disposal callbacks still dispose their owned nodes.

`TH2FileEditController` owns the gate as `_operationGate` and exposes `Future<T?> runGatedOperation<T>(Future<T> Function() body)`, which `TH2FileEditElementEditController.addImage()` uses, since it lives in another library (§2). Tests call `applyTextContent` through the same method.

`applyTextContent` gains `assert(_operationGate.isBusy)`. Its Phase 2 staleness checks (disposal, session openness and revision after the await) stay as they are. The text controller's idle validation doesn't call it, so nothing else changes there.

**Buffer lock.** `TH2FileEditController` implements `isBufferLocked` as an `Observable<bool>`, `acquireBufferLock()` and `releaseBufferLock()`, idempotent, as Phase 3's owner contract says. In text mode, `leaveTextMode()`, `discardTextEdits()`, `saveTH2File()`, `saveAsTH2File()` and `requestCanvasHistory()` acquire it in the same synchronous step that takes the gate, before any await, and release it in their `finally` (§3 change 10). `applyTextContent`'s revalidation of a buffer changed during its await (Phase 2) stays as a defensive path, and `lockBufferOnAccept` stays harmless, since the lock is idempotent.

**Mutation authorization.** `TH2FileEditController` gains `bool get isModelMutationAllowed => (_editMode == TH2EditMode.canvas) || (_authorizedMutationDepth > 0)` and `T runAuthorizedMutation<T>(T Function() body)`, which increments the depth around a synchronous body. Its callers: the accepted apply (`execute(MPReplaceTH2FileContentsCommand(...))` in `applyTextContent`) and the canvas traversal's `undo()`/`redo()` (§4.7). Never retain authorization across an await. Checks:

- `MPCommand.execute` returns before `_execPrePrepareUndoRedoInfo` when `!th2FileEditController.isModelMutationAllowed`, after an `assert(false, …)` and an `mpLog.e` naming the command type. Nested commands run inside an authorized parent's depth, so they inherit it.
- `MPUndoRedoController.add`, `execute`, `executeSubstitutingLastUndo`, `undo`, `redo` and `revertLastUndoWithoutRedo` check first and, with the same `assert(false, …)` and `mpLog.e`, return without touching a stack. `add` is checked because one caller pushes a command it executed itself (`th2_file_edit_element_edit_controller.dart:1028`, §2). `clearUndoRedoStack` isn't checked: only a save's commit calls it (§3 change 3). Direct model edits, such as Save As's image rebasing and its restoration, aren't intercepted either.
- `TH2FileEditController.undo()`/`redo()` return at once while `!isModelMutationAllowed`, without the assertion, so a canvas path reaching them in text mode does nothing. TH2 undo and redo in text mode go through the editor's routing (Phase 3) to `requestCanvasHistory`.

The text mode flag flips inside the gate (§4.3, §4.4), so commands run while leaving the canvas state on entry, such as finishing a line being drawn, still run in canvas mode.

### 4.2 Edit mode, text controller and body

`TH2FileEditController` gains:

- `enum TH2EditMode { canvas, text }` and `@readonly TH2EditMode _editMode = canvas`.
- `@readonly TH2TextEditController? _textEditController`, created on the first entry, reused by later entries and disposed in `dispose()` (§4.10). The controller implements `TH2TextEditOwner`: `filename`, `th2FileMPID`, `defaultLineEnding` (`_th2File.lineEnding`), `isDisposed`, `canSave` (§4.6), the buffer lock (§4.1), `save()` (logging wrapper around `saveTH2File()`, as `_saveActiveTab` does), `discardTextEdits()` and `requestCanvasHistory()`.
- `@readonly TH2TextApplyRejection? _textApplyRejection`: the rejected buffer string (the result's `content`, §5) and its diagnostics, shown by the "can't apply" banner (§4.4). It is cleared by _Keep editing_ and by any session end or replacement. The banner shows only while the session's `content` equals the rejected string, a `@computed` read, so the first edit after a rejection hides it without a buffer-change hook.
- `toggleEditMode()`: `enterTextMode()` on the canvas, `leaveTextMode()` in text mode. Broken files are Phase 5: on a broken file with no text session it does nothing.
- `FocusNode get activeFocusNode`: the text controller's `textFieldFocusNode` while `editMode == text` and a session is open; `th2FileFocusNode` otherwise. The three tab-activation sites (§2) use it, so a tab in text mode focuses its field when activated.

**`TH2FileEditBodyWidget`**, once the load future has data, decides inside one `Observer`: `editMode == text` → `TH2TextEditBodyWidget`; else `isBroken` → `TH2BrokenFileBodyWidget`; else the canvas. The `snapshot.data!.problems.isNotEmpty` test is removed (parent §4.1). The last-used chips and the status bar are built in the same `Observer`, only when `!isBroken && editMode == canvas`.

**`TH2TextEditBodyWidget`** (new, `lib/src/widgets/th2_text_edit_body_widget.dart`), inside an `Observer`, is a `Column`: the "can't apply" banner while it applies (§4.2, §4.4), then `THTextEditorWidget(controller: textEditController, leadingToolbarActions: [canvasButton])`. The _Canvas_ button calls `toggleEditMode()` through an error-logging handler, with the tooltip "Canvas (F2)".

**Mode buttons and `F2`.** `TH2FileEditActionButtonsWidget` gets a _Text_ button (tooltip "Text (F2)") calling `enterTextMode()`. The page's `CallbackShortcuts` gains `SingleActivator(LogicalKeyboardKey.f2)`, which calls the active TH2 tab's `toggleEditMode()` through the same handler, and does nothing on a `thconfig`/`.th` tab. The text field doesn't handle `F2`, so it bubbles to the page from both views.

### 4.3 Entering text mode

`enterTextMode()`:

1. Runs gated (§4.1): while an image insertion or a canvas Save As runs, the request is dropped. After admission, it returns when disposed, not loaded (`!isFileLoaded` or `loadError != null`), without an open tab (`openFileOrder` lacks its filename), already in text mode, or broken (Phase 5).
2. Asserts `!isInteractiveLineSimplificationDialogOpen.value` (parent §4.13).
3. Checks the text source: `serializeForTextMode()`, whose result is only used for this check. On `TH2UnsupportedLineEndingException`, it shows the localized unsupported-line-ending message (a `SnackBar` through `mpLocator.mpNavigatorKey`, with an error log) and returns, before changing any state, so the canvas, state and selection stay as they were (parent §3.1, `t3976`).
4. Leaves the canvas state as the tree does, `stateController.onButtonPressed(MPButtonType.select)`, except in _Line edit_ mode. Leaving an add-line or add-area state finalizes the line or area being drawn (`onStateExit`), as `Esc` does. Overlay windows are closed with `overlayWindowController.clearOverlayWindows()`. These may change the model; the mode is still `canvas`.
5. Serializes again, always, so the session describes the final model. (An `undoCount` comparison would miss `executeSubstitutingLastUndo` and a revert followed by an execute.)
6. Computes the cursor (parent §3.2) on that text: the smallest `firstOwnLineOf` among the selected points, lines and areas, the line segments of the selected end and control points and `selectedScrapMPIDs`; in _Line edit_ mode with no selected line point, the edited line. Its first non-blank column comes from the text. With no selection, the baseline has no selection and cursor line 0 (`endSession()` reset the cursor), and the editor, newly mounted with the text body, restores the tab's `lastScrollOffset` through its `initialScrollOffset`.
7. Creates the text controller if needed, installs the baseline (`TH2TextEditBaseline` with content, map, cursor and a pending selection at the cursor, `selectionRequestsFocus: true`), and sets `_editMode = text`. Step 7's assignments run in one MobX action.
8. After the frame, focuses `activeFocusNode`, subject to the deferred UI checks in §4.1.

Entry adds no text-apply command and no text history. Finalizing a canvas gesture in step 4 may execute its normal canvas commands, which stay undoable. If the second serialization fails, report/log the error and retain canvas mode without installing a session; gesture finalization already completed is not rolled back.

### 4.4 Leaving text mode, Discard and selection on the canvas

**`leaveTextMode()`**, gated:

1. Returns when no session is open. The buffer lock is held from admission (§4.1).
2. Awaits `applyTextContent(session.content, session: session, lockBufferOnAccept: true)`.
3. `rejected`: sets `_textApplyRejection`, publishes its diagnostics on the session at once (§5), and returns; the `finally` releases the lock, so the buffer is editable again, and the mode stays `text`. `cancelled`: returns.
4. `applied` or `unchanged`: maps `result.cursorLine` with `TH2TextElementLocator.locate` against `result.lineMap` and the live file, calls `endSession()`, sets `_editMode = canvas`, then `applyTextLocation(location)` and, after the canvas is laid out, `revealSelection()`, then focuses `th2FileFocusNode`, with deferred reveal/focus guarded by §4.1.
5. `finally`: releases the buffer lock.

**`applyTextLocation(TH2TextLocation)`** follows parent §3.3. The cursor decides the active scrap; the scrap active before text mode only survives at file level. This is required, since only the active scrap's elements can be selected on the canvas (§2):

- `selectElement`: `setActiveScrap(scrapMPID)`, then `selectionController.setSelectedElements([element], setState: true)`, as a tree single tap.
- `selectLinePoint`: `setActiveScrap(scrapMPID)`, then `setSelectedElements([line], setState: true)` and `stateController.setState(editSingleLine)`, as the double-click does. Passing through the selection state matters when entry kept _Line edit_ mode (§4.3 step 4): `setState` does nothing for the current state, so `onStateEnter` wouldn't rebuild the line's clones and selectable end points, and after an apply every element object is new. Then `setSelectedEndControlPoint` with the segment's end point from `getMPSelectableEndControlPoints()` (type `endPointStraight` or `endPointBezierCurve`), `updateSelectableEndAndControlPoints()` and `triggerEditLineRedraw()`, as a click on the point does (`mp_th2_file_edit_state_edit_single_line.dart:356-365`).
- `activateScrap`: `setActiveScrap(scrapMPID)`, then `setSelectedElements([], setState: true)`.
- `fileLevel`: `setSelectedElements([], setState: true)`; keep the active scrap if it exists, else the first scrap (already ensured by the apply's refresh, §2).

Clearing through `setSelectedElements([], setState: true)` also leaves _Line edit_ mode when entry kept it (§4.3 step 4) and the active scrap didn't change, so no `editSingleLine` state is left without a selected line. `setActiveScrap` shows a hidden scrap (§4.9), so selection inside a hidden scrap shows it.

**`revealSelection()`** (parent §4.11): the selection's bounding box, or the selected line point's position, is compared with the visible canvas rectangle; when not fully inside, `_canvasCenterX/Y` move to its center at the current scale, with `_setCanvasCenterOnZoom`'s math. It is called from a post-frame callback after the body swap, so the rebuilt canvas has been laid out; when the canvas has never had a size, it waits for layout the way `requestZoomToFit` does.

**`discardTextEdits()`**, gated, with the buffer lock from admission: returns when no session is open; otherwise calls `endSession()`, clears `_textApplyRejection`, sets `_editMode = canvas` and focuses the canvas; `finally` releases the lock. The model is untouched, and canvas traversals made in the session stay in effect (parent §4.15). The toolbar's Revert (the text controller's `revert()`) and the banner's _Discard text changes_ both await it. The banner's button is only reachable after the rejecting operation has released the gate, since the banner is set inside that operation and shown afterwards.

**The "can't apply" banner** shows "The text has problems and can't be applied. Fix the marked lines, or discard the text changes." with _Keep editing_ (clears `_textApplyRejection` and focuses the field) and _Discard text changes_. It shows while the buffer still equals the rejected text (§4.2). Every rejecting operation publishes the rejection's diagnostics on the session at once, so the markers and the editor's line-less row (Phase 3) show them without waiting for idle validation. It is also set by Save and Save As when they return `textHasProblems`.

### 4.5 Session replacement and regeneration failure

**`_prepareTextSession({required int cursorLine})`** builds a `TH2TextEditBaseline` from the live model without touching the installed session: `serializeForTextMode()`, the cursor line clamped to the new text, its first non-blank column, and a pending selection without changing focus requests. It throws whatever serialization throws. Save and Save As pass the apply result's `cursorLine`, which the apply already mapped through *N(T)* into the live writer text (parent §4.12); the new text has the same lines, since Save As's image rebasing rewrites lines without adding or removing any.

**`_replaceTextSession(...)`** runs inside a gated operation that holds the buffer lock: it prepares the candidate, then calls `installBaseline` in one action. Preparation is synchronous, so nothing can change between the two. `installBaseline` already ends the old session's state and advances both revisions, so no frame shows an empty session, and no baseline is published when preparation throws. Used by Save, Save As and canvas traversal.

**Regeneration failure** (§3 change 1). When preparation throws:

1. Log the exception and stack trace.
2. Call `endSession()`, clear `_textApplyRejection`, set `_editMode = canvas`, and show the localized "text editor couldn't be reopened" message (a `SnackBar` through `mpLocator.mpNavigatorKey`). The canvas gets focus after the frame, subject to §4.1's deferred checks.
3. The operation goes on as after a successful replacement: a Save or Save As whose write succeeded finishes its bookkeeping and returns `saved`; after a failed write, the write exception is rethrown and the regeneration exception is only logged.

The model holds the applied text, so returning to the canvas loses nothing.

### 4.6 Dirty state, Save and Save As

**Observables.**

- `TH2File.isNewFile` is backed by an `Observable<bool>`; the getter and setter keep their names, the setter writes in `runInAction` (parent §4.8). `toMap`, `fromMap` and `replaceContentsFrom` don't carry it.
- `@computed bool get hasUnsavedChanges => enableSaveButton || (_textEditController?.isDirty ?? false)`.
- `@computed bool get canSave => hasUnsavedChanges && !_th2File.isNewFile`. It implements the owner's `canSave`.
- The dirty-mirroring reaction watches `canSave` instead of `enableSaveButton`, and the comment in `renameFileController` that names the reaction's input (`mp_general_controller.dart:623`) names `canSave`. `shouldKeepTablessTH2Controller` uses `hasUnsavedChanges`. `_saveTH2ProjectFile`'s "already saved" check uses `canSave`.
- `enableSaveButton` keeps its formula; `_hasUnsavedBaseline` is Phase 5.

**`TH2FileSaveStatus`** gains `textHasProblems` and `cancelled`; its doc comment is updated (parent §4.8).

**`_actualSave` split.** `_writeFile(File file)` encodes and writes with `flush: true`; `_commitSave()` then runs `undoRedoController.clearUndoRedoStack()` and `updateUndoRedoStatus()`. Nothing is cleared when the write throws.

**`Future<TH2FileSaveStatus> saveTH2File()`**, gated:

1. A new file returns `saveFailed` with nothing applied or written.
2. In text mode with an open session: awaits `applyTextContent(..., lockBufferOnAccept: true)`. `rejected` sets `_textApplyRejection`, publishes its diagnostics and returns `textHasProblems`; `cancelled` returns `cancelled`. Remembers that an apply ran and the result's `cursorLine`.
3. `if (_isBroken) return saveFailed;`, after the apply, as the parent orders (Phase 5 makes the apply clear it).
4. `_writeFile`, then `_commitSave()`, `isNewFile = false`, `closeAutoDismissOverlayWindows()`.
5. In text mode after step 2, whether the write succeeded or threw: `_replaceTextSession` from the live model, or the regeneration-failure exit when it fails (§4.5). A write exception is rethrown after it.
6. `finally`: releases the lock. Returns `saved`.

**`Future<TH2FileSaveStatus> saveAsTH2File()`**, gated for its whole length, including the picker:

1. When the gate is busy, the request is dropped (`cancelled`) and nothing is locked. Otherwise the gate is taken, and in text mode the buffer lock too, in the same synchronous step, held until the `finally` (§3 changes 5 and 10). Outside text mode the broken-file guard is unchanged. Captures `originalFilename` (`_th2File.filename`: the controller's registry key, a placeholder for a new file).
2. In text mode: a buffer equal to `initialContent` is valid without a parse, as in `applyTextContent`. Otherwise it validates the buffer through `session.validationCache.validate` (cached when current); after the await, a closed session or a disposed controller returns `cancelled`. Invalid → `_textApplyRejection` with its diagnostics published, `textHasProblems`, no picker; the `finally` releases the lock, so the buffer is editable again. Valid → the picker opens with the buffer still read-only.
3. Awaits the picker. Dismissed, disposed, or in text mode a closed session (a tab close, §4.10) → `cancelled`; no apply, rename or Mapiah write runs, and `finally` releases the lock. Compute the final target path (with `.th2` appended when missing, as step 5 will name it) and normalize it as the registry does (`_normalizeFilename`). Then check that no other TH2 controller is registered under it: `renameFileController` would otherwise overwrite that registry entry silently, leaving its controller unregistered but alive. Text editor tabs never have a `.th2` key (`isTH2Tab`), so they can't collide. On collision return `cancelled` before applying or renaming. Saving to this controller's own path is allowed. The picker's earlier truncation of the file on disk remains a separate risk (§8).
4. In text mode: `applyTextContent(..., lockBufferOnAccept: true)` on the locked buffer, which is the validated text, so the cached result is accepted. `cancelled` → `cancelled`, with nothing written. A `rejected` result can't occur; it is handled as in Save, defensively. Steps 5–8 are synchronous (`renameSync`, and `_writeFile` keeps `writeAsBytesSync`), so nothing interleaves between the last await and the end of the write.
5. The `.th2` renaming of the picked path, as today.
6. Records `previousFilename` (the image-rebasing reference, `''` for a new file, as today) and the image element objects that `_rebaseImportedImagePathsForSaveAs` will replace; sets `_th2File.filename`, rebases image paths.
7. `_writeFile`. When step 5, 6 or 7 throws (§3 change 6): put the captured image objects back with `substituteElement` and restore `_th2File.filename`; in text mode, replace the session from the live model, which holds the accepted apply (§4.5); rethrow. Rebasing replaces each image with a copy, and `copyRuntimeImageCacheTo` copies caches without moving them, so the captured objects still have their representation, runtime caches and view flags. If the restoration itself throws, log it and rethrow the original exception. The registry hasn't changed, so the controller stays registered under `originalFilename`, with its dirty mark, and the apply stays one undoable command.
8. On success, in this order (parent §4.8): `renameFileController(oldFilename: originalFilename, newFilename: filePath)`, `_commitSave()`, in text mode `_replaceTextSession` (§4.5), `isNewFile = false`, `_markLoadedAfterSaveAs()`, `lastAccessedDirectory`, `closeAutoDismissOverlayWindows()`. A regeneration failure doesn't skip the steps after it.
9. `finally`: releases the lock. Returns `saved`.

**Callers.**

- The app bar's Save and the overflow menu's Save call `_saveActiveTab`; the app bar's Save As and the menu's Save As call `_saveActiveTabAs`. Both page methods are `async`, await inside `try/catch` and log; `_saveActiveTab` checks `canSave`. When either returns `textHasProblems`, the banner already shows it, and nothing else is reported; `cancelled` reports nothing.
- Save's enabled state everywhere is `canSave`. Save As is enabled for a non-broken file (Phase 5 enables it for a broken file in text mode).
- The canvas key handler's whole `keyS` case is removed (parent §4.8).
- `_saveTH2ProjectFile` awaits `saveTH2File()` and propagates `textHasProblems`, `cancelled` and `saveFailed` without removing dirty paths. After the await, it rechecks `_isCurrent(epoch, root)` before removing the dirty path or reporting success: a changed project returns `projectChanged`, so an old-project write never clears a new project's dirty path. A busy gate returns `cancelled`, so Save All is incomplete (`isComplete` is false, §3 change 10).
- `TH2TextEditController.save()` keeps its Phase 3 behavior through the owner's `save()`.

### 4.7 Canvas history traversal before the first text edit

`requestCanvasHistory({required bool redo})`, gated:

1. Rechecks an open session, `!hasTextEdits` and not broken. Otherwise returns.
2. Returns when there's nothing to undo or redo.
3. With the buffer lock held from admission (§4.1), notes the cursor line and column, and the MPID that owns the cursor line.
4. Calls `TH2FileEditController.undo()`/`redo()` under `runAuthorizedMutation`, bypassing their text-mode early return (§4.1). These owner wrappers run `_undoRedoDone()` (status, selection and overlay cleanup); calling the undo/redo sub-controller alone would skip it.
5. `syncControllersWithModel(initialSetup: false)`.
6. Prepares and installs a new baseline (§4.5), with the cursor at the same MPID's line and own-line offset when the owner of the old cursor line survives, otherwise the old line and column clamped. `hasTextEdits` stays false, and the installation's new baseline revision remounts the field with an empty native history and invalidates pending idle validation.
7. On an exception in steps 4–6: logs it and takes the regeneration-failure exit (§4.5, §3 change 7). Nothing is rolled back: a command that threw midway leaves the model as the same failure does on the canvas today.
8. `finally`: releases the lock and focuses the current `activeFocusNode`, subject to §4.1.

### 4.8 Exclusive text mode, Properties, tree Copy and the image gate

**Disabled tree actions.** `prepareTH2FileForTreeOptions` returns `null` when the controller's `editMode == text`, before `addFileTab`; `prepareTH2FileForTreeEdit` calls it first, so both refuse. In `th2_element_tree_row_widget.dart` and `th_project_tree_node_widget.dart`:

- the menu builders give drawing-order items, _Move to scrap_, Cut, Duplicate, Delete, _Scrap options_ and _Add scrap_ a `null` `onPressed` while the row's controller is in text mode. The items are built once when the menu opens (§2), so this reflects the mode at that moment;
- callbacks of a menu opened before entry, which still has enabled items, recheck `editMode` before acting;
- inside the row's `Observer`, `Draggable` is replaced by the plain row (no drag source) while the controller is in text mode, and drop targets reject payloads whose source or target controller is in text mode (`onWillAcceptWithDetails`), rechecked in `onAcceptWithDetails`.

**Properties.** `MPFileTabWidget` gains `bool propertiesEnabled = true`; when false, the button stays visible with `onPressed: null`. The page builds each TH2 tab's widget in an `Observer` and passes `propertiesEnabled: controller.editMode == TH2EditMode.canvas`. `prepareSetEncoding` returns when its controller is in text mode.

**Tree Copy in text mode.** `_executeScrapEdit('copy')` is split off into `_copyFromTree()`:

- On the canvas it calls `prepareTH2FileForTreeEdit` and `copyScraps(ids)` as today.
- In text mode it calls a new `MPGeneralController.prepareTH2FileForTreeRead(path)`, which activates the tab only, then, if the gate isn't busy and a session is open, `controller.copyTextFragment(ids)`.
- Element rows get a Copy item in text mode only (§3.8 of the parent), using `_menuSelection`.

`TH2FileEditController.copyTextFragment(List<int> mpIDs)` (new) builds the fragment synchronously from the session's `initialContent` and `initialLineMap`: it skips MPIDs whose `rangeOf` is `null`, orders the rest by `rangeOf(...).first`, drops any MPID inside the range of another requested one, adds before each area the border lines that the canvas copy adds (`_buildCopyResult`'s rule, extracted into a helper that returns MPIDs), deduplicated, and concatenates each block's text from its range, keeping its line endings, adding `_th2File.lineEnding` between blocks only where a block ends unterminated. It then awaits `Clipboard.setData(ClipboardData(text: fragment))` with the captured string, logs failures, and never touches the controller after the await. The internal clipboard is not touched. The tree's Copy item shows no error dialog on failure, only the log.

**Image gate.** `addImage()` runs its body through `runGatedOperation` (§4.1): after admission it returns unless the controller is live and in canvas mode; it rechecks `isDisposed` after the picker and after `_warmAddedImageBounds`, before `execute`. The picker's `BuildContext` lookup moves inside the gated body. An exception from `_warmAddedImageBounds` is logged and propagates to the two callers, which now call it through `unawaited(...catchError(log))`.

**Canvas Save and Save As** use the same gate (§4.6), so `F2` or the _Text_ button while a canvas Save As picker is open is dropped.

### 4.9 Tree navigation in text mode and the always-visible active scrap

**`_onTap`.** After `_validControllerFor`, when `editMode == text`: reset the tap tracker, bring the tab to the front as today, call `controller.moveTextCursorToElement(row.elementMPID)` (the scrap's MPID on a scrap row) and return.

**`_onBeforeOpenMenu`.** In text mode: `moveTextCursorToElement(mpID, requestFocus: false)` and return. `THProjectTreeRowContextMenuWidget` gains `VoidCallback? onAfterClose`, passed to `MenuAnchor.onClose`; the TH2 row passes one that requests `textFieldFocusNode` when the tab is still in text mode with an open session.

**`moveTextCursorToElement(int mpID, {bool requestFocus = true})`**: returns while the gate is busy or no session is open. Takes `initialLineMap.firstOwnLineOf(mpID)`; returns when `null`. When the buffer differs from `initialContent`, maps it through `lineTracker.currentLineOf` (Phase 2's lookup, giving the nearest unedited line above, or line 0). Sets the pending scroll and a pending selection at the line's first non-blank column, with `pendingSelectionRequestsFocus: requestFocus`.

**Highlighted rows** keep following the live canvas selection; nothing in text mode changes it.

**Text mode ignores scrap visibility and the active scrap.** The text always holds the whole file, and tree clicks, the context menu and Copy reach elements in any scrap without activating or showing it. The eye buttons keep working in text mode as on the canvas: they only change what the canvas will show. Only leaving text mode touches the active scrap, through the cursor (§4.4).

**Active scrap always visible** (parent §3.9, §4.14):

- `setActiveScrap(id)` calls `hideElementController.ensureScrapVisible(id)` first, before its same-ID early return. Snap targets need no refresh there: the active scrap is a snap source whether it is hidden or not (§2).
- `toggleScrapVisibility` does nothing when asked to hide the active scrap; `setScrapsHidden(ids, true)` skips the active scrap. `_setActiveScrapForVisibilityHide` is removed.
- The active scrap row's eye button has `onPressed: null` while visible, with the tooltip "The active scrap can't be hidden".
- The scrap menu's item reads Hide only when one of its scraps other than the active one is visible; otherwise Show (for the hidden ones). On the active scrap alone, Hide is disabled.
- `syncControllersWithModel` already shows the active scrap (Phase 2).

### 4.10 Tab close, reload and disposal

- `onTabClosed()` (new), in one action, ends the session if one is open, clears the rejection and sets `_editMode = canvas` (§3 change 9). It does this at once, even while a gated operation runs. That operation is at an await, because a tab close is a UI event; after the await it finds the closed session and returns `cancelled`, and its `finally` still releases the buffer lock. The text controller isn't disposed: the next entry reuses it. `onTabClosed()` applies nothing.

  `removeFileTab` calls it for every closing TH2 tab, before `shouldKeepTablessTH2Controller` decides retention. A reopened tab shows the canvas. Entry checks for an open tab (§4.3), so it never puts a tab-less controller in text mode. Because the session ends first, text that was never applied no longer counts as unsaved when retention is decided: the text is lost without a prompt, as unsaved canvas changes are today (`close()` has no unsaved-changes dialog), and when the model itself is clean, the controller is kept tab-less if its tree row is expanded, like any clean controller. A model with unsaved canvas changes or an applied text still disposes the controller, as today.
- `dispose()` disposes the text controller. A running gated operation finds `isDisposed` after its next await and returns, so nothing runs against a disposed or replacement controller (`reloadTH2File` replaces the controller).
- Disposing the text controller defers disposing its focus nodes (`textFieldFocusNode`, `textEditorFocusNode`) to a post-frame callback while they are still attached, as `dispose()` does for `th2FileFocusNode` (§2).

### 4.11 Strings

EN and PT `.arb` entries, then `flutter gen-l10n`: the _Text_ and _Canvas_ button tooltips, the "can't apply" banner text, _Keep editing_, _Discard text changes_, the unsupported line ending message, the message shown when the text editor can't be reopened after a save or a canvas traversal (§4.5), and "The active scrap can't be hidden". Phase 3 already added the TH2 Revert tooltip and the diagnostic texts.

## 5. Phase 3 contract changes

- `TH2TextEditController`: remove `enterRecoveryReadOnly()`, `_isRecoveryReadOnly`, its `isRecoveryReadOnly` getter, its reset in `installBaseline` and its check in `revert()`; `canSave => _owner.canSave`; `isReadOnly => _owner.isBufferLocked` (§3, change 1). The tests using `enterRecoveryReadOnly`, `t3974` (`:446`) and `t3975` (`:391`), are updated to the closed-session behavior.
- `TH2TextEditController` gains `showDiagnostics(List<TH2TextDiagnostic> diagnostics, {required String content})`, which publishes them, as idle validation does, only while the session is open and its `content` still equals the given one. Rejecting operations call it (§4.4).
- `TH2TextEditController.dispose()` defers disposing `textFieldFocusNode` and `textEditorFocusNode` to a post-frame callback while they are attached, as `TH2FileEditController.dispose()` does for `th2FileFocusNode` (§4.10); today it disposes them at once.
- `TH2TextApplyRejected` (Phase 2) gains `content`, the text its diagnostics describe. Rejecting operations store it in `_textApplyRejection` and pass it to `showDiagnostics`, instead of reading `session.content` after the await.
- `TH2TextEditBaseline` gains nothing: entry, replacement and traversal pass content, map, cursor and selection as it already allows.

## 6. Implementation sequence

Each step is one commit on the branch, with `flutter analyze` clean and `flutter test` green. After changing MobX-annotated code, run `dart run build_runner build --delete-conflicting-outputs` in the worktree (the main checkout's watch doesn't cover it) and commit the regenerated `.g.dart` files; after `.arb` changes, `flutter gen-l10n`.

1. **Gate and authorization (§4.1).** `TH2FileOperationGate` with `isBusy`, `runGatedOperation`, `TH2EditMode` and `_editMode` (canvas until step 4), the buffer lock on `TH2FileEditController`, `isModelMutationAllowed`/`runAuthorizedMutation`, the `MPCommand.execute` and `MPUndoRedoController` checks (`add` included), the early return of `TH2FileEditController.undo()`/`redo()`, the gate assertion in `applyTextContent` (update `t3965`–`t3971`, `t3974` and `t3985` to call it through `runGatedOperation`), and the gated `addImage()` (§4.8). No visible change on the canvas.
2. **Canvas save pipeline (§4.6).** Observable `isNewFile`, `hasUnsavedChanges` (without its text term yet) and `canSave`, the reaction and call-site changes, the new statuses, `_writeFile`/`_commitSave`, the asynchronous gated Save and Save As with the target-collision check and the filename/image restoration on a failure before or during the write, the page callers, removing the `keyS` case, `_saveTH2ProjectFile` with its epoch recheck, and the `renameFileController` comment. No text-session branches yet. Update `t3909` to await, and its comment that replays Save As's steps in the old order. Add `t3980`'s canvas cases (exactly-once `Ctrl+S`/`Ctrl+Shift+S`, write failure with restoration, target collision, a new file's Save As renaming its placeholder key, dirty paths).
3. **Active scrap always visible (§4.9).** Hide controller, `setActiveScrap`, eye button, scrap menu. Replace `t3670`'s active-scrap test and update `t3953`'s undo assertion (§7).
4. **Mode switching and text-mode saving (§4.2–§4.6, §4.10).** The owner implementation, `hasUnsavedChanges`'s text term, `enterTextMode`, `leaveTextMode`, `discardTextEdits`, `toggleEditMode`, `TH2TextEditBodyWidget` with its banner, the body `Observer`, buttons, `F2`, `activeFocusNode` at the three focus sites, `applyTextLocation`, `revealSelection`, `onTabClosed` and its call in `removeFileTab`, Properties, the §4.11 strings, and the Phase 3 contract changes (§5). §4.5 (`_prepareTextSession`, `_replaceTextSession` and the regeneration-failure exit) and the text-mode branches of Save and Save As, with the buffer lock from each operation's start. The owner's `requestCanvasHistory` does nothing until step 6. Add `t3976`–`t3979`, `t3980`'s text-mode cases and `t3990`.
5. **Exclusive tree and navigation (§4.8, §4.9).** Disabled tree actions and drag/drop, `prepareTH2FileForTreeRead`, `copyTextFragment`, the `_onTap`/`_onBeforeOpenMenu` branches, `moveTextCursorToElement`, `onAfterClose`. Add `t3981`, `t3984`.
6. **Canvas history traversal (§4.7).** `requestCanvasHistory` with its regeneration-failure exit. Add `t3987`, `t3988`.
7. **Parent plan update.** Record §3's changes in the parent's Phase 4 entry and in the sections they change (§3.6, §4.1, §4.6, §4.8, §4.9, §4.13, §4.15 and §4.17, whose recovery state and traversal rollback are replaced by changes 1 and 7), rewrite its Phase 4 tests `t3987`, `t3988` and `t3990` and its risk 6 (post-apply regeneration) to match, move the broken-file items to its Phase 5 entry (§3 change 8), correct its `t3670` bullet's "and `t3953`'s, pass unchanged" (§7), mark Phase 4 implemented, and run the whole suite.

Do not run `dart format`.

## 7. Verification

### Existing tests

- `t3909` passes, changed only to await `saveTH2File()` (and its step-replay comment). `t3944` passes unchanged: it already awaits `saveAsTH2File()`, and a new file's Save As still marks it loaded in one transition.
- `t3937` (Save As routing) and `t3050` (plain `S` in _Line edit_ mode, handled by the state, not by the removed `keyS` case) pass unchanged.
- `t3948` and `t3949` (tree drag/drop, context menu) pass unchanged on the canvas. `t3953` (scrap actions) too, except its "visibility keeps the last scrap visible and ignores deleted scraps" test: undoing the removal of the hidden scrap `s2` re-adds it through `afterAddScrap`, which makes it active (§2), so it is now visible; the test expects `s2` active and visible after the undo.
- `t3670`: its test that hiding the active scrap moves to the nearest visible scrap is replaced by one where `toggleScrapVisibility` on the active scrap leaves it visible and active, with the selection unchanged.
- `t3940` (broken-file body) passes unchanged; Phase 5 adds _Edit as text_.
- Phases 1–3 tests (`t3960`–`t3975`, `t3985`, `t3986`, `t3989`) pass; the tests calling `applyTextContent` (`t3965`–`t3971`, `t3974`, `t3985`) run it inside the gate, and `t3974`/`t3975` drop `enterRecoveryReadOnly` (§5).

### New tests

Widget tests use `t3950`'s `TH2FileTabsPage` setup. The parent's Phase 4 entry (§5) describes each one in full; this table lists them with what this plan adds and changes. The parent's broken-file cases move to Phase 5 (§3 change 8), its "edits during the picker" cases become "the buffer is read-only while the picker is open" (§3 change 5), and its cases where a request waits behind a pending one become "the request is ignored" (§3 change 10).

| File | Coverage |
| --- | --- |
| `t3976_th2_text_mode_entry_test.dart` | Parent `t3976`: cursor on the selected element nearest the top, the first selected line point in _Line edit_ mode; a lone `\r` in the writer output keeps the canvas with the message and changes nothing. Also: entry finalizes a line or area being drawn, the text includes it, and its normal undoable canvas commands remain with no text-apply command; a forced failure of the second serialization keeps the canvas, with the finalization retained and no session installed; overlay windows close; `F2` while the file is still loading, and `F2` while the image picker is open, both leave the controller on the canvas; with no selection, the editor shows the tab's last scroll offset. |
| `t3977_th2_text_mode_selection_test.dart` | Parent `t3977`: each row of parent §3.3; line point round-trip, also in a scrap other than the one active before entry, and after entering from _Line edit_ mode on a line, an apply, and the cursor on another point of the same line. Also: `revealSelection` moves the center without changing the scale only when the selection is outside the view; a cursor in a hidden scrap shows it and snapping reaches its elements; a cursor at file level or on the active scrap's `scrap` line after entering from _Line edit_ mode leaves the state `selectEmptySelection`; leaving after the active scrap was deleted in the text activates the first scrap. |
| `t3978_th2_text_mode_undo_steps_test.dart` | Parent `t3978`, plus `t3966`'s "returning to the canvas" assertion moved from Phase 2. |
| `t3979_th2_text_mode_rejection_test.dart` | Parent `t3979`; the banner's _Keep editing_ and _Discard text changes_; markers show right after a rejected leave, before idle validation runs; the first edit hides the banner. |
| `t3980_th2_text_mode_save_test.dart` | Parent `t3980` without its broken-file case, plus `t3969`'s Save and Save As assertions moved from Phase 2. Also: the buffer refuses typing while the Save As picker is open, and confirming applies the validated text; a new file's Save As, from the canvas and from text mode, re-registers the controller from its placeholder key. Forced failures of the extension rename, the image rebasing and the write, after an accepted apply and on the canvas, restore `_th2File.filename` and the captured image objects (`identical`), leave the registry key, history and dirty paths unchanged, keep one apply command, and in text mode leave a session matching the live model. Canvas Save As of a file with a lone `\r` still works. A target registered to another TH2 controller, also once `.th2` is appended, returns `cancelled` with both controllers unchanged; Save As to the controller's own path succeeds. Save All leaves the dirty path of a rejected or cancelled save, and returns `projectChanged` when the project changed during the save. |
| `t3981_th2_text_mode_tree_navigation_test.dart` | Parent `t3981`. Also: eye buttons work in text mode as on the canvas and change neither the session nor the active scrap. |
| `t3982`, `t3983` | Reserved for Phase 5. |
| `t3984_th2_text_mode_exclusive_tree_test.dart` | Parent `t3984` without its broken-file cases, including the `MPCommand.execute` and `MPUndoRedoController` guards (`add` included, through the line-point removal path) and `copyTextFragment`. The guards throw an `AssertionError` in debug before any model or stack change: the tests expect it and then check that nothing changed. |
| `t3987_th2_text_mode_operation_gate_test.dart` | Parent `t3987` with its history, image-entry and Discard cases, without its broken-file cases and its rollback cases (§3 change 7), and with every case where a request waits behind a pending one (Save, `F2`, Discard, undo/redo, image entry, `saveAllModifiedFiles`) changed to: the request is ignored, returns `cancelled` where it returns a status, and changes nothing (§3 change 10). Also: the buffer refuses typing from the start of a leave, Save, Save As, Discard or traversal until it ends, also while validation awaits; `applyTextContent` outside a gated operation fails its assertion; `isBusy` is true exactly while an operation runs; `Ctrl+Z` while the Save As picker is open does nothing; closing a clean tab while a text-mode Save As picker is open ends the session and returns the mode to the canvas at once, Save As then returns `cancelled` with nothing applied, renamed or written, and the reopened tab shows the canvas; a reload while an operation awaits leaves the new controller untouched; Save All reports a file whose gate is busy as not saved. |
| `t3988_th2_text_mode_canvas_history_test.dart` | Parent `t3988` without its broken-file case and with its rollback cases replaced (§3 change 7): a forced failure of the command or of the baseline preparation logs it, ends the session, shows the canvas with the message, and publishes no partial baseline. |
| `t3990_th2_text_mode_regeneration_failure_test.dart` | Parent `t3990`, replaced by the regeneration-failure exit (§3 change 1) and without its broken-file case: a forced preparation failure after Save and Save As, with applied and unchanged text, ends the session and shows the canvas with the message; after a successful write the save bookkeeping is complete (Save As's registry, `isNewFile` and loaded state included), the file is clean and Save All gets `saved`; after a failed write the write exception reaches the caller and the file stays dirty. Failures are injected through a `@visibleForTesting` hook on `_prepareTextSession`, like Phase 2's static test hooks. |

Commands, from the feature worktree (§1):

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

1. **Dropped requests.** A request made while an operation runs does nothing and shows nothing (§3 change 10), so a quick second press is lost, and typing is blocked while an operation validates. Save All reports a busy file as not saved, and Run Therion warns about it. A gated operation calling another one would be dropped silently; none does. `t3987` covers these.
2. **Save ordering.** Save As's rename, commit, new session and `isNewFile` order decides the dirty path; `t3980` records `dirtyFilePaths` changes with a listener.
3. **Minimal failure handling.** Save As restores the filename and the image elements only for a failure before or during the write; a regeneration or traversal failure returns to the canvas without rolling anything back (§3 changes 1, 6 and 7). A failure after a successful Save As write, or of the restoration itself, is only logged. `t3980`, `t3988` and `t3990` inject the handled failures.
4. **Guard false positives.** A canvas feature that executes a command from a timer or callback while the tab is in text mode is now rejected and logged. The interactive line simplification dialog is modal; the image insertion is gated. `t3984` exercises the known paths; any new rejection log during the full test suite is investigated before the phase is marked implemented.
5. **Focus.** Remounting the field and swapping bodies at mode switches can lose focus; tests type characters to check focus, not only `hasFocus`.
6. **The picker's empty file.** The file picker empties a picked existing file before Mapiah writes it (§2). Locking the buffer before the picker (§3 change 5) prevents edits from invalidating the validated source. It does not undo prior picker truncation when tab closure/reload cancels the operation, a target collision is rejected, or a later rename/rebase/write fails. Eliminating this disk risk requires a path-only picker or a separate save-transaction change; this phase does not claim that guarantee.
7. **Pickers outlive tabs.** A canvas Save As or image insertion whose clean tab is closed while its picker is open completes on the tab-less controller (§3 change 11). An inserted image then leaves that controller dirty and tab-less until its tab is reopened.
