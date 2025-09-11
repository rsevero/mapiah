# Changelog

## 0.2.16 - not release yet
* New features:
  * Using _MPOverlayWindowBlockWidget_ at _MPSnapTargetsWidget_ to improve reading.
  * Snap to XVI file features.
* Fixed bugs:
* Infrastructure maintenance:

## 0.2.15 - 2025-09-11
* New features:
  * Loading images on web.
  * Added keyboard shortcuts for initial page.
  * Support Cmd+keyboard shortcuts on MacOS.
  * Escape dismisses overlay modal windows.
  * Writing XTherion configs together at the beginning of THFile.
  * Snap to points and line points.
* Fixed bugs:
  * Going back to _file_picker_ 10.2.1 as 10.3.2 broke initial directory setting.
  * Encodings got from _therion --print-encodings_ could overwrite encoding got from file called by command line.
* Infrastructure maintenance:
  * flutter pub upgrade.
  * Flutter upgrade to 3.35.3.

## 0.2.14 - 2025-09-04
* New features:
  * Get list of available encodings from 'therion --print-encodings'.
  * Create new th2 file.
  * Create scrap dialog presenting both scrap scale and projection used both in scrap and in file creation.
  * On save as, force '.th2' extension.
  * Support for unknown point, line, and area types.
* Fixed bugs:
  * Multiple clicks in radio groups sometimes raised "RadioGroup policy does not support multiple selected items".
  * Editing scrap multiple options option not working.
  * Regression that blocked element options editing after inclusion of support for scrap options.
  * MPAddLineCommand.fromExisting leaves addAreaTHIDCommand parameter uninitialized when line wasn´t part of an area.
  * Filename at status bar not updated after save as.
  * Parsing of scrap projection elevation with angle but no index failing.
* Infrastructure maintenance:
  * Separating _mp_projection_option_widget_ in _mp_projection_option_widget_ and _mp_projection_option_overlay_window_widget_ so _mp_projection_option_widget_ can be reused in _mp_add_file_dialog_widget_.
  * Substituting placeholder at THCommandOption creation.
  * flutter pub upgrade.

## 0.2.13 - 2025-08-29
* New features:
  * Included 'add image' button in 'add elements' button options.
  * Create new scrap [requested by Marco Corvi].
  * Remove scrap.
  * Undoing a scrap removal should make the restored scrap active.
  * Removing a line that defines a border of an area removes the link between the line and the area.
* Fixed bugs:
  * Opening the help with a dialog on display the dialog did not close [reported by Marco Corvi].
  * saveAs suggested filename included the original path.
  * Point not selectable after undoing delete.
  * Points weren't removed when redoing scrap remove.
  * Add area status message not removed after leaving add area state.
* Infrastructure maintenance:
  * Refactored MPAdd elements commands to improve readbility and facilitate recursive-like use.
  * Flutter upgraded to 3.35.2.
  * Flutter pub upgrade
  * Simplified elements isSelected management.

## 0.2.12 - 2025-08-21
* New features:
  * Open th2 file from command line [proposed and implemented by Thomas Holder]
  * Moving control points in smooth line segments should move the other control point visually attached to the same end point.
  * When editing smooth option, the affected endpoints are automatically redrawn to indicate the new smooth setting.
  * When setting 'smooth' option to on on line segments, the bezier curve line segments should be smoothed.
  * Consider XVI and raster image files bounding boxes when calculating THFile bounding box.
* Fixed bugs:
  * Setting multiple option options in line segments not working.
  * Clicking in another controlpoint after moving a control point would unselect everything.
  * Making selection tolerance and point radius the same to avoid clicking near the border of a point and not selecting it.
  * When selecting a control point 1 the control points of the adjacent line segments weren't properly selected.
  * Changing first point of a line to bezier curve throws an exception.
  * When a Bèzier control point is selected, an end point appears as selected also.
  * When multiple elements are selected and the user asks for the options window, options that were set on the last selected element would be shown as if it were selected for all elements.
  * Right clicking anywhere when a control point is selected raises an exception.
  * Opening a TH2 file that calls for a non existent XVI file should not hang Mapiah.
  * Opening a TH2 file that calls for an non existent raster image should not raise an exception.
* Infrastructure maintenance:
  * Migrated MPMultipleElementsCommand constructors to MPMultipleElementsCommandFactory.
  * Adopted RadioGroup: https://docs.flutter.dev/release/breaking-changes/radio-api-redesign
  * Fixed 'file_picker version 10.3.1 won´t show any files if 'allowedExtensions' is set'.

