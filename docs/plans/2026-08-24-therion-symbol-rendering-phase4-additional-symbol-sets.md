<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Symbol Rendering Phase 4: Additional Symbol Sets — Implementation Plan

**Date:** 2026-08-24
**Status:** Proposed

---

## 1. Overview & Objectives

This document details **Phase 4** of
[the Therion symbol rendering roadmap](2026-07-15-therion-symbol-rendering-roadmap.md).
Phases 0–3 delivered the complete UIS point/line/area symbol set, the shared
drawing infrastructure, text labels, and the
`!= MapiahPlaceholder` dispatch policy. Phase 4 extends that work to the
remaining Therion symbol sets selected for this phase:

1. **SKBB** (Slovak)
2. **AUT** (Austrian)
3. **SBE** (Brazilian)
4. **BCRA** (British)
5. **NSS** (American)
6. **NZSS** (New Zealand)
7. **ASF** (Alpine/Austrian Federation)

**SM (Slovenian) is explicitly not implemented in Phase 4.** Its only native
definitions are special/map-furniture symbols rather than point/line/area
macros, and it is kept out of the visualization-method enum and registries
until a future phase that also addresses map furniture.

The goal is the same as the roadmap's Phase 3 deliverable, now applied to every
set: for each point, line, and area type that a selected Therion set defines,
Mapiah draws the faithful set-specific symbol instead of the Mapiah
placeholder. Types without a symbol in the selected set fall back to UIS,
matching Therion's own fallback chain. Text/label point types remain set-neutral
and continue to use the Phase 2.5 label renderer.

### Key objectives

1. **Enable the seven remaining visualization-method enum values** and wire
   them into the existing enum-backed setting UI.
2. **Replace the current UIS-specific hard-coded dispatch** in
   `MPVisualControllerBase.getLineDecorator`,
   `MPVisualControllerBase.getDefaultAreaPaint`, and
   `MPVisualControllerBase.getDefaultPointPaint` with set-aware registries.
3. **Implement each set's own point drawings, line decorators, and area
   pattern tiles** under new `lib/src/painters/therion_*/` modules, reusing
   the Phase 0 helpers (`MPSymbolTransform`, `MPLineDecorator`,
   `MPPatternCache`, `MPPathMetricWalker`, `MPSeededRandom`, `MPThClean`).
4. **Implement the UIS fallback chain** exactly once, in the registries, rather
   than repeating it in every visual-controller method.
5. **Preserve existing UIS behavior and golden tests**; Phase 4 must not
   regress the already-complete UIS set.

---

## 2. Current State

### 2.1 What already works

- `MPTH2EditVisualizationMethod` currently exposes only
  `mapiahPlaceholder` and `therionUIS`; the other seven members are commented
  out in
  `lib/src/controllers/types/mp_th2_edit_visualization_method.dart`.
- Localized labels for the seven additional sets already exist in
  `lib/l10n/intl_en.arb` and `lib/l10n/intl_pt.arb`, and are already present in
  the generated localizations. No new user-facing strings are required for the
  setting labels themselves.
- Point rendering is dispatched through
  `THPointPaint.therionSymbol` (`MPTherionPointSymbol`),
  `mpTherionSymbolPaints`, and `MPTherionPointSymbolsUIS.drawMethods`.
- Line rendering is dispatched through
  `MPVisualControllerBase.getLineDecorator` and `mpTherionLineColors`.
- Area rendering is dispatched through
  `MPVisualControllerBase._getTherionUISAreaPatternPaint`,
  `mpTherionAreaPatternColors`, and `MPTherionAreaPatternTilesUIS`.

### 2.2 Why the current shape cannot scale

The three dispatch sites are UIS-specific and keyed directly by Mapiah's
`THPointType`/`THLineType`/`THAreaType`. Adding seven sets by copy-pasting these
switches would scatter the fallback policy across three methods, duplicate
color/paint maps, and make it easy for a set to accidentally fall back to
Mapiah's placeholder instead of UIS. The registration/dispatch layer therefore
needs to be generalized before the first non-UIS symbol is drawn.

