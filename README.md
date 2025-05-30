# Mapiah

[Free software](https://www.gnu.org/philosophy/free-sw.en.html) graphical interface for [Therion](https://therion.speleo.sk/) cave mapping written in [Flutter](https://flutter.dev/).

## Main objectives

User-friendly interface to the powerful Therion mapping software.

As an intended side effect, it aims to completely replace xTherion, the venerable but ostensibly ancient Therion graphical interface.

Also create a thriving community of users and developers to make it as powerful and user friendly as such community needs and creates.

## Interesting characteristics

* Visually distinguish all point, line, and area types supported by Therion.
* Graphical interface for editing all supported options of points, lines, and areas supported by Therion.
* Multiple mouse and keyboard pan and zoom options.
* On save, original file lines are only changed if an actual edit modified them, which facilitates version control management.
* Uses Therion as the source of truth regarding supported features; i.e., if Therion supports it, Mapiah should support it as well.
  * As a secondary effect, tries to update and detail the Therion Book so it better reflects Therion features.
* Equivalent versions for Linux, Windows, MacOS, and web.
* Unlimited undo/redo.
* Redos available after some undos and new actions merged in the undo queue.

<!-- ![](header.png)

## Installation

OS X & Linux:

```sh
npm install my-crazy-module --save
```

Windows:

```sh
edit autoexec.bat
```

## Usage example

A few motivating and useful examples of how your product can be used. Spice this up with code blocks and potentially more screenshots.

_For more examples and usage, please refer to the [Wiki][wiki]._

## Development setup

Describe how to install all development dependencies and how to run an automated test suite of some kind. Potentially do this for multiple platforms.

```sh
make install
npm test
```
-->

## Reporting bugs

As is probably the case in all Free Software projects, the developers of Mapiah also aim to produce completely bug-free software. And as happens in all software, they also fail.

Please register bugs and enhancement suggestions as a [Mapiah Issue](https://github.com/rsevero/mapiah/issues).

When reporting bugs, please consider the following advice, which tries to make everybody happier:

* Check if the behavior you are identifying as a bug is actually a bug. For applicable types of issues, remember that Mapiah treats Therion as the 'source of truth.'
* If applicable, check if the Therion Book clearly defines the behavior you are expecting. If not, please consider submitting an update for the Therion Book.
* Remember that it is almost impossible for a developer to fix an issue the developer can't reproduce or at least see. To help with that, you can (should?):
  * Provide detailed steps explaining how to reproduce the bug;
  * Provide minimal files necessary to reproduce the bug;
  * Provide videos showing the bug (especially recommended for interaction-related issues);
  * Any other info that might help the developers visualize the issue you are reporting.

If you have some free time and want to see the above recommendations more extensively described, read [How to Report Bugs Effectively](https://www.chiark.greenend.org.uk/~sgtatham/bugs.html). I read it a few decades ago and am still impacted.

## Release History

* 0.2
  * Make output identical to original except on changed lines
  * Deal with clicking on more than one object at a time
  * Line edit
  * Point and line removal
  * Point and line addition
  * Status message totaling selected objects
  * Rename Stores to Controllers
  * All buttons (including zoom buttons) should use the default button color
  * Different point and line representations
  * Areas
  * Scrap options
  * Line segment options
  * Show direction of lines
  * Add/delete line segments in existing lines
  * Release creation for Linux
  * Help pages
  * Quick introduction guide
  * BUG: point arrow should be filled
  * BUG: last used point type not updating
  * BUG: saveAs didn't save the changes
  * BUG: correcting set/unset of originalLineInTH@File: MPSetOptionToElementCommand
  * BUG: distinguish normal execute command from those generated by undos: undos should keep originalLineInTH2File, normal ones should not.
  * BUG: 'N' not starting line edit mode
  * BUG: clicking on line segment is not selecting nodes in line edit
  * BUG: multiple control points overlay window opening far away from clicked points
  * BUG: opening a new PLA type/option window does not close another PLA type/option window already opened
  * Enhancement: when starting to drag in edit single line mode, prefer endpoints to control points if no 'multiple points clicked'
  * BUG: fix == operator signature
  * BUG: deleted line points not available at undo/redo
  * BUG: clicking on another element when in 'single line edit mode' does not select the new element
  * BUG: Save button should be disabled when there is no change to save
  * BUG: when trying to move objects, a new selection window is being drawn
  * BUG: added elements get inserted at the end of the file, after the endscrap element
  * BUG: new lines are created without their corresponding endline element
  * BUG: add area not working
  * BUG: clicking on selected control point over end point not moving the control point

## Roadmap
* 0.3
  * Change cursors to show current status
  * Release creation Windows
  * Release creation MacOS
  * Release for Web
  * Release automation Linux
  * Release automation Windows
  * Release automation MacOS
  * Config page
  * Drag overlay windows
  * Copy/Paste
  * Show status message listing what's selected in 'single line edit' mode
  * Moving control points in smooth line segments should move the other control point visually attached to the same end point
  * Set borders on points (and lines and areas?) to show the state of some key options like: mark for line points, visibility for points
  * Show (and edit) orientation and lsize on the line points during edit
  * Snap points
  * Hide elements by type
  * Highlight slope lines without at least one line point with orientation
  * Create shortcut to reverse line
  * Migrate away from Github
  * Include options and point/line count in multiple elements clicked dialog box
  * Add/remove lines from areas
  * Simplifying lines: https://raphlinus.github.io/curves/2023/04/18/bezpath-simplify.html
  * When deleting line points, adjust control points so curve is changed as little as possible
  * When clicking and dragging in non-selected control point, drag the control point
  * Implement Ctrl+O (open file) keyboard shortcut
* 0.4
  * Open multiple files simultaneously
  * Allow copy/paste between scraps
  * Allow copy/paste between files
  * Search/select elements by characteristics
* 1.0
  * Complete coverage of 'Map Editor' features in xTherion
* 2.0
  * Complete coverage of xTherion features
* 3.0
  * User-friendly Therion Project Manager

## Name origin

_Mapiah_ comes from the (Brazilian) Portuguese word _mapear_.

In Portuguese, _Let's go mapping?_ is _Vamos mapear?_.

In Brazil, it is usually pronounced as _Vâmu mapiá?_.

As the internet doesn't deal well with accents, _mapiá_ became _mapiah_.

## Meta

Rodrigo Severo – rsev AT pm.me

Distributed under the GNU GPL 3 license. See [LICENSE](https://github.com/rsevero/mapiah/blob/main/LICENSE.md) for more information.

[https://github.com/rsevero/mapiah](https://github.com/rsevero/mapiah)

## Contributing

1. Fork it (<https://github.com/rsevero/mapiah/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
