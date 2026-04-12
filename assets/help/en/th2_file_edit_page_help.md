<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
This is where all TH2 file editing is done.

_Note: Mapiah treats the Ctrl and Meta (Command on macOS) keys as interchangeable. Shortcut mentions below use "Ctrl" for brevity._

## Index
- [Index](#index)
- [Top bar](#top-bar)
- [File tabs](#file-tabs)
- [Edit window](#edit-window)
  - [Top right corner](#top-right-corner)
  - [Bottom right corner](#bottom-right-corner)
- [Drawing lines](#drawing-lines)
  - [Map connection](#map-connection)
- [Selecting elements](#selecting-elements)
- [Element operations](#element-operations)
  - [Copy and paste](#copy-and-paste)
  - [Cut](#cut)
  - [Duplicate](#duplicate)
- [Element options](#element-options)
- [Default options](#default-options)
- [Save](#save)
  - [Original file format](#original-file-format)
- [Images](#images)
  - [Image transform mode](#image-transform-mode)
  - [Image moving](#image-moving)
  - [Image scaling](#image-scaling)
  - [Image rotation](#image-rotation)
  - [Image visibility](#image-visibility)
  - [Grid visibility](#grid-visibility)
  - [Image reordering](#image-reordering)
- [Drag modifiers](#drag-modifiers)
  - [Selected elements](#selected-elements)
  - [Single-line end/control points](#single-line-endcontrol-points)
- [Scraps](#scraps)
  - [Scrap copy](#scrap-copy)
  - [Scrap cut](#scrap-cut)
  - [Scrap duplicate](#scrap-duplicate)
  - [Scrap visibility](#scrap-visibility)
  - [Scrap reordering](#scrap-reordering)
- [Simplify lines](#simplify-lines)
  - [Simplification methods](#simplification-methods)
  - [Bézier curve line segments](#bézier-curve-line-segments)
  - [Mixed line segments](#mixed-line-segments)
  - [Straight line segments](#straight-line-segments)
- [Convert line segments](#convert-line-segments)
- [Split line at selected points](#split-line-at-selected-points)
- [Split lines at crossings](#split-lines-at-crossings)
- [Join lines at coinciding extremities](#join-lines-at-coinciding-extremities)
- [Merge areas](#merge-areas)
- [Hide elements](#hide-elements)
- [Search and select](#search-and-select)
- [Snap](#snap)
- [Zoom and panning](#zoom-and-panning)

## Top bar
* On the left:
    * ![Back icon](assets/help/images/iconBack.png "Back")  _Back_: returns to the main window without saving contents.
* On the right:
  * ![Save icon](assets/help/images/iconSave.png "Save")  _Save_: saves changes in same file. Only enabled if there are changes to be saved. (Ctrl+S)
  * ![Save As icon](assets/help/images/iconSaveAs.png "Save As")  _Save As_: saves changes in new file. (Shift+Ctrl+S)
  * ![Choose THConfig file and run Therion icon](assets/help/images/iconChooseTHConfigAndRunTherion.png "Choose THConfig file and run Therion") _Choose THConfig file and run Therion_: shows system dialog where its possible to choose which THConfig file should be used to run Therion.
  * ![Run Therion icon](assets/help/images/iconRunTherion.png "Run Therion")" _Run Therion_: runs Therion with currently opened project.
  * ![Help icon](assets/help/images/iconHelp.png "Help") _Help_: show this dialog box.
  * ![Close icon](assets/help/images/iconClose.png "Close") _Close_: close the TH2 file edit window without saving changes.

## File tabs

When multiple files are open, each file appears as a tab at the top of the editor. The file name is displayed on the tab along with an **X** button to close that file.

**Tab features:**
* **Switch between files**: Click on any tab to switch to that file
* **Close a file**: Click the **X** button on the tab to close that file
* **Scroll tabs**: If you have many files open, use your mouse to click and drag horizontally on the tabs to scroll through them
* **Multiple selection**: Use the _File open_ button on the top bar to select and open multiple files at once

The currently active file's tab is highlighted, making it easy to see which file you're editing. All open files maintain their editing state, so you can switch between them without losing your work.

## Edit window

### Top right corner
* _Search_: opens the search and select dialog. (See [Search and select](#search-and-select))
* ![Snap button](assets/help/images/buttonSnap.png "Snap")  _Snap_: toggles the snap window where are presented the snap options. (Ctrl+L)
* _Default options_: opens the default options overlay window where default option values can be set for new points, lines, and areas. (O with no elements selected)
* ![Delete button](assets/help/images/buttonDelete.png "Delete")  _Delete_: deletes the currently selected elements. Only enabled if there is at least one element selected. (Delete/Backspace)
* ![Undo button](assets/help/images/buttonUndo.png "Undo")  _Undo_: undos the last executed edit operation. Only enabled if there is at elast one edit operation to be undone. (Ctrl+Z)
* ![Redo button](assets/help/images/buttonRedo.png "Redo")  _Redo_: redoes the last undone edit operation. Only enabled if there is at least one edit operation to be redone. (Ctrl+Y)

In case there are available redoes when a new edit operation is performed, the redo stack is migrated to the undo stack making redoes still accessible.

### Bottom right corner
* ![Images button](assets/help/images/buttonImages.png "Images")  _Images_: opens the images options overlay window. Shows all images inserted in the current file. Each image row has a visibility checkbox, a grid visibility checkbox (XVI images only), a delete button, and a drag handle for reordering. Also presents an "Add Image (I)" button. (Alt+I)
* ![Scraps button](assets/help/images/buttonScraps.png "Scraps")  _Scraps_: opens a dialog box to change the current scrap, delete an existing scrap and add a new one. The dialog box shows all available scraps and allows to select one of them. The scrap options overlay window is presented when right clicking on the desired scrap. (Alt+C)
* ![Select element button](assets/help/images/buttonSelectElement.png "Select element")  _Select element_: allows to select elements in the TH2 file. (C)
* ![Line edit button](assets/help/images/buttonLineEdit.png "Line edit")  _Line edit_: allows to edit individual lines in the TH2 file. (N)
  * Double-clicking a line or one of its visible line segments while using the _Select element_ tool also enters _Line edit_ mode for that line.
* ![Add element button](assets/help/images/buttonAddElement.png "Add element")  _Add element_: allows to add new elements to the TH2 file. On mouse over the following buttons are shown:
  * ![Add point button](assets/help/images/buttonAddPoint.png "Add point")  _Add point_: adds a new point to the TH2 file. (P)
  * ![Add line button](assets/help/images/buttonAddLine.png "Add line")  _Add line_: adds a new line to the TH2 file. (L)
  * ![Add area button](assets/help/images/buttonAddArea.png "Add area")  _Add area_: adds a new area to the TH2 file. (A)
* ![Zoom options button](assets/help/images/buttonZoomOptions.png "Zoom options")  _Zoom options_: presents the zoom options. On mouse over the following buttons are shown:
  * ![Zoom in button](assets/help/images/buttonZoomIn.png "Zoom in")  _Zoom in_: zooms in the TH2 file view. (+)
  * ![Zoom One to One button](assets/help/images/buttonZoomOneToOne.png "Zoom one to one")  _Zoom one to one_: zooms the TH2 file view to show the elements at their original size, i.e., each TH2 point corresponding to a screen pixel. (1)
  * ![Zoom to selection button](assets/help/images/buttonZoomSelection.png "Zoom to selection")  _Zoom to selection_: zooms the TH2 file view to show the currently selected elements. (2)
  * ![Zoom to selection window button](assets/help/images/buttonZoomSelectionWindow.png "Zoom to selection window")  _Zoom to selection window_: zooms the TH2 file view to show the window selected by the user with a mouse drag. (5)
  * ![Zoom to file button](assets/help/images/buttonZoomFile.png "Zoom to file")  _Zoom to file_: zooms the TH2 file view to show all elements in the file. (3)
  * ![Zoom to scrap button](assets/help/images/buttonZoomScrap.png "Zoom to scrap")  _Zoom to scrap_: zooms the TH2 file view to show the currently selected scrap. (4)
  * ![Zoom out button](assets/help/images/buttonZoomOut.png "Zoom out")  _Zoom out_: zooms out the TH2 file view. (-)

## Drawing lines
When drawing lines, each new segment is initially created as a straight line segment. To convert it to a Bézier Curve line segment, do not release the mouse button and drag. The mouse position will be treated as the position of the single control point of a quadratic Bézier Curve.

The exact drag behavior depends on the settings option "New line creation method". "Mapiah quadratic" keeps the current behavior described below and also lets you hold _Shift_ during the drag to constrain the control point to the nearest multiple of the configured snap angle relative to the shared node. "xTherion cubic smooth" uses the dragged position as the next segment's future control point, mirrors the current segment's other control point around the shared end point, and lets you hold _Ctrl_ while dragging to keep the mirrored control point at a fixed distance. While setting that control point in "xTherion cubic smooth" mode, you can also hold _Shift_ during the drag to constrain it to the nearest multiple of the configured snap angle relative to the shared node. This _Shift_ constraint can also be combined with _Alt_ in "xTherion cubic smooth" mode.

When drawing with either "Mapiah quadratic" or "xTherion cubic smooth", you can also hold _Shift_ while setting a node to constrain it to the nearest multiple of the configured snap angle relative to the previous node.

When drawing with "xTherion cubic smooth", you can also make the shared node a corner point by separating the two control points. Start dragging normally to define the current segment's control point at the shared end node. Then, without releasing the mouse button, hold _Alt_ and keep dragging to redefine only the next segment's future control point. This keeps the current segment handle fixed while changing the next one independently.

When drawing with either "Mapiah quadratic" or "xTherion cubic smooth", you can press _Backspace_ or _Delete_ to remove the last created node. If that was the only completed segment so far, Mapiah returns to the original start node so you can continue drawing from it.

When drawing with "xTherion cubic smooth", you can press _Esc_ to delete the whole unfinished path and leave line-creation mode.

While drawing a line, you can also move the last created node with the keyboard:
* Press an _Arrow_ key to move it by the configured nudge factor (`TH2Edit_NudgeFactor`), measured in canvas pixels
* Press _Shift+Arrow_ to move it by ten times the nudge factor
* Press _Alt+Arrow_ to move it by 1 screen pixel
* Press _Alt+Shift+Arrow_ to move it by 10 screen pixels

Bézier Curves on Therion (and Mapiah) are cubic curves, i.e., they have 2 control points for each segment. Just on line segment creation Mapiah pretends that the Bézier Curve being created is a quadratic Bézier Curve (with only one control point) so the user has flexibility to create the line segment.

Observe that despite the fact that Mapiah is simulating the existance of only one control point, an actual cubic Bézier Curve is being created with two control points as expected.

### Map connection
For selected X-Section points, on Ctrl+X, Mapiah searchs for a scrap option that ends on "-xs-STATION" where STATION is the station where the x-section was created. It searchs for a point type station with its name option set to STATION. If both are found, a line of type "map connection" is created between the x-section point and the station point.

## Selecting elements
To select an element, click on it with the _Select element_ tool active. To select multiple elements, hold the _Shift_ key while clicking on them. To deselect an element, hold the _Shift_ key while clicking on it. To select all elements, use the _Select all_ option on the _Select element_ tool or use the keyboard shortcut _Ctrl+A_.

Its also possible to select elements by dragging a selection window with the mouse. To do that, click and hold the left mouse button on an empty area of the canvas and drag the mouse. All elements that are fully or partially inside the selection window will be selected. To add elements to the selection, hold the _Shift_ key while dragging the selection window.

When clicking on a line that defines an area border, the behavior depends on which modifier keys are held:

1. **No modifier (or modifiers other than Ctrl+Shift)**: both the area and the line are candidates for selection. If exactly one is already selected the other is added; otherwise a "Multiple elements clicked" dialog is shown so you can choose which element(s) to add to the selection.
2. **Ctrl+click (without Alt or Shift)**: only border lines are added to the selection directly, without showing the dialog. If the area has more than one border line, the first click selects all of its border lines. Additional Ctrl clicks, while you keep Ctrl held, cycle through the same area's border lines in the order they appear in the area's `THAreaBorderTHIDs`, then return to selecting all border lines again.
3. **Ctrl+Alt+click (without Shift)**: only the area is added to the selection directly, without showing the dialog.

## Element operations

### Copy and paste
Selected elements can be copied to a clipboard and pasted into the current file or another open file.

**To copy selected elements:**
- Press _Ctrl+C_
- At least one element must be selected

- **To paste copied elements:**
- Press _Ctrl+V_
- Pasted elements appear in the current scrap
- All child elements (line segments, area borders, etc.) are automatically included in the paste
- THID references are automatically resolved to avoid conflicts: if a pasted element's THID already exists in the target file, a new unique THID is automatically generated
- Pasted elements become the new selection, making them ready for further editing or moving
- The paste operation can be undone with _Ctrl+Z_

**Cross-file pasting:**
When you have multiple files open in tabs, you can copy elements from one file and paste them into another file. Simply switch to the target file tab and press _Ctrl+V_.

### Cut
Selected elements can be cut (copied to clipboard and immediately removed from the file).

- **To cut selected elements:**
- Press _Ctrl+X_
- At least one element must be selected
- The elements are copied to the clipboard and then removed from the file
- The clipboard content can be pasted with _Ctrl+V_ into the same or another open file
- The cut operation can be undone with _Ctrl+Z_, which restores the elements to their original positions

### Duplicate
Selected elements can be quickly duplicated in place.

**To duplicate selected elements:**
- Press _Ctrl+D_
- All selected elements and their children are duplicated
- Duplicated elements appear at the same position as the originals
- The duplicate operation creates new unique IDs for all duplicated elements
- Duplicated elements become the new selection
- The duplicate operation can be undone with _Ctrl+Z_

## Element options
Right clicking on a selected element presents an overlay window with the options available for the currently selected elements. The element options window can also be opened by using the 'O' keyboard shortcut when there is at least one element selected.
The options available depend on the type of element selected.

To edit scrap options, right click on:
* the scrap select button on the right bottom corner in case there is only one scrap in the file, or
* the scrap name in the scrap select dialog box presented when clicking on the scrap select button in case there are multiple scraps in the file.

## Default options

Default options are option values that are automatically applied to newly created points, lines, or areas of matching types. They are set once and reused across all subsequent element creations until changed or removed.

Open the default options overlay window by:
* Pressing 'O' with no elements selected, or
* Clicking the _Default options_ button (tune icon) in the top right corner.

The overlay window contains three tabs: **Points**, **Lines**, and **Areas**. Select the tab for the element category whose defaults you want to configure.

Within each tab, the available options work identically to the regular element options editor. Setting an option stores it as a default for the selected category. Unsetting an option removes it from the defaults.

Only options applicable to the specific type of the newly created element are applied. For example, if a default "clip" option is set for lines, it will only be applied when creating line types that support the "clip" option.

A **Reset** button at the top of the overlay clears all defaults for the currently shown tab. The button is disabled when no defaults are set for that category.

## Save

### Original file format
Mapiah preserves the original file formatting as much as possible when saving. However, some changes are made on file parsing that are reflected in the saved version even if the user did no editing at all:
* Consecutive line points with identical end points are merged into a single line point.
* Lines with zero or one line points are removed.
* Non existing area border references are removed, i.e., the area mentions an area border ID but there is no line with the same ID on the file.
* Areas with no border references are removed.
* Line options defined in [LINE DATA] area are moved to the line definition. Not to be confunded with line point options that are defined in [LINE DATA] area and are preserved there.
* Subtype options defined before the first line point or on the first one are transformed to line subtype.

## Images
The images overlay window is opened with the ![Images button](assets/help/images/buttonImages.png "Images") button (Alt+I) in the bottom right corner. It lists all images (XVI survey backgrounds, raster images, and Mapiah-only SVG images) inserted in the current file.

SVG images are always stored as Mapiah-only image inserts. To import an SVG, the file must define either a `viewBox` or numeric `width` and `height`. If neither is available, Mapiah shows an import error and does not insert the image.

A _toggle all_ button appears above the list when images are present. Its tooltip and icon reflect what the button will do:
* _Hide all images_ (eye-off icon): shown when all images are visible; clicking hides all images.
* _Show all images_ (eye icon): shown when any image is hidden; clicking makes all images visible.

Each image row contains:
* A visibility checkbox to show or hide the image on the canvas
* A grid visibility checkbox (XVI images only) to show or hide the survey grid independently from the image itself
* The image filename
* An edit button to enter image transform mode on the canvas
* A reset button to restore image translation, scale, and rotation to their defaults
* A delete button to remove the image
* A drag handle (⣿) to reorder images

### Image visibility
Clicking the visibility checkbox toggles whether the image is displayed on the canvas. Hidden images are still stored in the file.

### Image transform mode
Click the edit button on an image row to enter image transform mode for that image. The image is outlined on the canvas with small black handles on the corners and on the middle of each side. Clicking the selected image again while transform mode is active switches to image rotation mode, where the corner handles become curved rotation handles and a pivot marker is shown.

While image transform mode is active:
* Drag the image itself to move it
* Drag any black handle to scale it
* Click the selected image to toggle between move/scale mode and rotate mode
* Press _H_ to flip the image horizontally
* Press _V_ to flip the image vertically
* Use the two flip buttons shown on the left side of the canvas to trigger the same actions with the mouse
* Press _Esc_ to leave image transform mode

Click the reset button on an image row to set `xx`, `yy`, and the rotation angle back to `0`, `xScale` and `yScale` back to `1`, and image visibility and XVI grid visibility back to their default visible state. The reset keeps the XVI root unchanged.

### Image moving
In image transform mode, drag the image body to move the selected image.

Keyboard movement:
* Press an _Arrow_ key to move the selected image by the configured nudge factor (`TH2Edit_NudgeFactor`), measured in canvas pixels
* Press _Shift+Arrow_ to move by ten times the nudge factor
* Press _Alt+Arrow_ to move by 1 screen pixel
* Press _Alt+Shift+Arrow_ to move by 10 screen pixels

The following modifiers can be combined while moving:
* Hold _Alt_ and drag anywhere on the canvas to move the selected image without needing to start on the image body
* Hold _Ctrl_ while dragging to constrain the move to the dominant horizontal or vertical direction
* Hold _Shift_ while dragging to temporarily disable snapping

### Image scaling
In image transform mode, drag any black handle to scale the selected image.

You can also flip the image instantly without dragging:
* Press _H_ to negate `xScale`
* Press _V_ to negate `yScale`
* The flip actions are undoable with _Ctrl+Z_

Scaling modifiers:
* Hold _Ctrl_ while dragging a handle to preserve the image aspect ratio
* Hold _Shift_ while dragging a handle to scale symmetrically around the image center
* Hold _Alt_ while dragging a handle for finer, slower scaling

### Image rotation
While image transform mode is active, click the selected image to enter rotation mode. The corner handles change to curved rotation handles and a pivot marker appears.

In rotation mode:
* Drag a curved corner handle to rotate the image
* Drag the pivot marker to change the rotation center
* Hold _Ctrl_ while rotating to snap the angle to the configured snap angle
* Hold _Shift_ while rotating to keep the opposite corner fixed in place

For XVI images with an `xviRoot`, the pivot marker is shown but cannot be moved.

### Grid visibility
For XVI survey background images, a second checkbox controls whether the survey grid is displayed. Hiding the grid leaves the shots, stations, and sketch lines visible while removing the grid lines from the canvas. The grid visibility state is saved with the session.

### Image reordering
Click and drag the drag handle (⣿) of any image row to change its position in the list. The order of images in this list determines the rendering order on the canvas: images listed earlier are drawn below images listed later. Reordering is undoable with _Ctrl+Z_.

While dragging:
* The dragged row disappears from the list and a semi-transparent preview of it follows the cursor.
* A colored bar appears above the row where the dragged image will be inserted when released.

## Drag modifiers
Mapiah uses the same movement modifiers for background images, selected elements, and selected end/control points in single-line edit mode. These modifiers can be combined.

### Selected elements
When one or more elements are selected in selection mode:
* Press an _Arrow_ key to move the selected elements by the configured nudge factor (`TH2Edit_NudgeFactor`), measured in canvas pixels
* Press _Shift+Arrow_ to move by ten times the nudge factor
* Press _Alt+Arrow_ to move by 1 screen pixel
* Press _Alt+Shift+Arrow_ to move by 10 screen pixels
* Drag the selected elements to move them normally
* Hold _Alt_ and drag anywhere on the canvas to move the current selection without changing the selection
* Hold _Ctrl_ while dragging to constrain the move to the dominant horizontal or vertical direction
* Hold _Shift_ while dragging to temporarily disable snapping

If the `TH2Edit_EnableElementTransforms` setting is enabled, the current selection also supports scaling, rotation, and mirroring:
* Drag any selection handle to scale the selected elements
* Hold _Ctrl_ while dragging a selection handle to preserve the current aspect ratio
* Hold _Shift_ while dragging a selection handle to scale symmetrically around the selection center
* Hold _Alt_ while dragging a selection handle for finer, slower scaling
* Click the selected elements to switch from normal selection mode to element rotation mode
* In element rotation mode, drag a corner selection handle to rotate the selection
* Hold _Ctrl_ while rotating to snap the angle to the configured snap angle
* Hold _Shift_ while rotating to keep the opposite corner fixed in place
* Press _H_ to mirror the selection horizontally
* Press _V_ to mirror the selection vertically

### Single-line end/control points
When one or more end/control points are selected in line edit mode:
* Press an _Arrow_ key to move the selected point or points by the configured nudge factor (`TH2Edit_NudgeFactor`), measured in canvas pixels
* Press _Shift+Arrow_ to move by ten times the nudge factor
* Press _Alt+Arrow_ to move by 1 screen pixel
* Press _Alt+Shift+Arrow_ to move by 10 screen pixels
* Drag the selected point or points to move them normally
* Hold _Alt_ and drag anywhere on the canvas to move the current point selection without changing the selection
* Hold _Ctrl_ while dragging to constrain the move to the dominant horizontal or vertical direction
* Hold _Shift_ while dragging to temporarily disable snapping

## Scraps
It's only possible to work on one scrap at a time. To change the current scrap, click on the scrap select button ![Scraps button](assets/help/images/buttonScraps.png "Scraps") on the bottom right corner and select the desired scrap from the dialog box presented.

You can also _Alt+click_ on a non active scrap to make it the current scrap.

Each scrap is listed as a row in the dialog box. The row contains:
* A radio button to select it as the active scrap
* A visibility checkbox (when the file has more than one scrap) — see [Scrap visibility](#scrap-visibility)
* Four icon buttons: _Copy scrap_, _Cut scrap_, _Duplicate scrap_, and _Remove scrap_
* A drag handle (⣿) to reorder scraps (when the file has more than one scrap) — see [Scrap reordering](#scrap-reordering)

A _toggle all_ button appears above the list (when the file has more than one scrap). Its tooltip and icon reflect what the button will do:
* _Hide all but active_ (eye-off icon): shown when all scraps are visible; clicking hides all scraps except the active one.
* _Show all scraps_ (eye icon): shown when any scrap is hidden; clicking makes all scraps visible.

### Scrap copy
Copies all elements within the scrap to the clipboard without removing the scrap. The clipboard content can then be pasted with _Ctrl+V_ into the same or another open file.

### Scrap cut
Copies all elements within the scrap to the clipboard and then removes the scrap from the file. The clipboard content can then be pasted with _Ctrl+V_ into the same or another open file. The cut operation can be undone with _Ctrl+Z_, which restores the scrap and all its elements.

### Scrap duplicate
Duplicates the entire scrap, including all its elements, creating a new scrap in the same file. New unique IDs are generated for all duplicated elements. The duplicate operation can be undone with _Ctrl+Z_.

### Scrap visibility
When the file has more than one scrap, a visibility checkbox appears in every scrap row, including the active one. Checking or unchecking this box toggles whether that scrap is displayed on the canvas.

If only one scrap is currently visible, the active scrap's checkbox is disabled to prevent hiding all scraps. When the active scrap is hidden, Mapiah automatically switches the active scrap to the nearest previously visible one.

If the file has only one scrap, the visibility checkbox is hidden.

### Scrap reordering
Click and drag the drag handle (⣿) of any scrap row to change its position in the list. Reordering is undoable with _Ctrl+Z_.

While dragging:
* The dragged row disappears from the list and a semi-transparent preview of it follows the cursor.
* A colored bar appears above the row where the dragged scrap will be inserted when released.

## Simplify lines
Bézier curves and straight line segments are simplified differently. To simplify lines, first select them. There can be other types of elements selected (points or areas) while simplifying lines. They will be untouched by the simplification process.

### Simplification methods
There are three line simplification methods available:
* __Keep original types (Ctrl+L)__: each line segment is simplified using its own type simplification algorithm.
* __Force Bézier (Ctrl+Alt+L)__: all line segments are, if necessary, first converted to Bézier curves and then simplified using the Bézier curve simplification algorithm.
* __Force straight (Ctrl+Shift+L)__: all line segments are, if necessary, first converted to straight lines and then simplified using the straight line simplification algorithm.

The __Interactive simplify lines dialog (Ctrl+Alt+Shift+L)__ exposes the same parameters through a live preview. Use it to switch between the three methods and adjust the simplification intensity before committing the final result. Closing the dialog, saving it, or clicking outside the dialog keeps the current preview as a single undoable action. Cancelling restores the original selected lines without creating an undo entry.

### Bézier curve line segments
Each _Ctrl+[Alt]+L_ press runs a round of line simplification. Mapiah uses an interactive algorithm to simplify Bézier curve line segments. It operates on canvas space. The initial tolerance (epsilon) is equivalent to 1.5 screen pixels. This value is converted to canvas coordinates. At each subsequent run the tolerance is increased by the same initial value.

### Mixed line segments
When a line contains both Bézier curve and straight line segments, Mapiah treats each part of the line separately. Each part containing only Bézier curve segments is simplified using the Bézier curve simplification algorithm. Each part containing only straight line segments is simplified using the straight line simplification algorithm.

### Straight line segments
Each _Ctrl+[Shift]+L_ press runs a round of line simplification. Mapiah uses an interactive (non-recursive) version of the ![Ramer–Douglas–Peucker algorithm](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm) to simplify straight line segments. It operates on canvas space. The initial tolerance (epsilon) is equivalent to 1.5 screen pixels. This value is converted to canvas coordinates. At each subsequent run the tolerance is increased by the same initial value.

## Convert line segments

Mapiah can convert line segments between straight and Bézier types without changing the line selection itself.

**Shortcuts and buttons:**
- Press `J` or click the **Convert line segments to Bézier** button to convert to Bézier.
- Press `Shift+J` or click the **Convert line segments to straight** button to convert to straight.

**When is it available:**
- In line edit mode (_N_), the action is enabled when at least one selected point is not the start point of the line.
- In selection mode (_C_), the action is enabled when at least one line is selected.

**How it works:**
- In line edit mode, only the selected non-start line segments are converted.
- In selection mode, all selected lines are processed and every non-start segment is converted to the requested type.
- Segments that already match the requested type are left unchanged.
- Mixed lines can be converted in either direction.
- The operation can be undone with _Ctrl+Z_.

## Split line at selected points

While in line edit mode (_N_), select one or more internal line points and press _Ctrl+P_ to split the line into multiple lines at those points.

**How it works:**
- The first new line contains all segments from the original line's start up to and including the first selected point.
- Each subsequent new line begins with a new straight segment whose endpoint is a copy of the last selected split point's position, followed by the original segments up to the next selected split point (or the end of the line).
- After the split, all newly created lines are selected.
- The operation can be undone with _Ctrl+Z_.

**IDs:** If the original line had an `-id` option (e.g. `wall1`), each new line receives a derived ID: `wall1-1`, `wall1-2`, and so on.

**Limitation:** Lines that are part of an area border cannot be split. A message is shown if you attempt to do so.

## Split lines at crossings

Press `Ctrl+Shift+X` to split the selected lines at every intersection with other selected lines in the same scrap.

**How it works:**
- For each selected line, every crossing point with any other selected lines is computed.
- Each crossing becomes a split point, producing multiple lines.
- New lines inherit options from the original; if the original line had an `-id` option (e.g. `wall1`), each new line receives a derived ID: `wall1-1`, `wall1-2`, and so on.
- After the split, all newly created lines are selected.
- The operation can be undone with `Ctrl+Z`.
- **Limitation:** Lines that are part of an area border cannot be split. A message is shown if you attempt to do so.

## Join lines at coinciding extremities

Press `Ctrl+J` (or click the **Join lines at coinciding extremities** button) to join selected lines whose start/end extremities coincide.

**When is it available:**
The action is enabled when at least two lines are selected.

**How it works:**
- The operation checks selected lines for extremities that coincide using a tolerance equivalent to 3 screen pixels (converted to canvas coordinates at execution time according to current zoom).
- A single run can produce multiple joined lines when selected lines form multiple independent groups.
- For each resulting joined line, the line type and options from the first selected line in that group are preserved.
- Line segments are reoriented as needed so the joined geometry is continuous; Bézier segments are reversed preserving their visual shape.
- The resulting joined lines are selected.
- The operation can be undone with _Ctrl+Z_.

If no coinciding extremities are found, Mapiah shows a message and performs no changes.

## Merge areas

Press _Ctrl+M_ (or click the **Merge areas** button) to merge the border lines of the selected areas into the fewest possible closed lines, replacing the selected areas with a single merged area.

**When is it available:**
The action is enabled when the total number of distinct border lines across the selected areas is two or more. Areas can be selected directly, or indirectly by selecting one or more of their border lines. This covers two common scenarios:
- One area that already has more than one border line (`THAreaBorderTHID`).
- Two or more areas selected, whether by selecting the areas themselves or their border lines.

**How it works:**
1. Mapiah collects all selected areas plus any areas referenced by selected border lines, then gathers their distinct border lines (LTSAs — Lines To be merged from Selected Areas).
2. Any LTSA that is not already closed (last point ≠ first point) is automatically closed with a straight segment.
3. The LTSAs are grouped by mergeability. Lines belong to the same group when they cross each other or share a geometrically identical segment; isolated lines form singleton groups.
4. For each group containing more than one line, all segments are assembled into a single merged line using a bounding-path algorithm that traces the outer boundary.
5. A single new area is created, referencing all merged lines as its borders.
6. The resulting merged area is selected after the operation.
7. The operation can be undone with _Ctrl+Z_.

**Options and IDs:**
- The new area inherits all options (type, subtype, etc.) from the first selected area.
- Each merged line inherits all options from the first LTSA in its group.
- Explicit Therion IDs (`-id`) are preserved where they existed on the canonical area and canonical line of a group. Lines and areas without explicit IDs receive auto-generated IDs so they can be properly referenced as area borders.

If segments outside the outer boundary are detected during the merge, Mapiah shows an error message and performs no changes.

## Hide elements
Press _Ctrl+H_ to temporarily hide elements on the canvas without removing them from the file.

**When elements are selected:**
* The selected elements are added to the hidden list and deselected.
* Hidden elements are no longer drawn on the canvas and cannot be clicked or selected.

**When no elements are selected:**
* All hidden elements are made visible again.

Hidden elements are a temporary canvas-only state: they are not saved to the file and are always restored when the file is reopened.

## Search and select
The search and select dialog allows you to find and select elements in the current scrap based on their characteristics. Open it by clicking the ![Search button](assets/help/images/buttonSearch.png "Search and select") button in the top right corner.

The dialog has three collapsible sections: **Points**, **Lines**, and **Areas**. Enable a section by checking its checkbox. Each enabled section offers filtering criteria:

* **All**: selects all elements of that type in the current scrap. Enabling this disables the other criteria.
* **By ID**: filters elements whose Therion ID contains the entered text (case-insensitive partial match).
* **By subtype**: filters elements by their subtype. Select known subtypes from chips and/or enter free text for unknown subtypes. Available for points and lines only.
* **By type**: filters elements by their type. Select one or more types from the available chips. Unknown types found in the current scrap are also listed.
* **By option**: filters elements by whether specific options are set or not. Each option can be set to _Undefined_ (ignored), _Set_ (element must have the option), or _Unset_ (element must not have the option).
* **By line segment option** _(lines only)_: filters lines by whether any of their line segments have specific options set or not. Each option can be set to _Undefined_ (ignored), _Set_ (at least one segment of the line must have the option), or _Unset_ (no segment of the line may have the option).

When multiple criteria are enabled within a section, an element must match **all** of them (AND logic). When multiple sections are enabled, matching elements from any section are included (OR logic).

A status bar at the bottom shows the number of elements matching the current criteria, updated live as you change the filters.

**Action buttons:**
* **Set selection**: replaces the current selection with the matching elements.
* **Add to selection**: adds the matching elements to the current selection.
* **Remove from selection**: removes the matching elements from the current selection.
* **Cancel**: closes the dialog without changing the selection.
* **Reset**: resets all criteria without closing the dialog.

## Snap
There are several snap options available that can be controled on the window presented when the button ![Snap button](assets/help/images/buttonSnap.png "Snap") is pressed:

* XVI file snap (zero or more options can be selected):
  * __Grid lines__: snap to grid lines.
  * __Grid line intersections__: snap to grid line intersections on the XVI file.
  * __Shots__: snap to shot start and end points on the XVI file.
  * __Sketch lines__: snap to sketch line line points on the XVI file.
  * __Stations__: snap to stations defined on the XVI file.
* Point snap (single option):
  * __None__: no snaping to points in the TH2 file.
  * __Points__: snap to all defined points in the TH2 file.
  * __Points by type__: snap only to the selected point types in the TH2 file.
* Line point snap (single option):
  * __Lines point__: snap to all line points in the TH2 file.
  * __Lines point by type__: snap only to the line points of the line types selcted.
  * __None__: no snaping to line points.

## Zoom and panning
The TH2 file view can be zoomed in and out using the zoom buttons or the mouse wheel.
The view can also be panned by right clicking and dragging the mouse.
_Ctrl+mouse wheel_ pans vertically, _Shift+mouse wheel_ pans horizontally.
