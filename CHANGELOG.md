<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Changelog

## 0.3.4 - 2026-04-04 - The [Back Pain](https://en.wikipedia.org/wiki/Back_pain) release
* Highlights:
  * **Ctrl+A and Ctrl+V in add-element states** let you select all elements or paste clipboard content without first cancelling the add operation; an in-progress line is auto-finalized first.
  * **Extra Therion run parameters** can be typed directly in the Run Therion dialog (persisted as `Main_TherionRunParameters`) and passed via the new `--therion_run_parameters` CLI argument.
  * **Bézier–Bézier line splitting** completes full crossing-split support: all segment-pair combinations (straight–straight, Bézier–straight, Bézier–Bézier) are now handled when splitting selected lines at intersections (Ctrl+Shift+X).
* New features:
  * Select all (Ctrl+A) and paste (Ctrl+V) now work in add-element states (add area, add line, add point): pressing Ctrl+A or clicking the new select-all FAB selects all elements and exits the add mode; pressing Ctrl+V or clicking the paste FAB pastes clipboard content. For add-line, any in-progress line is finalized first (same as pressing Enter) before the action is performed.
  * Therion run parameters: a new text field in the Run Therion dialog lets users enter extra Therion command-line options (e.g. `-d` for debug) that are passed to Therion on every run. The value is persisted as the `Main_TherionRunParameters` setting and can also be set via the `--therion_run_parameters` command-line argument. Closes [#20](https://github.com/rsevero/mapiah/issues/20).
  * Split selected lines at crossings: when two or more lines are selected, pressing Ctrl+Shift+X (or using the new state-context FAB action) splits the selected lines at detected intersection points, preserving options and generating sub-line IDs with numeric suffixes (for lines that already have IDs). Now supports all segment-pair combinations: straight–straight, Bézier–straight, and Bézier–Bézier. Bézier–Bézier intersection is found via recursive AABB subdivision (de Casteljau), and the resulting sub-curves are correctly split using the same de Casteljau algorithm. The action is fully undoable.
  * Join lines at coinciding extremities (Ctrl+J): when two or more lines are selected, pressing Ctrl+J (or using the new state-context FAB action) joins lines whose endpoints are within 3 screen pixels of each other into longer lines. Lines are chained greedily into connected groups; within each group a Hamiltonian-style path is followed and individual line orientations are automatically reversed when needed. Bézier reversal correctly swaps control-point order to preserve the visual curve shape. The joined line inherits the type and options of the first selected line in the chain. When no coinciding extremities are found among the selection a snackbar message is shown. The action is fully undoable.
* Fixed bugs:
  * Split at crossings (Bézier curves): fixed incorrect split point and control-points on final Bézier segment when the same Bézier curve is crossed by a straight line at multiple points. Root cause was twofold: (1) later crossing parameters on the same segment were applied directly to the original Bézier, but they needed reparameterization onto the remaining sub-curve after each earlier split; (2) the final sub-line was being built from the original segment in the file, not from the locally updated remainder segment after successive splits, causing it to retain the original endpoint and control-point definitions. Fixed by reparameterizing repeated crossings onto the current remainder and assembling sub-lines from the locally maintained segment list.
  * Run Therion dialog: keep status shown as 'Running' until all post-run processing completes (including appending therion.log and aggregating issues); final status (`Ok`, `Warning`, or `Error`) is displayed only after processing finishes. Closes [#21](https://github.com/rsevero/mapiah/issues/21).
  * "Rerun Therion" toolbar button now enabled after running Therion (via button or command-line `--thconfig`) even when Therion reports an error or is unavailable; the THconfig path is now always stored so the user can fix settings and rerun without re-picking the file.
  * MPHelpButtonWidget now uses `mpLocator.appLocalizations` directly instead of attempting to retrieve localizations from context, ensuring consistent localization access across the app.
* Infrastructure maintenance:
  * Elapsed time in the Run Therion dialog now updates live every second via a `Timer.periodic` + `ValueNotifier<Duration>`, so only the elapsed time text rebuilds — not the whole dialog.
  * Added EN/PT help pages (`run_therion_help`) for the Run Therion dialog, and a help icon button in the dialog actions row. Updated to document the `--therion_run_parameters` CLI argument.
  * Updated EN/PT help pages (`mapiah_home_help`) to document the `--therion_run_parameters` command-line argument.
  * Updated EN/PT settings help pages (`mp_settings_page_help`) to document the `Main_TherionRunParameters` setting.
  * Included launch.json and pre-commit hook examples.
  * Pre-commit hook ported to work on Windows (replaced `sed -i` with portable `mktemp`/`echo`/`cat`/`tail`/`mv` equivalents).
  * Pre-commit hook now always prints "Running pre-commit hook…" so execution is easy to confirm.

## 0.3.3 - 2026-03-27 - The [Subduction Retrieval](https://xkcd.com/3218) release
* Highlights:
  * **State-context FABs** bring the most-used actions directly onto the canvas, adapting to the current editing state (selection, single-line edit, empty selection).
  * **Default options** let you pre-configure point, line, and area attributes that are automatically applied to every newly created element.
  * **Search and select dialog** lets you find and select elements by type, ID, subtype, and option presence — including per-segment options on lines.
  * **Split line at selected points** (Ctrl+Shift+P) in single-line-edit mode makes it easy to break a line into sub-lines while preserving options.
  * **Hide elements** (Ctrl+H) temporarily removes selected elements from the canvas without saving the change, useful for uncluttering complex scraps.
  * **XVI survey grid visibility** can now be toggled per-image or all at once (Ctrl+G), independently from the image itself.
  * **TH2 file properties page** exposes per-file settings (currently file encoding) via a settings button in each file tab.
  * **Anonymous opt-in telemetry** (daily aggregate usage data — no personal information) with consent dialog on first launch and a Settings toggle.
* New features:
  * Area-border selection shortcuts updated: Ctrl/Meta+click now cycles border-line selection for areas with multiple border lines (all lines → each line in THAreaBorderTHIDs order → all lines again while Ctrl/Meta stays pressed [requested by Marco Corvi]). Area-only selection changed from Ctrl/Meta+Shift+click to Ctrl/Meta+Alt+click.
  * Show direction ticks on non-selected lines: new Settings toggle (TH2Edit_ShowDirectionTicksOnNonSelectedLines, default off). When off, only selected lines show direction ticks (previous behaviour). When on, all lines in the active scrap show direction ticks regardless of selection. Also togglable via Ctrl+Alt+R.  [requested by Marco Corvi]
  * Default option values: pressing 'O' with no elements selected (or clicking the new tune button in the top right corner) opens a "Default options" overlay with Points / Lines / Areas tabs. Options set there are automatically applied to every newly created element of the matching type. A Reset button clears all defaults for the current category.
  * Anonymous telemetry: Mapiah can optionally collect aggregated, anonymous daily usage data (OS type/version, Mapiah version, TH2 open counts and time, Therion run counts and time). A consent dialog is shown on first launch; consent can be changed at any time in Settings. No file paths, personal data, or identifying information is ever collected or transmitted. Data is aggregated client-side before sending and only previous UTC days' records are ever transmitted.
  * XVI image grid visibility toggle: each XVI image row in the available images panel now has a second checkbox to show or hide the survey grid independently from the image itself. Hiding the grid removes the grid lines from the canvas while keeping shots, stations, and sketch lines visible. The grid visibility state is persisted in the session.
  * Toggle all grids visibility button (Ctrl+G): a new icon button in the available images panel header hides or shows all XVI survey grids at once; it is only shown when at least one XVI image is present. The existing toggle all images button tooltip now also displays the Ctrl+I shortcut hint.
  * Checkbox clarity in the available images panel: each image row now shows a small image icon beside the visibility checkbox and a small grid icon beside the grid-visibility checkbox, making it immediately clear which checkbox controls what without needing to hover for a tooltip.
  * Search and select dialog: find and select elements in the current scrap by type, ID, subtype, and option presence. Supports set/add/remove selection actions with live matching count. Accessible via the search button in the top right corner.
  * Search and select dialog: added "By line segment option" filter in the Lines section, allowing lines to be selected based on whether any of their segments have specific options set or unset.
  * Ctrl+H shortcut: hides selected elements from the canvas (they are also deselected and no longer selectable); with no selection, clears all hidden elements and makes them visible again. Hidden elements are a temporary canvas-only state and are not saved to the file.
  * Showing selected elements on single line edit.
  * Show status message listing what's selected in 'single line edit' mode.
  * When moving an object of end/control point, show mouse position in canvas coordinates on status bar.
  * Split line at selected points (Ctrl+Shift+P): in single-line-edit mode, select one or more non-last line points and press Ctrl+Shift+P to split the line at those points. Each resulting sub-line preserves all options of the original; if the original had an -id, sub-lines receive -id suffixed with -1, -2, etc. Area border lines are protected (a message is shown and no split occurs). After splitting, all sub-lines are selected. The operation is fully undoable.
  * State-context FABs: a horizontal row of mini FABs appears at the top-left corner of the canvas and changes based on the current editing state. In single-line-edit mode the row offers: select/deselect all end points (toggle), simplify lines (keep types / force straight / force Bézier), open option window, split line at selected end points, reverse line, and smooth line segments. In non-empty selection mode the row adds: copy, cut, paste, duplicate, create map connection lines, and a select/deselect all elements toggle. In empty selection mode only the select-all toggle and paste button are shown. Buttons are automatically enabled or disabled based on selection state and clipboard content.
* Fixed bugs:
  * State-context FABs in single-line-edit mode (split line, open option window, smooth line segments): buttons were never enabled when selecting an end point. Root cause: `_selectedEndControlPoints` was mutated in-place (`.clear()`, `[key]=value`, `.remove()`), but MobX only fires atom notifications on map **assignment**; the `hasSelectedEndPoints` computed therefore never updated. Fixed by replacing all in-place mutations with full map reassignments.
  * Select/deselect all button: the button never changed from "Select all" to "Deselect all" because areAllElementsSelected always returned false. Root cause: it compared the selected count against getSelectableLogicalElementCount() which returned 0 whenever _mpSelectableElements was null (not yet lazily initialized). Fixed by rewriting areAllElementsSelected to count selectable elements directly from the active scrap's childrenMPIDs, which avoids the lazy-init side effect and keeps the computed pure and reactive.
  * Test 3100 (new file dialog): telemetry consent dialog was blocking the home UI because consent was unset in the test environment. Fixed by setting consent in setUp before pumping the app.
  * MPSettingsController: all setter methods (setBool, setInt, setDouble, setString, setStringList, setEnum) now always write the value to storage, even when it matches the implicit default. Previously, setting a value equal to the default was a no-op, so isXxxSet() returned false as if the setting had never been touched — causing the telemetry consent dialog to reappear on every launch after a user had refused.
  * Telemetry: session time spanning midnight was fully attributed to the new day. The rollover now snapshots active TH2 and Therion session time up to midnight into the old day's record and resets the in-memory session baseline to midnight, so each day receives only the time that actually occurred within it. [suggested by Patrícia Finageiv]
  * "Reset" button in search and select dialog is enabled when there is no active filter configuration.
  * Fixed crash when adding a point with default options configured: option commands (subtype + defaults) are now placed in the posCommand of MPAddPointCommand instead of alongside it in MPMultipleElementsCommand, so they run after the point is in the file and the MPID lookup succeeds. Added regression tests (1305).
  * Reset button in the default options overlay window was invisible when enabled because TextButton defaults to colorScheme.primary for its text, which matched the block's primary background. Fixed by explicitly setting foregroundColor to colorScheme.onPrimary.
* Infrastructure maintenance:
  * Fixed area-border Ctrl/Meta+click cycling: refactored cycle index to use -1 as sentinel for "all border lines selected" (previously 0), making the index directly usable as a list index for individual lines. Fixed double-index-advance bug where pointer-down and pointer-up each called the cycle independently; pointer-down now skips the selectable elements query when Ctrl/Meta-only is pressed.
  * Moved resetAreaBorderCtrlMetaCycle key-up handling from the base MPTH2FileEditState into a dedicated shared mixin applied only to MPTH2FileEditStateSelectEmptySelection and MPTH2FileEditStateSelectNonEmptySelection, limiting the behavior to selection modes.
  * Added widget regression tests for area-border selection shortcuts (3710), including Ctrl/Meta cycling, Ctrl/Meta+Alt area-only selection, and checks that Ctrl/Meta+Shift is no longer area-only.
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
  * flutter upgrade 3.41.6 and flutter pub upgrade --major-versions.
  * Separating current (0.3.X) changelog from previous versions.
  * Added tests for MPTelemetryController (3690): 27 tests covering consent gating, TH2 open/close recording, Therion recording, day rollover, and midnight session snapshot.
  * Added tests for MPSettingsController always-persist behaviour (3692): 12 tests verifying that all setter types (bool, int, double, string, stringList, enum) record the value even when it equals the implicit default, and that the setter return value correctly reflects whether observers should fire.
  * Home page: increased font size of the initial page presentation text to headlineMedium. [requested by Patrícia Finageiv]
  * Cursor changes to a hand pointer when hovering over links in the telemetry consent dialog and in the about dialog (MPURLTextWidget). [requested by Patrícia Finageiv]
  * Telemetry consent dialog body is now loaded from locale-aware markdown assets (assets/help/{locale}/telemetry_consent.md) and rendered with MarkdownBlock, replacing the plain localization string. Falls back to the localization string if the asset cannot be loaded. [requested by Patrícia Finageiv]
  * Canvas cursor now changes to reflect the current editing state: crosshair when adding points or lines, grabbing when moving elements or control points, and the default arrow cursor in select mode.
  * Added MPDefaultOptionsController: plain Dart class that stores default option values per element category (point/line/area), persists them via SharedPreferences (Internal settings), and filters applicable defaults at creation time using MPCommandOptionAux.getSupportedOptionsFor*.
  * Extracted MPOptionsListBuilderMixin: shared mixin eliminating duplicated option-list building and option-selection handling between MPOptionsEditOverlayWindowWidget and the new MPDefaultOptionsOverlayWindowWidget.
  * Added tests for default options (3700): 7 tests covering MPDefaultOptionsController unit behaviour (setDefault, getApplicableDefaults, removeDefault, clearForElementType, hasAnyDefaults) and area creation with clip and subtype posCommands.
  * Removed id from default options: id is now excluded from the default options UI and from getApplicableDefaults, since there is no meaningful default value for a unique identifier. The search/select dialog is unaffected.
  * Default options overlay window now auto-closes on canvas click, consistent with all other overlay windows.
  * Added regression tests for line and area creation with default options (1205, 1255): verify no exception is thrown, that the default option is present on the created element, and that undo restores the original state.
  * Overlay windows now auto-close when any action button is pressed (add point, add line, undo, redo, remove, etc.); zoom buttons are excluded as zooming does not imply dismissing a panel.
  * Added widget tests for select/deselect all button toggle (3730): two tests verify the button changes tooltip and state correctly — one starting from empty selection and one starting with a partial selection — across three consecutive clicks each.
  * Default options toolbar button is now painted in the active (full-color) style whenever any default option is set, giving a persistent visual cue even when the panel is closed. MPDefaultOptionsController converted to a MobX store so hasAnyDefaults is reactive.
  * Default options toolbar button icon changed from tune to auto_fix_high to better represent the concept of preset/initial configuration values.
  * 'O' shortcut with no selection now opens the default options window (previously the call was commented out with a TODO).
  * Default options toolbar button now shows four distinct visual states: pressed+active (primaryContainer, low elevation), pressed+no-defaults (dim, low elevation), unpressed+active (default FAB colors, high elevation), and unpressed+no-defaults (dim, medium elevation). Fixed showDefaultOptionsOverlayWindow reactivity: the previous @readonly Map mutation was invisible to MobX; replaced with a dedicated @observable bool _isDefaultOptionsWindowShown that is kept in sync in setShowOverlayWindow.
  * TH2 file properties page: a settings icon button in each file tab opens a dedicated page to edit per-file properties. Currently exposes the file encoding (THEncoding). Changes are applied immediately on save. If no THEncoding element exists in the file, one is created and prepended as the first child. Introduced TH2FilePropertiesController (MobX) to manage file-level properties editing.
  * Extracted MPTH2FileEditStateKeyDownMixin: keyboard shortcut handling (onKeyDownEvent/_onKeyDownEvent) moved from MPTH2FileEditStateMoveCanvasMixin into a new dedicated mixin, applied to all editing states that previously included MoveCanvasMixin.
  * Change active scrap shortcut corrected to Alt+K (was incorrectly implemented as Alt+S); tooltip and help pages updated.
  * Options edit overlay stays open when pressing "Add area border" button and while clicking lines in addLineToArea state: added keepOverlayOpenOnCanvasClick virtual property to base state (default false), overridden to true in MPTH2FileEditStateAddLineToArea; MPButtonType.addLineToArea added to _noAutoCloseButtonTypes.
  * Area borders panel now refreshes after every border addition: MPAddAreaBorderTHIDCommand._actualExecute calls addOutdatedCloneMPID and triggerOptionsListRedraw so the selection clone and overlay update for both lines with and without pre-existing THIDs.

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
