# Changelog

## 0.2.27 - not yet released
* New features:
* Fixed bugs:
* Infrastructure maintenance:
  * flutter pub upgrade --major-versions.
  * Created onDeselectAll() and onSelectAll() state and actuator methods.
  * Migrate select and desselect all elements to use onDeselectAll() and onSelectAll().

## 0.2.26 - 2025-12-11 - The São Paulo release
* New features:
  * Snap to "points", "line points" and "XVI shots" on as default.
  * Snap should snap to own object points and line points.
  * Non selected lines not showing direction line ticks.
  * Support reading files with ID and NAME values with invalid chars like spaces. The invalid chars are converted to underline.
  * Clarification of situations were Mapiah does not preserve the original file format included in help page.
  * When there is some snap option enabled, the "snap" button should be visually different.
  * ID written as the first PLA option on file.
  * Saving the file closes auto dismissable overlay windows.
  * Keyboard shorcut to toogle smooth between "on/unset".
* Fixed bugs:
  * Lines with duplicated subsequent line points would block the drawing of further elements.
  * On 'single line edit' mode:
    * further editing a line after removing its first line segment would throw;
    * clicking on empty space to dismiss a 'multiple elements selected' dialog box because the user clicked on an area throws;
    * after simplifying a line, it's not possible to select the line by clicking over the new path, only on the old one.
  * Line options included in [LINE DATA] area would not be preserved in save.
  * When setting an option, its overlay window is not closing.
  * On 'Ctrl+A', status bar remains 'empty selection'.
* Infrastructure maintenance:
  * Speeding up file opening with faster _findLineBreak() implementation.
  * flutter upgrade 3.38.4.
  * Improved 'single line edit' mode processing of clicks outside selected line by changing to 'non empty selected' mode and letting it deal with the clicks after that.
  * Major refactoring of line and line segment edit/add/remove changes propagation to all controllers.
  * Add tests to check IDs and references with invalid chars like spaces are properly read and written.
  * Seting 'empty selection' mode after undo/redo of commands.

## 0.2.25 - 2025-12-05 - The runaway point regression release
* Fixed bugs:
  * REGRESSION: when moving points, they would change position exponentially in relation to mouse movement.

## 0.2.24 - 2025-12-04 - The Peruaçu data processing release
* New features:
  * When a single element is selected, show its properties in the status bar.
  * Simplification calculated values should use "current decimals".
  * When a line is deleted, if it's the last line of an area, the area should also be deleted.
  * When deleting the second to last line segment of a line, the whole line should be deleted.
  * When the last area border THID of an area is deleted, the area itself is deleted.
  * On 'single line edit' mode:
    * when a endpoint is selected, clicking on a control point and dragging should work.
  * On single element selected status bar, include the name of the unknown PLA type when the element type is unknown.
* Fixed bugs:
  * Lines and points with unknown types would throw when being drawn.
  * Walkway line type not recognized.
  * Floor-step (and all hyphenated) line types not recognized.
  * 'UI: simplify line through Ctrl+L' test fails with widget width overflow.
  * When simplifying a line, line segment options are being lost.
  * Line segment options being lost when saving preserving original lines.
  * When simplifying a line being node edited, the visual editing points are not immediatly updated.
  * On certain occasions, when simplifying straight lines to Bézier, there were Ss created on the resulting lines.
  * Line types "Floor Step" and "floor-step" being presented.
  * On 'simplify line forcing to Bézier' the undo description says a generic 'substitute line segments'.
  * On 'single line edit' mode:
    * if the direction of the line is inverted, the screen does not show it;
    * if the user clicks on another element, the 'Multiple elements clicked' dialog box is presented instead of just selecting the new element;
    * when end points are deleted, they remain visually shown as part of the line;
    * when dragging several end points, the clicked at button down end point isn't positioned exactly at the end position of the mouse;
    * after deleting line points, the shape of the line would be different at the 'single line edit' view and the normal view;
    * after deleting several line points, the line is not click-selectable at its new line segments.
  * Moving lines moving only the selection handles but not the line itself.
