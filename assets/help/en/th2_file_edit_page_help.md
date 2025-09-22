This is where all TH2 file editing is done.

## Index
- [Index](#index)
- [Top bar](#top-bar)
- [Edit window](#edit-window)
  - [Top right corner](#top-right-corner)
  - [Bottom right corner](#bottom-right-corner)
- [Drawing lines](#drawing-lines)
- [Element options](#element-options)
- [Simplify lines](#simplify-lines)
  - [Straight line segments](#straight-line-segments)
- [Snap](#snap)
- [Zoom and panning](#zoom-and-panning)
- [Web releases](#web-releases)
  - [Save](#save)

## Top bar
* On the left:
    * ![Back icon](assets/help/images/iconBack.png "Back")  _Back_: returns to the main window without saving contents.
* On the right:
  *  ![Save icon](assets/help/images/iconSave.png "Save")  _Save_: saves changes in same file. Only enabled if there are changes to be saved. (Ctrl+S)
  *  ![Save As icon](assets/help/images/iconSaveAs.png "Save As")  _Save As_: saves changes in new file. (Shift+Ctrl+S)
  * ![Help icon](assets/help/images/iconHelp.png "Help") _Help_: show this dialog box.
  * ![Close icon](assets/help/images/iconClose.png "Close") _Close_: close the TH2 file edit window without saving changes.

## Edit window

### Top right corner
* ![Snap button](assets/help/images/buttonSnap.png "Snap")  _Snap_: toggles the snap window where are presented the snap options. (Ctrl+L)
* ![Delete button](assets/help/images/buttonDelete.png "Delete")  _Delete_: deletes the currently selected elements. Only enabled if there is at least one element selected. (Delete/Backspace)
* ![Undo button](assets/help/images/buttonUndo.png "Undo")  _Undo_: undos the last executed edit operation. Only enabled if there is at elast one edit operation to be undone. (Ctrl+Z)
* ![Redo button](assets/help/images/buttonRedo.png "Redo")  _Redo_: redoes the last undone edit operation. Only enabled if there is at least one edit operation to be redone. (Ctrl+Y)

In case there are available redoes when a new edit operation is performed, the redo stack is migrated to the undo stack making redoes still accessible.

### Bottom right corner
* ![Images button](assets/help/images/buttonImages.png "Imges")  _Images_: opens the images options overlay window. Shows all images inserted in the current file. Presents a "Delete" button for each image and a "Add Image (I)" button. (Alt+I)
* ![Scraps button](assets/help/images/buttonScraps.png "Scraps")  _Scraps_: opens a dialog box to change the current scrap, delete an existing scrap and add a new one. The dialog box shows all available scraps and allows to select one of them. The scrap options overlay window is presented when right clicking on the desired scrap. (Alt+C)
* ![Select element button](assets/help/images/buttonSelectElement.png "Select element")  _Select element_: allows to select elements in the TH2 file. (C)
* ![Line edit button](assets/help/images/buttonLineEdit.png "Line edit")  _Line edit_: allows to edit individual lines in the TH2 file. (N)
* ![Add element button](assets/help/images/buttonAddElement.png "Add element")  _Add element_: allows to add new elements to the TH2 file. On mouse over the following buttons are shown:
  * ![Add point button](assets/help/images/buttonAddPoint.png "Add point")  _Add point_: adds a new point to the TH2 file. (P)
  * ![Add line button](assets/help/images/buttonAddLine.png "Add line")  _Add line_: adds a new line to the TH2 file. (L)
  * ![Add area button](assets/help/images/buttonAddArea.png "Add area")  _Add area_: adds a new area to the TH2 file. (A)
* ![Zoom options button](assets/help/images/buttonZoomOptions.png "Zoom options")  _Zoom options_: presents the zoom options. On mouse over the following buttons are shown:
  * ![Zoom in button](assets/help/images/buttonZoomIn.png "Zoom in")  _Zoom in_: zooms in the TH2 file view. (+)
  * ![Zoom One to One button](assets/help/images/buttonZoomOneToOne.png "Zoom one to one")  _Zoom one to one_: zooms the TH2 file view to show the elements at their original size, i.e., each TH2 point corresponding to a screen pixel. (1)
  * ![Zoom to selection button](assets/help/images/buttonZoomSelection.png "Zoom to selection")  _Zoom to selection_: zooms the TH2 file view to show the currently selected elements. (2)
  * ![Zoom to file button](assets/help/images/buttonZoomFile.png "Zoom to file")  _Zoom to file_: zooms the TH2 file view to show all elements in the file. (3)
  * ![Zoom to scrap button](assets/help/images/buttonZoomScrap.png "Zoom to scrap")  _Zoom to scrap_: zooms the TH2 file view to show the currently selected scrap. (4)
  * ![Zoom out button](assets/help/images/buttonZoomOut.png "Zoom out")  _Zoom out_: zooms out the TH2 file view. (-)

## Drawing lines

When drawing lines, each new segment is initially created as a straight line segment. To convert it to a Bézier Curve line segment, do not release the mouse button and drag. The mouse position will be treated as the position of the single control point of a quadratic Bézier Curve.

Bézier Curves on Therion (and Mapiah) are cubic curves, i.e., they have 2 control points for each segment. Just on line segment creation Mapiah pretends that the Bézier Curve being created is a quadratic Bézier Curve (with only one control point) so the user has flexibility to create the line segment.

Observe that despite the fact that Mapiah is simulating the existance of only one control point, an actual cubic Bézier Curve is being created with two control points as expected.

## Element options
Right clicking on a selected element presents an overlay window with the options available for the currently selected elements.
The options available depend on the type of element selected.

To edit scrap options, right click on:
* the scrap select button on the right bottom corner in case there is only one scrap in the file, or
* the scrap name in the scrap select dialog box presented when clicking on the scrap select button in case there are multiple scraps in the file.

## Simplify lines
Bezier curves and straight line segments are simplified differently. To simplify lines, first select them. There can be other types of elements selected (points or areas) while simplifying lines. They will be untouched by the simplification process. 

### Straight line segments
Each Ctrl+L press runs a round of line simplification. Mapiah uses an interactive (non-recursive) version of the ![Ramer–Douglas–Peucker algorithm](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm) to simplify straight line segments. It operates on canvas space. The initial tolerance (epsilon) is equivalent to 1.5 screen pixels. This value is converted to canvas coordinates. At each subsequent run the tolerance is increased by the same initial value.

## Snap
There are several snap options available that can be controled on the window presented when the button ![Snap button](assets/help/images/buttonSnap.png "Snap") is pressed:

* XVI file snap (zero or more options can be selected):
  * __Grid line intersections__: snap at the grid line intersections on the XVI file.
  * __Shot__: snap at the shot start and end points on the XVI file.
  * __Sketch line__: snap at the sketch line line points on the XVI file.
  * __Station__: snap at the stations defined on the XVI file.
* Point snap (single one option):
  * __None__: no snaping to points in the TH2 file.
  * __Point__: snap at all defined points in the TH2 file.
  * __Point by type__: snap only at the selected point types in the TH@ file.
* Line point snap:
  * __Line point__: snap at all line points in the TH2 file.
  * __Line point by type__: snap only at the line points of the line types selcted.
  * __None__: no snaping at line points.

## Zoom and panning
The TH2 file view can be zoomed in and out using the zoom buttons or the mouse wheel.
The view can also be panned by right clicking and dragging the mouse.
_Ctrl+mouse wheel_ pans vertically, _Shift+mouse wheel_ pans horizontally.

## Web releases

### Save

Saving on web releases are actually download requests. In case you have your browser set to automatically download to a default download folder, please check there for the updated file after save.
