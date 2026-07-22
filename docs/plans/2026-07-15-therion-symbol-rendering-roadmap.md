# Therion Symbol Rendering Roadmap

**Created**: 2026-07-15
**Approach**: C — Phased manual Dart/Flutter port, UIS symbol set first

---

## Goal

Create a new Therion-like rendering system in Mapiah. There should be a configurable settings where the user can choose between current Mapiah placeholder rendering (abstract geometric shapes for points, dash-only patterns for lines, solid/transparent fills for areas) and Therion-faithful visual symbols matching the UIS symbol set, then extend to other symbol sets in later phases.

---

## Background

### How Therion Renders Symbols

Therion uses a two-stage pipeline:
1. **C++ layer** — Parses `.th2`, transforms coordinates, emits MetaPost code
2. **MetaPost layer** — Executes procedural drawing macros → EPS/SVG/PDF

All symbols are defined as MetaPost macros in three files:
- `thPoint.mp` (880 lines) — ~41 UIS point symbols
- `thLine.mp` (1201 lines) — ~15 UIS line symbols
- `thArea.mp` (358 lines) — ~6 UIS area patterns

Nine symbol sets exist (UIS, AUT, SBE, SKBB, BCRA, NSS, NZSS, ASF, SM). The UIS set is the default and covers the vast majority of real-world files.

### Current Mapiah State

| Element                | Current Rendering                                      | Missing                                                                                  |
| ---------------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| **Points** (112 types) | Abstract shapes: circle, star, triangle, diamond, etc. | Therion-specific symbol shapes (stalactite form, entrance cross, airdraught wings, etc.) |
| **Lines** (40 types)   | 17 dash/dot patterns only                              | Path decorations: pit teeth, slope ticks, step notches, flowstone curls, etc.            |
| **Areas** (21 types)   | Solid or semi-transparent fill colors                  | Tiling patterns: water hatching, sand stipple, debris texture, etc.                      |

The rendering abstraction is well-structured (`MPPointShapeType`, `MPLinePaintType`, `MPVisualController`, `THPointPaint`, `THLinePaint`). Adding Therion symbols means extending these systems, not restructuring them.

### Therion code availability

Therion code is locally available at ~/devel/therion-rsevero.

---

## Chosen Approach: Phased Manual Dart Port (UIS First)

Each MetaPost `def` macro is translated to a Dart function using Flutter's `Canvas`/`Path` API:

```
MetaPost def p_stalactite_UIS(pos, theta, sc, al)
  →  Dart void drawStalactiteUIS(Canvas, Offset pos, double rotation, double scale)
```

**Key Flutter equivalents for MetaPost primitives:**

| MetaPost                           | Flutter/Dart equivalent                                                                            |
| ---------------------------------- | -------------------------------------------------------------------------------------------------- |
| `thdraw path`                      | `canvas.drawPath(path.transform(T), paint)`                                                        |
| `thfill path`                      | `canvas.drawPath(path, paint)` with `PaintingStyle.fill`                                           |
| `thclean path`                     | `canvas.drawPath(path, backgroundPaint)` to erase                                                  |
| `adjust_step(len, step)`           | `(len / step).round()` → evenly spaced ticks                                                       |
| `arclength P`                      | `pathMetric.length`                                                                                |
| `arctime t of P`                   | `pathMetric.getTangentForOffset(t)`                                                                |
| `thdir(P, t)`                      | `tangent.vector` (direction at offset)                                                             |
| `PenA/B/C/D` (widths)              | `Paint()..strokeWidth = u * factor`                                                                |
| `normaldeviate` / `uniformdeviate` | `Random().nextGaussian()` / `Random().nextDouble()` — seeded per element MPID for stable repaints  |
| `beginpattern…endpattern`          | `PictureRecorder` → tile image → `ImageShader` in `Paint`                                          |
| Transformation matrix `T`          | `canvas.save()` / `canvas.translate()` / `canvas.rotate()` / `canvas.scale()` / `canvas.restore()` |

**Unit `u`**: In Therion MetaPost, `u` is configurable (default ~10pt). In Mapiah, `u` maps to a canvas-scale-aware base unit so symbols scale with zoom.

---

## Symbol Inventory & Complexity

### UIS Point Symbols (41 total)

