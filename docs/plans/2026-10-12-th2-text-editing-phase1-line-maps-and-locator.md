<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Text Editing — Phase 1: Line Maps, Settings Section and Locator

**Date:** 2026-10-12
**Status:** Proposed. Checked against `main` at `dcdaae85`. Validated against `1672f98b` on 2026-10-12 by running probes on the current parser and writer: round-trip stability is required only with `useOriginalRepresentation: true`, the locator handles lines owned by the file, `t3963` uses rows that a parse can produce, and the test writer options are stated. The ISO-8859 Save bug found then was fixed on `main` in `eef79409`, so no fixture is excluded from the reparse checks any more.
**Parent plan:** [TH2 Text Editing Mode with Selection Synchronization](2026-09-25-th2-text-editing.md) (§4.3, §4.4, §4.16 and §5 Phase 1)
**Issue:** [#38: Simplify object options entry by allowing user to type without clicking each option](https://github.com/rsevero/mapiah/issues/38)

## 1. Purpose

Build the pure, UI-free layer that every later phase uses to relate TH2 text lines to model elements:

- the writer's **line ledger** and `serializeWithLineMap`, which return the save-path text together with a `TH2TextLineMap` (MPID → own lines and range; line → owning MPID);
- the writer's **settings-section output planner**, which replaces today's "write all settings at the first one" behavior, with explicit `TH2TextRelocation` and added-ending records;
- the writer's handling of an **empty file**, and **line boundaries** after unterminated chunks;
- the parser's **`elementStartLines`**, from which a parser-side `TH2TextLineMap` is derived, including **removed lines** left by the clean-up passes;
- `TH2TextElementLocator`, which turns a line into the §3.3 canvas target.

Nothing here is visible in the UI, except one intended change to what ordinary Save writes: the settings-section policy of parent §4.16 and the line boundary after an unterminated chunk. Both go through the shared writer, so they apply to canvas Save and Save As on the feature branch as soon as this phase is committed there.

**Branch.** This phase is implemented on the feature branch `feat_38_th2_text_editing`, in its worktree, like every phase of the parent plan (parent §5, _Branch and merge_). It is not merged into `main` on its own: the branch is merged only after Phase 6 at least is implemented. The branch is created with `scripts/task_start.sh feat_38_th2_text_editing` as soon as the commit naming it as the only text editing branch reaches `main`, before any further validation of this plan. Every later validation or correction of this plan, and its implementation, is committed there; later phases continue in the same worktree.

## 2. Current codebase constraints

Verified at `dcdaae85`. Line numbers are those of that commit.

### 2.1 Writer (`lib/src/mp_file_read_write/th2_file_writer.dart`, 609 lines)

- `serialize` (`:35-62`) resets its state, writes a synthesized `encoding` line when `th2File.elementByMPID(th2File.childrenMPIDs.first) is! THEncoding` (`:51`), followed by `_trySerializeXTherionConfig()`, then `_childrenAsString(th2File)`. `childrenMPIDs.first` throws `StateError` on a file with no children.
- Settings emission is global: the encoding case of `serializeElement` (`:259-263`) calls `_trySerializeXTherionConfig()` (`:64-85`), which writes every setting right after the encoding line when **all** settings are new; otherwise the first setting reached in `serializeElement` (`:295-298`) calls `_serializeAllXTherionConfigs()` (`:87-111`), which writes every setting there, and `_xTherionConfigWritten` makes the others write nothing. `_configBlockElements()` (`:113-117`) lists the file-level settings in children order.
- Leaves (text producers): `_elementOriginalLineRepresentation` (`:322-324`), `_prepareLine` (`:467-540`, including wrapped long lines and the same-line comment), both branches of `_serializeEmptyLine` (`:143-149`), the generated branches of `_serializeMultiLineCommmentContent` (`:151-160`), `_serializeXTherionConfig` (`:181-192`), `_serializeXTherionImageInsertConfig` (`:194-217`) and `_serializeMapiahImageInsertConfig` (`:219-241`), the synthesized `encoding` line (`:52`), and in `_linePointOptionsAsString` (`:546-573`) both the stored option line (`_commandOptionOriginalLineRepresentation`, `:542-544`) and the generated one (`:562-564`).
- Composers: `_prepareLineWithOriginalRepresentation` (`:123-134`), `serializeElement` (`:243-320`), `_childrenAsString` (`:429-439`), the per-type serializers, `_trySerializeXTherionConfig` and `_serializeAllXTherionConfigs`.
- An XTherion-representable `MPImageInsertConfig` is written through a temporary `THXTherionImageInsertConfig` built by `fromMapiahImageInsertConfig` (`:226-231`), which reuses the model element's MPID.
- `toBytes` (`:575-608`) calls `serialize` and encodes. The only `lib` caller is `TH2FileEditController._encodedFileContents()` (`th2_file_edit_controller.dart:1648-1657`), used by `_actualSave` (`:1786`), so Save and Save As share it. No test calls `serializeElement` directly.

### 2.2 Parser (`lib/src/mp_file_read_write/th2_file_parser.dart`, 3506 lines)

- 21 `_th2FileElementEditController.executeAddElement(...)` calls, in `_injectEmptyLine` (`:465`), `_injectMultiLineCommentContent` (`:478`), `_injectEndMultiLineComment` (`:490`), `_injectStartMultiLineComment` (`:506`), `_injectEncoding` (`:528`), `_injectXTherionSetting` (`:567`), `_injectMapiahSetting` (`:633`), `_injectXTherionImageInsertConfig` (`:850`), `_injectPoint` (`:884`), `_injectBezierCurveLineSegment` (`:955`), `_injectAreaBorderTHID` (`:1006`), `_injectStraightLineSegment` (`:1037`), `_injectScrap` (`:1076`), `_injectEndScrap` (`:1098`), `_injectArea` (`:1173`), `_injectLine` (`:1224`), `_injectEndArea` (`:1265`), `_injectEndLine` (`:1294`), `_injectComment` (`:1342` full-line comment, `:1360` unrecognized) and `_injectUnknown` (`:2887`).
- `_injectContents` (`:154-185`) sets `_currentLineNumber` (1-based) before each `MPParseableLine`. `_scanStructureProblems` (`:2711-2730`) also sets it, but runs before injection and adds no element.
- Line-point option lines (`_injectLineCommandLikeOption`, `:1128-1155`) and area option lines (`_injectAreaCommandLikeOption`, `:1109-1120`) add options, not elements. A same-line comment is stored on the current element.
- `_splitContents` (`:3325-3440`) joins multi-line values into one parseable line numbered by its first line, and splits only at `\n` and `\r\n` (`_findLineBreak`, `:3073-3089`).
- Clean-up after injection (`:3049-3051`): `_cleanOriginalLinesInFile` substitutes elements under the same MPID; `_linesCleanUp` (`:3127-3205`) removes duplicate line points, short lines and their area border references; `_areasCleanUp` (`:3276-3323`) rewrites or removes border references and removes empty areas. `TH2File.removeElement` removes descendants too.
- `parse` returns `(TH2File, bool, List<String>)` (`:2992-3071`) and has no line-map output.

### 2.3 Tests and fixtures

- `test/auxiliary/` holds 397 `.th2` fixtures. 15 contain settings, all of them in a contiguous leading block, so **no fixture's plain round-trip output changes** under the new settings policy. No fixture contains a lone `\r`. `2025-06-20-point_date_quoted_value.th2` uses CRLF. At least ten fixtures end without a final line ending (for example `2025-10-05-001-line.th2`).
- Tests that add images and compare written output: `t1450` (`2025-10-06-004-only_encoding.th2`, encoding line terminated), `t2450`, `t2451`, `t2452`, plus `t0800`. They place new images right after leading settings, where old and new policy agree; `t2452` and `t0800` must still be run and checked.
- The highest existing test number is `t3957`. Parent plan numbering starts this phase at `t3960`; `t3989` is the settings-section test.
- `parse(filename, fileBytes: …)` accepts in-memory bytes, so most new tests build their input inline instead of adding fixtures.
- **Round-trip stability today** (checked at `1672f98b`, writing with `includeEmptyLines: true`, reparsing `toBytes` output): 333 fixtures parse cleanly. With `useOriginalRepresentation: true`, parse → write → parse → write is stable for all of them. With `false`, five are not stable, because of generated-output bugs that already exist: `2025-12-05-001-line_with_repeated_points.th2`, `th_file_parser-00151-point_with_dist_option_with_unit.th2`, `th_file_parser-00154-point_with_invalid_type_for_dist_option_failure.th2`, `th_file_parser-02281-point_with_explored_option_with_unit.th2` and `th_file_parser-02284-point_with_invalid_type_for_explored_option_failure.th2` (the last four don't reparse cleanly).
- **ISO-8859 Save (fixed).** At `1672f98b`, `th_file_parser-00014-iso8859-2_encoding.th2` and `th_file_parser-00015-iso8859-15_encoding.th2` were written as UTF-8 and couldn't be read back. `eef79409` fixed it on `main` (`MPEncodingAux`, `t3958`), so both fixtures round-trip like the others.
- **Lines that a clean parse can't produce.** Area option lines (`place bottom`, `clip off` inside an area body) are read as invalid border references, a parse problem, and the writer never emits an area option on its own line. A line option such as `subtype` on its own line, before or after a line point, is moved into the line header (`line wall:clay`) and the line's stored text is cleared. So a writer map has no area option line and no `subtype` option line; real line-point options (`smooth`, `orientation`, `l-size`, …) stay on their own lines, owned by their segment.

## 3. Scope and non-goals

### In scope

- `TH2TextLineEndingsAux` (pure): lone-`\r` detection and line splitting at `\r\n`/`\n`. **Pulled forward from parent Phase 2**, because the ledger scan and the parser map need the same line split; Phase 2 reuses it and extends its tests (`t3986`).
- `TH2UnsupportedLineEndingException`.
- The writer's `_emit` ledger, `serializeWithLineMap`, empty-file handling and boundary insertion.
- `TH2FileOutputPlanner` (pure settings-section planner) and the writer refactor that consumes it.
- `TH2TextLineMap`, `TH2TextRelocation`, `TH2TextAddedEnding`.
- `TH2FileParser.elementStartLines`, `parsedLineCount`, the `_addElement` helper, and `TH2TextLineMap.fromParserStartLines` with removed lines.
- `TH2TextElementLocator` and `TH2TextLocation`.
- Tests `t3960`, `t3961`, `t3962`, `t3963`, `t3989`.
- A CHANGELOG entry for the Save layout change (§8.8).

### Out of scope (later phases)

- Detached parse, `contents`/`targetController` on `parse`, `lineNumberInProgress`, `TH2FileNormalization` records and markers, identity matching, apply command (Phase 2). Phase 1's removed lines record the **removed MPID** of the line's derived owner, which may be a child of the element the clean-up removed: the point and `endline` lines of a removed short line record those children's MPIDs, not the line's. Phase 2 links them to normalization records, so when it records a removal it also collects the removed element's descendant MPIDs, while they are still in the file.
- The generated-output instabilities (§2.3).
- `serializeForTextMode()`, `applyTextLocation`, any controller, widget, localization or help change (Phases 3–6). The exception added here is caught and localized in Phase 4.

## 4. Design

### 4.1 `TH2TextLineEndingsAux` (`lib/src/auxiliary/th2_text_line_endings_aux.dart`)

Static, pure methods:

- `int? loneCarriageReturnOffset(String text)`: offset of the first `\r` not followed by `\n`, or `null`.
- `List<int> lineStartOffsets(String text)`: start offset of each line, splitting after `\n` (a preceding `\r` is part of that ending). A final ending does not start another line: `"a\n"` has one line, `"a\nb"` two, `""` none. This matches the parser's `_splitContents`.
- `int lineIndexAtOffset(List<int> lineStarts, int offset)`: binary search.

Callers run `loneCarriageReturnOffset` first; the splitter does not validate.

### 4.2 `TH2UnsupportedLineEndingException` (`lib/src/exceptions/th2_unsupported_line_ending_exception.dart`)

Extends `THBaseException`, with `final int offset` (into the writer output) and `final int mpID` (the owner of the offending chunk). A real `throw`, not an assertion: Phase 4 relies on it in release builds.

### 4.3 `TH2FileOutputPlanner` (`lib/src/mp_file_read_write/th2_file_output_planner.dart`)

Pure: input is the file's top-level child MPIDs with their element types, output is a `TH2FileOutputPlan`:

- `bool synthesizeEncoding`: `childrenMPIDs.isEmpty || first child is! THEncoding` (§4.5).
- `List<int> orderedChildMPIDs`: every top-level child exactly once.
- `List<int> relocatedSettingMPIDs`, in output order.

Algorithm (parent §4.16), with `isSetting` meaning `TH2FileWriter.configBlockElementTypes`:

1. `start` = 1 if the first child is an `encoding`, else 0.
2. `runEnd`: advance from `start` while the child is a setting, a comment, an empty line or a multiline comment (`THMultiLineComment`, whose content and `endcomment` are its children). Stop at the first other element or at the end of the children.
3. `sectionEnd`: from `runEnd`, step back over trailing comments and multiline comments. **The section never ends in a comment**, also when the run reaches the end of the file with no other element after it (decision, see §8.3).
4. `insertAt`: from `sectionEnd`, step back over trailing empty lines. When the section is empty, `insertAt == start`.
5. `later` = the settings at index ≥ `sectionEnd`, in children order.
6. Order: `children[0..insertAt) + later + children[insertAt..)` with `later` removed from the tail.
7. `relocatedSettingMPIDs = later`.

Every loop is bounded by the children count. Nested containers are never inspected: settings-looking lines inside scraps are comments (parent §2.3), and settings-looking text in a multiline comment is content.

Expected orders (all from parent §4.16, plus the two cases the parent left implicit):

| Children | Output |
|---|---|
| `enc, S1, C, E, S2, S3, scrap` | unchanged |
| `enc, S1, C, E, scrap, I` | `enc, S1, C, I, E, scrap` (today: `I` after `S1`; changes, see §8.2) |
| `enc, E, scrapA, E, scrapB, I` | `enc, I, E, scrapA, E, scrapB` |
| `enc, S1, E, C, scrap, I` | `enc, S1, I, E, C, scrap` |
| `enc, C, scrap, I` | `enc, I, C, scrap` |
| `enc, S1, scrap, C, S2` | `enc, S1, S2, scrap, C` |
| `enc, S1, S2, E, C, E, scrap, I` | `enc, S1, S2, E, C, I, E, scrap` (today: `I` after `S2`; changes, see §8.2) |
| `enc, S1, C` + `I` (no drawing element) | `enc, S1, I, C` |

### 4.4 Writer refactor and `_emit`

**State** (reset at the start of every serialization): `_recordLedger`, `List<TH2LedgerSpan> _ledger` (`mpID`, `start`, `length`), `int _outputLength`, `int? _lastChunkOwnerMPID`, `bool _lastChunkTerminated` (initially `true`), and the added-ending list (`ownerMPID`, separator offset).

**`String _emit(int mpID, String chunk)`**, with the rule in its doc comment: *a leaf's result is appended to the output exactly once, in the order the leaf was called, and never discarded or reordered.*

1. Empty chunk: return `''`; state unchanged.
2. Ledger mode only: `assert` that `mpID` is `_th2File.mpID` or names an element of `_th2File`; throw `TH2UnsupportedLineEndingException` when `loneCarriageReturnOffset(chunk)` is not `null` (checked **before** any separator, so a chunk ending in `\r` cannot become `\r\n`).
3. If `!_lastChunkTerminated`: prepend the writer's selected ending (`_lineEnding`, from `lineEnding` or `TH2File.lineEnding`), attributed to `_lastChunkOwnerMPID`; record it as an added ending, and in ledger mode as its own span.
4. Record the chunk's span in ledger mode; advance `_outputLength`; set `_lastChunkOwnerMPID = mpID`, `_lastChunkTerminated = chunk.endsWith('\n')`.
5. Return separator + chunk.

Boundary insertion runs in ordinary and ledger mode alike (parent §4.16). No ending is ever added at EOF, and stored text is never mutated. In ordinary mode a lone `\r` inside a chunk is written as today. In ledger mode, `assert` that `_lineEnding` is `\n` or `\r\n`.

**Where `_emit` goes** (leaves only; parent §4.3 table):

| Leaf | `mpID` |
|---|---|
| `_elementOriginalLineRepresentation(element)` | `element.mpID` |
| `_prepareLine(line, element)` (whole result, wrapped parts included) | `element.mpID` |
| stored and generated option lines in `_linePointOptionsAsString` | the line segment's `mpID` (equal to `option.parentMPID`) |
| generated branches of `_serializeXTherionConfig`, `_serializeXTherionImageInsertConfig`, `_serializeMapiahImageInsertConfig`, `_serializeMultiLineCommmentContent` | `element.mpID` (the temporary image element carries the model MPID) |
| both branches of `_serializeEmptyLine` | `element.mpID` |
| synthesized `encoding` line | `_th2File.mpID` |

No `_emit` in `_prepareLineWithOriginalRepresentation` or any other composer: it would count a generated line twice.

**Top level.** A private `_serializeFile()` shared by `serialize` and `serializeWithLineMap`:

1. Compute the plan (§4.3).
2. If `synthesizeEncoding`, emit the `encoding` line for the file.
3. `_serializeElement` each child in `orderedChildMPIDs`.

`serializeElement` becomes private (`_serializeElement`): it now depends on `_emit` state that only `_serializeFile` resets, and nothing outside the writer calls it. Its encoding case no longer calls `_trySerializeXTherionConfig`; its three setting cases call `_serializeXTherionConfig`, `_serializeXTherionImageInsertConfig` and `_serializeMapiahImageInsertConfig` individually. Remove `_trySerializeXTherionConfig`, `_serializeAllXTherionConfigs`, `_configBlockElements`, `_isConfigBlockElement` and `_xTherionConfigWritten`. Keep the public `configBlockElementTypes`, which the planner uses. Nested containers keep `_childrenAsString`.

**`(String, TH2TextLineMap) serializeWithLineMap(TH2File th2File, {bool includeEmptyLines = false, bool useOriginalRepresentation = false, String? lineEnding})`** sets `_recordLedger = true`, runs `_serializeFile()`, and resets `_recordLedger` in a `finally`. Then:

1. **Length check** (`assert`): spans are contiguous from 0 and their lengths add up to `text.length`. This catches a leaf that bypasses `_emit`, a chunk counted twice, or one recorded but not appended.
2. **Scan**: `lineStartOffsets(text)`; each nonempty span owns the lines containing its characters (an ending belongs to its line). `assert` that no line gets two different owners: after boundary insertion every non-final chunk ends at a line end, so this is an invariant.
3. **Records**: each relocated setting becomes `TH2TextRelocation(mpID, destinationLine: its first own line)`; each added ending becomes `TH2TextAddedEnding(ownerMPID, line: the line it terminates)`.
4. Build the map with `TH2TextLineMap.fromWriterLedger(...)` (§4.6).

`serialize` and `toBytes` keep their signatures. `toBytes` sets nothing extra; Save output is `serialize`'s output encoded.

### 4.5 Empty file

`serialize` and `serializeWithLineMap` of a file with no children produce the synthesized `encoding` line alone, owned by the file in the ledger. This only changes behavior for input that throws today.

### 4.6 `TH2TextLineMap` (`lib/src/auxiliary/th2_text_line_map.dart`)

Immutable; 0-based editor lines throughout.

- `int get lineCount`
- `int? ownerOfLine(int line)`: from a `List<int?>` indexed by line; `null` outside `0..lineCount-1` and for lines with no owner.
- `List<int> ownLinesOf(int mpID)` (sorted; empty when unknown), `int? firstOwnLineOf(int mpID)`
- `(int first, int last)? rangeOf(int mpID)`: from the first own line to the last line of the last descendant.
- `Iterable<int> get ownerMPIDs`
- `Map<int, int> get removedLines`: line → removed MPID (parser maps only; empty for writer maps).
- `List<TH2TextRelocation> get relocations`, `List<TH2TextAddedEnding> get addedEndings` (writer maps only; empty for parser maps).

Two factories:

- `fromWriterLedger({required List<int?> ownerByLine, required TH2File th2File, required List<TH2TextRelocation> relocations, required List<TH2TextAddedEnding> addedEndings})`.
- `fromParserStartLines({required Map<int, int> elementStartLines, required int lineCount, required TH2File th2File})` (§4.7). The **only** place where 1-based parser numbers become 0-based.

Ranges: for each owned line, extend the owner's range and those of its ancestors, walking `parentMPID` until the file's MPID. The walk is bounded by `mpMaxParseNestingDepth`.

`TH2TextRelocation` (`mpID`, `destinationLine`) and `TH2TextAddedEnding` (`ownerMPID`, `line`) are small immutable classes in the same file.

### 4.7 Parser map

- `TH2FileParser` gains `final LinkedHashMap<int, int> elementStartLines` (MPID → 1-based line, insertion order = file order) and `int get parsedLineCount`, both cleared at the start of `parse`. `parsedLineCount` is `lineStartOffsets(contents).length` on the decoded text, computed before `_splitContents`.
- A private `_addElement({required THElement newElement, required THIsParentMixin parent, required int childPositionInParent})` records `elementStartLines[newElement.mpID] = _currentLineNumber` and calls `executeAddElement`. The 21 call sites use it; none calls `executeAddElement` directly afterwards.
- `fromParserStartLines`:
  1. Walk the entries in order. Element *i* owns lines `start_i - 1` up to the line before the next **different** start line, the last one up to `lineCount - 1`. When several elements share a start line, the first one recorded owns it; the others own no lines (their start is still recorded). Lines before the first start (none in practice) have no owner.
  2. This derivation uses **all** recorded starts, including elements the clean-up passes removed. So continuation lines go to the element they continue, option lines to their line segment (or to the line header, before the first point), and a removed element's lines are not folded into the element before it.
  3. A line whose derived owner is no longer in `th2File` (removed directly or as a descendant) goes to `removedLines[line] = thatMPID` and gets no owner.

Load behavior does not change: nothing reads the map during a load.

### 4.8 `TH2TextElementLocator` (`lib/src/auxiliary/th2_text_element_locator.dart`)

`static TH2TextLocation locate({required int line, required TH2TextLineMap lineMap, required TH2File th2File})`. `TH2TextLocation` is a `sealed class` with:

- `TH2TextLocationSelectElement(mpID, scrapMPID)`
- `TH2TextLocationSelectLinePoint(lineMPID, lineSegmentMPID, scrapMPID)`
- `TH2TextLocationActivateScrap(scrapMPID)`
- `TH2TextLocationFileLevel()`

Steps (parent §4.4):

1. `owner = lineMap.ownerOfLine(line)`. If `null` (past the last line, a trailing empty editor line, or a removed line) → `FileLevel`.
2. If `owner == th2File.mpID` (the synthesized `encoding` line, and any separator attributed to it) → `FileLevel`. This is checked before any `elementByMPID` call, since the file's MPID names no element.
3. If the owner is a `THLineSegment` → `SelectLinePoint` with its parent line and that line's scrap. Option lines are already owned by their segment.
4. Otherwise walk up from the owner (bounded by `mpMaxParseNestingDepth`) to the first `THPoint`, `THLine`, `THArea` or `THScrap`, or the file:
   - point, line or area → `SelectElement` with its scrap. `endline`, a border reference and `endarea` arrive here through their parent. An area option line would too, but a clean parse can't produce one today (§2.3).
   - scrap → `ActivateScrap`. This covers `scrap`, `endscrap`, and comments, empty lines and multiline comments inside a scrap.
   - file → `FileLevel`.

   A point, line or area with no scrap ancestor cannot come from a valid parse; `assert` it, and return `FileLevel` in release.

The locator reads the model and changes nothing. `applyTextLocation` comes in Phase 4.

## 5. Implementation steps

Each step ends with `flutter analyze` clean in the worktree and the touched tests green; the last runs the full suite.

1. **Line endings aux and exception** (§4.1, §4.2), with their unit tests in `t3960`.
2. **Planner** (§4.3) with table-driven unit tests in `t3989`, independent of the writer.
3. **Writer refactor without the ledger**: planner-driven top level, per-setting emission, empty file, `_emit` with boundary insertion (ledger off). Run `flutter test`; the only expected failures are outputs covered by §8.2. Update those expectations explicitly, one reviewed example each.
4. **Ledger and `serializeWithLineMap`** (§4.4), `TH2TextLineMap.fromWriterLedger`, relocation and added-ending records. `t3960`, `t3961`.
5. **Parser start lines** and `fromParserStartLines` (§4.7). `t3962`.
6. **Locator** (§4.8). `t3963`.
7. Full `flutter analyze` and `flutter test`; byte comparison with the outputs captured before step 3 (§6, `t3960`); CHANGELOG entry (§8.8).

## 6. Tests

All new tests parse inline text through `parse(filename, fileBytes: …)` after `mpLocator.mpGeneralController.reset()`, as `t0100` and `t1450` do, unless they name a fixture. Unless a test says otherwise, they write with Save's options, `includeEmptyLines: true` and `useOriginalRepresentation: true` (`_encodedFileContents`). A reparse of written text parses its `toBytes` output, as a reload after Save does.

### `t3960_th2_writer_line_ledger_test.dart`

- `TH2TextLineEndingsAux`: `\n`, `\r\n`, mixed, no final ending, empty text, lone `\r` in the middle and at the end.
- For **every** fixture in `test/auxiliary/*.th2` that parses cleanly and has no lone `\r` (skip the others; assert that at least one fixture was checked), with `useOriginalRepresentation` `true` and `false`:
  - ledger spans are contiguous and cover the text exactly, including a final unterminated line;
  - every nonempty line has exactly one owner, every owner is the file or one of its elements;
  - `serializeWithLineMap` text equals `serialize` text byte for byte, and `toBytes` equals the encoded `serialize` text;
  - with `useOriginalRepresentation: true` only: parse → write → parse → write is stable (same text the second time). It isn't required with `false`: five fixtures aren't stable there because of generated-output bugs that already exist (§2.3), and the other invariants already cover the generated branches.

  Unchanged output against the old writer is checked once during implementation, not by a permanent test: before step 3 (§5), a throwaway script in the scratchpad writes every clean fixture with the `main` writer, both option values, and step 7 compares the new output byte for byte. No fixture is expected to differ (§2.3). The existing output tests (`t0100`, `t0800`, `t1450`, …) keep pinning the old output permanently.
- A command-built model with no stored text: new settings, no `encoding` line, a line long enough to wrap, line-point options with no stored text, a representable `##MAPIAH##` image next to a rotated or scaled one. Same invariants. Wrapped parts and the representable image's XTherion line are owned by their element.
- A valid model whose stored text contains a lone `\r`: `serializeWithLineMap` throws `TH2UnsupportedLineEndingException` with the right `mpID`; `serialize` returns the `\r` byte unchanged.
- A file with no children: `serialize` and `serializeWithLineMap` give the `encoding` line alone, owned by the file.

### `t3989_th2_writer_settings_section_test.dart`

- Planner unit tests: every row of the §4.3 table, plus a section with no trailing empty lines, a section of only empty lines, several later settings keeping their order, no settings, a synthesized encoding, a multiline comment inside the section and one trailing it.
- Writer tests on parsed text, through `serialize`, `toBytes` and `serializeWithLineMap`, checking **exact bytes**, `relocations` (MPIDs and destination lines) and `addedEndings`:
  - each §4.3 row with stored text, including mixed `\r\n`/`\n` endings and stored formatting;
  - generated settings mixed with stored ones, image settings, comments and empty lines inside scraps, lines and areas (never moved), a settings-looking line inside a scrap (stays a comment, no relocation), settings-looking text inside a multiline comment (unchanged);
  - an unterminated final setting that moves up gets exactly one added ending, attributed to it; an unterminated last line that stays last gets none;
  - **added image after an unterminated chunk**: load `encoding UTF-8` with no final ending, add an image through `MPCommandFactory.addImageInsertConfig` (as `t1450` does): one selected ending between the two commands, the separator owned by the encoding, the image on its own line, no relocation record. Repeat with an unterminated leading setting followed by a new image, in a file with no scraps;
  - an unterminated stored comment and an unterminated closing marker gaining following output; an empty-line element after an unterminated chunk keeps its own blank line;
  - the above with LF and CRLF `TH2File.lineEnding`, and with a `lineEnding` override; empty chunks between elements (`includeEmptyLines: false`) emit no separator; nothing is added at EOF;
  - in ledger mode, a stored chunk ending in a lone `\r` throws before a separator could turn it into `\r\n`;
  - no element emitted twice or omitted; `includeEmptyLines` and `useOriginalRepresentation` keep their meanings;
  - stability: parse → write → parse → write gives the same text, IDs, image representation and encoding, and the second write has no relocation records.

### `t3961_th2_text_line_map_test.dart`

Writer maps of handcrafted text: own lines and ranges for points, lines, line segments with option lines, areas, border references, scraps, settings, empty lines, multiline comments, wrapped long lines, multi-line values (bracketed, quoted and `\`-continued), and a final line without an ending. Reverse lookup of that final line returns its element; the line after a trailing ending has no owner. `rangeOf` a scrap spans `scrap` to `endscrap`; `rangeOf` a line spans its header to `endline`.

### `t3962_th2_parser_line_map_test.dart`

- For every clean fixture (same filter as `t3960`): parse it, write *N* with Save's options, parse *N* and build its parser map, then write that model with `serializeWithLineMap`. Text equals *N*, and both maps give the same owner for every line. Both use that model's MPIDs, so they compare directly. A disagreement is a bug to fix in this phase; if it comes from parser behavior out of scope, list the fixture in an explicit, commented exception set (expected to be empty).
- Option lines, multi-line values (all three kinds) and a final unterminated line are owned as in `t3961`.
- Removed lines: a text with a duplicate line point, a short line (with its segments) that borders an area with another border, and an empty area. Each removed element's lines are in `removedLines` with the MPID of their derived owner (for the short line's point and `endline` lines, those children's MPIDs, §3), not owned by the element before them; the surviving area still owns its remaining border line.
- Raw-text ownership of a line option moved to the header: in `line wall` / `1 1` / `subtype clay` / `2 2` / `endline`, the parser map gives the `subtype clay` line to the `1 1` segment, and `line wall` / `subtype clay` / `1 1` / … gives it to the line. The writer map of the same model has no such line (§2.3).
- `elementStartLines` has one entry per `_addElement` call; a load's resulting model is unchanged (compare `toMap()` with and without reading the map).

### `t3963_th2_text_element_locator_test.dart`

Every row of parent §3.3 that a clean parse can produce, on the writer map of one parsed text: a `point` line and its wrapped continuation; a `line` header and `endline`; a line point and each of its option lines (`smooth`, `orientation`, on a `slope` line); an `area` header, a border reference and `endarea`; `scrap`, `endscrap`, an empty line, a comment and a multiline comment inside a scrap; `encoding`, a setting, a file-level comment and empty line; a line past the end and the empty editor line after a trailing ending. Each gives the listed `TH2TextLocation` with the right MPIDs.

Plus, on a command-built model with no `encoding` element: the synthesized `encoding` line, owned by the file, gives `FileLevel` without an `elementByMPID` call on the file's MPID.

Area option lines and a `subtype` option line are not covered: a clean parse can't produce them (§2.3, §8.9).

## 7. Acceptance criteria

- `flutter analyze` clean; `flutter test` green.
- Every clean fixture writes the same bytes as before; ledger and ordinary output agree byte for byte everywhere.
- Changed Save output is limited to §8.2's documented cases, each with an explicit expected output.
- Parser and writer maps agree on every clean round-tripped fixture outside the map-agreement exception set (§6).
- No UI, localization or controller behavior changes.

## 8. Risks and notes

1. **Hidden leaf.** A text-producing path missed by `_emit` breaks the length assertion. `t3960` runs the assertion over every fixture and the command-built model, with both `useOriginalRepresentation` values, so it can't go unnoticed.
2. **Save output changes.** Intended (parent §4.16): new settings now go before the section's trailing empty lines, which can be after a section comment (the `S1, S2, E, C, E, scrap` row, as in `2025-11-28-002-line_throws_at_show_options.th2`); settings after a drawing element move up; comments and empty lines between settings are kept instead of compacted; an unterminated chunk followed by more output gets one ending instead of being concatenated. Every changed expectation is updated explicitly, never regenerated in bulk.
3. **Section ending at EOF.** The parent defines trimming trailing comments "right before" the first other element. This plan also trims them when no other element follows (`enc, S1, C` + `I` → `enc, S1, I, C`), consistent with "the section can't end in a comment". Revisit only if the user prefers the other reading.
4. **Line-point option order.** `_linePointOptionsAsString` writes options in `optionsMap` key order, not source order. If a file's unterminated last line is an option line that is not written last, the boundary rule now inserts an ending where the old writer concatenated two lines. Better than today; covered implicitly by the fixture invariants.
5. **Shared start lines.** No current injector adds two elements at one line, but the derivation handles it (first one owns the line), so Phase 2 can rely on the map without assumptions.
6. **Change to the parent plan.** `TH2TextLineEndingsAux` moves from Phase 2 to Phase 1. The parent plan's Phase 1, Phase 2 and `t3986` bullets already say so.
7. **Assertions vs throws.** The MPID, length and single-owner checks are `assert`s (debug and tests). The lone-`\r` refusal is a `throw`, because Phase 4 uses it in release.
8. **CHANGELOG.** This phase changes what Save writes, so its commit on the feature branch adds an entry, referencing #38: Save keeps comments and empty lines between settings, moves settings found later in the file up into the settings section, and ends an unterminated last line when new content is written after it. It reaches `main` only with the branch merge, after Phase 6, whose CHANGELOG work completes the same entry with text mode.
9. **Rows a parse can't produce.** Parent §3.3 used to list an area option line and `subtype` as a line-point option line; it now lists only lines a clean parse can produce. Neither occurs in the text that text mode shows (§2.3), so the locator handles both through their parent only in principle, and `t3963` doesn't test them. If the grammar later accepts area option lines, or keeps a line option on its own line, add the rows to parent §3.3 and `t3963` then.
