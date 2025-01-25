import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';

class MPSelectedLine extends MPSelectedElement {
  late THLine originalLineClone;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMapClone =
      LinkedHashMap<int, THLineSegment>();

  MPSelectedLine({required THFile thFile, required THLine originalLine}) {
    final Iterable<int> lineSegmentMapiahIDs = originalLine.childrenMapiahID;

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

      originalLineSegmentsMapClone[element.mapiahID] = element.copyWith(
        optionsMap: optionsMap,
      );
    }

    final List<int> childrenMapiahIDsClone =
        originalLine.childrenMapiahID.toList();

    final LinkedHashMap<String, THCommandOption> optionsMapClone =
        LinkedHashMap<String, THCommandOption>();
    originalLine.optionsMap.forEach((key, value) {
      optionsMapClone[key] = value.copyWith();
    });

    originalLineClone = originalLine.copyWith(
      childrenMapiahID: childrenMapiahIDsClone,
      optionsMap: optionsMapClone,
    );
  }

  @override
  THElement get originalElementClone => originalLineClone;
}