| Symbol                         | Visual                                                          | Complexity |
| ------------------------------ | --------------------------------------------------------------- | ---------- |
| `p_stalactite_UIS`             | Downward V-shape + vertical line                                | simple     |
| `p_stalagmite_UIS`             | Upward V-shape + vertical line                                  | simple     |
| `p_pillar_UIS`                 | Vertical line + V-shapes top and bottom                         | simple     |
| `p_curtain_UIS`                | Top V-shape + hanging curved line                               | medium     |
| `p_helictite_UIS`              | Vertical line + angled reflected lines                          | medium     |
| `p_sodastraw_UIS`              | Horizontal line + vertical lines below                          | simple     |
| `p_crystal_UIS`                | Three lines at 60° spacing                                      | simple     |
| `p_flowstone_UIS`              | Three stacked horizontal lines                                  | simple     |
| `p_moonmilk_UIS`               | Single smooth bezier curve                                      | medium     |
| `p_wallcalcite_UIS`            | Upward triangle                                                 | simple     |
| `p_popcorn_UIS`                | Three filled circles above baseline                             | medium     |
| `p_disk_UIS`                   | Baseline + circle above                                         | medium     |
| `p_anastomosis_UIS`            | Wavy path with alternating curves                               | medium     |
| `p_karren_UIS`                 | Two parallel diagonal lines                                     | simple     |
| `p_scallop_UIS`                | Arc shape (scallop shell)                                       | medium     |
| `p_flute_UIS`                  | Two parallel horizontal lines                                   | simple     |
| `p_narrowend_UIS`              | Two vertical parallel lines                                     | simple     |
| `p_lowend_UIS`                 | Two horizontal parallel lines                                   | simple     |
| `p_sand_UIS`                   | Three radial lines at 120°                                      | simple     |
| `p_pebbles_UIS`                | Three superellipses at different angles                         | medium     |
| `p_debris_UIS`                 | Three triangles at different positions                          | simple     |
| `p_blocks_UIS`                 | Multiple triangles with inner lines                             | complex    |
| `p_water_UIS`                  | Ellipse with water fill pattern                                 | complex    |
| `p_ice_UIS`                    | Cross pattern (vertical + horizontal)                           | simple     |
| `p_archeomaterial_UIS`         | Circle with diagonal crossing lines                             | medium     |
| `p_paleomaterial_UIS`          | Filled bezier blob                                              | medium     |
| `p_guano_UIS`                  | Curved blob at top                                              | medium     |
| `p_entrance_UIS`               | Filled triangle                                                 | simple     |
| `p_waterflow_paleo_UIS`        | Vertical line + triangular arrowhead                            | medium     |
| `p_gradient_UIS`               | Vertical line + triangular arrowhead                            | medium     |
| `p_waterflow_permanent_UIS`    | S-curve + arrowhead                                             | medium     |
| `p_waterflow_intermittent_UIS` | S-curve + dashed pattern                                        | medium     |
| `p_airdraught_UIS`             | Vertical line + wing curves + hash marks (loop, `mlog` scaling) | complex    |
| `p_airdraught_winter_UIS`      | Airdraught + diagonal cross                                     | complex    |
| `p_airdraught_summer_UIS`      | Airdraught + cross + circle                                     | complex    |
| `p_camp_UIS`                   | Triangle + base line + small top triangle                       | simple     |
| `p_dig_UIS`                    | Excavation icon shape                                           | simple     |
| `p_continuation_UIS`           | Curved mark + dot                                               | simple     |
| `p_stalagmites_UIS`            | Multiple stalagmites (loop, 0.7× scale)                         | complex    |
| `p_stalactites_UIS`            | Multiple stalactites (loop, 0.7× scale)                         | complex    |
| `p_pillars_UIS`                | Multiple pillars (loop, 0.7× scale)                             | complex    |

**Complexity counts**: simple 16 · medium 16 · complex 9

### UIS Line Symbols (15 total)