* Infrastructure maintenance:
  * Creating TH2FileEditElementEditController._lineSegmentsWithOptionsToPreserveSimplification set to keep track of line segments that have options to preserve during simplification.
  * MPEditElementAux.separateLineSegmentsPerType() moved to TH2FileEditElementEditController.groupLineSegmentsForSimplification().
  * THHasOptionsMixin constructors now receive optionsMap and attrOptionsMap parameters to initialize the element with existing options maps.
  * Identifying methods and classes actually used in line simplification with a 'MPSimplification' prefix in their names.
  * Moved fromExisting constructors from individual MPCommand classes to MPCommandFactory:
    * add:
      * area;
      * areaBorderTHID;
      * element;
      * empty line;
      * line;
      * line segment;
      * point;
      * scrap;
      * XTherionImageInsertConfig;
    * remove:
      * area;
      * element;
      * line;
      * point;
      * scrap;
      * XTherionImageInsertConfig.
  * Removed:
    *  MPEmptyLinesAfterMixin;
    *  MPScrapChildrenMixin.

## 0.2.23 - 2025-11-27 - The Peruaçu release
* New features:
  * Add/remove commmands removing empty lines after element selected for deletion:
    * AreaBorderTHID;
    * Area;
    * Element;
    * Line;
    * Line segment;
    * Point;
    * Scrap;
    * XTherionImageInsertConfig.
  * Removing last area border THID from area removes the area.
  * Removing all or all but one line segments from line removes the line.
* Fixed bugs:
  * MPCommandFactory.removeElements() does not use provided description type.
  * Empty lines not being properly represented as original version.
* Infrastructure maintenance:
  * Flutter upgraded to 3.38.3.
  * flutter pub upgrade --major-versions
  * MPCommandFactory.[add/remove]elements() using all specific add/remove commands.
  * Created MP[Add|Remove]ElementCommand.
  * Created MP[Add|Remove]EmptyLineCommand.

## 0.2.22 - 2025-11-13 - The line simplification release
* New features:
  * Simplify complex (that contains straight and Bézier curve segments) lines.
  * Keyboard shortcuts help page.
  * Simplified line segments forced to Bézier curves (Ctrl+Alt+L).
  * Simplified line segments forced to straight (Ctrl+Shift+L).
* Fixed bugs:
  * Select and Node Edit buttons enabling/disabling logic.
  * On Bézier curve line simplification, first line segment being lost.
  * When several elements are selected and one is deselected, the status bar message is not updated.
* Infrastructure maintenance:
  * Added test:
    * Open a file, select a line and simplify pressing Ctrl+L.
  * Fixed Bézier spelling.
  * Improving line segments list line generation.
  * Flutter upgraded to 3.38.1.

## 0.2.21 - 2025-11-06 - Life isn't only programming
* New features:
  * Setting canvas scale to 100% for new files.
* Fixed bugs:
  * New files don´t update internal status on element add/edit/remove: caused all kinds of strange problems on new file editing.
  * On line creation, smooth option was set to Bézier line segments but control points were adjusted only after line creation completion.
* Infrastructure maintenance:
  * Added tests:
    * asserting the fitter first command is always a moveTo before any curveTo, ensuring regressions don’t return;
    * editing a new line in a new file.
  * flutter pub upgrade --major-versions:
    * upgraded to petite_parser 7.0.1.

## 0.2.20 - 2025-11-01 - The polish refactoring - Part 2, The Pará Ending
* New features:
  * Bézier curve lines simplification.
* Fixed bugs:
  * Delete button only removes points and lines but no areas.
  * Original TH2File line management in MPRemoveAttrOptionFromElementCommand and MPSetAttrOptionToElementCommand.
  * Sometimes PLA options not presented in alphabetical order.
  * PLA original TH2File lost on setattr option undo/redo.
  * File parsing with XTherion Insert Image Config being treated as if the last image set doesn't exist.
  * Line creation with Bézier segments throwing "Command of type editLineSegment needs to prepare undo/redo info but did not.".
  * THFile.copyWith() does not deep copy elements.
  * Repetitive line simplification isn´t written in file.
