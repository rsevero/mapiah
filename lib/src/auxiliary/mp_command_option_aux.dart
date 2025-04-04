import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

class MPCommandOptionAux {
  static const List<THCommandOptionType> _supportAreaOptionsForAll = [
    THCommandOptionType.clip,
    THCommandOptionType.context,
    THCommandOptionType.id,
    THCommandOptionType.place,
    THCommandOptionType.visibility,
  ];

  static const List<THCommandOptionType> _supportLineSegmentsOptionsForAll = [
    THCommandOptionType.adjust,
    THCommandOptionType.altitude,
    THCommandOptionType.linePointGradient,
    THCommandOptionType.linePointDirection,
    THCommandOptionType.lSize,
    THCommandOptionType.mark,
    THCommandOptionType.orientation,
    THCommandOptionType.smooth,
  ];

  static const List<THCommandOptionType> _supportLineOptionsForAll = [
    THCommandOptionType.clip,
    THCommandOptionType.close,
    THCommandOptionType.context,
    THCommandOptionType.id,
    THCommandOptionType.outline,
    THCommandOptionType.place,
    THCommandOptionType.reverse,
    THCommandOptionType.visibility,
  ];

  static const Map<THLineType, List<THCommandOptionType>>
      _supportedLineOptions = {
    THLineType.arrow: [
      THCommandOptionType.head,
    ],
    THLineType.border: [
      THCommandOptionType.subtype,
    ],
    THLineType.contour: [
      THCommandOptionType.lineGradient,
    ],
    THLineType.label: [
      THCommandOptionType.lineScale,
      THCommandOptionType.text,
    ],
    THLineType.pit: [
      THCommandOptionType.lineHeight,
    ],
    THLineType.rope: [
      THCommandOptionType.anchors,
      THCommandOptionType.rebelays,
    ],
    THLineType.section: [
      THCommandOptionType.lineDirection,
    ],
    THLineType.slope: [
      THCommandOptionType.border,
    ],
    THLineType.survey: [
      THCommandOptionType.subtype,
    ],
    THLineType.u: [
      THCommandOptionType.subtype,
    ],
    THLineType.wall: [
      THCommandOptionType.altitude,
      THCommandOptionType.lineHeight,
      THCommandOptionType.subtype,
    ],
    THLineType.waterFlow: [
      THCommandOptionType.subtype,
    ],
  };

  static const List<THCommandOptionType> _supportPointOptionsForAll = [
    THCommandOptionType.align,
    THCommandOptionType.clip,
    THCommandOptionType.context,
    THCommandOptionType.id,
    THCommandOptionType.place,
    THCommandOptionType.orientation,
    THCommandOptionType.pointScale,
    THCommandOptionType.visibility,
    THCommandOptionType.dimensionsValue,
  ];

  static const Map<THPointType, List<THCommandOptionType>>
      _supportedPointOptions = {
    THPointType.airDraught: [
      THCommandOptionType.subtype,
    ],
    THPointType.altitude: [
      THCommandOptionType.altitudeValue,
    ],
    THPointType.continuation: [
      THCommandOptionType.explored,
      THCommandOptionType.text,
    ],
    THPointType.date: [
      THCommandOptionType.dateValue,
    ],
    THPointType.dimensions: [
      THCommandOptionType.dimensionsValue,
    ],
    THPointType.extra: [
      THCommandOptionType.dist,
      THCommandOptionType.from,
    ],
    THPointType.height: [
      THCommandOptionType.pointHeightValue,
    ],
    THPointType.label: [
      THCommandOptionType.text,
    ],
    THPointType.passageHeight: [
      THCommandOptionType.passageHeightValue,
    ],
    THPointType.remark: [
      THCommandOptionType.text,
    ],
    THPointType.section: [
      THCommandOptionType.scrap,
    ],
    THPointType.station: [
      THCommandOptionType.extend,
      THCommandOptionType.name,
      THCommandOptionType.subtype,
    ],
    THPointType.u: [
      THCommandOptionType.subtype,
    ],
    THPointType.waterFlow: [
      THCommandOptionType.subtype,
    ],
  };

  static const List<THCommandOptionType> _supportScrapOptionsForAll = [
    THCommandOptionType.author,
    THCommandOptionType.copyright,
    THCommandOptionType.cs,
    THCommandOptionType.flip,
    THCommandOptionType.projection,
    THCommandOptionType.scrapScale,
    THCommandOptionType.sketch,
    THCommandOptionType.stationNames,
    THCommandOptionType.stations,
    THCommandOptionType.title,
    THCommandOptionType.walls,
  ];

  static List<THCommandOptionType> getSupportedOptionsForArea() {
    return _supportAreaOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForLineType(
    THLineType lineType,
  ) {
    return _supportedLineOptions.containsKey(lineType)
        ? _supportLineOptionsForAll + _supportedLineOptions[lineType]!
        : _supportLineOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForLineSegment() {
    return _supportLineSegmentsOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForPointType(
    THPointType pointType,
  ) {
    return _supportedPointOptions.containsKey(pointType)
        ? _supportPointOptionsForAll + _supportedPointOptions[pointType]!
        : _supportPointOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForScrap() {
    return _supportScrapOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForElement(
    THHasOptionsMixin element,
  ) {
    switch (element) {
      case THArea _:
        return getSupportedOptionsForArea();
      case THLine _:
        return getSupportedOptionsForLineType(element.lineType);
      case THLineSegment _:
        return getSupportedOptionsForLineSegment();
      case THPoint _:
        return getSupportedOptionsForPointType(element.pointType);
      case THScrap _:
        return getSupportedOptionsForScrap();
    }

    return [];
  }

  static List<THCommandOptionType> getSupportedOptionsForElements(
    List<THHasOptionsMixin> elements,
  ) {
    if (elements.isEmpty) {
      return [];
    }

    Set<THCommandOptionType> commonOptions =
        getSupportedOptionsForElement(elements.first).toSet();

    for (THHasOptionsMixin element in elements.skip(1)) {
      commonOptions = commonOptions
          .intersection(getSupportedOptionsForElement(element).toSet());
    }

    return commonOptions.toList();
  }

  static List<THCommandOptionType> getOrderedList(
    Iterable<THCommandOptionType> unorderedList,
  ) {
    final List<THCommandOptionType> orderedList = List.from(unorderedList);

    orderedList.sort((a, b) {
      return MPTextToUser.compareStringsUsingLocale(
        MPTextToUser.getCommandOptionType(a),
        MPTextToUser.getCommandOptionType(b),
      );
    });

    return orderedList;
  }

  static bool isSmooth(THHasOptionsMixin element) {
    return element.hasOption(THCommandOptionType.smooth) &&
        (element.optionByType(THCommandOptionType.smooth)
                    as THSmoothCommandOption)
                .choice ==
            THOptionChoicesOnOffAutoType.on;
  }

  static bool elementTypeSupportsOptionType(
    THElement element,
    THCommandOptionType optionType,
  ) {
    return element is THHasOptionsMixin
        ? getSupportedOptionsForElement(element).contains(optionType)
        : false;
  }
}
