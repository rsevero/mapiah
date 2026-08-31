<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Initial workspace page where the project tree, file tabs, and main actions are presented.

_Note: Mapiah treats the Ctrl and Meta (Command on macOS) keys as interchangeable. Shortcut mentions below use "Ctrl" for brevity._

## Project workflow

**Open project** is the normal entry point for a Therion project. Select any root configuration filename, including a configuration without the `.thconfig` extension. Mapiah loads that file and recursively follows its `source`, `input`, and related references into the project tree. Opening another project replaces the loaded tree; the usual file-tab lifecycle is preserved.

The sidebar contains file nodes and logical nodes. File nodes represent `thconfig`, `.th`, and `.th2` source files. Logical nodes represent scraps, surveys, maps, and centrelines discovered in those files. Use the search field to filter nodes and the chevrons to expand or collapse branches. The sidebar width and collapsed state are persisted in settings. A dirty marker means a text file has unsaved changes. Error indicators identify parser or compiler diagnostics; missing files and circular references are reported as project errors.

Click a `.th2` file node to open its canvas tab. Click a `thconfig` or `.th` node to open its text tab. Clicking a scrap, survey, map, or centreline selects the corresponding source and navigates to its location when a source line is available.

Use **Run Therion** to run the loaded project's root configuration. In the empty state, the project-tree Run Therion action opens a project and runs it. With a project loaded, the action reruns that project. Compiler diagnostics replace the previous run's compiler diagnostics after the next run; editing alone does not clear them.

## Standalone `.th2` files

Standalone drawings can be opened by clicking a `.th2` file node in a loaded project, or at startup with a positional path or the `--th2` option. `Ctrl/Cmd+O` opens a project in the workspace; it is not a standalone-file picker.

```bash
mapiah file.th2
mapiah --th2 file.th2
```

## Top bar

* **Open project**: opens a project configuration in the workspace. `Ctrl/Cmd+O` and `Ctrl/Cmd+Shift+O` use this project-opening action.
* **Run Therion**: runs the loaded project, or opens a project and runs it when no project is loaded.
* **Settings page**: opens application settings.
* **Keyboard shortcuts page**: shows the available shortcuts.
* **Help**: shows this dialog.
* **About**: shows application information.

## Command-line Arguments

Mapiah supports command-line arguments to open files directly when starting.

### Positional Arguments

```bash
mapiah /path/to/file.th2          # Opens a standalone TH2 canvas
mapiah /path/to/therion.cfg       # Loads the project and runs Therion
```

Mapiah detects TH2 files by their `.th2` extension and treats any other file as a project configuration. The selected configuration becomes the root of the project tree.

### Named Arguments

#### --th2: Open standalone TH2 files

This option can appear multiple times; each file opens in a separate canvas tab.

```bash
mapiah --th2 file1.th2 --th2 file2.th2
mapiah --th2 /path/to/survey.th2
```

#### --thconfig: Load and run a project

Use at most one `--thconfig` per command. The project tree is loaded for the selected configuration, whose filename does not need to end in `.thconfig`.

```bash
mapiah --thconfig project.cfg
mapiah --thconfig /path/to/therion.cfg
```

#### --therion_run_parameters: Set Therion command-line options

Sets extra options passed to Therion when compiling (for example, `-d` for debug mode). The value is persisted as the `Main_TherionRunParameters` setting.

```bash
mapiah --therion_run_parameters "-d -q"
mapiah --thconfig project.cfg --therion_run_parameters "-d"
```

If a required flag value is missing, or more than one `--thconfig` is provided, Mapiah exits with an error.