## 0.2.11 - 2025-08-15
* Flutter upgrade to 3.35.1
* pub upgrade
* Temporarily fixed file_picker version to 10.2.1 as 10.3.1 won´t show any files if allowedExtensions is set.
* Fixed issue [Fails to parse more than one backslash](https://github.com/rsevero/mapiah/issues/8) [reported by speleo3]
* Fixed issue [Support more than one custom attribute](https://github.com/rsevero/mapiah/issues/9) [reported by speleo3]
* Fixed 'quoted (and bracket) contents with line breaks inside should retain the line breaks'

## 0.2.10 - 2025-08-08
* Web: fixed min and max int constants for web compatibility

## 0.2.9 - 2025-08-08
* Web release: automated
* xth_me_image_insert support for XVI, jpg, png, gif, etc
* Fixed 'on opening edited file after saveAs, the old file opened with the changes that should be only on the saveAs file'
* Flutter upgrade to 3.32.8
* Included canvas position in mouse position debug

## 0.2.8 - 2025-07-01
* Web release: fixed 'save not working' [reported by CaverBruce]

## 0.2.7 - 2025-07-01
* Keyboard shortcuts should respect the same enabling conditions as buttons
* Web release: debugging save

## 0.2.6 - 2025-06-30
* Linux release in appimage format (automated)
* Web release: remove context menu from right clicks
* Web release: fixed nextUp() and nextDown() that were messing with bounding box calculations
* Flutter upgraded to 3.32.5; pub upgrade

## 0.2.5 - 2025-06-21
* 'point -value' and 'line -altitude' options: quoted and bracket string support
* Preserving original line endings in save
* Fixed for Windows [Neither Windows App or Web App js are saving correctly, Windows App opens wrong file](https://github.com/rsevero/mapiah/issues/6) [reported by CaverBruce]
* Fixed [line wall subtypes deleted on save](https://github.com/rsevero/mapiah/issues/7) [reported by CaverBruce]

## 0.2.4 - 2025-06-16
* Included links to CHANGELOG and LICENSE in _About_ dialog
* Included release date in CHANGELOG
* Fixing 'right clicking without any objects selected presents ineffective options overlay window' [reported by Bruce Mutton]
* Explaining how to edit element options in the help page
* Fixing 'divide by zero on empty file zoom calculation'
* TH2FileEditPageHelp: explaining behaviour during Bézier Curve line segment creation
* README.md: Microsfot Defender false flagging Mapiah Setup exe file as having trojan horses
* Explaining how to edit element options in the help page
* Fixing 'scrap scale length too big for small files' [reported by Bruce Mutton]
* TH2FileEditPageHelp: explaining save on web releases
* Including link for officially supported browser for Flutter web apps
* Fixing 'scrap IDs are extended keywords' [reported by Axel Hack]
* Fixing lack of -attr command option support [reported by Axel Hack]
* First MacOS release (already automated) [thanks to Christian de Jongh]
* Automated Window releases

## 0.2.3 - 2025-06-13
- Flutter upgraded to 3.32.4; pub upgrade
- Windows release creation
- Fixing 'Failure to parse -scrap option with quoted value' [reported by Wookey]

## 0.2.2 - 2025-06-12
- file_picker update: might fix 'file picker not showing files on debian'
- Updating index.html
- Creating WASM web release

## 0.2.1 - not released
- Fixing tests after parse() signature change
- Fixing href on index.html for web release
- Flutter: upgrading to 3.32.3
- Show english help page if there is no translated help page
- New WASM web release.

## 0.2.0 - 2025-06-10
- Make output identical to original except on changed lines
- Deal with click on more than one object at a time
- Line edit
- Point and line remove
- Point and line add
- Status message totaling selected objects
- Rename Stores to Controllers
- All buttons (including zoom buttons) should use default button color
- Different points and line representations
- Areas
- Scrap options
- Line segment options
- Show direction of lines
- Add/delete line segments in existing lines
s- Release creation Linux
- Help pages
- Quick introduction guide
- BUG: point arrow should be filled
- BUG: last used point type not updating
- BUG: saveAs didn't save the changes
- BUG: corrigindo set/unset de originalLineInTH@File: MPSetOptionToElementCommand
- BUG: distinguir execute command normal dos gerados por undos: os dos undos devem manter originalLineInTH2File, os normais não.
- BUG: 'N' not starting line edit mode
- BUG: clicking on line segment is not selecting nodes in line edit
- BUG: multiple control points overlay window opening far away from clicked points
- BUG: opening a new PLA type/option window does not close another PLA type/option window already opened
- Enhancement: when start draging in edit single line mode, prefer endpoints to control points if no 'multiple points clicked'
- BUG: fix == operator signature
- BUG: deleted line points not available at undo/redo
- BUG: clicking on another element when on 'single line edit mode' does not selects the new element
- BUG: Save button should be disabled when there is no change to save
- BUG: when trying to move objects, a new selection window is being drawn
- BUG: added elements get inserted at the end of the file, after the endscrap element
- BUG: new lines are created without its correspondent endline element
- BUG: add area not working
- BUG: clicking on selected control point over end point not moving the control point
