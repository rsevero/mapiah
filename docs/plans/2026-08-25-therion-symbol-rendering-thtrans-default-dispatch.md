<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Symbol Rendering: `thTrans.mp` Default Dispatch and `TherionDefault` — Design Doc

**Date:** 2026-08-26
**Status:** Proposed

---

## 1. Overview & Motivation

[The Phase 4 plan](2026-08-24-therion-symbol-rendering-phase4-additional-symbol-sets.md)
states, as one of its foundational assumptions:

> Types without a symbol in the selected set fall back to UIS, matching
> Therion's own fallback chain.

This turns out to be **incorrect**, and the mistake has already shown up in
Phase 4B work landed this session: `survey -subtype surface`,
`ropeLadder`, `viaFerrata`, and several `wall` subtypes were ported as
"SKBB-specific" symbols, with doc comments claiming Mapiah's "Therion UIS"
visualization method would keep showing Mapiah's placeholder for them
because "UIS has no macro." That framing assumes UIS is Therion's universal
base/fallback set. It isn't.

### 1.1 What `thTrans.mp` actually is

Therion's MetaPost sources define each point/line/area symbol under a
suffixed name — `p_clay_SKBB`, `l_survey_cave_SKBB`, `p_gypsum_NSS`,
`a_flowstone_ASF`, `p_altar_SBE`, etc. — one per "set" (UIS, SKBB, AUT, SBE,
BCRA, NSS, NZSS, ASF, SM) that happens to define that symbol. A single file,
`thTrans.mp` ("default translations"), then picks **exactly one** concrete
macro per bare symbol name via unconditional `let` assignments — e.g.
`let p_clay = p_clay_SKBB;`, `let l_survey_cave = l_survey_cave_SKBB;`,
`let a_flowstone = a_flowstone_ASF;`. Every other Therion source file calls
the bare name (`p_clay`, not `p_clay_SKBB`).

Checked and confirmed:

- `thTrans.mp` is Therion's **default translation table**: with no explicit
  symbol-set selection, it is what every document renders.
- Therion also exposes a layout option, `symbol-set <set>`, documented in
  `thbook/ch03.tex` and implemented via `mapsymbol(...)`. It does **not**
  swap `thTrans.mp` for another file; it emits per-symbol assignments after
  `input thTrans` and overrides a bare symbol only where the selected set
  defines that symbol. If the set does not define a symbol, `thTrans.mp`'s
  default remains in force.
- `thtrans.h`/`thtrans.cxx` in `therion-core` are unrelated (2D vector/matrix
  math for coordinate transforms), despite the similar name.
- The `_UIS`/`_SKBB`/`_AUT`/`_SBE`/`_BCRA`/`_NSS`/`_ASF`/`_SM` suffixes are a
  **naming convention** grouping macros by which national/organizational
  contribution originated them. A user-selectable rendering profile is then
  assembled from those suffixes by `symbol-set`.

So "UIS" is not Therion's default/fallback set — it's just the
best-represented *contributor* in `thTrans.mp` (see §2), because it's the
oldest and most complete set. Many individual symbols default to SKBB, ASF,
NSS, SBE, BCRA, or AUT instead, with no UIS equivalent existing at all in
some cases (`l_survey_surface`, `a_flowstone`, all of `p_altar`/`p_bat`/
`p_danger`/etc. under SBE).

### 1.2 What this means for Mapiah

Mapiah's `MPTherionSymbolSet` registries (`getTherionPointSymbol`,
`getTherionLineDefinition`, `getTherionAreaPatternDefinition`) currently
implement a two-tier chain: **chosen set → hardcoded UIS**. That
hardcoded UIS terminal case is what's wrong: it should be **whatever
`thTrans.mp` actually assigns**, with the selected set applying only where
it actually defines a macro. `thTrans.mp` assigns UIS only about half the
time.

Concretely, today, selecting **"Therion UIS"** in Mapiah's settings does
*not* reproduce what a real `therion` run outputs for `survey -subtype
surface`, `ropeLadder`, `viaFerrata`, most `wall` subtypes, `a_flowstone`,
any `p_altar`/`p_bat`/`p_danger`/... SBE point, `p_gypsum`, `p_raft`,
`p_station_fixed`, and more — because none of those have a UIS macro to
fall back to in the first place, yet Mapiah's placeholder still shows for
them instead of the correct (non-UIS) symbol.

### 1.3 Direction agreed with the user

