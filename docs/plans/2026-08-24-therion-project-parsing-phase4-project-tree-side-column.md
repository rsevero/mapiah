<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 4: Project Tree Side Column UI — Implementation Plan

**Date:** 2026-08-24
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 4** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](2026-08-24-therion-project-parsing-and-tree-view.md). It builds on the outputs of:

- **Phase 1** — Grammars, parsers, and lossless writers for `thconfig` and `.th` files.
- **Phase 2** — The recursive project tree loader (`THProjectParser`), the `THProjectNode` model family.
- **Phase 3** — `THProjectController` (`mpLocator.thProjectController`), a MobX store owning the loaded project tree, dependency indexes, dirty-file tracking, and debounced re-parsing. It exposes `projectRootNode`, `projectErrors`, `isParsing`, `activeSelectedNodeId`, `dirtyFilePaths`, `selectNode(nodeId)`, `nodeByCanonicalPath`, `dependenciesOf`/`dependentsOf`, and `isFileDirty`.

Phase 4 adds the first visual layer on top of that store: a collapsible, resizable **project tree side column** (`THProjectTreeWidget`) rendered next to the existing tab workspace in `th2_file_tabs_page.dart`. Clicking a node only calls `selectNode`; opening or focusing tabs, text editing, and cross-navigation are explicit non-goals deferred to Phase 5/6. The one project-state mutation in Phase 4 is the sidebar's empty-state **Open Project** button, which always opens a `thconfig` file through a native file picker by calling `THProjectController.openProject(..., forceConfigShape: true)`.

