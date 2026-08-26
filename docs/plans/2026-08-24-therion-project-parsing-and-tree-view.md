<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing, Tree View & Text Editing — Implementation Plan

**Date:** 2026-08-24  
**Status:** Proposed

---

## 1. Overview & Goals

Mapiah has evolved from a 2D sketch/drawing canvas editor for individual `.th2` files toward a full-featured Therion project development environment. Real-world Therion cave survey projects consist of a structured hierarchy of interconnected files orchestrated by a top-level configuration file (`thconfig`).

### Core Objectives
1. **Full Project Lifecycle Support**: Allow opening, editing, saving, and managing entire Therion projects starting from a root `thconfig` file (which can have any filename or extension).
2. **Recursive Project Tree Parsing**:
   - Recursively parse the project file graph starting from `thconfig`, traversing all `source` and `input` directives across all `.th` and `.th2` files.
   - Construct a unified Abstract Syntax Tree (AST) representing both the **file hierarchy** and the **logical Therion hierarchy** (surveys, centrelines, scraps, maps, joins, equates, layouts, exports).
3. **Dedicated File Readers & Writers**:
   - **`thconfig` files**: `THConfigGrammar`, `THConfigFileParser`, and `THConfigFileWriter`.
   - **`.th` data files**: `THGrammar`, `THFileParser`, and `THFileWriter`.
   - **`.th2` drawing files**: `TH2Grammar`, `TH2FileParser`, and `TH2FileWriter`.
4. **Interactive Side Column (Project Tree View)**:
   - Present the project in a collapsible, resizable side column.
   - Provide clear visual indicators for file types, survey structures, scraps, and parse errors.
   - Enable quick navigation: clicking any node focuses its corresponding visual canvas or opens the text editor at the exact line of definition.
5. **Integrated Text Editing for `thconfig` and `.th` Files**:
   - Provide a built-in text editor with syntax highlighting, line numbers, code folding, bracket matching, and error diagnostics for `.th` and `thconfig` files.
6. **Live Auto-Parsing & Synchronization**:
   - Any text edit in a `thconfig` or `.th` file automatically triggers debounced re-parsing in the background.
   - The project tree updates in real-time, dynamically adding/removing branches, updating survey namespaces, and reflecting changes without requiring manual refresh.
   - Visual changes made in `.th2` canvas tabs update scrap references and metadata across the project.
7. **Therion Compiler Integration**:
   - Seamlessly trigger Therion compilation directly from the loaded `thconfig`.
   - Parse compiler log output and link errors directly to the source files and line numbers.

---

## 2. Therion Project Architecture & Specification

Based on the *Therion Book* (*The Therion Book*, Mudrák & Budaj), a Therion project follows precise file inclusion and hierarchical naming rules:

```
                  ┌────────────────────────┐
                  │    thconfig file       │
                  │  (entry configuration) │
                  └───────────┬────────────┘
                              │
             ┌────────────────┴────────────────┐
             │ source                          │ input
             ▼                                 ▼
   ┌───────────────────┐             ┌───────────────────┐
   │    root .th file  │             │ sub-config file   │
   └─────────┬─────────┘             └───────────────────┘
             │
      ┌──────┴─────────────────────────────────┐
      │ input                                  │ input
      ▼                                        ▼
┌───────────┐                            ┌───────────┐
│ sub .th   │ (nested surveys)           │   .th2    │ (scraps/drawings)
└─────┬─────┘                            └───────────┘
      │ input
      ▼
┌───────────┐
│   .th2    │
└───────────┘
```

### 2.1 File Types and Inclusion Semantics

