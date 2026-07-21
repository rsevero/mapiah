// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Mirrors Therion's five `\th*size` label font sizes as multipliers of the
/// base symbol unit `u` ([MPSymbolUnit]). Phase 2.5 always resolves
/// [THLabelSize.normal] since `<size:S>` tag parsing is not implemented yet;
/// the enum exists so a later phase can wire that parsing up without
/// touching call sites.
enum THLabelSize {
  tiny(0.6),
  small(0.8),
  normal(1.0),
  large(1.4),
  huge(2.0);

  const THLabelSize(this.multiplier);

  final double multiplier;
}
