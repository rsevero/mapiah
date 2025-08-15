# Changelog

## 0.2.11 - 2025-08-15
* Flutter upgrade to 3.35.1
* pub upgrade
* Temporarily fixed file_picker version to 10.2.1 as 10.3.1 won´t show any files if I set allowedExtensions.

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