| File Type | Primary Role | Inclusion Directives | Default Extension | Parser / Grammar | Writer |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`thconfig`** | Project configuration, layouts, selections, exports | `source <path>` (data source)<br>`input <path>` (config include) | `.th` for `source` | `THConfigFileParser`<br>`THConfigGrammar` | `THConfigFileWriter` |
| **`.th`** | Survey hierarchy, centrelines, maps, scraps, equates | `input <path>` (nested `.th` or `.th2`)<br>`import <path>` (3D / centerline) | `.th` if omitted | `THFileParser`<br>`THGrammar` | `THFileWriter` |
| **`.th2`** | 2D drawing data (scraps, points, lines, areas) | Included via `input <path>.th2` inside `.th` | `.th` if omitted | `TH2FileParser`<br>`TH2Grammar` | `TH2FileWriter` |

### 2.2 Key Therion Commands by Context

#### 1. Configuration (`thconfig` context)
- `source <filename>` / `source ... endsource`: Specifies survey data input files (`.th`).
- `input <filename>`: Includes other configuration files.
- `layout <id> [options] ... endlayout`: Map/atlas layout definitions.
- `select <object> [options]` / `unselect <object>`: Selects surveys or maps for export.
- `export <type> [options]`: Generates outputs (e.g. `export map -o cave.pdf`, `export model -o cave.lox`).
- `cs <coordinate-system>`, `encoding <enc>`, `language <lang>`, `maps <on/off>`, `scrap-sort <on/off>`.

#### 2. Survey Data (`.th` context)
- `survey <id> [options] ... endsurvey`: Hierarchical container with its own namespace. Sub-surveys are nested. Stations and scraps in sub-surveys use `@survey` referencing (e.g., `station@subsurvey.mainsurvey`).
- `input <filename>`: Includes sub-files (`.th` or `.th2`). Resolved relative to the directory of the file containing the `input` line.
- `centreline [options] ... endcentreline`: Contains centerline shots, survey stations, `date`, `team`, `instrument`, `calibrate`, `data`, `flags`, `fix`, `equate`, `extend`, `station-names`, etc.
- `map <id> [options] ... endmap`: Organizes scraps, other maps, or surveys for 2D/3D presentation.
- `scrap <id> [options] ... endscrap`: Can be embedded directly in `.th`, though commonly defined in `.th2`.
- `join <line1> <line2>`, `equate <st1> <st2>`, `surface`, `import <file>`, `grade`, `revise`, `require`, `encoding`.

#### 2.3 Path Resolution & Edge Case Rules
- **Relative Path Resolution**: All relative paths in `source`, `input`, and `import` directives are relative to the directory of the file in which the directive is written.
- **Default Extension**: If a path in an `input` or `source` directive has no extension, `.th` is appended by default.
- **Circular Dependency Guard**: The project resolver maintains a `Set<String>` of normalized canonical paths during recursive loading to prevent infinite loops.
- **Missing File Graceful Handling**: If an included file does not exist on disk, the parser creates a placeholder `THMissingFileNode` with error diagnostics rather than aborting project load.
- **Encoding Management**: Each file may specify `encoding <name>` on its first non-comment line. Defaults to UTF-8/ASCII.

---

## 3. Data Models & Unified Project AST

A dedicated AST and project model will represent the structure in memory:

```
THProjectNode (abstract)
 ├── THProjectFileNode (abstract)
 │    ├── THConfigFileNode (thconfig)
 │    ├── THDataFileNode (.th)
 │    ├── TH2FileNode (.th2)
 │    └── THMissingFileNode (unresolved reference)
 └── THProjectLogicalNode (abstract)
      ├── THSurveyNode (survey ... endsurvey)
      ├── THCentrelineNode (centreline ... endcentreline)
      ├── THMapNode (map ... endmap)
      ├── THScrapNode (scrap ... endscrap)
      ├── THEquateJoinNode (equate / join)
      ├── THLayoutNode (layout ... endlayout)
      └── THExportNode (export ...)
```

### 3.1 Node Definitions

