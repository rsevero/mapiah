<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 7: Remove the Scrap Button and Dialog

**Date:** 2026-09-24  
**Status:** Proposed. Outcome A of parent plan Phase 7 (remove completely) was chosen on 2026-09-24. First checked against the code on `main` at `606d728d`, while Phase 4 was being implemented. Validated again on 2026-09-28 against `main` at `abeaba4d`, with Phase 4 merged: every Phase 4 name used here exists and behaves as described. That validation added new unsaved files to §3, the placeholder values and tree selection of standalone rows (§3.1), the multi-scrap visibility method (§5), and the existing `optionsScrapMPID` (§7.1), and corrected the help line numbers (§10.2) and the `t3741` plan (§12). A third check on 2026-09-28, at `2628c280`, extended the option target to every option edit method and to the options state map refresh (§7.1), replaced the scrap options toggle with a show method (§7.2), and re-syncs standalone tree selection after project changes (§3.1).  
**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md)  
**Prerequisite:** Phase 4 is merged: scrap selection (Phase 4 plan §3.6), `prepareTH2FileForTreeEdit` (§3.5), the tree mode-exit helper and the right-click rules (§6.2), and the scrap-row context menu (§6.1).  
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose

The canvas's right-hand action column has a scrap button (`_changeScrapButton` in `th2_file_edit_action_buttons_widget.dart`, tooltip "Change active scrap (Alt+K)"). It opens a dialog (`MPWindowType.availableScraps` → `MPAvailableScrapsWidget`) that lists the file's scraps. After Phase 4, the project sidebar already chooses the active scrap and reorders scraps. This phase moves the dialog's remaining features into the sidebar, then removes the button and the dialog.

## 2. What the dialog does, and where each feature goes

| Dialog feature | Code today | Replacement |
|---|---|---|
| Choose the active scrap (radio) | `setActiveScrap` | Plain click on a scrap row (Phase 4). Nothing to do. |
| Reorder scraps (drag handle) | `reorderScraps` via `MPReversedListIndexHelper` | Scrap drag, order menu and shortcuts (Phase 4). Nothing to do. |
| Show/hide one scrap (checkbox) | `hideElementController.toggleScrapVisibility` | Eye toggle on scrap rows (§5), plus a menu item. |
| Hide all but active / Show all scraps | `hideElementController.toggleAllScrapsVisibility` | File-row menu item (§6). |
| Copy, Cut, Duplicate scrap | `copyPasteController.copyScrap`, `cutScrap`, `duplicateScrap` | Scrap-row menu items (§4). |
| Remove scrap | `elementEditController.removeScrap` | Scrap-row menu item "Delete" (§4). |
| Scrap options (right-click on a row) | `setSelectedScrapByMPID` + `perfomToggleScrapOptionsOverlayWindow` | Scrap-row menu item "Options…" (§7). |
| Add scrap (button under the list) | `MPButtonType.addScrap` | `K` and the add-scrap action button stay. Also a file-row menu item (§6). |

`Alt+K` (`toggleToNextAvailableScrap`, also reached through `MPButtonType.changeScrap`) and `Alt+click` on an inactive scrap do not use the dialog and stay unchanged.

The dialog lists scraps in reverse file order (the scrap drawn on top first). The tree lists them in file order, with the header tooltip explaining the order (Phase 3). The help text (§10.2) points this out for users who are used to the dialog.

## 3. Open `.th2` tabs that have no tree row

The tree only shows files that belong to the loaded project. Today a `.th2` tab can still be open without a tree row:

- a file given on the command line (`--th2` or a positional `.th2` argument, `TH2FileTabsPage._openTH2FileFromPath`), with no project or outside the project;
- a file saved with TH2 Save As to a path that the project does not reference. `renameFileController` moves the controller and the tab to the new path, but the project graph is not rewritten;
- the same files after the project is closed or replaced: `closeProjectFileTabs` leaves tabs outside the project open;
- new, never saved files (tab names `NEW_TH2_FILE_<n>`, from `mpNewFilePrefix`). They are canvas tabs with no path on disk: `MPGeneralController._normalizeFilename` returns their names unchanged, and they never have a project node.

