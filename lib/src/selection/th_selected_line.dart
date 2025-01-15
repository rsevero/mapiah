import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/selection/th_selected_element.dart';

class THSelectedLine extends THSelectedElement {
  final THLine line;
  late final THLine originalLine;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
      LinkedHashMap<int, THLineSegment>();

  THSelectedLine({required this.line}) {
    final Iterable<int> lineSegmentMapiahIDs = line.childrenMapiahID;
    final THFile thFile = line.thFile;
    for (final int mapiahID in lineSegmentMapiahIDs) {
      final THElement element = thFile.elementByMapiahID(mapiahID);

      if (element is! THLineSegment) {
        continue;
      }

      final LinkedHashMap<String, THCommandOption> optionsMap =
          LinkedHashMap<String, THCommandOption>();

      element.optionsMap.forEach((key, value) {
        optionsMap[key] = value.copyWith();
      });

      originalLineSegmentsMap[element.mapiahID] = element.copyWith(
        optionsMap: optionsMap,
      );
    }

    final LinkedHashMap<String, THCommandOption> optionsMap =
        LinkedHashMap<String, THCommandOption>();
    line.optionsMap.forEach((key, value) {
      optionsMap[key] = value.copyWith();
    });

    originalLine = line.copyWith(optionsMap: optionsMap);
    assert(!identical(line, originalLine));
  }

  @override
  THLine get element => line;

  @override
  THLine get originalElement => originalLine;
}