```dart
/// Base class for all nodes in the project hierarchy tree.
abstract class THProjectNode {
  final String id;
  final String label;
  final String sourceFilePath;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;
  final List<THProjectNode> children = [];
  THProjectNode? parent;
  
  bool isExpanded = true;
  List<String> parseErrors = [];
  bool get hasErrors => parseErrors.isNotEmpty;
}

/// Represents a physical file in the project.
abstract class THProjectFileNode extends THProjectNode {
  final String absolutePath;
  final String relativePathToProjectRoot;
  final String encoding;
  bool isDirty = false;
  bool isLoaded = false;
}

/// Logical node for nested surveys.
class THSurveyNode extends THProjectNode {
  final String surveyId;
  final String fullNamespace;
  final String? title;
  final List<String> entrances = [];
}

/// Logical node for centrelines.
class THCentrelineNode extends THProjectNode {
  final String? centrelineId;
  final String? surveyDate;
  final List<String> team = [];
  final int shotCount;
  final int stationCount;
}

/// Logical node for 2D/3D scraps.
class THScrapNode extends THProjectNode {
  final String scrapId;
  final String projection; // plan, elevation, extended, none
  final String? scale;
  final int elementCount;
  final bool isFromTH2File;
}

/// Logical node for maps.
class THMapNode extends THProjectNode {
  final String mapId;
  final String projection;
  final List<String> referencedScrapsAndMaps = [];
}
```

---

## 4. Parser & Writer Architecture

Following the clean separation introduced in Mapiah:
- `.th2` scrap drawings: parsed by `TH2Grammar` / `TH2FileParser`, serialized by `TH2FileWriter`.
- `.th` survey data: parsed by `THGrammar` / `THFileParser`, serialized by `THFileWriter`.
- `thconfig` configuration: parsed by `THConfigGrammar` / `THConfigFileParser`, serialized by `THConfigFileWriter`.
- Project orchestration: managed by `THProjectParser` (`th_project_parser.dart`).

```
lib/src/mp_file_read_write/
 ├── grammar_utils.dart             # Shared grammar helpers
 ├── th_config_grammar.dart         # PetitParser grammar for thconfig
 ├── th_config_file_parser.dart     # Parser & AST builder for thconfig
 ├── th_config_file_writer.dart     # Writer & serializer for thconfig
 ├── th_grammar.dart                # PetitParser grammar for .th files
 ├── th_file_parser.dart            # Parser & AST builder for .th files
 ├── th_file_writer.dart            # Writer & serializer for .th files
 ├── th_project_parser.dart         # Recursive project tree loader
 ├── th2_grammar.dart               # PetitParser grammar for .th2
 ├── th2_file_parser.dart           # Parser for .th2 files
 └── th2_file_writer.dart           # Writer for .th2 files
```

### 4.1 `THConfigGrammar` Rules
- **Directives**:
  - `source`: `stringIgnoreCase('source') & thWhitespace & anyString()`
  - `multilineSource`: `stringIgnoreCase('source') & newline & ... & stringIgnoreCase('endsource')`
  - `input`: `stringIgnoreCase('input') & thWhitespace & anyString()`
  - `layout`: `stringIgnoreCase('layout') & thWhitespace & identifier & ... & stringIgnoreCase('endlayout')`
  - `export`: `stringIgnoreCase('export') & thWhitespace & identifier & ...`
  - `select` / `unselect`: `(stringIgnoreCase('select') | stringIgnoreCase('unselect')) & thWhitespace & anyString()`
  - Global options: `cs`, `encoding`, `language`, `system`, `maps`, `scrap-sort`, `sketch-warp`.
