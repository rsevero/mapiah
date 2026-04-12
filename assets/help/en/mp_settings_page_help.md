<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
This page allows you to configure Mapiah's settings. Settings are grouped into sections displayed as cards.

_Note: Mapiah treats the Ctrl and Meta (Command on macOS) keys as interchangeable. Shortcut mentions below use "Ctrl" for brevity._

## Index
- [Index](#index)
- [Using settings](#using-settings)
  - [Resetting a single setting](#resetting-a-single-setting)
  - [Buttons](#buttons)
- [Main section](#main-section)
  - [Language](#language)
- [TH2 edit section](#th2-edit-section)
  - [Enable element transforms](#enable-element-transforms)
  - [Enable special border for ID set](#enable-special-border-for-id-set)
  - [Enable special border for slope line without l-size](#enable-special-border-for-slope-line-without-l-size)
  - [Enable special border for visibility off](#enable-special-border-for-visibility-off)
  - [Line thickness](#line-thickness)
  - [New line creation method](#new-line-creation-method)
  - [Point radius](#point-radius)
  - [Snap angle](#snap-angle)
  - [Selection tolerance](#selection-tolerance)
  - [Show direction ticks on non-selected lines](#show-direction-ticks-on-non-selected-lines)
- [Therion section](#therion-section)
  - [Debug log 1](#debug-log-1)
  - [Therion executable path](#therion-executable-path)
  - [Therion run parameters](#therion-run-parameters)

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

## TH2 edit section

### Enable element transforms
When enabled, selected elements gain scale, rotate, and mirror actions in selection mode. Selection handles can be dragged to scale, clicking the selected elements enters rotation mode, and _H_ / _V_ mirror the current selection. The default is disabled (`false`).

### Enable special border for ID set
When enabled (default), elements with THID/ID set are painted with a dedicated special border on the canvas. Disable this if you prefer those elements to use only their normal symbol styling.

### Enable special border for slope line without l-size
When enabled (default), slope lines whose line segments do not define any `l-size` are painted with a dedicated special border on the canvas. This can help you spot slope lines that still need `l-size` information.

### Enable special border for visibility off
When enabled (default), elements with `visibility off` are painted with a dedicated special border on the canvas. Disable this if you prefer invisible elements not to receive extra visual emphasis while editing.

### Line thickness
Controls the visual thickness (in pixels) of lines drawn on the canvas. This is a display-only setting and does not affect the data stored in the TH2 file.

### New line creation method
Controls the behavior when creating a new line segment by clicking and dragging:
* **Mapiah quadratic**: the drag position is used as the single control point of a quadratic Bézier curve approximation.
* **xTherion cubic smooth**: the drag position becomes the next segment's future control point; the current segment's other control point is mirrored around the shared endpoint. Hold _Ctrl_ while dragging to lock the mirrored control point at a fixed distance. It tries to reproduce XTherion behaviour.

While drawing with either method, the last created node can also be nudged with _Arrow_, _Shift+Arrow_, _Alt+Arrow_, and _Alt+Shift+Arrow_.

### Point radius
Controls the visual radius (in pixels) of points drawn on the canvas. This is a display-only setting and does not affect the data stored in the TH2 file.

### Snap angle
Controls the angular increment (in degrees) used when snapping image rotation. While rotating an image, hold _Ctrl_ to snap the angle to multiples of this value. Set it to `0` to disable snapping even while _Ctrl_ is held.

### Selection tolerance
Controls how close the mouse cursor must be to an element (in pixels) for it to be considered clicked and selected. Increasing this value makes elements easier to click.

### Show direction ticks on non-selected lines
When enabled, direction ticks are drawn on all lines in the active scrap, regardless of selection. When disabled (default), only selected lines show direction ticks. Can also be toggled with **Ctrl+Alt+R**.

## Therion section

### Debug log 1
When enabled, Mapiah shows extra Therion startup and run diagnostics. The default is disabled (`false`).

### Therion executable path
The full path to the Therion executable on your system. Required for the _Run Therion_ feature to work. Click the folder icon or tap the field to open a file picker and navigate to the Therion binary.

### Therion run parameters
Optional extra command-line options passed to Therion on every run (e.g. `-d` for debug mode, `-q` for quiet mode). Multiple options can be entered space-separated. The value is also editable directly in the Run Therion dialog and can be preset via the `--therion_run_parameters` Mapiah command-line argument. Default is empty (no extra options).