- Mapiah keeps its symbol-set picker in settings (`mapiahPlaceholder`,
  `therionDefault`, `therionUIS`, `therionAUT`, `therionSBE`, `therionSKBB`,
  `therionBCRA`, `therionNSS`, `therionNZSS`, `therionASF`), rather than
  collapsing it to a single "Therion" mode.
- **`therionDefault` is new and means "exactly what `thTrans.mp` specifies"**
  — no explicit symbol-set override. It is Mapiah's equivalent of running
  Therion without a `symbol-set` layout option. **`therionDefault` is also
  Mapiah's new default visualization method**: new installs and setting
  resets start with it selected instead of `mapiahPlaceholder`.
- Existing stored visualization-method values are not rewritten. Users who
  already have `mapiahPlaceholder`, `therionUIS`, or another value saved keep
  it; the new default applies only when the setting is absent or reset.
- **`therionUIS` becomes a true UIS override** — Mapiah's equivalent of
  `symbol-set UIS`. It overrides `thTrans.mp`'s default to UIS only where a
  `_UIS` macro exists; elsewhere `thTrans.mp`'s default remains.
- **Every other set behaves like `symbol-set <set>`**: it overrides
  `thTrans.mp`'s default only where the chosen set actually defines a macro
  for that exact symbol type/subtype. Where it doesn't, `thTrans.mp`'s
  default stands, even if that default is a *different* set than the one the
  user picked. E.g. picking `therionAUT` still renders `survey -subtype
  surface` via `l_survey_surface_SKBB`, because AUT has no
  `l_survey_surface_AUT` to override with.
- This is **not** a Mapiah-specific divergence: it is the same behavior as
  Therion's `symbol-set <set>` layout option. Mapiah just exposes it as a
  live editor preview rather than a compile-time layout setting.

---

## 2. `thTrans.mp`, transcribed in full

The following is the complete, current content of `thTrans.mp` (208 lines,
`~/devel/therion-rsevero/src/therion-mpost/thTrans.mp` at the time of
writing), grouped by domain. This is the literal ground truth the new
dispatch tables in §4 must reproduce.

### 2.1 Points

| Symbol | Default set | | Symbol | Default set |
|---|---|---|---|---|
| `p_station_fixed` | ASF | | `p_electriclight` | SBE |
| `p_station_painted` | SKBB | | `p_exvoto` | SBE |
| `p_station_natural` | ASF | | `p_gate` | SBE |
| `p_station_temporary` | ASF | | `p_helictites` | UIS |
| `p_station` | SKBB | | `p_humanbones` | SBE |
| `p_waterflow_paleo` | UIS | | `p_masonry` | SBE |
| `p_waterflow_permanent` | UIS | | `p_minus` | UIS |
| `p_waterflow_intermittent` | UIS | | `p_mud` | SBE |
| `p_stalactite` | UIS | | `p_mudcrack` | SBE |
| `p_stalagmite` | UIS | | `p_nameplate` | SBE |
| `p_stalactites` | UIS | | `p_nowheelchair` | SBE |
| `p_stalagmites` | UIS | | `p_pendant` | SBE |
| `p_pillar` | UIS | | `p_pillarwithcurtains` | UIS |
| `p_pillars` | UIS | | `p_pillarswithcurtains` | UIS |
| `p_icestalactite` | AUT | | `p_photo` | SBE |
| `p_icestalagmite` | AUT | | `p_plus` | UIS |
| `p_icepillar` | AUT | | `p_plusminus` | UIS |
| `p_curtain` | UIS | | `p_seedgermination` | SBE |
| `p_curtains` | UIS | | `p_stalactitestalagmite` | UIS |
| `p_helictite` | UIS | | `p_stalactitesstalagmites` | UIS |
| `p_sodastraw` | UIS | | `p_treetrunk` | SBE |
| `p_crystal` | UIS | | `p_volcano` | SBE |
| `p_flowstone` | UIS | | `p_walkway` | SBE |
| `p_moonmilk` | UIS | | `p_waterdrip` | SBE |
| `p_wallcalcite` | UIS | | `p_wheelchair` | SBE |
| `p_popcorn` | UIS | | `p_vegetabledebris` | ASF |
| `p_disk` | UIS | | `p_root` | ASF |
| `p_gypsum` | NSS | | `p_entrance` | UIS |
| `p_aragonite` | NSS | | `p_gradient` | UIS |
| `p_cavepearl` | SKBB | | `p_rope` | SKBB |
| `p_gypsumflower` | NSS | | `p_fixedladder` | SKBB |
| `p_rimstonepool` | ASF | | `p_ropeladder` | SKBB |
| `p_rimstonedam` | ASF | | `p_steps` | SKBB |
| `p_anastomosis` | UIS | | `p_bridge` | SKBB |
| `p_karren` | UIS | | `p_traverse` | SKBB |
| `p_scallop` | UIS | | `p_anchor` | SKBB |
| `p_flute` | UIS | | `p_camp` | SKBB |
| `p_raft` | NSS | | `p_dig` | UIS |
| `p_raftcone` | NSS | | `p_noequipment` | SKBB |
| `p_spring` | SKBB | | `p_sectionarrow` | SKBB |
| `p_sink` | SKBB | | `p_continuation` | UIS |
| `p_narrowend` | UIS | | `p_airdraught` | UIS |
| `p_lowend` | UIS | | `p_airdraught_winter` | UIS |
| `p_flowstonechoke` | NSS | | `p_airdraught_summer` | UIS |
| `p_breakdownchoke` | NSS | | `p_handrail` | SKBB |
| `p_claychoke` | AUT | | `p_viaferrata` | SKBB |
| `p_claytree` | AUT | | | |
| `p_bedrock` | ASF | | | |
| `p_clay` | SKBB | | | |
| `p_sand` | UIS | | | |
| `p_pebbles` | UIS | | | |
| `p_debris` | UIS | | | |
| `p_blocks` | UIS | | | |
| `p_water` | UIS | | | |
| `p_ice` | UIS | | | |
| `p_snow` | SKBB | | | |
| `p_archeomaterial` | UIS | | | |
| `p_paleomaterial` | UIS | | | |
| `p_guano` | UIS | | | |
| `p_altar` | SBE | | | |
| `p_archeoexcavation` | SBE | | | |
| `p_audio` | SBE | | | |
| `p_bat` | SBE | | | |
| `p_bones` | SBE | | | |
| `p_borehole` | SKBB | | | |
| `p_danger` | SBE | | | |
| `p_discpillar` | UIS | | | |
| `p_discpillars` | UIS | | | |
| `p_discstalactites` | UIS | | | |
| `p_discstalagmites` | UIS | | | |
| `p_discstalactite` | UIS | | | |
| `p_discstalagmite` | UIS | | | |