- **Comments & Continuations**: Full-line `#` comments, inline `#` comments, line continuations ending with `\`.

### 4.2 `THGrammar` (`.th` files) Rules
- **Directives**:
  - `survey`: `stringIgnoreCase('survey') & thWhitespace & identifier & ... & stringIgnoreCase('endsurvey')` (supports recursive nesting).
  - `input`: `stringIgnoreCase('input') & thWhitespace & anyString()` (auto-appends `.th` if no extension present).
  - `centreline`: `(stringIgnoreCase('centreline') | stringIgnoreCase('centerline')) & ... & (stringIgnoreCase('endcentreline') | stringIgnoreCase('endcenterline'))`.
  - `map`: `stringIgnoreCase('map') & thWhitespace & identifier & ... & stringIgnoreCase('endmap')`.
  - `scrap`: `stringIgnoreCase('scrap') & thWhitespace & identifier & ... & stringIgnoreCase('endscrap')`.
  - `join`, `equate`, `surface`, `import`, `grade`, `revise`, `require`, `encoding`.

### 4.3 Fault-Tolerant & Incremental Parsing
- When a syntax error occurs on line $N$, the parser records the error in `parseErrors` for that line/node and continues parsing subsequent lines using line-by-line fallback tokens.
- This ensures the UI tree remains populated and responsive even while the user is actively typing incomplete statements.

### 4.4 File Writers & Serialization (`THConfigFileWriter` & `THFileWriter`)

Matching the non-destructive editing philosophy established by `TH2FileWriter`:

1. **`THConfigFileWriter` (`th_config_file_writer.dart`)**:
   - Serializes configuration files while **preserving unchanged original lines, comments (`#`), line continuations (`\`), and custom formatting**.
   - Supports programmatic edits (e.g. adding a new `source` file, updating `layout` properties, configuring `export` formats or `select` commands via dialogs).
   - Generates properly encoded output (`UTF-8`, `ISO-8859-1`, etc.) respecting the file's `encoding` header and native line endings (`\n` or `\r\n`).
   - Round-trip idempotence: parsing an unmodified `thconfig` and writing it back produces byte-identical output.

2. **`THFileWriter` (`th_file_writer.dart`)**:
   - Serializes survey data files (`.th`) while **preserving unchanged lines, whitespace, comments, and centerline formatting**.
   - Supports programmatic structural changes (e.g. adding a new nested survey, inserting `input passage.th2`, modifying survey options like `-title` or `-declination`, adding scrap joins or station equates).
   - Correctly handles multi-line blocks (`survey...endsurvey`, `centreline...endcentreline`, `map...endmap`, `scrap...endscrap`).
   - Round-trip idempotence: parsing an unmodified `.th` and writing it back produces byte-identical output.

---

## 5. Project Management & State Architecture (MobX)

### 5.1 `THProjectController`
A top-level MobX controller managing project-wide state, file caching, dependency graphs, and tree updates.

```dart
class THProjectController = THProjectControllerBase with _$THProjectController;

abstract class THProjectControllerBase with Store {
  @observable
  String rootConfigPath = '';

  @observable
  THProjectNode? projectRootNode;

  @observable
  bool isParsing = false;

  @observable
  ObservableList<THProjectParseError> projectErrors = ObservableList<THProjectParseError>();

  @observable
  String? activeSelectedNodeId;

  @observable
  ObservableMap<String, String> fileContentsCache = ObservableMap<String, String>();

  /// Dependency graph: mapping from file path to set of directly included file paths.
  final Map<String, Set<String>> _fileDependencies = {};
  
  /// Reverse dependency graph: mapping from file path to files that include it.
  final Map<String, Set<String>> _reverseDependencies = {};

  @action
  Future<void> openProject(String configFilePath);

  @action
  Future<void> reloadProject();

  @action
  Future<void> reparseFile({required String filePath, required String updatedContent});

  @action
  Future<void> saveProjectFile(String filePath);

  @action
  Future<void> saveAllModifiedFiles();

  @action
  void selectNode(String nodeId);

  @action
  void closeProject();
}
```

### 5.2 Incremental Re-parsing Pipeline
When the user edits a `thconfig` or `.th` file in the text editor:
1. **Debounce (300ms)**: Wait until user pauses typing.
2. **Local Parse**: Parse the modified file string into a new `THProjectFileNode` branch using `THConfigFileParser` or `THFileParser`.
3. **Dependency Check**:
   - If `source` or `input` directives changed, re-evaluate child inclusions (load newly added files, detach removed files).
   - If survey names or scrap references changed, propagate namespace updates to dependent nodes.
