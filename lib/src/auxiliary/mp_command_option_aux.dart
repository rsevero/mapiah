import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';

class MPCommandOptionAux {
  static const List<THCommandOptionType> _supportAreaOptionsForAll = [
    THCommandOptionType.attr,
    THCommandOptionType.clip,
    THCommandOptionType.context,
    THCommandOptionType.id,
    THCommandOptionType.place,
    THCommandOptionType.visibility,
  ];

  static const Map<THAreaType, List<THCommandOptionType>>
  _supportedAreaOptions = {
    THAreaType.u: [THCommandOptionType.subtype],
  };

  static const List<THCommandOptionType> _supportLineSegmentsOptionsForAll = [
    THCommandOptionType.adjust,
    THCommandOptionType.mark,
    THCommandOptionType.smooth,
  ];

  static const Map<THLineType, List<THCommandOptionType>>
  _supportLineSegmentsOptions = {
    THLineType.border: [THCommandOptionType.subtype],
    THLineType.contour: [THCommandOptionType.linePointGradient],
    THLineType.slope: [
      THCommandOptionType.lSize,
      THCommandOptionType.orientation,
    ],
    THLineType.section: [THCommandOptionType.linePointDirection],
    THLineType.survey: [THCommandOptionType.subtype],
    THLineType.wall: [
      THCommandOptionType.altitude,
      THCommandOptionType.subtype,
    ],
    THLineType.waterFlow: [THCommandOptionType.subtype],
  };

  static const List<THCommandOptionType> _supportLineOptionsForAll = [
    THCommandOptionType.attr,
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
    THLineType.arrow: [THCommandOptionType.head],
    THLineType.border: [THCommandOptionType.subtype],
    THLineType.contour: [THCommandOptionType.lineGradient],
    THLineType.label: [THCommandOptionType.plScale, THCommandOptionType.text],
    THLineType.pit: [THCommandOptionType.lineHeight],
    THLineType.rope: [
      THCommandOptionType.anchors,
      THCommandOptionType.rebelays,
    ],
    THLineType.section: [THCommandOptionType.lineDirection],
    THLineType.slope: [THCommandOptionType.border],
    THLineType.survey: [THCommandOptionType.subtype],
    THLineType.u: [THCommandOptionType.subtype],
    THLineType.wall: [
      THCommandOptionType.altitude,
      THCommandOptionType.lineHeight,
      THCommandOptionType.subtype,
    ],
    THLineType.waterFlow: [THCommandOptionType.subtype],
  };

  static const List<THCommandOptionType> _supportPointOptionsForAll = [
    THCommandOptionType.align,
    THCommandOptionType.attr,
    THCommandOptionType.clip,
    THCommandOptionType.context,
    THCommandOptionType.id,
    THCommandOptionType.place,
    THCommandOptionType.orientation,
    THCommandOptionType.plScale,
    THCommandOptionType.visibility,
  ];

  static const Map<THPointType, List<THCommandOptionType>>
  _supportedPointOptions = {
    THPointType.airDraught: [THCommandOptionType.subtype],
    THPointType.altitude: [THCommandOptionType.altitudeValue],
    THPointType.continuation: [
      THCommandOptionType.explored,
      THCommandOptionType.text,
    ],
    THPointType.date: [THCommandOptionType.dateValue],
    THPointType.dimensions: [THCommandOptionType.dimensionsValue],
    THPointType.extra: [THCommandOptionType.dist, THCommandOptionType.from],
    THPointType.height: [THCommandOptionType.pointHeightValue],
    THPointType.label: [THCommandOptionType.text],
    THPointType.passageHeight: [THCommandOptionType.passageHeightValue],
    THPointType.remark: [THCommandOptionType.text],
    THPointType.section: [THCommandOptionType.scrap],
    THPointType.station: [
      THCommandOptionType.extend,
      THCommandOptionType.name,
      THCommandOptionType.subtype,
    ],
    THPointType.u: [THCommandOptionType.subtype],
    THPointType.waterFlow: [THCommandOptionType.subtype],
  };

