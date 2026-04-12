// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';

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

  String get typeSubtypeID {
    return '$type$mpPLATypeSubtypeSeparator$subtype';
  }

  bool get hasSubtype {
    return subtype.trim().isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return (other is MPPLATypeSubtype) &&
        (other.pla == pla) &&
        (other.type == type) &&
        (other.subtype == subtype);
  }

  @override
  int get hashCode {
    return Object.hash(pla, type, subtype);
  }
}
