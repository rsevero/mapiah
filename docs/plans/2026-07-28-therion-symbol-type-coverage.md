<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Therion Symbol Type Coverage

**Created:** 2026-07-28

This inventory covers every user-facing point, line, and area type token in
Therion's `thtt_point_types`, `thtt_line_types`, and `thtt_area_types` tables.
It excludes only the internal `UNKNOWN` sentinels. The `pitch` line token is
included because Therion accepts it as an alias of `pit`. The parent `wall`
line-type row is followed by one detail row for each of its 15 accepted
subtypes.

The symbol-set column lists sets that directly define a MetaPost macro for the
type, including `let` aliases. `Built-in label system` means that Therion
renders the type through its C++/`p_label` path rather than a set-specific
point macro. Therion calls its Austrian set `AUT`; there is no `AUS` set.

In the Mapiah column, **Yes** means that the `TherionUIS` visualization method
has a Therion-oriented symbol, decorator, pattern, label renderer, or an
intentionally shared base stroke for that type. **No (placeholder)** means
that selecting `TherionUIS` still leaves the ordinary Mapiah placeholder.
Subtype limitations are stated in the cell.

Complexity is transcribed from
[`2026-07-15-therion-symbol-rendering-roadmap.md`](2026-07-15-therion-symbol-rendering-roadmap.md).
`Not classified` means the roadmap does not assign the type to its
simple/medium/complex inventory; it is not an assessment of the symbol itself.

## Point types

