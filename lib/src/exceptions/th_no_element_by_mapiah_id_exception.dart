// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THNoElementByMPIDException extends THBaseException {
  THNoElementByMPIDException(String filename, int index)
    : super("No element with index '$index' in file '$filename'.");
}
