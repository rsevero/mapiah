<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 3: Editor Generalization and TH2 Highlighting

**Date:** 2026-10-13
**Status:** Proposed. Grounded in `feat_38_th2_text_editing` at `10b75419`, with Phases 1 and 2 implemented. Revised on 2026-10-13 after validating against `9cc6e491`: folds stay computed regions with no UI, find state moves to a generated store instead of a mixin, the gutter and line-less diagnostics follow severity, a refused edit restores the field, the session's owner is one permanent interface, and the TH2 lexer follows multi-line values. Further validation against `4afff75d` distinguishes value state from logical-line continuation, adds cached tokens to the buffer contract, and routes Flutter's standard undo/redo intents through the TH2 history guard.
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
- `th_text_editor_syntax_highlighter.dart` scans each line independently. Despite its token documentation mentioning line-relative offsets, emitted offsets are absolute offsets in the complete text; preserve that behavior. The widget re-tokenizes the whole content on every `Observer` rebuild, including cursor moves and find navigation. `th_text_editor_fold_aux.dart` scans a stack of project block openers.
- **Folding has no UI.** `THTextEditorController` computes `foldRegions` and keeps `collapsedFoldStarts`/`toggleFold`, but `THTextEditorWidget` reads none of them; only `t3901` and `t3936` use them. This phase computes TH2 fold regions the same way and adds no fold UI; a fold UI is a later TODO outside this plan.
- `THTextEditorDiagnosticMarkerWidget` accepts one project error. The editor keeps only one diagnostic per line; it must retain every message after generalization. The gutter (`THTextEditorLineNumberGutterWidget`) draws every diagnostic line with `colorScheme.error`, from `thTextEditorDiagnosticLines`, which keeps no severity.
- Project errors with no line use `lineNumber: 0` (8 sites in `th_project_controller.dart`). The widget places them at line −1, so they are invisible today.
- `mobx_codegen` (2.7.0 in `pubspec.lock`) generates code only for classes that mix in `Store`, and visits only that class's own members (`mobx_codegen_base.dart:30-38`, `:84-85`). Annotations in a plain `mixin` get no generated code, so they would not be tracked.
- The TH2 parser joins an open double-quoted value across lines. An open bracketed value requires a trailing `\` to continue; without it, `updateContinuationDelimiter` throws. A trailing `\` outside a value also joins the next physical line into the same parseable line, without turning its contents into one value token (parent §2.3). The writer itself writes `\` continuations when it wraps a long generated line (`th2_file_writer.dart:666`).
- Phase 2 provides `TH2TextApplySession`, `TH2TextValidationCache`, `TH2TextDiagnostic`, `TH2TextValidator`, `TH2TextLineTracker` and `TH2FileEditController.serializeForTextMode()`/`applyTextContent()`. Reuse these; do not introduce another parser, diff or cache.
- `TH2TextDiagnostic.line` is nullable and zero-based. Project errors use one-based `lineNumber`. Make conversion explicit at the adapter boundary.
- At this branch revision, `saveTH2File()` still returns `void`; the owner has no text-mode `canSave`, Discard operation or gated canvas history request. Those APIs are Phase 4 work, so Phase 3 cannot safely wire a TH2 toolbar Save directly to the existing method: it would write the old model without applying the buffer.

## 3. Shared editor contracts

### 3.1 Buffer and language

Add `THTextEditorBuffer` as an abstract interface, with `THTextEditorLanguage { therion, th2 }`. Use the existing member signatures where possible:

| Concern | Members |
| --- | --- |
| Content | `content`, `bool setContent(String, {int? cursorOffset})` (returns whether the change was accepted), `isDirty`, `lineEnding`, `language` |
| Highlighting | `List<THTextEditorToken> get tokens`, implemented as a `@computed` of `content` in both controllers (§4) |
| Cursor/navigation | `cursorLine`, `setCursorPosition`, `pendingScrollToLine`, `clearPendingScrollToLine`, `pendingSelectionRange`, `pendingSelectionRequestsFocus`, `clearPendingSelectionRange` |
| Focus | `textEditorFocusNode` for the wrapper; `textFieldFocusNode` for typing |
| Feedback/actions | `diagnostics`, `canSave`, `isReadOnly`, `revertTooltip`, `Future<void> save()`, `Future<void> revert()` |
| History | `baselineRevision`, `hasTextEdits`, `Future<void> requestCanvasHistory({required bool redo})` |
| Find/replace | `THTextEditorFindController get find` (§3.2), holding the existing query, replacement, case, matches, active index, visibility and mutation/navigation members listed in parent §2.1 |

`THTextEditorController` implements the interface. Its language is `therion`, line ending is LF, `canSave == isDirty`, `isReadOnly == false`, `revertTooltip == null`, `baselineRevision == 0`, and `hasTextEdits == true`. Its unused canvas history request does nothing. Preserve its typed `Future<THTextFileSaveResult> save()` override and its existing asynchronous Revert behavior. Ignore the new optional cursor offset there. Its `setContent` returns `false` where it already rejects a change (`registerTextContentChange` returning `-1`), and `true` otherwise. Its fold members (`foldRegions`, `collapsedFoldStarts`, `toggleFold`) stay on the controller and out of the interface, since no widget reads them. It gains its own `textFieldFocusNode`, disposed with `textEditorFocusNode`.

Add optional `leadingToolbarActions` to `THTextEditorWidget`, before the ordinary toolbar actions. Phase 4 supplies the Canvas button. Save follows `canSave`; Revert preserves the project behavior and uses the TH2 discard tooltip for TH2. Await Revert through an error-handling handler.

### 3.2 Shared find logic

Move reusable find observables, computed matches and actions into a separate generated MobX store, `THTextEditorFindController` (`abstract class THTextEditorFindControllerBase with Store`, like the other stores), retaining plain substring matching, case handling, wraparound and active-match clamping. A plain `mixin` can't hold them, since `mobx_codegen` wouldn't instrument its annotations (§2). Each buffer owns one and exposes it as `find`. The store reads the buffer's `content` through a getter, so its `@computed findMatches` tracks the buffer's observable content. Leave project reparse/save responsibilities in the project controller. The project controller keeps forwarding members for the find API its existing callers and tests use, so they don't change.

Route Replace and Replace All through the buffer's `setContent`, so one replacement updates dirty state, tracking and validation once. Pass the end of the replaced range in the new text: the single replacement's end, or the last replacement's end for Replace All (§4.14). Replacement actions check the buffer's `isReadOnly`, including direct controller calls. Find query edits and navigation remain allowed while the main buffer is locked.

Regenerate MobX files in the worktree after changing annotated stores. Verify in an `Observer` that the find store's observables and `findMatches` follow both query changes and buffer content changes.

### 3.3 Diagnostics

Add immutable `THTextEditorDiagnostic` with a nullable zero-based line, message and severity (`error`, `warning`, `information`). To keep existing controller tests and consumers unchanged, retain optional `filePath` provenance and a one-based `lineNumber` compatibility getter on the adapted diagnostic. A project error with `lineNumber <= 0` maps to a `null` line, and its `lineNumber` getter still returns the original value. Project error types and `THProjectController.allDiagnostics` stay unchanged.

Map project diagnostics in `THTextEditorController`; map Phase 2 diagnostics in the TH2 controller. Use `TH2FileProblemTextAux` for parser problems and localized messages for the other diagnostic kinds, including normalization destinations and added endings. Add the EN/PT strings needed by this phase when implementing it and run `flutter gen-l10n`; Phase 6 completes documentation and the remaining strings. Do not add temporary hardcoded user text.

Group diagnostics by line. The marker receives that line's list, chooses error before warning before information, and lists all messages in severity order with stable ordering within each severity. Add a distinct information color. The gutter dot uses the same most-severe color: `thTextEditorDiagnosticLines` becomes a map from line to that line's most severe severity, so an information-only line never gets an error dot. Line-less diagnostics are shown in a row under the toolbar, one message per entry, colored by severity, in both editors; do not invent a line number or silently drop them. For project editors this is an intentional visible change: their line-less errors were invisible before (§2). All information markers are nonblocking.

## 4. TH2 lexical behavior

Keep the default `tokenizeTherionText(text, language: therion)` and default `buildFoldRegions(content, language: therion)` compatible with current callers. Choose TH2 block openers for auto-indent through the same language selection.

For TH2:

1. Recognize `encoding`, `scrap`, `endscrap`, `point`, `line`, `endline`, `area`, `endarea`, `comment` and `endcomment` as keywords. Preserve strings, signed/exponent numbers, inline comments, punctuation and dash options.
2. At a line's start at file level, classify `##XTHERION##` and `##MAPIAH##` settings as `setting`, before ordinary hash-comment handling. Inside a `scrap`, `line` or `area` block the parser reads such a line as a comment (parent §2.3), so color it as `comment` there. Add setting colors for light and dark themes.
3. Carry block context across lines. Inside a `line` block, the leading option words from parent §4.10 are options, including `l-size`; do not classify coordinates, quoted text or the same word elsewhere by that rule.
4. Between `comment` and `endcomment`, treat body text as comment, including apparent commands and settings. The fold scanner must ignore apparent block openers and closers in that body. Recognize the actual closing command without ending the block on a word inside a string or an inline comment.
5. Compute fold regions for balanced `scrap`, `line`, `area` and `comment` blocks with zero-based inclusive ranges, as `buildFoldRegions(content, language: th2)`. They are computed regions only: no editor renders folds yet (§2). Preserve the existing tolerant handling of incomplete input; an unmatched opener produces no complete fold. Never require a successful parse to highlight or compute folds for typed text.
6. Ignore the trailing CR of a CRLF line for lexical decisions, without rewriting the source or changing absolute token offsets. Keep line numbers and offsets correct for mixed endings and an unterminated last line.
7. Track value state separately from logical-line continuation. An open double-quoted value carries across lines; doubled double quotes escape a quote, as in `updateContinuationDelimiter`. The parser requires a trailing `\` to continue an open bracketed value. Highlight unfinished bracketed input tolerantly across lines even when that backslash is missing; this is editor recovery, not parser acceptance. Inside an open quoted or bracketed value, preserve its token type and treat `#` as value content. After its closing delimiter, resume normal token classification. A trailing `\` outside a value continues the logical line without forcing one token type: numbers, dash options, strings and inline `#` comments retain their normal classifications. For example, a wrapped point command can continue with `-text "label" # note`, retaining option, string and comment tokens. No continuation line starts a new command, block opener or closer for folds, or `line`-block option line. An unterminated value at the end of the input ends there, with no lexer error; validation still reports parser failures.