* Infrastructure maintenance:
  * THCommmandOption changed from having its parent to having only its parent MPID.
  * MPCommand migration to _prepareUndoRedoInfo() completed.
  * Added tests:
    * MPRemoveAreaCommand;
    * MPRemoveAttrOptionFromElementCommand;
    * MPRemoveLineCommand;
    * MPRemoveLineSegmentCommand;
    * MPRemoveOptionFromElementCommand;
    * MPRemovePointCommand:
    * MPRemoveScrapCommand:
    * MPRemoveXTherionImageInsertConfigCommand;
    * MPReplaceLineSegmentsCommand;
    * MPSetAttrOptionFromElementCommand;
    * MPSetOptionFromElementCommand;
    * UI: add line via mouse click + drag;
    * UI: new file dialog flow.
  * Migrated to new MPCommand execute (the polish refactoring):
    * MPMoveAreaCommand;
    * MPMoveLineCommand;
    * MPRemoveAreaCommand;
    * MPRemoveAttrOptionFromElementCommand;
    * MPRemoveLineCommand;
    * MPRemoveLineSegmentCommand;
    * MPRemoveOptionFromElementCommand
    * MPRemovePointCommand;
    * MPRemoveScrapCommand;
    * MPRemoveXTherionImageInsertConfigCommand;
    * MPReplaceLineSegmentsCommand;
    * MPSetAttrOptionFromElementCommand;
    * MPSetOptionFromElementCommand.
  * Create at least one test per MPCommand.
  * Change MPCommand execute/creteUndoRedoCommand logic to: on execute, each command saves any pre execute info it might need to create its undo version but only after actual execute the undo command is actually created. This new method is important so MPMultipleCommandsCommand can properly create its undo command.
  * MPMultipleCommandsCommand undo will be created after execute (as all MPCommands will do) by creating the reverse list of each of its own subcommands for their undo command.
  * flutter upgrade to 3.35.7.
  * Changed undoRedoController.executeAndSubstituteLastUndo() to executeSubstitutingLastUndo().

## 0.2.19 - 2025-10-14 - The polish refactoring - Part 1
* Fixed bugs:
  * THFile creation through forCWJM constructor resulted in duplicated childrenMPIDs.
  * Hash calculation and == operator not working in most elements with list or maps.
  * No implementation found for method getApplicationDocumentsDirectory.
  * Original TH2FileLine being lost on set option.
  * Undoing add area left an empty area hanging.
  * Only adding THIDs to new areas if necessary to create a line THID.
  * Add line should not checking for Meta key.
  * Multiple line segment addition positioning new line segments after first at wrong position.
  * LineSegmentsMPIDs in wrong order after line segment addition.
  * Add line segments control point should be exact, i.e., not use currentDecimalPositions.
  * When adding line segment to Bézier curve line segment, new calculated control point values not saved.
  * XTherion settings written before encoding.
  * Area original line lost on area type change undo.
  * Original TH2 file representation lost on some situaitons for MPMoveBezierLineSegmentCommand.
  * THScrapScaleCommandoption hash code marking equal elements as different.
  * THStationsCommandoption hash code marking equal elements as different.