| Symbol                      | Visual                                              | Complexity |
| --------------------------- | --------------------------------------------------- | ---------- |
| `l_wall_bedrock_UIS`        | Solid line (PenA)                                   | simple     |
| `l_wall_underlying_UIS`     | Dashed line                                         | simple     |
| `l_wall_presumed_UIS`       | Double-dashed line                                  | simple     |
| `l_rockborder_UIS`          | Thin solid line (PenC)                              | simple     |
| `l_rockedge_UIS`            | Very thin line (PenD)                               | simple     |
| `l_gradient_UIS`            | Line + triangular arrowhead at end                  | simple     |
| `l_survey_cave_UIS`         | Segmented line with optional polygon sections       | medium     |
| `l_pit_UIS`                 | Line + perpendicular tick marks at intervals        | complex    |
| `l_chimney_UIS`             | Delegates to `l_ceilingstep_SKBB(reverse P)`        | complex    |
| `l_ceilingmeander_UIS`      | Line + paired perpendicular marks                   | complex    |
| `l_ceilingstep_UIS`         | Line + perpendicular ticks (direction-aware)        | complex    |
| `l_contour_UIS`             | Line + optional midpoint tick                       | complex    |
| `l_flowstone_UIS`           | Looped curls along path (bezier, arc-parameterized) | complex    |
| `l_moonmilk_UIS`            | Tighter curved loops along path                     | complex    |
| `l_waterflow_permanent_UIS` | Meandering path with `normaldeviate` noise          | complex    |

**Complexity counts**: simple 6 · medium 1 · complex 8

### UIS Area Patterns (6 total)

| Symbol            | Visual                                              | Complexity |
| ----------------- | --------------------------------------------------- | ---------- |
| `a_water_UIS`     | Diagonal line hatching                              | simple     |
| `a_sump_UIS`      | Cross-hatch pattern                                 | simple     |
| `a_debris_UIS`    | Scattered debris pattern                            | simple     |
| `a_flowstone_ASF` | Curved fill pattern                                 | simple     |
| `a_moonmilk_SKBB` | Wave pattern                                        | simple     |
| `a_sand_UIS`      | Randomized point cloud (nested loop + `randomized`) | complex    |

**Complexity counts**: simple 5 · complex 1

---

## Architecture Plan

### Point Symbols

Add a new enum `MPTherionPointSymbol` (one value per Therion point type) and a corresponding `MPTherionPointPainter` or a drawing function map analogous to the existing `_pointShapeDrawMethods` in `mp_interaction_aux.dart`.

Each symbol function signature:
```dart
void drawStalactiteUIS(
  Canvas canvas,
  Offset position,
  double rotation,   // theta in MetaPost
  double scale,      // sc — base unit multiplier
  Paint strokePaint,
  Paint? fillPaint,
)
```

Point symbols are **static paths** — define the path once at unit scale, then apply a `Matrix4` transform (rotation + scale + translation) before drawing. This is more efficient than rebuilding the path per frame.

### Line Decorations

Line symbols that are more than a styled stroke require a **path decorator** pattern:

```dart
abstract class MPLineDecorator {
  void decorate(Canvas canvas, Path path, THLinePaint paint, double scale);
}
```

The decorator receives the full line `Path`, computes a `PathMetric`, then walks it at `adjust_step`-equivalent intervals to stamp marks (ticks, curls, arrowheads) using `getTangentForOffset()` for position and angle.

This extends `THLinePainter` without breaking the existing continuous/dashed rendering.

### Area Fill Patterns

Area patterns use a tiling approach:

1. **Define the tile**: Draw the pattern tile to a `PictureRecorder` → `Picture` → `ui.Image`
2. **Create a shader**: `ImageShader(image, TileMode.repeated, TileMode.repeated, matrix)`
3. **Apply to fill**: `Paint()..shader = shader`
4. **Clip to area**: `canvas.clipPath(areaPath)` before drawing

Tile generation is done once per pattern type and cached. The tile size should use the same base unit `u` as point symbols so scale stays consistent.

For the **`a_sand_UIS`** complex pattern (randomized point cloud), seed `Random` with a fixed seed so the pattern is stable across repaints.

---

## Phases

### Phase 0 — Infrastructure (prerequisite)

Before drawing any symbols, establish the shared foundations:

