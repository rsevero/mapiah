// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
enum MPPLAType { point, line, area }

class MPPLATypeSubtype {
  const MPPLATypeSubtype({
    required this.pla,
    required this.type,
    required this.subtype,
  });

  final MPPLAType pla;

  final String type;

  final String subtype;

  bool get hasSubtype {
    return subtype.trim().isNotEmpty;
  }
}