### 2.3 Therion source material

The local Therion checkout is `~/devel/therion-rsevero`. The relevant sources
are:

| Source | What it contains for Phase 4 |
| --- | --- |
| `src/therion-mpost/thPoint.mp` | UIS points plus SKBB/NSS/BCRA/ASF point macros embedded alongside UIS. |
| `src/therion-mpost/thLine.mp` | UIS lines plus SKBB/NSS/NZSS/BCRA/ASF line macros embedded alongside UIS. |
| `src/therion-mpost/thArea.mp` | UIS areas plus SKBB/ASF area macros and pattern `beginpattern` blocks. |
| `src/therion-mpost/uAUT.mp` | The complete AUT symbol set. |
| `src/therion-mpost/uSBE.mp` | The complete SBE symbol set (1308 lines, including picture-based symbols). |
| `src/therion-mpost/thTrans.mp` | Generic `p_*`/`l_*`/`a_*` aliases that show which set owns the default macro for each Therion type. |
| `build/src/therion-mpost/thsymbolsetlist.h` | Generated, authoritative Therion type → generic MetaPost macro mapping. |

`SM` is not part of Phase 4. It has no point/line/area macros of its own; its
definitions live in `thSpecial.mp` (`s_scalebar_SM`, `s_hgrid_SM`, `s_vgrid_SM`),
which are map furniture rather than canvas element symbols. Implementing those
would belong with a future map-furniture/special-symbol effort, not with the
point/line/area symbol-set work in this plan.

---

## 3. Scope & Non-goals

### In scope

- All point/line/area symbols for SKBB, AUT, SBE, BCRA, NSS, NZSS, and ASF,
  prioritized as described in §6.
- Set-aware dispatch and UIS fallback for the existing visual-controller entry
  points.
- Set-specific point paint maps, line color/decorator maps, and area tile
  builder/color maps.
- Tests and goldens for each newly implemented set.

### Out of scope for Phase 4

- **Phase 5 symbol-set selector polish.** Enabling the enum values makes the
  existing enum-backed setting control list them automatically; Phase 5 will
  own the dedicated selector treatment, persistence/migration changes, hot-swap
  documentation, and help pages.
- **The SM visualization method.** Its `therionSM` enum member stays commented
  out, and no `MPTherionSymbolSet.sm` member or registry entries are created.
- **Therion special/map-furniture symbols** (`s_northarrow`, `s_scalebar`,
  `s_hgrid`, `s_vgrid`, `s_altitudebar`). They are not drawn by the
  point/line/area pipeline.
- **UIS aliases for point types still missing from Phase 3**, such as the
  remaining `disc-*`, `*with-curtains`, and related UIS-only point types shown
  in `docs/plans/2026-07-28-therion-symbol-type-coverage.md` as
  “No (placeholder)”. Those are UIS coverage gaps and are tracked independently
  of the additional-set work.
- **Changing the text/label renderer.** Phase 2.5 already activates labels for
  every non-placeholder visualization method; Phase 4 only needs to keep that
  behavior intact.
- **Replacing Mapiah's base placeholder line with a fully Therion base stroke.**
  Phase 3 established that line decorators remain additive overlays. New-set
  decorators follow the same rule unless a specific set requires `buildBasePath`
  (as `survey_cave` already does).

---

## 4. Set-Aware Architecture

The principle is to keep the three public rendering entry points stable while
moving their `switch` bodies into set-aware registries. The existing UIS files
are left in place as the baseline; new set files are added beside them.

### 4.1 Proposed file organization

