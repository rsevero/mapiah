// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THDuplicateIDException extends THBaseException {
  THDuplicateIDException(String duplicateID, String filename)
    : super("Duplicate ID '$duplicateID' in file '$filename'");
}
