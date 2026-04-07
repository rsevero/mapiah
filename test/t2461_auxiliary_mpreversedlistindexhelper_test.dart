// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_reversed_list_index_helper.dart';

void main() {
  group('MPReversedListIndexHelper', () {
    test('displayedToStoredIndex maps reversed positions correctly', () {
      expect(
        MPReversedListIndexHelper.displayedToStoredIndex(
          displayedIndex: 0,
          listLength: 4,
        ),
        3,
      );
      expect(
        MPReversedListIndexHelper.displayedToStoredIndex(
          displayedIndex: 1,
          listLength: 4,
        ),
        2,
      );
      expect(
        MPReversedListIndexHelper.displayedToStoredIndex(
          displayedIndex: 3,
          listLength: 4,
        ),
        0,
      );
    });

    test('finalDisplayedIndexForDropBefore accounts for removal shift', () {
      expect(
        MPReversedListIndexHelper.finalDisplayedIndexForDropBefore(
          oldDisplayedIndex: 3,
          targetDisplayedIndex: 0,
        ),
        0,
      );
      expect(
        MPReversedListIndexHelper.finalDisplayedIndexForDropBefore(
          oldDisplayedIndex: 0,
          targetDisplayedIndex: 3,
        ),
        2,
      );
      expect(
        MPReversedListIndexHelper.finalDisplayedIndexForDropBefore(
          oldDisplayedIndex: 2,
          targetDisplayedIndex: 1,
        ),
        1,
      );
    });
  });
}
