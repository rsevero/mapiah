# Phase 2.5 — Text/Label Point Symbols

## Context

`docs/plans/2026-07-15-therion-symbol-rendering-roadmap.md` (lines 267–372) defines Phase 2.5 of the Therion-faithful rendering roadmap: render the point types whose Therion output is text (label, remark, date, altitude, height, passage-height, dimensions, station-name, station) as actual text with alignment, a white background, font sizing, and — for passage-height — a decorated container, instead of today's abstract placeholder shapes (diamond, inverted-T, etc.). Phases 0–2 (infrastructure, simple symbols, medium symbols) are already implemented; this phase only activates for point types whose primary content is text, and whenever `TH2Edit_VisualizationMethod` is any Therion mode (i.e. `!= MapiahPlaceholder`) — see the dispatch note below.

Scope decisions confirmed with the user:
- Text formatting: parse `<br>` into multiple lines; all other Therion text tags (`<center>`, `<size:N>`, `<rm>/<it>/<bf>`, `<rtl>`, `<lang:XX>`, `<thsp>`) are left as literal characters for now. The `THLabelSize` enum/infra is still built so a later phase can wire up `<size:S>` parsing.
- `THPointType.stationName` has no text-bearing option in the current data model (only generic align/attr/id/place/orientation/plScale/visibility). It is explicitly left out of this phase's label wiring and keeps its current placeholder shape.
- Label rendering is **not** UIS-specific: unlike the point/line/area *symbols* from Phases 1–2 (which are only defined for the UIS set so far and gate on `== therionUIS`), text labels are the same across all Therion symbol sets. The dispatch condition for this phase is therefore `tH2EditVisualizationMethod != MPTH2EditVisualizationMethod.mapiahPlaceholder` (any Therion mode), not an equality check against `therionUIS`.
- **Roadmap-wide policy (added by the user directly in `2026-07-15-therion-symbol-rendering-roadmap.md`, "Observations" under Phase 3)**: every phase's output — not just this one — should activate for `tH2EditVisualizationMethod != MPTH2EditVisualizationMethod.mapiahPlaceholder`, falling back to the generic `therionUIS` set when a specific `therionXXX` mode has no symbol of its own. Since Phases 1–2 only ever implemented the UIS set, applying this means broadening their existing `== therionUIS` dispatch checks to `!= mapiahPlaceholder` (the fallback is automatically satisfied because UIS is the only implementation that exists). This phase updates all three existing dispatch sites in `MPVisualController` to match, alongside adding the new label dispatch:
  - `getLineDecorator` (`mp_visual_controller.dart:1073-1089`): currently returns `null` early when `!= therionUIS`; change the early-return condition to `== mapiahPlaceholder`.
  - `getDefaultAreaPaint` (`mp_visual_controller.dart:1237-1259`): currently applies the UIS pattern-tile fill only `== therionUIS`; change to `!= mapiahPlaceholder`.
  - `getDefaultPointPaint` symbol dispatch (`mp_visual_controller.dart:1401-1413`): currently attaches `therionSymbol` only `== therionUIS`; change to `!= mapiahPlaceholder`.
  - New label dispatch (this phase): `!= mapiahPlaceholder`, per above.

## Data → text resolution (new `MPLabelTextAux`)

New file `lib/src/auxiliary/mp_label_text_aux.dart`, mirroring the static-method style of `MPCommandOptionAux`. Single entry point:

```dart
MPLabelData? resolve(THPoint point)
```

Returns `null` for any point type not handled this phase (falls through to placeholder rendering as today). Handles, reading via `point.getOption(...)` per `THCommandOptionType`:

| `THPointType` | Option consumed | Text produced |
|---|---|---|
| `label` | `text` (`THTextCommandOption.text.content`) | split on `<br>` → lines |
| `remark` | `text` | split on `<br>` → lines |
| `date` | `dateValue` (`THDatetimePart`) | `datetime.toString()` |
| `altitude` | `altitudeValue` | formatted number + unit, prefixed with `▲` glyph; `isFix` shown as e.g. `1300 m (fix)`, `isNan` → `—` |
| `height` | `pointHeightValue` | reuse `specToFile()`-style formatting (chimney `+`, pit `-`, step, presumed `?`) minus the `[...]` wrapper Therion uses for file syntax |
| `passageHeight` | `passageHeightValue` | two numbers (plus/minus) per `THPassageHeightModes`, routed to the decorated-container mode below rather than plain text |
| `dimensions` | `dimensionsValue` | `"above / below unit"` two-line or single-line text |
| `station` | `station` option via `MPCommandOptionAux.getName(point)` | station name string |

`MPLabelData` (new small value class, same file or `lib/src/controllers/auxiliary/mp_label_data.dart`) carries: `List<String> lines`, `MPLabelMode mode` (`plain`, `passageHeightPos`, `passageHeightNeg`, `passageHeightPosNeg`), and for passage-height the plus/minus line strings kept separate (needed by the split-oval container).

## New enums

- `THLabelSize` (`lib/src/painters/types/th_label_size.dart`): `tiny, small, normal, large, huge` with a multiplier map (`0.6, 0.8, 1.0, 1.4, 2.0`) matching the roadmap's font-size table. Phase 2.5 always resolves `normal` (no `<size:S>` parsing yet) — the enum/multiplier map exists so later phases can wire it up without touching call sites.
- Alignment reuses the **existing** `THOptionChoicesAlignType` (`lib/src/elements/command_options/types/th_option_choices_align_type.dart`, 9 values) read via the point's generic `align` option (`THAlignCommandOption`, already supported by every point type through `_supportPointOptionsForAll`). No new alignment enum needed.

