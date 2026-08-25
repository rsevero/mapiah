<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Symbol Rendering: `thTrans.mp`-Faithful Default Dispatch — Design Doc

**Date:** 2026-08-25
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
the bare name (`p_clay`, not `p_clay_SKBB`), so **this table is the only
selection therion actually performs**, for every document, unconditionally.

Checked and confirmed:

- There is no `-symbol-set` command-line flag, `thconfig` option, or other
  mechanism that swaps `thTrans.mp` out for a different table. It's the one
  and only mapping compiled into Therion.
- `thtrans.h`/`thtrans.cxx` in `therion-core` are unrelated (2D vector/matrix
  math for coordinate transforms), despite the similar name.
- The `_UIS`/`_SKBB`/`_AUT`/`_SBE`/`_BCRA`/`_NSS`/`_ASF`/`_SM` suffixes are a
  **naming convention** grouping macros by which national/organizational
  contribution originated them — not a user-selectable rendering profile.
  Real Therion has exactly one rendering per symbol, period.

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
`thTrans.mp` actually assigns**, which is UIS only about half the time.

Concretely, today, selecting **"Therion UIS"** in Mapiah's settings does
*not* reproduce what a real `therion` run outputs for `survey -subtype
surface`, `ropeLadder`, `viaFerrata`, most `wall` subtypes, `a_flowstone`,
any `p_altar`/`p_bat`/`p_danger`/... SBE point, `p_gypsum`, `p_raft`,
`p_station_fixed`, and more — because none of those have a UIS macro to
fall back to in the first place, yet Mapiah's placeholder still shows for
them instead of the correct (non-UIS) symbol.

### 1.3 Direction agreed with the user

- Mapiah keeps its symbol-set picker in settings (`mapiahPlaceholder`,
  `therionUIS`, `therionAUT`, `therionSBE`, `therionSKBB`, `therionBCRA`,
  `therionNSS`, `therionNZSS`, `therionASF`), rather than collapsing it to a
  single "Therion" mode.
- **`therionUIS` becomes "exactly what `thTrans.mp` specifies"** — a pure,
  unconditional pass-through of Therion's real default table, no
  UIS-specific override layer on top. Renamed conceptually (not necessarily
  in code/UI label, TBD — see §6) to "Therion (faithful default)."
- **Every other set overrides `thTrans.mp`'s default only where it
  "clashes"** — i.e. only where the chosen set actually defines a macro for
  that exact symbol type/subtype. Where it doesn't, `thTrans.mp`'s default
  stands, even if that default is a *different* set than the one the user
  picked. E.g. picking `therionAUT` still renders `survey -subtype surface`
  via `l_survey_surface_SKBB`, because AUT has no `l_survey_surface_AUT` to
  override with.
- This means picking a non-UIS set is a genuine Mapiah-specific enhancement
  beyond what real Therion offers (there is no way to "force AUT-style
  survey lines" in real Therion) — a deliberate, disclosed divergence for
  users who want to preview/prefer one set's own house style wherever it
  exists, while staying faithful everywhere else.

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
appear in §2.1–§2.4 keeps today's behavior unchanged (chosen set → UIS →
placeholder) until it's individually confirmed against Therion's source.

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
signaling "no `thTrans.mp` opinion — keep today's UIS-terminal behavior for
this one."

These tables are the only new hand-transcribed artifact this design
introduces; everything else is a change to *how existing lookups compose*,
not new symbol content.

### 4.2 New chain, per domain

