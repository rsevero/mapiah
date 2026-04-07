// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
class MPReversedListIndexHelper {
  static int displayedToStoredIndex({
    required int displayedIndex,
    required int listLength,
  }) {
    assert(displayedIndex >= 0);
    assert(displayedIndex < listLength);

    return listLength - displayedIndex - 1;
  }

  static int finalDisplayedIndexForDropBefore({
    required int oldDisplayedIndex,
    required int targetDisplayedIndex,
  }) {
    assert(oldDisplayedIndex >= 0);
    assert(targetDisplayedIndex >= 0);

    if (oldDisplayedIndex < targetDisplayedIndex) {
      return targetDisplayedIndex - 1;
    }

    return targetDisplayedIndex;
  }
}
