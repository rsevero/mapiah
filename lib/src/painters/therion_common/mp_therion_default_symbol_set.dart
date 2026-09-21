// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// `thTrans.mp`'s default `let <bare> = <bare>_<SET>;` assignment for each
/// point type/subtype Mapiah dispatches on, hand-transcribed from
/// `thTrans.mp` (see the `2026-08-25-therion-symbol-rendering-thtrans-
/// default-dispatch.md` design doc, §2.1, for the full symbol-by-symbol
/// table this mirrors). Returns null for point types/subtypes with no
/// `thTrans.mp` entry at all — not every [THPointType] is a real Therion
/// translatable name — letting the caller fall back to the UIS terminal
/// case.
MPTherionSymbolSet? getTherionDefaultPointSet({
  required THPointType pointType,
  required String subtype,
}) {
  switch (pointType) {
    case THPointType.airDraught:
    case THPointType.waterFlow:
      // p_airdraught(_winter|_summer) and p_waterflow_(paleo|permanent|
      // intermittent) are all UIS regardless of subtype.
      return MPTherionSymbolSet.uis;
    case THPointType.station:
      // p_station_fixed/natural/temporary = ASF; p_station_painted and
      // bare p_station = SKBB.
      switch (subtype) {
        case 'fixed':
        case 'natural':
        case 'temporary':
          return MPTherionSymbolSet.asf;
        default:
          return MPTherionSymbolSet.skbb;
      }
    case THPointType.altar:
    case THPointType.archeoExcavation:
    case THPointType.audio:
    case THPointType.bat:
    case THPointType.bones:
    case THPointType.danger:
    case THPointType.electricLight:
    case THPointType.exVoto:
    case THPointType.gate:
    case THPointType.humanBones:
    case THPointType.masonry:
    case THPointType.mud:
    case THPointType.mudcrack:
    case THPointType.namePlate:
    case THPointType.noWheelchair:
    case THPointType.pendant:
    case THPointType.photo:
    case THPointType.seedGermination:
    case THPointType.treeTrunk:
    case THPointType.volcano:
    case THPointType.walkway:
    case THPointType.waterDrip:
    case THPointType.wheelchair:
      return MPTherionSymbolSet.sbe;
    case THPointType.bedrock:
    case THPointType.rimstoneDam:
    case THPointType.rimstonePool:
    case THPointType.root:
    case THPointType.vegetableDebris:
      return MPTherionSymbolSet.asf;
    case THPointType.aragonite:
    case THPointType.breakdownChoke:
    case THPointType.flowstoneChoke:
    case THPointType.gypsum:
    case THPointType.gypsumFlower:
    case THPointType.raft:
    case THPointType.raftCone:
      return MPTherionSymbolSet.nss;
    case THPointType.clayChoke:
    case THPointType.clayTree:
    case THPointType.icePillar:
    case THPointType.iceStalactite:
    case THPointType.iceStalagmite:
      return MPTherionSymbolSet.aut;
    case THPointType.anchor:
    case THPointType.borehole:
    case THPointType.bridge:
    case THPointType.camp:
    case THPointType.cavePearl:
    case THPointType.clay:
    case THPointType.fixedLadder:
    case THPointType.gradient:
    case THPointType.handrail:
    case THPointType.noEquipment:
    case THPointType.rope:
    case THPointType.ropeLadder:
    case THPointType.sink:
    case THPointType.snow:
    case THPointType.spring:
    case THPointType.steps:
    case THPointType.traverse:
    case THPointType.viaFerrata:
      return MPTherionSymbolSet.skbb;
    case THPointType.anastomosis:
    case THPointType.archeoMaterial:
    case THPointType.blocks:
    case THPointType.continuation:
    case THPointType.crystal:
    case THPointType.curtain:
    case THPointType.curtains:
    case THPointType.debris:
    case THPointType.dig:
    case THPointType.discPillar:
    case THPointType.discPillars:
    case THPointType.discStalactite:
    case THPointType.discStalactites:
    case THPointType.discStalagmite:
    case THPointType.discStalagmites:
    case THPointType.disk:
    case THPointType.entrance:
    case THPointType.flowstone:
    case THPointType.flute:
    case THPointType.guano:
    case THPointType.helictite:
    case THPointType.helictites:
    case THPointType.ice:
    case THPointType.karren:
    case THPointType.lowEnd:
    case THPointType.moonmilk:
    case THPointType.narrowEnd:
    case THPointType.paleoMaterial:
    case THPointType.pebbles:
    case THPointType.pillar:
    case THPointType.pillars:
    case THPointType.pillarsWithCurtains:
    case THPointType.pillarWithCurtains:
    case THPointType.popcorn:
    case THPointType.sand:
    case THPointType.scallop:
    case THPointType.sodaStraw:
    case THPointType.stalactite:
    case THPointType.stalactites:
    case THPointType.stalactitesStalagmites:
    case THPointType.stalactiteStalagmite:
    case THPointType.stalagmite:
    case THPointType.stalagmites:
    case THPointType.wallCalcite:
    case THPointType.water:
      return MPTherionSymbolSet.uis;
    // altitude, date, dimensions, extra, height, label, mapConnection,
    // passageHeight, remark, section, stationName, u, unknown: no
    // `thTrans.mp` entry (not real Therion translatable point names).
    default:
      return null;
  }
}