- [x] Create `TH2Edit_VisualizationMethod` MPSetting as a enum with the following options: `MapiahPlaceholder`, `TherionUIS`, `TherionAUT`, `TherionSBE`, `TherionSKBB`, `TherionBCRA`, `TherionNSS`, `TherionNZSS`, `TherionASF`, `TherionSM`. Default value is `MapiahPlaceholder`.
- [x] Define base unit `u` as a canvas-scale-aware constant (e.g., `MPSymbolUnit`) accessible from all painters
- [x] Add `Matrix4`-based symbol transform helper (position + rotation + scale in one call)
- [x] Add `PathMetric` walker utility for line decorators (wraps `getTangentForOffset`, handles path direction)
- [x] Add `MPLineDecorator` abstract class and hook it into `THLinePainter`
- [x] Add area pattern tile cache (`Map<THAreaType, ui.Image>`) in `MPVisualController` or a dedicated `MPPatternCache`
- [x] Add seeded-random helper for stable procedural patterns (seed = element MPID)
- [x] Prototype `thclean` erase behavior: evaluate `BlendMode.clear` (requires a `saveLayer`/`restoreLayer` pair so clearing only affects the current layer, not the canvas background) vs. `canvas.clipPath` (clips subsequent draws to the shape boundary). Determine which approach matches Therion's hole-punching semantics and document the decision for use in Phase 1+
- [x] Establish visual test harness: a debug page or golden test that renders all symbols side-by-side for comparison against Therion output

### Phase 1 — Simple UIS Symbols

**Goal**: All "simple" symbols rendered correctly. No loops, no randomness.

**Points (16)**:
- `stalactite`, `stalagmite`, `pillar`
- `sodastraw`, `crystal`, `flowstone` (point), `wallcalcite`
- `karren`, `flute`, `narrowend`, `lowend`
- `sand` (point), `ice`, `entrance`, `dig`, `continuation`

**Lines (6)**:
- `wall_bedrock` (solid line — may already be correct)
- `wall_underlying`, `wall_presumed` (dash patterns — review against Therion)
- `rockborder`, `rockedge` (thin lines)
- `gradient` (line + arrowhead)

**Areas (5)**:
- `water` (diagonal hatching)
- `sump` (cross-hatch)
- `debris`, `flowstone_ASF`, `moonmilk_SKBB`

**`thclean` usage in Phase 1**: Apply the approach chosen in Phase 0 wherever a symbol needs to erase the background (e.g., label backgrounds punching through filled areas). Phase 1 symbols are simple enough that the full erasing pattern is rarely needed, but the prototype must be exercised here on at least one real case before Phase 3 relies on it heavily.

**Deliverable**: A file with only simple element types renders identically to Therion SVG output.

### Phase 2 — Medium Complexity UIS Symbols

**Goal**: Symbols with curves, bezier paths, and moderate geometry.

**Points (16)**:
- `curtain`, `helictite`, `moonmilk`, `anastomosis`, `scallop`
- `popcorn`, `disk`, `pebbles`
- `archeomaterial`, `paleomaterial`, `guano`
- `waterflow_paleo`, `gradient` (point), `waterflow_permanent`, `waterflow_intermittent`
- `camp` (has simple base but involves multiple subshapes)

**Lines (1)**:
- `survey_cave` (segmented line with conditional polygon sections)

**Deliverable**: All medium-complexity symbols match Therion. Phase 1+2 together cover the symbols used in the majority of real-world `.th2` files.

### Phase 2.5 — Text / Label Point Symbols

**Goal**: Render all point types whose primary output is text rather than a drawn shape, matching Therion's label placement, alignment, background fill, and decorated containers.

#### Context

Therion handles text-based points through a specialized `p_label` macro system (in `therion.mp`) rather than the regular symbol macros in `thPoint.mp`. The C++ layer (`thpoint.cxx`) emits calls like:

```metapost
p_label.urt(btex \thnormalsize Station1 etex, pos, rotation, p_label_mode_station);
```

Key features:
- **8 alignment anchors**: `urt` (upper-right), `ulft` (upper-left), `lrt` (lower-right), `llft` (lower-left), `top`, `bot`, `lft`, `rt` — and implicitly centered
- **White background fill**: each label gets a white rounded rectangle behind it (`label_fill_color`, `process_filledlabel`)
- **Horizontal override** (`horiz_labels = true` by default): text always renders horizontally regardless of map rotation — the canvas transform is reset for text, then restored
- **5 font size levels**: `\thtinysize`, `\thsmallsize`, `\thnormalsize`, `\thlargesize`, `\thhugesize`
- **Decorated containers** for specific label modes (see below)

