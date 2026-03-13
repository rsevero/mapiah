# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mapiah is a Flutter-based graphical interface for [Therion](https://therion.speleo.sk/) cave mapping software. It reads/writes `.th2` files (Therion's 2D survey sketch format) and provides an interactive canvas editor for cave survey elements: points, lines, and areas.

## Commands

```bash
# Run the app
flutter run -d linux

# Run all tests
flutter test

# Run a single test file
flutter test test/1200-commands_MPAddAreaCommand_test.dart

# Build for Linux
flutter build linux

# Analyze code
flutter analyze

# Generate MobX boilerplate (run after modifying @observable/@action annotated files)
dart run build_runner build

# Watch and auto-regenerate MobX boilerplate
dart run build_runner watch

# Generate l10n localizations (run after editing .arb files)
flutter gen-l10n
```

## Architecture

### State Management: MobX

The app uses MobX for reactive state management. Controllers (in `lib/src/controllers/`) use `@observable`, `@action`, and `@computed` annotations. Each controller has a corresponding `.g.dart` generated file. Run `dart run build_runner build` after modifying annotated controller code.

### Controllers

Located in `lib/src/controllers/`:

- **`TH2FileEditController`** — Main controller for file editing. Orchestrates all edit operations.
- **`TH2FileEditElementEditController`** — Handles element editing (moving, type changes).
- **`TH2FileEditSelectionController`** — Manages element selection state.
- **`TH2FileEditStateController`** — Manages the current editing mode (state machine).
- **`TH2FileEditSnapController`** — Handles snap-to-grid/snap-to-point behavior.
- **`TH2FileEditUserInteractionController`** — Processes mouse/keyboard events from the canvas.
- **`TH2FileEditOptionEditController`** — Handles editing of element options/attributes.
- **`TH2FileEditOverlayWindowController`** — Controls overlay popups (option editors, type selectors).
- **`MPUndoRedoController`** — Manages the undo/redo command queue.
- **`MPSettingsController`** — Persistent app settings (SharedPreferences + config file).
- **`MPGeneralController`** — App-wide general state (current open files, etc.).
- **`MPVisualController`** — Visual/display parameters (zoom, pan, viewport).

### User Interaction Flow (see `auxiliary/From_user interaction_to_new_updated_state-how_does_it_work.md`)

Three method naming conventions in controllers:

1. **`prepare*()`** — Called first from widget/state; gathers info and creates+executes an `MPCommand`.
2. **`apply*()`** (annotated `@action`) — Called by `MPCommand._actualExecute()`; makes actual changes to `THFile` and triggers redraws.
3. **`perform*()`** (annotated `@action`) — For non-data-altering actions (UI state changes, overlay toggles); no `MPCommand` involved.

### Command Pattern (Undo/Redo)

`lib/src/commands/` — Every data-altering action is encapsulated in an `MPCommand` subclass. Commands implement:
- `_actualExecute()` — Performs the action
- `_createUndo()` — Creates the inverse command for undo

`MPMultipleElementsCommand` wraps multiple commands into one undoable unit.

### Data Model

`lib/src/elements/`:
- **`THFile`** — Root container (represents a `.th2` file). Holds all elements by internal Mapiah ID (MPID).
- **`THElement`** — Base class for all Therion elements.
- **`THScrap`** — Therion scrap (survey sketch container within a file).
- **`THPoint`**, **`THLine`**, **`THArea`** — The three editable element types.
- **`THLineSegment`**, **`THBezierCurveLineSegment`**, **`THStraightLineSegment`** — Line segment variants.

Each element has two ID systems:
- **MPID**: Internal Mapiah integer ID, runtime only (never saved).
- **thID**: Therion string ID from the file (used for references between elements).

Elements with children use `THIsParentMixin`. Element options/attributes use `THHasOptionsMixin`.

### File Parsing & Writing

`lib/src/mp_file_read_write/`:
- `th_grammar.dart` / `th_file_parser.dart` — PetitParser-based grammar for `.th2` files.
- `xvi_grammar.dart` / `xvi_file_parser.dart` — Parser for `.xvi` (XVI survey image) files.
- `th_file_writer.dart` — Writes `THFile` back to `.th2`. Only changed lines are modified; original formatting is preserved elsewhere.

### State Machine

