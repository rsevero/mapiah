<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
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
# Main checkout: do not run build_runner; the watch instance regenerates MobX.
# In a worktree: dart run build_runner build --delete-conflicting-outputs (see Parallel Work)
flutter gen-l10n                   # Generate localizations after .arb edits
```

## Architecture Summary

### State Management: MobX

Controllers in lib/src/controllers/ use @observable/@action. In the main checkout, the build_runner watch regenerates `.g.dart` files after modifications; do not run `build_runner` there. The watch doesn't see worktrees: see Parallel Work.

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

* th2_file_tabs_page.dart — Root project workspace with tabbed canvas/text editors
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

* cc: Update CHANGELOG.md + prepare commit on the task's branch, inside the task's worktree (see Parallel Work). Always asks for confirmation of commit message before actually commiting.
* ccm: Like cc, then merges the branch into main, removes the worktree and deletes the branch (see Parallel Work, "Finishing").
* Commit messages should include Assisted_By/Signed-off-by (first Assisted_By: and then finish with Signed-off-by:) when appliable.
* hpcc: Update help pages (EN/PT) + keyboard shortcuts + cc above

### Parallel Work: Branches and Worktrees

Several agents may work on different issues at the same time. Each one works in its own branch **and** its own worktree, so no agent ever changes another agent's files, index or checked-out branch.

**The main checkout** (`/home/rodrigo/devel/mapiah`) belongs to the user:
* It always stays on `main`. Never run `git switch`/`git checkout <branch>` there.
* Never edit, stage, commit, stash, reset or clean files there. Uncommitted changes in it are the user's or another agent's work in progress.
* The only git command an agent runs there is the final `git merge --ff-only` of "Finishing".
* Read-only tasks (questions, reviews, analysis) can run from it, without a worktree.

**Starting a task that changes files**, before editing anything:
1. Pick a branch name: `<type>_<issue>_<slug>` (type: `feat`, `fix`, `docs`, `refactor`, `test`), e.g. `fix_46_xtherion_image_format`. Without an issue: `<type>_<slug>`. Check it doesn't exist yet (`git branch --list <name>`).
2. Create the worktree from the current `main`: `git worktree add -b <branch> ../mapiah-worktrees/<branch> main`.
3. Work only inside that worktree: use its absolute path for every file edit and run every command there (`git -C <worktree> …`, or `cd` into it).
4. Run `flutter pub get` in it once.

**Inside a worktree:**
* The build_runner watch only covers the main checkout. After changing MobX-annotated code (`@observable`, `@action`, `@computed`, `@readonly`), run `dart run build_runner build --delete-conflicting-outputs` in the worktree, and commit the regenerated `.g.dart` files.
* `flutter gen-l10n`, `flutter analyze` and `flutter test` run in the worktree, on its code.
* Touch only your own branch and worktree. Never switch, reset, rebase, delete or force-update another agent's branch, and never remove another worktree. When `git worktree list` or `git branch` shows something you didn't create, leave it alone.

**Committing (cc):**
* Run `git status` in the worktree first. Stage the task's files by path. `git add -A` is fine only when `git status` shows nothing but the task's files.
* Ask authorization for staging and committing in the same step, after showing the complete commit message.

**Finishing (ccm)**, after the commit:
1. Bring the branch up to date: `git -C <worktree> rebase main`. On a conflict in `CHANGELOG.md`, keep both entries. For any other conflict, stop and ask.
2. Run `flutter analyze` and `flutter test` in the worktree again if the rebase brought in new commits.
3. Merge: `git -C /home/rodrigo/devel/mapiah merge --ff-only <branch>`. If it fails because `main` moved (another agent merged first), go back to step 1. If it fails because of the user's uncommitted changes in the main checkout, stop and ask. Never use a merge commit, `--force` or `reset` to get past it.
4. Clean up: `git worktree remove ../mapiah-worktrees/<branch>`, then `git branch -d <branch>`. If either refuses (uncommitted or unmerged work), stop and ask. Never use `--force` or `-D`.
* Never push unless asked.

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
* Each feature/bugfix gets its own branch and worktree (see Parallel Work).

### For every prompt:

1. Run 'flutter analyze' (in the task's worktree when there is one)
2. Summarize diffs

### Release Targets

See release-targets.md — Linux (AppImage/Flatpak), macOS, Windows (no web/Flathub).

When commiting:
* When presenting a commit message, show the complete message before actually asking for permission so I can see it all.
* Ask for authorization for staging and for the commit at the same step (see Parallel Work, "Committing").

See coding-guidelines.md for detailed coding rules.

See release-targets.md for release.
