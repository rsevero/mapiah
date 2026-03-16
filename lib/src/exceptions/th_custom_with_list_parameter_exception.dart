// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THCustomWithListParameterException extends THBaseException {
  final List<dynamic> aList;

  THCustomWithListParameterException(String message, this.aList)
    : super(_buildMessage(message, aList));

  static String _buildMessage(String message, List<dynamic> aList) {
    String asString = '$message\nList:\n';

    for (final item in aList) {
      asString += "$item\n";
    }
    asString += '\n';

    return asString;
  }
}
