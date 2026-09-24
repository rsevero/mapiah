<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 7: Remove the Scrap Button and Dialog

**Date:** 2026-09-24  
**Status:** Proposed. Outcome A of parent plan Phase 7 (remove completely) was chosen on 2026-09-24. Checked against the code on `main` at `606d728d`, while Phase 4 was being implemented in the working tree. This plan builds on the [Phase 4 plan](2026-09-23-th2-element-tree-and-drawing-order-phase4-drag-drop-and-menu.md), not on the unfinished Phase 4 code. Re-check every Phase 4 name used here once Phase 4 is merged.  
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
- the same files after the project is closed or replaced: `closeProjectFileTabs` leaves tabs outside the project open.

Once the dialog is gone, these tabs would have no way to change their active scrap except `Alt+K` and `Alt+click`, and no way to reorder, hide, copy, delete or edit scraps. So the sidebar gets a new section for them.

### 3.1 "Open files outside the project" section

- Below the project rows, the tree shows a header row, "Open files outside the project", followed by one `.th2` file row for every open `.th2` tab whose canonical path has no project node (`THProjectController.nodeByCanonicalPath(path) == null`). The rows follow `MPGeneralController`'s open-tab order. The section is hidden when there are no such tabs.
- When no project is loaded, the section is shown under the empty-state actions (Open project, and so on) instead of replacing them.
- Each file row is a synthetic `TH2FileNode` built from the tab's path, with the file name as label. It uses the same row widget, chevron, badge and element rows as project `.th2` rows, so every Phase 3–7 feature (selection, drag, menus, shortcuts) works the same way.
- **No tab-less state:** these files always have an open tab and a loaded controller, so there is no background load. `isTH2FileRowLoadEligible` and `loadTH2FileIfEligible` are never called for them. They also call `nodeByCanonicalPath(...)!` and would throw on these paths. When the tab closes, the row disappears. Expansion state is kept in `THProjectTreeUIController` under the synthetic node id, `standalone:<canonicalPath>`, so it cannot collide with project node ids. It is dropped when the tab closes.
- **Filtering:** the section's element rows are filtered like project rows. The header row stays visible while any of its file rows matches.
- **Tab switching:** activating such a tab selects its file row, as project tabs already do.
- **Where it is built:** `THProjectTreeWidget._buildVisibleRows` appends the section after `flattenVisibleNodes`, reusing the same `th2ElementRowsFor` callback. The flattener itself does not change. The tree observer reads `MPGeneralController`'s open-tab list and controller-registry revision, so the section follows tab opens, closes and Save As renames.

## 4. Scrap-row context menu

Phase 4 gives scrap rows the four order items. This phase extends the menu:

| Row | Items |
|---|---|
| scrap | Bring forward, Send backward, Bring to front, Send to back, divider, Copy, Cut, Duplicate, Delete, divider, Hide / Show, Options… |

- **Menu target:** as in Phase 4 plan §6.2. On a selected scrap row, the menu acts on every selected scrap. On an unselected scrap row, it acts on that scrap only and does not change the scrap selection.
- **Before every item** that changes the file: call `prepareTH2FileForTreeEdit(th2FilePath)`, as Phase 4 does, and do nothing when it returns `null`. This opens and activates the tab of a tab-less file, so the edit can be seen and undone.
- **Copy, Cut, Duplicate:** new list versions of the existing helpers, `copyScraps(List<int>)`, `cutScraps(List<int>)` and `duplicateScraps(List<int>)`, in `TH2FileEditCopyPasteController`. They pass all target scraps to `setSelectedElements` and then call the existing `copySelectedElements`, `cutSelectedElements` and `duplicateSelectedElements`, which already accept several top-level elements. The single-scrap methods become one-line wrappers, or are removed if nothing else calls them. Cut and Duplicate each make one undo step. After Duplicate, the first new scrap becomes active, as today.
  - **Check:** these helpers end with `clearSelectedElements()`. Following Phase 4 plan §3.6, they must leave `selectedScrapMPIDs` alone. Verify that `clearSelectedElements()` does, or restore the scrap selection after it. They also clear any point, line or area selection, as the dialog does today; that is acceptable, because the menu is opened on a scrap row.
