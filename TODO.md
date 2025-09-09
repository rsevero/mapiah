# TODO

Version 0.2
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

Version 0.3
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
[ ] - Snap points
[ ] - Add/remove lines from areas
[ ] - Simplifying lines: https://raphlinus.github.io/curves/2023/04/18/bezpath-simplify.html
[ ] - When deleting line points, adjust control points so curve is changed as little as possible
[X] - Implement Ctrl+O (open file) keyboard shortcut
[X] - Implement F1 shortcut to help page
[X] - Support XVI images
[X] - Support xth_me_image_insert additional formats
[ ] - Properly present lines with partial subtypes
[ ] - Show (and edit) orientation and lsize on the line points during edit
[ ] - Set borders on points (and lines and areas?) to show the state of some key options like: mark for line points, visibility for points, lines and areas
[ ] - Manually edit position of points
[ ] - Manually edit position of end and control points in line segments
[X] - BUG: opening a TH2 file that calls for a non existent XVI file should not hang Mapiah
[X] - BUG: opening a TH2 file that calls for an non existent raster image should not raise an exception

Version 0.4
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
[ ] - Create shortcut to reverse line
[ ] - Migrate away from Github
[ ] - Include options and point/line count in multiple elements clicked dialog box
[ ] - Implement default option values
[ ] - Preference option to choose between Mapiah Bezier Curve morphing style on creation and XTherion style
[ ] - Control which scraps are visible in Mapiah (that is not a Therion setting)
[ ] - Show points, lines and areas using therion symbology [requested by Marco Corvi]
[ ] - When an area defined by more than one line is selected, allow the user to refine the selection by selecting only one line [requested by Marco Corvi]
[ ] - Easily turn on/off the direction ticks [requested by Marco Corvi]
[ ] - Open file dialog on web should only show accepted file extensions [requested by Marco Corvi]
[ ] - Edit file properties (enconding and?...)

