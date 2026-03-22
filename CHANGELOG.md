<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Changelog

## 0.3.3 - not yet released
* New features:
  * Anonymous telemetry: Mapiah can optionally collect aggregated, anonymous daily usage data (OS type/version, Mapiah version, TH2 open counts and time, Therion run counts and time). A consent dialog is shown on first launch; consent can be changed at any time in Settings. No file paths, personal data, or identifying information is ever collected or transmitted. Data is aggregated client-side before sending and only previous UTC days' records are ever transmitted.
  * XVI image grid visibility toggle: each XVI image row in the available images panel now has a second checkbox to show or hide the survey grid independently from the image itself. Hiding the grid removes the grid lines from the canvas while keeping shots, stations, and sketch lines visible. The grid visibility state is persisted in the session.
  * Toggle all grids visibility button (Ctrl+G): a new icon button in the available images panel header hides or shows all XVI survey grids at once; it is only shown when at least one XVI image is present. The existing toggle all images button tooltip now also displays the Ctrl+I shortcut hint.
  * Checkbox clarity in the available images panel: each image row now shows a small image icon beside the visibility checkbox and a small grid icon beside the grid-visibility checkbox, making it immediately clear which checkbox controls what without needing to hover for a tooltip.
  * Search and select dialog: find and select elements in the current scrap by type, ID, subtype, and option presence. Supports set/add/remove selection actions with live matching count. Accessible via the search button in the top right corner.
  * Search and select dialog: added "By line segment option" filter in the Lines section, allowing lines to be selected based on whether any of their segments have specific options set or unset.
  * Ctrl+H shortcut: hides selected elements from the canvas (they are also deselected and no longer selectable); with no selection, clears all hidden elements and makes them visible again. Hidden elements are a temporary canvas-only state and are not saved to the file.
* Fixed bugs:
  * Test 3100 (new file dialog): telemetry consent dialog was blocking the home UI because consent was unset in the test environment. Fixed by setting consent in setUp before pumping the app.
  * Telemetry: session time spanning midnight was fully attributed to the new day. The rollover now snapshots active TH2 and Therion session time up to midnight into the old day's record and resets the in-memory session baseline to midnight, so each day receives only the time that actually occurred within it. [suggested by Patrícia Finageiv]
* Infrastructure maintenance:
  * Extracted TH2FileEditAreaLineCreationController: separated all area and line creation logic from TH2FileEditElementEditController into a dedicated MobX controller for better separation of concerns.
  * Created TH2FileEditSearchController: new MobX controller for search and select functionality.
  * Added public getAllSupportedPointOptions/LineOptions/AreaOptions getters to MPCommandOptionAux.
  * Removed the legacy TH2FileEditPage entry point, standardized widget tests on TH2FileTabsPage with a shared test helper, and made MPGeneralController.reset clear tab state for isolated tabbed-page tests.
  * Extracted MPDialogBottomWidget: shared widget for the dialog button area (divider + tinted background + rounded bottom corners), used by both the help dialog and the search and select dialog.
  * Removed duplicate TH2FileEditOverlayWindowController.close() method; unified callers to use clearOverlayWindows().
  * clearOverlayWindows() now accepts an optional except parameter to preserve specific window types.
  * Added no-op guard to setShowOverlayWindow() to skip MobX notifications when the window state is unchanged.
  * Search and select dialog: consolidated duplicated option row/subsection builder methods into unified helpers parameterized by option list and state map.
  * Search controller: extracted _matchesOptionStates() helper to eliminate duplicated logic between _matchesOptions() and _matchesLineSegmentOptions().
  * Created TH2FileHideElementController: extracted all hide/show logic for both elements and scraps from TH2FileEditController into a dedicated controller, accessible as hideElementController.
  * Added tests for TH2FileEditSearchController (3680): 23 tests covering getMatchingElements, selectAll, byType, byID, byOption, byLineSegmentOption, resetCriteria, and all three selection actions (setSelection, addToSelection, removeFromSelection).
  * flutter upgrade 3.41.5 and flutter pub upgrade --major-versions.
  * Separating current (0.3.X) changelog from previous versions.
  * Added tests for MPTelemetryController (3690): 27 tests covering consent gating, TH2 open/close recording, Therion recording, day rollover, and midnight session snapshot.