(All 118 `p_*` lines of `thTrans.mp` are represented above; the two-column
layout is purely a formatting convenience, not a grouping.)

### 2.2 Lines

| Symbol | Default set | | Symbol | Default set |
|---|---|---|---|---|
| `l_abyssentrance` | SBE | | `l_rockborder` | UIS |
| `l_dripline` | SBE | | `l_rockedge` | UIS |
| `l_fault` | SBE | | `l_flowstone` | UIS |
| `l_joint` | SBE | | `l_moonmilk` | UIS |
| `l_lowceiling` | SBE | | `l_section` | SKBB |
| `l_pitchimney` | SBE | | `l_survey_cave` | SKBB |
| `l_rimstonedam` | SBE | | `l_survey_surface` | SKBB |
| `l_rimstonepool` | SBE | | `l_arrow` | SKBB |
| `l_walkway` | SBE | | `l_gradient` | UIS |
| `l_wall_bedrock` | UIS | | `l_mapconnection` | SKBB |
| `l_wall_sand` | SKBB | | `l_handrail` | SKBB |
| `l_wall_clay` | SKBB | | `l_steps` | SKBB |
| `l_wall_pebbles` | SKBB | | `l_fixedladder` | SKBB |
| `l_wall_debris` | SKBB | | `l_ropeladder` | SKBB |
| `l_wall_blocks` | SKBB | | `l_rope` | SKBB |
| `l_wall_ice` | SKBB | | `l_viaferrata` | SKBB |
| `l_wall_underlying` | UIS | | | |
| `l_wall_unsurveyed` | SKBB | | | |
| `l_wall_presumed` | UIS | | | |
| `l_wall_pit` | AUT | | | |
| `l_wall_overlying` | AUT | | | |
| `l_wall_flowstone` | AUT | | | |
| `l_wall_moonmilk` | AUT | | | |
| `l_waterflow_permanent` | UIS | | | |
| `l_waterflow_intermittent` | SKBB | | | |
| `l_waterflow_conjectural` | SKBB | | | |
| `l_border_visible` | SKBB | | | |
| `l_border_temporary` | SKBB | | | |
| `l_border_presumed` | SKBB | | | |
| `l_floorstep` | UIS | | | |
| `l_pit` | UIS | | | |
| `l_ceilingstep` | SKBB | | | |
| `l_chimney` | UIS | | | |
| `l_overhang` | SKBB | | | |
| `l_slope` | SKBB | | | |
| `l_ceilingmeander` | SKBB | | | |
| `l_floormeander` | SKBB | | | |
| `l_contour` | SKBB | | | |