#### Current Mapiah State

All text-based point types are currently drawn as abstract geometric shapes (e.g., `label` → horizontal diamond, `altitude` → inverted-T). No actual text content is rendered on the canvas.

#### Label Modes (from `thpoint.cxx`)

| Mode                               | Visual                          | Container                                     |
| ---------------------------------- | ------------------------------- | --------------------------------------------- |
| `p_label_mode_label`               | User-provided free text         | Plain text + white background                 |
| `p_label_mode_station`             | Station name                    | Plain text + white background                 |
| `p_label_mode_altitude`            | Altitude value (e.g., `▲ 1234`) | Plain text + altitude prefix symbol           |
| `p_label_mode_date`                | Survey date string              | Plain text + white background                 |
| `p_label_mode_height`              | Single passage height value     | Plain text + white background                 |
| `p_label_mode_passageheightpos`    | Positive height only            | Top semicircular box (`process_uplabel`)      |
| `p_label_mode_passageheightneg`    | Negative height only            | Bottom semicircular box (`process_downlabel`) |
| `p_label_mode_passageheightposneg` | Both +/− heights                | Split oval box (`process_updownlabel`)        |

#### Point Types Affected

| Therion Point Type | Mapiah Enum                 | Label Mode               | Notes                         |
| ------------------ | --------------------------- | ------------------------ | ----------------------------- |
| `label`            | `THPointType.label`         | `label`                  | Free text from `extra` option |
| `remark`           | `THPointType.remark`        | `label`                  | Free text                     |
| `date`             | `THPointType.date`          | `date`                   | Date string from point data   |
| `altitude`         | `THPointType.altitude`      | `altitude`               | Numeric value + prefix symbol |
| `height`           | `THPointType.height`        | `height`                 | Single numeric value          |
| `passage-height`   | `THPointType.passageHeight` | `posneg` / `pos` / `neg` | Split or single box           |
| `dimensions`       | `THPointType.dimensions`    | `label`                  | Formatted dimension string    |
| `station-name`     | `THPointType.stationName`   | `station`                | Station ID string             |
| `station`          | `THPointType.station`       | `station`                | Station dot + name label      |

#### Flutter Implementation Plan

**Text rendering primitive**:

```dart
void drawTherionLabel(
  Canvas canvas,
  String text,
  Offset anchor,          // label attachment point (post-alignment offset applied)
  THLabelAlignment align, // maps to Therion's .urt/.lft/etc.
  double fontSize,        // derived from THLabelSize enum
  bool horizontal,        // horiz_labels — reset rotation before drawing
  Color fillColor,        // label_fill_color (default white)
)
```

**Alignment → anchor offset**: Each alignment variant shifts the text bounding box so the correct corner/edge touches `anchor`. For example, `.urt` (upper-right) means the lower-left corner of the text box sits at the anchor point.

**Background fill**: Before drawing text, paint a white `RRect` around the measured `TextPainter` bounds with a small margin (≈ 0.8 bp equivalent in canvas units).

**Horizontal labels**: Wrap the text draw call in `canvas.save()` → undo the current canvas rotation → draw text → `canvas.restore()`. This matches Therion's `horiz_labels` behavior.

**Decorated containers** (for `passageHeight`):

- `process_uplabel` → top edge is a circular arc; bottom edge is straight — drawn as a custom `Path` clip/border
- `process_downlabel` → inverted arc on bottom
- `process_updownlabel` → full oval with horizontal dividing line; the positive value sits in the upper half and the negative value in the lower half

These containers are drawn with `canvas.drawPath()` before the text.

**Font size levels**: Map `THLabelSize` enum to `TextStyle(fontSize: ...)` values scaled by the same base unit `u` used for symbol geometry:

| Therion         | Flutter   |
| --------------- | --------- |
| `\thtinysize`   | `u * 0.6` |
| `\thsmallsize`  | `u * 0.8` |
| `\thnormalsize` | `u * 1.0` |
| `\thlargesize`  | `u * 1.4` |
| `\thhugesize`   | `u * 2.0` |