## 0.3.2 - 2026-03-19 - The [Claude](https://en.wikipedia.org/wiki/Claude_(language_model)) release
* New features:
  * Copy/Paste functionality for elements (Ctrl+C / Ctrl+V or Meta+C / Meta+V) with cross-file support and automatic THID conflict resolution.
  * Cut selected elements (Ctrl+X / Meta+X): copies elements to clipboard and deletes originals.
  * Scrap duplication, copy, and cut from the available scraps panel.
  * Multiple TH2 file open support with multi-selection in file dialog.
  * Click-and-drag horizontal scrolling for tabs when many files are open.
  * Mouse wheel scrolling support for tab bar.
  * Tab drag-to-reorder: reorder file tabs by clicking and dragging them with visual insertion point indicator. [requested by Patrícia Finageiv]
  * Command-line argument handling: positional arguments, --th2 (multiple), and --thconfig (single).
  * Created enumeration-backed settings, including the new TH2Edit_newLineCreationMethod setting with localized enum values.
  * Implemented selectable new line creation behavior for both the Mapiah quadratic mode and the xTherion cubic smooth mode with Ctrl-drag distance locking.
  * Show Bézier control points during click-and-drag line creation: CP1 and CP2 visible while dragging, with the dragged handle painted black and others white; control points disappear on mouse release.
  * Per-scrap visibility toggle in the available scraps panel: each scrap row shows a checkbox to hide/show the scrap on the canvas. Hidden scraps cannot be the active scrap. The checkbox is hidden for the active scrap.
  * Added toggle-all scrap visibility button above the scrap list; hides all but the active scrap when all are visible, or shows all when any are hidden. Tooltip and icon update dynamically to describe what the button will do.
  * Added toggle-all image visibility button above the image list; hides all images when all are visible, or shows all when any are hidden. Tooltip and icon update dynamically to describe what the button will do.
  * Scrap reordering via drag-and-drop in the available scraps panel, with animated insertion indicator. Reordering is undoable with Ctrl+Z (MPReorderScrapsCommand).
  * Pasted elements are now automatically selected after a paste; if a scrap was pasted, the selection is cleared instead.
  * Available images panel now supports click-and-drag reordering; image order is persisted in the TH2File top-level children list.
