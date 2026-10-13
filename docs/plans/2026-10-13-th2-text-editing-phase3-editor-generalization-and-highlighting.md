<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 3: Editor Generalization and TH2 Highlighting

**Date:** 2026-10-13
**Status:** Proposed. Grounded in `feat_38_th2_text_editing` at `10b75419`, with Phases 1 and 2 implemented.
**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§4.6, §4.9, §4.10, §4.12, §4.14, §4.15, §4.17 and §5 Phase 3)
**Previous phase:** [Phase 2: Detached Parse, Identity Matching and One Apply Command](2026-10-13-th2-text-editing-phase2-detached-parse-identity-and-apply.md)
**Issue:** [#38](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose and boundaries

Generalize the existing text editor without changing the project editors' save, reparse or native undo behavior. Add TH2 highlighting, folds, diagnostics and newline handling, and a TH2 text-session controller using Phase 2's validation cache and line tracker. Build and test the surface before exposing text mode in tabs.

All work, including this plan and its later validation, stays on `feat_38_th2_text_editing`, in `/home/rodrigo/devel/mapiah-worktrees/feat_38_th2_text_editing`. Do not create a separate Phase 3 branch or merge this phase into `main`. The feature branch merges only after Phase 6 at the earliest.

Phase 4 connects the controller to mode entry/exit, dirty mirroring, Save/Save As, the shared operation gate, canvas history traversal, tree navigation and regeneration recovery. Phase 5 exposes raw broken-file sessions. Phase 6 completes help and localization. Phase 7 investigates Flutter's initial native undo snapshot delay; do not replace native history in this phase.

## 2. Current code and dependencies

- `lib/src/widgets/th_text_editor_widget.dart` takes `THTextEditorController` directly. Its wrapper `Focus` uses `textEditorFocusNode`; the main `TextField` has no supplied focus node or undo controller. Its fixed key is `THTextEditorWidget|TextField`. The outer shortcuts cover the toolbar, find/replace fields and main editor.
- The widget detects a single inserted LF in its listener and adds indentation. That heuristic cannot distinguish Enter from a one-character paste. Both toolbar buttons currently follow `isDirty`.
- `lib/src/controllers/th_text_editor_controller.dart` owns project identity, saving and debounced project reparsing, plus reusable find/replace state. Keep project ownership and reparsing there. Its public diagnostics currently contain `THProjectParseError`, with one-based `lineNumber` and `filePath`.
- `th_text_editor_syntax_highlighter.dart` scans each line independently. Despite its token documentation mentioning line-relative offsets, emitted offsets are absolute offsets in the complete text; preserve that behavior. `th_text_editor_fold_aux.dart` scans a stack of project block openers.
- `THTextEditorDiagnosticMarkerWidget` accepts one project error. The editor keeps only one diagnostic per line; it must retain every message after generalization.
- Phase 2 provides `TH2TextApplySession`, `TH2TextValidationCache`, `TH2TextDiagnostic`, `TH2TextValidator`, `TH2TextLineTracker` and `TH2FileEditController.serializeForTextMode()`/`applyTextContent()`. Reuse these; do not introduce another parser, diff or cache.
- `TH2TextDiagnostic.line` is nullable and zero-based. Project errors use one-based `lineNumber`. Make conversion explicit at the adapter boundary.
- At this branch revision, `saveTH2File()` still returns `void`; the owner has no text-mode `canSave`, Discard operation or gated canvas history request. Those APIs are Phase 4 work, so Phase 3 cannot safely wire a TH2 toolbar Save directly to the existing method: it would write the old model without applying the buffer.

## 3. Shared editor contracts

### 3.1 Buffer and language

Add `THTextEditorBuffer` as an abstract interface, with `THTextEditorLanguage { therion, th2 }`. Use the existing member signatures where possible:

| Concern | Members |
| --- | --- |
| Content | `content`, `setContent(String, {int? cursorOffset})`, `isDirty`, `lineEnding`, `language` |
| Cursor/navigation | `cursorLine`, `setCursorPosition`, `pendingScrollToLine`, `clearPendingScrollToLine`, `pendingSelectionRange`, `pendingSelectionRequestsFocus`, `clearPendingSelectionRange` |
| Focus | `textEditorFocusNode` for the wrapper; `textFieldFocusNode` for typing |
| Feedback/actions | `diagnostics`, `canSave`, `isReadOnly`, `revertTooltip`, `Future<void> save()`, `Future<void> revert()` |
| History | `baselineRevision`, `hasTextEdits`, `Future<void> requestCanvasHistory({required bool redo})` |
| Find/replace | Existing query, replacement, case, matches, active index, visibility and mutation/navigation members listed in parent §2.1 |

`THTextEditorController` implements the interface. Its language is `therion`, line ending is LF, `canSave == isDirty`, `isReadOnly == false`, `revertTooltip == null`, `baselineRevision == 0`, and `hasTextEdits == true`. Its unused canvas history request does nothing. Preserve its typed `Future<THTextFileSaveResult> save()` override and its existing asynchronous Revert behavior. Ignore the new optional cursor offset there.

Add optional `leadingToolbarActions` to `THTextEditorWidget`, before the ordinary toolbar actions. Phase 4 supplies the Canvas button. Save follows `canSave`; Revert preserves the project behavior and uses the TH2 discard tooltip for TH2. Await Revert through an error-handling handler.

### 3.2 Shared find logic

Move reusable find observables, computed matches and actions into `THTextEditorFindMixin`, retaining plain substring matching, case handling, wraparound and active-match clamping. Use it in both MobX stores; leave project reparse/save responsibilities in the project controller.

Route Replace and Replace All through the buffer's `setContent`, so one replacement updates dirty state, tracking and validation once. Pass the end of the replaced range in the new text: the single replacement's end, or the last replacement's end for Replace All (§4.14). Replacement actions check `isReadOnly`, including direct controller calls. Find query edits and navigation remain allowed while the main buffer is locked.

Regenerate MobX files in the worktree after changing annotated stores. Verify the mixin's observables and computed values are tracked in an `Observer`; do not assume extraction preserves generated instrumentation automatically.

### 3.3 Diagnostics

Add immutable `THTextEditorDiagnostic` with a nullable zero-based line, message and severity (`error`, `warning`, `information`). To keep existing controller tests and consumers unchanged, retain optional `filePath` provenance and a one-based `lineNumber` compatibility getter on the adapted diagnostic. Project error types and `THProjectController.allDiagnostics` stay unchanged.

Map project diagnostics in `THTextEditorController`; map Phase 2 diagnostics in the TH2 controller. Use `TH2FileProblemTextAux` for parser problems and localized messages for the other diagnostic kinds, including normalization destinations and added endings. Add the EN/PT strings needed by this phase when implementing it and run `flutter gen-l10n`; Phase 6 completes documentation and the remaining strings. Do not add temporary hardcoded user text.

Group diagnostics by line. The marker receives that line's list, chooses error before warning before information, and lists all messages in severity order with stable ordering within each severity. Add a distinct information color. Line-less errors must remain visible as editor-level feedback; do not invent a line number or silently drop them. All information markers are nonblocking.

## 4. TH2 lexical behavior

Keep the default `tokenizeTherionText(text, language: therion)` and default `buildFoldRegions(content, language: therion)` compatible with current callers. Choose TH2 block openers for auto-indent through the same language selection.

For TH2:

1. Recognize `encoding`, `scrap`, `endscrap`, `point`, `line`, `endline`, `area`, `endarea`, `comment` and `endcomment` as keywords. Preserve strings, signed/exponent numbers, inline comments, punctuation and dash options.
2. At a line's start, classify `##XTHERION##` and `##MAPIAH##` settings as `setting`, before ordinary hash-comment handling. Add setting colors for light and dark themes.
3. Carry block context across lines. Inside a `line` block, the leading option words from parent §4.10 are options, including `l-size`; do not classify coordinates, quoted text or the same word elsewhere by that rule.
4. Between `comment` and `endcomment`, treat body text as comment, including apparent commands and settings. The fold scanner must ignore apparent block openers and closers in that body. Recognize the actual closing command without ending the block on a word inside a string or an inline comment.
5. Fold balanced `scrap`, `line`, `area` and `comment` blocks with zero-based inclusive ranges. Preserve the existing tolerant handling of incomplete input; an unmatched opener produces no complete fold. Never require a successful parse to highlight or fold typed text.
6. Ignore the trailing CR of a CRLF line for lexical decisions, without rewriting the source or changing absolute token offsets. Keep line numbers and offsets correct for mixed endings and an unterminated last line.

Use bounded scans based on input length; no general line diff or lossy large-file fallback. Keep lexical state local to one scan, so tokenizing another buffer cannot inherit it.

## 5. TH2 text-session controller

Add MobX `TH2TextEditController`, owned by one `TH2FileEditController`, implementing both `THTextEditorBuffer` and Phase 2's `TH2TextApplySession`.

### 5.1 State and lifecycle

Store the open session's current and initial text, initial writer map, cursor/column, pending scroll/selection, diagnostics, validation cache and line tracker. The file's `lineEnding` is the Enter default. Keep session identity (`sessionRevision`) distinct from buffer edits; `baselineRevision` changes on every installed baseline and drives native history reset.

- Install a prepared baseline atomically: initialize text, map, tracker, diagnostics, find matches and cursor before publishing its new session/baseline revision. Session preparation must not partially overwrite the live session. Phase 4 owns the operation and its recovery policy.
- `isDirty` is true only while a session is open and `content != initialContent`. `hasTextEdits` becomes true on the first actual text mutation and stays true even when undo restores the initial text. Selection changes do not set it.
- `setContent` ignores identical text and refuses mutations while closed, disposed or locked. Otherwise record the old/new text with the supplied cursor offset, set `hasTextEdits`, update find state, invalidate displayed stale feedback and schedule validation. It changes no live model or canvas history.
- `endSession()` cancels the idle timer, advances session identity, clears content/baseline/map/diagnostics/cache/tracker and edit flags, and clears pending navigation and session find state. Keep only the last scroll position for re-entry, as parent §4.6 requires. A baseline replacement preserves find-bar UI/query state as parent §4.15 requires; do not confuse replacement with a complete mode exit.
- Lock ownership belongs to the enclosing owner operation. `lockBuffer()` must use that lock; `endSession()` and baseline installation never release it. Internal baseline installation is a distinct authorized path, not a public mutation that bypasses the guard. Expose permanent recovery read-only state separately from a temporary operation lock.
- Dispose timers, cache references and both focus nodes; late completions cannot install diagnostics or revive a closed session. The owner wires tab close/disposal in Phase 4.

### 5.2 Idle validation

Debounce current-buffer validation with `mpTH2TextValidationIdleMilliseconds`, regardless of cursor movement. Use the session's existing `TH2TextValidationCache.validate`, with the owner's filename, file MPID and default ending. Keep its exact-content caching and in-flight sharing with `applyTextContent`.

Capture a session revision and an edit generation when starting idle work. Publish only if the owner/controller is still live, the same session is open, the generation is current and the result describes the exact current content. Generation checks prevent an older result from being installed after editing away from and back to the same string. Cache completion alone is not authority to publish UI diagnostics.

Phase 2 already turns lone CR, encoding failures, parse problems and thrown parses into results. Consume those results; do not reimplement validation. Information records describe the current raw source before apply. An unexpected asynchronous failure is logged and surfaced, with no unhandled future error or silent timer failure.

### 5.3 Phase 4 operation boundary

Provide narrow owner-operation hooks for `canSave`, read-only/lock state, Save, Discard and canvas history traversal, supplied through typed constructor dependencies until the real owner APIs exist. Keep hook wiring in one place so Phase 4 replaces it with the parent's owner delegation rather than introducing another operation coordinator.

An unconnected TH2 editor is available only to Phase 3 tests; it is not installed into production tabs. Its Save stays disabled, and unavailable operations are explicit refusals, never successful no-op saves. In tests, inject recording/throwing operation hooks to verify routing and error handling without writing disk or traversing the live stack. The eventual Save checks owner `canSave`, awaits `saveTH2File()` and logs failure; Discard awaits the gated owner operation; canvas history requests await the gated owner traversal. No direct call to Phase 2's apply belongs in the widget.

## 6. Widget input, focus and history

### 6.1 Focus and selection

Pass `textFieldFocusNode` to the main `TextField`; retain the wrapper node for Tab/Esc propagation. Update existing project-text tab focus sites in `MPGeneralController` and `TH2FileTabsPage`, and pending selection application, to request the actual field node. TH2 tab activation is Phase 4 work.

Add `pendingSelectionRequestsFocus`, defaulting to true and cleared with the pending range. A false value moves selection without taking focus, for later tree context-menu navigation. Pass valid `TextEditingValue.selection.extentOffset` to `setContent`; pass null for an invalid selection.

### 6.2 Enter and line endings

For TH2 only, bind Enter, Shift+Enter, numpad Enter and numpad Shift+Enter, including repeats, in the inner shortcuts around the main editor. Replace the selected range with the file's default LF or CRLF and computed auto-indent in one value update. Compute indentation from the preceding text with a trailing CR removed. Place the caret after the full ending and indentation; do not expose a caret position between CR and LF.

Respect active IME composition: Enter used to confirm composition must not also insert a newline. Verify this with text-input composition events during implementation. Preserve native CRLF navigation behavior where available; add a narrowly scoped correction only if tests show the caret can land inside an ending, without normalizing the buffer.

Disable the listener's LF-insertion heuristic for TH2. Pasted LF, pasted CRLF and programmatic replacements retain their own endings and get no inferred auto-indent. Keep the project's current LF/auto-indent behavior. Find/replace fields stay outside these shortcuts, so their Enter behavior is unchanged.

### 6.3 Native undo routing

Pass a widget-owned `UndoHistoryController` to the main field. Wrap only that field in a `KeyedSubtree` keyed by `baselineRevision`, retaining the field's fixed key. Reset the associated native undo state when the baseline changes; do not reuse stale history entries. Keep the rest of the widget mounted so find text, replace expansion, focus and scrolling survive. Install the baseline before user input resumes and never record it as an edit.

Add TH2 undo/redo intents and actions to the same inner shortcuts as Enter, covering the main field and gutter but excluding find/replace fields. Handle Ctrl and Cmd with Shift+Z redo, exactly once:

- When read-only, consume the key and do nothing.
- With `hasTextEdits`, invoke the main field's native undo/redo controller.
- Before the first text edit, request canvas history through the buffer hook, which Phase 4 will gate and recheck. Do not traverse the stack in the widget.

Actions remain enabled and consume the key even for an empty stack, a broken raw baseline or recovery; otherwise default Flutter shortcuts could fall through to native text undo. After a text edit, exhausting text history never reaches canvas history. Project editors retain their existing shortcut behavior; find and replace fields always retain their own native histories.

Every mutating route, including Tab indentation, cut/paste, Replace, Replace All, Enter and programmatic controller edits, observes read-only state. Selection, scrolling, finding and Copy remain usable. Handle exceptions from asynchronous canvas history requests without an unhandled future error.

## 7. Implementation sequence

1. Introduce language and diagnostic types and buffer contract. Adapt the project controller and marker/widget consumers; preserve diagnostic provenance and existing project tests.
2. Extract find logic, add the main field focus node and conditional pending-selection focus, and change project tab focus requests. Regenerate MobX files and verify project editor regressions before adding TH2 behavior.
3. Implement language-aware tokenization, folds and indent opener selection; add `t3972` and the lexical/fold portions of `t3973` alongside them.
4. Add the TH2 session controller over the existing apply-session/cache/tracker APIs, atomic baseline installation, lifecycle guards and explicit operation hooks. Add idle/lifecycle tests in `t3974`.
5. Add TH2 Enter handling, grouped information diagnostics, read-only checks and toolbar extensions. Complete `t3973`.
6. Add main-editor-only history routing and baseline reset. Add `t3975`, using established native history for initial-baseline assertions; leave immediate first-edit correction to Phase 7.
7. Add required EN/PT strings, run localization and MobX generation, then analyze and run the full tests in the feature worktree. Do not run `dart format`.

## 8. Verification

### Existing regressions

Keep the existing editor tests in `t3900`–`t3937` and `t3956` passing unchanged, including project parsing, compiler diagnostics, find/replace, reveal-range navigation, save flushing, Save As and redo shortcuts. Preserve the observable project diagnostic message, file path and one-based line number even after adapting its type. Re-run Phases 1/2 tests to verify cache sharing and the apply-session interface.

### New tests

| File | Coverage |
| --- | --- |
| `t3972_th2_text_editor_syntax_highlighter_test.dart` | Every TH2 keyword; dash and line-leading options; both setting prefixes; multiline comments hiding apparent commands/settings; numbers/strings; LF/CRLF/mixed offsets; malformed/unfinished blocks; default Therion output unchanged |
| `t3973_th2_text_editor_widget_test.dart` | TH2 folds and indent openers; project openers unchanged; all Enter variants/repeats and selection replacement; caret around CRLF; pasted single LF/CRLF preserved; IME confirmation; find/replace Enter scope; read-only mutation refusal; leading toolbar actions; Save/Revert delegation and failures; severity/color/tooltip grouping and line-less feedback; actual typing focus and focus-free pending selection |
| `t3974_th2_text_editor_validation_test.dart` | Idle debounce while cursor stays still; newest-content diagnostics; A→B→A races; shared in-flight/cached validation; stale cache revalidated by apply; thrown duplicate-ID parse cached and fixed; normalization information; lock ownership across baseline installation; closing/replacing/disposing sessions during pending work; no model or canvas-stack mutation |
| `t3975_th2_text_editor_undo_test.dart` | Exact text/endings/selection through typing, paste, Enter, indentation, Replace/Replace All, invalid syntax and committed IME; sticky `hasTextEdits`; selection-only changes add no edit; baseline revision clears native history while preserving find/replace UI; Ctrl/Cmd route once; empty/locked/refused canvas request cannot fall through; find/replace histories before/after first edit; project undo unchanged |

In `t3975`, allow Flutter's existing initial recording window to elapse before the first edit when checking baseline restoration. Record that immediate first edits remain the parent's Phase 7 TODO, rather than silently accepting them as verified. Use fake time and completers for idle and asynchronous races; avoid wall-clock sleeps. Full canvas traversal/rollback, Save operation locks and recovery integration belong to `t3987`, `t3988` and `t3990` in Phase 4.

Implementation commands, from the feature worktree:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

User preview after implementation: from the main checkout, `scripts/task_run.sh feat_38_th2_text_editing test test/t3973_th2_text_editor_widget_test.dart`. This phase intentionally supplies no production Text button to preview; Phase 4 connects it.

## 9. Acceptance and risks

- Existing project editor behavior and regressions pass, with typing focus corrected.
- TH2 highlighting/folding works on invalid intermediate text, with exact source offsets and endings preserved.
- TH2 edits update session dirty state, tracking, find state and current diagnostics without changing the model or canvas history.
- Enter is distinguished from paste; diagnostic messages are never overwritten by another marker on the same line.
- Native text undo and canvas requests are mutually exclusive; locked/no-op actions consume keys; find/replace fields keep their own undo.
- Session replacement resets native history, retains find-bar state and never releases the operation-owned lock. Closed/disposed sessions cannot publish late validation.
- Analyzer and full test suite pass after implementation. No TH2 Save is exposed before Phase 4's apply/write pipeline exists.

Primary implementation risks are MobX instrumentation after extracting find state, rebinding native undo state when only the main field is rebuilt, IME-aware Enter dispatch, and incompatible diagnostic consumers. Test those seams directly. Session hooks are an explicit temporary dependency boundary, not a second history/gate implementation. The native initial-snapshot limitation remains documented for Phase 7.