```
lib/src/
 ├── controllers/
 │    ├── types/
 │    │    └── mp_th2_edit_visualization_method.dart   # existing: uncomment 7 enum members
 │    └── mp_visual_controller.dart                    # existing: call registries instead of hardcoded UIS switches
 ├── painters/
 │    ├── types/
 │    │    └── mp_therion_point_symbol.dart             # existing UIS enum; see §4.2
 │    ├── therion_uis/                                   # existing UIS implementation (baseline)
 │    ├── therion_skbb/                                  # new
 │    ├── therion_aut/                                   # new
 │    ├── therion_sbe/                                   # new
 │    └── therion_common/                                # new: set-aware dispatch + fallback
 │         ├── mp_therion_symbol_registry.dart
 │         ├── mp_therion_line_registry.dart
 │         ├── mp_therion_area_pattern_registry.dart
 │         └── mp_therion_fallback.dart
 └── constants/
      └── mp_constants.dart                              # new constants only for actual ported geometry
```

Set implementations are separate folders rather than one giant registry so each
set can be reviewed, tested, and committed independently.

### 4.2 Point-symbol model

The existing `MPTherionPointSymbol` enum is UIS-only. Two options were
considered:

1. Introduce one enum per set and change `THPointPaint.therionSymbol` to a
   wrapper/reference object.
2. Extend `MPTherionPointSymbol` with set-qualified values (for example
   `cavePearlSKBB`, `stalactiteAUT`, `altarSBE`) and centralize drawing dispatch.

**Recommended:** option 2. It keeps the existing `THPointPaint.therionSymbol`
field type, keeps `MPInteractionAux._drawTherionPoint` close to its current
form, and preserves the current “one enum value per symbol, one paint entry per
enum value” invariants that Phase 0–3 tests already assert. The cost is a larger
enum, but that is mechanical and each set's additions are isolated in its own
PR.

New shared types:

```dart
/// The currently selected Therion symbol set, mirroring the visualization enum.
enum MPTherionSymbolSet { uis, aut, sbe, skbb, bcra, nss, nzss, asf }
```

New registry entry point:

```dart
MPTherionPointSymbol? getTherionPointSymbol({
  required MPTherionSymbolSet set,
  required THPointType pointType,
  required String subtype,
});

void Function(Canvas, Offset, double, MPTherionSymbolPaint)? getTherionPointDrawMethod(
  MPTherionPointSymbol symbol,
);
```

The registry resolves in this order:

1. set-specific subtype-aware lookup (for example SKBB `air-draught`, AUT
   `water-flow`, and any other subtype-sensitive macros);
2. set-specific non-subtyped lookup;
3. UIS subtype-aware lookup (`getTherionUISPointSymbol`);
4. UIS non-subtyped lookup (`therionUISPointSymbols`).

`mpTherionSymbolPaints` becomes set-neutral: it gains one entry per newly added
enum value, using the same rule as today — `fill` and `border` are non-null only
when that macro calls `thfill`/`thdraw`.

`MPInteractionAux._drawTherionPoint` changes only its final method lookup:

```dart
final drawMethod = getTherionPointDrawMethod(therionSymbol)!;
```

instead of reading `MPTherionPointSymbolsUIS.drawMethods` directly.

### 4.3 Line-symbol model

Lines do not need a new enum. The existing
`MPLineDecorator` type is already the right abstraction; the new work is a
factory that maps `(set, THLineType, subtype)` to a decorator and color.

```dart
class MPTherionLineDefinition {
  const MPTherionLineDefinition({required this.decorator, required this.color});

  final MPLineDecorator decorator;
  final Paint color;
}

MPTherionLineDefinition? getTherionLineDefinition({
  required MPTherionSymbolSet set,
  required THLineType lineType,
  required String? subtype,
});
```

`MPVisualControllerBase.getLineDecorator` becomes a thin adapter:

```dart
MPLineDecorator? getLineDecorator(THLineType lineType, {String? subtype}) {
  if (mpLocator.mpSettingsController.tH2EditVisualizationMethod ==
      MPTH2EditVisualizationMethod.mapiahPlaceholder) {
    return null;
  }

  return getTherionLineDefinition(
    set: _selectedTherionSymbolSet,
    lineType: lineType,
    subtype: subtype,
  )?.decorator;
}
```

