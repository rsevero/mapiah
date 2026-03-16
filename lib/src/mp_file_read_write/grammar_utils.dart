// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:petitparser/petitparser.dart';

/// Shared grammar utilities used by multiple grammar definitions.

class GrammarUtils {
  /// Case-insensitive string matcher.
  static Parser stringIgnoreCase(String s) {
    return string(s, ignoreCase: true);
  }
}