4. **Reactive Tree Swap**: Replace the sub-tree in `projectRootNode` without rebuilding unmodified branches, preserving user expand/collapse states and scroll offset.

```
User keystroke in Text Editor
         │
         ▼ (Debounce 300ms)
THFileParser.parseString(updatedContent)
         │
         ▼
Update local File AST & Extract new includes / surveys
         │
         ▼
Diff with existing node & update projectRootNode in THProjectController
         │
         ▼
MobX reaction triggers incremental repaint of Project Tree Widget
```

---

## 6. User Interface & Interaction Design

### 6.1 Main Layout: Side Column Project Explorer

The main Mapiah workspace will feature a resizable split view:

```
+-------------------------------------------------------------------------------+
| App Bar: Project: my_cave.thconfig | [Run Therion] [Save All] [Settings]       |
+-------------------+-----------------------------------------------------------+
| PROJECT EXPLORER  | TAB BAR: [thconfig] [cave.th] [passage_1.th2 (Canvas)]    |
| [Search/Filter]   +-----------------------------------------------------------+
| ----------------- |                                                           |
| ▼ 📄 my_cave.cfg   | 1 | survey cave_system -title "Mammoth Cave"              |
|   ▼ 📁 source:    | 2 |   input entrance_passage.th                           |
|     ▼ 📄 cave.th  | 3 |   input chamber_a.th                                  |
|       ▼ 🏛️ cave_sys| 4 |   input maps.th                                       |
|         ▶ 📐 centre| 5 | endsurvey                                             |
|         ▼ 📄 ent.th|                                                           |
|           🖼️ p1.th2|                                                           |
|           🖼️ p2.th2|                                                           |
|   ▼ ⚙️ layouts     |                                                           |
|       🖨️ plan_pdf  |                                                           |
|   ▶ 📦 exports     |                                                           |
|                   |                                                           |
+-------------------+-----------------------------------------------------------+
| Bottom Status Bar: Line 3, Col 1 | Survey: cave_system | Status: Ready        |
+-------------------------------------------------------------------------------+
```

### 6.2 Project Tree Widget Features (`THProjectTreeWidget`)
- **Iconography**:
  - `thconfig` / `.cfg`: `Icons.settings_suggest_outlined`
  - `.th` data file: `Icons.description_outlined`
  - `.th2` drawing file: `Icons.draw_outlined` / `Icons.image_outlined`
  - Survey: `Icons.account_balance_outlined` / `Icons.folder_special_outlined`
  - Centreline: `Icons.timeline_outlined` / `Icons.straighten_outlined`
  - Scrap (Plan): `Icons.map_outlined`
  - Scrap (Extended/Elevation): `Icons.height_outlined`
  - Map: `Icons.layers_outlined`
  - Missing file / Error: `Icons.error_outline` (colored in theme error color)
- **Badges**:
  - `*` indicator for unsaved/dirty files.
  - Error/warning counts on parent nodes with issues.
- **Node Interactions**:
  - **Click on `.th2` / Scrap node**: Opens or switches to the visual canvas editor for that `.th2` file, automatically selecting the active scrap.
  - **Click on `thconfig` / `.th` node**: Opens or switches to the text editor tab.
  - **Click on a Survey / Centreline / Map child node**: Opens the containing file in the text editor and scrolls directly to that line.
  - **Right-Click Context Menu**:
    - *Open in Text Editor* / *Open in Canvas*
    - *Show in File Manager*
    - *Save File* (using `THConfigFileWriter` or `THFileWriter`)
    - *Re-parse File*
    - *Run Therion with this Config*
    - *Copy Full Survey Namespace* (e.g. `station@passage.cave`)

---

## 7. Integrated Text Editor (`THTextEditorWidget`)