Once the dialog is gone, these tabs would have no way to change their active scrap except `Alt+K` and `Alt+click`, and no way to reorder, hide, copy, delete or edit scraps. So the sidebar gets a new section for them.

### 3.1 "Open files outside the project" section

- Below the project rows, the tree shows a header row, "Open files outside the project", followed by one `.th2` file row for every open canvas tab (`isTH2Tab`) whose canonical path has no project node (`THProjectController.nodeByCanonicalPath(path) == null`). This includes new, never saved files. The rows follow `MPGeneralController.openFileOrder`. The section is hidden when there are no such tabs.
- When no project is loaded, the section is shown under the empty-state actions (Open project, and so on) instead of replacing them.
- Each file row is a synthetic `TH2FileNode` built from the tab's key in `openFileOrder` (the canonical path, or `NEW_TH2_FILE_<n>` for a new file). It uses the same row widget, chevron, badge and element rows as project `.th2` rows, so every Phase 3–7 feature (selection, drag, menus, shortcuts) works the same way. Its required fields get these values:
  - `id`: `standalone:<tab key>` (see below);
  - `label`: the tab's own label, the last path segment without `.th2`, as `TH2FileTabsPage._buildDraggableTab` shows it; so a new file shows `NEW_TH2_FILE_<n>`;
  - `absolutePath` and `sourceFilePath`: the tab key. The file row's tap handler (`THProjectTreeNodeWidget._onTap`) passes `absolutePath` to `getTH2FileEditController` and `addFileTab`, which then find the existing tab, including a new file's;
  - `relativePathToProjectRoot`: the tab key, since there is no project root;
  - `lineNumber`: `0`; `encoding`: the file controller's encoding, or `mpDefaultEncoding` for a new file.

  No other code may read these placeholder values as a real project path. In particular, project lookups by path (`nodeByCanonicalPath`, `isTH2FileRowExpanded`) are never used with a standalone row.
- **Tree selection:** tapping a standalone row calls `THProjectController.selectNode` with its synthetic id, as for project rows, so `activeSelectedNodeId` can hold a standalone id. `MPGeneralController._syncProjectTreeSelectionToActiveTab` is a no-op today for a tab without a project node. It changes to select the standalone id `standalone:<tab key>` in that case, and the selection is cleared when that tab closes. Loading, reloading or closing a project sets `activeSelectedNodeId` to `null` (`THProjectController._clearProjectState`), even when the active tab is a standalone file that stays open, so the active tab's selection is synced again after each of these.
- **No tab-less state:** these files always have an open tab and a loaded controller, so there is no background load. `isTH2FileRowLoadEligible` and `loadTH2FileIfEligible` are never called for them. They are written for project nodes only (`isTH2FileRowLoadEligible` ends with `nodeByCanonicalPath(...)!`), so the standalone row's expand handler skips them instead of relying on their early returns. When the tab closes, the row disappears.
- **Separate expansion state:** `THProjectTreeUIController` gets an observable `expandedStandaloneTH2FileIds` set, keyed by `standalone:<tab key>`. Its `isExpanded`, `toggleExpanded`, `expand` and `collapse` methods route standalone ids to this set and project ids to the existing `expandedNodeIds`. `_handleProjectRootChanged` continues to clear only project expansion on a null root and checks only project expansion before applying a new project's default expansion. It neither clears nor counts standalone ids. Closing a standalone tab removes its id from the standalone set. This keeps the file expanded across project close, load and reload without suppressing default expansion of the project tree.
- **Filtering:** the section's element rows are filtered like project rows. The header row stays visible while any of its file rows matches.
- **Tab switching:** activating such a tab selects its file row, through the `_syncProjectTreeSelectionToActiveTab` change above.
- **Save As of a new file:** after TH2 Save As, `renameFileController` moves the tab from `NEW_TH2_FILE_<n>` to the real path. The row follows the new tab key. Its expansion and selection move to the new synthetic id; if the new path belongs to the project, the row moves out of the section into the project tree and its expansion moves to that project node's id in `expandedNodeIds`. The old standalone id is removed in either case. The same migration applies when an existing outside-project file is saved under another path or becomes a project file after a project reload.
- **Where it is built:** `THProjectTreeWidget._buildVisibleRows` appends the section after `flattenVisibleNodes`, reusing the same `th2ElementRowsFor` callback. The flattener itself does not change. The tree observer reads `MPGeneralController`'s open-tab list and controller-registry revision, so the section follows tab opens, closes and Save As renames.