Use bounded scans based on input length; no general line diff or lossy large-file fallback. Keep lexical state local to one scan, so tokenizing another buffer cannot inherit it. Expose the tokens of each buffer as a `@computed` of its `content` (the project controller included), so rebuilds that don't change the text, such as cursor moves and find navigation, don't tokenize again; the widget reads `buffer.tokens` through the shared contract instead of calling the tokenizer in `build`.

## 5. TH2 text-session controller

Add MobX `TH2TextEditController`, owned by one `TH2FileEditController`, implementing both `THTextEditorBuffer` and Phase 2's `TH2TextApplySession`.

### 5.1 State and lifecycle

Store the open session's current and initial text, initial writer map, cursor/column, pending scroll/selection, diagnostics, validation cache and line tracker. The file's `lineEnding` is the Enter default. Keep session identity (`sessionRevision`) distinct from buffer edits. Installing a baseline advances both `sessionRevision` and `baselineRevision` and resets the edit generation (§5.2), since `applyTextContent`'s staleness check and idle publishing both compare `sessionRevision`; `endSession()` advances only `sessionRevision`. `baselineRevision` drives native history reset.

- Install a prepared baseline atomically: initialize text, map, tracker, diagnostics, find matches and cursor before publishing its new session/baseline revision. Session preparation must not partially overwrite the live session. Phase 4 owns the operation and its recovery policy.
- `isDirty` is true only while a session is open and `content != initialContent`. `hasTextEdits` becomes true on the first actual text mutation and stays true even when undo restores the initial text. Selection changes do not set it.
- `setContent` ignores identical text and refuses mutations while closed, disposed or locked, returning `false`. Otherwise it records the old/new text with the supplied cursor offset, sets `hasTextEdits`, updates find state, invalidates displayed stale feedback, schedules validation and returns `true`. It changes no live model or canvas history.
- `endSession()` cancels the idle timer, advances session identity, clears content/baseline/map/diagnostics/cache/tracker and edit flags, and clears pending navigation and session find state. Keep only the last scroll position for re-entry, as parent §4.6 requires. A baseline replacement preserves find-bar UI/query state as parent §4.15 requires; do not confuse replacement with a complete mode exit.
- Lock ownership belongs to the enclosing owner operation, through the owner's lock (§5.3). `lockBuffer()` acquires it there; only the owner operation releases it, and `endSession()` and baseline installation never do. Internal baseline installation is a distinct authorized path, not a public mutation that bypasses the guard. Expose permanent recovery read-only state separately from a temporary operation lock.
- Dispose timers, cache references and both focus nodes; late completions cannot install diagnostics or revive a closed session. The owner wires tab close/disposal in Phase 4.

