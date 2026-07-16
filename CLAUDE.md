<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# CLAUDE.md

Project overview, commands, and architecture. See `coding-guidelines.md` for detailed coding rules.

## Project Overview

Mapiah: Flutter GUI for [Therion](https://therion.speleo.sk/) cave mapping. Reads/writes `.th2` files, provides interactive canvas editor for survey elements (points/lines/areas).

**Tech stack**: Flutter (Linux/macOS/Windows), MobX for state, PetitParser for grammar parsing.

## Commands

```bash
flutter run -d linux              # Run app
flutter test                       # All tests
flutter test test/t1200_...        # Single test
flutter build linux                # Build for Linux
flutter analyze                    # Static analysis
dart run build_runner build       # Generate MobX (only if watch not running)
flutter gen-l10n                   # Generate localizations after .arb edits
```

## Architecture Summary

### State Management: MobX
Controllers in lib/src/controllers/ use @observable/@action. Run build_runner after modifications. .g.dart files are auto-generated.

### Key Controllers

* TH2FileEditController — Main editing orchestration
* MPUndoRedoController — Undo/redo queue
* MPSettingsController — Persistent settings
* MPGeneralController — App-wide state (open files)
* MPVisualController — Zoom, pan, viewport

### Interaction Flow (3 method types)
1. prepare*() — Creates+executes MPCommand (data changes)
2. apply*() (@action) — Called by commands, modifies THFile
3. perform*() (@action) — UI state changes only (no command)

### Command Pattern (Undo/Redo)

lib/src/commands/ — Each data-altering action extends MPCommand:
* _actualExecute() — Performs action
* _createUndo() — Inverse command

MPMultipleElementsCommand wraps multiple commands into one undoable unit.

### Data Model (lib/src/elements/)
* THFile — Root container, holds elements by MPID (internal integer ID)
* THScrap — Sketch container
* THPoint / THLine / THArea — Editable elements
* THLineSegment, THBezierCurveLineSegment, THStraightLineSegment — Line variants
* Two ID systems: MPID (runtime) + thID (Therion string ID from file)
* Mixins: THIsParentMixin (children), THHasOptionsMixin (attributes)

### File Parsing (lib/src/mp_file_read_write/)
* th_grammar.dart / th_file_parser.dart — PetitParser for .th2
* xvi_grammar.dart / xvi_file_parser.dart — Parser for .xvi files
* th_file_writer.dart — Preserves original formatting, only changed lines modified

### State Machine (lib/src/state_machine/mp_th2_file_edit_state_machine/)

Editing modes:
* MPTh2FileEditStateSelectEmptySelection — Default, no selection
* MPTh2FileEditStateSelectNonEmptySelection — Elements selected
* MPTh2FileEditStateAddPoint/Line/Area — Adding new elements
* MPTh2FileEditStateEditSingleLine — Editing individual line nodes
* MPTh2FileEditStateMovingElements — Dragging selected elements

### Pages (lib/src/pages/)
* mapiah_home.dart — Open/create files
* th2_file_tabs_page.dart — Main canvas (tabbed)
* mp_settings_page.dart — Settings

### Dialgos
* Bottom buttons that should always stay visible, even when the content scrolls, use MPDialogBottomWidget for consistent styling.

### Localization

.arb editable files in lib/l10n/ and generated files in lib/src/generated/i18n/ → Run flutter gen-l10n → Access via mpLocator.appLocalizations

### Service Locator

MPLocator (global mpLocator) provides:
* Controllers (mpGeneralController, mpSettingsController)
* mpLog (logger)
* appLocalizations
* mpNavigatorKey

### Naming Conventions
* TH* — Therion data structures
* MP* — Mapiah infrastructure
* .g.dart — Generated, do not edit
* Test files: numeric prefix for ordering (e.g., t1200_commands_MPAddAreaCommand_test.dart)

### Prompt Abbreviations
* cc: Update CHANGELOG.md + prepare commit with sign-off (Signed-off-by, Assisted_By)
* hpcc: Update help pages (EN/PT) + keyboard shortcuts + cc above

### Canvas Orientation

Therion and Flutter Y-axes are opposite. Mapiah uses Therion's convention (Y increases downwards) for intuitive mapping to .th2 files. All canvas transformations account for this.

### Coding Rules Summary

Full rules in coding-guidelines.md. Critical rules:
* Explicit types, final by default
* No magic numbers → use mp_constants.dart
* All user strings → AppLocalizations (no hardcoding)
* No all-caps in UI text
* Update help pages (EN/PT) + keyboard shortcuts (alphabetical order)
* URLs → MPURLTextWidget
* Formatting handled automatically on commit: never run "dart format".

### For every prompt:
1. Run 'flutter analyze'
2. Summarize diffs

### Release Targets

See release-targets.md — Linux (AppImage/Flatpak), macOS, Windows (no web/Flathub).
