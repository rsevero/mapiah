<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
This dialog runs Therion with the selected THConfig file and shows its output in real time.

## Status

Shows the current state of the Therion run:

* **Running** — Therion is currently executing.
* **Ok** — Therion finished with no warnings or errors.
* **Warning** — Therion finished but reported one or more warnings.
* **Error** — Therion finished with one or more errors, or could not be started.

## Therion run parameters

Optional extra command-line options passed to Therion on every run (e.g. `-d` for debug mode). The value is saved as a persistent setting and can also be set via:

* The **Settings page** (`Main_TherionRunParameters` field).
* The Mapiah `--therion_run_parameters` command-line argument (see the [Main page help](mapiah_home_help) for details).

## Output

The full text output produced by Therion during the run. After the run finishes, the Therion log file is appended, followed by the start and end times.

* **Warning** and **Error** keywords are highlighted in color.
* The output area is scrollable and its text is selectable.
* Clicking an item in the issues list (see below) scrolls the output to the corresponding line.

## Elapsed time

Shows the time elapsed since the run started. Updates live every second while Therion is running, then freezes when the run finishes.

## Issues list

When Therion reports warnings or errors, they appear as a scrollable list below the output area. Clicking any item scrolls the output to that line.

## Buttons and keyboard shortcuts

* **Rerun Therion** (keyboard: **T**) — runs Therion again with the same THConfig and current run parameters. Only enabled when Therion is not running.
* **Close** (keyboard: **Escape**) — stops any in-progress Therion run and closes the dialog.
* Keyboard: **Ctrl+T** — closes the dialog and reopens the THConfig file picker so you can choose a different THConfig.