| Therion type | Symbol sets defining it | Roadmap complexity | Mapiah `TherionUIS` representation | In showcase |
| --- | --- | --- | --- | --- |
| `air-draught` | UIS, AUT | complex | Yes | Yes |
| `altar` | SBE | not classified | No (placeholder) | No |
| `altitude` | built-in label system | not classified (text) | Yes | Yes |
| `anastomosis` | UIS | medium | Yes | Yes |
| `anchor` | SKBB | not classified | No (placeholder) | No |
| `aragonite` | NSS | not classified | No (placeholder) | No |
| `archeo-excavation` | SBE | not classified | No (placeholder) | No |
| `archeo-material` | UIS | medium | Yes | Yes |
| `audio` | SBE | not classified | No (placeholder) | No |
| `bat` | SBE | not classified | No (placeholder) | No |
| `bedrock` | ASF | not classified | No (placeholder) | No |
| `blocks` | UIS, AUT | complex | Yes | Yes |
| `bones` | SBE | not classified | No (placeholder) | No |
| `borehole` | SKBB | not classified | No (placeholder) | No |
| `breakdown-choke` | NSS, AUT | not classified | No (placeholder) | No |
| `bridge` | SKBB | not classified | No (placeholder) | No |
| `camp` | UIS, SKBB | simple[^camp-complexity] | Yes | Yes |
| `cave-pearl` | SKBB | not classified | No (placeholder) | No |
| `clay` | SKBB, AUT | not classified | No (placeholder) | No |
| `clay-choke` | AUT | not classified | No (placeholder) | No |
| `clay-tree` | AUT | not classified | No (placeholder) | No |
| `continuation` | UIS | simple | Yes | Yes |
| `crystal` | UIS, AUT | simple | Yes | Yes |
| `curtain` | UIS | medium | Yes | Yes |
| `curtains` | UIS | not classified | No (placeholder) | Yes |
| `danger` | SBE | not classified | No (placeholder) | No |
| `date` | built-in label system | not classified (text) | Yes | Yes |
| `debris` | UIS, AUT | simple | No (placeholder) | Yes |
| `dig` | UIS | simple | Yes | Yes |
| `dimensions` | built-in label system | not classified (text) | Yes | Yes |
| `disc-pillar` | UIS | not classified | No (placeholder) | Yes |
| `disc-pillars` | UIS | not classified | No (placeholder) | Yes |
| `disc-stalactite` | UIS | not classified | No (placeholder) | Yes |
| `disc-stalactites` | UIS | not classified | No (placeholder) | Yes |
| `disc-stalagmite` | UIS | not classified | No (placeholder) | Yes |
| `disc-stalagmites` | UIS | not classified | Yes | Yes |
| `disk` | UIS | medium | Yes | Yes |
| `electric-light` | SBE | not classified | No (placeholder) | No |
| `entrance` | UIS, AUT | simple | Yes | Yes |
| `ex-voto` | SBE | not classified | No (placeholder) | No |
| `extra` | none (C++-handled) | not classified | No (placeholder) | No |
| `fixed-ladder` | SKBB | not classified | No (placeholder) | No |
| `flowstone` | UIS | simple | Yes | Yes |
| `flowstone-choke` | NSS | not classified | No (placeholder) | No |
| `flute` | UIS | simple | Yes | Yes |
| `gate` | SBE | not classified | No (placeholder) | No |
| `gradient` | UIS, BCRA, NSS, SKBB, AUT | medium | Yes | Yes |
| `guano` | UIS | medium | Yes | Yes |
| `gypsum` | NSS | not classified | No (placeholder) | No |
| `gypsum-flower` | NSS | not classified | No (placeholder) | No |
| `handrail` | SKBB | not classified | No (placeholder) | No |
| `height` | built-in label system | not classified (text) | Yes | Yes |
| `helictite` | UIS | medium | Yes | Yes |
| `helictites` | UIS | not classified | No (placeholder) | Yes |
| `human-bones` | SBE | not classified | No (placeholder) | No |
| `ice` | UIS, AUT | simple | Yes | Yes |
| `ice-pillar` | AUT | not classified | No (placeholder) | No |
| `ice-stalactite` | AUT | not classified | No (placeholder) | No |
| `ice-stalagmite` | AUT | not classified | No (placeholder) | No |
| `karren` | UIS | simple | Yes | Yes |
| `label` | built-in label system | not classified (text) | Yes | Yes |
| `low-end` | UIS, NSS | simple | Yes | Yes |
| `map-connection` | none (C++-handled) | not classified | No (placeholder) | No |
| `masonry` | SBE | not classified | No (placeholder) | No |
| `moonmilk` | UIS | medium | Yes | Yes |
| `mud` | SBE | not classified | No (placeholder) | No |
| `mudcrack` | SBE | not classified | No (placeholder) | No |
| `nameplate` | SBE | not classified | No (placeholder) | No |
| `narrow-end` | UIS | simple | Yes | Yes |
| `no-equipment` | SKBB | not classified | No (placeholder) | No |
| `no-wheelchair` | SBE | not classified | No (placeholder) | No |
| `paleo-material` | UIS | medium | Yes | Yes |
| `passage-height` | built-in label system | not classified (text) | Yes | Yes |
| `pebbles` | UIS, AUT | medium | Yes | Yes |
| `pendant` | SBE | not classified | No (placeholder) | No |
| `photo` | SBE | not classified | No (placeholder) | No |
| `pillar` | UIS, AUT | simple | Yes | Yes |
| `pillar-with-curtains` | UIS | not classified | No (placeholder) | Yes |
| `pillars` | UIS | complex | Yes | Yes |
| `pillars-with-curtains` | UIS | not classified | No (placeholder) | Yes |
| `popcorn` | UIS | medium | Yes | Yes |
| `raft` | NSS | not classified | No (placeholder) | No |
| `raft-cone` | NSS | not classified | No (placeholder) | No |
| `remark` | built-in label system | not classified (text) | Yes | Yes |
| `rimstone-dam` | ASF | not classified | No (placeholder) | No |
| `rimstone-pool` | ASF | not classified | No (placeholder) | No |
| `root` | ASF | not classified | No (placeholder) | No |
| `rope` | SKBB | not classified | No (placeholder) | No |
| `rope-ladder` | SKBB | not classified | No (placeholder) | No |
| `sand` | UIS, AUT | simple | Yes | Yes |
| `scallop` | UIS | medium | Yes | Yes |
| `section` | none | not classified | No (placeholder) | No |
| `seed-germination` | SBE | not classified | No (placeholder) | No |
| `sink` | SKBB, AUT | not classified | No (placeholder) | No |
| `snow` | SKBB | not classified | No (placeholder) | No |
| `soda-straw` | UIS | simple | Yes | Yes |
| `spring` | SKBB, AUT | not classified | No (placeholder) | No |
| `stalactite` | UIS, AUT | simple | Yes | Yes |
| `stalactite-stalagmite` | UIS | not classified | No (placeholder) | Yes |
| `stalactites` | UIS | complex | Yes | Yes |
| `stalactites-stalagmites` | UIS | not classified | No (placeholder) | Yes |
| `stalagmite` | UIS, AUT | simple | Yes | Yes |
| `stalagmites` | UIS | complex | Yes | Yes |
| `station` | ASF, SKBB, AUT | not classified (text)[^station-labels] | No (placeholder) | No |
| `station-name` | built-in label system | not classified (text)[^station-labels] | No (placeholder) | No |
| `steps` | SKBB | not classified | No (placeholder) | No |
| `traverse` | SKBB | not classified | No (placeholder) | No |
| `tree-trunk` | SBE | not classified | No (placeholder) | No |
| `u` | universal/custom (`p_u`) | not classified | No (placeholder) | No |
| `vegetable-debris` | ASF | not classified | No (placeholder) | No |
| `via-ferrata` | SKBB | not classified | No (placeholder) | No |
| `volcano` | SBE | not classified | No (placeholder) | No |
| `walkway` | SBE | not classified | No (placeholder) | No |
| `wall-calcite` | UIS | simple | Yes | Yes |
| `water` | UIS, AUT | complex | Yes | Yes |
| `water-drip` | SBE | not classified | No (placeholder) | No |
| `water-flow` | UIS | medium | Yes | Yes |
| `wheelchair` | SBE | not classified | No (placeholder) | No |

