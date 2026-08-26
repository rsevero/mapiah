<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 5: Integrated Text Editor — Implementation Plan

**Date:** 2026-08-24
**Status:** Implemented

---

## 1. Overview & Objectives

This document details **Phase 5** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It builds on:

- **Phase 1** — `thconfig` and `.th` grammars, parsers, and lossless writers.
- **Phase 2** — `THProjectParser`, the `THProjectNode` model family, and project dependency graph.
- **Phase 3** — `THProjectController`, including `fileContentsCache`, debounced `reparseFile`, `saveProjectFile`, and project parse errors.
- **Phase 4** — the project-tree sidebar, `THProjectTreeUIController`, and `.th2` node activation.

Phase 5 adds the first integrated text-editing layer for **`thconfig` and `.th` files**: a syntax-highlighting editor with line numbers, parse-error markers, bracket matching, and basic code folding. It is deliberately a *standalone editor widget plus a controller* and does **not** yet unify text-editor tabs with canvas tabs in `MPGeneralController`; that cross-navigation work is Phase 6.

### Key Objectives

1. **`THTextEditorController`**: A MobX store owning the file path, current text, dirty state, debounce timers, cursor/scroll position, diagnostics, and computed fold regions.
2. **`THTextEditorWidget`**: A reusable editor surface for one `thconfig` or `.th` file, composed of a line-number gutter, editable text area, syntax highlighting, error markers, bracket-match highlighting, and fold controls.
3. **Syntax highlighting**: Keyword, directive, option, comment, string, number, and station-reference coloring, implemented without a new code-editor dependency.
4. **Live re-parsing**: Debounced text edits call `THProjectController.reparseFile`, so the project tree updates in the background.
5. **Save integration**: `Ctrl/Cmd+S` and an explicit save action call `THProjectController.saveProjectFile`; `.th2` files are excluded from this editor.
6. **Diagnostics display**: `THProjectParseError` entries attached to the edited file are rendered as line markers and/or squiggle regions.

### Explicit Non-Goals