* Fixed bugs:
  * Parsing error dialog now shows the file's basename and full path above the error list so the user knows which file caused the errors.
  * When a file fails to parse, its tab is now automatically closed once the user dismisses the error dialog.
  * Drag-to-reorder (scraps and images): items dropped on a lower-index row landed one position below the visual indicator when dragging downward (off-by-one due to removeAt index shift). Fixed by decrementing newIndex when oldIndex < newIndex.
  * Drag-to-reorder (scraps and images): no drop zone existed after the last row, making it impossible to drag an item to the last position. Fixed by adding a trailing DragTarget with an animated insertion indicator below the last row.
  * Duplicate scrap throws "Bad state: No element": duplicateScrap() was relying on the selection to find the new scrap MPID after paste, but pasteElements() now clears selection after pasting a scrap. Fixed by having pasteElements() return the top-level pasted MPIDs, which duplicateScrap() now uses directly.
  * Duplicate (elements and scrap) was overwriting the clipboard; now saves and restores the clipboard around the internal copy so duplicate never affects clipboard contents.
  * Added tests for duplicate-scrap (3208) and clipboard preservation during duplicate (3210).
  * THAreaBorderTHID.thID not updated when border line THID is conflict-resolved during paste: when pasting an area with a border line into the same file (cross-scrap), the border line's THID gets a conflict suffix but the THAreaBorderTHID reference was never updated, causing crashes in MPSelectedArea creation. Fixed by tracking old-THID → new-THID in MPTHElementPasteAux and applying it in step 6.
  * Duplicate scrap icon looking ugly.
  * Failure decoding "therion.log". [reported by CaverBruce  (issue [#17](https://github.com/rsevero/mapiah/issues/17))]
  * Regular loop error reports being treated as actual errors.
  * Non actual error should not be marked in red.
  * RenderFlex overflow error when resizing window smaller than tab bar width.
  * Tab drag-to-reorder functionality now properly reorders tabs without overflow.
  * Drag feedback image now has rounded corners matching the tab style.
  * Unable to open multiple files at once from home screen (first time opening files).
  * Exception "No element with index '0'" when opening TH2 file from command line.
  * Tab names now display without .th2 extension for cleaner UI.
  * Creating a new file while another file is already open caused a "Multiple widgets used the same GlobalKey" crash due to a duplicate TH2FileTabsPage being pushed onto the navigator.
  * Overlay windows left open on a tab were not closed when switching to another tab.
  * Cross-file scrap paste via Ctrl+V did nothing: switching tabs stole keyboard focus to the outgoing canvas because clearOverlayWindows called requestFocus for every MPWindowType even with no overlay open. Fixed by guarding the requestFocus call with wasOpen, giving focus to the incoming canvas in setActiveTab, and adding a post-frame focus reaction in TH2FileTabsPage.
  * Overlay windows on the current tab were not closed when opening or creating a new file.
  * Test 3100 assertions now correctly expect TH2FileTabsPage instead of TH2FileEditPage.
  * Copy/Paste logic refined: parents (scraps, areas, lines) materialized with empty childrenMPIDs and added at end position; children automatically populate parent childrenMPIDs when added to th2File. Border lines processed before areas during copy. (3/4 duplicate tests now passing)
  * THID conflict resolution for elements with THIDCommandOption: duplicate pasted lines now get new unique THIDs when conflicts exist (all 5/5 duplicate tests now passing).
  * Phase 6 validation tests for multi-element copy/paste: same scrap, across scraps, and cross-file paste with point + line + area elements and implicit border line inclusion (3164-3166).
  * XTherion mode line creation with drag throwing.
  * Available images reordering is now undoable/redoable and uses a dedicated "Reorder images" undo/redo label instead of the generic move-elements message.
* Scripts:
  * Added sort_arb_files.dart script to sort ARB localization files alphabetically; runs flutter gen-l10n automatically only when files change.
  * Pre-commit hook now runs sort_arb_files.dart and re-stages ARB and generated l10n files whenever an ARB file is staged.
* Infrastructure maintenance:
  * Extracted TH2FileEditAreaLineCreationController: separated all area and line creation logic from TH2FileEditElementEditController into a dedicated MobX controller for better separation of concerns.
  * Extracted TH2FileEditCopyPasteController: separated copy/paste/duplicate logic from TH2FileEditElementEditController into a dedicated MobX controller for better separation of concerns.
  * Updated packaging/README.md to mention release constant.
  * Removed Flathub files from scripts/update_flutter_and_mapiah_version.dart.
  * Test for scrap duplication.
  * update_flutter_and_mapiah_version.dart script updating release name and URL constants.
  * Migrated from "rsevero.github.io" to "flatpak.mapiah.org" and updated all installation URLs in documentation and help files.
  * Moved dart format from VSC to git hook.
  * Including instructions to Claude update help pages when adding new features or changing existing ones.
  * Added SPDX license identifiers to all Dart and Markdown source files.
  * Updated pre-commit git hook to automatically add SPDX headers and copyright information to new Dart and Markdown files.
  * Added comprehensive pre-commit hook documentation with examples and troubleshooting guide.
  * Fixed pre-commit hook `sed -i` to `sed -i''` for Windows (Git Bash) compatibility; updated installation docs to mention Git Bash requirement on Windows.
  * Renamed MPDuplicateElementResult parameters.
  * Refactored THFile class rename: updated all variable names (thFile → th2File, _thFile → _th2File), related properties throughout the codebase, and THFile → TH2File in comments.
  * Renamed `_filenameAndScrap` to `_currentScrapName` and updated to store only scrap name, not filename (filename is already shown in tab).
  * Updated help pages (EN/PT) with documentation for scrap copy, cut, duplicate, and per-scrap visibility toggle.
  * Added settings help pages (EN/PT) covering all settings and their sections; added help button to the settings page AppBar.
  * Fixed help dialog rendering HTML comments (SPDX license headers) as visible text: markdown is now pre-processed to strip HTML comments before display.
  * Fixed help dialog "Close" button being hidden when help content is long: the markdown body now scrolls independently while the Close button stays pinned in a visually separated footer.
  * Improved image reorder drag feedback: dragged row disappears from the list while a semi-transparent row preview follows the cursor; an animated colored bar opens above the hovered drop target to indicate the insertion point.
  * Updated help pages (EN/PT) with documentation for image visibility toggle and image reordering via drag-and-drop.

## 0.3.1 - 2026-03-13 - The [Memória Musical](https://radios.ebc.com.br/memoria-musical) release
* New features:
  * Changed "Create map connection line from point X-Section to Station" shortcut from Ctrl+X to Ctrl+Alt+X.
  * Including an ID on automatically added map connection lines.
  * Translating option names on status bar.
  * Element duplication with Ctrl+D.
* Fixed bugs:
  * "Run Therion" button blinking red on every start.
  * Status bar message not updating on option edit.
  * Duplicated point appearing after scrap.
  * Duplicated elements with THID throws because of duplicate THID.
  * REGRESSION: When moving line point that didn´t snap, it would jump arbitrarily on the screen. [reported by Daniel Bean]
* Infrastructure maintenance:
  * Created MPCommandAux.addTHIDToElement().
  * Upgrade actions/checkout github action from v4 to v6.
  * Tight flatpak GitHub action permissions.
  * Removi flatpak mention on AppImage GitHub action.
  * flutter upgrade to 3.41.4.
  * flutter pub upgrade --major-versions.
  * Make copyWith do a deep copy for options map, children, etc.
  * Test point duplication.
  * Default positionInParent on MPCommandFactory.addElements() changed to mpAddChildAtEndMinusOneOfParentChildrenList.
  * Use a cache for updating THIDs of duplicated elements and their options.
  * Test line duplication.
  * Created MPTHElementDuplicatorAux class.
  * Make _updatedTHIDsMap an internal class variable on MPTHElementDuplicatorAux.
  * Test area duplication.
  * Removed from packaging/README.md the instructions to build Flathub release.

## 0.3.0 - 2026-03-09 - The [Great Fanfarra](https://youtu.be/HlV59UbrY-E) release
* New features:
  * Include contents of 'therion.log' file at end of Therion output.
  * If there are more than 3 newer versions available, warn the user of the newer versions on all runs instead of just showing the "New version available" dialog once a day.
  * At the "Therion run" window, create a "Run Therion" button. [requested by Edvard]
  * Enable shortcuts Esc, Ctrl+T and T at "Therion run" window.
  * Adding start and end time at Therion run output.
  * When creating a point or a line point, it should snap to near elements.
  * When clicking on an area, Ctrl (or Meta+Click) selects the area (and not the line), Shift+Ctrl+Click (or Meta+Shift+Click) selects the line (and not the area).
  * Created keyboard shortcut Ctrl+X that creates a "Map connection" line between the "section" point and the "base" point the section refers to. [requested by Edvard]
  * At flathub_disable.md, explain why Flathub version is being disabled.
  * At "newer versions available" page, also show how many commits and how many days the users installed version is old.
  * Release name and URL at About dialog.
* Fixed bugs:
  * Newer version available window not appearing in Flathub version.
  * On very fast Therion executions, therion.log file content not being included in Therion run output.
  * Bézier created from straight lines are too tight.
  * Status bar info for selected elements not internationalized.
  * Current PLA type at PLA type selection overlay with too small left and bottom margins.
  * Zoom to file or to scrap should not consider images not visible.
  * When clicking on the name of an image, checkbox is not changed on "available images" dialog box.
* Infrastructure maintenance:
  * Enabling github created flatpak generation.
  * New "New version available" page.
  * Created debug new version structure.
  * Improving newer version available messages.
  * Mapiah constants should start with 'mp' prefix. Save the 'th' prefix for Therion related constants.
  * Simplifying and reorganizing code related to Bézier curves and straight line segments simplification and conversion.
  * Review portuguese translations of PLA types and subtypes.
  * Renaming mpSubtype* localization strings to thSubtype*.
  * Included "Used on:..." on translation strings.
  * Created scripts/generate_releases_brief.dart and assets/releases/releases_summary.json to speed new version check.
  * Including "Accept-Encoding: gzip" on all http requests.
  * All clearBoundingBox() calls clear ancestor bounding boxes.