The widget currently passes `mpTherionLineColors[lineType]` to `THLinePainter`.
That must be replaced by a registry lookup (or by carrying the color on the
decorator definition), because SKBB/AUT/etc. use different colors for the same
`THLineType`. The least disruptive approach is to add a
`MPTherionLineRegistry.colorFor(...)` accessor and change the two call sites in
`lib/src/widgets/mixins/mp_line_painting_mixin.dart` to use it. The existing
`mpTherionLineColors` map can become the UIS registry's color source, preserving
current values.

### 4.4 Area-pattern model

Current area pattern resolution is in `_getTherionUISAreaPatternPaint`. Replace
it with a registry that returns a pattern definition:

```dart
class MPTherionAreaPatternDefinition {
  const MPTherionAreaPatternDefinition({
    required this.tileBuilder,
    required this.color,
    required this.cleanBeforeFill,
  });

  final ui.Image Function(ui.Color color) tileBuilder;
  final Color color;
  final bool cleanBeforeFill;
}

MPTherionAreaPatternDefinition? getTherionAreaPatternDefinition({
  required MPTherionSymbolSet set,
  required THAreaType areaType,
});
```

`MPPatternCache` currently caches by `THAreaType` (its `imageFor`, `store`,
`contains`, and `remove` methods all key on a single `THAreaType`). Once
multiple sets exist, the same `THAreaType` can produce different tiles under
different sets, so the cache key must become a pair of
`(MPTherionSymbolSet, THAreaType)` or a stable string id such as
`"skbb:blocks"`. The plan is to keep `MPPatternCache`'s method names
(`imageFor`, `store`, `contains`, `remove`, `clear`) unchanged and only widen
their key parameter to the composite key.

`getDefaultAreaPaint` becomes:

```dart
final definition = getTherionAreaPatternDefinition(
  set: _selectedTherionSymbolSet,
  areaType: areaType,
);

if (definition != null) {
  final tile = patternCache.imageFor(set, areaType);
  if (tile == null) {
    patternCache.store(set, areaType, definition.tileBuilder(definition.color));
  }
  return areaPaint.copyWith(
    fillPaint: /* ImageShader built from the tile */,
    cleanBeforeFill: definition.cleanBeforeFill,
  );
}
```

### 4.5 Selection helper

Add a private helper on `MPVisualControllerBase`:

```dart
MPTherionSymbolSet get _selectedTherionSymbolSet {
  final method = mpLocator.mpSettingsController.tH2EditVisualizationMethod;
  return switch (method) {
    MPTH2EditVisualizationMethod.mapiahPlaceholder =>
      throw StateError('Placeholder has no Therion symbol set'),
    MPTH2EditVisualizationMethod.therionUIS => MPTherionSymbolSet.uis,
    MPTH2EditVisualizationMethod.therionAUT => MPTherionSymbolSet.aut,
    MPTH2EditVisualizationMethod.therionSBE => MPTherionSymbolSet.sbe,
    MPTH2EditVisualizationMethod.therionSKBB => MPTherionSymbolSet.skbb,
    MPTH2EditVisualizationMethod.therionBCRA => MPTherionSymbolSet.bcra,
    MPTH2EditVisualizationMethod.therionNSS => MPTherionSymbolSet.nss,
    MPTH2EditVisualizationMethod.therionNZSS => MPTherionSymbolSet.nzss,
    MPTH2EditVisualizationMethod.therionASF => MPTherionSymbolSet.asf,
  };
}
```

No equality-check code remains in the three rendering entry points. Their
placeholder gate is `method == mapiahPlaceholder`; everything else enters the
registry.

### 4.6 Fallback policy

The fallback order is set-specific → UIS → placeholder:

- Points: if the selected set has no symbol for a point type/subtype, the
  registry returns the existing UIS symbol; only if UIS has no symbol does the
  current placeholder path remain.
