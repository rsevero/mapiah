<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
This dialog runs Therion with the loaded project's root configuration file and shows its output in real time.

## Status

Shows the current state of the Therion run:

* **Running** — Therion is currently executing.
* **Ok** — Therion finished with no warnings or errors.
* **Warning** — Therion finished but reported one or more warnings.
* **Error** — Therion finished with one or more errors, or could not be started.

## Therion run parameters

Optional extra command-line options passed to Therion on every run (e.g. `-d` for debug mode). The value is saved as a persistent setting and can also be set via:

* The **Settings page** (`Therion_RunParameters` field).
* The Mapiah `--therion_run_parameters` command-line argument (see the [Main page help](mapiah_home_help) for details).

## Broken files warning

When you run the loaded project and some of its `.th2` files that Mapiah has already loaded are broken, a warning above the output lists their paths. Therion may fail because of them, but the run starts anyway. The paths are selectable text, and a long list scrolls.

* Only files of the loaded project that is being run are listed, and only those already loaded, by expanding them in the project tree or opening them in a tab. Mapiah does not read other files to look for problems.
* No warning appears when you run a configuration file that is not the loaded project, or right after choosing a project to run, before it has loaded.
* The list is taken when the dialog opens. After fixing and reloading a file, the next run no longer lists it.

## Output

The full text output produced by Therion during the run. After the run finishes, the Therion log file is appended, followed by the start and end times.

* **Warning** and **Error** keywords are highlighted in color.
* The output area is scrollable and its text is selectable.
* Clicking an item in the issues list (see below) scrolls the output to the corresponding line.
* A diagnostic with a recognized project file and source line can open that text tab at the line. Diagnostics without a file or line remain visible here but cannot be mapped to a tree line.

## Elapsed time

Shows the time elapsed since the run started. Updates live every second while Therion is running, then freezes when the run finishes.

## Issues list

When Therion reports warnings or errors, they appear as a scrollable list below the output area. Clicking any item scrolls the output to that line.

## Buttons and keyboard shortcuts

* **Rerun Therion** (keyboard: **T**) — runs Therion again with the same THConfig and current run parameters. Only enabled when Therion is not running.
* **Close** (keyboard: **Escape**) — stops any in-progress Therion run and closes the dialog.
* **Ctrl/Cmd+T** — when no project is loaded, opens a project and starts Therion. It is unavailable for switching projects once a project is loaded or while this run dialog is active.

Compiler diagnostics remain until a subsequent run replaces them; editing a file does not by itself prove that a compiler error is fixed.