  static const List<THCommandOptionType> _supportScrapOptionsForAll = [
    THCommandOptionType.attr,
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

  static const Map<String, Map<String, Map<String, Object>>> supportedSubtypes =
      {
        'point': {
          'air-draught': {
            'default': 'undefined',
            'subtypes': <String>{'winter', 'summer', 'undefined'},
          },
          'station': {
            'default': 'temporary',
            'subtypes': <String>{'temporary', 'painted', 'natural', 'fixed'},
          },
          'water-flow': {
            'default': 'permanent',
            'subtypes': <String>{'permanent', 'intermittent', 'paleo'},
          },
        },
        'line': {
          'border': {
            'default': 'visible',
            'subtypes': <String>{
              'invisible',
              'presumed',
              'temporary',
              'visible',
            },
          },
          'survey': {
            'default': 'cave',
            'subtypes': <String>{'cave', 'surface'},
          },
          'wall': {
            'default': 'bedrock',
            'subtypes': <String>{
              'bedrock',
              'blocks',
              'clay',
              'debris',
              'flowstone',
              'ice',
              'invisible',
              'moonmilk',
              'overlying',
              'pebbles',
              'pit',
              'presumed',
              'sand',
              'underlying',
              'unsurveyed',
            },
          },
          'water-flow': {
            'default': 'permanent',
            'subtypes': <String>{'permanent', 'conjectural', 'intermittent'},
          },
        },
      };

  static List<THCommandOptionType> getSupportedOptionsForArea(
    THAreaType areaType,
  ) {
    return _supportedAreaOptions.containsKey(areaType)
        ? _supportAreaOptionsForAll + _supportedAreaOptions[areaType]!
        : _supportAreaOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForLineType(
    THLineType lineType,
  ) {
    return _supportedLineOptions.containsKey(lineType)
        ? _supportLineOptionsForAll + _supportedLineOptions[lineType]!
        : _supportLineOptionsForAll;
  }

  static List<THCommandOptionType> getSupportedOptionsForLineSegment(
    THLineType lineType,
  ) {
    return _supportLineSegmentsOptions.containsKey(lineType)
        ? _supportLineSegmentsOptionsForAll +
              _supportLineSegmentsOptions[lineType]!
        : _supportLineSegmentsOptionsForAll;
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
        return getSupportedOptionsForArea(element.areaType);
      case THLine _:
        return getSupportedOptionsForLineType(element.lineType);
      case THLineSegment _:
        return getSupportedOptionsForLineSegment(
          (element.parent() as THLine).lineType,
        );
      case THPoint _:
        return getSupportedOptionsForPointType(element.pointType);
      case THScrap _:
        return getSupportedOptionsForScrap();
    }

    return [];
  }

  static Iterable<THCommandOptionType> getSupportedOptionsForElements(
    Iterable<THHasOptionsMixin> elements,
  ) {
    if (elements.isEmpty) {
      return [];
    }

    Set<THCommandOptionType> commonOptions = getSupportedOptionsForElement(
      elements.first,
    ).toSet();

    for (THHasOptionsMixin element in elements.skip(1)) {
      commonOptions = commonOptions.intersection(
        getSupportedOptionsForElement(element).toSet(),
      );
    }

    return commonOptions;
  }

  static List<THCommandOptionType> getTHCommandOptionTypeOrderedList(
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

  static String? getStationNameFromScrapOption(THPoint point) {
    final String? scrapName = MPCommandOptionAux.getScrap(point);

    if (scrapName == null) {
      return null;
    }

    /// Assuming the scrap name is in the format "-xs-StationName" as
    /// TopoDroid uses on x-sections on stations.
    final RegExp stationRegExp = RegExp(r'-xs-(.+)$');
    final Match? match = stationRegExp.firstMatch(scrapName);

    if (match == null) {
      return null;
    }

    final String station = match.group(1)?.trim() ?? '';

    return station.isEmpty ? null : station;
  }

  static Map<String, THPoint> getStationPointsByStationName(
    TH2FileEditController th2FileEditController,
  ) {
    final Map<String, THPoint> stationPointsByStationName = {};
    final THScrap activeScrap = th2FileEditController.getActiveScrap();
    final Iterable<THElement> scrapChildren = activeScrap.getChildren(
      th2FileEditController.thFile,
    );

    for (final THElement scrapChild in scrapChildren) {
      if ((scrapChild is THPoint) &&
          (scrapChild.pointType == THPointType.station)) {
        final String? stationName = MPCommandOptionAux.getName(scrapChild);

        if (stationName != null) {
          stationPointsByStationName[stationName] = scrapChild;
        }
      }
    }

    return stationPointsByStationName;
  }

  static List<String> getStringOrderedList(Iterable<String> unorderedList) {
    final List<String> orderedList = List.from(unorderedList);

    orderedList.sort((a, b) {
      return MPTextToUser.compareStringsUsingLocale(a, b);
    });

    return orderedList;
  }

  static bool isSmooth(THElement element) {
    return (element is THHasOptionsMixin) &&
        element.hasOption(THCommandOptionType.smooth) &&
        (element.getOption(THCommandOptionType.smooth) as THSmoothCommandOption)
                .choice ==
            THOptionChoicesOnOffAutoType.on;
  }

  static bool isReversed(THElement element) {
    return (element is THHasOptionsMixin) &&
        element.hasOption(THCommandOptionType.reverse) &&
        (element.getOption(THCommandOptionType.reverse)
                    as THReverseCommandOption)
                .choice ==
            THOptionChoicesOnOffType.on;
  }

  static bool isTHVisible(THElement element) {
    return (element is THHasOptionsMixin) &&
        (!element.hasOption(THCommandOptionType.visibility) ||
            (element.getOption(THCommandOptionType.visibility)
                        as THVisibilityCommandOption)
                    .choice !=
                THOptionChoicesOnOffType.off);
  }

  static double? getLSize(THElement element) {
    return ((element is THHasOptionsMixin) &&
            element.hasOption(THCommandOptionType.lSize))
        ? (element.getOption(THCommandOptionType.lSize) as THLSizeCommandOption)
              .number
              .value
        : null;
  }

  static String? getName(THElement element) {
    return (element is THHasOptionsMixin) &&
            element.hasOption(THCommandOptionType.name)
        ? (element.getOption(THCommandOptionType.name) as THNameCommandOption)
              .reference
        : null;
  }

  static double? getOrientation(THElement element) {
    return ((element is THHasOptionsMixin) &&
            element.hasOption(THCommandOptionType.orientation))
        ? (element.getOption(THCommandOptionType.orientation)
                  as THOrientationCommandOption)
              .azimuth
              .value
        : null;
  }

  static bool hasID(THElement element) {
    return (element is THHasOptionsMixin) &&
        element.hasOption(THCommandOptionType.id);
  }

  static String? getID(THElement element) {
    return (element is THHasOptionsMixin) &&
            element.hasOption(THCommandOptionType.id)
        ? (element.getOption(THCommandOptionType.id) as THIDCommandOption).thID
        : null;
  }

  static String? getSubtype(THElement element) {
    return (element is THHasOptionsMixin) &&
            element.hasOption(THCommandOptionType.subtype)
        ? (element.getOption(THCommandOptionType.subtype)
                  as THSubtypeCommandOption)
              .subtype
        : null;
  }

  static String? getScrap(THElement element) {
    return (element is THHasOptionsMixin) &&
            element.hasOption(THCommandOptionType.scrap)
        ? (element.getOption(THCommandOptionType.scrap) as THScrapCommandOption)
              .reference
        : null;
  }

  static THProjectionModeType getScrapProjectionMode(THScrap scrap) {
    return scrap.hasOption(THCommandOptionType.projection)
        ? (scrap.getOption(THCommandOptionType.projection)
                  as THProjectionCommandOption)
              .mode
        : THProjectionModeType.plan;
  }

  static bool elementTypeSupportsOptionType(
    THElement element,
    THCommandOptionType optionType,
  ) {
    return element is THHasOptionsMixin
        ? getSupportedOptionsForElement(element).contains(optionType)
        : false;
  }

  static ({String type, String subtype}) getPLATypeSubtypeRecord(
    String typeSubtypeID,
  ) {
    final int separatorPosition = typeSubtypeID.indexOf(
      mpPLATypeSubtypeSeparator,
    );

    if (separatorPosition < 0) {
      return (type: typeSubtypeID.trim(), subtype: '');
    }

    final String type = typeSubtypeID.substring(0, separatorPosition).trim();
    final int subtypeStartPosition =
        separatorPosition + mpPLATypeSubtypeSeparator.length;
    final String subtype = typeSubtypeID.substring(subtypeStartPosition).trim();

    return (type: type, subtype: subtype);
  }

  static String getPLATypeAndSubtypeID({
    required String plaType,
    required String plaSubtype,
  }) {
    return '$plaType$mpPLATypeSubtypeSeparator$plaSubtype';
  }

  static bool isSamePLATypeSubtype({
    required THHasPLATypeMixin element,
    required String plaTypeSubtype,
  }) {
    final String elementTypeSubtypeID = element.typeSubtypeID;

    return elementTypeSubtypeID == plaTypeSubtype;
  }
}