`l_wall_invisible` and `l_border_invisible` are commented out in
`thTrans.mp` (no default assignment at all — Therion presumably resolves
these through a different mechanism, e.g. always-empty/`l_invisible`
regardless of set; not investigated further here).

### 2.3 Areas

| Symbol | Default set |
|---|---|
| `a_water` | UIS |
| `a_sump` | UIS |
| `a_sand` | UIS |
| `a_debris` | SKBB |
| `a_blocks` | SKBB |
| `a_snow` | SKBB |
| `a_ice` | SKBB |
| `a_pebbles` | SKBB |
| `a_clay` | SKBB |
| `a_bedrock` | SKBB |
| `a_flowstone` | ASF |
| `a_moonmilk` | SKBB |
| `a_dimensions` | SKBB |
| `a_mudcrack` | SBE |
| `a_pillar` | SBE |
| `a_pillarwithcurtains` | SBE |
| `a_stalactite` | SBE |
| `a_stalactitestalagmite` | SBE |
| `a_stalagmite` | SBE |

### 2.4 Map furniture (`s_*`)

| Symbol | Default set |
|---|---|
| `s_northarrow` | SKBB |
| `s_scalebar` | SKBB |
| `s_hgrid` | SM |
| `s_vgrid` | SKBB |
| `s_altitudebar` | SKBB |

Out of scope for this doc (Mapiah has no map-furniture rendering yet, and
`s_hgrid`'s only default is SM, which the existing roadmap already excludes
— see [the Phase 4 plan](2026-08-24-therion-symbol-rendering-phase4-additional-symbol-sets.md)'s
rationale for leaving SM out).

### 2.5 What isn't in `thTrans.mp` at all

Line/point/area types Mapiah dispatches on that have **no `thTrans.mp`
entry** (meaning: not every symbol Mapiah tracks is a Therion "translatable"
name — some are Mapiah-internal groupings, or Therion types resolved a
different way, e.g. via subtype-suffixed bare macro names like
`l_wall_presumed`/`l_border_presumed` which *are* covered above, versus
truly bare types like `wall`/`border` themselves which aren't real Therion
macro names). Any symbol type Mapiah currently dispatches on that doesn't
appear in §2.1–§2.4 has **no `thTrans.mp` default opinion**, so the new
default tables return `null` and the registry falls through to the existing
UIS terminal case (`therionUIS`/`therionDefault` both end at UIS, then the
Mapiah placeholder). Each such type still needs to be individually confirmed
against Therion's source before assuming this is faithful.

---

## 3. Current Mapiah dispatch (recap)

Three parallel registries, each following the same two-tier shape:

```dart
// lib/src/painters/therion_common/mp_therion_symbol_registry.dart
MPTherionPointSymbol? getTherionPointSymbol({
  required MPTherionSymbolSet set,
  required THPointType pointType,
  required String subtype,
}) {
  final setSymbol = _setSpecificPointSymbolLookups[set]?.call(pointType: pointType, subtype: subtype);
  if (setSymbol != null) return setSymbol;
  return getTherionUISPointSymbol(pointType: pointType, subtype: subtype); // hardcoded UIS
}
```

(`mp_therion_line_registry.dart`'s `getTherionLineDefinition` and
`mp_therion_area_pattern_registry.dart`'s `getTherionAreaPatternDefinition`
are structurally identical, differing only in the per-domain types
involved.)

`_setSpecificPointSymbolLookups`/`_setSpecificLineLookups`/
`_setSpecificAreaPatternLookups` currently only have a `skbb` entry (Phase
4B); `aut`/`sbe`/`bcra`/`nss`/`nzss`/`asf` have no entries and so always
fall straight through to UIS today — which is exactly the bug described in
§1.2, just currently invisible because none of those six sets has *any*
ported content yet to differ from UIS in the first place.

`MPTH2EditVisualizationMethod` currently has no way to express "no symbol-set
override": `therionUIS` is the only non-placeholder option that has been
given special meaning. §4 adds `therionDefault` and makes the registry API
nullable-set-aware instead of overloading `therionUIS`.