### 5.2 Idle validation

Debounce current-buffer validation with `mpTH2TextValidationIdleMilliseconds`, a new constant in `mp_constants.dart` set to 500, regardless of cursor movement. Use the session's existing `TH2TextValidationCache.validate`, with the owner's filename, file MPID and default ending. Keep its exact-content caching and in-flight sharing with `applyTextContent`.

Capture a session revision and an edit generation when starting idle work. Publish only if the owner/controller is still live, the same session is open, the generation is current and the result describes the exact current content. Generation checks prevent an older result from being installed after editing away from and back to the same string. Cache completion alone is not authority to publish UI diagnostics.

Phase 2 already turns lone CR, encoding failures, parse problems and thrown parses into results. Consume those results; do not reimplement validation. Information records describe the current raw source before apply. An unexpected asynchronous failure is logged and surfaced, with no unhandled future error or silent timer failure.

### 5.3 Owner interface

`TH2TextEditController` takes its owner through one narrow, permanent interface, `TH2TextEditOwner`, instead of temporary hooks that Phase 4 would replace. Phase 4's `TH2FileEditController` implements it, so no second operation coordinator is introduced. It provides:

- the validation inputs: filename, file MPID, default line ending and `isDisposed`;
- `canSave`;
- the operation-owned buffer lock: `isBufferLocked`, and its acquire and release, which only an owner operation calls in pairs (§5.1);
- `Future<void> save()`, `Future<void> discardTextEdits()` and `Future<void> requestCanvasHistory({required bool redo})`.

