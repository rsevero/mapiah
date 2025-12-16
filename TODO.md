# TODO

## Version 0.2
[X] - Make output identical to original except on changed lines
[X] - Deal with click on more than one object at a time
[X] - Line edit
[X] - Point and line remove
[X] - Point and line add
[X] - Status message totaling selected objects
[X] - Rename Stores to Controllers
[X] - All buttons (including zoom buttons) should use default button color
[X] - Different points and line representations
[X] - Areas
[X] - Scrap options
[X] - Line segment options
[X] - Show direction of lines
[X] - Add/delete line segments in existing lines
[X] - Release creation Linux
[X] - Help pages
[X] - Quick introduction guide
[X] - BUG: point arrow should be filled
[X] - BUG: last used point type not updating
[X] - BUG: saveAs didn't save the changes
[X] - BUG: corrigindo set/unset de originalLineInTH@File: MPSetOptionToElementCommand
[X] - BUG: distinguir execute command normal dos gerados por undos: os dos undos devem manter originalLineInTH2File, os normais não.
[X] - BUG: 'N' not starting line edit mode
[X] - BUG: clicking on line segment is not selecting nodes in line edit
[X] - BUG: multiple control points overlay window opening far away from clicked points
[X] - BUG: opening a new PLA type/option window does not close another PLA type/option window already opened
[X] - Enhancement: when start draging in edit single line mode, prefer endpoints to control points if no 'multiple points clicked'
[X] - BUG: fix == operator signature
[X] - BUG: deleted line points not available at undo/redo
[X] - BUG: clicking on another element when on 'single line edit mode' does not selects the new element
[X] - BUG: Save button should be disabled when there is no change to save
[X] - BUG: when trying to move objects, a new selection window is being drawn
[X] - BUG: added elements get inserted at the end of the file, after the endscrap element
[X] - BUG: new lines are created without its correspondent endline element
[X] - BUG: add area not working
[X] - BUG: clicking on selected control point over end point not moving the control point

## Version 0.3
[X] - Release creation Windows
[X] - Release creation MacOS
[X] - Release for Web
[X] - Release automation Linux
[X] - Release automation Windows
[X] - Release automation MacOS
[X] - Release automation for Web
[X] - Moving control points in smooth line segments should move the other control point visually attached to the same end point
[X] - Create new file
[X] - Create new scrap [requested by Marco Corvi]
[X] - Snap points
[X] - Snap to XVIFile elements: stations, sketch line ends, grid line crossings
[X] - Optimize snap search with spatial index
[X] - Add/remove lines from areas
[X] - Create at least one test per MPCommand
[X] - Change MPCommand execute/creteUndoRedoCommand logic to: on execute, each command saves any pre execute info it might need to create its undo version but only after actual execute the undo command is actually created. This new method is important so MPMultipleCommandsCommand can properly create its undo command.
[X] - MPMultipleCommandsCommand undo will be created after execute (as all MPCommands will do) by creating the reverse list of each of its own subcommands for their undo command.
[X] - Simplifying lines: https://raphlinus.github.io/curves/2023/04/18/bezpath-simplify.html
[X] - When deleting the second to last line segment of a line, the whole line should be deleted.
[X] - When opening files, delete empty lines.
[X] - When opening files, delete empty areas. An area might get empty if all its line TH IDs are pointing to non-existent lines.
[X] - Implement Ctrl+O (open file) keyboard shortcut
[X] - Implement F1 shortcut to help page
[X] - Support XVI images
[X] - Support xth_me_image_insert additional formats
[ ] - Show (and edit) orientation and lsize on the line points during edit
[ ] - Set borders on points (and lines and areas?) to show the state of some key options like: mark for line points, visibility for points, lines and areas
[X] - Snap to grid lines.
[X] - BUG: opening a TH2 file that calls for a non existent XVI file should not hang Mapiah
[X] - BUG: opening a TH2 file that calls for an non existent raster image should not raise an exception
[X] - BUG: Mapiah throws if line referred by area does not exist.
[X] - BUG: lines added to areas not getting IDs associated to them.
[X] - BUG: empty lines produce overflow as its bounding box is infinite.
[X] - BUG: on a new file, create a line: can't edit nodes of this line.
[X] - BUG: on newly created lines, Bézier line segments are set as smooth but the control points don't respect this smoothness.
[X] - Add a small unit test for the fitter to assert the first command is always a moveTo before any curveTo, ensuring regressions don’t return.
[X] - On an empty file, the select button should be disabled.
[X] - BUG: when several elements are selected and one is deselected, the status bar message is not updated.
[X] - When an element is deleted, the empty lines after it should also be deleted.
[X] - BUG: when several elements are deleted, resulting empty areas (because all its lines have been deleted) are not deleted.
[X] - BUG: when simplifying a line being node edited, the visual editing points are not immediatly updated.
[X] - When a line is deleted, if it's the last line of an area, the area should also be deleted.
[X] - BUG: On 'single line edit' mode, if the direction of the line is inverted, the screen does not show it.
[X] - BUG: On 'simplify line forcing to Bézier' the undo description says a generic 'substitute line segments'.
[X] - BUG: when on 'single line edit' mode, if the user clicks on another element, the 'Multiple elements clicked' dialog box is presented instead of just selecting the new element.
[X] - BUG: when simplifying a line, line segment options are being lost.
[X] - BUG: when saving a file with lines with line segments that have 'l-size' options, the 'l-size' options are being lost.
[X] - Simplification calculated values should use "current decimals".
[X] - BUG: when deleting several line points near an extremity, the extremity changed position.
[X] - BUG: after deleting several line points, the line is not click-selectable at its new line segments.
[X] - BUG: line types "Floor Step" and "floor-step" being presented.
[X] - When there is some snap option enabled, the "snap" button should be visually different.
[X] - On 'single line edit' mode, when a endpoint is selected, clicking on a control point and dragging should work.
[X] - BUG: on 'single line edit' mode, when end points are deleted, they remain visually shown as part of the line.
[X] - BUG: when clicking the 'Ok' button to set an option, the overlay window of the option being set is not closed.
[X] - BUG: when selecting a multiple option option, the overlay window of the option being set is not closed.
[X] - Make THID the first option when writing to file.
[X] - Snap should have "points" and line points" on as default.
[X] - Saving should close overlay windows like "options".
[X] - BUG: on some situations, when on 'single edit line' mode, the Mapiah ends in no mode.
[X] - BUG: on 'Ctrl+A', the state remains 'empty selection'.
[X] - Keyboard shorcut to toogle smooth between "on/unset".
[ ] - On 'single line edit' mode, after setting a line point option, clicking outside the overlay window should only close the overlay window but not but the user back in the 'empty selection' mode.
[ ] - When recording the last PLA type used to be the default one for the next PLA created, the subtype should also be saved.
[ ] - When clicking to create either an initial line point or a point, snap should also be effective if enabled.
[X] - BUG: Simplification of several lines at once is not working at all.
[X] - BUG: On the PLA type selection overlay window, in the "Current" box, hyphenated options are being presented hyphenated instead of translated.
[X] - On 'single line edit' mode, after changing line point positions, the line bounding box is not being updated (selection handles still on the old position).
[X] - BUG: On 'single line edit' mode, if I move a end point and immediatly edit its smooth option, the point moves back to the original position before the move.
[X] - BUG: On 'single line edit' mode, clicking on empty space with points selected throws.
[X] - BUG: On 'single line edit' mode, after simplifying a line, it's not possible to select the line by clicking over the new path, only on the old one.
[ ] - When clicking on an area, create some sort of short cut that would enable the user to automatically selected either the line or the area without being presented with a 'multiple elements clicked' dialog box.
[X] - Create state 'select all/deseselct all' methods.
[X] - Move kerboard shortcuts R (reverse line) and S (smooth line points) to states that actually deal with selected lines.
[X] - Make 'smooth line points' work when in 'non empty selection' mode acting only on selected lines.
[ ] - Properly support lines with partial subtypes: subtype can be either a line or a line point option. If its a line option, it sets the start of the line. If a subtype appears as a line point option, it changes the line from that point on.
[ ] - Create 'O' shotcut to open options overlay window.

