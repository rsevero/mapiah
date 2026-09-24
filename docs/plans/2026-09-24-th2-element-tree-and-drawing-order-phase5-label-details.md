<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# TH2 Element Tree and Drawing Order — Phase 5: Station Names and Label/Remark Text in Element Labels

**Date:** 2026-09-24  
**Status:** Implemented on 2026-09-24. The label tooltip uses `TooltipTriggerMode.manual`, because the §8 "hold, then drag" test failed with the default trigger. Two Phase 3 tests were updated, contrary to §8 Acceptance: `t3942` expected station names to stay out of labels, and `t3944` used a station-name edit as its example of an option that does not bump the revision. Checked against the code at `65e8d164` on 2026-09-24.  
**Parent plan:** [TH2 Element Tree in the Project Sidebar](2026-09-23-th2-element-tree-and-drawing-order.md) (§4.1 labels, §7 Phase 5)  
**Prerequisite:** Phases 1–4 are in place: the read-only sidebar tree with its label cache ([Phase 3 plan](2026-09-23-th2-element-tree-and-drawing-order-phase3-sidebar-read-only.md) §6.2, §7) and drag and drop with row feedback ([Phase 4 plan](2026-09-23-th2-element-tree-and-drawing-order-phase4-drag-drop-and-menu.md)).  
**Issue:** [#32: Provide move object up/down drawing stack and awareness of relative stack order between objects](https://github.com/rsevero/mapiah/issues/32)

## 1. Purpose

Phase 3 labels rows as `<kind> <type[:subtype]> <thID?>`. A long list of `point station` rows, or of `point label` rows, tells the surveyor nothing about which station or which label a row is. This phase adds one extra **detail** part to three point types, so they can be recognized in the tree without selecting them:

| Point type | Detail source | Example row |
|---|---|---|
| `station` | the `-name` option (`THCommandOptionType.station`, `THStationNameCommandOption.name`) | `point station` *`1.3@main`* `s12` |
| `label` | the `-text` option (`THCommandOptionType.text`, `THTextCommandOption.text.content`) | `point label` *`Main entrance`* |
| `remark` | the `-text` option | `point remark` *`Unsurveyed lead`* |

In the examples, italics show the detail span and the trailing part is the muted Therion id.

## 2. Scope

### In scope

- A `detail` part in `TH2ElementTreeLabel`, computed by `TH2ElementTreeAux.buildLabel` for `station`, `label` and `remark` points (§4.1, §4.2).
- Rendering the detail as an italic span between the type and the id, and a tooltip with the full text of multi-line labels and remarks (§4.3).
- Filtering by the detail (§4.4).
- Refreshing labels when `-name` or `-text` is set, changed or removed, including undo and redo (§4.5).
- EN/PT help update of the existing "Labels" bullet, and a CHANGELOG entry (§5).
- Tests in `test/t3951_th2_element_tree_label_details_test.dart` (§8).

### Out of scope

- The `-text` of `continuation` points and of `label` **lines**.
- Other option values: `-value`, `-altitude`, dates, dimensions, `-scale`, `-align` and so on.
- Resolving station names (survey namespaces, `name@survey`), or checking that a station exists.
- Interpreting Therion text tags other than `<br>`.
- Details on scrap, line or area rows.
- New translatable strings. The detail is user data.

## 3. Current state

- **Label model.** `TH2ElementTreeLabel` (`lib/src/auxiliary/th_project_tree_visible_row.dart:32-55`) has `primaryText` (localized kind and type[:subtype]) and `thID`. Its `plainText` getter joins them with a space, leaving empty parts out.
- **Label builder.** `TH2ElementTreeAux.buildLabel(THElement)` (`lib/src/auxiliary/th2_element_tree_aux.dart:406-`) builds labels for scraps, points, lines and areas from `MPTextToUser` and `MPCommandOptionAux.getID`. It reads only the element. `labelFor(...)` (`:367`) caches labels per controller, keyed by `structureRevision` and locale.
- **Users of the label.**
  - `TH2ElementTreeRowWidget._buildLabel` (`lib/src/widgets/th2_element_tree_row_widget.dart:310-332`) renders a `Text.rich` with two spans: `primaryText`, then the id in `colorScheme.onSurfaceVariant`. It uses one line with an ellipsis, and `plainText` as `semanticsLabel`. The label has **no tooltip** today; the only tooltip in the row is the selection dot of collapsed scraps (`:347`).
  - The drag feedback shows `row.label.plainText` (`:202`).
  - `moveRejectionMessage` uses `buildLabel(...).plainText` of lines and areas (`th2_element_tree_aux.dart:97-`). Lines and areas get no detail, so these messages do not change.
  - The filter matches `row.label.plainText` (`th2_element_tree_aux.dart:289`).
- **Text source for labels and remarks.** `MPLabelTextAux.resolve(point)` (`lib/src/auxiliary/mp_label_text_aux.dart`) returns an `MPLabelData` whose `lines` are the `-text` content split on `<br>` and trimmed. Every other tag stays literal. The canvas uses the same rule. The grammar strips the surrounding quotes or brackets (`quotedString` and `bracketStringGeneral` with `.pick(1)`, `th2_grammar.dart:64-93`), and `_parseTHString` (`th2_file_parser.dart:2652`) turns each doubled quote into one, so `content` is the text the user typed.
- **Revision bumps.** `executeSetOptionToElement` and `executeRemoveOptionFromElement` bump `structureRevision` only when `_isTreeLabelOption(optionType)` is true (`th2_file_edit_element_edit_controller.dart:799-802`, used at `:834` and `:877`). Today it returns true for `id` and `subtype`. Type-edit commands already bump the revision (Phase 2), so a point that changes to or from `station`, `label` or `remark` already gets a new label.
- **Help.** `assets/help/en/th2_file_edit_page_help.md:93` and `assets/help/pt/th2_file_edit_page_help.md:93` already describe row labels ("**Labels**" / "**Rótulos**"), written in Phase 3.

## 4. Design

### 4.1 Label model

Add two fields to `TH2ElementTreeLabel`:

```dart
/// User data that identifies the element: a station's `-name`, or the
/// `-text` of a label or remark point on one line. `null` when there is none.
final String? detail;

/// The full `-text` of a label or remark point, one `<br>` line per line,
/// for the row tooltip. `null` when the row needs no tooltip.
final String? tooltipText;
```

Both are optional constructor parameters, so existing callers and tests keep compiling.

`plainText` becomes `<primaryText> <detail> <thID>`, with empty or `null` parts left out, joined with single spaces. It stays the one string used for filtering, semantics and drag feedback.

### 4.2 Computing the detail

In `TH2ElementTreeAux.buildLabel`, the `THPoint` case adds `detail` and `tooltipText` from a new private helper, `_pointDetail(THPoint point)`, which returns `({String? detail, String? tooltipText})`:

- **`station`:** if the point has `THCommandOptionType.station`, the detail is `(option as THStationNameCommandOption).name`, trimmed. The name is shown verbatim (for example `1.3@main` or `47@39.2002-08`). No tooltip.
- **`label` and `remark`:** `MPLabelTextAux.resolve(point)` gives the trimmed `<br>` lines. Empty lines are dropped. The detail is the remaining lines joined with a single space. When more than one non-empty line remains, `tooltipText` is those lines joined with `\n`; with only one line the row text already shows it all, so there is no tooltip. Other tags (`<center>`, `<size:N>`, font switches, `<rtl>`, `<lang:XX>`, `<thsp>`) stay literal, as on the canvas.
- **Everything else:** no detail and no tooltip. This includes `continuation` points with `-text` (`resolve` already returns `null` for them), `station` points without `-name`, and a `-name` on a point of another type (the parser accepts `-name`/`-station` on any element, `th2_file_parser.dart:1563-1565`).
- An empty result after trimming counts as no detail.

`MPLabelTextAux.resolve` also handles altitude, date, dimensions, height and passage-height points. `_pointDetail` only calls it for `label` and `remark`, so those types keep their Phase 3 labels.

`buildLabel` still reads only the element and never changes it.

### 4.3 Rendering

In `TH2ElementTreeRowWidget._buildLabel`:

- The `Text.rich` gets a third span between the primary text and the id: `' $detail'` in `FontStyle.italic` with the row's normal text color. The id span keeps its leading space and muted color. Spacing follows the rule `_buildLabel` already uses for the id, so the label never starts with a space.
- The active-scrap bold style and `maxLines: 1` with `TextOverflow.ellipsis` stay as they are. A long detail pushes the id out of view; that is accepted, because the id is still part of `plainText`, which search and semantics use, and the detail is what identifies these points.
- When `label.tooltipText` is not `null`, the `Text.rich` is wrapped in a `Tooltip(message: tooltipText, excludeFromSemantics: true)`. Only the label is wrapped, not the whole row, so the row's gesture detectors, drag source and drop target are unchanged. `excludeFromSemantics` keeps the row's semantics label equal to `plainText`. The tooltip uses Flutter's default wait, like the tree's other tooltips (the scrap selection dot and the header order tooltip), so no new constant is needed.
- With the default `triggerMode` (long press), `Tooltip` adds a long-press recognizer to the gesture arena over almost the whole row, so a press held still for about 500 ms before dragging could win over the row's `Draggable`. The "hold, then drag" test in §8 checks this. If it fails, set `triggerMode: TooltipTriggerMode.manual`, which drops the tooltip's gesture recognizers, and check that hover still shows the tooltip.
- The drag feedback keeps using `plainText`, which now includes the detail.

### 4.4 Filtering

No code change: `_elementRows` already matches `row.label.plainText` (§3), which now includes the detail. Searching for a station name or for a word from a label or remark finds the point and shows its scrap and file ancestors, following the Phase 3 filter rules. As before, only loaded, valid files are searched.

### 4.5 Keeping labels current

Extend `_isTreeLabelOption` in `th2_file_edit_element_edit_controller.dart` to also return true for `THCommandOptionType.station` and `THCommandOptionType.text`. Update its doc comment ("Options shown in the sidebar tree's element labels (id, subtype, station name and text).").

The check stays independent of the element type: a `-text` edit on a line or a continuation point also bumps the revision. That only rebuilds the tree's label cache once, and such edits are rare, so checking the element type is not worth the code.

This covers:

- edits from the options overlay, which go through `MPSetOptionToElementCommand` and `MPRemoveOptionFromElementCommand`;
- the same commands wrapped in `MPMultipleElementsCommand` (multi-selection edits);
- undo and redo, which call the same `execute*` methods.

The Phase 3 label cache, keyed by `structureRevision`, then rebuilds the labels.

`executeSetOptionToElement` already calls `_syncTherionStationCacheOrMarkDirty` for station names; that call is unchanged, and its position relative to the new bump does not matter.

## 5. Help and changelog

This phase updates the existing "**Labels**" bullet itself instead of waiting for Phase 6, because Phase 3 already wrote the section and leaving it out of date between phases would be wrong. Phase 6 then only checks it.

- `assets/help/en/th2_file_edit_page_help.md:93`: "each row shows the element kind, its type (and subtype, if any), then, in italics, a station's name or the text of a label or remark point, and then its Therion id, if it has one, exactly as written in the file. Hover over a multi-line label or remark to see all its lines. Search also finds station names and label or remark text."
- `assets/help/pt/th2_file_edit_page_help.md:93`: the same content in Portuguese ("o nome da estação ou o texto de um ponto `label` ou `remark`, em itálico").
- The PT search bullet (`:101`) and its EN counterpart mention that search matches labels; they need no change, since the detail is part of the label.

CHANGELOG, in the current unreleased section, next to the Phase 3 and 4 entries:

> Project-tree element rows now show a station's `-name`, and the `-text` of label and remark points, in italics between the type and the Therion id (#32, Phase 5). Multi-line texts show all their lines in a tooltip. Search matches these values, and rows update when they are edited, undone or redone. Added tests (`test/t3951`).

No `.arb` changes, so no `flutter gen-l10n`.

## 6. Implementation order

1. `TH2ElementTreeLabel`: add `detail` and `tooltipText`, update `plainText`.
2. `TH2ElementTreeAux`: add `_pointDetail`, use it in `buildLabel`.
3. Label-builder tests from §8 (pure part), and run `t3942` to check that existing labels are unchanged.
4. `TH2ElementTreeRowWidget._buildLabel`: detail span and tooltip.
5. `_isTreeLabelOption`: add `station` and `text`.
6. Widget and command tests from §8.
7. Help pages (EN/PT) and CHANGELOG.
8. `flutter analyze` and `flutter test`.

## 7. Expected files

| Area | Files |
|---|---|
| Aux | `lib/src/auxiliary/th_project_tree_visible_row.dart` (label fields), `lib/src/auxiliary/th2_element_tree_aux.dart` (`_pointDetail`, `buildLabel`); `mp_label_text_aux.dart` reused as is |
| Widgets | `lib/src/widgets/th2_element_tree_row_widget.dart` (detail span, tooltip) |
| Controllers | `lib/src/controllers/th2_file_edit_element_edit_controller.dart` (`_isTreeLabelOption`) |
| Help | `assets/help/en/th2_file_edit_page_help.md`, `assets/help/pt/th2_file_edit_page_help.md` |
| Changelog | `CHANGELOG.md` |
| Tests | new `test/t3951_th2_element_tree_label_details_test.dart` |

No MobX annotations change, so no generated files change.

## 8. Tests

New file `test/t3951_th2_element_tree_label_details_test.dart`. Fixtures are small `.th2` strings loaded through a `TH2FileEditController`, as in `t3942` and `t3943`.

### Label builder (pure)

- A station with `-name 1.3@main` has detail `1.3@main`, shown verbatim with its `@` and dots. A station without `-name` has no detail.
- A `station:temporary` point keeps its subtype in `primaryText` and gets the detail after it.
- Label and remark points with `-text` have the text as detail. `-text "a<br>b"` gives detail `a b` and tooltip `a\nb`. `-text "a<br><br>b"` gives `a b` with no double space. A one-line text has no tooltip.
- Other tags stay literal: `-text "<center>Main<br>entrance"` gives detail `<center>Main entrance`.
- Empty or whitespace-only `-text` (`-text ""`, `-text " "`, `-text "<br>"`) gives no detail.
- No detail for: a line `label` with `-text`, a `continuation` point with `-text`, an `altitude` point with a value, and a `-name` on a non-station point.
- `plainText` is `kind type detail id` in that order, with missing parts left out and single spaces.
- Building labels never changes the file: `originalLineInTH2File` and the written output are identical before and after building every label.

### Row widget

- With a Therion id, the spans are kind/type, detail, then id; the detail span is italic in the normal text color, and only the id span uses `onSurfaceVariant`.
- A multi-line label or remark row shows a tooltip with one line per `<br>` part on hover. Rows without `tooltipText` have no `Tooltip`.
- The row's semantics label equals `plainText`, with or without the tooltip.
- Tapping, right-clicking and dragging a row with a tooltip behave as before (one representative case each, reusing the `t3943`/`t3948` helpers).
- Pressing a row with a tooltip, holding still for longer than the long-press delay, then dragging still starts the drag (§4.3), and hovering still shows the tooltip.

### Keeping labels current

- Setting, changing and removing `-name` on a station, and `-text` on a label or remark, through `MPSetOptionToElementCommand` and `MPRemoveOptionFromElementCommand`, bumps `structureRevision` and updates the row text.
- Undo and redo of each of those restore the previous row text.
- The same edit wrapped in `MPMultipleElementsCommand` updates every affected row.
- Changing a point's type from `station` to `label` and back through the type-edit command switches the detail source. The type edit keeps every option, so the fixture point has both `-name` and `-text`. The test calls `MPEditPointTypeCommand` directly: changing the type to `station` from the UI (`th2_file_edit_user_interaction_controller.dart:1300-1330`) also assigns a new station name through `getNextStationNameOptions`, which would replace the fixture's `-name`.

### Filtering

- Filtering by a station name, or by a word from a label or remark, shows the row with its scrap and file ancestors.
- Filtering by a word that appears only in a tooltip line also finds the row, since the detail contains every line.

### Acceptance

- `flutter analyze` is clean and `flutter test` is green, including `t3942`, `t3943` and `t3947`–`t3950` unchanged.
- Rows of every other element type look as they did in Phase 4.

## 9. Risks

1. **Long details hide the id.** A long label text fills the row and the ellipsis cuts off the id. Search and semantics still see the id. If users miss it, a later change could cap the detail's width; not needed for v1.
2. **Revision bumps on unrelated `-text` edits.** Editing `-text` on a line or continuation point rebuilds the label cache once without changing any label. The cost is one cache rebuild per edit, which is negligible.
3. **Tooltip gestures versus dragging.** The label tooltip's long-press recognizer could take a held press away from the row's drag. Covered by the §8 "hold, then drag" test, with `TooltipTriggerMode.manual` as the fix (§4.3).
4. **Literal tags in the row.** Labels full of `<size:…>` or `<lang:…>` tags look noisy. This matches the canvas today; a shared tag-stripping helper for both is a possible later improvement, out of scope here.