## Paint plumbing

- `THPointPaint` (`lib/src/controllers/auxiliary/th_point_paint.dart`): add one new optional field `final MPLabelPaint? labelPaint;` (parallel to the existing `therionSymbol` field) plus `copyWith` support. `MPLabelPaint` (new class, `lib/src/controllers/auxiliary/mp_label_paint.dart`) carries the resolved `MPLabelData`, `THOptionChoicesAlignType align`, `THLabelSize size`, and the fill/border `Paint`s to use for the white background box.
- `MPVisualController.getDefaultPointPaint` (`lib/src/controllers/mp_visual_controller.dart:1401-1413`): the existing block only dispatches Therion symbols when `tH2EditVisualizationMethod == MPTH2EditVisualizationMethod.therionUIS`. Add a second, broader check — `tH2EditVisualizationMethod != MPTH2EditVisualizationMethod.mapiahPlaceholder` — under which `MPLabelTextAux.resolve(point)` is called; if non-null, read the point's `align` option and set `pointPaint.copyWith(labelPaint: MPLabelPaint(...))`. This runs regardless of which Therion set (UIS/AUT/SBE/...) is selected, since labels aren't symbol-set-specific. Label and symbol are mutually exclusive per point type (a type is either in `therionUISPointSymbols` or handled by `MPLabelTextAux`, never both), so no precedence conflict.

## Drawing

- New `MPLabelPainter` (`lib/src/painters/helpers/mp_label_painter.dart`), analogous to `mp_symbol_transform.dart`. Core method:

```dart
void drawTherionLabel(
  Canvas canvas,
  MPLabelPaint labelPaint,
  Offset anchor,
  double rotation,     // current point rotation, to be undone (horiz_labels)
  MPSymbolUnit symbolUnit,
)
```

  Steps: `canvas.save()` → `canvas.translate(anchor)` → `canvas.rotate(-rotation)` (undoes the point's rotation so text stays horizontal, matching Therion's `horiz_labels`) → build a `TextPainter`/`TextSpan` per line with `fontSize = symbolUnit.canvasValue * THLabelSize.normal.multiplier`, clamped to a minimum of `8px / (canvasScale * devicePixelRatio)` in canvas units (roadmap's readability floor) → measure combined bounding box → compute the anchor-corner offset for the 9 `THOptionChoicesAlignType` values (e.g. `topRight` → box's bottom-left corner sits at the anchor) → paint a white `RRect` (small margin) behind the text via the paint stored on `MPLabelPaint` → `canvas.restore()`.
- Passage-height containers (`process_uplabel`/`process_downlabel`/`process_updownlabel`): three small `Path`-building helpers in the same file (`buildUpLabelContainer`, `buildDownLabelContainer`, `buildUpDownLabelContainer`), each returning a `Path` (arc + straight edge / oval + divider) sized to the measured text box; drawn via `canvas.drawPath` before the text, driven by `MPLabelData.mode`.
- Wire-in point: `MPInteractionAux.drawPoint` (`lib/src/auxiliary/mp_interaction_aux.dart:208-239`) — add a branch mirroring the existing `therionSymbol != null` early return (lines 214-226): if `pointPaint.labelPaint != null` and `symbolUnit != null`, call `MPLabelPainter.drawTherionLabel(...)` and return, before falling through to the placeholder-shape lookup. `THPointPainter.paint()` needs no changes — it already always supplies `symbolUnit`.

## Tests

Follow existing numbering/convention (`test/t3760`–`t3764` cover Phases 0–2):
- `test/t3765_therion_uis_phase2_5_labels_test.dart` — golden test rendering all Phase 2.5 point types side by side via the existing `MPSymbolGoldenHarness` (`test/auxiliary/mp_symbol_golden_harness.dart`), covering: plain label with `<br>`, remark, date, altitude (normal/fix/nan), height (chimney/pit/step/presumed), passage-height (pos/neg/posneg containers), dimensions, station name — each at a couple of `align` values and one rotated case to confirm `horiz_labels` un-rotation. New golden `test/goldens/therion_uis_phase2_5_labels.png`.
- Extend the dispatch-style test pattern from `test/t3762_therion_uis_phase1_dispatch_test.dart`: verify `MPLabelTextAux.resolve` returns the right `MPLabelData`/`null` per point type, and that `getDefaultPointPaint` attaches `labelPaint` for every non-`mapiahPlaceholder` `TH2Edit_VisualizationMethod` value (not just `therionUIS`), and never when it's `mapiahPlaceholder`.

## Non-goals for this phase

- `<center>`/`<left>`/`<right>` per-line alignment, `<size:N>`/`<size:N%>`/`<size:S>`, font-switch tags, `<rtl>`, `<lang:XX>`, `<thsp>` — left as literal text.
- `THPointType.stationName` — left on placeholder rendering.
- Any new global settings (font-size UI) — deferred to Phase 5 (symbol-set selection UI) or later.

## Verification

- `flutter analyze` — no new warnings.
- `flutter test test/t3765_therion_uis_phase2_5_labels_test.dart` (and re-run `t3762`–`t3764` to confirm no regressions in the existing dispatch/symbol tests).
- Manually run the app (`flutter run -d linux`), open a `.th2` fixture containing label/altitude/height/passage-height/dimensions/station points, switch `TH2Edit_VisualizationMethod` to a Therion mode in settings, and visually confirm text renders with white background, correct alignment, and stays horizontal when the scrap/point is rotated.
- Update `CHANGELOG.md` under the unreleased section following the existing Phase 0–2 bullet style ("Implemented Phase 2.5 of Therion-faithful symbol rendering: ...").
