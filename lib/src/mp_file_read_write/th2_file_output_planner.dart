// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';

/// The order in which the writer writes a file's top-level children.
class TH2FileOutputPlan {
  /// Whether the writer writes an `encoding` line the file has no element for.
  final bool synthesizeEncoding;

  /// Every top-level child exactly once, in output order.
  final List<int> orderedChildMPIDs;

  /// The settings moved up into the settings section, in output order.
  final List<int> relocatedSettingMPIDs;

  const TH2FileOutputPlan({
    required this.synthesizeEncoding,
    required this.orderedChildMPIDs,
    required this.relocatedSettingMPIDs,
  });
}

/// Plans the settings section: the run of settings, comments, empty lines and
/// multiline comments right after the `encoding` line. Settings found later in
/// the file move up into it, before its trailing empty lines. The section never
/// ends in a comment, so a comment right before the first drawing element stays
/// with that element. Pure: it reads element types only.
class TH2FileOutputPlanner {
  static TH2FileOutputPlan plan(List<(int, THElementType)> children) {
    final int childrenCount = children.length;
    final bool synthesizeEncoding =
        children.isEmpty || (children.first.$2 != THElementType.encoding);
    final int start = synthesizeEncoding ? 0 : 1;

    int runEnd = start;

    while ((runEnd < childrenCount) && _isSectionElement(children[runEnd].$2)) {
      runEnd++;
    }

    int sectionEnd = runEnd;

    while ((sectionEnd > start) && _isComment(children[sectionEnd - 1].$2)) {
      sectionEnd--;
    }

    int insertAt = sectionEnd;

    while ((insertAt > start) &&
        (children[insertAt - 1].$2 == THElementType.emptyLine)) {
      insertAt--;
    }

    final List<int> relocatedSettingMPIDs = <int>[];
    final List<int> tailMPIDs = <int>[];

    for (int index = insertAt; index < childrenCount; index++) {
      final (int mpID, THElementType type) = children[index];

      if ((index >= sectionEnd) && _isSetting(type)) {
        relocatedSettingMPIDs.add(mpID);
      } else {
        tailMPIDs.add(mpID);
      }
    }

    final List<int> orderedChildMPIDs = <int>[
      for (int index = 0; index < insertAt; index++) children[index].$1,
      ...relocatedSettingMPIDs,
      ...tailMPIDs,
    ];

    return TH2FileOutputPlan(
      synthesizeEncoding: synthesizeEncoding,
      orderedChildMPIDs: orderedChildMPIDs,
      relocatedSettingMPIDs: relocatedSettingMPIDs,
    );
  }

  static bool _isSetting(THElementType type) {
    return TH2FileWriter.configBlockElementTypes.contains(type);
  }

  static bool _isComment(THElementType type) {
    return (type == THElementType.comment) ||
        (type == THElementType.multilineComment);
  }

  static bool _isSectionElement(THElementType type) {
    return _isSetting(type) ||
        _isComment(type) ||
        (type == THElementType.emptyLine);
  }
}