`lib/src/state_machine/mp_th2_file_edit_state_machine/` — Defines editing modes:
- `MPTh2FileEditStateSelectEmptySelection` — Default, no selection
- `MPTh2FileEditStateSelectNonEmptySelection` — Elements selected
- `MPTh2FileEditStateAddPoint/Line/Area` — Adding new elements
- `MPTh2FileEditStateEditSingleLine` — Editing individual line nodes
- `MPTh2FileEditStateMovingElements` — Dragging selected elements

### Pages

`lib/src/pages/`:
- `mapiah_home.dart` — Home screen (open/create file)
- `th2_file_edit_page.dart` — Main canvas editing page
- `mp_settings_page.dart` — App settings

### Localization

Uses `flutter_localizations` with `.arb` files in `lib/src/generated/i18n/`. Run `flutter gen-l10n` after editing `.arb` files. Access via `mpLocator.appLocalizations`.

### Service Locator

`MPLocator` (singleton via `mpLocator` global in `main.dart`) provides access to global controllers: `mpGeneralController`, `mpSettingsController`, `mpLog`, `appLocalizations`, `mpNavigatorKey`.

### Naming Conventions

- Files/classes prefixed `TH` relate to Therion data structures.
- Files/classes prefixed `MP` are Mapiah-specific infrastructure.
- Generated MobX files have `.g.dart` suffix — do not edit these directly.
- Test files are numerically prefixed (e.g., `1200-commands_MPAddAreaCommand_test.dart`) for ordering.

## Coding Style

### When writing general app code

1. App localizations must be accessed via `mpLocator.appLocalizations`. Exception: `MapiahHome` uses `final AppLocalizations appLocalizations = AppLocalizations.of(context);`.
2. No magic numbers. Define constants in `lib/src/constants/mp_constants.dart`.
3. Avoid duplicated code. Extract reusable logic into separate methods or widgets.
4. Keep UI logic separate from business logic. Use MobX controllers for business logic and state management.
5. All variable declarations must have explicit type definitions. Avoid `var` when the type is not immediately obvious.
6. Declare variables as `final` whenever possible.
7. Put an empty line between "finals", non-finals and regular code.
8. Avoid complex calculations in a single step. Break them down into intermediate variables with descriptive names.
9. In multiple-condition decisions, wrap all comparisons that involve more than one element in parentheses for clarity.
10. Avoid onliners "if-thens", i.e., always put curly braces around conditional commands.
11. All user-facing strings must be localized via `AppLocalizations`. Do not hardcode displayed text. Localization files: `lib/l10n/intl_en.arb` (English) and `lib/l10n/intl_pt.arb` (Portuguese). Run `flutter gen-l10n` after adding new strings.
12. Don't use all caps in user-facing text.
13. Prefer named parameters; allow positional parameters only when there are at most two parameters and they have different types.
14. Run `flutter analyze` after generating or modifying code.

### When writing scripts (command-line tools)

1. Avoid duplicated code. Extract reusable logic into separate methods.
2. All variable declarations must have explicit type definitions. Avoid `var` when the type is not immediately obvious.
3. Declare variables as `final` whenever possible.
4. Put an empty line between "finals", non-finals and regular code.
5. Avoid complex calculations in a single step. Break them down into intermediate variables with descriptive names.
6. In multiple-condition decisions, wrap all comparisons that involve more than one element in parentheses for clarity.
7. Avoid onliners "if-thens", i.e., always put curly braces around conditional commands.
8. Don't use all caps in user-facing text.
9. Prefer named parameters; allow positional parameters only when there are at most two parameters and they have different types.
10. Run `flutter analyze` after generating or modifying code.

### When writing tests

1. All variable declarations must have explicit type definitions. Avoid `var` when the type is not immediately obvious.
2. Declare variables as `final` whenever possible.
3. Put an empty line between "finals", non-finals and regular code.
4. Avoid complex calculations in a single step. Break them down into intermediate variables with descriptive names.
5. In multiple-condition decisions, wrap all comparisons that involve more than one element in parentheses for clarity.
6. Avoid onliners "if-thens", i.e., always put curly braces around conditional commands.
7. Prefer named parameters; allow positional parameters only when there are at most two parameters and they have different types.
8. Run `flutter analyze` after generating or modifying code.

## Release Targets

Mapiah is released as: Linux/AppImage, Linux/Flatpak (built by a GitHub Action), macOS, and Windows. There is no web or Linux/Flathub version.
