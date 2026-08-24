<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 1: Grammars, Parsers & Writers — Implementation Plan

**Date:** 2026-08-24  
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 1** of the [Therion Project Parsing & Management Roadmap](file:///home/rodrigo/devel/mapiah/docs/plans/2026-08-24-therion-project-parsing-and-tree-view.md).

Phase 1 provides the core foundation: parsing and non-destructive serialization of Therion configuration files (`thconfig`) and survey data files (`.th`), complementing the existing `.th2` drawing file parser and writer.

### Key Objectives
1. **`thconfig` Support**:
   - Data models for all Therion configuration directives and layout blocks.
   - `THConfigGrammar` and `THConfigFileParser` (PetitParser-based).
   - `THConfigFileWriter` preserving unchanged lines, comments, and layout structures.
2. **`.th` Survey Data Support**:
   - Data models for nested surveys, centrelines, maps, equates, joins, surface, and imports.
   - `THGrammar` and `THFileParser` (PetitParser-based).
   - `THFileWriter` preserving original tabular shot formatting, comments, and survey blocks.
3. **Lossless Round-Trip Guarantee**:
   - Parsing an unmodified `thconfig` or `.th` file and serializing it back must produce a byte-identical representation.
   - Programmatic edits (e.g. adding a new source file or modifying survey options) modify only the affected lines.
4. **Resilient & Fault-Tolerant Parsing**:
   - Parsers must recover from syntax errors line-by-line, capturing errors in node diagnostics without aborting parsing.

---

## 2. File Organization & Architecture

Following the rename in commit `83dbca2f`:
- `.th2` files (drawings): `TH2Grammar`, `TH2FileParser`, `TH2FileWriter` in `th2_*.dart`.
- `.th` files (survey data): `THGrammar`, `THFileParser`, `THFileWriter` in `th_*.dart`.
- `thconfig` files (configuration): `THConfigGrammar`, `THConfigFileParser`, `THConfigFileWriter` in `th_config_*.dart`.

```
lib/src/
 ├── elements/
 │    ├── th_config/                     # thconfig data models
 │    │    ├── th_config_file.dart
 │    │    ├── th_config_element.dart
 │    │    ├── th_config_source.dart
 │    │    ├── th_config_input.dart
 │    │    ├── th_config_layout.dart
 │    │    ├── th_config_export.dart
 │    │    ├── th_config_select.dart
 │    │    ├── th_config_setting.dart
 │    │    └── th_config_comment.dart
 │    └── th_data/                       # .th survey data models
 │         ├── th_data_file.dart
 │         ├── th_data_element.dart
 │         ├── th_survey.dart
 │         ├── th_centreline.dart
 │         ├── th_centreline_shot.dart
 │         ├── th_map.dart
 │         ├── th_data_input.dart
 │         ├── th_equate.dart
 │         ├── th_join.dart
 │         ├── th_surface.dart
 │         ├── th_import.dart
 │         └── th_data_comment.dart
 └── mp_file_read_write/
      ├── grammar_utils.dart             # Shared token matchers
      ├── th_config_grammar.dart         # PetitParser grammar for thconfig
      ├── th_config_file_parser.dart     # Parser for thconfig
      ├── th_config_file_writer.dart     # Non-destructive writer for thconfig
      ├── th_grammar.dart                # PetitParser grammar for .th
      ├── th_file_parser.dart            # Parser for .th
      ├── th_file_writer.dart            # Non-destructive writer for .th
      ├── th2_grammar.dart               # Existing .th2 grammar
      ├── th2_file_parser.dart           # Existing .th2 parser
      └── th2_file_writer.dart           # Existing .th2 writer
```

---

## 3. Sub-phase 1A: `thconfig` File Support

### 3.1 Data Models (`lib/src/elements/th_config/`)

```dart
/// Represents a parsed thconfig configuration file.
class THConfigFile {
  String filename = '';
  String encoding = 'UTF-8';
  String lineEnding = '\n';
  
  final List<THConfigElement> elements = [];
  final List<String> parseErrors = [];
  
  /// Helper getters for quick inspection.
  List<String> get sourceFilePaths => elements
      .whereType<THConfigSource>()
      .map((s) => s.filePath)
      .toList();
      
  List<String> get inputFilePaths => elements
      .whereType<THConfigInput>()
      .map((i) => i.filePath)
      .toList();
      
  List<THConfigExport> get exports => elements.whereType<THConfigExport>().toList();
  List<THConfigLayout> get layouts => elements.whereType<THConfigLayout>().toList();
}

/// Base class for all elements in a thconfig file.
abstract class THConfigElement {
  int lineNumber = 0;
  String originalLine = '';
  bool isModified = false;
}

/// Single-line or multi-line source directive.
class THConfigSource extends THConfigElement {
  final String filePath; // empty if multi-line inline source
  final List<String> inlineCommands = []; // if source ... endsource
  final bool isMultiLine;
  THConfigSource({required this.filePath, this.isMultiLine = false});
}

/// input <file-path>
class THConfigInput extends THConfigElement {
  final String filePath;
  THConfigInput({required this.filePath});
}

/// layout <id> ... endlayout
class THConfigLayout extends THConfigElement {
  final String layoutId;
  final List<String> rawOptions = [];
  final Map<String, dynamic> parsedOptions = {};
  THConfigLayout({required this.layoutId});
}

/// export <type> [options]
class THConfigExport extends THConfigElement {
  final String exportType; // map, model, atlas, database, etc.
  final String? outputFilePath; // parsed from -output / -o
  final String? layoutId; // parsed from -layout / -l
  final List<String> options = [];
  THConfigExport({required this.exportType, this.outputFilePath, this.layoutId});
}

/// select / unselect <object> [options]
class THConfigSelect extends THConfigElement {
  final bool isSelect; // true = select, false = unselect
  final String targetObjectId;
  final Map<String, String> options = {};
  THConfigSelect({required this.isSelect, required this.targetObjectId});
}

/// Global settings: cs, encoding, language, system, maps, scrap-sort, sketch-warp, text, log, setup3d
class THConfigSetting extends THConfigElement {
  final String keyword;
  final List<String> arguments = [];
  THConfigSetting({required this.keyword, required List<String> arguments}) {
    this.arguments.addAll(arguments);
  }
}

/// Comment (#) or empty line.
class THConfigComment extends THConfigElement {
  final String commentText;
  final bool isEmptyLine;
  THConfigComment({required this.commentText, this.isEmptyLine = false});
}
```

### 3.2 `THConfigGrammar` (`lib/src/mp_file_read_write/th_config_grammar.dart`)
- **PetitParser Rules**:
  - `start()`: `thConfigStatement().star().end()`
  - `thConfigStatement()`: `commentLine() | emptyLine() | sourceCommand() | inputCommand() | layoutBlock() | exportCommand() | selectCommand() | unselectCommand() | settingCommand() | fallbackLine()`
  - `sourceCommand()`: `stringIgnoreCase('source') & thWhitespace & anyString()` | `sourceMultiLineBlock()`
  - `layoutBlock()`: `stringIgnoreCase('layout') & thWhitespace & identifier & ... & stringIgnoreCase('endlayout')`
  - `exportCommand()`: `stringIgnoreCase('export') & thWhitespace & identifier & thWhitespace.optional() & optionsList().optional()`
  - `selectCommand()` / `unselectCommand()`: `(stringIgnoreCase('select') | stringIgnoreCase('unselect')) & thWhitespace & anyString() & optionsList().optional()`
  - `settingCommand()`: `(stringIgnoreCase('cs') | stringIgnoreCase('encoding') | stringIgnoreCase('language') | stringIgnoreCase('system') | stringIgnoreCase('maps') | stringIgnoreCase('maps-offset') | stringIgnoreCase('scrap-sort') | stringIgnoreCase('sketch-warp') | stringIgnoreCase('log') | stringIgnoreCase('text') | stringIgnoreCase('setup3d') | stringIgnoreCase('lookup')) & thWhitespace & settingArguments()`

### 3.3 `THConfigFileParser` (`lib/src/mp_file_read_write/th_config_file_parser.dart`)
- Parses raw text content line-by-line with PetitParser.
- Builds `THConfigFile` and attaches `originalLine` and line numbers.
- Handles line continuations (lines ending with `\`).

### 3.4 `THConfigFileWriter` (`lib/src/mp_file_read_write/th_config_file_writer.dart`)
- Serializes `THConfigFile` to a String or encoded `Uint8List`.
- For unchanged elements: outputs `originalLine` directly.
- For modified or newly added elements: constructs the formatted Therion command string.
- Handles line endings (`lineEnding`) and file encoding headers.

---

## 4. Sub-phase 1B: `.th` Survey Data File Support

### 4.1 Data Models (`lib/src/elements/th_data/`)

```dart
/// Represents a parsed .th survey data file.
class THDataFile {
  String filename = '';
  String encoding = 'UTF-8';
  String lineEnding = '\n';
  
  final List<THDataElement> elements = [];
  final List<String> parseErrors = [];

  List<THSurvey> get surveys => elements.whereType<THSurvey>().toList();
  List<THDataInput> get inputs => elements.whereType<THDataInput>().toList();
  List<THCentreline> get centrelines => elements.whereType<THCentreline>().toList();
  List<THMap> get maps => elements.whereType<THMap>().toList();
}

abstract class THDataElement {
  int lineNumber = 0;
  String originalLine = '';
  bool isModified = false;
}

/// survey <id> [options] ... endsurvey [<id>]
class THSurvey extends THDataElement {
  final String surveyId;
  final String? title;
  final Map<String, dynamic> options = {};
  final List<THDataElement> children = [];
  
  THSurvey({required this.surveyId, this.title});
}

/// input <file-path> (auto-appends .th if extension omitted)
class THDataInput extends THDataElement {
  final String rawPath;
  String get resolvedPath => rawPath.contains('.') ? rawPath : '$rawPath.th';
  THDataInput({required this.rawPath});
}

/// centreline [options] ... endcentreline
class THCentreline extends THDataElement {
  final String? id;
  final String? date;
  final List<String> team = [];
  final List<THCentrelineShot> shots = [];
  final List<String> stations = [];
  final List<String> rawDataLines = [];
  final Map<String, dynamic> options = {};
  
  THCentreline({this.id, this.date});
}

/// Individual survey leg / shot reading.
class THCentrelineShot {
  final String fromStation;
  final String toStation;
  final double length;
  final double? bearing;
  final double? gradient;
  final List<String> flags = [];
  final String originalLine;
  
  THCentrelineShot({
    required this.fromStation,
    required this.toStation,
    required this.length,
    this.bearing,
    this.gradient,
    this.originalLine = '',
  });
}

/// map <id> [options] ... endmap
class THMap extends THDataElement {
  final String mapId;
  final String projection; // plan, elevation, extended
  final List<String> items = []; // scrap IDs, sub-map IDs, survey IDs
  final Map<String, dynamic> options = {};
  
  THMap({required this.mapId, this.projection = 'plan'});
}

/// equate <station1> <station2> ...
class THEquate extends THDataElement {
  final List<String> stations = [];
  THEquate({required List<String> stations}) {
    this.stations.addAll(stations);
  }
}

/// join <line1> <line2> [options]
class THJoin extends THDataElement {
  final String line1;
  final String line2;
  final Map<String, String> options = {};
  THJoin({required this.line1, required this.line2});
}

/// import <file> [options]
class THImport extends THDataElement {
  final String filePath;
  final Map<String, String> options = {};
  THImport({required this.filePath});
}
```

### 4.2 `THGrammar` (`lib/src/mp_file_read_write/th_grammar.dart`)
- **PetitParser Rules**:
  - `start()`: `thDataStatement().star().end()`
  - `thDataStatement()`: `commentLine() | emptyLine() | surveyBlock() | centrelineBlock() | mapBlock() | scrapBlock() | inputCommand() | equateCommand() | joinCommand() | importCommand() | surfaceBlock() | generalCommand()`
  - `surveyBlock()`: `stringIgnoreCase('survey') & thWhitespace & identifier & ... & stringIgnoreCase('endsurvey')` (recursive).
  - `centrelineBlock()`: `(stringIgnoreCase('centreline') | stringIgnoreCase('centerline')) & ... & (stringIgnoreCase('endcentreline') | stringIgnoreCase('endcenterline'))`.
  - `mapBlock()`: `stringIgnoreCase('map') & thWhitespace & identifier & ... & stringIgnoreCase('endmap')`.
  - `inputCommand()`: `stringIgnoreCase('input') & thWhitespace & anyString()`.
  - `equateCommand()`: `stringIgnoreCase('equate') & thWhitespace & identifier.plusSeparated(thWhitespace)`.
  - `joinCommand()`: `stringIgnoreCase('join') & thWhitespace & anyString() & thWhitespace & anyString() & ...`.

### 4.3 `THFileParser` (`lib/src/mp_file_read_write/th_file_parser.dart`)
- Parses `.th` files into `THDataFile`.
- Maintains survey hierarchy stack to properly nest sub-surveys.
- Captures station names and namespaces (`station@survey`).

### 4.4 `THFileWriter` (`lib/src/mp_file_read_write/th_file_writer.dart`)
- Non-destructive serialization of `THDataFile`.
- Preserves exact shot tabular alignment, column spacing, and comments in `centreline` blocks.
- Emits clean indentation for newly created surveys and nested elements.

---

## 5. Step-by-Step Implementation Sequence

```
Step 1: Shared Grammar Utils (GrammarUtils enhancements)
   │
   ▼
Step 2: thconfig Data Models (lib/src/elements/th_config/)
   │
   ▼
Step 3: THConfigGrammar & THConfigFileParser
   │
   ▼
Step 4: THConfigFileWriter & thconfig Unit Tests (test/t1300_*, test/t1310_*)
   │
   ▼
Step 5: .th Data Models (lib/src/elements/th_data/)
   │
   ▼
Step 6: THGrammar & THFileParser
   │
   ▼
Step 7: THFileWriter & .th Unit Tests (test/t1301_*, test/t1311_*)
   │
   ▼
Step 8: Static Analysis & Validation (flutter analyze, flutter test)
```

---

## 6. Test Plan & Scenarios

### 6.1 `thconfig` Tests (`test/t1300_th_config_parser_test.dart` & `test/t1310_th_config_file_writer_test.dart`)
1. **Directives Parsing**: `source file.th`, multi-line `source ... endsource`, `input sub.cfg`.
2. **Layout Blocks**: Parsing `layout cave_layout` with complex nested options (`scale`, `base-scale`, `code metapost ... endcode`).
3. **Exports & Selections**: `export map -o cave.pdf -layout cave_layout`, `select cave@system`, `unselect passage_b`.
4. **Settings**: `cs UTM33N`, `encoding UTF-8`, `language en`, `system "echo done"`.
5. **Round-Trip Idempotence**: Read `sample.thconfig`, serialize with `THConfigFileWriter`, verify byte-for-byte identity.
6. **Programmatic Edits**: Add `source new_survey.th`, change `export` output path, verify that only the modified lines changed.

### 6.2 `.th` Survey Data Tests (`test/t1301_th_data_parser_test.dart` & `test/t1311_th_file_writer_test.dart`)
1. **Nested Surveys**: Parsing 3-level deep surveys (`survey cave ... survey passage ... survey room ... endsurvey`).
2. **Centrelines**: Parsing shots, stations, instruments, calibrate, equate, flags, and `data normal from to length bearing clino`.
3. **Maps & Scraps**: Parsing `map plan_map -projection plan` containing scrap references and sub-maps.
4. **Equates & Joins**: Parsing `equate 1@cave 2@passage`, `join line1 line2 -count 2`.
5. **Round-Trip Idempotence**: Read complex real-world `.th` files, serialize with `THFileWriter`, verify byte-for-byte identity.
6. **Programmatic Edits**: Insert a new `input scrap.th2` inside a survey, rename survey, verify formatting preservation.