```dart
MPTherionPointSymbol? getTherionPointSymbol({
  required MPTherionSymbolSet set,
  required THPointType pointType,
  required String subtype,
}) {
  // 1. The user's chosen set overrides thTrans.mp's default wherever it
  //    actually defines this symbol — but NOT for `uis` itself: selecting
  //    "Therion UIS" means "exactly thTrans.mp," full stop, no override
  //    layer (per the user's explicit direction in §1.3).
  if (set != MPTherionSymbolSet.uis) {
    final MPTherionPointSymbol? chosenSetSymbol =
        _setSpecificPointSymbolLookups[set]?.call(pointType: pointType, subtype: subtype);
    if (chosenSetSymbol != null) return chosenSetSymbol;
  }

  // 2. thTrans.mp's real default for this symbol, if we know one and have
  //    it implemented.
  final MPTherionSymbolSet? defaultSet =
      getTherionDefaultPointSet(pointType: pointType, subtype: subtype);
  if (defaultSet != null) {
    final MPTherionPointSymbol? defaultSetSymbol = defaultSet == MPTherionSymbolSet.uis
        ? getTherionUISPointSymbol(pointType: pointType, subtype: subtype)
        : _setSpecificPointSymbolLookups[defaultSet]?.call(pointType: pointType, subtype: subtype);
    if (defaultSetSymbol != null) return defaultSetSymbol;
  }

  // 3. UIS as a last-resort catch-all: either thTrans.mp has no opinion
  //    (§2.5) or its assigned set isn't ported in Mapiah yet. UIS is
  //    Mapiah's only 100%-complete set, so it's the best "at least draw
  //    something reasonably shaped" fallback available.
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
four-step shape, substituting their own per-domain types.

### 4.3 Worked examples

- **`survey -subtype surface`, set = `therionUIS`**: step 1 skipped (`uis`
  case). Step 2: `getTherionDefaultLineSet` → SKBB; SKBB has
  `MPSurveySurfaceSKBBLineDecorator` → used. **Matches real Therion.**
  (Today: falls to UIS, which has nothing → Mapiah placeholder. **Bug.**)
- **`survey -subtype surface`, set = `therionSKBB`**: step 1: SKBB defines
  it → used directly (same result, different path).
- **`survey -subtype surface`, set = `therionAUT`**: step 1: AUT has no
  survey-surface macro → skip. Step 2: thTrans default is SKBB, which is
  ported → used. Picking AUT still renders this symbol correctly, just not
  "in AUT's style" (because AUT has no such style to begin with).
- **`wall -subtype clay`, set = `therionAUT`**: step 1: AUT has no
  `l_wall_clay_AUT` → skip. Step 2: thTrans default SKBB → used
  (`MPWallClaySKBBLineDecorator`).
- **`wall -subtype pit`, set = `therionUIS`**: step 1 skipped. Step 2:
  thTrans default is AUT, which Mapiah hasn't ported yet (no
  `l_wall_pit_AUT` decorator exists) → step 2 finds nothing. Step 3: UIS has
  no `l_wall_pit_UIS` either (confirm against Therion source when this gets
  implemented) → Mapiah placeholder, same as today. No regression, and this
  is the honest state until AUT's wall-pit macro is ported.
- **`area clay`, set = `therionUIS`**: step 2: thTrans default SKBB, ported
  → `a_clay_SKBB`'s tile is used even under "Therion UIS." This is the
  headline behavior change: **the "Therion UIS" method will visibly use
  SKBB-authored tiles/decorators for the ~40% of symbols `thTrans.mp`
  assigns away from UIS**, once those are ported.

### 4.4 Settings: `isEnabled` gating reconsidered

[The earlier change hiding `AUT`/`SBE`/`BCRA`/`NSS`/`NZSS`/`ASF` from the
settings dropdown](../../CHANGELOG.md) reasoned that picking one "rendered
exactly like UIS with no visible effect." Under the new dispatch, that's
still true in practice today (none of those six sets has *any* ported
content, so step 1 always misses and every symbol falls through to
thTrans-default/UIS exactly as it would under `therionUIS` itself) — so
**no immediate change needed to `mp_setting_type.dart`'s `enabledPredicate`
or the hidden sets**. The reasoning in its comment should be updated,
though: "picking one has no visible effect" is now true because thTrans's
default dispatch already applies under every set equally, not because the
set falls back to UIS specifically. Re-enable each set once it has at least
one ported symbol whose set-specific decorator differs from what thTrans's
default would already produce.

---

## 5. Migration plan

This is mechanical but touches every existing set-specific doc comment that
currently claims "falls back to UIS" as if that were Therion's real
behavior (at least `mp_therion_skbb_line_map.dart`,
`mp_therion_symbol_registry.dart`, `mp_therion_line_registry.dart`,
`mp_therion_area_pattern_registry.dart`, and the Phase 4 plan's own
"Current State"/rationale sections).

1. **Transcribe `thTrans.mp` into the three lookup tables** (§4.1), each as
   a straightforward `switch`/`Map` — no clever logic, just data entry
   double-checked against §2's tables (which were themselves transcribed
   directly from the live `thTrans.mp`, not from memory).
2. **Rewrite the three registries** to the four-step chain in §4.2,
   preserving their existing public signatures (no caller changes needed
   outside these three files).
3. **Update doc comments** repo-wide that currently assert "X falls back to
   UIS, matching Therion" — correct to "X falls back to `thTrans.mp`'s
   default (§ref), which for this symbol happens to be UIS/SKBB/etc."
4. **Add regression tests** per registry asserting, for a representative
   sample of §2's entries (at minimum every symbol already ported under
   SKBB, plus a few UIS-default and AUT/SBE/NSS/ASF-default-but-unported
   ones), that `getTherionXSymbol(set: uis, ...)` resolves to the correct
   `thTrans.mp`-mandated result — not just "the same as before."
5. **No changes needed** to individual `MPLineDecorator`/point-draw-method/
   area-tile implementations themselves — every symbol already ported
   (Phase 0–4B) keeps its existing decorator class; only *when it gets
   selected* changes.
6. **Settings**: no code change per §4.4, just a comment correction.

### 5.1 Suggested phase split

Given the amount of doc-comment churn and the value of getting the dispatch
core right before touching every call site's prose, this likely wants to be
its own phase (call it **Phase 5**) rather than folded into Phase 4B's
remaining SKBB work:

- **Phase 5a**: the three lookup tables + registry rewrite + core tests
  (§4.1, §4.2, §5.4). This alone fixes the actual behavior bug.
- **Phase 5b**: doc-comment sweep across already-landed SKBB files (§5.3),
  correcting the "falls back to UIS" framing to reference `thTrans.mp`
  instead, file by file.
- **Phase 5c** (optional, lower priority): audit symbols *not* yet covered
  by any set-specific decorator against §2's tables to prioritize what to
  port next by "how far current UIS rendering diverges from `thTrans.mp`'s
  real default" rather than by symbol-set groupings — e.g. `p_altar`
  (SBE-only, currently shows the Mapiah placeholder under every visualization
  method including UIS) is a bigger real-world fidelity gap than another UIS
  wall subtype would be, since Therion never renders `p_altar` any other way.

---

## 6. Decisions

1. **Naming**: the `therionUIS` enum value / settings label stays `UIS`.
   Only the underlying dispatch behavior changes (§4); no user-facing
   rename.
2. **Scope for this first pass**: Phase 5a covers all three domains —
   points, lines, *and* areas — in one pass, not just the line registry.
   §7 below reflects this as a single combined task rather than a
   per-domain split.
3. **§2.5 (types with no `thTrans.mp` entry)**: confirmed. Every symbol
   already ported this session — `wall -subtype
   sand/pebbles/clay/debris/blocks/ice/unsurveyed`, `waterFlow -subtype
   conjectural/intermittent`, `ropeLadder`, `viaFerrata`, and `survey
   -subtype cave/surface` — appears in §2.2, so all of it is covered by the
   new dispatch with no special-casing needed. Any other in-flight or
   planned symbol work should still be checked against §2 before assuming
   today's UIS-terminal behavior is correct for it.

## 7. Implementation checklist (Phase 5a)

Single pass, all three domains together:

1. Add `lib/src/painters/therion_common/mp_therion_default_symbol_set.dart`
   with `getTherionDefaultPointSet`/`getTherionDefaultLineSet`/
   `getTherionDefaultAreaSet` (§4.1), transcribed from §2.1–§2.3.
2. Rewrite `getTherionPointSymbol` (`mp_therion_symbol_registry.dart`),
   `getTherionLineDefinition` (`mp_therion_line_registry.dart`), and
   `getTherionAreaPatternDefinition` (`mp_therion_area_pattern_registry.dart`)
   to the four-step chain in §4.2, keeping their existing public signatures.
3. Add regression tests per registry per §5's item 4 (sample of SKBB-ported,
   UIS-default, and AUT/SBE/NSS/ASF-default-but-unported symbols each).
4. Sweep doc comments per §5's item 3 (start with the files this session
   already touched: `mp_therion_skbb_line_map.dart`,
   `mp_therion_symbol_registry.dart`, `mp_therion_line_registry.dart`,
   `mp_therion_area_pattern_registry.dart`, and the Phase 4 plan's "Current
   State" wording).
5. Update `mp_setting_type.dart`'s `enabledPredicate` comment per §4.4 (no
   behavior change, just correcting the stated reasoning).
6. Run the full test suite (not just touched files — see the
   `mpTherionLineColors` regression this session caught by doing exactly
   that) before considering Phase 5a done.