## 4. Scrap-row context menu

Phase 4 gives scrap rows the four order items. This phase extends the menu:

| Row | Items |
|---|---|
| scrap | Bring forward, Send backward, Bring to front, Send to back, divider, Copy, Cut, Duplicate, Delete, divider, Hide / Show, Options… |

- **Menu target:** as in Phase 4 plan §6.2. On a selected scrap row, the menu acts on every selected scrap. On an unselected scrap row, it acts on that scrap only and does not change the scrap selection.
- **Before every item** that changes the file: call `prepareTH2FileForTreeEdit(th2FilePath)`, as Phase 4 does, and do nothing when it returns `null`. This opens and activates the tab of a tab-less file, so the edit can be seen and undone.
- **Copy, Cut, Duplicate:** new list versions of the existing helpers, `copyScraps(List<int>)`, `cutScraps(List<int>)` and `duplicateScraps(List<int>)`, in `TH2FileEditCopyPasteController`. They pass all target scraps to `setSelectedElements` and then call the existing `copySelectedElements`, `cutSelectedElements` and `duplicateSelectedElements`, which already accept several top-level elements. The single-scrap methods become one-line wrappers, or are removed if nothing else calls them. Cut and Duplicate each make one undo step. After Duplicate, the first new scrap becomes active, as today.
  - **Scrap selection:** these helpers end with `clearSelectedElements()`, which clears only the canvas selection (`mpSelectedElementsLogical`, `isSelected`) and leaves `selectedScrapMPIDs` alone, as Phase 4 plan §3.6 requires (checked 2026-09-28). `setSelectedElements` with only scraps also leaves the scrap selection alone: it clears it only when it adds a point, line or area. The helpers do clear any point, line or area selection, as the dialog does today; that is acceptable, because the menu is opened on a scrap row.
- **Delete:** `elementEditController.removeScraps(List<int>)`. It builds one `MPRemoveScrapCommand` per scrap (`MPCommandFactory.removeScrapFromExisting`) and wraps them in one `MPMultipleElementsCommand` when there are several. It is one undo step. It does not call `setActiveScrapForScrapRemoval` itself: `MPRemoveScrapCommand._actualExecute` already calls it before removing its scrap, and the commands run one after another, so the active scrap always ends on a remaining scrap (or `0` when none is left). The same call in `removeScrap` is redundant; `removeScrap` becomes a wrapper of `removeScraps` or is removed. Removed MPIDs leave the scrap selection through Phase 4's stale-id pruning. The label is "Delete" (existing key `th2FileEditPageRemoveScrapButton` reads "Remove scrap"; see §10.1). Deleting the last scrap stays allowed, as in the dialog.
- **Hide / Show:** see §5. It needs no open tab, because visibility is view state (§5).
- **Options…:** see §7. It is enabled only when the menu target is a single scrap.
- Disabled items follow Phase 4 plan §6.1: an item that would do nothing is disabled.

## 5. Scrap visibility in the tree

