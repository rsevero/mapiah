<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Project Parsing Phase 4: Project Tree Side Column UI — Implementation Plan

**Date:** 2026-08-24
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 4** of the [Therion Project Parsing, Tree View & Text Editing Roadmap](file:///devel/mapiah/docs/plans/2026-08-24-therion-project-parsing-and-tree-view.md). It builds on the outputs of:

- **Phase 1** — Grammars, parsers, and lossless writers for `thconfig` and `.th` files.
- **Phase 2** — The recursive project tree loader (`THProjectParser`), the `THProjectNode` model family.
- **Phase 3** — `THProjectController` (`mpLocator.thProjectController`), a MobX store owning the loaded project tree, dependency indexes, dirty-file tracking, and debounced re-parsing. It exposes `projectRootNode`, `projectErrors`, `isParsing`, `activeSelectedNodeId`, `dirtyFilePaths`, `selectNode(nodeId)`, `nodeByCanonicalPath`, `dependenciesOf`/`dependentsOf`, and `isFileDirty`.

Phase 4 adds the first purely visual layer on top of that store: a collapsible, resizable **project tree side column** (`THProjectTreeWidget`) rendered next to the existing tab workspace in `th2_file_tabs_page.dart`. This phase is read-only with respect to project content — clicking a node only updates `activeSelectedNodeId` and (where a corresponding tab already exists) focuses it. Opening new tabs from tree clicks, text editing, and cross-navigation are explicit non-goals deferred to Phase 5/6.

### Key Objectives
1. **`THProjectTreeWidget`**: A MobX-observing tree view rendering `projectRootNode` — file nodes and logical nodes (`THSurveyNode`, `THCentrelineNode`, `THMapNode`, `THScrapNode`) — with per-node expand/collapse, icons, dirty badges, and error badges.
2. **Client-side expansion state**: Since `THProjectNode` carries no expand/collapse flag and `THProjectController` currently has no such state either (confirmed absent in Phase 3's implementation), Phase 4 introduces a small `THProjectTreeUIController` (or equivalent widget-local store — see §3) holding `expandedNodeIds` and `selectedNodeId` mirroring, so tree rebuilds triggered by re-parses do not collapse unrelated branches.
3. **Search/filter**: A text field that filters visible nodes by label substring, auto-expanding ancestors of matches.
4. **Resizable, collapsible split layout**: Insert the sidebar into the existing `Scaffold` body in `th2_file_tabs_page.dart` (currently a plain tab strip + canvas, no side column today) as a `Row` with a draggable divider, collapsible to a thin rail.
5. **Persisted layout preferences**: Sidebar width and collapsed state persisted via `MPSettingsController`/`SharedPreferencesWithCache`, following the existing `MPSettingID` enum pattern.
6. **No project mutation**: This phase never calls `openProject`, `reparseFile`, or any writer. It only reads `THProjectController` observables and calls `selectNode`.

---

## 2. Grounding: Current State (Pre-Phase 4)

Verified directly against the codebase (not just prior planning docs):

- `lib/src/pages/th2_file_tabs_page.dart` is a plain `Scaffold` with `MPResponsiveAppBar` + `TH2FileEditBodyWidget` (tab strip via `mp_file_tab_widget.dart`). **No `Drawer`, split view, or side column exists.** Phase 4 is greenfield for layout.
- `lib/src/widgets/` has **no existing tree/collapsible-list widget** to extend. The closest stylistic precedent is `mp_available_scraps_widget.dart` (simple selectable list rendered inside `MPOverlayWindowWidget`) for row styling conventions only — it has no expand/collapse behavior to reuse.
- `THProjectNode` (`lib/src/elements/th_project/th_project_node.dart`): `id`, `label`, `sourceFilePath`, `lineNumber`, `children`, `parent`, `parseErrors`, computed `hasErrors`. **No `isExpanded` field** (unlike the aspirational sketch in the top-level roadmap doc §3.1 — that sketch was never implemented as written).
- `THProjectFileNode` adds `absolutePath`, `relativePathToProjectRoot`, `encoding`, `isLoaded`. **No `isDirty` field on nodes** — dirty state lives only in `THProjectController.dirtyFilePaths`, keyed by canonical path (`node.absolutePath` for file nodes).
- Logical nodes: `THSurveyNode` (`survey`, `fullNamespace`), `THCentrelineNode` (`centreline`), `THMapNode` (`map`), `THScrapNode` (`scrapId`, `isFromTH2File`). **No projection-type field** anywhere in the hierarchy, so the roadmap's "Scrap (Plan) vs Scrap (Extended/Elevation)" icon distinction (§6.2 of the top-level plan) is not achievable from the node alone in Phase 4; it is deferred (see §8 Non-Goals) until a projection field is added to `THScrapNode` or looked up from the underlying `THScrap` element.
- `mpLocator.thProjectController` accessor confirmed present (`lib/src/auxiliary/mp_locator.dart`).
- `mp_constants.dart` naming convention: `mp<Context><Thing>`, e.g. `mpTabLabelMaxWidth`, `mpSmallIconSize`, `mpProjectReparseDebounceMilliseconds`.
- `MPSettingsController` persists settings via `SharedPreferencesWithCache` keyed by `MPSettingID` enum (`lib/src/controllers/types/mp_setting_type.dart`), grouped by prefix (e.g. `Main_LocaleID`, `Main_TelemetryConsent`), with typed getter/setter families (`setDouble`/`getDoubleWithDefault`, `setBool`/`getBoolWithDefault`, ...). No panel/sidebar-width settings exist yet.
- Localization file is `lib/l10n/intl_en.arb` / `intl_pt.arb` (not `app_en.arb` as loosely stated in the top-level roadmap) — each key has a matching `"@key"` metadata block with `description` and `type`.
- Test numbering for `th_project`-scoped tests currently runs `t3840`–`t3873`. Phase 4 widget tests continue at `t3880`+.

---

## 3. File Organization & Architecture

```
lib/src/
 ├── controllers/
 │    ├── th_project_tree_ui_controller.dart      # New: MobX store for expansion/filter/selection UI state
 │    ├── th_project_tree_ui_controller.g.dart    # Generated by build_runner (not hand-edited)
 │    └── mp_settings_controller.dart              # Existing: gains sidebar width/collapsed persistence
 ├── auxiliary/
 │    └── mp_locator.dart                          # Existing: gains a THProjectTreeUIController accessor
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
| `expandedNodeIds` | `ObservableSet<String>` | Node ids currently expanded. Defaults to expanded-by-default for file nodes reachable within 2 levels of the root (see §5.3); everything else starts collapsed. |
| `filterText` | `String` | Current search box contents, empty = no filtering. |
| `isSidebarCollapsed` | `bool` | Whether the sidebar is reduced to a thin rail. Initialized from `MPSettingID.ProjectTree_SidebarCollapsed`. |
| `sidebarWidth` | `double` | Current sidebar width in logical pixels, clamped to `[mpProjectTreeSidebarMinWidth, mpProjectTreeSidebarMaxWidth]`. Initialized from `MPSettingID.ProjectTree_SidebarWidth`. |

`sidebarWidth`/`isSidebarCollapsed` writes are debounced-persisted (simple `Timer`, 250ms, reusing the pattern already used for reparse debouncing) to `MPSettingsController` to avoid a `SharedPreferences` write per drag-frame.

### 4.2 Node Identity Across Re-parses

Phase 3 documents that a survey namespace change produces a **new** node id (id encodes namespace). `THProjectTreeUIController.expandedNodeIds` and `activeSelectedNodeId` (owned by `THProjectController`) can therefore silently desync from the live tree after a re-parse elsewhere in the app (Phase 5 territory, but the UI must already be robust to it in Phase 4 since `THProjectController.reparseFile`/`reloadProject` are already callable today via tests/future callers). Rendering must treat `expandedNodeIds`/`activeSelectedNodeId` values that no longer exist in the tree as simply "not expanded"/"not selected" — no error, no crash. This is a pure lookup-miss, not a special-cased reconciliation pass.

---

## 5. `THProjectTreeWidget` Rendering

### 5.1 Composition

```
THProjectTreeWidget (StatelessWidget, Observer)
 ├── search box (TextField, debounced onChanged -> setFilterText)
 ├── [empty state] when projectRootNode == null (no project open)
 ├── [loading state] Observer on isParsing -> LinearProgressIndicator strip
 ├── [error summary] Observer on projectErrors -> collapsible banner with count, following existing error-badge visual language (see MPFileTabWidget's dirty-indicator pattern for badge placement precedent)
 └── ListView.builder over a flattened, filtered node list
      └── THProjectTreeNodeWidget per visible row (indentation = depth * mpProjectTreeIndent)
```

A `ListView.builder` over a **flattened** list (depth-first walk honoring `expandedNodeIds`, computed each `build` via `Observer`) is used instead of nested collapsible widgets, so very large projects scroll efficiently without building offscreen subtrees. The flattening function is a pure top-level helper (`_flattenVisibleNodes`) in `th_project_tree_widget.dart`, unit-testable independent of widget rendering.

### 5.2 `THProjectTreeNodeWidget`

Single row: `[indent] [expand/collapse chevron or spacer] [icon] [label] [dirty dot] [error badge]`.

- Expand/collapse chevron only rendered when `node.children.isNotEmpty`; tapping toggles `THProjectTreeUIController.toggleExpanded(node.id)`.
- Tapping the row body (not the chevron) calls `mpLocator.thProjectController.selectNode(node.id)`. Phase 4 does **not** open tabs or scroll editors on click — that is Phase 6's cross-navigation work. The row visually highlights when `node.id == activeSelectedNodeId` (`Observer` on that field) so selection is visible even though it has no other effect yet.
- Dirty dot: rendered when `node is THProjectFileNode && mpLocator.thProjectController.isFileDirty(node.absolutePath)`.
- Error badge: rendered when `node.hasErrors`, shown as a small colored dot using `colorScheme.error`, with `node.parseErrors.length` in a tooltip. Parent nodes do **not** aggregate descendant error counts in Phase 4 (that requires a recursive `hasErrors` walk on every build); this is listed as a possible Phase 4 follow-up, not a blocker (see §8).

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

On first render after a project loads (`projectRootNode` becomes non-null and `expandedNodeIds` is empty), the root node and its direct file children are auto-expanded once via a `reaction` in `THProjectTreeUIController` (or an `initState`-time check in the widget) so the user is not greeted with a fully collapsed single root row. Depth-2+ nodes start collapsed. This mirrors common IDE project-tree defaults and avoids hand-authoring a full default-expansion policy per node type.

### 5.5 Search/Filter

- `matchesFilter(node)` does case-insensitive substring match against `node.label`.
- A node is **visible** under an active filter if it matches, or any descendant matches (ancestors of matches are always shown and auto-expanded regardless of `expandedNodeIds`, without mutating `expandedNodeIds` itself — filter-driven visibility is computed independently so clearing the filter restores the prior manual expansion state).
- Empty `filterText` disables filtering entirely (fast path, no matching walk).

---

## 6. Layout Integration (`th2_file_tabs_page.dart`)

### 6.1 Split Layout

The existing `Scaffold.body` (currently `TH2FileEditBodyWidget` directly) becomes:

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
    Expanded(child: TH2FileEditBodyWidget(...)),
  ],
),
```

wrapped in an `Observer` so collapse toggling rebuilds the row. When `projectRootNode == null` (no project open — i.e. a lone `.th2` file opened outside any project, which remains fully supported), the sidebar renders its empty state rather than being omitted, so users always have a discoverable "Open Project" affordance (Phase 4 renders the affordance; wiring it to an actual `openProject` file-picker flow is explicitly a Phase 4 UI task since `THProjectController.openProject` already exists — see §7 Step 6).

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
const int mpProjectTreeUIPersistDebounceMilliseconds = 250;
```

### 6.4 New `MPSettingID` Entries (`mp_setting_type.dart`)

```dart
ProjectTree_SidebarWidth,   // MPSettingType.double
ProjectTree_SidebarCollapsed, // MPSettingType.bool
```

Following the existing `Category_Name` convention (`Main_LocaleID`, `Main_TelemetryConsent`) with a new `ProjectTree_` category prefix, registered in the same type map used by those two existing entries.

---

## 7. Step-by-Step Implementation Sequence

```
Step 1: Add THProjectTreeUIController store shell + MPLocator accessor
   │
   ▼
Step 2: Add mp_constants.dart sizing constants + ProjectTree_* MPSettingID entries
   │
   ▼
Step 3: Implement expandedNodeIds/filterText/selection logic + _flattenVisibleNodes helper
   │
   ▼
Step 4: Build THProjectTreeNodeIconWidget (pure type -> icon mapping, easiest to unit test first)
   │
   ▼
Step 5: Build THProjectTreeNodeWidget (row rendering, click/selection, dirty/error badges)
   │
   ▼
Step 6: Build THProjectTreeWidget (search box, empty/loading/error states, ListView.builder)
   │
   ▼
Step 7: Build THProjectTreeResizeDividerWidget + wire sidebar width/collapse persistence
   │
   ▼
Step 8: Integrate Row layout into th2_file_tabs_page.dart
   │
   ▼
Step 9: Add localized strings (intl_en.arb / intl_pt.arb) for search hint, empty state, collapse tooltip
   │
   ▼
Step 10: Widget/unit tests
   │
   ▼
Step 11: flutter analyze / dart run build_runner build / flutter test
```

---

## 8. Explicit Non-Goals for Phase 4

- **No tab-opening on click.** Clicking a `.th2`/`.th`/`thconfig` node only calls `selectNode`; opening or focusing the corresponding tab is Phase 6 (Deep Integration & Tab Management), since it requires coordinating with `MPGeneralController`'s tab lifecycle, which Phase 4 does not touch.
- **No scroll-to-line navigation** for survey/centreline/map/scrap child nodes — requires the Phase 5 text editor to exist first.
- **No text editing, syntax highlighting, or line-number gutter** — Phase 5.
- **No context menu** (*Open in Text Editor*, *Show in File Manager*, *Save File*, *Re-parse File*, *Run Therion*, *Copy Full Survey Namespace*) — most actions require Phase 5/6/7 infrastructure that doesn't exist yet; adding a menu with mostly-disabled items would be dead UI.
- **No projection-specific scrap icons** (Plan vs Extended vs Elevation) — blocked on `THScrapNode` (or the underlying `THScrap`) exposing a projection field, which is not part of the Phase 1-3 model. Filed as a follow-up, not silently dropped.
- **No aggregated/rolled-up error counts on ancestor nodes** — a per-build recursive descendant walk is a real cost on large trees; deferred until profiling shows it's needed or until Phase 3-side eager error aggregation is added to the model itself.
- **No file-picker-driven "Open Project" flow beyond the sidebar's empty-state button** wiring straight to `THProjectController.openProject` with a native file picker — if a suitable file-picker package/pattern doesn't already exist elsewhere in the app, that integration (not the picker UI itself) may be scoped out and tracked as a small follow-up; existing `flutter run` manual testing must confirm which is the case before Step 8 is called done.
- **No drag-and-drop reordering, multi-select, or keyboard navigation (arrow keys) in the tree** — single-select, mouse/touch only, matching the simplicity of Phase 4's scope.
- **No therion compiler diagnostics wiring** — Phase 7.

---

## 9. Test Plan

Test numbering continues the `th_project` block at `t3880`+:

| Test file | Coverage |
| :--- | :--- |
| `test/t3880_th_project_tree_ui_controller_test.dart` | Expand/collapse/toggle, filter text, sidebar width clamping, collapsed toggle, settings persistence round-trip via a fake `MPSettingsController`/`SharedPreferences`. |
| `test/t3881_th_project_tree_flatten_test.dart` | Pure `_flattenVisibleNodes` helper: depth-first order, expansion honored, filter-driven visibility/auto-expand-of-ancestors without mutating `expandedNodeIds`, stale node id lookups after a simulated re-parse. |
| `test/t3882_th_project_tree_node_icon_widget_test.dart` | Icon selection per node runtime type, including `THMissingFileNode` error styling. |
| `test/t3883_th_project_tree_widget_test.dart` | Widget test: empty state (no project), loading state (`isParsing`), rendering a fixture tree, expand/collapse tap, selection highlight on tap, dirty dot rendering via a stub `THProjectController` state, search box filtering rows. |
| `test/t3884_th_project_tree_resize_divider_widget_test.dart` | Drag updates `sidebarWidth` within clamped bounds; double-click/tap toggles `isSidebarCollapsed`. |

Fixture trees reuse `test/auxiliary/th_project/` fixtures already established in Phase 2/3 rather than inventing a new fixture set. Widget tests follow the existing `t3xxx_ui_*` precedent (`testWidgets`, `mpLocator` reset in `setUp`, faked `PathProviderPlatform`, `AppLocalizationsEn()`).

Representative scenarios:

1. **Toggle expand/collapse**: tapping a chevron flips only that node's entry in `expandedNodeIds`, leaving siblings untouched.
2. **Selection highlight**: tapping a row calls `selectNode` exactly once and does not call `openProject`/`reparseFile`/any writer.
3. **Filter narrows tree**: typing a substring hides non-matching leaf rows while keeping matching leaves' ancestor chain visible and auto-expanded.
4. **Clearing filter restores prior expansion**: filter-driven auto-expansion doesn't leak into `expandedNodeIds` once `filterText` is cleared.
5. **Stale ids after re-parse are inert**: an `expandedNodeIds`/`activeSelectedNodeId` value with no matching node in the current tree renders as unexpanded/unselected, no exception.
6. **Dirty dot reflects controller state**: a node whose `absolutePath` is in `THProjectController.dirtyFilePaths` shows the dirty indicator; removing it from the set (simulating a save) removes the dot on next build.
7. **Sidebar width persistence**: dragging the divider updates `sidebarWidth`, and after the debounce window the value is written through `MPSettingsController`; a fresh `THProjectTreeUIController` initializes from the persisted value.
8. **Collapsed sidebar hides tree but keeps a reopen affordance** (e.g. a slim rail button), and toggling restores the previous width rather than resetting to the default.
9. **No project open**: sidebar shows the empty state without throwing when `projectRootNode == null`.

---

## 10. Localization & Documentation Touches

- New `intl_en.arb`/`intl_pt.arb` keys (with matching `"@key"` metadata blocks per existing convention): search box hint text, empty-state message/button label, sidebar collapse/expand tooltip, error-summary banner text (with a `{count}` placeholder).
- No all-caps UI text; no magic numbers (all sizes come from `mp_constants.dart` per §6.3).
- Help pages and keyboard-shortcut tables are **not** updated in Phase 4 — the top-level roadmap assigns that consolidation to Phase 8, once the sidebar's interactions are finalized across Phases 4-7 and don't need to be documented twice.

---

## 11. Risks & Open Questions

1. **Large-project scroll performance**: `ListView.builder` over a flattened list avoids building offscreen widgets, but the flatten walk itself still runs on every `filterText`/`expandedNodeIds` change. For very large projects this may need memoization keyed on `(projectRootNode identity, expandedNodeIds, filterText)`; not built preemptively in Phase 4 but called out so Step 10 test fixtures include a moderately large synthetic tree (~200 nodes) to catch obviously quadratic behavior early.
2. **File-picker dependency**: confirm during Step 6 whether an existing package (e.g. already used for `.th2` "Open File") can be reused for picking a `thconfig`/root file, or whether this needs a small separate follow-up outside Phase 4's scope.
3. **Row highlight vs. Flutter's built-in selection affordances**: decide during Step 5 whether selection highlight uses a plain `Container` color or `Material`/`InkWell` splash, to stay consistent with the rest of the app's list-row conventions (see `mp_available_scraps_widget.dart` for precedent).