- Lines: if the selected set has no decorator, the registry returns the UIS
  decorator; `getLineDecorator` returns `null` only when UIS also has none.
- Areas: if the selected set has no tile, the registry returns the UIS tile;
  `getDefaultAreaPaint` leaves the placeholder fill only when UIS also has none.

This satisfies the roadmap's Open Question #3 and its Phase 3 Observations.
Text labels are not affected by the fallback chain because they are set-neutral.

---

## 5. Enabling the Enum Values

In `lib/src/controllers/types/mp_th2_edit_visualization_method.dart`, uncomment
the seven members so the enum reads:

```dart
enum MPTH2EditVisualizationMethod {
  mapiahPlaceholder,
  therionUIS,
  therionAUT,
  therionSBE,
  therionSKBB,
  therionBCRA,
  therionNSS,
  therionNZSS,
  therionASF,
  // therionSM,
}
```

Then in
`lib/src/controllers/types/mp_setting_type.dart`, extend the
`TH2Edit_VisualizationMethod` `localizedLabelBuilder` switch with one case per
new member, using the already-existing localization getters:

```dart
case MPTH2EditVisualizationMethod.therionAUT:
  return appLocalizations.mpSettingsEnumVisualizationMethodTherionAUT;
// ... SBE, SKBB, BCRA, NSS, NZSS, ASF
```

The existing `MPSettingEnumDefinitionImpl` uses `enumValues` and `byName`, so
stored setting persistence continues to work for existing `mapiahPlaceholder`
and `therionUIS` values. No migration is needed unless an existing install
stored a different value, which is impossible today because those members did
not exist.