##Version 0.4
[ ] - Open multiple files simultaneously
[ ] - Allow copy/paste between scraps
[ ] - Allow copy/paste between files
[ ] - Search/select elements by characteristics
[ ] - Change cursors to show current status
[ ] - Config page
[ ] - Drag overlay windows
[ ] - Prevent (or at least try harder to prevent) overlay windows being opened with parts of it outside the available canvas [requested by Marco Corvi]
[ ] - Hide elements by type
[ ] - Copy/Paste
[ ] - Show status message listing what's selected in 'single line edit' mode
[ ] - Highlight slope lines without at least one line point with orientation
[X] - Create shortcut to reverse line
[ ] - Migrate away from Github
[ ] - Include options and point/line count in multiple elements clicked dialog box
[ ] - Implement default option values
[ ] - Preference option to choose between Mapiah Bezier Curve morphing style on creation and XTherion style
[ ] - Control which scraps are visible in Mapiah (that is not a Therion setting)
[ ] - Show points, lines and areas using therion symbology [requested by Marco Corvi]
[ ] - When an area defined by more than one line is selected, allow the user to refine the selection by selecting only one line [requested by Marco Corvi]
[ ] - Easily turn on/off the direction ticks [requested by Marco Corvi]
[ ] - Open file dialog on web should only show accepted file extensions [requested by Marco Corvi]
[ ] - Edit file properties (encoding and?...)
[ ] - Visually close lines with command option close set to on or auto (for line types automatcally closed).
[X] - When deleting an element, all imediate empty lines after it should also be deleted.
[ ] - Split one line in two.
[ ] - Join 2 lines.
[ ] - Merge 2 areas.
[ ] - Implement simplify lines interactive dialog box.
[X] - When a single element is selected, show its properties in the status bar.
[ ] - Create a 'split line at selected end point' action in 'single line edit' mode.
[ ] - Allow the user to choose if the grid of a XVI file should be visible or not.
[ ] - Command options that are a dropdown, should not have 'set/unset' but rather the 'unset' option should be included in the dropdown itself.
[ ] - When deleting line points, adjust control points so curve is changed as little as possible.
[ ] - Manually edit position of points.
[ ] - Manually edit position of end and control points in line segments.
[ ] - Properly support lines with partial subtypes: subtype can be either a line or a line point option. If its a line option, it sets the start of the line. If a subtype appears as a line point option, it changes the line from that point on.
[ ] - Convert multiline comment into a single element.

##Version 0.5
[ ] - Raster images tracing
[ ] - Create configurable list of element types and/or subtypes to prevent them from being selected, edited or deleted. The 'u:splay' lines should be on this list by default.