- **State:** unchanged. `TH2FileHideElementController._hiddenScrapMPIDs` is an observable set per file controller. It is not saved and not undoable, and it exists for tab-less controllers too.
- **Eye toggle:** each scrap row gets a trailing eye icon button (`Icons.visibility` / `Icons.visibility_off`, `mpSmallIconSize`) with the existing tooltip `th2FileEditPageToggleScrapVisibilityTooltip`. It calls `hideElementController.toggleScrapVisibility(scrapMPID)`. Clicking it does not select the row, does not change the tree selection and does not start a drag.
- **Rules kept from the dialog:**
  - the toggle is hidden when the file has only one scrap;
  - the active scrap's toggle is disabled when it is the only visible scrap (`visibleScrapCount <= 1`);
  - hiding the active scrap moves the active scrap to the nearest visible one (`_setActiveScrapForVisibilityHide`, unchanged).
- **Hidden rows:** a hidden scrap row's label is shown in `colorScheme.onSurfaceVariant` with the eye-off icon, so hidden scraps are recognizable without hovering. Its child rows stay visible and editable in the tree.
- **No tab needed:** toggling visibility of a tab-less file changes only that controller's view state. It does not open a tab, and the new state shows when the tab is opened.
- **Menu item:** "Hide" / "Show" in the scrap-row menu does the same for the menu target. With several targets, it hides them all if any is visible, and shows them all otherwise. It never hides the last visible scrap: if the targets include every visible scrap, the active scrap stays visible.
  - **New method:** `toggleScrapVisibility` flips one scrap, so calling it on each target would show the hidden targets while hiding the visible ones. `TH2FileHideElementController` gets `setScrapsHidden(List<int> scrapMPIDs, bool hidden)`, one `@action` that sets every target to the given state, keeps one scrap visible as described above, moves the active scrap with `_setActiveScrapForVisibilityHide` when the active scrap is hidden, and then updates the station-name cache, the snap targets and the redraw once. The single-target menu item and the eye toggle can keep using `toggleScrapVisibility`.
- **Observability:** the eye icon and the dimmed label observe `hiddenScrapMPIDs` in a row-scoped `Observer`, like the Phase 3 selection highlight.

## 6. File-row context menu

`.th2` file rows of loaded, valid files (project and §3.1 rows) get a context menu. Broken and load-error rows keep only their Phase 3 Reload item.

| Row | Items |
|---|---|
| valid, loaded `.th2` file | Add scrap, divider, Hide all but active / Show all scraps |
| valid `.th2` file not loaded yet | no menu (as today) |

- **Add scrap:** `prepareTH2FileForTreeEdit`, then `stateController.onButtonPressed(MPButtonType.addScrap)`, after the canvas has laid out (§7.2), because the add-scrap dialog is a canvas overlay.
- **Hide all but active / Show all scraps:** `hideElementController.toggleAllScrapsVisibility()`, with the dialog's two labels (`th2FileEditPageToggleAllScrapsVisibilityHideOthersTooltip` / `…ShowAllTooltip`) chosen from `allScrapsVisible`. It is disabled when the file has only one scrap. It opens no tab.

## 7. Scrap options from the tree

### 7.1 Option edits target the scrap directly

Today the scrap options window edits whatever is in `selectionController.mpSelectedElementsLogical`. That is why the dialog's right-click calls `setSelectedScrapByMPID`, which leaves a stray `MPSelectedScrap` in the canvas selection (Phase 4 plan §3.4, §3.6). The tree must not add one again. So:

- `TH2FileEditOptionEditController` already has the target: `optionsScrapMPID` (`@readonly`, default `-1`), set by `setOptionsScrapMPID` from `perfomToggleScrapOptionsOverlayWindow` and read by `MPScrapOptionsEditWidget`. Today nothing resets it. It is reset to `-1` when the scrap options window closes, in `setShowOverlayWindow(MPWindowType.scrapOptions, false)`.
- **Option edit targets.** Five methods of `TH2FileEditUserInteractionController` take their candidate elements from `selectionController.mpSelectedElementsLogical` (checked 2026-09-28): `_prepareSetOption`, `_prepareUnsetOption`, `prepareUnsetAttrOption`, `_prepareSetMultipleOptionChoice` and `_prepareUnsetMultipleOptionChoice`. A new private helper returns the elements an option edit targets: `[th2File.scrapByMPID(optionsScrapMPID)]` while the scrap options window is shown (`isOverlayWindowShown[MPWindowType.scrapOptions]`), and the selected elements otherwise. All five methods use it. The condition is the window, not `optionsScrapMPID >= 0`, so a missed reset can never send a later option edit to a stale scrap. Their line-segment branch (`selectedEndControlPoints`) is unchanged. Setting an `attr` option goes through `_prepareSetOption`, so it is covered.
- **Options state map.** Opening the window builds the map from the scrap (`updateElementOptionMapByMPID`). But after each edit, the methods above refresh it with `optionEditController.updateOptionStateMap()`, which rebuilds it from `mpSelectedElementsLogical`. Today that works only because the dialog puts the scrap into the selection. So `updateOptionStateMap` changes too: while the scrap options window is shown, it calls `updateElementOptionMapByMPID(optionsScrapMPID)` instead. This covers its other callers as well (commands, the element edit toggles), so the window never shows the selection's options.
- `TH2FileEditSelectionController.setSelectedScrapByMPID` is removed. It has no other caller.
- Phase 4's clean-up of stray `MPSelectedScrap` entries stays as a safety net. The copy, cut and duplicate helpers still put scraps into the selection for a moment.

### 7.2 Opening the window

The window is a canvas overlay, so it needs the file's tab to be open and laid out.