### Key Objectives
1. **`THProjectTreeWidget`**: A MobX-observing tree view rendering `projectRootNode` — file nodes and logical nodes (`THSurveyNode`, `THCentrelineNode`, `THMapNode`, `THScrapNode`) — with per-node expand/collapse, icons, dirty badges, and error badges.
2. **Client-side expansion state**: Since `THProjectNode` carries no expand/collapse flag and `THProjectController` currently has no such state either (confirmed absent in Phase 3's implementation), Phase 4 introduces a small `THProjectTreeUIController` (or equivalent widget-local store — see §3) holding `expandedNodeIds` and `selectedNodeId` mirroring, so tree rebuilds triggered by re-parses do not collapse unrelated branches.
3. **Search/filter**: A text field that filters visible nodes by label substring, auto-expanding ancestors of matches.
4. **Resizable, collapsible split layout**: Insert the sidebar into the existing `Scaffold` body in `th2_file_tabs_page.dart` (currently a plain tab strip + canvas, no side column today) as a `Row` with a draggable divider, collapsible to a thin rail.
5. **Persisted layout preferences**: Sidebar width and collapsed state persisted via `MPSettingsController`/`SharedPreferencesWithCache`, following the existing `MPSettingID` enum pattern.
6. **Open Project in scope**: The sidebar's empty state provides an Open Project button wired to `THProjectController.openProject(..., forceConfigShape: true)` via the existing `file_picker` package. The selected file is always a `thconfig` file; no root-shape detection is attempted, regardless of its extension or whether it has one. Apart from that explicit entry point, Phase 4 performs no project-content mutation — it never calls `reparseFile` or any writer, and tree-node clicks only call `selectNode`.
7. **App-bar Open Project button**: The initial-window (`MapiahHome`) app bar's existing Open `.th2` action (expanded action, overflow menu item, and `Ctrl/Cmd+O` / `Ctrl/Cmd+Shift+O` shortcuts) is replaced by Open Project, using `MPDialogAux.pickProjectFile`. The New `.th2` and Open THConfig + Run Therion app-bar actions remain unchanged in this phase; the file-editor app bar is also left unchanged. Selecting a project from the initial window navigates to `TH2FileTabsPage` even when no `.th2` tab is open, so the loaded project tree is immediately visible.

---

## 2. Grounding: Current State (Pre-Phase 4)

Verified directly against the codebase (not just prior planning docs):

- `lib/src/pages/th2_file_tabs_page.dart` is a plain `Scaffold` whose `MPResponsiveAppBar.bottom` hosts the draggable tab strip (built via `mp_file_tab_widget.dart`) and whose `body` is an `Observer` returning a centered empty-state `Text` when no tabs are open, otherwise a `PopScope` wrapping an `IndexedStack` of `TH2FileEditBodyWidget` canvases. **No `Drawer`, split view, or side column exists.** Phase 4 is greenfield for layout.
- `lib/src/widgets/` has **no existing tree/collapsible-list widget** to extend. The closest stylistic precedent is `mp_available_scraps_widget.dart` (simple selectable list rendered inside `MPOverlayWindowWidget`) for row styling conventions only — it has no expand/collapse behavior to reuse.
- `THProjectNode` (`lib/src/elements/th_project/th_project_node.dart`): `id`, `label`, `sourceFilePath`, `lineNumber`, `children`, `parent`, `parseErrors`, computed `hasErrors`. **No `isExpanded` field** (unlike the aspirational sketch in the top-level roadmap doc §3.1 — that sketch was never implemented as written).
- `THProjectFileNode` adds `absolutePath`, `relativePathToProjectRoot`, `encoding`, `isLoaded`. **No `isDirty` field on nodes** — dirty state lives only in `THProjectController.dirtyFilePaths`, keyed by canonical path (`node.absolutePath` for file nodes).
- Logical nodes: `THSurveyNode` (`survey`, `fullNamespace`), `THCentrelineNode` (`centreline`), `THMapNode` (`map`), `THScrapNode` (`scrapId`, `isFromTH2File`). **No projection-type field** anywhere in the hierarchy, so the roadmap's "Scrap (Plan) vs Scrap (Extended/Elevation)" icon distinction (§6.2 of the top-level plan) is not achievable from the node alone in Phase 4; it is deferred (see §8 Non-Goals) until a projection field is added to `THScrapNode` or looked up from the underlying `THScrap` element.
- Logical node ids use `type:canonicalPath:lineNumber`; namespace is available separately as `THSurveyNode.fullNamespace` and is **not** part of the id.
- No reusable dirty/error badge widget exists. `MPFileTabWidget` exposes info and close icons, and the page app bar uses `TH2FileEditController.enableSaveButton` to enable/disable the Save action, but there is no existing dot/badge convention. Phase 4 introduces its own small status-dot convention.
- `mpLocator.thProjectController` accessor confirmed present (`lib/src/auxiliary/mp_locator.dart`).
- `mp_constants.dart` naming convention: `mp<Context><Thing>`, e.g. `mpTabLabelMaxWidth`, `mpSmallIconSize`, `mpProjectReparseDebounceMilliseconds`.
- `MPSettingsController` persists settings via `SharedPreferencesWithCache` keyed by `MPSettingID` enum (`lib/src/controllers/types/mp_setting_type.dart`), grouped by prefix (e.g. `Main_LocaleID`, `Main_TelemetryConsent`), with typed getter/setter families (`setDouble`/`getDoubleWithDefault`, `setBool`/`getBoolWithDefault`, ...). No panel/sidebar-width settings exist yet.
- Localization files are `lib/l10n/intl_en.arb` (the template) and `intl_pt.arb` (translations). `intl_en.arb` carries `"@key"` metadata blocks with `description`, `type`, and placeholders for most keys; `intl_pt.arb` does not repeat that metadata except where ARB requires it for that key (for example plural/select placeholders).
- Test numbering for `th_project`-scoped tests currently runs `t3840`–`t3873`. Phase 4 widget tests continue at `t3880`+.

---

## 3. File Organization & Architecture

```
lib/src/
 ├── controllers/
 │    ├── th_project_tree_ui_controller.dart      # New: MobX store for expansion/filter/selection UI state
 │    ├── th_project_tree_ui_controller.g.dart    # Generated by build_runner (not hand-edited)
 │    └── mp_settings_controller.dart              # Existing: gains sidebar width/collapsed persistence and the ProjectTree_SidebarWidth double default
 ├── auxiliary/
 │    ├── mp_locator.dart                          # Existing: gains a THProjectTreeUIController accessor
 │    └── th_project_tree_flatten_aux.dart          # New: pure visible-node flattening helper
 ├── constants/
 │    └── mp_constants.dart                        # Existing: adds sidebar sizing/row constants
 ├── controllers/types/
 │    └── mp_setting_type.dart                     # Existing: adds ProjectTree_* MPSettingID entries
 ├── elements/th_project/                          # Existing Phase 2 models — read-only in Phase 4
 ├── widgets/
 │    ├── th_project_tree_widget.dart               # New: root sidebar widget (search box + scrollable tree)
 │    ├── th_project_tree_node_widget.dart           # New: single recursive row widget
 │    ├── th_project_tree_node_icon_widget.dart       # New: icon selection per node type/state
 │    └── th_project_tree_resize_divider_widget.dart # New: draggable splitter between sidebar and workspace
 └── pages/
      └── th2_file_tabs_page.dart                  # Existing: body becomes Row(sidebar, divider, tab workspace)
```

`THProjectTreeUIController` is kept separate from `THProjectController` (Phase 3) deliberately: it holds *view* state (which nodes are expanded, current filter text) that has no meaning outside the UI and must never be touched by the parsing/re-parsing pipeline, mirroring the existing separation between `THProjectController` (data) and `MPGeneralController` (tab/UI bookkeeping).

---

## 4. `THProjectTreeUIController` Public Surface

```dart
class THProjectTreeUIController = THProjectTreeUIControllerBase
    with _$THProjectTreeUIController;

abstract class THProjectTreeUIControllerBase with Store {
  @observable
  ObservableSet<String> expandedNodeIds = ObservableSet<String>();

  @observable
  String filterText = '';

  @observable
  bool isSidebarCollapsed = false;

  @observable
  double sidebarWidth = mpProjectTreeSidebarDefaultWidth;

  @action
  void toggleExpanded(String nodeId);

  @action
  void expand(String nodeId);

  @action
  void collapse(String nodeId);

  @action
  void expandAncestorsOf(THProjectNode node);

  @action
  void setFilterText(String text);

  @action
  void setSidebarCollapsed(bool collapsed);

  @action
  void setSidebarWidth(double width);

  bool isExpanded(String nodeId);

  bool matchesFilter(THProjectNode node);
}
```

### 4.1 State Fields

| Field | Type | Purpose |
| :--- | :--- | :--- |
| `expandedNodeIds` | `ObservableSet<String>` | Node ids currently expanded. Starts empty. The controller populates it with the default expansion whenever `THProjectController.projectRootNode` becomes non-null and the set is empty (i.e. once per project load), and clears it when the root becomes `null`; after that it is purely user-driven. |
| `filterText` | `String` | Current search box contents, empty = no filtering. |
| `isSidebarCollapsed` | `bool` | Whether the sidebar is reduced to a thin rail. Initialized from `MPSettingID.ProjectTree_SidebarCollapsed`. |
| `sidebarWidth` | `double` | Current sidebar width in logical pixels, clamped to `[mpProjectTreeSidebarMinWidth, mpProjectTreeSidebarMaxWidth]`. Initialized from `MPSettingID.ProjectTree_SidebarWidth`. |

`sidebarWidth`/`isSidebarCollapsed` writes are debounced-persisted (simple `Timer`, 250ms, reusing the pattern already used for reparse debouncing) to `MPSettingsController` to avoid a `SharedPreferences` write per drag-frame.

### 4.1.1 Default Expansion Initialization

The controller owns the one-time default-expansion reaction, so `THProjectTreeWidget` can stay a `StatelessWidget`:

```dart
late final ReactionDisposer _projectRootReaction;

THProjectTreeUIControllerBase() {
  _projectRootReaction = reaction<THProjectFileNode?>(
    (_) => mpLocator.thProjectController.projectRootNode,
    _handleProjectRootChanged,
  );
  _handleProjectRootChanged(mpLocator.thProjectController.projectRootNode);
}

@action
void _handleProjectRootChanged(THProjectFileNode? root) {
  if (root == null) {
    expandedNodeIds.clear();
    return;
  }

  if (expandedNodeIds.isEmpty) {
    final int? firstTH2Depth = _firstTH2FileDepth(root, 0);
    final int expansionDepth =
        firstTH2Depth ?? _maximumDepth(root, 0) + 1;

    _expandNodesAboveDepth(root, 0, expansionDepth);
  }
}
```

The snippet above shows only the `projectRootNode` reaction. The `sidebarWidth` and `isSidebarCollapsed` field initializers that read `MPSettingID.ProjectTree_SidebarWidth` and `MPSettingID.ProjectTree_SidebarCollapsed` (see §4.1) happen in the same constructor but are elided here for brevity.

The reaction clears `expandedNodeIds` when a project closes and reapplies defaults only when the expansion set is empty on the next project load. Reparses and reloads of the same project do not reapply defaults. Default expansion walks depth-first to find the shallowest `.th2` file; it then expands every branch down to that `.th2` depth. If the project contains no `.th2` file, the whole tree is expanded.

### 4.2 Node Identity Across Re-parses

In the current implementation, logical-node ids are synthetic `type:canonicalPath:lineNumber` values (`survey:<canonicalPath>:<lineNumber>`, `centreline:...`, `map:...`, `scrap:...`). They do **not** encode the survey namespace. Renaming a survey on the same line keeps the same id, while moving or reordering lines can produce a new id even when the namespace is unchanged. `THProjectTreeUIController.expandedNodeIds` and `activeSelectedNodeId` (owned by `THProjectController`) can therefore still become stale after `reparseFile`/`reloadProject` when line numbers or included paths change. Rendering must treat `expandedNodeIds`/`activeSelectedNodeId` values that no longer exist in the tree as simply "not expanded"/"not selected" — no error, no crash. This is a pure lookup-miss, not a special-cased reconciliation pass.

---

## 5. `THProjectTreeWidget` Rendering

### 5.1 Composition

```
THProjectTreeWidget (StatelessWidget, Observer)
 ├── header row with collapse button (calls setSidebarCollapsed(true))
 ├── search box (_THProjectTreeSearchField, a private stateful widget that owns a TextEditingController and Timer; onChanged cancels/restarts the timer and calls setFilterText after mpProjectTreeFilterDebounceMilliseconds)
 ├── [empty state] when projectRootNode == null (no project open)
 ├── [loading state] Observer on isParsing -> LinearProgressIndicator strip
 ├── [error summary] Observer on projectErrors -> collapsible banner using colorScheme.errorContainer/onErrorContainer and a count; it follows the new status-dot convention defined in §5.2, not MPFileTabWidget
 └── ListView.builder over a flattened, filtered node list
      └── THProjectTreeNodeWidget per visible row (indentation = depth * mpProjectTreeIndent)
```

A `ListView.builder` over a **flattened** list (depth-first walk honoring `expandedNodeIds`, computed each `build` via `Observer`) is used instead of nested collapsible widgets, so very large projects scroll efficiently without building offscreen subtrees. The flattening logic is a pure public helper, `flattenVisibleNodes`, in `th_project_tree_flatten_aux.dart`. It returns `THProjectTreeVisibleNode` entries (`node` plus `depth`) so the widget renders indentation and the helper remains independently unit-testable.

The text field updates immediately for the user, but `THProjectTreeUIController.filterText` is only updated after the debounce window. This keeps large-tree flattening from running on every keystroke while preserving responsive input. The debounce belongs to the search-field widget, not the controller, so the controller remains a plain MobX store with no timer for filtering.

### 5.2 `THProjectTreeNodeWidget`

Single row: `[indent] [expand/collapse chevron or spacer] [icon] [label] [dirty dot] [error badge]`.

- Expand/collapse chevron only rendered when `node.children.isNotEmpty`; tapping toggles `THProjectTreeUIController.toggleExpanded(node.id)`.
- Tapping the row body (not the chevron) calls `mpLocator.thProjectController.selectNode(node.id)`. Phase 4 does **not** open tabs or scroll editors on click — that is Phase 6's cross-navigation work. The row visually highlights when `node.id == activeSelectedNodeId` (`Observer` on that field) so selection is visible even though it has no other effect yet.
- Dirty dot: 8×8 circular dot in `colorScheme.tertiary`, rendered only for `THProjectFileNode` when `mpLocator.thProjectController.isFileDirty(node.absolutePath)` is true.
- Error badge: 8×8 circular dot in `colorScheme.error`, rendered when `node.hasErrors`, with `node.parseErrors.length` in a tooltip. Both dots use the new `mpProjectTreeStatusDotSize` constant. Parent nodes do **not** aggregate descendant error counts in Phase 4 (that requires a recursive `hasErrors` walk on every build); this is listed as a possible Phase 4 follow-up, not a blocker (see §8).

### 5.3 Icon Selection (`THProjectTreeNodeIconWidget`)

Based on runtime type only (no projection field available — see §2):

| Node type | Icon |
| :--- | :--- |
| `THConfigFileNode` | `Icons.settings_suggest_outlined` |
| `THDataFileNode` | `Icons.description_outlined` |
| `TH2FileNode` | `Icons.draw_outlined` |
| `THMissingFileNode` | `Icons.error_outline` (theme error color, regardless of `hasErrors`) |
| `THSurveyNode` | `Icons.account_balance_outlined` |
| `THCentrelineNode` | `Icons.timeline_outlined` |
| `THMapNode` | `Icons.layers_outlined` |
| `THScrapNode` | `Icons.map_outlined` (single icon for all scraps in Phase 4; projection-specific icon deferred, see §8) |

Icon constants (sizes) come from existing `mpSmallIconSize` in `mp_constants.dart`; no new icon-size constant is introduced unless the row height forces a different size.

### 5.4 Default Expansion

The controller registers a MobX reaction on `THProjectController.projectRootNode`. When the root becomes `null`, `expandedNodeIds` is cleared. When a root becomes non-null and `expandedNodeIds` is still empty, the controller finds the shallowest `.th2` file and expands every branch down to that depth, so at least one `.th2` file is visible while sibling branches are opened to the same level. If the project has no `.th2` file, the whole tree is expanded. Reparses and reloads do not reapply defaults unless the expansion set was cleared by a project switch. `THProjectTreeWidget` remains a `StatelessWidget` and only observes `expandedNodeIds`.

### 5.5 Search/Filter

- `matchesFilter(node)` does case-insensitive substring match against `node.label`.
- A node is **visible** under an active filter if it matches, or any descendant matches (ancestors of matches are always shown and auto-expanded regardless of `expandedNodeIds`, without mutating `expandedNodeIds` itself — filter-driven visibility is computed independently so clearing the filter restores the prior manual expansion state).
- Empty `filterText` disables filtering entirely (fast path, no matching walk).

---

## 6. Layout Integration (`th2_file_tabs_page.dart`)

### 6.1 Split Layout

The existing `Scaffold.body` (currently an `Observer` returning a centered empty-state `Text` when no tabs are open, otherwise a `PopScope` wrapping an `IndexedStack` of `TH2FileEditBodyWidget` canvases) becomes:

```dart
body: Row(
  children: [
    if (!projectTreeUIController.isSidebarCollapsed)
      SizedBox(
        width: projectTreeUIController.sidebarWidth,
        child: const THProjectTreeWidget(),
      ),
    if (!projectTreeUIController.isSidebarCollapsed)
      const THProjectTreeResizeDividerWidget(),
    if (projectTreeUIController.isSidebarCollapsed)
      SizedBox(
        width: mpProjectTreeRailWidth,
        child: IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: appLocalizations.projectTreeExpandSidebarTooltip,
          onPressed: () =>
              projectTreeUIController.setSidebarCollapsed(false),
        ),
      ),
    Expanded(child: TH2FileEditBodyWidget(...)),
  ],
),
```

wrapped in an `Observer` so collapse toggling rebuilds the row. The collapsed branch is a thin rail containing a reopen button; it does not render `THProjectTreeWidget` or the resize divider. When `projectRootNode == null` (no project open — i.e. a lone `.th2` file opened outside any project, which remains fully supported) and the sidebar is expanded, `THProjectTreeWidget` renders its empty state with an Open Project button.

Phase 4 adds `MPDialogAux.pickProjectFile(context)`, which reuses the existing `file_picker` dependency and the existing `pickTHConfigFile`/`pickTH2File` patterns: show a native picker, update `lastAccessedDirectory`, then call `THProjectController.openProject` with the selected path and `forceConfigShape: true`. The selected file is always a `thconfig` file; there is no ambiguity and no root-shape detection, even when it has an arbitrary extension or no extension at all. No new picker dependency or ad-hoc file-choosing code is introduced.

The initial-window app bar's Open `.th2` button and its compact-menu/quick-shortcut equivalents are replaced by this Open Project action. This is intentionally scoped to `mapiah_home.dart`; the file-editor Open `.th2` button and the New `.th2` / Open THConfig + Run Therion actions are not changed in Phase 4.

### 6.2 Resize Divider

`THProjectTreeResizeDividerWidget`: a narrow `MouseRegion`/`GestureDetector` column (`SystemMouseCursors.resizeColumn`) that on `onHorizontalDragUpdate` calls `setSidebarWidth(currentWidth + delta.dx)`, clamped. A double-click/tap on the divider toggles `isSidebarCollapsed` (common IDE affordance), in addition to an explicit collapse button in the sidebar header.

### 6.3 New Constants (`mp_constants.dart`)

```dart
const double mpProjectTreeSidebarDefaultWidth = 280.0;
const double mpProjectTreeSidebarMinWidth = 180.0;
const double mpProjectTreeSidebarMaxWidth = 560.0;
const double mpProjectTreeResizeDividerWidth = 6.0;
const double mpProjectTreeRowHeight = 28.0;
const double mpProjectTreeIndent = 16.0;
const double mpProjectTreeStatusDotSize = 8.0;
const double mpProjectTreeRailWidth = 32.0;
const int mpProjectTreeFilterDebounceMilliseconds = 150;
const int mpProjectTreeUIPersistDebounceMilliseconds = 250;
```

### 6.4 New `MPSettingID` Entries (`mp_setting_type.dart`)

```dart
ProjectTree_SidebarWidth,   // MPSettingType.double
ProjectTree_SidebarCollapsed, // MPSettingType.bool
```

Following the existing `Category_Name` convention (`Main_LocaleID`, `Main_TelemetryConsent`) with a new `ProjectTree_` category prefix, registered in the same type map used by those two existing entries.

In `mp_settings_controller.dart`, add `MPSettingID.ProjectTree_SidebarWidth: mpProjectTreeSidebarDefaultWidth` to `_doubleDefaultSettings`. `ProjectTree_SidebarCollapsed` needs no entry because its default falls through to `mpDefaultDefaultBoolSetting` (`false`).

---

## 7. Step-by-Step Implementation Sequence

```
Step 1: Add THProjectTreeUIController store shell + MPLocator accessor
   │
   ▼
Step 2: Add mp_constants.dart sizing constants + ProjectTree_* MPSettingID entries + ProjectTree_SidebarWidth double default
   │
   ▼
Step 3: Implement expandedNodeIds/filterText/selection logic + flattenVisibleNodes helper
   │
   ▼
Step 4: Build THProjectTreeNodeIconWidget (pure type -> icon mapping, easiest to unit test first)
   │
   ▼
Step 5: Build THProjectTreeNodeWidget (row rendering, click/selection, dirty/error badges)
   │
   ▼
Step 6: Build THProjectTreeWidget (search box, empty/loading/error states, Open Project button, ListView.builder) + MPDialogAux.pickProjectFile openProject flow
   │
   ▼
Step 7: Build THProjectTreeResizeDividerWidget + collapsed thin rail + wire sidebar width/collapse persistence
   │
   ▼
Step 8: Integrate Row layout into th2_file_tabs_page.dart
   │
   ▼
Step 9: Add localized strings (intl_en.arb / intl_pt.arb) for search hint, empty state/Open Project, collapse/expand tooltip, error summary
   │
   ▼
Step 10: Widget/unit tests
   │
   ▼
Step 11: flutter analyze / flutter test
```

Process exceptions for this phase: help pages and keyboard-shortcut documentation are deferred to Phase 8, and tests are intentionally written at Step 10 after the widget APIs exist. Both are approved exceptions to the default "update help pages for new features" and "tests first" rules; the tests-first deviation is explicitly approved by Rodrigo Severo. The existing MobX watch generates `.g.dart` files; do not manually run `build_runner build`.

---

## 8. Explicit Non-Goals for Phase 4

- **No tab-opening on click.** Clicking a `.th2`/`.th`/`thconfig` node only calls `selectNode`; opening or focusing the corresponding tab is Phase 6 (Deep Integration & Tab Management), since it requires coordinating with `MPGeneralController`'s tab lifecycle, which Phase 4 does not touch.
- **No scroll-to-line navigation** for survey/centreline/map/scrap child nodes — requires the Phase 5 text editor to exist first.
- **No text editing, syntax highlighting, or line-number gutter** — Phase 5.
- **No context menu** (*Open in Text Editor*, *Show in File Manager*, *Save File*, *Re-parse File*, *Run Therion*, *Copy Full Survey Namespace*) — most actions require Phase 5/6/7 infrastructure that doesn't exist yet; adding a menu with mostly-disabled items would be dead UI.
- **No projection-specific scrap icons** (Plan vs Extended vs Elevation) — blocked on `THScrapNode` (or the underlying `THScrap`) exposing a projection field, which is not part of the Phase 1-3 model. Filed as a follow-up, not silently dropped.
- **No aggregated/rolled-up error counts on ancestor nodes** — a per-build recursive descendant walk is a real cost on large trees; deferred until profiling shows it's needed or until Phase 3-side eager error aggregation is added to the model itself.
- **No drag-and-drop reordering, multi-select, or keyboard navigation (arrow keys) in the tree** — single-select, mouse/touch only, matching the simplicity of Phase 4's scope.
- **No therion compiler diagnostics wiring** — Phase 7.

---

## 9. Test Plan

Test numbering continues the `th_project` block at `t3880`+:

| Test file | Coverage |
| :--- | :--- |
| `test/t3880_th_project_tree_ui_controller_test.dart` | Expand/collapse/toggle, filter text, sidebar width clamping, collapsed toggle, settings persistence round-trip via a fake `MPSettingsController`/`SharedPreferences`. |
| `test/t3881_th_project_tree_flatten_test.dart` | Pure `flattenVisibleNodes` helper (imported from `th_project_tree_flatten_aux.dart`): depth-first order, expansion honored, filter-driven visibility/auto-expand-of-ancestors without mutating `expandedNodeIds`, stale node id lookups after a simulated re-parse. |
| `test/t3882_th_project_tree_node_icon_widget_test.dart` | Icon selection per node runtime type, including `THMissingFileNode` error styling. |
| `test/t3883_th_project_tree_widget_test.dart` | Widget test: empty state (no project), loading state (`isParsing`), rendering a fixture tree, expand/collapse tap, selection highlight on tap, dirty dot rendering via a stub `THProjectController` state, search box filtering rows. |
| `test/t3884_th_project_tree_resize_divider_widget_test.dart` | Drag updates `sidebarWidth` within clamped bounds; double-click/tap toggles `isSidebarCollapsed`. |

Fixture trees reuse `test/auxiliary/th_project/` fixtures already established in Phase 2/3 rather than inventing a new fixture set. Widget tests follow the existing `t3xxx_ui_*` precedent (`testWidgets`, `mpLocator` reset in `setUp`, faked `PathProviderPlatform`, `AppLocalizationsEn()`).

Representative scenarios:

1. **Toggle expand/collapse**: tapping a chevron flips only that node's entry in `expandedNodeIds`, leaving siblings untouched.
2. **Selection highlight**: tapping a row calls `selectNode` exactly once and does not call `openProject`/`reparseFile`/any writer.
3. **Filter narrows tree**: typing a substring hides non-matching leaf rows while keeping matching leaves' ancestor chain visible and auto-expanded.
4. **Filter input is debounced**: typing into the search box updates the displayed text immediately, but `filterText` and therefore the visible tree change only after `mpProjectTreeFilterDebounceMilliseconds` elapse; rapid consecutive edits collapse to one update.
5. **Clearing filter restores prior expansion**: filter-driven auto-expansion doesn't leak into `expandedNodeIds` once `filterText` is cleared.
6. **Stale ids after re-parse are inert**: an `expandedNodeIds`/`activeSelectedNodeId` value with no matching node in the current tree renders as unexpanded/unselected, no exception.
7. **Dirty dot reflects controller state**: a node whose `absolutePath` is in `THProjectController.dirtyFilePaths` shows the dirty indicator; removing it from the set (simulating a save) removes the dot on next build.
8. **Sidebar width persistence**: dragging the divider updates `sidebarWidth`, and after the debounce window the value is written through `MPSettingsController`; a fresh `THProjectTreeUIController` initializes from the persisted value.
9. **Collapsed sidebar hides tree but keeps a reopen affordance** (e.g. a slim rail button), and toggling restores the previous width rather than resetting to the default.
10. **No project open**: sidebar shows the empty state without throwing when `projectRootNode == null`.

---

## 10. Localization & Documentation Touches

- New `intl_en.arb` keys with full `"@key"` metadata blocks (`description`, `type`, and any placeholders). New `intl_pt.arb` translations are added only for the localized values; add `"@key"` metadata there only when ARB requires it for that key, matching the current translation-file convention.
- New localized values: search box hint text, empty-state message/Open Project button label, sidebar collapse/expand tooltip, error-summary banner text (with a `{count}` placeholder).
- No all-caps UI text; no magic numbers (all sizes come from `mp_constants.dart` per §6.3).
- Help pages and keyboard-shortcut tables are **not** updated in Phase 4 — the top-level roadmap assigns that consolidation to Phase 8, once the sidebar's interactions are finalized across Phases 4-7 and don't need to be documented twice.

---

## 11. Risks & Open Questions

1. **Large-project scroll performance**: `ListView.builder` over a flattened list avoids building offscreen widgets, but the flatten walk itself still runs on every `filterText`/`expandedNodeIds` change. For very large projects this may need memoization keyed on `(projectRootNode identity, expandedNodeIds, filterText)`; not built preemptively in Phase 4 but called out so Step 10 test fixtures include a moderately large synthetic tree (~200 nodes) to catch obviously quadratic behavior early.
2. **Row highlight vs. Flutter's built-in selection affordances**: decide during Step 5 whether selection highlight uses a plain `Container` color or `Material`/`InkWell` splash, to stay consistent with the rest of the app's list-row conventions (see `mp_available_scraps_widget.dart` for precedent).
