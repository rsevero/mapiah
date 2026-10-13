<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 2: Detached Parse, Identity Matching and One Apply Command

**Date:** 2026-10-13
**Status:** Proposed. Checked against `feat_38_th2_text_editing` at `b74e1d29` (Phase 1 implemented, rebased on `main` up to `8e3e07c0`). Validated on 2026-10-13 against `8c3e2571`: the remapper rewrites the file's top-level children, parser errors become diagnostics once, byte-based encoding detection no longer throws on a non-ASCII byte, the text never sets the file's line ending, the refresh clears stale selection geometry and invalid selected line points, and test hooks and guards were made reachable.
**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§4.2, §4.5, §4.6, §4.7, §4.12, §4.14 and §5 Phase 2)
**Previous phase:** [Phase 1: Line Maps, Settings Section and Locator](2026-10-12-th2-text-editing-phase1-line-maps-and-locator.md)
**Issue:** [#38: Simplify object options entry by allowing user to type without clicking each option](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose

Build the model side of text mode, with no UI:

- a **detached parse** of an editor buffer (a string) into a scratch controller that is never registered, with every parse failure, including a parse that throws, turned into a rejected validation result;
- **validation** of a buffer: lone `\r`, encodability, parse problems and errors, and, for valid text, the normalized text *N(T)*, both line maps of the detached model and the parser's **normalization records**;
- the **information markers** and the **raw → normalized cursor mapping** derived from them (parent §4.12);
- **content-keyed identity matching** of the live and the detached model, and the MPID remap it drives (parent §4.7);
- `TH2File.replaceContentsFrom`, `MPReplaceTH2FileContentsCommand` and `syncControllersWithModel`, so one apply is **one canvas undo step**, and apply, undo and redo all refresh the sub-controllers the same way;
- `TH2FileEditController.applyTextContent`, which ties them together;
- the pure `TH2TextLineTracker` (parent §4.14), which `t3986` tests in this phase.

Nothing here is visible in the UI. Outside text mode, a valid load runs its canvas setup through `syncControllersWithModel(initialSetup: true)` instead of `_finalFilePreparations`' inline code, with the same result (§4.11). The only user-visible change is a load fix: a file with no `encoding` line and a non-ASCII character among its first `mpthMaxEncodingLength` characters now loads instead of failing (§4.1).

**Branch.** Implemented on `feat_38_th2_text_editing`, in its worktree (`/home/rodrigo/devel/mapiah-worktrees/feat_38_th2_text_editing`), like every phase (parent §5). This plan, its validations and its implementation are committed there. The branch is merged into `main` only after Phase 6 at least.

## 2. Current codebase constraints

Verified at `b74e1d29`.

### 2.1 Parser (`lib/src/mp_file_read_write/th2_file_parser.dart`, 3556 lines)

- `parse(filename, {fileBytes, alternateStartParser, trace, forceNewController = true})` (`:3036-3121`) always gets its controller from `mpLocator.mpGeneralController.getTH2FileEditController(filename:, forceNewController:)` (`:3053-3057`), which registers a new controller when none exists (`mp_general_controller.dart:472-499`). It returns `(TH2File, bool, List<String>)`; `problems` (`:70`) and Phase 1's `lineStarts`, `elementStartLines` and `parsedLineCount` are public fields.
- Reading is inside one `try` (`:3070-3096`): it reads the bytes, sets `encoding` with `_encodingNameFromFile` (`:2963-3014`), decodes with `_decodeFile` (`:2945`), which also strips NUL characters, counts lines and runs `_splitContents`. Any exception there becomes an `_addError`, which, like every `_addError` (`:2728-2743`), also records a `parseError` problem on `_currentLineNumber`, here 0. `_scanStructureProblems`, `_injectContents` (`:186-222`) and the three clean-up passes (`:3098-3101`) have no `try`.
- `_encodingNameFromFile` skips leading blank bytes, reads up to `mpthMaxEncodingLength` characters and calls `_isEncodingDelimiter` (`:3017-3032`), which **sets `_parsedTH2File.lineEnding`** on the first `\r\n` or `\n`. With no line break in that window (`mpthMaxEncodingLength` is 20), `lineEnding` keeps the `TH2File`'s default, the platform's. Each byte is turned into a character with `utf8.decode([byte])`, which throws `FormatException` on any byte ≥ 0x80, so a file with no `encoding` line and a non-ASCII character in that window fails to load today ("Failed to read file").
- **Throws.** A duplicate thID throws `THCustomException` from `TH2File.registerElementWithTHID`/`registerMPIDWithTHID` (`th2_file.dart:271-299`) during injection; `_linesCleanUp` throws on an inconsistent area border (`:3241-3243`). `t3944` relies on a load turning the throw into `loadError`.
- **Clean-up passes.** `_cleanOriginalLinesInFile` (`:3141-3150`) substitutes every MPID flagged by `_addToMPIDsToCleanOriginalLine` (`:2020`; called at `:1039`, `:1119`, `:1164`, `:1567`, `:1586`, `:1692`, `:2041`, `:2083`) with a copy whose stored text is empty. `_linesCleanUp` (`:3177-3256`) removes a duplicate line point with no options (or the previous one, when only it has none) and a line left with fewer than two segments, with its area border reference. `_resolveBorderReference` (`:3297-3319`) repairs an invalid-id reference and clears its stored text only in its third branch (`:3313-3318`); the `name@survey` branch keeps the stored text. `_areasCleanUp` (`:3326-3373`) reports unresolved references (problems) and removes an area left with no border. `TH2File.removeElement` removes descendants.
- Every `executeAddElement` goes through Phase 1's `_addElement` (`:153-165`), so the parser has one place to see each element's start.

### 2.2 `TH2File` (`lib/src/elements/th2_file.dart`, 1098 lines)

- `TH2File()` (`:80-82`) always takes a new MPID from `nextMPIDForTH2Files()`. `TH2File.forCWJM` (`:68-78`) takes an `mpID` and runs `_initializeSupportMaps`, which registers thIDs and fills the type sets; it never sets the elements' `th2File`.
- `toMap()` (`:96-106`) has `filename`, `encoding`, `mpID`, `childrenMPIDs` and `elementByMPID` (int keys, each value an element's `toMap()`), **no `lineEnding`**. `fromMap` (`:108-120`) and `copyWith` (`:126-156`) don't carry it either, so a copy gets the platform default. `copyWith` has three callers, all in the line simplification (`th2_file_edit_element_edit_controller.dart:2040`, `:2083`, `:2560`). About 56 test files (`t1100`–`t1900` and others) take `TH2File.fromMap(x.toMap())` snapshots; they round-trip through `toMap`, so a required `lineEnding` in `fromMap` keeps them working.
- `clear()` (`:773-789`) resets the element map, children, both thID maps, the type sets, the lazy lists, the area-line maps and the bounding box, and also `filename` and `encoding`.
- Elements store their MPID references in their maps under `mpID`, `parentMPID` and `childrenMPIDs`; every command option stores its owner under `parentMPID`. No element or option map has another MPID-valued key (checked with a grep for `'…MPID…':` keys in `lib/src/elements`). Area border references name their line by thID.

### 2.3 Controller (`lib/src/controllers/th2_file_edit_controller.dart`, 2010 lines)

- `create` (`:642-652`) and `createFromNewTH2File` (`:656-665`) use `_create()` (`:667`) and `_basicInitialization` (`:669-718`), which builds the ~20 sub-controllers, each keeping the `TH2File` it got. Construction installs no reactions; it reads the default options from the settings and creates `th2FileFocusNode` (`:634`). `dispose()` (`:1527-1539`) is safe on a controller that never installed reactions or got a widget.
- `_finalFilePreparations` (`:827-864`): for a valid file with scraps, sets the first scrap active, `updateHasMultipleScraps()` and the default snap targets; then `_initializeReactions()` (`:866`, the dirty-mirroring `reaction` at `:1032`); for a broken file it returns after `setFilename`; otherwise `clearIsSelected`/`setIsSelected(…, false)` for points and lines, `resetSelectableElements()`, `updateEnableSelectButton()`, `initializeUsedTypes()`, `setFilename`.
- `execute(command)` (`:1806-1811`) runs the command through `MPUndoRedoController.execute`, then `updateControllersAfterElementEditPartial`/`Final` and `updateUndoRedoStatus()`. `undo()`/`redo()` (`:1840-1848`) call `_undoRedoDone()` (`:1834-1838`).
- `setActiveScrap` (`:1109-1129`) clears the selection and calls `_updateCurrentScrapName()` (`:1932-1940`). `_disposed`/`isDisposed` (`:61-64`).
- `_encodedFileContents()` (`:1648-1657`) writes with `includeEmptyLines: true, useOriginalRepresentation: true`.

### 2.4 Commands and undo stack

- Commands are `part`s of `mp_command.dart`. A command type needs an `MPCommandType` value, a `fromMap` case (`mp_command.dart:~249`), an `MPCommandDescriptionType` value and its string in `MPTextToUser` (`mp_text_to_user.dart:~454`) with EN/PT `.arb` entries. `getOppositeDescription` returns the description itself by `default` (`mp_command_description_type.dart:142`). `MPSetFileEncodingCommand` is the closest template.
- `MPUndoRedoController` (`mp_undo_redo_controller.dart`) stores `MPUndoRedoCommand(mapUndo, mapRedo)` and rebuilds commands with `MPCommand.fromMap` on every `undo()`, `redo()`, `undoDescription` and `redoDescription`. `add()` (`:35-89`) copies redo entries into the undo list through `fromMap`, `copyWith(descriptionType:)` and `toMap()`. `undo()`/`redo()` run the command, then `setState(selectEmptySelection)` and `triggerAllElementsRedraw()`.

### 2.5 Sub-controller state the refresh must fix

- Selection (`th2_file_edit_selection_controller.dart`): `_isSelected` (`:43`), `selectedScrapMPIDs` (`:45`, with `pruneSelectedScraps`), `_mpSelectedElementsLogical` (`:69`), `_selectedEndControlPoints` (`:113`), `_selectedLineLineSegmentsMPIDs` (`:123`, reset by `resetSelectedLineLineSegmentsMPIDs`, `:1460`), `updateAllSelectedElementsClones` (`:326`), `updateSelectedLineSegment` (`:305`), `resetSelectableElements` (`:613`), `updateSelectableEndAndControlPoints` (`:1155`).
- Hide (`th2_file_hide_element_controller.dart`): `_hiddenScrapMPIDs` (`:24`), `_hiddenElementMPIDs` (`:27`). Its visibility actions mark the station cache with `userInteractionController.markTherionStationPointNameCoordinateCacheDirty()`, update snap targets and redraw.
- Snap: `setSnapTargets` (`th2_file_edit_snap_controller.dart:97`), `updateSnapTargets` (`:170`).
- Used types: `initializeUsedTypes()` isn't idempotent (parent §2.5).

### 2.6 Encoding

`MPEncodingAux.encode` (`lib/src/auxiliary/mp_encoding_aux.dart:52`) is already the shared encoder of `toBytes` (since `eef79409`), so the parent's "move `toBytes`' encoder choice into a shared helper" is done. `ascii` and `latin1` throw `ArgumentError` on a character they can't hold, and charset.dart's code pages throw `FormatException` (`charset-2.0.1`, `code_page.dart`, no `invalidCharacter` given); `utf8` never fails. So "encode the line and catch" is a complete encodability check.

### 2.7 Phase 1 pieces used here

`TH2TextLineEndingsAux` (`loneCarriageReturnOffset`, `lineStartOffsets`, `lineIndexAtOffset`), `TH2TextLineMap` (`ownerOfLine`, `ownLinesOf`, `firstOwnLineOf`, `rangeOf`, `removedLines`, `relocations`, `addedEndings`, `fromParserStartLines`), `TH2FileWriter.serializeWithLineMap`, `TH2TextElementLocator`, and the parser's `lineStarts`/`elementStartLines`/`parsedLineCount`. A line map holds owners, not text: whoever compares line text keeps the text next to its map.

## 3. Scope and non-goals

### In scope

- `TH2FileParser.parse` gains `contents` and `targetController`; the static encoding detection helpers; `lineNumberInProgress`; `TH2FileNormalization` records.
- `TH2File.withMPID`, `lineEnding` in `toMap`/`fromMap`/`forCWJM`/`copyWith`, and `replaceContentsFrom`.
- `TH2FileEditControllerBase.createForDetachedParse` and the `_initializeReactions` assertion.
- `TH2TextValidator`, `TH2TextValidationResult`, `TH2TextValidationCache`, `TH2TextDiagnostic`.
- `TH2TextNormalizationAnalyzer` (markers) and `TH2TextCursorMapper` (raw → normalized lines).
- `TH2TextIdentityMatcher` and `TH2TextMPIDRemapper`.
- `TH2TextLineTracker` (pure; parent §4.14). Feeding it from the buffer is Phase 3.
- `MPReplaceTH2FileContentsCommand`, `executeReplaceTH2FileContents`, `syncControllersWithModel`, `TH2FileHideElementController.ensureScrapVisible`, and the move of `_finalFilePreparations` onto `syncControllersWithModel`.
- `TH2FileEditController.serializeForTextMode()` and `applyTextContent`, with `TH2TextApplySession` and `TH2TextApplyResult`.
- The command description string (EN/PT) and `flutter gen-l10n`.
- Tests `t3964`–`t3971`, `t3985`, `t3986`.

### Out of scope (later phases)

- `TH2TextEditController`, idle debounce, the editor widget, localized diagnostic and marker texts (Phase 3 maps `TH2TextDiagnostic` to `THTextEditorDiagnostic`; Phase 6 writes the strings).
- The operation gate, its assertion in `applyTextContent`, the buffer lock's real implementation, mode switching, Save (Phase 4). Phase 2's `applyTextContent` already calls the session's `lockBuffer()` at the parent's point (§4.10), so Phase 4 only implements it.
- Showing a hidden scrap in `setActiveScrap`, the hide controller's "never hide the active scrap" rule and the tree changes (Phase 4). Phase 2 adds only the selection-preserving show helper that the refresh needs (§4.11).
- The broken-file baseline (Phase 5). `applyTextContent` asserts that the controller isn't broken, and returns `rejected` in release with a line-less error.
- The `t3969` and `t3966` assertions that need Save, Save As or the canvas UI (moved to `t3980`/`t3987` and `t3978`, §6).

### Changes to the parent plan

Recorded here, and in the parent's Phase 2 entry and named sections at step 9 (§5):

1. `serializeForTextMode()` moves into Phase 2 (parent §4.2 places it with mode switching): `applyTextContent` and its tests need the live text and writer map. It throws Phase 1's `TH2UnsupportedLineEndingException` unchanged; Phase 4 catches it.
2. `applyTextContent` takes a `TH2TextApplySession` (§4.10) instead of reading `_textEditController`, which doesn't exist until Phase 3. Phase 3's `TH2TextEditController` implements the interface, and Phase 4 passes `_textEditController!` and adds the gate assertion. The parent's `applyTextContent(String content, {bool lockBufferOnAccept})` becomes `applyTextContent(String content, {required TH2TextApplySession session, bool lockBufferOnAccept = false})`.
3. `TH2TextLineTracker` is built here, since `t3986` (Phase 2) tests it; Phase 3 feeds it.
4. The selection-preserving show helper of parent §4.14 is built here (§4.11); Phase 4 reuses it in `setActiveScrap`.
5. Diagnostics and markers are structured values here (§4.4); their localized texts are Phase 3/6 work. Only the command description is localized now.
6. `t3969`'s Save/Save As assertions and `t3966`'s "returning to the canvas" assertion move to Phase 4's tests (§6).
7. **The text never sets `lineEnding`.** The parent's §4.2 has `contents` set `TH2File.lineEnding` from the text, with the platform default when no line break is seen, and its §4.7 step 2 has `replaceContentsFrom` take the source's `lineEnding`. Then an edit could switch a file's line ending: deleting a CRLF file's `encoding` line leaves a first line starting with `#`, and the apply would put the platform default in place of `\r\n`. Here the line ending is set at load only: the scratch file starts with the live file's (§4.1, §4.3), and `replaceContentsFrom` keeps it (§4.7). The parent's Phase 2 entry ("with `contents` setting both the encoding and `lineEnding` from the text") changes too.
8. **Load fix.** `detectEncodingFromBytes` no longer throws on a non-ASCII byte in the encoding window (§4.1), so the parent's "load behavior doesn't change" (§4.2, _Broken file_) gets this exception.

## 4. Design

### 4.1 Encoding detection and `contents` (parser)

- **Static helpers.** Replace `_encodingNameFromFile` and `_isEncodingDelimiter` with two public static methods returning a record, `({String encoding, String? lineEnding})`:
  - `TH2FileParser.detectEncodingFromBytes(Uint8List bytes)`: today's algorithm, byte for byte, but returning the line ending it saw (`\r\n` or `\n`, or `null` when it stopped at `#`, at `mpthMaxEncodingLength` or at the end) instead of setting it, with one fix: a byte ≥ 0x80 is an ordinary character that is never a delimiter (`String.fromCharCode(byte)`), instead of going through `utf8.decode([byte])`, which throws on it (§2.1). The `encoding` line and its delimiters are ASCII, so no file that loads today changes; a file with no `encoding` line and a non-ASCII character in the window now loads instead of failing with "Failed to read file".
  - `TH2FileParser.detectEncodingFromText(String text)`: the same rules on characters: skip leading spaces, tabs, `\r` and `\n`; read at most `mpthMaxEncodingLength` characters; stop at `#`, `\r\n` or `\n`; match `_encodingRegex` (made `static`); `mpDefaultEncoding` when it doesn't match.

  On a load, `parse` assigns `encoding` from the result and `lineEnding` only when the result's `lineEnding` is non-null, so a load behaves as today except for the non-ASCII fix above. `t3964` compares both helpers on every fixture's bytes and decoded text.
- **`String? contents`.** When given, `fileBytes` must be `null` (assert). `parse` skips reading and decoding: it takes the encoding from `detectEncodingFromText(contents)`, never the line ending, strips NUL characters as `_decodeFile` does (extracted into a shared `_stripNul`), counts lines and splits. So the same text parses to the same model as its bytes would, except for `lineEnding`: the file's line ending is set at load and no text edit changes it, so the scratch file keeps the live file's (§4.3) whatever the text's first line shows. Taking it from the text would let an edit switch it: deleting the `encoding` line of a CRLF file leaves a first line starting with `#`, no line break is seen, and the platform default would replace `\r\n` on apply. A stripped NUL changes a line's text, so the analyzer gives that line a generic rewrite marker (§4.5).
- **`TH2FileEditController? targetController`.** When given, `parse` uses it and never calls `getTH2FileEditController`; `forceNewController` is ignored (assert it's the default).
- **`int? lineNumberInProgress`.** A public getter over a private field, `null` at the start of `parse`. `_injectContents` sets it to `_currentLineNumber` at the top of each loop iteration and back to `null` after the loop. A throw during injection therefore leaves the line being read; a throw in a clean-up pass leaves `null`. Load behavior doesn't change.

### 4.2 Normalization records (parser)

`TH2FileNormalization` (new, `lib/src/mp_file_read_write/th2_file_normalization.dart`): `kind` (`TH2FileNormalizationKind`: `rewrittenLine`, `removedDuplicateLinePoint`, `removedShortLine`, `removedBorderOfShortLine`, `removedEmptyArea`), `line` (1-based raw line of the element), `mpID` and `removedMPIDs` (`Set<int>`: the removed element and all its descendants, collected **before** `removeElement`; empty for `rewrittenLine`). The parser gains `final List<TH2FileNormalization> normalizations`, cleared at the start of `parse`. `line` is `elementStartLines[mpID]`.

| Where | Record |
|---|---|
| `_cleanOriginalLinesInFile`, for each flagged MPID still in the file | `rewrittenLine` |
| `_resolveBorderReference`, third branch only (stored text cleared) | `rewrittenLine` for the border |
| `_linesCleanUp`, either duplicate-point removal | `removedDuplicateLinePoint` for the removed segment |
| `_linesCleanUp`, short line with an area border | `removedBorderOfShortLine` for the border, recorded **before** it is removed, even when the area keeps other borders |
| `_linesCleanUp`, short line | `removedShortLine` for the line |
| `_areasCleanUp`, area left with no border | `removedEmptyArea` for the area |

A flagged MPID can be removed later (a line whose header was rewritten and is then removed as short); `_cleanOriginalLinesInFile` runs first, so both records can exist, and the analyzer gives a removed line only its removal record (§4.5). The unresolved-border removals in `_areasCleanUp` report problems, so their text is rejected and needs no record. A load ignores `normalizations`.

### 4.3 Detached parse: `createForDetachedParse`

- `TH2File.withMPID(int mpID)`: a named constructor that sets `_mpID` to `mpID` and nothing else.
- `static TH2FileEditController TH2FileEditControllerBase.createForDetachedParse({required String filename, required int th2FileMPID, required String lineEnding})`: `_create()`, a `TH2File.withMPID(th2FileMPID)` with that `filename` and `lineEnding` (the live file's, §4.1), `_basicInitialization`, and `_isDetachedParse = true` (a new private `bool`). It is never registered, never gets a tab, and never runs `_finalFilePreparations` or `_initializeReactions`. The doc comment says why: it shares the real file's filename, so the dirty-mirroring reaction would add or remove the real file's path in `THProjectController.dirtyFilePaths`. `_initializeReactions` starts with `assert(!_isDetachedParse)`; a `@visibleForTesting void initializeReactionsForTesting()` calls it, for `t3964`.
- Because the scratch file has the real file's MPID and filename, it can be `==` to the live file (parent §2.5). No element object of a scratch file is ever put into the live file (§4.9).

### 4.4 Validation: `TH2TextValidator`

`TH2TextValidator` (new, `lib/src/auxiliary/th2_text_validator.dart`):

`static Future<TH2TextValidationResult> validate({required String content, required String filename, required int th2FileMPID, required String lineEnding})`. `lineEnding` is the live file's and only seeds the scratch file (§4.1, §4.3).

1. **Lone `\r`.** `loneCarriageReturnOffset(content)`; if found, return `rejected` with one `unsupportedLineEnding` error diagnostic on its line (`lineIndexAtOffset`). Nothing is parsed.
2. **Encodability.** `final String encoding = TH2FileParser.detectEncodingFromText(content).encoding`. For each line (Phase 1's `lineStartOffsets`, the line text without its ending), `MPEncodingAux.encode(lineText, encoding)` in a `try`; a throw gives an `unencodableCharacter` error on that line, with `encoding` as detail. This runs whatever the parse does, so both kinds of diagnostic can show at once. The encoding is the one the detached model will have (§4.1), which Save then uses.
3. **Parse.** `createForDetachedParse` (with `lineEnding`), then a new `TH2FileParser` with `parse(filename, contents: content, targetController: scratch)` inside `try`/`catch (e, s)`/`finally`. On a throw: an `unreadableText` error (detail: the exception's message) on `parser.lineNumberInProgress - 1` when it is non-null, else line-less; `mpLog.e` with the stack trace in debug builds. The `finally` disposes the scratch controller.
4. **Problems.** Each `TH2FileProblem` becomes a `parseProblem` error on `lineNumber - 1`, or a line-less one when `lineNumber < 1`, carrying the problem. Parser error strings are not converted: `_addError` already records each one as a `parseError` problem on its line, unless that line already has a problem, so converting them too would show every error twice. Any error diagnostic from steps 2–4 makes the result `rejected`.
5. **Valid.** `(normalizedText, writerMap) = TH2FileWriter().serializeWithLineMap(detached, includeEmptyLines: true, useOriginalRepresentation: true)`; `parserMap = TH2TextLineMap.fromParserStartLines(lineStarts: parser.lineStarts, lineCount: parser.parsedLineCount, th2File: detached)`; then the analyzer (§4.5) gives the information diagnostics and the cursor mapper.

The validator is the **single entry point** of the detached parse: idle validation (Phase 3) and `applyTextContent` both go through it, so neither can see an exception.

**`TH2TextDiagnostic`** (new, same file): `int? line` (0-based, `null` for line-less), `TH2TextDiagnosticSeverity severity` (`error`, `information`), `TH2TextDiagnosticKind kind` (`unsupportedLineEnding`, `unencodableCharacter`, `unreadableText`, `parseProblem`, and the marker kinds of §4.5), `String? detail`, `TH2FileProblem? problem`, `int? destinationLine` (moves). It holds no localized text.

**`TH2TextValidationResult`**: `content` (the exact string validated), `isValid`, `diagnostics` (sorted by line, line-less first), and for valid results only: `detachedFile`, `normalizedText`, `writerMap` (of *N(T)*), `parserMap` (of *T*), `normalizations` and `cursorMapper`. The detached `TH2File` is never mutated after validation: the apply reads it through `toMap()` (§4.9).

**`TH2TextValidationCache`** (new, same file): holds at most one finished result and one in-flight validation, each keyed by its exact content string. `lineEnding` isn't part of the key: a file's line ending never changes while it is open (§4.7). `Future<TH2TextValidationResult> validate(String content, {required String filename, required int th2FileMPID, required String lineEnding})` returns the finished result when its content equals `content`, joins the in-flight `Future` when its content equals `content`, and otherwise starts a new validation, which replaces both slots; when a validation finishes, its result is stored only if no newer validation has started since. `void clear()` drops both. Phase 3 calls it after its idle delay; `applyTextContent` calls it directly.

### 4.5 Markers and cursor mapping: `TH2TextNormalizationAnalyzer`

Pure (new, `lib/src/auxiliary/th2_text_normalization_analyzer.dart`). Inputs: the raw text *T* and its `parserMap`, *N(T)* and its `writerMap`, `normalizations`, and the detached file. Both maps use the detached model's MPIDs, so they are compared directly. Line texts are compared **without their endings** (parent §4.2). Output: information diagnostics, and the data for `TH2TextCursorMapper`.

1. **Removed lines.** Each `parserMap.removedLines` entry `line → mpID` finds the record whose `removedMPIDs` contains `mpID` and gets one marker of that record's kind. A removed line gets nothing else. A removed line with no covering record is a bug: `assert`, and give it a generic rewrite marker in release.
2. **Recorded rewrites.** For each `rewrittenLine` record whose MPID survives, every raw own line of it gets a `rewrittenLine` marker.
3. **Generic rewrites.** For every surviving element (in `parserMap.ownerMPIDs`) not covered by step 2: if the texts of its raw own lines differ from the texts of its `writerMap` own lines, each raw own line gets a `genericRewrite` marker. In debug builds, log the element when its detached copy still has a nonempty `originalLineInTH2File` and it isn't an `MPImageInsertConfig` written in XTherion format: the writer reproduces stored text, so the difference comes from a path that changes text without recording it.
4. **Moves.** For each `writerMap.relocations` entry: every raw own line of the moved setting gets a `movedSetting` marker with `destinationLine` (0-based here; the message adds 1). Comments, empty lines and lines merely shifted get none. A setting both moved and rewritten gets both markers.
5. **Added lines.** Walk `writerMap` lines in order. A line whose owner has no raw own lines (the file's MPID for a synthesized `encoding` line) is added; consecutive added lines with the same owner form one block. The block's marker (`addedLine`, detail: the block's text without endings) goes on the first raw own line of the next owner in *N(T)* order that has raw lines, or on the last raw line when there is none, or on line 0 for an empty buffer.
6. **Added endings.** For each `writerMap.addedEndings` entry: an `addedEnding` marker on the owner's last raw own line. No move marker results from it.

**`TH2TextCursorMapper`**: `int mapRawLine(int rawLine)`. Find the raw line's owner in `parserMap`; if it has none (a removed line, a discarded leading blank line, a line past the end), use the nearest raw line above that has a surviving owner, or return 0 when there is none. Then let *k* be the line's index among the owner's raw own lines, and return the owner's `writerMap` own line *k*, or its last one when it has fewer. An owner with no writer lines (only possible through a bug) maps to the start of its parent's range, or 0. No line is matched by text.

### 4.6 Identity matching: `TH2TextIdentityMatcher`

Pure (new, `lib/src/auxiliary/th2_text_identity_matcher.dart`). Input: two sides, each a `TH2File`, its writer text and its writer map. The live side is the session's `initialContent` and `initialLineMap` (the live model's text, §4.10); the detached side is *N(T)* and its `writerMap`. Output: `Map<int, int>` from detached MPID to live MPID, injective. The file's MPID maps to itself (both files share it, §4.3).

- **Key.** `(elementType, the texts of its own lines without endings)`. An element with no own lines has no key and is matched only in pass 1, under the generic rule below.
- **Generic elements**: `THEndline`, `THEndarea`, `THEndscrap`, `THEndcomment`, `THEmptyLine`, `THComment`, `THMultiLineComment` and its content, and elements with no own lines. They match only inside already matched parents (pass 1), never across the file (pass 2), and never count as substantive evidence (pass 3).
- **Uniqueness.** A pair matches only when its key is unique among the candidates of the pass **on both sides**. Order and position never break a tie.

Passes, sharing one work queue of matched parent pairs and a visited set, so each matched pair is scanned once:

1. **Within matched parents.** For a matched parent pair, group each side's unmatched children by key and match the keys unique on both sides; enqueue newly matched children that are parents. Start from the file pair.
2. **Across the file.** Among all elements still unmatched on both sides, excluding generic ones, match keys unique on both sides. Enqueue every newly matched parent and drain the queue with pass 1 before continuing.
3. **Containers through their children.** For `THLine` and `THArea`, then `THScrap`: an unmatched live container and an unmatched detached container of the same type match when the detached one has at least one **substantive** matched child (a `THPoint`, a `THLineSegment`, a `THAreaBorderTHID`, or a `THLine`/`THArea` matched by key or by this pass), every matched child of the live one is matched to a child of the detached one, and every matched child of the detached one to a child of the live one. Candidates are found from the matched children (each child's two parents), so the pass costs O(children). When one container qualifies for two, neither matches. Enqueue each new match and drain pass 1.

Cost: one pass over each side's lines to build keys (hashing the joined line text), plus the passes above, each linear in the number of elements.

**`TH2TextMPIDRemapper`** (new, same file): `static Map<String, dynamic> remap(Map<String, dynamic> detachedFileMap, Map<int, int> detachedToLive)`. It returns a **new** map; the input is never changed. It rewrites the file map's `childrenMPIDs` and `elementByMPID` keys and, inside every element map, `mpID`, `parentMPID` and each entry of `childrenMPIDs`, and inside every option map under `optionsMap` and `attrOptionsMap`, `parentMPID`. MPIDs not in the matching are kept: detached MPIDs come from the global counter, so they can't collide with live ones. The key list is fixed by §2.2's check, and `t3967` guards it (§6).

### 4.7 `TH2File` changes

- `lineEnding` is added to `toMap()`, required by `fromMap()`, taken by `forCWJM` (`required String lineEnding`) and by `copyWith` (`String? lineEnding`, default `this.lineEnding`).
- `void replaceContentsFrom(TH2File source)`:
  1. `assert` that every element and option of `source` has `th2File == null` (identity, not `==`).
  2. Clear what `clear()` clears, except `filename`, plus nothing else: keep `filename`, `fileBytes`, `mpID`, `isNewFile` and `lineEnding`.
  3. Take `source.encoding`. Never `source.lineEnding`: the file's line ending is set at load and no apply, undo or redo changes it (§4.1). `assert(source.lineEnding == lineEnding)`, which holds because the scratch file starts with the live one's and every snapshot comes from one of the two.
  4. Put **all** of `source`'s elements into the element map and copy its `childrenMPIDs`.
  5. Then, for every element, `element.setTH2File(this)` and `_updateSupportMaps(element)`; then `clearBoundingBox()`.
  6. `assert` that every element and option has `identical(th2File, this)`.
- `TH2File.==` and `hashCode` are unchanged.

Callers pass a fresh `TH2File.fromMap(snapshot)` only (§4.8, §4.9).

### 4.8 Command: `MPReplaceTH2FileContentsCommand`

New `part` of `mp_command.dart`, `MPCommandType.replaceTH2FileContents`, `MPCommandDescriptionType.replaceTH2FileContents` (its opposite is itself, through the existing `default`), and `mpCommandDescriptionReplaceTH2FileContents` in `intl_en.arb` ("Text edit") and `intl_pt.arb` ("Edição de texto"), mapped in `MPTextToUser`.

- Fields: `final Map<String, dynamic> before`, `final Map<String, dynamic> after`.
- `_prepareUndoRedoInfo`: sets `_undoRedoInfo = {}`, as `MPSetFileEncodingCommand` does.
- `_actualExecute`: `th2FileEditController.elementEditController.executeReplaceTH2FileContents(after)`.
- `_createUndoRedoCommand`: `MPUndoRedoCommand(mapRedo: toMap(), mapUndo: inverse.toMap())`, where the inverse is `forCWJM(before: after, after: before, descriptionType: descriptionType)`.
- **Snapshot sharing** (parent §4.7): `toMap()` puts the two snapshot map **objects** under `before` and `after`, never copies; `fromMap` keeps the maps it receives; `copyWith` passes them on. `==` compares `before` and `after` with `identical` and the description type; `hashCode` uses `identityHashCode` of both.

`TH2FileEditElementEditController.executeReplaceTH2FileContents(Map<String, dynamic> snapshot)`: `_th2File.replaceContentsFrom(TH2File.fromMap(snapshot))`, then `_th2FileEditController.syncControllersWithModel(initialSetup: false)`. Apply, undo and redo run the same `_actualExecute`, so all three refresh the same way. The existing undo/redo state transition (`selectEmptySelection`, then `_undoRedoDone()`) still follows undo and redo.

`MPUndoRedoController` gains `@visibleForTesting List<MPUndoRedoCommand> get undosForTesting` and `redosForTesting` (unmodifiable views) for `t3971`.

### 4.9 Live text: `serializeForTextMode()`

`(String, TH2TextLineMap) TH2FileEditController.serializeForTextMode()` calls `serializeWithLineMap(_th2File, …)` with the options of `_encodedFileContents()`. Both read them from one private `static const` record (or two constants) in the controller, so they can't drift apart.

### 4.10 `applyTextContent`

**`TH2TextApplySession`** (new abstract interface, `lib/src/auxiliary/th2_text_apply_session.dart`), what the apply needs from a text session:

- `int get sessionRevision`: changes whenever the session ends or is replaced.
- `bool get isOpen`.
- `String get content`: the current buffer.
- `String get initialContent` and `TH2TextLineMap get initialLineMap`: the live model's text and writer map.
- `int get cursorLine`: the raw cursor line (0-based).
- `TH2TextValidationCache get validationCache`.
- `void lockBuffer()`: takes the operation-owned buffer lock (parent §4.6). Phase 2's test session records the call; Phase 3/4 implement it.

**`TH2TextApplyResult`** (sealed, same file): `TH2TextApplyApplied(TH2TextLineMap lineMap, int cursorLine)`, `TH2TextApplyUnchanged(TH2TextLineMap lineMap, int cursorLine)`, `TH2TextApplyRejected(List<TH2TextDiagnostic> diagnostics)`, `TH2TextApplyCancelled()`. `lineMap` is the live writer map after the apply, and `cursorLine` the mapped cursor line in it.

**`Future<TH2TextApplyResult> applyTextContent(String content, {required TH2TextApplySession session, bool lockBufferOnAccept = false})`**:

1. `assert(!_isBroken)` (Phase 5 adds the broken-file branch); in release, return `rejected` with a line-less `unreadableText`.
2. Snapshot `revision = session.sessionRevision`.
3. **Unchanged text.** If `content == session.initialContent`: lock when asked and return `unchanged(session.initialLineMap, session.cursorLine)`. No parse.
4. **Validate.** `result = await session.validationCache.validate(content, filename: _th2File.filename, th2FileMPID: _th2File.mpID, lineEnding: _th2File.lineEnding)`.
5. **Staleness.** If `_disposed`, `!session.isOpen` or `session.sessionRevision != revision`: return `cancelled`. If `session.content != content`: set `content = session.content` and go back to step 3, so the current buffer is validated before any model change.
6. **Rejected**: return `rejected(result.diagnostics)`. No lock.
7. From here on everything is **synchronous**. Lock when asked (parent §4.6: after the final snapshot check, before any model change, also for `unchanged`).
8. `cursorLine = result.cursorMapper.mapRawLine(session.cursorLine)`.
9. **Normalizes back.** If `result.normalizedText == session.initialContent`: return `unchanged(session.initialLineMap, cursorLine)`. The texts are equal, so the line numbers carry over.
10. `before = _th2File.toMap()`. In debug builds, `assert(serializeForTextMode().$1 == session.initialContent)`: the matcher reads the live side from the session (step 11), which is only right while the session describes the live model (parent §4.6, _An apply that stays in text mode_).
11. `matching = TH2TextIdentityMatcher.match(live: (_th2File, session.initialContent, session.initialLineMap), detached: (result.detachedFile, result.normalizedText, result.writerMap))`.
12. `after = TH2TextMPIDRemapper.remap(result.detachedFile.toMap(), matching)`. In debug builds, `assert` that `TH2FileWriter().serialize(TH2File.fromMap(after), …)` with Save's options equals `result.normalizedText`.
13. `execute(MPReplaceTH2FileContentsCommand(before: before, after: after))`.
14. `(liveText, liveMap) = serializeForTextMode()`; `assert(liveText == result.normalizedText)`. Return `applied(liveMap, cursorLine)`.

It does not end or replace the session (parent §4.6); its callers do, in Phase 4. Ending a session must also clear its validation cache (Phase 3).

### 4.11 Controller refresh: `syncControllersWithModel`

`@action void TH2FileEditController.syncControllersWithModel({required bool initialSetup})`, the only place that brings the sub-controllers in line with the whole model (parent §4.7), in this order:

1. **Selection.** Drop MPIDs no longer in the file from `_mpSelectedElementsLogical`, `_selectedEndControlPoints`, `selectedScrapMPIDs` (`pruneSelectedScraps`) and `_isSelected`, through a new `TH2FileEditSelectionController.pruneToModel()`. It also drops a `_selectedEndControlPoints` entry whose segment is no longer a child of the single selected line (pass 2 of §4.6 can match a segment that moved to another line), or whose control-point type the live segment no longer has (a `controlPoint1`/`controlPoint2` on a segment that is now straight): `updateSelectedLineSegment` keeps a control-point type as it is. Then `updateAllSelectedElementsClones()`; `updateSelectedLineSegment(segment)` for each retained selected line point, with the live segment; `resetSelectedLineLineSegmentsMPIDs()`; `clearSelectedElementsBoundingBoxAndSelectionHandleCenters()`, since an apply keeps the selection while its geometry may change (undo and redo also clear it, through `_undoRedoDone`). A retained MPID doesn't mean unchanged geometry or children.
2. **Hidden.** A new `TH2FileHideElementController.pruneToModel()` drops removed MPIDs from `_hiddenElementMPIDs` and `_hiddenScrapMPIDs`.
3. **Active scrap.** Keep `_activeScrapID` when it names a scrap, else the first scrap, else `0`. When nonzero, `hideElementController.ensureScrapVisible(_activeScrapID)`: a new `@action` that removes the scrap from `_hiddenScrapMPIDs` and, when it was hidden, marks the station cache, updates snap targets and redraws the non-selected elements, without calling `setActiveScrap` and without touching the selection. Then `selectionController.resetSelectableElements()`, `updateSelectableEndAndControlPoints()`, `updateHasMultipleScraps()` and `_updateCurrentScrapName()`, every time.
4. **Snap targets.** With `initialSetup` and at least one scrap, the load defaults (`setSnapTargets(point, linePoint, [shot])`). Then `snapController.updateSnapTargets()` in every case.
5. **Station cache.** Without `initialSetup`, `userInteractionController.markTherionStationPointNameCoordinateCacheDirty()`.
6. **Used types.** Only with `initialSetup`, `elementEditController.initializeUsedTypes()`.
7. `updateEnableSelectButton()`, `triggerAllElementsRedraw()`, `bumpStructureRevision()`.

**`_finalFilePreparations`** becomes: `_initializeReactions()`; when not broken, `syncControllersWithModel(initialSetup: true)`; `setFilename(_th2File.filename)`; `_isLoading = false`. A broken load skips the refresh as today; Phase 5 calls it at the baseline. On a load nothing is selected, so step 1 does what `clearIsSelected`/`setIsSelected(…, false)` did; `isSelected` of points and lines then means "not in `_isSelected`", which is what those calls produced. The refresh executes no command and changes neither `_hasUndo` nor `enableSaveButton`, so the dirty reaction doesn't fire. `bumpStructureRevision()` doesn't bump while `_isLoading`, as today; `_commitLoadResult` still bumps after. The existing load tests check that a load gives the same state.

### 4.12 Line tracker: `TH2TextLineTracker`

Pure (new, `lib/src/auxiliary/th2_text_line_tracker.dart`), exactly as parent §4.14 specifies:

- `TH2TextLineTracker(String initialContent)`.
- `void recordChange({required String oldText, required String newText, int? cursorOffset})`: trim the common end first, limited to `newText.length - cursorOffset` when the offset is given, then the common start; express the change as old lines *a*..*b* replaced by *k* lines (lines counted with `lineStartOffsets`). Whole lines inserted at a line's start (inserted text ending with a line ending) only shift that line. An insertion at the end of a line's content, or at the end of an unterminated last line, whose text starts with a line ending leaves that line unedited and shifts the lines below. Anything else marks the touched lines edited.
- `int? currentLineOf(int initialLine)`: replays the recorded replacements on that one line; for an edited or deleted line, the nearest unedited line above, or 0.

Phase 3's `setContent` calls `recordChange`; nothing calls it in Phase 2 but `t3986`.

## 5. Implementation steps

Each step ends with `flutter analyze` clean in the worktree and the touched tests green; the last runs the full suite. After step 7, run `dart run build_runner build --delete-conflicting-outputs` in the worktree for the new `@action`s and commit the regenerated `.g.dart` files.

1. **`TH2File`** (§4.7), `TH2File.withMPID` (§4.3). `t3967`'s `replaceContentsFrom` cases, and every `test/t1*` test still green (they snapshot with `fromMap`).
2. **Parser**: static encoding helpers, `contents`, `targetController`, `lineNumberInProgress`, NUL helper (§4.1). `t3964`.
3. **Normalization records** (§4.2), **`createForDetachedParse`** (§4.3), **validator and cache** (§4.4). `t3969`, `t3964`.
4. **Analyzer and cursor mapper** (§4.5). `t3970`.
5. **Matcher and remapper** (§4.6). `t3965`.
6. **Line tracker** (§4.12). `t3986`.
7. **Command, description, `executeReplaceTH2FileContents`, `syncControllersWithModel`, `ensureScrapVisible`, `pruneToModel`s** (§4.8, §4.11), and `_finalFilePreparations` on the refresh. `flutter gen-l10n`, `build_runner`. Run the full suite here: the load path changed.
8. **`serializeForTextMode`, `TH2TextApplySession`, `TH2TextApplyResult`, `applyTextContent`** (§4.9, §4.10). `t3966`, `t3967`, `t3968`, `t3971`, `t3985`.
9. Full `flutter analyze` and `flutter test`; update the parent plan's Phase 2 entry and the sections named in §3, _Changes to the parent plan_. A CHANGELOG entry for the load fix of §4.1 only: nothing else is user-visible.

## 6. Tests

New tests parse inline text after `mpLocator.mpGeneralController.reset()`, as Phase 1's do. A **test session** (`test/auxiliary/th2_text_test_session.dart`) implements `TH2TextApplySession` with plain fields, a counter for `sessionRevision` and a record of `lockBuffer()` calls. Its `initialContent`/`initialLineMap` come from `serializeForTextMode()` of the controller under test. Controllers under test are loaded through `getTH2FileEditController` and `load()`, as `t3944` does.

### `t3964_th2_detached_parse_test.dart`

- A detached validation registers no controller in `MPGeneralController` (`th2ControllersRevision` unchanged, and `getTH2FileEditControllerIfExists(filename)` still `null` for a filename that has no controller yet), replaces none, and leaves `THProjectController.dirtyFilePaths` and the live controller's `th2File` unchanged. `structureRevision` of the live controller doesn't change.
- The scratch controller is disposed after a valid parse, a rejected one and one that throws (a hook or `isDisposed` on a controller exposed through a `@visibleForTesting` callback).
- `initializeReactionsForTesting()` on a detached controller trips its assertion.
- `detectEncodingFromBytes` and `detectEncodingFromText` agree on every fixture in `test/auxiliary/*.th2` (bytes, and text decoded with the detected encoding), including CRLF, no line ending in the window, leading blank lines and no `encoding` line. Parsing a fixture's decoded text with `contents` gives a `toMap()` equal to parsing its bytes, plus equal `encoding`, `lineEnding`, `lineStarts` and `parsedLineCount`, for every clean fixture.
- Text with NUL characters parses as its bytes do.
- A file with no `encoding` line whose first line has a non-ASCII character within `mpthMaxEncodingLength` characters (`scrap s1 -title "Çã"`) loads, from bytes and from text, with `mpDefaultEncoding`; before the fix the bytes load failed.
- With `contents`, the scratch file keeps the `lineEnding` it was created with, whatever the text's first line shows (CRLF text, LF text, and text starting with `#`).
- `t3944` and `t3945` pass unchanged.

### `t3965_th2_text_identity_matcher_test.dart`

As the parent's `t3965`, on the matcher directly and through `applyTextContent`:

- unchanged elements keep their MPIDs; an element whose own lines changed doesn't match by key;
- duplicates with identical own lines in one parent stay unmatched; repeated text in different matched parents (the same coordinates in two lines, `endline`) matches within each parent;
- a point cut and pasted into another scrap keeps its MPID;
- a line with a unique header moved to another scrap, while its coordinate lines also occur in another line: pass 2 matches it, and its children, including `endline`, keep their MPIDs;
- editing a scrap's header keeps the MPIDs of the scrap and its unchanged children; so does editing a line's header, and both at once (bottom-up);
- two containers of the same type with no substantive matched children stay unmatched; a container whose matched children qualify it for two candidates matches neither;
- one scrap and one line, with scrap header, line header and every coordinate replaced while `endline`, `endscrap`, blank lines and comments stay: the drawing containers and coordinates get fresh MPIDs, the generic children don't keep theirs either; likewise an area replacement keeping only `endarea`. It still applies and undo restores the exact predecessor;
- deleting a block of 1,000 lines and pasting it back elsewhere keeps the MPID of every unambiguously matched unchanged element;
- two elements whose lines differ only in their ending match.

### `t3966_th2_text_apply_undo_test.dart`

- Editing several lines and applying once creates one canvas undo step (`undoCount` + 1). Undo restores the exact pre-apply text (`serializeForTextMode()` equals the old `initialContent`); redo restores *N(T)*. An older canvas command (a point move made before) still undoes and redoes correctly afterwards. Two applies create two steps.
- Applying an empty buffer to a file with an active scrap sets `activeScrapID` to `0` before selectable elements are rebuilt (no lookup of the removed scrap: no exception, `currentScrapName` empty). Undo restores a valid active scrap; redo resets it to `0`.
- The unchanged paths: `content == initialContent` and text that normalizes back (a typed duplicate line point) add no command and return `unchanged`.
- Staleness: with the validation held pending (a test cache whose `validate` awaits a completer), changing the session's `content` revalidates the new content before applying it; changing `sessionRevision` or closing the session returns `cancelled`; disposing the controller returns `cancelled`. None changes the model or the undo stack.
- `lockBufferOnAccept`: the lock is taken for `applied` and both `unchanged` paths, and not for `rejected` or `cancelled`.
- Returning to the canvas and reading scrap-dependent UI state after the empty-buffer apply is checked in Phase 4 (`t3978`).

### `t3967_th2_text_apply_identity_test.dart`

- Clearly matched unchanged elements keep their MPIDs through apply and redo; ambiguous duplicate lines need not.
- Added points, lines and scraps have valid parent and child MPIDs; area border references resolve after apply, undo and redo.
- After each of them, every element and option of the live file has `identical(th2File, liveFile)`, including the children of scraps, lines and areas. `replaceContentsFrom` rejects (assertion) a source whose elements still point at a file, including a scratch file that is `==` to the live file.
- `replaceContentsFrom` keeps `filename`, `fileBytes`, `mpID`, `isNewFile` and `lineEnding`, and takes `encoding`.
- A selected line whose unchanged header keeps its MPID while points are added, removed or edited: during the command refresh of apply, undo and redo, before undo/redo clear the selection, the selection clone uses the live child IDs and coordinates, and a retained selected line point uses the live segment clone and endpoint type. `getSelectedLineLineSegmentsMPIDs()` populated before the replacement gives the live child order afterwards (checked after apply, and after selecting the restored line again after undo and redo). A selected line point whose segment pass 2 matched into another line, and a selected control point whose segment became straight, are dropped from the selected end and control points. After an apply that moves a selected point, the selection bounding box and handle centers follow the live geometry.
- **Remapper key guard.** For one instance of every `THElement` subclass and every `THCommandOption` subclass that the fixtures produce, collect the `toMap()` keys (recursively) whose name contains `mpid`, case-insensitively; the set must equal `{mpID, parentMPID, childrenMPIDs}`, and the `TH2File` map's must equal `{mpID, childrenMPIDs, elementByMPID}`. The remapped `after` of a test apply has no detached MPID left in the file map's `childrenMPIDs` for a matched top-level element. A new MPID-valued field then fails here instead of escaping the remap.
- `TH2File.copyWith()` and `fromMap(toMap())` preserve `lineEnding` `\r\n` while the platform default is `\n`.

### `t3968_th2_text_apply_line_endings_test.dart`

- A CRLF file (`lineEnding` `\r\n`, platform default `\n`): apply, undo and redo keep `lineEnding` and the serialized bytes; `serializeForTextMode()` after the apply still uses `\r\n` for generated lines.
- A file whose ending is the opposite of `MPDirectoryAux.getDefaultLineEnding()` (so the test means the same on every platform), with its `encoding` line deleted, so the text starts with `##XTHERION##`, and with its first line turned into a comment: after apply, undo and redo, `lineEnding` is unchanged, and the synthesized `encoding` line ends with it.
- A session with temporarily invalid text applies once when its final text is valid. A moved `endscrap` also applies once.
- A file with mixed `\r\n` and `\n` endings whose last line has none: edit one line, add a line with the file's ending (as Enter will insert in Phase 3), add one with the ending the file doesn't use (as a paste), delete one, then apply and encode with `toBytes`. The bytes differ from the original only in those lines: the edited line keeps its ending, the added lines keep theirs, the last line still has none. Adding the file's ending at the end of the last line gives it that ending.
- The Enter action's own behavior (`\r\n` after an apply, mixed-ending defaults) is checked by Phase 3's `t3973`.

### `t3969_th2_text_validation_rejection_test.dart`

- Text with a parse problem or error is rejected: diagnostics on the right lines, each error shown once (no line-less copy of a parser error string), the model and undo stack unchanged.
- `ç` in an `ASCII` file and a character outside `ISO8859-2` in an `ISO8859-2` file: an `unencodableCharacter` error on that line naming the encoding; also when the text has a parse problem elsewhere (both shown).
- A lone `\r`, mid-line and at the end: one `unsupportedLineEnding` error on its line, and no parse (no scratch controller created).
- A second scrap with an existing ID, typed or pasted: `unreadableText` on that scrap's line, with the ID in its detail; `applyTextContent` returns `rejected`; the scratch controller is disposed; the cache holds the rejection, and a second validation of the same text doesn't parse again.
- A throw from a clean-up pass, forced through a `@visibleForTesting` hook on the parser: a line-less `unreadableText`.
- Loading a file with duplicate scrap IDs still sets `loadError` (`t3944`).
- Save returning `textHasProblems` and Save As opening no picker are Phase 4's (`t3980`, `t3987`).

### `t3970_th2_text_normalization_test.dart`

The live model serializes to the final *N(T)* after every apply below. For each case, check the markers (kind, line, `destinationLine`, detail) and `mapRawLine` for every raw line:

- a duplicate line point: only its `removedDuplicateLinePoint` marker; the line before it gets no rewrite marker;
- a short line, and an area with two borders whose short border line is removed while the other border survives: `removedShortLine` on the line's lines, `removedBorderOfShortLine` on the border's raw line, which remains a removed line, the element before it gets no rewrite marker, a cursor on the border maps through the nearest surviving raw line above, and the area resolves its remaining border;
- an empty area: `removedEmptyArea`;
- a rewritten scrap option and a line option on its own line (`close on`): `rewrittenLine` on the header and on the option line;
- a repaired border reference (`b@1` for a line stored as `b_1`): `rewrittenLine` on the reference;
- a deleted `encoding` line: `addedLine` on the next element's first raw line; an empty buffer: valid, `addedLine` on line 0, and it applies to a file with no scraps;
- a setting typed after a scrap: one `movedSetting` marker at its raw line with the right destination; the scrap, its children and the section's settings, comments and empty lines get none; several settings after a shorter drawing block each get the right destination; a setting separated from the others only by file-level comments or empty lines stays and gets none;
- a settings-looking line inside a scrap: a comment, stays with the scrap, no marker;
- an unterminated last setting that moves up: `movedSetting` and `addedEnding` on its line;
- a representable `##MAPIAH##` image: `genericRewrite`, no debug log;
- line shifts caused only by added or removed neighbors: no marker;
- a cursor on a moved setting, a removed line, a rewritten multi-line element and a leading blank line maps through its owner, or to the nearest raw line above with a surviving owner, or to 0;
- a final text that normalizes to the initial text gives no canvas step.

### `t3971_th2_text_apply_performance_test.dart`

On the largest fixtures, and on a generated file of a few thousand lines: time (printed with `debugPrint`, not asserted) uncached and cached validation and one apply, for a small edit, a wholesale replacement, deleting and pasting a 1,000-line block, and long repeated lines. Assert:

- unchanged elements keep their MPIDs in every case but the wholesale replacement;
- an apply adds one `MPUndoRedoCommand` whose `mapUndo['before']`/`['after']` and `mapRedo['before']`/`['after']` are the same two map objects (`identical`); an undo followed by a new command, which copies the entry through `fromMap`, `copyWith` and `toMap`, still holds those two objects and adds no other snapshot;
- undo, redo and reading `undoDescription` leave both snapshots deep-equal to their state right after the apply (nothing mutates them).

### `t3985_th2_text_apply_controller_sync_test.dart`

- Undoing an apply that added a scrap while it is active makes the first scrap active, and `hasMultipleScraps` follows. When that first scrap was hidden, the refresh shows it before rebuilding selectable elements and snap targets; the active scrap stays visible through apply, undo and redo.
- An element removed by the undo, which was selected, hidden or a selected line point, leaves its MPID in none of the selection, the hidden sets, `isSelected` or the selectable elements. Redo gives the same model-derived state as the apply.
- After undo and redo, the state is `selectEmptySelection`; the test doesn't expect the apply-time selection back.
- Snap targets and the station cache reflect the restored model. Used-type counts don't change on apply, undo or redo.
- `currentScrapName` follows the active scrap: renaming the active scrap in its header updates it while the MPID stays; removing every scrap empties it.
- A valid load gives the same controller state as before the change: active scrap, `hasMultipleScraps`, snap targets, `isSelected`, selectable elements, used types and `enableSelectButton`, compared with a snapshot taken on the branch before step 7 for a few fixtures (one-off, like Phase 1's byte comparison), and permanently through the existing load tests.

### `t3986_th2_text_line_tracking_test.dart`

As the parent's `t3986`:

- `TH2TextLineEndingsAux` splits editor buffers with `\r\n`, `\n` and a missing final ending into the lines the parser sees (`parsedLineCount` and `lineStarts` of the same text), and finds a lone `\r` (Phase 1's `t3960` covers the unit cases).
- `TH2TextLineTracker`: typing in a line marks it edited; inserting lines above shifts it; deleting it maps to the nearest unedited line above; whole lines inserted at a line's start only shift it, while typing a character there marks it edited; Replace All, recorded as one change, counts as one; undoing an edit leaves the line edited; a CRLF buffer counts `\r\n` as one ending; no unedited line above gives 0; pasting a copy of a line directly above it keeps the original mapped to itself; deleting the first of two identical adjacent lines marks that one deleted and shifts the second; Enter at the end of a line, with and without auto-indent, in LF and CRLF buffers and at the end of an unterminated last line, leaves that line unedited and shifts the lines below, while typing a character at a line's end marks it edited; a change with no cursor offset is still recorded, trimmed with no limit.

## 7. Acceptance criteria

- `flutter analyze` clean; `flutter test` green, including `t3944`, `t3945`, `t1110` and every load test unchanged.
- No UI, localization (beyond the command description) or Save output change. The only load change is the non-ASCII fix of §4.1.
- A detached validation never registers, replaces or dirties a controller, and never throws.
- Every successful apply is one canvas undo step whose undo and redo restore the exact texts, with every live element and option pointing at the live file.

## 8. Risks and notes

1. **Identity assertions.** The `serialize(fromMap(after)) == N(T)` and `liveText == N(T)` assertions catch a remap that misses a reference or a matcher that pairs elements whose text differs. They are `assert`s, so `t3965`–`t3971` must run in debug mode, as `flutter test` does.
2. **Load refactor.** Moving `_finalFilePreparations` onto `syncControllersWithModel` touches every load. Step 7 runs the full suite, and `t3985` compares the controller state of a few fixtures with a pre-change snapshot.
3. **Snapshot cost.** Two whole-file maps per apply, shared by the command and its inverse (§4.8). `t3971` measures them; a large file with many applies holds many snapshots, as the parent's §6 item 4 accepts.
4. **Shared-start elements.** Phase 1's parser map gives a line to the first of several elements starting on it. No injector does that today; the analyzer and cursor mapper treat the others as having no raw lines, so they could only get an `addedLine` marker, and `t3962`'s fixture sweep would show it.
5. **Throwing clean-up pass.** `_linesCleanUp`'s `THCustomException` on an inconsistent border can't come from text a user types today; the test forces a throw through a hook, so the line-less path is covered anyway.
6. **Encoding change by text.** The detached model's encoding comes from the text's `encoding` line, so editing that line changes the file's encoding on apply, and undo restores it (the snapshots carry `encoding`). Encodability is checked against the new encoding, which Save will use.
7. **Release-mode broken files.** Until Phase 5, `applyTextContent` on a broken controller is a programming error: an assertion, and a rejection in release. No caller exists before Phase 4, which only enters text mode on a valid file until Phase 5.