- **No multi-tab integration**: Phase 5 does not add a second tab type to `MPGeneralController`; that is Phase 6.
- **No `.th2` text editing**: Canvas files continue to use `TH2FileEditController`.
- **No Therion compiler log linking**: Therion output diagnostics are Phase 7.
- **No find/replace of any kind in this increment**: single-file find/replace is a Phase 5 follow-up (§13); multi-file search across the project is deferred to its own later phase (see the top-level roadmap's Phase 9).
- **No LSP/IntelliSense**, type checking, or semantic analysis beyond the existing parser diagnostics.

---

## 2. Grounding: Current State

Verified against the codebase:

- There is **no existing `THTextEditorWidget`** or code-editor dependency. `pubspec.yaml` includes no syntax-highlighting package such as `flutter_code_editor` or `re_editor`.
- `THProjectController` already exposes:
  - `fileContentsCache` — canonical path to last-known `thconfig`/`.th` text.
  - `reparseFile({required String filePath, required String updatedContent})` — debounced single-file re-parse.
  - `saveProjectFile(String filePath)` — saves `thconfig`/`.th` via `THConfigFileWriter`/`THFileWriter`.
  - `projectErrors` — tree-attached and project-level parse diagnostics.
  - `nodeByCanonicalPath`, `selectNode`, and `activeSelectedNodeId`.
- `THProjectParser` exposes `readFileContent` and `parseFileContent`, but the editor should normally read the already-cached content through `THProjectController.fileContentsCache` and let `reparseFile` update the tree.
- `THConfigFileWriter` and `THFileWriter` are lossless for unchanged content. `saveProjectFile` already branches on file type: `.th2` paths delegate to `TH2FileEditController.saveTH2File()`, while `THConfigFileNode`/`THDataFileNode` paths are serialized via `THConfigFileWriter`/`THFileWriter`. Phase 5's editor only ever calls `saveProjectFile` with `thconfig`/`.th` paths, so only the latter branch is exercised.
- `THProjectTreeWidget` already renders file nodes and `.th2` node clicks open canvas tabs. Phase 5 will later be wired into non-`.th2` node clicks in Phase 6; Phase 5 itself only needs a callable editor surface.
- Test numbering for `th_project` currently runs through `t3884`. Phase 5 tests start at `t3900`.

---

## 3. File Organization & Architecture

```
lib/src/
 ├── controllers/
 │    ├── th_text_editor_controller.dart      # New: MobX editor state
 │    └── th_text_editor_controller.g.dart    # Generated
 ├── auxiliary/
 │    ├── th_text_editor_syntax_highlighter.dart # New: pure line/token classifier
 │    └── th_text_editor_fold_aux.dart            # New: pure fold-region builder
 ├── constants/
 │    └── mp_constants.dart                   # Existing: gains editor metrics/debounce
 ├── elements/th_project/                     # Existing, read-only
 └── widgets/
      ├── th_text_editor_widget.dart           # New: editor surface
      ├── th_text_editor_line_number_gutter_widget.dart # New
      └── th_text_editor_diagnostic_marker_widget.dart  # New
```

`THTextEditorController` is a UI/data bridge, not a replacement for `THProjectController`. It owns only what is meaningful inside one editor instance: current text, cursor, fold state, debounce timer, and diagnostics snapshot. Parsing/tree mutation remains with `THProjectController`.

---

## 4. `THTextEditorController` Public Surface

```dart
class THTextEditorController = THTextEditorControllerBase
    with _$THTextEditorController;

abstract class THTextEditorControllerBase with Store {
  @observable
  String canonicalPath = '';

  @observable
  String content = '';

  @observable
  bool isDirty = false;

  @observable
  bool isLoading = false;

  @observable
  int cursorLine = 0;

  @observable
  int cursorColumn = 0;

  @observable
  ObservableSet<int> collapsedFoldStarts =
      ObservableSet<int>();

  @observable
  ObservableList<THProjectParseError> diagnostics =
      ObservableList<THProjectParseError>();

  Timer? _reparseTimer;

  @action
  Future<void> loadFile(String filePath);

  @action
  void setContent(String newContent);

  @action
  void setCursorPosition({required int line, required int column});

  @action
  void toggleFold(int startLine);

  @action
  Future<void> save();

  @action
  Future<void> revert();

  void dispose();
}
```

### 4.1 Loading

1. Canonicalize `filePath` with `THProjectPathResolver.canonicalize(p.absolute(filePath))`.
2. Set `canonicalPath` and `isLoading = true`.
3. Prefer `mpLocator.thProjectController.fileContentsCache[canonicalPath]`. If absent, read via `THProjectParser.readFileContent`.
4. Set `content`, reset cursor to `0:0`, rebuild diagnostics from `THProjectController.projectErrors` filtered by `filePath`, and clear fold state.
5. Set `isLoading = false`.

### 4.2 Editing and Debounced Reparse

`setContent` is called on every keystroke:

1. Update `content` and `isDirty`.
2. Cancel `_reparseTimer`.
3. Start a timer with `mpTextEditorReparseDebounceMilliseconds`.
4. On timer expiry, call:

```dart
mpLocator.thProjectController.reparseFile(
  filePath: canonicalPath,
  updatedContent: content,
);
```

The editor does not wait for the re-parse before updating its own text. This matches the existing Phase 3 debounce pattern.

### 4.3 Saving and Reverting

- `save()` calls `THProjectController.saveProjectFile(canonicalPath)`, then clears `isDirty` only if the controller confirms the file is no longer in `dirtyFilePaths`.
- `revert()` reloads the last cached content and clears local dirty state.

### 4.4 Diagnostics Refresh

After a re-parse, the controller observes `THProjectController.projectErrors` and copies only diagnostics whose `filePath == canonicalPath`. Parse errors are immutable value objects, so this can be a plain `where` filter during the widget build.

---

## 5. Syntax Highlighting

Use a pure `th_text_editor_syntax_highlighter.dart` helper:

```dart
class THTextEditorToken {
  final int start;
  final int end;
  final THTextEditorTokenType type;
}

enum THTextEditorTokenType {
  keyword,
  directive,
  option,
  comment,
  string,
  number,
  stationReference,
  punctuation,
  plain,
}

List<THTextEditorToken> tokenizeTherionText(String text);
```

Rules, ordered for specificity:

1. `#...` to end of line is a comment.
2. Single- or double-quoted strings are strings.
3. Numbers with optional decimal/exponent are numbers.
4. `@`-containing station references such as `station@cave.passage` are station references.
5. Known block/end keywords are keywords:
   `survey`, `endsurvey`, `centreline`, `endcentreline`, `map`, `endmap`, `scrap`, `endscrap`, `layout`, `endlayout`, `input`, `source`, `select`, `unselect`, `export`, `join`, `equate`, `cs`, `encoding`.
6. Tokens starting with `-` followed by an identifier are options.
7. Other non-whitespace text is plain.

The tokenizer is deliberately lexical, not a second grammar. It only needs to color the editor; the real parser remains authoritative for errors and tree updates.

### 5.1 Rendering Approach

`THTextEditorWidget` renders a `Stack`:

- Bottom layer: a monospaced `TextField` with a transparent foreground and the same controller/font metrics.
- Top layer: an `IgnorePointer` `RichText` built from `tokenizeTherionText(content)`, aligned to the same scroll offset and line metrics.
- Left: `THTextEditorLineNumberGutterWidget`, synchronized with the editor scroll controller.
- Right/overlay: diagnostic markers and fold toggles.

All sizes/font metrics use constants from `mp_constants.dart`.

---

## 6. Line Numbers, Folding, and Diagnostics

### 6.1 Line Number Gutter

- One number per logical line, padded to the width of the longest visible line number.
- Current-line number is highlighted.
- Gutter markers are shown for lines with diagnostics.
- The gutter scrolls in lock-step with the text area.

### 6.2 Code Folding

`th_text_editor_fold_aux.dart` builds pure fold regions:

```dart
class THTextEditorFoldRegion {
  final int startLine;
  final int endLine; // inclusive
}

List<THTextEditorFoldRegion> buildFoldRegions(String content);
```

The initial implementation folds only balanced block pairs:

- `survey ... endsurvey`
- `centreline ... endcentreline`
- `map ... endmap`
- `scrap ... endscrap`
- `layout ... endlayout`

It uses a line scanner with a stack and does not attempt indentation-based folding. Collapsed regions are replaced visually by a single placeholder line; the underlying text remains unchanged.

### 6.3 Diagnostics

- Parse errors from `THProjectParseError` are mapped to `lineNumber - 1` for zero-based rendering.
- The gutter shows an error dot.
- A squiggle span is drawn under the affected token when a column range is available; otherwise the whole line gets an error background/underline.
- Hovering a marker shows the parse-error message.

---

## 7. Editor Actions & Shortcuts

Phase 5 implements:

| Shortcut | Action |
| :--- | :--- |
| `Ctrl/Cmd+S` | Save current file |
| `Ctrl/Cmd+Z` | Undo text edit |
| `Ctrl/Cmd+Y` / `Ctrl/Cmd+Shift+Z` | Redo text edit |
| `Tab` / `Shift+Tab` | Indent / outdent selection |
| `Enter` after a block-opening keyword | Basic auto-indent |

Undo/redo is provided by the text field's built-in editing stack, not the `MPUndoRedoController` used by canvas commands, and needed no extra implementation: Flutter's default `Shortcuts`/`Actions` bindings already give a multiline `TextField` working `Ctrl/Cmd+Z`/`Ctrl/Cmd+Y`/`Ctrl/Cmd+Shift+Z`. This keeps Phase 5 text editing isolated from canvas command semantics.

`Ctrl/Cmd+F` (single-file find/replace) was cut from this increment; it ships as the Phase 5 follow-up in §13.

---

## 8. Integration Boundary

- **Input**: a canonical `thconfig`/`.th` path and a `THProjectFileNode` (or node id) from the project tree.
- **Output**: `THProjectController` gets updated content through `reparseFile`, saves through `saveProjectFile`, and project-tree diagnostics update through `projectErrors`.
- **Not integrated in Phase 5**: `MPGeneralController` tab creation, keyboard focus routing between canvas and text editors, and tree-node click navigation for non-`.th2` nodes.

This boundary is intentionally narrow so Phase 6 can wrap `THTextEditorWidget` in a text tab without redesigning the editor.

---

## 9. Step-by-Step Implementation Sequence

```
Step 1: Add constants and pure syntax tokenizer
   │
   ▼
Step 2: Add pure fold-region builder
   │
   ▼
Step 3: Implement THTextEditorController + locator accessor
   │
   ▼
Step 4: Build line-number gutter and diagnostic markers
   │
   ▼
Step 5: Build THTextEditorWidget with syntax overlay and folding
   │
   ▼
Step 6: Wire debounced reparseFile and saveProjectFile
   │
   ▼
Step 7: Add localized editor strings
   │
   ▼
Step 8: Unit and widget tests
   │
   ▼
Step 9: flutter analyze / flutter test
```

---

## 10. Test Plan

Test numbering continues at `t3900`:

| Test file | Coverage |
| :--- | :--- |
| `test/t3900_th_text_editor_syntax_highlighter_test.dart` | Tokenizer classification for keywords, directives, options, comments, strings, numbers, station references, and multi-line input. |
| `test/t3901_th_text_editor_fold_aux_test.dart` | Balanced block folding, nested blocks, unterminated blocks, and empty input. |
| `test/t3902_th_text_editor_controller_test.dart` | Load from cache/disk, dirty tracking, debounced reparse, save, revert, cursor state, and diagnostics filtering. |
| `test/t3903_th_text_editor_widget_test.dart` | Widget rendering, line numbers, syntax overlay, fold toggle placeholder, error marker, save shortcut, and reparse trigger. |
| `test/t3904_th_text_editor_diagnostics_test.dart` | Parse errors from `THProjectController` appear as gutter/squiggle markers and disappear after successful re-parse. |

Representative scenarios:

1. **Highlighting stays lexical**: a malformed line still receives syntax colors while parse diagnostics are reported separately.
2. **Debounced reparse**: rapid edits collapse into one `reparseFile` call.
3. **Save only writable nodes**: `.th2` files are rejected or ignored.
4. **Fold regions do not mutate text**: expanding a folded block restores the original content exactly.
5. **Diagnostics line mapping**: one-based `THProjectParseError.lineNumber` maps to the correct zero-based editor line.

---

## 11. Localization & Documentation Touches

- Add EN/PT strings for editor-related labels: save, revert, fold, error tooltip, and any find/replace labels.
- No all-caps UI text.
- Help pages and keyboard-shortcut tables remain deferred to Phase 8, per the top-level roadmap.

---

## 12. Risks & Open Questions

1. **Syntax overlay alignment**: `TextField` and `RichText` metrics can drift across platforms/fonts. Mitigation: use the same `TextStyle`, `textScaleFactor`, `strutStyle`, and padding, and add golden/widget tests at several surface sizes.
2. **Code folding complexity in a raw `TextField`**: replacing collapsed ranges with placeholders can complicate cursor/selection math. Mitigation: keep fold regions pure and initially fold only at block boundaries; if the UX becomes fragile, defer visual folding and expose fold-region data only.
3. **Reparse feedback loops**: editor changes trigger re-parse, which can rebuild diagnostics and potentially update `fileContentsCache`. Mitigation: the editor never overwrites its own `TextEditingController` from re-parse output while it owns focus; it only refreshes diagnostics.
4. **Large files**: tokenizing the entire text on every frame is expensive. Mitigation: tokenize on a debounced content snapshot and cache tokens keyed by `content`; optional incremental tokenization can be added later.

---

## 13. Follow-up: Single-File Find/Replace

Cut from the initial Phase 5 increment to keep it reviewable; scoped here so it can be picked up without re-deriving the design. Single-file only — it operates on one already-open `THTextEditorWidget`/`THTextEditorController` pair. Searching across multiple project files is a separate, later phase (see the top-level roadmap's Phase 9, added alongside this note).

### 13.1 Controller additions (`THTextEditorController`)

```dart
@observable
String findQuery = '';

@observable
String replaceQuery = '';

@observable
bool findCaseSensitive = false;

@observable
bool isFindBarVisible = false;

@observable
int? activeMatchIndex;

@computed
List<TextRange> get findMatches; // computed from content + findQuery + findCaseSensitive

@action
void openFindBar();

@action
void closeFindBar();

@action
void findNext();

@action
void findPrevious();

@action
void replaceActiveMatch();

@action
void replaceAllMatches();
```

`findMatches` is a plain substring/case-fold scan over `content` — no regex in this increment. Replacing mutates `content` through the existing `setContent` path, so a replace is indistinguishable from a normal edit to the rest of the controller (same debounce, same dirty tracking).

### 13.2 Widget additions (`THTextEditorWidget`)

- `Ctrl/Cmd+F` opens an in-editor find bar (a `Row` overlay pinned above the text area, not a dialog), with a query field, case-sensitivity toggle, match-count label (`3/12`), next/previous buttons, and `Esc` to close.
- An optional replace field (revealed by an expand affordance) with "Replace" and "Replace All" buttons.
- Matches are highlighted in the syntax overlay (an additional `TextSpan` background color layered under the syntax color, keyed off `findMatches`), with the active match visually distinguished from the rest.
- `findNext`/`findPrevious` also move the `TextField`'s selection/scroll to the active match.

### 13.3 Test plan

`test/t3905_th_text_editor_find_replace_test.dart` (continuing the Phase 5 numbering):
- `findMatches` computation: case-sensitive/insensitive, overlapping-free matches, empty query, no matches, query longer than content.
- `findNext`/`findPrevious` wrap around at the ends of the match list.
- `replaceActiveMatch` replaces only the active match and re-syncs `findMatches` against the new content.
- `replaceAllMatches` replaces every match in one `setContent` call (not one call per match, to keep a single debounced reparse).
- Widget test: `Ctrl/Cmd+F` opens the find bar, typing filters matches, `Esc` closes it.

### 13.4 Non-goals (kept from Phase 5)

- No regex search.
- No search across files — that's the multi-file phase.
- No persisted find-bar state across editor sessions.