**Scale behavior**: Unlike geometric symbols that scale with canvas zoom, text should remain at a minimum readable size at low zoom levels. Implement a minimum pixel floor (e.g., 8px) below which font size does not shrink further.

#### Implementation Tasks

- [x] Add label alignment support (9 values): reused the existing `THOptionChoicesAlignType` enum and its `align` point option instead of adding a separate `THLabelAlignment` enum, since they're identical in shape and already wired to every point type
- [x] Add `THLabelSize` enum (tiny, small, normal, large, huge)
- [x] Implement `drawTherionLabel()` utility in a new `MPLabelPainter` helper
- [x] Implement white background `RRect` fill with bbox margin
- [x] Implement `horiz_labels` behaviour in `MPLabelPainter`: the canvas point painters receive is never pre-rotated by the point's orientation (only the Therion symbol path rotates it), so labels stay horizontal by simply not rotating, with no explicit "reset" needed
- [x] Implement `process_uplabel` / `process_downlabel` / `process_updownlabel` containers as `Path` builders, plus a 4th `passageHeightUnsigned` framed-box container for the unsigned passage-height value (`p_label_mode_passageheight` in `thpoint.cxx`, not explicitly listed above)
- [x] Plumb text content from `THPoint` options (`text`, `dateValue`, `altitudeValue`, `pointHeightValue`, `passageHeightValue`, `dimensionsValue`, station name) through to the painter via `MPLabelTextAux`
- [x] Wire `MPLabelPainter` into `MPInteractionAux.drawPoint` (the shared point-drawing entry point used by `THPointPainter`) as an alternative rendering path for text-type points
- [x] Update `MPVisualController.getDefaultPointPaint` to trigger label rendering instead of shape rendering for text-based point types, active for any Therion visualization method (not just UIS — see the roadmap-wide policy in the Phase 3 Observations note)
- [x] Add label rendering to the Phase 0 visual test harness (`test/t3765_therion_uis_phase2_5_labels_test.dart`)

**Deliverable**: All text-based point types render their actual content (text strings) on the canvas with correct alignment, white background, font sizing, and decorated containers for passage heights. Station names appear next to station dots.

### Phase 3 — Complex UIS Symbols ✅

**Goal**: Symbols requiring loops, randomness, or `adjust_step`-equivalent path walking.