---

## 4. Proposed dispatch

### 4.1 New default-set lookup tables

Three new small, static, hand-transcribed lookup tables — one per domain —
mirroring §2.1–§2.3 exactly:

```dart
// lib/src/painters/therion_common/mp_therion_default_symbol_set.dart (new)

MPTherionSymbolSet? getTherionDefaultPointSet({
  required THPointType pointType,
  required String subtype,
}) { ... } // mirrors §2.1

MPTherionSymbolSet? getTherionDefaultLineSet({
  required THLineType lineType,
  String? subtype,
}) { ... } // mirrors §2.2

MPTherionSymbolSet? getTherionDefaultAreaSet(THAreaType areaType) { ... } // mirrors §2.3
```

Returns `null` for any type/subtype not covered by §2.1–§2.4 (see §2.5),
signaling "no `thTrans.mp` opinion — use the UIS terminal behavior for this
one."

These functions are keyed by Mapiah's own `TH*Type` enum values and subtype
strings, so their implementation must contain the explicit Therion-name
mapping that is currently implicit in Mapiah's camelCase enum names. In
particular:

- `THPointType.airDraught` subtypes `winter`/`summer`/`NO_SUBTYPE` map to
  `p_airdraught_winter`/`p_airdraught_summer`/`p_airdraught`.
- `THPointType.waterFlow` subtypes `paleo`/`permanent`/`intermittent`/
  `NO_SUBTYPE` map to the corresponding `p_waterflow_*` entries.
- `THPointType.station` subtypes `fixed`/`painted`/`natural`/`temporary`/
  `NO_SUBTYPE` map to the `p_station_*`/`p_station` entries.
- `THLineType.pitch` is a Therion alias for `l_pit`; both `THLineType.pit`
  and `THLineType.pitch` map to §2.2's `l_pit` entry.
- `THLineType.pitChimney` maps to `l_pitchimney`, `THLineType.waterFlow` to
  `l_waterflow`, `THLineType.rockBorder` to `l_rockborder`, and
  `THLineType.mapConnection` to `l_mapconnection`.

Some §2 entries have no corresponding Mapiah `TH*Type` value at all
(`p_plus`, `p_minus`, `p_plusminus`, `p_sectionarrow`, `a_dimensions`, the
`s_*` map furniture). They stay in §2 as the ground-truth inventory, but the
new functions need only contain reachable Mapiah types/subtypes; unreachable
`thTrans.mp` entries are not implemented until Mapiah models those types.

These tables are the only new hand-transcribed artifact this design
introduces; everything else is a change to *how existing lookups compose*,
not new symbol content.

### 4.2 New chain, per domain

The visualization-method enum gains a new value before `therionUIS`:

```dart
// lib/src/controllers/types/mp_th2_edit_visualization_method.dart
enum MPTH2EditVisualizationMethod {
  mapiahPlaceholder,
  therionDefault,
  therionUIS,
  therionAUT,
  therionSBE,
  therionSKBB,
  therionBCRA,
  therionNSS,
  therionNZSS,
  therionASF,
}
```

`MPSettingEnumDefinitionImpl` currently falls back to `enumValues.first`
(`mapiahPlaceholder`). The definition for
`MPSettingID.TH2Edit_VisualizationMethod` must instead pass
`explicitDefaultValue: MPTH2EditVisualizationMethod.therionDefault` so new
installs/resets start on `therionDefault`.

`MPVisualController` maps `therionDefault` to `null` and all other Therion
methods to their corresponding `MPTherionSymbolSet`. The registry functions
change their `set` parameter from `required MPTherionSymbolSet` to
`MPTherionSymbolSet?`:

```dart
MPTherionPointSymbol? getTherionPointSymbol({
  MPTherionSymbolSet? set,
  required THPointType pointType,
  required String subtype,
}) {
  // 1. If an explicit symbol-set override is selected, try that set first.
  //    `null` means `therionDefault`: skip this step and use thTrans.mp.
  if (set != null) {
    final MPTherionSetPointSymbolLookup? setLookup =
        _setSpecificPointSymbolLookups[set];

    if (setLookup != null) {
      final MPTherionPointSymbol? chosenSetSymbol =
          setLookup(pointType: pointType, subtype: subtype);
      if (chosenSetSymbol != null) return chosenSetSymbol;
    }
  }

  // 2. thTrans.mp's real default for this symbol, if known and ported.
  final MPTherionSymbolSet? defaultSet =
      getTherionDefaultPointSet(pointType: pointType, subtype: subtype);
  if (defaultSet != null) {
    final MPTherionSetPointSymbolLookup? defaultLookup =
        _setSpecificPointSymbolLookups[defaultSet];

    if (defaultLookup != null) {
      final MPTherionPointSymbol? defaultSetSymbol =
          defaultLookup(pointType: pointType, subtype: subtype);
      if (defaultSetSymbol != null) return defaultSetSymbol;
    }
  }

  // 3. UIS as a last-resort catch-all: either thTrans.mp has no opinion
  //    (§2.5) or its assigned set isn't ported in Mapiah yet.
  final MPTherionPointSymbol? uisSymbol =
      getTherionUISPointSymbol(pointType: pointType, subtype: subtype);
  if (uisSymbol != null) return uisSymbol;

  // 4. Neither thTrans.mp's real default nor UIS has this symbol —
  //    genuinely unimplemented anywhere in Mapiah. Caller keeps the
  //    Mapiah placeholder.
  return null;
}
```

`getTherionLineDefinition`/`getTherionAreaPatternDefinition` follow the same
four-step shape, substituting their own per-domain types. Each
`_setSpecific*Lookups` map gains a `uis` entry pointing at its existing UIS
lookup function, so `therionUIS` participates in step 1 like any other set
and step 2 can resolve a UIS `thTrans.mp` default.

`MPPatternCache` must also become nullable-set-aware: its key changes from
`(MPTherionSymbolSet, THAreaType)` to `(MPTherionSymbolSet?, THAreaType)`, so
`therionDefault` does not collide with any real set cache entry.

### 4.3 Worked examples

- **`survey -subtype surface`, mode = `therionDefault`**: step 1 skipped
  (`set == null`). Step 2: `getTherionDefaultLineSet` → SKBB; SKBB has
  `MPSurveySurfaceSKBBLineDecorator` → used. **Matches real Therion with no
  `symbol-set` layout option.** (Today: falls to UIS, which has nothing →
  Mapiah placeholder. **Bug.**)
- **`survey -subtype surface`, mode = `therionUIS`**: step 1 tries UIS, but
  UIS has no `l_survey_surface_UIS` → misses. Step 2 still finds the SKBB
  default. So `therionUIS` and `therionDefault` render this symbol the same
  way, exactly like `symbol-set UIS` in real Therion.
- **`survey -subtype surface`, set = `therionSKBB`**: step 1: SKBB defines
  it → used directly (same result, different path).
- **`survey -subtype surface`, set = `therionAUT`**: step 1: AUT has no
  survey-surface macro → skip. Step 2: thTrans default is SKBB, which is
  ported → used. Picking AUT still renders this symbol correctly, just not
  "in AUT's style" (because AUT has no such style to begin with).
- **`survey -subtype cave`, mode = `therionDefault`**: step 2 default is SKBB
  → the SKBB broken-line decorator is used.
- **`survey -subtype cave`, mode = `therionUIS`**: step 1 finds the existing
  UIS cave decorator, so `therionUIS` deliberately renders UIS's continuous
  line here. This is the key visible difference from `therionDefault`.
- **`point camp`, mode = `therionDefault`**: default `p_camp` is SKBB →
  `campSKBB`. Mode = `therionUIS`: UIS also defines `p_camp`, so
  `therionUIS` renders `campUIS`.
- **`wall -subtype clay`, set = `therionAUT`**: step 1: AUT has no
  `l_wall_clay_AUT` → skip. Step 2: thTrans default SKBB → used
  (`MPWallClaySKBBLineDecorator`).
- **`wall -subtype pit`, mode = `therionDefault`**: step 1 skipped. Step 2:
  thTrans default is AUT, which Mapiah hasn't ported yet (no
  `l_wall_pit_AUT` decorator exists) → step 2 finds nothing. Step 3: UIS has
  no `l_wall_pit_UIS` either (confirm against Therion source when this gets
  implemented) → Mapiah placeholder, same as today. No regression, and this
  is the honest state until AUT's wall-pit macro is ported.
- **`area debris`, mode = `therionDefault`**: default `a_debris` is SKBB →
  SKBB tile. Mode = `therionUIS`: UIS has an `a_debris_UIS` tile, so
  `therionUIS` renders the UIS tile instead.
- **`area clay`, mode = `therionUIS`**: step 1: UIS has no `a_clay_UIS`.
  Step 2: thTrans default SKBB, ported → `a_clay_SKBB`'s tile is used. This
  is the headline behavior change from the old hardcoded-UIS fallback.

