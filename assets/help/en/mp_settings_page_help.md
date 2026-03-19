<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
This page allows you to configure Mapiah's settings. Settings are grouped into sections displayed as cards.

## Index
- [Index](#index)
- [Using settings](#using-settings)
  - [Resetting a single setting](#resetting-a-single-setting)
  - [Buttons](#buttons)
- [Main section](#main-section)
  - [Language](#language)
  - [Therion executable path](#therion-executable-path)
- [TH2 edit section](#th2-edit-section)
  - [Line thickness](#line-thickness)
  - [New line creation method](#new-line-creation-method)
  - [Point radius](#point-radius)
  - [Selection tolerance](#selection-tolerance)

## Using settings

Changes made on the settings page are not applied immediately. They are held as draft values until you explicitly save or apply them.

### Resetting a single setting
Each setting has a reset button (↺) on its right side. Clicking it reverts that setting to its default value in the draft, without saving.

### Buttons
* **Save & Close**: applies all draft changes and closes the settings page. If any field contains an invalid value, the save is blocked and the invalid fields are highlighted.
* **Apply**: applies all draft changes but keeps the settings page open.
* **Cancel**: discards all draft changes and closes the settings page.
* **Reset all settings**: reverts all settings to their default values in the draft, without saving.

## Main section

### Language
Selects the language used throughout the app interface. The default option follows the system locale. Changing this setting takes effect after applying and reopening any currently open pages.

### Therion executable path
The full path to the Therion executable on your system. Required for the _Run Therion_ feature to work. Click the folder icon or tap the field to open a file picker and navigate to the Therion binary.

## TH2 edit section

### Line thickness
Controls the visual thickness (in pixels) of lines drawn on the canvas. This is a display-only setting and does not affect the data stored in the TH2 file.

### New line creation method
Controls the behavior when creating a new line segment by clicking and dragging:
* **Mapiah quadratic**: the drag position is used as the single control point of a quadratic Bézier curve approximation.
* **xTherion cubic smooth**: the drag position becomes the next segment's future control point; the current segment's other control point is mirrored around the shared endpoint. Hold _Ctrl_ while dragging to lock the mirrored control point at a fixed distance. It tries to reproduce XTherion behaviour.

### Point radius
Controls the visual radius (in pixels) of points drawn on the canvas. This is a display-only setting and does not affect the data stored in the TH2 file.

### Selection tolerance
Controls how close the mouse cursor must be to an element (in pixels) for it to be considered clicked and selected. Increasing this value makes elements easier to click.