**Ordering note:** The enum values above follow the roadmap's declared order
exactly — `MapiahPlaceholder, TherionUIS, TherionAUT, TherionSBE, TherionSKBB,
TherionBCRA, TherionNSS, TherionNZSS, TherionASF, TherionSM` (roadmap §"Create
`TH2Edit_VisualizationMethod`"), with the still-unimplemented `therionSM`
staying commented out at the end. This replaces the current file's alphabetical
commented-out order (`ASF, AUT, BCRA, NSS, NZSS, SBE, SKBB, SM` before `UIS`),
and matches the `MPTherionSymbolSet` enum order in §4.2. Changing enum order
after release can break `byName` persistence only if names change, not if
order changes, but the setting UI renders `enumValues` in declaration order, so
the order should match the roadmap/Phase 5 intent.

---

## 6. Implementation Sub-Phases

The seven sets differ sharply in size. The plan groups them into four rollout
batches rather than forcing a strict simple→medium→complex cycle per set. Each
batch still completes simple symbols before complex ones and is independently
mergeable.

### 6.1 Phase 4A — Registry infrastructure + enum enablement

**Deliverable:** the seven enum values are visible in settings, and selecting
any of them currently produces the UIS renderings through the new fallback
path. No new visual output yet.

Tasks:

1. Uncomment and wire the enum values and localized labels (§5).
2. Add `MPTherionSymbolSet`.
3. Add the three registries and the `_selectedTherionSymbolSet` helper.
4. Migrate `getLineDecorator`, `getDefaultAreaPaint`, and
   `getDefaultPointPaint` to the registries while keeping behavior identical for
   `therionUIS`.
5. Change the line-decorator color call sites to use the registry color.
6. Change `MPPatternCache` to use `(set, areaType)` keys, or a stable string
   key, without altering its public users outside the registry.
7. Point the current UIS registry entries at the existing UIS implementation.
8. Update existing dispatch tests (`test/t3762*`, `t3765`, `t3766`) so they
   continue to pass against the registry-backed code.

Acceptance:

- `flutter analyze` clean.
- Existing Phase 0–3 symbol tests still pass unchanged in their goldens.
- A new dispatch test loops over every non-placeholder
  `MPTH2EditVisualizationMethod` value and asserts that known UIS-only symbols
  still resolve (fallback works) before any set-specific implementation exists.

### 6.2 Phase 4B — SKBB

**Rationale:** SKBB is the most widely used additional set in European surveys
and already participates in UIS behavior (`l_chimney_UIS` delegates to
`l_ceilingstep_SKBB`). Many of its macros live directly in
`thPoint.mp`/`thLine.mp`/`thArea.mp`, so the porting effort is lower than AUT or
SBE.

**Source files:** `thPoint.mp`, `thLine.mp`, `thArea.mp` (SKBB macros embedded
alongside UIS), with alias verification from `thTrans.mp`.

**Scope — points:** cave-pearl, clay, snow, spring, sink, station (as defined
by the SKBB station macro), steps, borehole, fixed-ladder, rope-ladder, bridge,
no-equipment, anchor, traverse, rope, camp, handrail, via-ferrata, gradient,
and the SKBB station subtype aliases already present in Therion.

**Scope — lines:** wall subtype lines (`sand`, `pebbles`, `clay`, `debris`,
`blocks`, `ice`, `unsurveyed`), overhang, chimney, ceiling-step,
ceiling-meander, floor-meander, slope, contour, border visible/temporary/
presumed, survey cave/surface, water-flow intermittent/conjectural, arrow,
map-connection, section, rope, steps, handrail, fixed-ladder, rope-ladder, and
via-ferrata.

**Scope — areas:** bedrock, clay, debris, ice, snow, blocks, pebbles, water,
and sump (SKBB's `a_sump` aliases `a_water_SKBB`). `a_debris` is already used
as Therion's default `a_debris` alias, but the SKBB tile still needs its own
registry entry.

Notes:

- SKBB's `l_chimney` already matches the Phase 3 UIS chimney port because the
  UIS macro delegates to the SKBB macro. The SKBB registry can reuse the UIS
  decorator in that case.
- SKBB `p_station` is a `(pos, mark, txt)` macro with text flags. Mapiah's
  Phase 2.5 station handling intentionally left `station`/`station-name` on
  placeholder/label; Phase 4B should port the station *marker geometry* only
  and keep text placement aligned with whatever Phase 2.5/Phase 5 decide for
  station labels. If SKBB station is entangled with text, document and defer the
  text part, keeping the marker/fallback.

**Deliverable:** a `.th2` fixture containing SKBB-owned types renders the SKBB
forms under `therionSKBB`, and falls back to UIS for every type SKBB does not
define.

### 6.3 Phase 4C — AUT

**Source file:** `src/therion-mpost/uAUT.mp`.

**Rationale:** AUT is the second most-used European set and is a single,
self-contained MetaPost file, making it the cleanest large-set port.

**Scope — points:** stalactite, stalagmite, pillar, ice-stalactite,
ice-stalagmite, ice-pillar, crystal, spring, sink, breakdown-choke, sand,
clay (alias of sand), pebbles, debris, blocks, water, ice, entrance, gradient,
air-draught, clay-choke, clay-tree, and the AUT station subtype aliases.

**Scope — lines:** wall subtype lines (`pit`, `sand`, `pebbles`, `clay`,
`debris`, `blocks`, `ice`, `underlying`, `overlying`, `moonmilk`, `flowstone`),
pit, overhang, floor-step (alias), contour, ceiling-step, ceiling-meander,
flowstone, and survey cave.

**Scope — areas:** water, sump, sand, clay, pebbles, debris, ice, snow, blocks,
and flowstone.

Notes:

- AUT `l_overhang` is `let l_overhang_AUT = l_pit_AUT`, so reuse the AUT pit
  decorator rather than writing a second decorator.
- AUT `l_contour_AUT`, `l_ceilingstep_AUT`, and `l_ceilingmeander_AUT` alias
  SKBB/UIS implementations. The registry should point at the already-ported
  decorators and set-specific color, not duplicate the geometry.

**Deliverable:** AUT symbols render under `therionAUT`; non-AUT types fall back
to UIS.

### 6.4 Phase 4D — SBE

**Source file:** `src/therion-mpost/uSBE.mp` (1308 lines).

**Rationale:** SBE is large and contains several picture/image-based symbols
that require special handling, so it is scheduled after the smaller,
macro-only sets.

**Scope — points:** altar, archeo-excavation, audio, bat, bones, danger,
electric-light, ex-voto, gate, human-bones, masonry, mud, mudcrack, nameplate,
no-wheelchair, pendant, photo, seed-germination, tree-trunk, volcano, walkway,
water-drip, and wheelchair.

**Scope — lines:** abyss-entrance, dripline, fault, joint, low-ceiling,
pit-chimney, rimstone-dam, rimstone-pool, and walkway.

**Scope — areas:** mudcrack, pillar, pillar-with-curtains, stalactite,
stalactite-stalagmite, and stalagmite.

Notes:

- SBE `uSBE.mp` uses image/`btex`/picture construction more heavily than the
  other sets. These are ported as `Path`/`PictureRecorder` constructions where
  possible; any genuinely raster/picture-based symbol that cannot be expressed
  as paths is documented as a partial symbol and falls back to UIS until a
  follow-up.
- The `pillar_main_SBE` helper is shared by `a_pillar_SBE`,
  `a_pillarwithcurtains_SBE`, `a_stalactite_SBE`,
  `a_stalactitestalagmite_SBE`, and `a_stalagmite_SBE`; port it once and
  reuse it, mirroring the `.mp` structure.

**Deliverable:** SBE symbols render under `therionSBE`; any deferred
picture-based symbols are listed explicitly in the PR/CHANGELOG as fallback.

### 6.5 Phase 4E — BCRA, NSS, NZSS, ASF

These four sets are small enough to batch in a final sub-phase, but each gets
its own commit where practical.

#### BCRA

- Points: gradient.
- Lines: gradient, slope.

#### NSS

- Points: gypsum, aragonite, gypsum-flower, raft, raft-cone, low-end,
  flowstone-choke, breakdown-choke, gradient.

#### NZSS

- Lines: ceiling-meander (alias of UIS), ceiling-step (alias of UIS), chimney,
  wall presumed.

#### ASF

- Points: rimstone-pool, rimstone-dam, bedrock, vegetable-debris, root, and
  the ASF station marker aliases (`fixed`, `natural`, `temporary`).
- Areas: flowstone (`a_flowstone_ASF`, already used as the UIS area pattern's
  source macro in Phase 1). The ASF registry entry can reuse the existing
  `MPTherionAreaPatternTilesUIS.buildFlowstoneTile` until a set-specific tile
  is needed.

**Deliverable:** all four small sets resolve correctly.

---

## 7. Testing & Validation

### 7.1 Unit/dispatch tests

Follow the existing `t3762`–`t3766` conventions. For each set add:

- A symbol-map test asserting every `THPointType` the set defines maps to the
  expected set-specific `MPTherionPointSymbol`, and every type it does not
  define maps to the UIS fallback (when UIS has one).
- A line registry test asserting decorator/color resolution for each supported
  `(THLineType, subtype)` and fallback for unsupported ones.
- An area registry test asserting tile-builder resolution and fallback.
- A “one paint entry per enum value” test for newly added point symbols, mirroring
  `t3763`'s `mpTherionSymbolPaints` invariant.
- A settings test covering the seven new enum values and their localized labels.

### 7.2 Golden tests

For each set, add golden harness tests in the style of
`test/t3764_therion_uis_phase2_symbols_test.dart` and
`test/t3766_therion_uis_phase3_symbols_test.dart`:

- point symbols side by side;
- line decorators on a shared curved/polygonal path;
- area pattern tiles where applicable.

Goldens should be generated at unit scale with the existing
`MPSymbolGoldenHarness` and stored under `test/goldens/therion_<set>_*.png`.

### 7.3 Reference comparison

Use the same minimal-`.th2`-fixture method as the roadmap validation strategy:

1. Build a Therion SVG from a fixture for each set using the local Therion
   checkout and the corresponding `layout`/symbol set.
2. Extract the symbol graphic.
3. Compare visually and, where practical, by pixel diff against Mapiah's
   golden/render output.

At minimum, a manual visual pass is required for every newly ported symbol;
automated pixel comparison is preferred for the simpler SKBB/AUT/BCRA/NSS/NZSS
symbols and for all repeating area tiles.

### 7.4 Regression guard

Before each sub-phase is merged:

- Re-run `test/t3762*` through `test/t3766*` to prove UIS behavior is unchanged.
- Re-run `flutter test` (or the relevant test subset) and `flutter analyze`.
- Confirm `mapiahPlaceholder` still renders exactly as before, because the
  registry must never enter the Therion path for placeholder mode.

---

## 8. Risks, Decisions, and Open Items

### 8.1 Risks

- **Enum/paint-map growth.** Extending one enum for all sets makes the
  `mpTherionSymbolPaints` map larger. This is intentional and mirrors Therion's
  own macro namespace; the global paint invariant test keeps it honest.
- **SBE picture-based symbols.** Some SBE symbols may be expensive or awkward
  as pure `Path` drawings. The plan permits explicit fallback for those cases
  rather than blocking the entire set.
- **`MPPatternCache` key migration.** If the composite key change is done
  carelessly it can cause UIS area goldens to change. The Phase 4A migration
  must keep UIS cache behavior byte-for-byte identical.
- **Station text coupling.** Several sets define station marker macros that
  expect Therion's C++-side text flags. Phase 4 ports marker geometry only;
  station text remains governed by Phase 2.5/5.

### 8.2 Decisions already made

- Fallback chain is set-specific → UIS → placeholder (roadmap Open Question #3).
- Fixed colors follow the same “use the set's/placeholder-derived color” rule
  as the UIS paints; no per-symbol CMYK/RGB overrides yet (Open Question #2).
- Line decorators stay additive overlays unless `buildBasePath` is required,
  consistent with Phase 3.
- SM is not implemented at all: no enum member, no `MPTherionSymbolSet` member,
  no registry entries, and no UI label switch case.

### 8.3 Open items

- Exact AUT/SBE/SKBB color values should be extracted during implementation
  from the corresponding MetaPost macros and compared with Mapiah's existing
  `THPaint` palette before hard-coding. The plan does not guess them now.
- Whether the Phase 4A enum should be fully enabled in the user-facing setting
  dropdown immediately, or kept behind an internal flag until Phase 5, should
  be confirmed with the user before merging 4A. This document assumes enablement
  is acceptable because the labels already exist and the setting is already
  enum-backed.

---

## 9. Verification Checklist

- [ ] `MPTH2EditVisualizationMethod` contains UIS plus the seven additional sets;
      `therionSM` remains commented out.
- [ ] `MPSettingID.TH2Edit_VisualizationMethod` labels all enum values in EN/PT.
- [ ] The three rendering entry points call set-aware registries and contain no
      set-specific `switch` bodies.
- [ ] UIS goldens and dispatch tests pass unchanged.
- [ ] SKBB point/line/area symbols render and fall back correctly.
- [ ] AUT point/line/area symbols render and fall back correctly.
- [ ] SBE point/line/area symbols render and fall back correctly; deferred
      picture symbols are documented.
- [ ] BCRA, NSS, NZSS, and ASF symbols render and fall back correctly.
- [ ] `therionSM` remains commented out and has no registry or UI wiring.
- [ ] `MPPatternCache` uses a set-aware key without changing UIS tiles.
- [ ] New goldens exist for each implemented set.
- [ ] `flutter analyze` reports no new warnings.
- [ ] `CHANGELOG.md` notes Phase 4 and any deferred symbols.
