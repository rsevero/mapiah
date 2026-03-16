<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Initial app page where its main functions are presented.

## Top bar
* ![New file icon](assets/help/images/iconNewFile.png "New file") _New file_: creates new project.
* ![File open icon](assets/help/images/iconOpenFile.png "File open")  _File open_: shows system dialog where its possible to choose which file(s) should be opened. You can select multiple files at once (using Ctrl+Click or Shift+Click) to open them all simultaneously in separate tabs.
* ![Choose THConfig file and run Therion icon](assets/help/images/iconChooseTHConfigAndRunTherion.png "Choose THConfig file and run Therion") _Choose THConfig file and run Therion_: shows system dialog where its possible to choose which THConfig file should be used to run Therion.
* ![Run Therion icon](assets/help/images/iconRunTherion.png "Run Therion")" _Run Therion_: runs Therion with currently opened project.
* ![Settings page icon](assets/help/images/iconSettings.png "Settings page") _Settings page_: shows settings page where it's possible to change app's settings.
* ![Keyboard shortcuts page icon](assets/help/images/iconKeyboardShortcuts.png "Keyboard shortcuts page") _Keyboard shortcuts page_: shows keyboard shortcuts page where it's possible to see all available keyboard shortcuts.
* ![Help icon](assets/help/images/iconHelp.png "Help") _Help_: show this dialog box.
* ![About icon](assets/help/images/iconAbout.png "About")_About_: apps metainfo.

## Opening Multiple Files

You can open multiple TH2 files at the same time. When you click the _File open_ button, the file selection dialog allows you to select more than one file:

* Hold **Ctrl** and click on files to select multiple files individually
* Hold **Shift** and click to select a range of files
* Click **Open** to open all selected files in separate tabs

All selected files will be opened in the file editor with each file having its own tab. You can easily switch between open files by clicking on their tabs, or use keyboard navigation to move between them.

## Command-line Arguments

Mapiah supports command-line arguments to open files directly when starting:

### Positional Arguments (Backward Compatible)
```bash
mapiah /path/to/file.th2          # Opens TH2 file
mapiah /path/to/therion.cfg       # Runs Therion with config
```

It detects TH2 files by their .th2 extension, and treats any other file as a THConfig for running Therion. This allows backward compatibility with previous versions of Mapiah that only accepted a single positional argument.

### Named Arguments

#### --th2: Open TH2 files
- Can appear multiple times to open multiple files
- Each file opens in a separate tab

```bash
mapiah --th2 file1.th2 --th2 file2.th2
mapiah --th2 /path/to/survey.th2
```

#### --thconfig: Run Therion with THConfig
- Maximum of one --thconfig per command
- Will show error if multiple --thconfig arguments provided

```bash
mapiah --thconfig project.cfg
mapiah --thconfig /path/to/therion.cfg
```

#### Combining Arguments
```bash
# Open multiple TH2 files AND run Therion with config
mapiah --th2 file1.th2 --th2 file2.th2 --thconfig project.cfg
```

### Error Handling
- If multiple `--thconfig` arguments are provided, Mapiah will exit with an error message
- If `--th2` or `--thconfig` flag is provided without a file path, Mapiah will exit with an error message