### 4.4 Settings: `isEnabled` gating reconsidered

[The earlier change hiding `AUT`/`SBE`/`BCRA`/`NSS`/`NZSS`/`ASF` from the
settings dropdown](../../CHANGELOG.md) reasoned that picking one "rendered
exactly like UIS with no visible effect." Under the new dispatch, that's
still true in practice today (none of those six sets has *any* ported
content, so step 1 always misses and every symbol falls through to
thTrans-default/UIS exactly as it would under `therionDefault`) — so the
hidden sets remain hidden. The reasoning in the `mp_setting_type.dart`
comment must still be updated: "picking one has no visible effect" is now
true because thTrans's default dispatch already applies under every set
equally, not because the set falls back to UIS specifically. Re-enable each
set once it has at least one ported symbol whose set-specific decorator
differs from what thTrans's default would already produce.

`therionDefault` and `therionUIS` are both enabled in the dropdown from the
start, and `therionDefault` is the new default selection. They are no longer
synonyms:

- `therionDefault` means "no `symbol-set` override."
- `therionUIS` means "`symbol-set UIS`."

---

## 5. Migration plan

This is mostly mechanical, but it now includes a small public-surface change:
the new `therionDefault` visualization method and the nullable-set registry
signature.

1. **Add `therionDefault`** to `MPTH2EditVisualizationMethod` (§4.2) and
   wire it through `MPVisualController._selectedTherionSymbolSet` as `null`.
2. **Add EN/PT localization labels** for the new visualization method
   (e.g. `mpSettingsEnumVisualizationMethodTherionDefault`), enable it in
   `mp_setting_type.dart`'s `enabledPredicate`, and set
   `explicitDefaultValue: MPTH2EditVisualizationMethod.therionDefault` for
   `MPSettingID.TH2Edit_VisualizationMethod`. Do not rewrite already-stored
   values; the new default applies only to new installs and resets.
3. **Transcribe `thTrans.mp` into the three lookup tables** (§4.1), including
   the explicit Mapiah-type/name alias mapping described there.
4. **Rewrite the three registries** to the nullable-set four-step chain in
   §4.2, adding a `uis` entry to each `_setSpecific*Lookups` map.
5. **Make `MPPatternCache` nullable-set-aware** (§4.2) so `therionDefault`
   has its own cache keys.
6. **Update existing UIS tests/goldens that will change under the new
   semantics**, not just add new tests. At minimum:
   - `test/t3762_therion_uis_phase1_dispatch_test.dart` (UIS `survey cave`
     and UIS debris currently assume the old hardcoded-UIS path)
   - `test/t3766_therion_uis_phase3_symbols_test.dart` (UIS
     `ceiling-meander`/`ceiling-step` currently assume the old path)
   - `test/t3767_therion_phase4a_registry_test.dart` (it asserts the exact
     `MPTH2EditVisualizationMethod.values` order, which gains
     `therionDefault`)
   - UIS Phase 2/3 point/area goldens involving `camp` and `debris`
7. **Add regression tests** per registry for both modes: `set: null`
   (`therionDefault`) must resolve to `thTrans.mp`'s default, and
   `set: uis` must resolve to the UIS override where a `_UIS` macro exists.
8. **Update doc comments** repo-wide that currently assert "X falls back to
   UIS, matching Therion" — including `mp_therion_skbb_line_map.dart`,
   `mp_therion_skbb_area_map.dart`, `mp_therion_skbb_point_map.dart`, the
   three registries, the Phase 4 plan, and the CHANGELOG entry that currently
   says Therion has no `symbol-set` mechanism.
9. **No changes needed** to individual `MPLineDecorator`/point-draw-method/
   area-tile implementations themselves — every symbol already ported
   (Phase 0–4B) keeps its existing decorator class; only *when it gets
   selected* changes.
10. **Run the full test suite**, including golden tests, before considering
    the phase done.

### 5.1 Suggested phase split

Given the amount of test and doc-comment churn and the value of getting the
dispatch core right before touching every call site's prose, this likely
wants to be its own phase (call it **Phase 5**) rather than folded into Phase
4B's remaining SKBB work:

- **Phase 5a**: `therionDefault` enum/localization/settings, the three
  lookup tables, nullable-set registry rewrite, pattern-cache change, and
  core dispatch tests (§4.1, §4.2, §5 items 1–5 and 7).
