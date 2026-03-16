// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THConvertFromStringException extends THBaseException {
  final String objectNameToCreate;
  final String originalString;

  THConvertFromStringException(this.objectNameToCreate, this.originalString)
    : super(
        "Creation of a '$objectNameToCreate' from string '$originalString' failed.",
      );
}