The controller's `isReadOnly` is `owner.isBufferLocked` or the recovery read-only state; `lockBuffer()` acquires the owner's lock.

In Phase 3 no production code implements the interface, so no TH2 editor is installed into production tabs. Tests implement a fake owner, recording or throwing, to verify routing, locking and error handling without writing disk or traversing the live stack; a fake with `canSave` false checks that Save stays disabled, and unavailable operations are explicit refusals, never successful no-op saves. The controller's Save checks `owner.canSave`, awaits `owner.save()` and logs failure; Discard awaits the gated owner operation; canvas history requests await the gated owner traversal. No direct call to Phase 2's apply belongs in the widget.

## 6. Widget input, focus and history

### 6.1 Focus and selection

Pass `textFieldFocusNode` to the main `TextField`; retain the wrapper node for Tab/Esc propagation. Update existing project-text tab focus sites in `MPGeneralController` and `TH2FileTabsPage`, and pending selection application, to request the actual field node. TH2 tab activation is Phase 4 work.

Add `pendingSelectionRequestsFocus`, defaulting to true and cleared with the pending range. A false value moves selection without taking focus, for later tree context-menu navigation. Pass valid `TextEditingValue.selection.extentOffset` to `setContent`; pass null for an invalid selection.

**A refused change restores the field.** The lock is taken synchronously at accepted apply, but `TextField.readOnly` only follows it on the next frame, so a key event in between can still change the field. When `setContent` returns `false`, the widget puts the buffer's `content` and the field's previous selection back into its `TextEditingController` under `_isSyncingFromController`, so the restore isn't reported as an edit and doesn't set `hasTextEdits`. Without it, no observable changes and the build-time resync never runs, leaving the field showing text the buffer doesn't have.

### 6.2 Enter and line endings