- **Phase 5b**: update existing UIS tests/goldens and sweep doc comments
  across already-landed files and affected plan/CHANGELOG prose (§5 items
  6 and 8), file by file.
- **Phase 5c** (optional, lower priority): audit symbols *not* yet covered
  by any set-specific decorator against §2's tables to prioritize what to
  port next by "how far current UIS rendering diverges from `thTrans.mp`'s
  real default" rather than by symbol-set groupings — e.g. `p_altar`
  (SBE-only, currently shows the Mapiah placeholder under every visualization
  method including UIS) is a bigger real-world fidelity gap than another UIS
  wall subtype would be, since Therion never renders `p_altar` any other way.

---

## 6. Decisions

1. **Naming**: add a new `therionDefault` visualization method. `therionUIS`
   keeps its existing enum value/settings label, but now means
   `symbol-set UIS` rather than "the default table." `therionDefault` gets
   its own distinct user-facing label (e.g. "Therion (default)") and becomes
   Mapiah's new default visualization method for new installs and resets.
2. **Scope for this first pass**: Phase 5a covers all three domains —
   points, lines, *and* areas — in one pass, not just the line registry.
   §7 below reflects this as a single combined task rather than a
   per-domain split.
3. **§2.5 (types with no `thTrans.mp` entry)**: confirmed. Every symbol
   already ported this session — `wall -subtype
   sand/pebbles/clay/debris/blocks/ice/unsurveyed`, `waterFlow -subtype
   conjectural/intermittent`, `ropeLadder`, `viaFerrata`, and `survey
   -subtype cave/surface` — appears in §2.2, so all of it is covered by the
   new dispatch with no special-casing needed. Six already-ported symbols
   have both a `_UIS` and a non-UIS `thTrans.mp` default
   (`p_camp`, `l_ceilingmeander`, `l_ceilingstep`, `l_contour`,
   `l_survey_cave`, `a_debris`); these are exactly where `therionDefault`
   and `therionUIS` are expected to differ, and they are the primary
   regression-test targets. Any other in-flight or planned symbol work
   should still be checked against §2 before assuming today's UIS-terminal
   behavior is correct for it.

## 7. Implementation checklist (Phase 5a)

Single pass, all three domains together:

1. Add `therionDefault` to `MPTH2EditVisualizationMethod` and update
   `MPVisualController._selectedTherionSymbolSet` to return `null` for it.
2. Add EN/PT labels for `therionDefault`, enable it in
   `mp_setting_type.dart`'s `enabledPredicate`, and set
   `explicitDefaultValue: MPTH2EditVisualizationMethod.therionDefault` for
   `MPSettingID.TH2Edit_VisualizationMethod`.
3. Add `lib/src/painters/therion_common/mp_therion_default_symbol_set.dart`
   with `getTherionDefaultPointSet`/`getTherionDefaultLineSet`/
   `getTherionDefaultAreaSet` (§4.1), transcribed from §2.1–§2.3 and using
   the explicit Mapiah-type/name alias mapping.
4. Rewrite `getTherionPointSymbol` (`mp_therion_symbol_registry.dart`),
   `getTherionLineDefinition` (`mp_therion_line_registry.dart`), and
   `getTherionAreaPatternDefinition` (`mp_therion_area_pattern_registry.dart`)
   to the nullable-set four-step chain in §4.2, adding a `uis` entry to each
   `_setSpecific*Lookups` map.
5. Change `MPPatternCacheKey` to `(MPTherionSymbolSet?, THAreaType)` and make
   `MPPatternCache` methods accept a nullable set.
6. Add regression tests per registry for `set: null` and `set: uis`, covering
   the six `therionDefault`/`therionUIS` difference cases from §6 plus a
   sample of SKBB-ported, UIS-default, and
   AUT/SBE/NSS/ASF-default-but-unported symbols.
7. Update existing UIS tests/goldens listed in §5 item 6.
8. Sweep doc comments per §5 item 8 (start with `mp_therion_skbb_line_map.dart`,
   `mp_therion_skbb_area_map.dart`, `mp_therion_skbb_point_map.dart`, the three
   registries, the Phase 4 plan wording, and CHANGELOG).
9. Update `mp_setting_type.dart`'s `enabledPredicate` comment per §4.4 (now
   `therionDefault` and `therionUIS` are both enabled and distinct).
10. Run the full test suite (not just touched files — see the
   `mpTherionLineColors` regression this session caught by doing exactly
   that) before considering Phase 5a done.