* Infrastructure maintenance:
  * Fixing error 'Binding has not yet been initialized' on all tests.
  * Removing pub test.
  * flutter pub upgrade --major-versions.
  * Implemented MPAddAreaTHIDCommand test.
  * Renamed MPTH2FileEditStateSingleLineEdit to MPTH2FileEditStateEditSingleLine
  * flutter upgrade to 3.35.6
  * Created MPCommandFactory.addXTherionInsertImageConfig().
  * Removed mpCalculatedDecimalPositions constant.
  * Added getAreas(), getLines() and getPoints() methods to THScrap.
  * Changed mpMaxDecimalPositions from 12 to 6.
  * Created find_deprecated_packages script.
  * Renamed originalXXX/modifiedXXX to fromXXX/toXXX in MPMoveLineCommands.
  * Changed scrapMPIDs, imageMPIDs and xtherionSettingMPIDs in THFile from Set to List so they indicate the order of the elements in the file.
  * Checking if _prepare_UndoRedoInfo() has been called on commands whose _createUndoRedoCommand() depends on it.
  * Created hash code debug methods for:
    * THCommandOption;
    * THDoublePart;
    * THElement;
    * THLengthUnitPart;
    * THScrap;
    * THScrapScaleCommandOption.
  * Added tests:
    * add area THID that creates area and line THIDs;
    * add area;
    * add line segment;
    * add line;
    * add point;
    * add scrap;
    * add XTherionImageInsert;
    * MPEditAreaTypeCommand;
    * MPEditLineSegmentCommand;
    * MPEditLineTypeCommand;
    * MPEditPointTypeCommand;
    * MPMoveBezierLineSegmentCommand;
    * MPMoveLineCommand;
    * MPMovePointCommand;
    * MPMoveStraightLineSegmentCommand;
    * MPRemoveAreaBorderTHIDCommand.
  * Migrated to new MPCommand execute (the polish refactoring):
    * MPAddAreaCommand;
    * MPAddAreaTHIDCommand;
    * MPAddLineCommand;
    * MPAddLineSegmentCommand;
    * MPAddPointCommand;
    * MPAddScrapCommand;
    * MPAddXTherionInsertImageCommand;
    * MPEditAreaTypeCommand;
    * MPEditLineSegmentCommand;
    * MPEditLineTypeCommand;
    * MPEditPointTypeCommand;
    * MPMoveBezierLineSegmentCommand;
    * MPMovePointCommand;
    * MPMoveStraightLineSegmentCommand;
    * MPRemoveAreaBorderTHIDCommand.

## 0.2.18 - 2025-09-26 - The anoying bug release
* Fixed bugs:
  * Failure to load XVI files dialog box was repeatly shown.

## 0.2.17 - 2025-09-25 - The polish cave rescue release
* New features:
  * Create shortcut to reverse line (R).
  * When opening files, delete empty areas.
  * When opening files, delete TH IDs from areas that do not refer to any existing line.
  * When opening files, delete empty lines.
  * Help page update.
  * Snap to grid lines.
  * Straight line segments line simplification.
* Fixed bugs:
  * Removing XTherion inserted images throwing errors.
  * Showing XVI parse errors at TH file open would throw because there was already a widget being built.
  * Files with empty lines (with no line segments) or empty areas (no valid line TH ID) would throw an exception when calculating bounding box.
* Infrastructure maintenance:
  * flutter pub upgrade --major-versions.
  * Flutter upgrade to 3.35.4.

## 0.2.16 - 2025-09-17 - The hidden diamonds release
* New features:
  * Using _MPOverlayWindowBlockWidget_ at _MPSnapTargetsWidget_ to improve reading.
  * Snap to XVI file features.
  * Snap spatial index.
  * Improved snap icon.
  * Add/remove lines from areas.
* Fixed bugs:
  * Lines added to areas not getting IDs associated to them.
  * Mapiah throws if line referred by area does not exist.
* Infrastructure maintenance:
  * dart fix --apply
  * flutter pub upgrade.

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
  * When setting 'smooth' option to on on line segments, the Bézier curve line segments should be smoothed.
  * Consider XVI and raster image files bounding boxes when calculating THFile bounding box.
* Fixed bugs:
  * Setting multiple option options in line segments not working.
  * Clicking in another controlpoint after moving a control point would unselect everything.
  * Making selection tolerance and point radius the same to avoid clicking near the border of a point and not selecting it.
  * When selecting a control point 1 the control points of the adjacent line segments weren't properly selected.
  * Changing first point of a line to Bézier curve throws an exception.
  * When a Bézier control point is selected, an end point appears as selected also.
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