For TH2 only, bind Enter, Shift+Enter, numpad Enter and numpad Shift+Enter, including repeats, in the inner shortcuts around the main editor. Replace the selected range with the file's default LF or CRLF and computed auto-indent in one value update. Compute indentation from the preceding text with a trailing CR removed. Place the caret after the full ending and indentation; do not expose a caret position between CR and LF.

Respect active IME composition: Enter used to confirm composition must not also insert a newline. Key events can reach `Shortcuts` before the input method sees them, so while the field's `value.composing` is a valid range, the Enter action does not consume the key (`consumesKey` false) and leaves it to the input method. Unlike the undo/redo actions (§6.3), it consumes the key otherwise. Verify this with text-input composition events during implementation. Preserve native CRLF navigation behavior where available; add a narrowly scoped correction only if tests show the caret can land inside an ending, without normalizing the buffer.

Disable the listener's LF-insertion heuristic for TH2. Pasted LF, pasted CRLF and programmatic replacements retain their own endings and get no inferred auto-indent. Keep the project's current LF/auto-indent behavior. Find/replace fields stay outside these shortcuts, so their Enter behavior is unchanged.

### 6.3 Native undo routing

Pass a widget-owned `UndoHistoryController` to the main field. Wrap only that field in a `KeyedSubtree` keyed by `baselineRevision`, retaining the field's fixed key. Reset the associated native undo state when the baseline changes; do not reuse stale history entries. Keep the rest of the widget mounted so find text, replace expansion, focus and scrolling survive. Install the baseline before user input resumes and never record it as an edit.

Add TH2 undo/redo intents and actions to the same inner shortcuts as Enter, covering the main field and gutter but excluding find/replace fields. In that same main-editor scope, override Flutter's standard `UndoTextIntent` and `RedoTextIntent` actions: `UndoHistory` exposes overridable actions for them. Route both the custom shortcut intents and standard intents through one history handler, so direct standard-intent dispatch cannot bypass the TH2 guard. With text history selected, invoke the widget-owned `UndoHistoryController` directly; redispatching a standard intent would recurse through the override. Install these overrides only for TH2. Handle Ctrl and Cmd with Shift+Z redo, exactly once:

- When read-only, consume the key and do nothing.
- With `hasTextEdits`, invoke the main field's native undo/redo controller.
- Before the first text edit, request canvas history through the buffer hook, which Phase 4 will gate and recheck. Do not traverse the stack in the widget.

Actions remain enabled and consume the key even for an empty stack, a broken raw baseline or recovery; otherwise default Flutter shortcuts could fall through to native text undo. After a text edit, exhausting text history never reaches canvas history. Project editors retain their existing shortcut behavior; find and replace fields always retain their own native histories.

Every mutating route, including Tab indentation, cut/paste, Replace, Replace All, Enter and programmatic controller edits, observes read-only state. Selection, scrolling, finding and Copy remain usable. Handle exceptions from asynchronous canvas history requests without an unhandled future error.

## 7. Implementation sequence

1. Introduce language and diagnostic types and buffer contract. Adapt the project controller and marker, gutter and widget consumers, including the line-less diagnostics row; preserve diagnostic provenance and existing project tests.
2. Extract find logic into `THTextEditorFindController`, add the main field focus node and conditional pending-selection focus, and change project tab focus requests. Regenerate MobX files and verify project editor regressions before adding TH2 behavior.
3. Implement language-aware tokenization (with multi-line values), fold regions and indent opener selection, and tokens as a `@computed` of content; add `t3972` alongside them.
4. Add `TH2TextEditOwner`, the TH2 session controller over the existing apply-session/cache/tracker APIs, atomic baseline installation and lifecycle guards, and the `mpTH2TextValidationIdleMilliseconds` constant. Add idle/lifecycle tests in `t3974`.
5. Add TH2 Enter handling, grouped information diagnostics, read-only checks, the field restore after a refused change and toolbar extensions. Add `t3973`.
6. Add main-editor-only history routing for custom and standard Flutter intents, plus baseline reset. Add `t3975`, using established native history for initial-baseline assertions; leave immediate first-edit correction to Phase 7.
7. Add required EN/PT strings, run localization and MobX generation, then analyze and run the full tests in the feature worktree. Do not run `dart format`.

## 8. Verification

