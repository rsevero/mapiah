// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
class TH2FileAux {
  static int countCharOccurrences(String text, String charToCount) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == charToCount) {
        count++;
      }
    }
    return count;
  }
}