**Points (9)**:
- [x] `blocks` — triangles with inner lines, multiple iterations
- [x] `water` (point) — ellipse with embedded water fill pattern (clipped diagonal hatch, drawn directly rather than via the area-pattern tile cache)
- [x] `airdraught`, `airdraught_winter`, `airdraught_summer` — resolved via the point's `subtype` option (`undefined`/`winter`/`summer`), the same mechanism as `waterFlow`'s subtypes; the wing hash-mark count uses Therion's `round(3 + 2*log2(sc))` formula with `sc` fixed at 1, since Mapiah has no per-point scale knob beyond the global symbol unit (matching every other ported symbol)
- [x] `stalagmites`, `stalactites`, `pillars` — repeated sub-symbol placement (3 instances at 0.7x scale, geometry pre-scaled rather than the ambient canvas scale, so the pen width stays constant like Therion's fixed-width `pickup PenC`)

**Lines (8)**:
- [x] `pit` (and its Therion alias `floorstep`, mapped to `THLineType.floorStep`) — perpendicular ticks at regular arc intervals
- [x] `chimney` — `l_ceilingstep_SKBB(reverse P)`: same tick pattern as `ceilingstep` but measured from the path's end, ticks on the opposite side
- [x] `ceilingmeander` — paired radial+crossbar marks along path
- [x] `ceilingstep` — ticks on a fixed side (no direction-awareness beyond what Therion's own macro encodes)
- [x] `contour` — midpoint tick (Therion's `pnt = -2` default case only; per-knot tick positions from the C++ layer's `txt` list have no Mapiah equivalent)
- [x] `flowstone` (line) — bezier curls along path (directional-curve approximation, see below)
- [x] `moonmilk` (line) — tight curved loops along path (same approximation, narrower angle)
- [x] `waterflow_permanent` — meandering path with seeded pseudo-random noise (`MPSeededRandom`, seeded by element `mpID`) plus an arrowhead

**Areas (1)**:
- [x] `sand` — randomized dot cloud, implemented as a repeating 3x3-grid tile (fixed seed, not per-element, per this document's own Architecture Plan guidance) rather than a live per-area nested loop, reusing the existing `MPPatternCache`/`ImageShader` infrastructure

**Deviations from this document's original Phase 3 sketch, decided with the user before implementation**:
- **`thclean`**: Phase 0/1 already established `MPThClean.drawPath` (flat background-color fill) instead of `canvas.saveLayer`/`BlendMode.clear`, and that mechanism is correct for Mapiah's flat-color canvas. Rather than introduce a second, unused erase mechanism, `MPThClean.drawPath` gained an optional `opacity` parameter (mirroring `thclean`'s `withalpha` transparency branch) and Phase 3's `airdraught_winter`/`airdraught_summer` reuse it as-is (full opacity).
- **Line decorators stay additive**: like every Phase 1/2 decorator, Phase 3's line decorators add marks on top of Mapiah's existing placeholder dash-styled base line rather than replacing it with Therion's exact solid-line-plus-gap rendering; `waterflow_permanent`'s meander is likewise drawn as an overlay instead of replacing the line's base path (which would need threading `MPSymbolUnit`/`mpID` into `MPLineDecorator.buildBasePath`, not just `decorate`).
- **`pillars` point type**: while auditing Phase 3, discovered Therion has a standalone `pillars` point type (`TT_POINT_TYPE_PILLARS`) that Mapiah never supported at all (only `pillar`, `pillarWithCurtains`, `pillarsWithCurtains`). Added full support (grammar recognition is generic and needed no changes; added the enum member, placeholder shape, EN/PT labels, and tests) as a separate prerequisite commit before porting `p_pillars_UIS`.

**Deliverable**: Complete UIS symbol set. All Therion UIS files render faithfully.

**Observations**

- The outputs generated by all phases in this doc should be used when `tH2EditVisualizationMethod != MPTH2EditVisualizationMethod.mapiahPlaceholder` (any Therion mode), not an equality check against `therionUIS`. If a therionXXX mode does not have a specific symbol set, fall back to the generic `therionUIS` set. Check that this fallback behavior is consistent across all Therion modes for previous phases and keep it true for future phases.

### Phase 4 — Additional Symbol Sets

Implement the remaining 8 symbol sets, prioritized by community usage:

1. **SKBB** (Slovak) — widely used in European cave surveys; several SKBB symbols are already referenced as fallbacks in UIS (`l_chimney_UIS` delegates to `l_ceilingstep_SKBB`)
2. **AUT** (Austrian) — used in Austrian/German surveys
3. **SBE** (Brazilian) — large symbol set (1308 lines of MetaPost); complex picture-based symbols
4. **BCRA** (British)
5. **NSS** (American)
6. **NZSS** (New Zealand)
7. **ASF** (Alpine/Austrian Federation)
8. **SM** (Slovenian)

Each set follows the same three-phase pattern (simple → medium → complex) within that set.

### Phase 5 — Symbol Set Selection UI

- Add symbol set selector to settings (UIS / AUT / SBE / SKBB / …)
- Persist selection via `MPSettingsController`
- Hot-swap symbol renderers without restart
- Document in help pages (EN + PT)

---

## Validation Strategy

- **Reference output**: For each symbol, generate a Therion SVG using a minimal `.th2` fixture, extract the symbol graphic, and compare visually (or via pixel diff) against Mapiah's rendered output.
- **Golden tests**: Flutter golden tests for each symbol at unit scale, generated from the reference SVG.
- **Scale invariance**: Verify symbols look correct at typical zoom levels (0.5×–5×).
- **Rotation**: Verify rotated point symbols (theta ≠ 0) match Therion.

---

## Open Questions

1. **Symbol size calibration**: What is the canonical `u` value in screen pixels at 1:500 scale? This determines how Therion's `0.4u` measurements map to Flutter canvas units.
2. **Color support**: Therion supports per-symbol color overrides (CMYK/RGB). Should Mapiah support this from Phase 1, or start with fixed UIS colors? Answer: Just use UIS colors.
3. **Symbol set fallback chain**: When a symbol is missing in the selected set, Therion falls back to UIS. Should Mapiah implement this same chain from Phase 4, or require explicit UIS as baseline? Answer: Implement this same chain from Phase 4.