- **Delete:** `elementEditController.removeScraps(List<int>)`. It builds one `MPRemoveScrapCommand` per scrap (`MPCommandFactory.removeScrapFromExisting`), wraps them in one `MPMultipleElementsCommand` when there are several, and moves the active scrap away first with `setActiveScrapForScrapRemoval`, as `removeScrap` does. It is one undo step. Removed MPIDs leave the scrap selection through Phase 4's stale-id pruning. The label is "Delete" (existing key `th2FileEditPageRemoveScrapButton` reads "Remove scrap"; see §10.1). Deleting the last scrap stays allowed, as in the dialog.
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

- `TH2FileEditOptionEditController` gets an explicit option target. While the scrap options window is shown, `optionsScrapMPID` names the scrap being edited. It is reset to `-1` when that window closes, in `setShowOverlayWindow(MPWindowType.scrapOptions, false)`.
- `TH2FileEditUserInteractionController._prepareSetOption` and `_prepareUnsetOption` use `[th2File.scrapByMPID(optionsScrapMPID)]` as their candidate elements when `optionsScrapMPID >= 0`, instead of the selection. The line-segment branch is unchanged.
- The options state map is already built from the scrap (`updateElementOptionMapByMPID`), so the window's contents do not change.
- `TH2FileEditSelectionController.setSelectedScrapByMPID` is removed. It has no other caller.
- Phase 4's clean-up of stray `MPSelectedScrap` entries stays as a safety net. The copy, cut and duplicate helpers still put scraps into the selection for a moment.

### 7.2 Opening the window

The window is a canvas overlay, so it needs the file's tab to be open and laid out.

1. `prepareTH2FileForTreeEdit(th2FilePath)`; stop if it returns `null`.
2. If the canvas of that tab is not laid out yet (`getTH2FileWidgetGlobalKey().currentContext == null`, which is the case right after a tab-less file's tab is opened), wait with `addPostFrameCallback` and check again, for at most `mpTreeCanvasOverlayMaxWaitFrames` frames (new constant, 3). If the canvas is still not there, do nothing.
3. Compute the anchor in canvas-local coordinates: the menu target row's centre, from its `RenderBox.localToGlobal`, then converted with the canvas `RenderBox.globalToLocal`. The anchor x is `0` (the canvas's left edge, next to the sidebar); y is the row's centre clamped to the canvas height. If the row is no longer mounted, use the vertical centre of the canvas. Do not use `MPInteractionAux.getWidgetRectFromContext` with the canvas key as ancestor, because the row is not a descendant of the canvas.
4. Call `perfomToggleScrapOptionsOverlayWindow(scrapMPID:, outerAnchorPosition:, innerAnchorType: MPWidgetPositionType.centerLeft)`. The method gets an `innerAnchorType` parameter, which today is hard-coded to `centerRight`, and the dialog was its only caller. The window then opens to the right of the sidebar, level with the row.

## 8. What is removed

- `TH2FileEditActionButtonsWidget._changeScrapButton` and its call in `build`.
- `MPAvailableScrapsWidget` (`lib/src/widgets/mp_available_scraps_widget.dart`).
- `MPWindowType.availableScraps`, its case in `MPOverlayWindowFactory`, and its entries in `autoDismissOverlayWindowTypes` and `_getMutuallyExclusiveOverlayWindowTypes` (the `changeImage` case then returns an empty set).
- `MPGlobalKeyWidgetType.changeScrapButton` and its global key.
- `_isChangeScrapWindowShown` / `showChangeScrapOverlayWindow` in `TH2FileEditOverlayWindowController`, and their use in `showRemoveButton` and `showSnapButton` in `th2_file_edit_controller.dart`. Both then check only the image dialog.
- `TH2FileEditSelectionController.setSelectedScrapByMPID` (§7.1).
- `.arb` keys used only by the dialog: `th2FileEditPageChangeActiveScrapTool` and `th2FileEditPageChangeActiveScrapTitle` (EN/PT), then `flutter gen-l10n`.

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
  - remove the "Scraps" action-button entry (line 119 in EN), which also mentions an `Alt+C` shortcut and a right-click on the button that do not exist in the code;
  - rewrite the "Scraps" section and its subsections (Scrap copy, cut, duplicate, visibility, reordering) around the project sidebar: the scrap-row menu, the eye toggle, the file-row menu, and the "Open files outside the project" section. Mention that the sidebar lists scraps in file order, top row drawn first, while the old dialog listed them the other way round;
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
  - the menu item with several targets never hides the last visible scrap;
  - the file-row item switches between "Hide all but active" and "Show all scraps".