/// `thTrans.mp`'s default set for each line type/subtype Mapiah dispatches
/// on (§2.2 of the design doc). Returns null for line types/subtypes with
/// no `thTrans.mp` entry, including the commented-out `l_wall_invisible`/
/// `l_border_invisible`.
MPTherionSymbolSet? getTherionDefaultLineSet({
  required THLineType lineType,
  String? subtype,
}) {
  switch (lineType) {
    case THLineType.border:
      switch (subtype) {
        case 'visible':
        case 'temporary':
        case 'presumed':
          return MPTherionSymbolSet.skbb;
        default:
          return null;
      }
    case THLineType.survey:
      // l_survey_cave (bare/`cave` subtype) and l_survey_surface are both
      // SKBB; there is no `l_survey_surface_UIS` at all.
      return MPTherionSymbolSet.skbb;
    case THLineType.wall:
      switch (subtype) {
        case 'sand':
        case 'clay':
        case 'pebbles':
        case 'debris':
        case 'blocks':
        case 'ice':
        case 'unsurveyed':
          return MPTherionSymbolSet.skbb;
        case 'bedrock':
        case 'underlying':
        case 'presumed':
          return MPTherionSymbolSet.uis;
        case 'pit':
        case 'overlying':
        case 'flowstone':
        case 'moonmilk':
          return MPTherionSymbolSet.aut;
        default:
          return null;
      }
    case THLineType.waterFlow:
      switch (subtype) {
        case 'intermittent':
        case 'conjectural':
          return MPTherionSymbolSet.skbb;
        default:
          return MPTherionSymbolSet.uis;
      }
    case THLineType.abyssEntrance:
    case THLineType.dripline:
    case THLineType.fault:
    case THLineType.joint:
    case THLineType.lowCeiling:
    case THLineType.pitChimney:
    case THLineType.rimstoneDam:
    case THLineType.rimstonePool:
    case THLineType.walkway:
      return MPTherionSymbolSet.sbe;
    case THLineType.ceilingMeander:
    case THLineType.ceilingStep:
    case THLineType.contour:
    case THLineType.floorMeander:
    case THLineType.overhang:
    case THLineType.slope:
    case THLineType.section:
    case THLineType.arrow:
    case THLineType.mapConnection:
    case THLineType.handrail:
    case THLineType.steps:
    case THLineType.fixedLadder:
    case THLineType.ropeLadder:
    case THLineType.rope:
    case THLineType.viaFerrata:
      return MPTherionSymbolSet.skbb;
    case THLineType.chimney:
    case THLineType.floorStep:
    case THLineType.pit:
    case THLineType.pitch:
    case THLineType.flowstone:
    case THLineType.moonmilk:
    case THLineType.rockBorder:
    case THLineType.rockEdge:
    case THLineType.gradient:
      return MPTherionSymbolSet.uis;
    // label, u, unknown: no `thTrans.mp` entry.
    default:
      return null;
  }
}

/// `thTrans.mp`'s default set for each area type Mapiah dispatches on
/// (§2.3 of the design doc). Returns null for area types with no
/// `thTrans.mp` entry, including `pillars`/`pillarsWithCurtains` (only the
/// singular `a_pillar`/`a_pillarwithcurtains` exist).
MPTherionSymbolSet? getTherionDefaultAreaSet(THAreaType areaType) {
  switch (areaType) {
    case THAreaType.flowstone:
      return MPTherionSymbolSet.asf;
    case THAreaType.mudcrack:
    case THAreaType.pillar:
    case THAreaType.pillarWithCurtains:
    case THAreaType.stalactite:
    case THAreaType.stalactiteStalagmite:
    case THAreaType.stalagmite:
      return MPTherionSymbolSet.sbe;
    case THAreaType.sand:
    case THAreaType.sump:
    case THAreaType.water:
      return MPTherionSymbolSet.uis;
    case THAreaType.bedrock:
    case THAreaType.blocks:
    case THAreaType.clay:
    case THAreaType.debris:
    case THAreaType.ice:
    case THAreaType.moonmilk:
    case THAreaType.pebbles:
    case THAreaType.snow:
      return MPTherionSymbolSet.skbb;
    // pillars, pillarsWithCurtains, u, unknown: no `thTrans.mp` entry.
    default:
      return null;
  }
}