## Line types

| Therion type | Symbol sets defining it | Roadmap complexity | Mapiah `TherionUIS` representation | In showcase |
| --- | --- | --- | --- | --- |
| `abyss-entrance` | SBE | not classified | No (placeholder) | No |
| `arrow` | SKBB | not classified | No (placeholder) | No |
| `border` | SKBB | not classified | No (placeholder) | Yes[^showcase-helpers] |
| `ceiling-meander` | SKBB, UIS, NZSS, AUT | complex | Yes | Yes |
| `ceiling-step` | SKBB, UIS, NZSS, AUT | complex | Yes | Yes |
| `chimney` | SKBB, UIS, NZSS | complex | Yes | Yes |
| `contour` | UIS, SKBB, AUT | complex | Yes | Yes |
| `dripline` | SBE | not classified | No (placeholder) | No |
| `fault` | SBE | not classified | No (placeholder) | No |
| `fixed-ladder` | SKBB | not classified | No (placeholder) | No |
| `floor-meander` | SKBB | not classified | No (placeholder) | No |
| `floor-step` | UIS, AUT | complex | Yes | Yes |
| `flowstone` | UIS, AUT | complex | Yes | Yes |
| `gradient` | UIS, BCRA | simple | Yes | Yes |
| `handrail` | SKBB | not classified | No (placeholder) | No |
| `joint` | SBE | not classified | No (placeholder) | No |
| `label` | built-in label system | not classified | No (placeholder) | No |
| `low-ceiling` | SBE | not classified | No (placeholder) | No |
| `map-connection` | SKBB | not classified | No (placeholder) | No |
| `moonmilk` | UIS | complex | Yes | Yes |
| `overhang` | SKBB, AUT | not classified | No (placeholder) | No |
| `pit` | UIS, AUT | complex | Yes | Yes |
| `pit-chimney` | SBE | not classified | No (placeholder) | No |
| `pitch` | UIS (alias of `pit`) | complex | Yes | Yes |
| `rimstone-dam` | SBE | not classified | No (placeholder) | No |
| `rimstone-pool` | SBE | not classified | No (placeholder) | No |
| `rock-border` | UIS | simple | Yes (shared base stroke) | Yes |
| `rock-edge` | UIS | simple | Yes (shared base stroke) | Yes |
| `rope` | SKBB | not classified | No (placeholder) | No |
| `rope-ladder` | SKBB | not classified | No (placeholder) | No |
| `section` | SKBB | not classified | No (placeholder) | No |
| `slope` | SKBB, BCRA | not classified | No (placeholder) | No |
| `steps` | SKBB | not classified | No (placeholder) | No |
| `survey` | SKBB, UIS, AUT | medium (cave subtype) | Yes (cave subtype) | Yes |
| `u` | universal/custom (`l_u`) | not classified | No (placeholder) | No |
| `via-ferrata` | SKBB | not classified | No (placeholder) | No |
| `walkway` | SBE | not classified | No (placeholder) | No |
| `wall` | UIS, SKBB, NZSS, AUT | varies by subtype | Partial (3 of 15)[^wall-subtypes] | Partial (3 of 15)[^showcase-helpers] |
| `wall:bedrock` | UIS | simple | Yes (shared base stroke) | Yes |
| `wall:blocks` | SKBB, AUT | not classified | No (placeholder) | No |
| `wall:clay` | SKBB, AUT | not classified | No (placeholder) | No |
| `wall:debris` | SKBB, AUT | not classified | No (placeholder) | No |
| `wall:flowstone` | AUT | not classified | No (placeholder) | No |
| `wall:ice` | SKBB, AUT | not classified | No (placeholder) | No |
| `wall:invisible` | universal (`l_invisible`) | not classified | No (placeholder) | No |
| `wall:moonmilk` | AUT | not classified | No (placeholder) | No |
| `wall:overlying` | AUT | not classified | No (placeholder) | No |
| `wall:pebbles` | SKBB, AUT | not classified | No (placeholder) | No |
| `wall:pit` | AUT | not classified | No (placeholder) | No |
| `wall:presumed` | UIS, NZSS | simple | Yes (shared base stroke) | Yes |
| `wall:sand` | SKBB, AUT | not classified | No (placeholder) | No |
| `wall:underlying` | UIS, AUT | simple | Yes (shared base stroke) | Yes |
| `wall:unsurveyed` | SKBB | not classified | No (placeholder) | No |
| `water-flow` | UIS, SKBB | complex | Yes (permanent subtype) | Yes |