- **Options…:**
  - opens the scrap options window on the canvas, anchored at the canvas's left edge level with the row, also for a tab-less file whose tab is opened by the action;
  - setting and unsetting an option changes the scrap, not a selected point, line or area;
  - no `MPSelectedScrap` is added to `mpSelectedElementsLogical`;
  - closing the window resets `optionsScrapMPID`;
  - the item is disabled with several target scraps.
- **Add scrap** from the file-row menu opens the add-scrap dialog on the file's canvas.
- **Open files outside the project:**
  - a `.th2` tab outside the project (opened as the startup code does, and after a TH2 Save As to a path outside the project) shows under the section header, with and without a loaded project;
  - its element rows support selection, the order menu and the new scrap actions;
  - closing the tab removes the row, and a file that becomes part of the project after a project reload moves out of the section;
  - no background load is ever scheduled for its rows.

### Updated or removed

- `test/t3741_ui_change_scrap_overlay_hides_top_right_buttons_test.dart`: it tests that the scrap dialog hides the top-right buttons. Remove the scrap-dialog cases and keep the image-dialog cases, or remove the file if only scrap cases remain.
- Tests that call `setSelectedScrapByMPID`, `copyScrap`, `cutScrap` or `duplicateScrap` directly are moved to the new names. Find them with `grep -rlE 'setSelectedScrapByMPID|copyScrap|cutScrap|duplicateScrap|removeScrap\(' test`.
- `t2461` (`MPReversedListIndexHelper`) is unchanged.

### Acceptance

- The canvas action column no longer has the scrap button, and no code path opens `MPWindowType.availableScraps`.
- Every feature in the §2 table can be reached from the sidebar for every open `.th2` tab, in or outside the project.
- `flutter analyze` is clean and `flutter test` is green.

## 13. Expected files

| Area | Files |
|---|---|
| Controllers | `th2_file_edit_copy_paste_controller.dart` (list helpers), `th2_file_edit_element_edit_controller.dart` (`removeScraps`), `th2_file_edit_option_edit_controller.dart` (option target reset), `th2_file_edit_user_interaction_controller.dart` (option candidates), `th2_file_edit_overlay_window_controller.dart` (removed window type and flag, `innerAnchorType` parameter), `th2_file_edit_selection_controller.dart` (remove `setSelectedScrapByMPID`), `th2_file_edit_controller.dart` (`showRemoveButton`, `showSnapButton`), `th_project_tree_ui_controller.dart` (expansion of standalone rows) |
| Types | `lib/src/controllers/types/mp_window_type.dart`, `lib/src/controllers/types/mp_global_key_widget_type.dart` |
| Widgets | `th_project_tree_widget.dart` (standalone section), `th_project_tree_node_widget.dart` (file-row menu), `th2_element_tree_row_widget.dart` (scrap menu items, eye toggle, hidden style, options anchor), `th2_file_edit_action_buttons_widget.dart` (button removed), `factories/mp_overlay_window_factory.dart`, removed `mp_available_scraps_widget.dart` |
| Constants | `mp_constants.dart` (`mpTreeCanvasOverlayMaxWaitFrames`) |
| l10n | `lib/l10n/intl_en.arb`, `lib/l10n/intl_pt.arb`, generated files from `flutter gen-l10n` |
| Help | `assets/help/{en,pt}/th2_file_edit_page_help.md` |
| Changelog | `CHANGELOG.md` |
| Tests | new `test/t3953_th2_element_tree_scrap_actions_test.dart`; updated `test/t3741_ui_change_scrap_overlay_hides_top_right_buttons_test.dart` and tests using the renamed helpers |

## 14. Risks

1. **Users of the dialog lose a familiar place.** Everything moves to the sidebar, which can be collapsed. The CHANGELOG and the help page say where each feature went. `Alt+K` still cycles through scraps without the sidebar.
2. **Reversed order.** Users of the dialog are used to seeing the top scrap first. The tree shows file order, with its header tooltip; the help page calls this out.
3. **Phase 4 names may change during implementation.** This plan uses the Phase 4 plan's names (`prepareTH2FileForTreeEdit`, `selectedScrapMPIDs`, the mode-exit helper). Re-check them before starting.