### Existing regressions

Keep the existing editor tests in `t3900`–`t3937` and `t3956` passing unchanged, including project parsing, compiler diagnostics, find/replace, reveal-range navigation, save flushing, Save As and redo shortcuts. Preserve the observable project diagnostic message, file path and one-based line number even after adapting its type. Re-run Phases 1/2 tests to verify cache sharing and the apply-session interface.

### New tests

| File | Coverage |
| --- | --- |
| `t3972_th2_text_editor_syntax_highlighter_test.dart` | Every TH2 keyword; dash and line-leading options; both setting prefixes at file level, and as comments inside a scrap, line or area; multiline comments hiding apparent commands/settings; numbers/strings; open double-quoted values with doubled-quote escapes and backslash-continued bracketed values preserving value tokens and literal `#`; unfinished brackets without a backslash highlighted tolerantly despite parser rejection; closing delimiters restoring normal tokens; `\` continuations outside values, including the writer's wrapped long lines, preserving numbers/options/strings/inline comments while suppressing new commands, option lines and folds; LF/CRLF/mixed offsets; malformed/unfinished blocks and values; TH2 fold regions (`scrap`, `line`, `area`, `comment`) and project fold regions unchanged; default Therion output unchanged; tokens of a generated text the size of `t3971`'s within a time bound, and not recomputed by a cursor move |
| `t3973_th2_text_editor_widget_test.dart` | TH2 indent openers; project openers unchanged; all Enter variants/repeats and selection replacement; caret around CRLF; pasted single LF/CRLF preserved; IME confirmation, with Enter not consumed while composing; find/replace Enter scope; read-only mutation refusal; a key event between the lock and the next frame leaves both the buffer and the field unchanged; leading toolbar actions; Save/Revert delegation and failures through a fake owner; severity/color/tooltip grouping, an information-only line's gutter dot in the information color, and line-less feedback in both editors; find matches following buffer edits in an `Observer`; actual typing focus and focus-free pending selection |
| `t3974_th2_text_editor_validation_test.dart` | Idle debounce while cursor stays still; newest-content diagnostics; A→B→A races; shared in-flight/cached validation; stale cache revalidated by apply; thrown duplicate-ID parse cached and fixed; normalization information; lock ownership across baseline installation, with the lock held and released only by the fake owner; baseline installation advancing `sessionRevision` and `baselineRevision`; closing/replacing/disposing sessions during pending work; no model or canvas-stack mutation |
| `t3975_th2_text_editor_undo_test.dart` | Exact text/endings/selection through typing, paste, Enter, indentation, Replace/Replace All, invalid syntax and committed IME; sticky `hasTextEdits`; selection-only changes add no edit; baseline revision clears native history while preserving find/replace UI; Ctrl/Cmd and directly dispatched standard `UndoTextIntent`/`RedoTextIntent` each route once before and after the first edit; standard intents dispatched from the main field's context reach the override, and locked standard intents do nothing; empty/locked/refused canvas request cannot fall through; find/replace histories before/after first edit; project undo unchanged |

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
- TH2 highlighting and fold regions work on invalid intermediate text and multi-line values, with exact source offsets and endings preserved. No fold UI is added.
- TH2 edits update session dirty state, tracking, find state and current diagnostics without changing the model or canvas history.
- Enter is distinguished from paste; diagnostic messages are never overwritten by another marker on the same line; the gutter follows severity and line-less diagnostics are visible.
- Native text undo and canvas requests are mutually exclusive; locked/no-op actions consume keys; find/replace fields keep their own undo.
- Session replacement resets native history, retains find-bar state and never releases the operation-owned lock. Closed/disposed sessions cannot publish late validation.
- Analyzer and full test suite pass after implementation. No TH2 Save is exposed before Phase 4's apply/write pipeline exists.

Primary implementation risks are the find store's tracking of the buffer's content, rebinding native undo state when only the main field is rebuilt, IME-aware Enter dispatch, keeping the field and buffer equal when a change is refused, and incompatible diagnostic consumers. Test those seams directly. `TH2TextEditOwner` is a permanent narrow boundary that Phase 4's owner implements, not a second history/gate implementation. The native initial-snapshot limitation remains documented for Phase 7.