## Area types

| Therion type | Symbol sets defining it | Roadmap complexity | Mapiah `TherionUIS` representation | In showcase |
| --- | --- | --- | --- | --- |
| `bedrock` | SKBB | not classified | No (placeholder) | No |
| `blocks` | SKBB, AUT | not classified (known gap) | No (placeholder) | No |
| `clay` | SKBB, AUT | not classified | No (placeholder) | No |
| `debris` | UIS, SKBB, AUT | simple | Yes | Yes |
| `dimensions` | SKBB | not classified | No (unsupported type)[^area-dimensions] | No |
| `flowstone` | ASF, AUT | simple | Yes | Yes |
| `ice` | SKBB, AUT | not classified | No (placeholder) | No |
| `moonmilk` | SKBB | simple | Yes | Yes |
| `mudcrack` | SBE | not classified | No (placeholder) | No |
| `pebbles` | SKBB, AUT | not classified | No (placeholder) | No |
| `pillar` | SBE | not classified | No (placeholder) | No |
| `pillar-with-curtains` | SBE | not classified | No (placeholder) | No |
| `sand` | UIS, AUT | complex | Yes | Yes |
| `snow` | SKBB, AUT | not classified | No (placeholder) | No |
| `stalactite` | SBE | not classified | No (placeholder) | No |
| `stalactite-stalagmite` | SBE | not classified | No (placeholder) | No |
| `stalagmite` | SBE | not classified | No (placeholder) | No |
| `sump` | UIS, SKBB, AUT | simple | Yes | Yes |
| `u` | universal/custom (`a_u`) | not classified | No (placeholder) | No |
| `water` | UIS, SKBB, AUT | simple | Yes | Yes |

[^camp-complexity]: The roadmap inventory labels `camp` as simple, while
    Phase 2 groups it with medium-complexity symbols.
[^station-labels]: Phase 2.5 lists `station` and `station-name` as implemented,
    but the current `MPLabelTextAux.resolve` switch handles neither type and
    neither has a `MPTherionPointSymbol` mapping.
[^showcase-helpers]: The showcase's `wall` is its enclosing outline and its
    `border` lines are invisible area-boundary helpers; they are still literal
    occurrences of those Therion types.
[^wall-subtypes]: The roadmap classifies the UIS `bedrock`, `underlying`, and
    `presumed` wall macros as simple. Mapiah uses its shared base-stroke
    rendering for them rather than a line decorator. The other 12 accepted
    wall subtypes still use Mapiah placeholders under `TherionUIS`.
[^area-dimensions]: Therion defines an `area dimensions` type, but
    `THAreaType` has no `dimensions` member, so Mapiah parses it as unknown.
