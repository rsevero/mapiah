// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THNoElementByIDException extends THBaseException {
  THNoElementByIDException(String elementType, String id, String filename)
    : super(
        "No element of type '$elementType' with ID '$id' in file '$filename'",
      );
}