### 7.1 Text Editor Capabilities
- **Syntax Highlighting**:
  - Keywords: `survey`, `endsurvey`, `centreline`, `endcentreline`, `scrap`, `endscrap`, `map`, `endmap`, `input`, `source`, `layout`, `export`, `select`, `unselect`, `join`, `equate`, `cs`, `encoding`.
  - Commands & options: `-title`, `-projection`, `-scale`, `-author`, `-copyright`, `station-names`, etc.
  - Comments: `# ...` styled with dimmed syntax color.
  - Survey station references: `station@survey.subsurvey` with highlighted `@` namespace separators.
  - Quoted strings & numbers.
- **Editor Features**:
  - Line numbers gutter with error markers.
  - Code folding for `survey...endsurvey`, `centreline...endcentreline`, `layout...endlayout`.
  - Error squiggles under syntax error tokens with hover tooltip descriptions.
  - Auto-indentation on Enter after block openings (`survey`, `centreline`, `scrap`, `map`, `layout`).
  - Standard shortcuts: `Ctrl+S` (Save via dedicated writer), `Ctrl+Z` (Undo), `Ctrl+Y` / `Ctrl+Shift+Z` (Redo — both provided for free by the text field's built-in editing stack). `Ctrl+F` (single-file Find/Replace) is a Phase 5 follow-up rather than part of the initial Phase 5 increment; searching across multiple project files is its own Phase 9.
  - Quick Go-To Definition: `Ctrl+Click` on `input filename` opens that file immediately.

---

## 8. Therion Compiler Integration & Diagnostics

1. **Current infrastructure use**:
   - Current infrastructure for Therion compilation will be reusued as much as possible to minimize behaviour changes.
2. **Compilation Action**:
   - `Run Therion` action button in the toolbar and shortcut (`Ctrl+R` / `F5`).
   - Automatically uses the currently loaded `thconfig` path.
3. **Compiler Log Parsing**:
   - Captures `stdout` / `stderr` and Therion `therion.log`.
   - Parses Therion diagnostic lines (e.g., `therion: error -- filename.th [line 42] -- syntax error`).
   - Annotates corresponding nodes in the Project Tree with error badges.
   - Highlights the error line in the Text Editor / Canvas.
4. **Artifact Output Detection**:
   - Inspects `export` statements in `thconfig` to locate generated PDF/SVG/LOX files.
   - Provides quick "Open Output PDF" button upon successful compilation.


---

## 9. Implementation Roadmap & Phases

```
Phase 1: Grammars, Parsers & Writers (thconfig, .th)
   │
   ▼
Phase 2: Recursive Project Tree Loader (THProjectParser) & Dependency Graph
   │
   ▼
Phase 3: MobX Project State Controller (THProjectController) & Incremental Re-parsing
   │
   ▼
Phase 4: Side Column Project Tree View UI (THProjectTreeWidget)
   │
   ▼
Phase 5: Integrated Text Editor (THTextEditorWidget) with Syntax Highlighting & Linting
   │
   ▼
Phase 6: Multi-Tab Integration (Canvas + Text Editor) & Navigation
   │
   ▼
Phase 7: Therion Run Diagnostics & Error Linking
   │
   ▼
Phase 8: Help Pages, Keyboard Shortcuts, Localization (EN/PT) & Tests
   │
   ▼
Phase 9: Multi-File Find/Replace
```

Phase 9 depends only on Phase 6 (it needs `MPGeneralController` managing multiple open text-editor tabs to have files to search across); it's numbered last because the need for it only became concrete after Phase 8 was already planned, not because it depends on Phases 7-8.

### Phase 1: Core Grammars, Parsers & Writers
- Implement `THConfigGrammar`, `THConfigFileParser`, and `THConfigFileWriter`.
- Implement `THGrammar`, `THFileParser`, and `THFileWriter` for `.th` files (preserving comments and unchanged lines).
- Build unit test suite for all Therion directives, nested surveys, comments, options, and round-trip serialization.

### Phase 2: Dependency Graph & Recursive Project Loader
- Implement `THProjectParser` with relative path resolution, default `.th` extensions, and cycle detection.
- Model `THProjectNode`, `THConfigFileNode`, `THDataFileNode`, `TH2FileNode`, `THSurveyNode`, `THScrapNode`, `THMapNode`.
- Test on real-world multi-file Therion projects.

### Phase 3: MobX State Management & Live Re-parsing
- Create `THProjectController` with reactive observables and actions.
- Implement debounced single-file re-parsing and incremental AST splicing.
- Wire into `MPLocator` and `MPGeneralController`.

### Phase 4: UI Project Tree Side Column
- Build `THProjectTreeWidget` with collapsible tree view, node icons, dirty badges, and search filtering.
- Implement resizable split layout with sidebar collapse/expand toggle.

### Phase 5: Integrated Text Editor
- Build `THTextEditorWidget` with custom syntax highlighter, line numbers, error markers, and code folding.
- Wire keystroke events to debounced re-parsing in `THProjectController` and Save actions to `THConfigFileWriter` / `THFileWriter`.

### Phase 6: Deep Integration & Tab Management
- Extend `MPGeneralController` to support both `TH2FileCanvasTab` and `THTextEditorTab`.
- Implement seamless cross-navigation: Project Tree ↔ Text Editor ↔ Canvas Editor.

### Phase 7: Compiler Diagnostics & Runner Integration
- Connect `Run Therion` to project root `thconfig`.
- Parse Therion compiler error messages and map them back to tree nodes and editor lines.

### Phase 8: Localization, Documentation & Testing
- Add localized strings to `lib/l10n/app_en.arb` and `lib/l10n/app_pt.arb`.
- Update help pages (`assets/help/en/`, `assets/help/pt/`) and keyboard shortcuts tables.
- Write comprehensive test suites (unit, widget, and integration tests).

### Phase 9: Multi-File Find/Replace
- Search across every open `THTextEditorController` (and, optionally, every `thconfig`/`.th` file in the project tree, not just currently-open tabs) for a query, with results grouped by file and a jump-to-match action that opens/focuses the right tab at the right line.
- Project-wide "Replace All" that writes through each affected file's `THTextEditorController.setContent`/`save`, respecting the same debounce and dirty-tracking semantics as a single-file edit — no bespoke multi-file write path.
- Builds on the single-file find/replace shipped as a Phase 5 follow-up (§7.1): reuses its match-computation and highlight rendering per file rather than a separate implementation.
- Depends on Phase 6 for multiple simultaneously-open text-editor tabs to search across.

---

## 10. Testing Strategy

1. **Grammar & Parser Unit Tests**:
   - `test/t1300_th_config_parser_test.dart`: Parsing valid/invalid `thconfig` commands, multi-line `source ... endsource`, `layout`, `export`.
   - `test/t1301_th_data_parser_test.dart`: Parsing nested surveys, namespaces, centrelines, maps, equates, joins, scrap headers using `THGrammar` and `THFileParser`.
   - `test/t1302_project_dependency_graph_test.dart`: Circular include handling, relative path resolution, missing files.
2. **File Writer & Round-Trip Tests**:
   - `test/t1310_th_config_file_writer_test.dart`: Verifying formatting preservation, encoding headers, round-trip idempotence on `thconfig` files.
   - `test/t1311_th_file_writer_test.dart`: Verifying comments/whitespace preservation, survey nesting, centerline formatting, and round-trip idempotence on `.th` files.
3. **Incremental Re-parsing Tests**:
   - `test/t1320_project_incremental_reparse_test.dart`: Verifying AST updates after text modifications without re-reading unchanged files from disk.
4. **UI & Controller Tests**:
   - `test/t1330_th_project_controller_test.dart`: MobX reactions, active node selection, file tab opening, save operations.
   - `test/t1331_th_project_tree_widget_test.dart`: Tree rendering, node expansion, click handling.
   - `test/t1332_th_text_editor_widget_test.dart`: Syntax highlighting, error squiggles, shortcut triggers.