1. `prepareTH2FileForTreeEdit(th2FilePath)`; stop if it returns `null`.
2. If the canvas of that tab is not laid out yet (`getTH2FileWidgetGlobalKey().currentContext == null`, which is the case right after a tab-less file's tab is opened), wait with `addPostFrameCallback` and check again, for at most `mpTreeCanvasOverlayMaxWaitFrames` frames (new constant, 3). If the canvas is still not there, do nothing.
3. Compute the anchor in canvas-local coordinates with `MPInteractionAux.getWidgetRectFromContext(widgetContext: <row context>, ancestorGlobalKey: getTH2FileWidgetGlobalKey())`, as the dialog does. The row is not a descendant of the canvas, but `RenderObject.getTransformTo` accepts any render object in the same tree, and the dialog (in the root overlay) relies on that already. The anchor x is `0` (the canvas's left edge, next to the sidebar); y is the row's centre clamped to the canvas height. If the row is no longer mounted, use the vertical centre of the canvas.
4. Open the window for the target scrap. `perfomToggleScrapOptionsOverlayWindow` toggles: it closes the window when it is already shown, even for another scrap. Today a pointer-down on the sidebar closes the canvas overlays first (`TH2FileTabsPage._closeOverlayWindowsOnClickOutsideDrawingArea`), but a menu opened without a pointer-down would not. So the method becomes `performShowScrapOptionsOverlayWindow(scrapMPID:, outerAnchorPosition:, innerAnchorType:)`, which always shows the window for `scrapMPID`. If the window is already shown, it first closes it with `setShowOverlayWindow(MPWindowType.scrapOptions, false)`: `_showOverlayWindow` reuses an existing `OverlayEntry` as it is, so showing it again would keep the old anchor. Then it sets `optionsScrapMPID`, updates the options state map and calls `setShowOverlayWindow(MPWindowType.scrapOptions, true, …)`, which builds a new entry at the new anchor. The dialog was the only caller of the toggle, so the toggle is replaced. The tree passes `innerAnchorType: MPWidgetPositionType.centerLeft`, where the toggle hard-codes `centerRight`. The window then opens to the right of the sidebar, level with the row.

## 8. What is removed

- `TH2FileEditActionButtonsWidget._changeScrapButton` and its call in `build`.
- `MPAvailableScrapsWidget` (`lib/src/widgets/mp_available_scraps_widget.dart`).
- `MPWindowType.availableScraps`, its case in `MPOverlayWindowFactory`, and its entries in `autoDismissOverlayWindowTypes` and `_getMutuallyExclusiveOverlayWindowTypes` (the `changeImage` case then returns an empty set).
- `MPGlobalKeyWidgetType.changeScrapButton` and its global key.
- `_isChangeScrapWindowShown` / `showChangeScrapOverlayWindow` in `TH2FileEditOverlayWindowController`, and their use in `showRemoveButton` and `showSnapButton` in `th2_file_edit_controller.dart`. Both then check only the image dialog.
- `TH2FileEditSelectionController.setSelectedScrapByMPID` (§7.1).
- `TH2FileEditOverlayWindowController.perfomToggleScrapOptionsOverlayWindow`, replaced by `performShowScrapOptionsOverlayWindow` (§7.2).
- `.arb` keys used only by the dialog: `th2FileEditPageChangeActiveScrapTool` and `th2FileEditPageChangeActiveScrapTitle` (EN/PT), then `flutter gen-l10n`.
- The help image `assets/help/images/buttonScraps.png`, once §10.2 removes its only uses (EN help lines 141 and 397, PT help lines 248 and 327). Check with `grep -rn buttonScraps assets lib` before deleting it.

**Kept:**

- `MPReversedListIndexHelper` and its test `t2461`: `mp_available_images_widget.dart` uses it too.
- `mpScrapButtonImagePath` and its asset: the add-scrap button uses it.
- `TH2FileEditController.availableScraps()`: `mp_scrap_option_widget.dart` uses it.
- `MPButtonType.changeScrap` and `toggleToNextAvailableScrap` (`Alt+K`).
- The dialog's copy/cut/duplicate/remove/visibility `.arb` keys, reused by §4–§6 with updated `Used on:` descriptions.

## 9. Changes to what Phase 4 describes

Phase 4 is finished, and its plan stays as it was written. These points supersede it, and this phase carries them out:

- **Test numbers.** The Phase 4 plan (§10) gives Phase 7 `t3952`. Since this phase was added, the type preview icons phase is Phase 8 and keeps `t3952`; this phase uses `t3953`.
- **Leftover scraps in the canvas selection.** The Phase 4 plan (§3.4, §3.6) names the scraps dialog's `setSelectedScrapByMPID` as the source of an `MPSelectedScrap` left in `mpSelectedElementsLogical`. This phase removes the dialog and that method (§7.1), so the copy, cut and duplicate helpers become the only way a scrap enters that map, and only for a moment. Phase 4's clean-up of such entries and its rejection of mixed selections stay as a safety net.

## 10. Localization, help and changelog

### 10.1 Strings

In `lib/l10n/intl_en.arb` and `intl_pt.arb`, each with an `@key` description ending in `Used on: <Class>.<method>`, followed by `flutter gen-l10n`.

| Key | EN | PT |
|---|---|---|
| `th2ElementTreeOutsideProjectHeader` | `Open files outside the project` | `Arquivos abertos fora do projeto` |
| `th2ElementTreeCopy` | `Copy` | `Copiar` |
| `th2ElementTreeCut` | `Cut` | `Recortar` |
| `th2ElementTreeDuplicate` | `Duplicate` | `Duplicar` |
| `th2ElementTreeDelete` | `Delete` | `Excluir` |
| `th2ElementTreeHide` | `Hide` | `Ocultar` |
| `th2ElementTreeShow` | `Show` | `Mostrar` |
| `th2ElementTreeScrapOptions` | `Options…` | `Opções…` |
| `th2ElementTreeAddScrap` | `Add scrap` | `Adicionar scrap` |

New short keys are used for menu items, because the existing dialog keys include the word "scrap" or a shortcut hint ("Add scrap (K)"), which reads oddly in a scrap row's own menu. The eye toggle's tooltip and the file-row visibility item reuse the existing dialog keys.

### 10.2 Help pages (EN/PT)

- `th2_file_edit_page_help.md`:
  - remove the "Scraps" action-button entry (line 141 in EN, 327 in PT, on 2026-09-28), which also mentions an `Alt+C` shortcut and a right-click on the button that do not exist in the code;
  - rewrite the "Scraps" section (line 396 in EN, 247 in PT) and its subsections (Scrap copy, cut, duplicate, visibility, reordering) around the project sidebar: the scrap-row menu, the eye toggle, the file-row menu, and the "Open files outside the project" section. Mention that the sidebar lists scraps in file order, top row drawn first, while the old dialog listed them the other way round;
  - rewrite "To edit scrap options, right click on…" (Element options section): right-click a scrap row and choose Options….
- `keyboard_shortcuts_edit.md`: no shortcut changes. `Alt+K` stays.

### 10.3 CHANGELOG

One Phase 7 entry in the unreleased section, under "New features", referencing #32. It says that the scrap button and dialog were removed and where each of its features is now, and lists the new test file.

## 11. Implementation order

1. Option target refactor (§7.1) and removal of `setSelectedScrapByMPID`, with tests. The dialog still works at this point, using the new target.
2. `copyScraps`, `cutScraps`, `duplicateScraps`, `removeScraps` (§4), with tests.
3. Visibility toggle and hidden-row style (§5).
4. Scrap-row menu items (§4) and file-row menu (§6), with the canvas-layout wait (§7.2) and the anchored options window.
5. "Open files outside the project" section (§3.1).
6. Remove the button, dialog and related code (§8). Update or remove the tests that depend on them (§12).
7. Strings (§10.1) together with steps 3–5, never as a later clean-up. Help pages (§10.2).
8. Run the focused tests, `flutter analyze` and the full test suite. Do not run `build_runner` manually or `dart format`.
9. CHANGELOG entry (§10.3).

## 12. Tests

### New: `test/t3953_th2_element_tree_scrap_actions_test.dart`

- **Copy, Cut, Duplicate, Delete** from the scrap-row menu, on one scrap and on a scrap selection of several scraps: the clipboard content, the resulting scraps, one undo step each, undo and redo restoring the file, and the scrap selection unchanged by Copy and Duplicate and pruned by Cut and Delete. On a tab-less file, each item opens and activates the tab first.
- **Visibility:**
  - the eye toggle hides and shows a scrap on a tab-less file without opening a tab;
  - the toggle is hidden with one scrap, and disabled on the active scrap when it is the only visible one;
  - hiding the active scrap moves the active scrap;
  - clicking the toggle does not change the tree selection;
  - the menu item with several targets, some visible and some hidden, hides them all, and never hides the last visible scrap;
  - the file-row item switches between "Hide all but active" and "Show all scraps".
- **Options…:**
  - opens the scrap options window on the canvas, anchored at the canvas's left edge level with the row, also for a tab-less file whose tab is opened by the action;
  - setting and unsetting an option changes the scrap, not a selected point, line or area. Cover a plain option, a multiple-choice option (`-flip`) and `attr`, set and unset;
  - after each edit the window still shows the scrap's options, not the selection's;
  - choosing Options… on another scrap while the window is open shows that scrap's options instead of closing the window;
  - after the window closes, setting an option acts on the selection again;
  - no `MPSelectedScrap` is added to `mpSelectedElementsLogical`;
  - closing the window resets `optionsScrapMPID`;
  - the item is disabled with several target scraps.
- **Add scrap** from the file-row menu opens the add-scrap dialog on the file's canvas.
- **Open files outside the project:**
  - a `.th2` tab outside the project (opened as the startup code does, and after a TH2 Save As to a path outside the project) shows under the section header, with and without a loaded project;
  - its element rows support selection, the order menu and the new scrap actions;
  - closing the tab removes the row, and a file that becomes part of the project after a project reload moves out of the section;
  - no background load is ever scheduled for its rows;
  - a new, never saved file shows in the section with its `NEW_TH2_FILE_<n>` label, supports the scrap actions, and after Save As follows the renamed tab;
  - an expanded standalone file stays expanded through project close, load and reload, while newly loaded project rows still receive their default expansion; Save As and a project reload migrate its expansion to the replacement row, and closing its tab removes the standalone expansion id;
  - activating such a tab selects its row, and closing it clears that selection.

### Updated or removed

- `test/t3741_ui_change_scrap_overlay_hides_top_right_buttons_test.dart`: its only test opens the scrap dialog and checks that the Snap and Remove buttons disappear. `showRemoveButton` and `showSnapButton` keep checking the image dialog, so rewrite the test to open the image dialog (`MPWindowType.changeImage`) instead, and rename the file to match, rather than deleting the coverage.
- Tests that call `copyScrap`, `cutScrap`, `duplicateScrap` or `removeScrap` directly move to the new names or keep using the wrappers: `t2400`, `t3203`, `t3204`, `t3206`, `t3208`, `t3210` on 2026-09-28. No test calls `setSelectedScrapByMPID`. Re-check with `grep -rlE 'setSelectedScrapByMPID|copyScrap|cutScrap|duplicateScrap|removeScrap\(' test`.
- `t2461` (`MPReversedListIndexHelper`) is unchanged.

### Acceptance

- The canvas action column no longer has the scrap button, and no code path opens `MPWindowType.availableScraps`.
- Every feature in the §2 table can be reached from the sidebar for every open `.th2` tab, in or outside the project.
- `flutter analyze` is clean and `flutter test` is green.

## 13. Expected files

| Area | Files |
|---|---|
| Controllers | `th2_file_edit_copy_paste_controller.dart` (list helpers), `th2_file_edit_element_edit_controller.dart` (`removeScraps`), `th2_file_edit_option_edit_controller.dart` (option target reset, `updateOptionStateMap` while the scrap options window is shown), `th2_file_edit_user_interaction_controller.dart` (option target helper), `th2_file_edit_overlay_window_controller.dart` (removed window type and flag, `performShowScrapOptionsOverlayWindow`), `th2_file_edit_selection_controller.dart` (remove `setSelectedScrapByMPID`), `th2_file_edit_controller.dart` (`showRemoveButton`, `showSnapButton`), `th2_file_hide_element_controller.dart` (`setScrapsHidden`), `mp_general_controller.dart` (`_syncProjectTreeSelectionToActiveTab` for standalone rows), `th_project_tree_ui_controller.dart` (expansion of standalone rows) |
| Types | `lib/src/controllers/types/mp_window_type.dart`, `lib/src/controllers/types/mp_global_key_widget_type.dart` |
| Widgets | `th_project_tree_widget.dart` (standalone section), `th_project_tree_node_widget.dart` (file-row menu), `th2_element_tree_row_widget.dart` (scrap menu items, eye toggle, hidden style, options anchor), `th2_file_edit_action_buttons_widget.dart` (button removed), `factories/mp_overlay_window_factory.dart`, removed `mp_available_scraps_widget.dart` |
| Constants | `mp_constants.dart` (`mpTreeCanvasOverlayMaxWaitFrames`) |
| l10n | `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb`, generated files from `flutter gen-l10n` |
| Help | `assets/help/{en,pt}/th2_file_edit_page_help.md`, removed `assets/help/images/buttonScraps.png` |
| Changelog | `CHANGELOG.md` |
| Tests | new `test/t3953_th2_element_tree_scrap_actions_test.dart`; `test/t3741_ui_change_scrap_overlay_hides_top_right_buttons_test.dart` rewritten for the image dialog and renamed; tests using the renamed helpers |

## 14. Risks

1. **Users of the dialog lose a familiar place.** Everything moves to the sidebar, which can be collapsed. The CHANGELOG and the help page say where each feature went. `Alt+K` still cycles through scraps without the sidebar.
2. **Reversed order.** Users of the dialog are used to seeing the top scrap first. The tree shows file order, with its header tooltip; the help page calls this out.
3. **Phase 4 names may change during implementation.** This plan uses the Phase 4 plan's names (`prepareTH2FileForTreeEdit`, `selectedScrapMPIDs`, the mode-exit helper). Re-check them before starting.
