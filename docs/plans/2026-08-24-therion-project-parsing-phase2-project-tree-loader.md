<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 2: Recursive Project Tree Loader & Dependency Graph — Implementation Plan

**Date:** 2026-08-24
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 2** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](file:///devel/mapiah/docs/plans/2026-08-24-therion-project-parsing-and-tree-view.md), following on from [Phase 1: Grammars, Parsers & Writers](file:///devel/mapiah/docs/plans/2026-08-24-therion-project-parsing-phase1-parsers-and-writers.md), which is implemented (`THConfigGrammar`/`THConfigFileParser`/`THConfigFileWriter` for `thconfig`, `THGrammar`/`THFileParser`/`THFileWriter` for `.th`, both under `lib/src/mp_file_read_write/`, with data models under `lib/src/elements/th_config/` and `lib/src/elements/th_data/`).

Phase 2 builds the layer that turns a single parsed `thconfig`/`.th` file into a **whole project**: recursively resolving `source`/`input`/`import` directives across disk, building a unified project tree (file nodes + logical Therion nodes), and doing so safely — cycle-free, tolerant of missing files, with correct relative-path and default-extension resolution.

Phase 2 is a pure data/model layer: no MobX controller, no UI. Those come in Phase 3 (`THProjectController`) and Phase 4 (`THProjectTreeWidget`), which will consume the `THProjectParser` output built here.

### Key Objectives
1. **`THProjectNode` Model Family**: file nodes (`THConfigFileNode`, `THDataFileNode`, `TH2FileNode`, `THMissingFileNode`) and logical nodes (`THSurveyNode`, `THCentrelineNode`, `THMapNode`, `THScrapNode`) as described in [the roadmap, §3](file:///devel/mapiah/docs/plans/2026-08-24-therion-project-parsing-and-tree-view.md).
2. **`THProjectParser`**: recursively loads a project starting from a root `thconfig` (or root `.th`) file, reusing `THConfigFileParser`/`THFileParser` for each file it reads, and assembles the file-hierarchy tree plus the logical-hierarchy tree (surveys/centrelines/maps/scraps).
3. **Dependency Graph**: forward (`file → files it includes`) and reverse (`file → files that include it`) maps, built while loading, for later use by Phase 3's incremental re-parsing.
4. **Path Resolution Rules**: relative-to-including-file resolution, default `.th` extension when omitted (already available via `THDataInput.resolvedPath`; `THConfigSource`/`THConfigInput` need the equivalent), and platform-safe path joining.
5. **Cycle Detection**: a `Set<String>` of canonical absolute paths tracked during recursion; a repeated path is not re-parsed but is linked to the already-existing node and recorded as a non-fatal `THProjectParseError`.
6. **Missing File Handling**: unresolved `source`/`input`/`import` targets produce a `THMissingFileNode` (or an `import` error entry) with a diagnostic, and loading continues.
7. **`.th2` File Linking (No New Parsing Logic)**: `.th2` files referenced via `input` in a `.th` file are represented as `TH2FileNode` leaves; Phase 2 does not parse their contents (that's the existing `TH2FileParser`, invoked lazily when a tab is opened in Phase 6) — it only records their resolved path and existence.

---

## 2. File Organization & Architecture

```
lib/src/
 ├── elements/
 │    └── th_project/                       # New: project tree data models
 │         ├── th_project_node.dart          # THProjectNode (abstract base)
 │         ├── th_project_file_node.dart     # THProjectFileNode (abstract)
 │         ├── th_config_file_node.dart      # THConfigFileNode
 │         ├── th_data_file_node.dart        # THDataFileNode
 │         ├── th2_file_node.dart            # TH2FileNode
 │         ├── th_missing_file_node.dart     # THMissingFileNode
 │         ├── th_survey_node.dart           # THSurveyNode
 │         ├── th_centreline_node.dart       # THCentrelineNode
 │         ├── th_map_node.dart              # THMapNode
 │         ├── th_scrap_node.dart            # THScrapNode
 │         └── th_project_parse_error.dart   # THProjectParseError
 └── mp_file_read_write/
      ├── th_config_grammar.dart             # Existing (Phase 1)
      ├── th_config_file_parser.dart         # Existing (Phase 1)
      ├── th_config_file_writer.dart         # Existing (Phase 1)
      ├── th_grammar.dart                    # Existing (Phase 1)
      ├── th_file_parser.dart                # Existing (Phase 1)
      ├── th_file_writer.dart                # Existing (Phase 1)
      ├── th_project_path_resolver.dart      # New: shared path-resolution helpers
      └── th_project_parser.dart             # New: recursive project tree loader
```

`th_project_path_resolver.dart` is factored out as its own file (rather than folded into `th_project_parser.dart`) because both `THProjectParser` and, later, Phase 3's incremental re-parser need identical relative-path/default-extension logic, and because `THConfigSource`/`THConfigInput`/`THDataInput`/`THImport` all need consistent "resolve against including file" behaviour.

---

## 3. Data Models (`lib/src/elements/th_project/`)

### 3.1 `THProjectNode` (abstract base)

```dart
/// Base class for every node in the project hierarchy tree (file nodes and
/// logical Therion nodes alike).
abstract class THProjectNode {
  final String id; // stable synthetic id, e.g. 'file:<absolutePath>' or 'survey:<absolutePath>:<lineNumber>'
  final String label;

  /// Absolute path of the file this node's definition lives in.
  final String sourceFilePath;

  final int lineNumber;

  final List<THProjectNode> children = <THProjectNode>[];
  THProjectNode? parent;

  final List<THProjectParseError> parseErrors = <THProjectParseError>[];
  bool get hasErrors => parseErrors.isNotEmpty;

  THProjectNode({
    required this.id,
    required this.label,
    required this.sourceFilePath,
    required this.lineNumber,
  });

  void addChild(THProjectNode child) {
    child.parent = this;
    children.add(child);
  }
}
```

Notes vs. the roadmap's sketch (§3.1):
- `isExpanded` is dropped from the model — expand/collapse state is UI-only and belongs to `THProjectTreeWidget` state in Phase 4, keyed by `id`, not to the parsed tree (which Phase 3 will rebuild/splice on every re-parse).
- `startColumn`/`endColumn`/`endLine` are dropped; nothing in Phase 1's data models tracks column or block-end position (`THSurvey.endLine` is the *raw closing-line text*, not a position). Only `lineNumber` (the definition line) is needed for "click node → scroll editor to line" in Phase 4/6. If block-range highlighting is wanted later, it can be added then without disturbing this model.
- `parseErrors` uses a small `THProjectParseError` type (message + severity) rather than bare `String`, so the tree widget can distinguish errors from warnings when rendering badges (§6.2 of the roadmap).

### 3.2 `THProjectFileNode` (abstract) and concrete file nodes

```dart
abstract class THProjectFileNode extends THProjectNode {
  final String absolutePath;
  final String relativePathToProjectRoot;
  final String encoding;
  bool isLoaded;

  THProjectFileNode({
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
    required this.absolutePath,
    required this.relativePathToProjectRoot,
    required this.encoding,
    this.isLoaded = false,
  });
}

class THConfigFileNode extends THProjectFileNode {
  final THConfigFile configFile;
  THConfigFileNode({required this.configFile, /* ...super params */});
}

class THDataFileNode extends THProjectFileNode {
  final THDataFile dataFile;
  THDataFileNode({required this.dataFile, /* ...super params */});
}

class TH2FileNode extends THProjectFileNode {
  // Content is not parsed by THProjectParser; TH2FileParser runs lazily
  // (Phase 6) when the file is opened in a canvas tab.
  TH2FileNode({/* ...super params */});
}

class THMissingFileNode extends THProjectFileNode {
  final String requestedPath; // the raw, unresolved path as written in the source directive
  THMissingFileNode({required this.requestedPath, /* ...super params */})
    : super(isLoaded: false);
}
```

`isDirty` (present in the roadmap's `THProjectFileNode` sketch) is dropped here: dirty/unsaved-changes tracking is editor state that belongs to Phase 3's `THProjectController` (one file can be open and dirty while its project node is regenerated independently), not to the static parse-time model built in Phase 2.

`configFile` / `dataFile` embed the actual Phase 1 model (`THConfigFile` / `THDataFile`) directly, so `THProjectParser` doesn't need to duplicate any data already captured by `THConfigFileParser`/`THFileParser` — it only adds tree structure and cross-file links on top.

### 3.3 Logical nodes

```dart
class THSurveyNode extends THProjectNode {
  final THSurvey survey;       // the underlying Phase 1 element
  final String fullNamespace;  // e.g. 'passage.cave', computed from ancestor THSurveyNodes
  THSurveyNode({required this.survey, required this.fullNamespace, /* ... */});
}

class THCentrelineNode extends THProjectNode {
  final THCentreline centreline;
  THCentrelineNode({required this.centreline, /* ... */});
}

class THMapNode extends THProjectNode {
  final THMap map;
  THMapNode({required this.map, /* ... */});
}

class THScrapNode extends THProjectNode {
  final String scrapId;
  final bool isFromTH2File; // true if defined via a linked .th2 file, false if inline in a .th file
  THScrapNode({required this.scrapId, required this.isFromTH2File, /* ... */});
}
```

Each logical node wraps the corresponding Phase 1 element (`THSurvey`, `THCentreline`, `THMap`) instead of re-declaring fields like `title`, `team`, `projection`: those already exist on the wrapped element (`THSurvey.title`, `THSurvey.parsedOptions`, etc.), and duplicating them would create a second, driftable source of truth. `THScrapNode` is the one exception — Phase 1 has no `THScrap`-in-`.th` element yet (inline `scrap...endscrap` in `.th` files is represented via `th_inline_scrap.dart`; scraps embedded in `.th2` files are the existing canvas `THScrap` from `lib/src/elements/`), so `THScrapNode` only carries the minimal identifying fields needed for the tree (id, whether it came from a `.th2` file). Enriching `THScrapNode` with element counts / projection / scale is deferred to Phase 4 once the tree widget's actual display needs are known, to avoid speculative fields.

### 3.4 `THProjectParseError`

```dart
enum THProjectParseErrorSeverity { warning, error }

class THProjectParseError {
  final String message;
  final THProjectParseErrorSeverity severity;
  final String filePath;
  final int lineNumber;

  const THProjectParseError({
    required this.message,
    required this.severity,
    required this.filePath,
    required this.lineNumber,
  });
}
```

Used for: missing files (`error`), cyclic includes (`warning` — the tree still degrades gracefully by linking to the already-loaded node), and any `parseErrors` already collected by `THConfigFile`/`THDataFile` during Phase 1 parsing, surfaced up onto the owning file node.

---

## 4. `THProjectPathResolver` (`lib/src/mp_file_read_write/th_project_path_resolver.dart`)

```dart
class THProjectPathResolver {
  /// Resolves [rawPath] (as written in a source/input/import directive)
  /// against the directory of [includingFileAbsolutePath], applying
  /// [defaultExtension] (e.g. '.th') when rawPath has no extension.
  static String resolve({
    required String rawPath,
    required String includingFileAbsolutePath,
    String? defaultExtension,
  });

  /// Canonicalizes a path for use as a cycle-detection / dependency-graph
  /// key. Two differently-written paths that point at the same file on disk
  /// (e.g. 'a/../a/cave.th' and 'a/cave.th') must canonicalize identically.
  static String canonicalize(String absolutePath);
}
```

Implementation uses `package:path` (`p.normalize`, `p.isAbsolute`, `p.join`, `p.extension`, `p.dirname`), already a dependency via `mp_directory_aux.dart`. `canonicalize` uses `p.normalize` on the absolute path; it does not resolve symlinks (Therion projects are typically plain directory trees, and `dart:io`'s `File.resolveSymbolicLinks()` requires the file to exist, which conflicts with the "missing file" case) — this is a deliberate scope limit, noted inline as a comment where `canonicalize` is defined.

The default-extension behaviour duplicates `THDataInput.resolvedPath`'s logic (`lib/src/elements/th_data/th_data_input.dart`). `THDataInput.resolvedPath` is left as-is (Phase 1 API, used elsewhere) and `THProjectParser` calls `THProjectPathResolver.resolve` directly rather than `resolvedPath`, so there is exactly one place implementing the rule for all four directive types (`THConfigSource`, `THConfigInput`, `THDataInput`, `THImport`).

---

## 5. `THProjectParser` (`lib/src/mp_file_read_write/th_project_parser.dart`)

### 5.1 Public API

```dart
class THProjectLoadResult {
  final THProjectFileNode rootNode;
  final Map<String, Set<String>> fileDependencies;   // file path -> paths it includes
  final Map<String, Set<String>> reverseDependencies; // file path -> paths that include it
  final List<THProjectParseError> projectErrors;
}

class THProjectParser {
  /// Loads a project starting from [rootFilePath] (a thconfig file, or a
  /// root .th file when there is no thconfig). Reads files synchronously
  /// via dart:io; Phase 3 wraps this in a MobX action / isolate as needed.
  static THProjectLoadResult loadProject(String rootFilePath);
}
```

`loadProject` is synchronous and side-effect-free beyond reading files from disk — no MobX, no controller state — so it can be unit-tested directly against fixture directory trees without bootstrapping the app, and Phase 3 can later call it from a background isolate if large projects make it worth doing so.

### 5.2 Algorithm

```
loadProject(rootFilePath):
  visited := {}                      # canonical path -> THProjectFileNode already built
  forwardDeps := {}, reverseDeps := {}, errors := []

  rootNode := loadFileNode(rootFilePath, includingFile: null)
  return THProjectLoadResult(rootNode, forwardDeps, reverseDeps, errors)

loadFileNode(path, includingFile):
  canonical := THProjectPathResolver.canonicalize(path)

  if canonical in visited:
    errors.add(cycle warning, referencing includingFile and path)
    return visited[canonical]        # link back to existing node, do not recurse again

  if not File(path).existsSync():
    node := THMissingFileNode(requestedPath: path, ...)
    errors.add(missing-file error)
    return node                      # no entry in `visited`: a later, different include
                                      # path to the same missing file gets its own node,
                                      # since there's nothing to share

  visited[canonical] := <placeholder inserted before recursing, to guard self-cycles>

  content := File(path).readAsStringSync() (respecting file's declared encoding, mirroring
             the existing encoding-detection already used by THFileParser/TH2FileParser)

  if path is a thconfig-shaped file (see 5.3 for how "shape" is decided):
    configFile := THConfigFileParser.parse(content)
    node := THConfigFileNode(configFile: configFile, ...)
    forwardDeps[canonical] := {}
    for each THConfigSource s in configFile.sourceFilePaths:
      childPath := THProjectPathResolver.resolve(s, path, defaultExtension: '.th')
      childNode := loadFileNode(childPath, includingFile: path)
      node.addChild(childNode)
      forwardDeps[canonical].add(canonicalize(childPath))
      reverseDeps[canonicalize(childPath)].add(canonical)
    for each THConfigInput i in configFile.inputFilePaths:
      # same pattern, no default extension forced for config-to-config input
    attach configFile.parseErrors to node.parseErrors

  else: # .th file
    dataFile := THFileParser.parse(content)
    node := THDataFileNode(dataFile: dataFile, ...)
    forwardDeps[canonical] := {}
    walk dataFile.elements recursively (surveys nest; centrelines/maps/inline scraps
       are leaves) building THSurveyNode / THCentrelineNode / THMapNode / THScrapNode
       children of `node` (or of the parent THSurveyNode, for nested elements),
       computing THSurveyNode.fullNamespace by joining ancestor survey ids
    for each THDataInput inp in dataFile.inputs (at any nesting level):
      childPath := THProjectPathResolver.resolve(inp.rawPath, path, defaultExtension: '.th')
      if childPath ends with '.th2':
        childNode := TH2FileNode(absolutePath: childPath, isLoaded: File(childPath).existsSync(), ...)
        # no cycle/recursion: .th2 files don't themselves include other files
      else:
        childNode := loadFileNode(childPath, includingFile: path)
      attach childNode as a child of the THSurveyNode (or file node) containing the `input` line
      forwardDeps[canonical].add(canonicalize(childPath))
      reverseDeps[canonicalize(childPath)].add(canonical)
    for each THImport imp in dataFile (wherever THImport elements are collected):
      resolve similarly; on missing file, attach error to the owning node rather than
      creating a visible tree child (import targets are 3D/centreline data, not part of
      the file-hierarchy tree per the roadmap's diagram in §2)
    attach dataFile.parseErrors to node.parseErrors

  visited[canonical] := node
  return node
```

Key points carried over from the roadmap (§2.3) and made concrete:
- **Self-cycle guard**: `visited[canonical]` is populated with a placeholder *before* recursing into children, so a file that (directly or indirectly) includes itself is caught rather than causing unbounded recursion.
- **Missing files are not cached in `visited`**: two different `source`/`input` lines that both point at the same nonexistent path each get their own `THMissingFileNode` (cheap, and keeps each diagnostic anchored to its own including line — sharing them would require deciding which including-file "owns" the shared missing-file node, which has no natural answer).
- **`.th2` files are leaves**: consistent with objective 7 — no recursion, no dependency-graph edges beyond the single `parent → .th2` edge, no parsing of scrap contents (that stays lazy, in `TH2FileParser`, until a canvas tab opens it in Phase 6).

### 5.3 Determining file "shape" (thconfig vs. `.th`)

The root file can be a `thconfig` with an arbitrary filename (per roadmap §1, objective 1: "which can have any filename or extension"), so file type cannot be decided by extension alone for the root. `THProjectParser` decides using the same signal Phase 1's parsers already rely on for fault tolerance: it attempts `THConfigFileParser.parse` first only for the *root* file (the only place ambiguity exists — everything reached via `source` is unambiguously `.th`-shaped per the Therion book's rules in roadmap §2.1, and everything reached via a `thconfig`'s `input` is unambiguously another `thconfig`-shaped file). If the root file contains any `thconfig`-only directive (`layout`, `export`, `select`/`unselect`, or `source`) it is treated as a `thconfig`; otherwise it is treated as a root `.th` file. This mirrors real Therion behavior (a project can be launched directly from a `.th` file with no `thconfig` at all) without needing a new sniffing grammar.

### 5.4 Encoding

File reads reuse whatever encoding-detection mechanism `THFileParser`/`TH2FileParser` already implement (declared `encoding <name>` directive on the first non-comment line, defaulting to `mpDefaultEncoding` from `mp_constants.dart`) — Phase 2 does not introduce a second encoding-detection path; `THProjectPathResolver`/`THProjectParser` call into the existing helper used by Phase 1's parsers rather than re-implementing charset detection.

---

## 6. Step-by-Step Implementation Sequence

```
Step 1: THProjectParseError + THProjectNode/THProjectFileNode base classes
   │
   ▼
Step 2: Concrete file nodes (THConfigFileNode, THDataFileNode, TH2FileNode, THMissingFileNode)
   │
   ▼
Step 3: Logical nodes (THSurveyNode, THCentrelineNode, THMapNode, THScrapNode)
   │
   ▼
Step 4: THProjectPathResolver (resolve + canonicalize) & unit tests
   │
   ▼
Step 5: THProjectParser — single-file loading (root thconfig OR root .th, no recursion yet)
   │
   ▼
Step 6: THProjectParser — recursive source/input resolution + dependency graph
   │
   ▼
Step 7: Cycle detection & missing-file handling
   │
   ▼
Step 8: Logical-node tree construction (surveys/centrelines/maps/scraps) within each file node
   │
   ▼
Step 9: Fixture-based tests against realistic multi-file project trees (test/auxiliary/th_project/)
   │
   ▼
Step 10: Static Analysis & Validation (flutter analyze, flutter test)
```

---

## 7. Test Plan & Scenarios

Test file numbering follows the existing `t38xx` block used by Phase 1 (`t3800_th_config_parser_test.dart`, `t3810_th_config_file_writer_test.dart`, `t3820_th_data_parser_test.dart`, `t3830_th_file_writer_test.dart`); Phase 2 continues from `t3840`.

### 7.1 `test/t3840_th_project_path_resolver_test.dart`
1. Relative path resolved against including file's directory (including nested subdirectories, `../` traversal).
2. Absolute path passed through unchanged.
3. Default extension appended only when the raw path has no extension (`cave` → `cave.th`; `cave.th2` untouched; `cave.v3` untouched).
4. `canonicalize` normalizes `a/../a/cave.th` and `a/cave.th` to the same string; different files canonicalize differently.
5. Platform path separators (forward slash in Therion source files even on Windows) resolve correctly via `package:path`.

### 7.2 `test/t3850_th_project_parser_test.dart`
1. **Single-file project**: root `thconfig` with no `source`/`input` — tree has exactly the root `THConfigFileNode`, no children.
2. **Root is a `.th` file (no thconfig)**: loader correctly identifies shape per §5.3 and produces a `THDataFileNode` root.
3. **Simple two-level project**: `thconfig` → `source cave.th` → `input passage.th2`; verify `THConfigFileNode → THDataFileNode → TH2FileNode` chain and correct `relativePathToProjectRoot`/`absolutePath` on each.
4. **Nested surveys**: `.th` file with 3 levels of `survey ... endsurvey`; verify `THSurveyNode.fullNamespace` is computed correctly at each level (e.g. `room.passage.cave`).
5. **Multiple `source` files**: `thconfig` with two `source` lines; both become sibling children of the root.
6. **Missing file**: `source missing.th` where `missing.th` doesn't exist on disk — verify a `THMissingFileNode` is created, an `error`-severity `THProjectParseError` is recorded with the correct `filePath`/`lineNumber`, and loading of the rest of the project continues unaffected.
7. **Circular include**: `a.th` has `input b.th`, `b.th` has `input a.th` — verify the second visit to `a.th` links back to the already-built node (no infinite recursion, no duplicate parse), and a `warning`-severity error is recorded.
8. **Self-include**: a file that directly `input`s itself — same cycle-guard path as #7 with `includingFile == path`.
9. **Default extension in practice**: `input passage` (no extension) inside a `.th` file resolves to `passage.th`, not `passage.th2`.
10. **`import` directive**: verify `THImport` targets are resolved and diagnosed on missing files, but do not appear as visible tree nodes (per §5.2).
11. **Dependency graph correctness**: for a project with the shape in scenario 3, verify `fileDependencies['thconfig'] == {'cave.th'}`, `reverseDependencies['cave.th'] == {'thconfig'}`, and that `passage.th2` appears in `fileDependencies['cave.th']` but has no entry of its own in `fileDependencies` (leaf).
12. **Encoding propagation**: a `.th` file with a declared `encoding ISO-8859-1` header and non-ASCII content is read correctly (mirrors the equivalent Phase 1 encoding tests already present for `.th2`, e.g. `th_file_parser-00013-iso8859-1_encoding.th2`).

### 7.3 `test/t3860_th_project_logical_nodes_test.dart`
1. **Centrelines**: a `.th` file with a top-level `centreline ... endcentreline` produces a sibling `THCentrelineNode` under the file node.
2. **Maps**: `map ... endmap` produces a `THMapNode`; nested maps (a map referencing another map) are represented as children.
3. **Scraps embedded in `.th`**: an inline `scrap ... endscrap` block (via `th_inline_scrap.dart`) produces a `THScrapNode` with `isFromTH2File == false`.
4. **Scraps from linked `.th2`**: an `input passage.th2` line produces a `TH2FileNode`; no `THScrapNode` is synthesized for it at this stage (its scrap(s) are only known once `TH2FileParser` runs in Phase 6) — this is asserted explicitly so the boundary doesn't silently shift later.
5. **Mixed nesting**: a survey containing both a centreline and a nested sub-survey containing a map — verify the tree shape (not just flat lists) matches the source nesting.

Fixture files for §7.2/7.3 live under `test/auxiliary/th_project/<scenario-name>/`, one small multi-file directory tree per scenario, following the existing convention of dated/numbered fixture filenames used under `test/auxiliary/`.

---

## 8. Explicit Non-Goals for Phase 2

To keep this phase's scope aligned with "Recursive Project Tree Loader & Dependency Graph" (roadmap §9, Phase 2) and not bleed into later phases:
- No MobX controller, no reactivity, no debouncing — that is Phase 3 (`THProjectController`).
- No UI, icons, or widget code — that is Phase 4 (`THProjectTreeWidget`).
- No text editor, syntax highlighting, or line-jump navigation wiring — that is Phase 5/6.
- No Therion compiler invocation or log parsing — that is Phase 7.
- No localization strings or help-page updates — `THProjectParseError.message` values in this phase are internal/diagnostic (English, developer-facing) and are expected to be re-authored as localized, user-facing strings when Phase 4 renders them; that rework is out of scope here.
