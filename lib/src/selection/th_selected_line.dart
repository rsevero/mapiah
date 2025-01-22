import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/selection/th_selected_element.dart';

class THSelectedLine extends THSelectedElement {
  THLine modifiedLine;
  late THLine originalLine;
  final LinkedHashMap<int, THLineSegment> originalLineSegmentsMap =
      LinkedHashMap<int, THLineSegment>();

  THSelectedLine({required THFile thFile, required this.modifiedLine}) {
    final Iterable<int> lineSegmentMapiahIDs = modifiedLine.childrenMapiahID;

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

    final List<int> clonedChildrenMapiahIDs =
        modifiedLine.childrenMapiahID.toList();

    final LinkedHashMap<String, THCommandOption> clonedOptionsMap =
        LinkedHashMap<String, THCommandOption>();
    modifiedLine.optionsMap.forEach((key, value) {
      clonedOptionsMap[key] = value.copyWith();
    });

    originalLine = modifiedLine.copyWith(
      childrenMapiahID: clonedChildrenMapiahIDs,
      optionsMap: clonedOptionsMap,
    );
  }

  @override
  THLine get modifiedElement => modifiedLine;

  @override
  THLine get originalElement => originalLine;

  @override
  set modifiedElement(THElement element) {
    if (element is! THLine) {
      throw ArgumentError(
          'The element is should be a THLine in modifiedElement of THSelectedLine.');
    }

    modifiedLine = element;
  }

  @override
  set originalElement(THElement element) {
    if (element is! THLine) {
      throw ArgumentError(
          'The element is should be a THLine in modifiedElement of THSelectedLine.');
    }

    originalLine = element;
  }
}
