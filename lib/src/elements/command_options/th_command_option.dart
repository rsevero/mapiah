library;

import 'dart:collection';
import 'dart:convert';

import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/elements/parts/th_angle_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/parts/th_multiple_choice_part.dart';
import 'package:mapiah/src/elements/parts/th_person_part.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/exceptions/th_convert_from_string_exception.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_altitude_command_option.dart';
part 'th_altitude_value_command_option.dart';
part 'th_author_command_option.dart';
part 'th_clip_command_option.dart';
part 'th_context_command_option.dart';
part 'th_copyright_command_option.dart';
part 'th_cs_command_option.dart';
part 'th_date_value_command_option.dart';
part 'th_dimensions_value_command_option.dart';
part 'th_dist_command_option.dart';
part 'th_explored_command_option.dart';
part 'th_extend_command_option.dart';
part 'th_from_command_option.dart';
part 'th_has_altitude_mixin.dart';
part 'th_has_length_mixin.dart';
part 'th_id_command_option.dart';
part 'th_line_height_command_option.dart';
part 'th_line_scale_command_option.dart';
part 'th_lsize_command_option.dart';
part 'th_mark_command_option.dart';
part 'th_multiple_choice_command_option.dart';
part 'th_name_command_option.dart';
part 'th_orientation_command_option.dart';
part 'th_passage_height_value_command_option.dart';
part 'th_point_height_value_command_option.dart';
part 'th_point_scale_command_option.dart';
part 'th_projection_command_option.dart';
part 'th_scrap_command_option.dart';
part 'th_scrap_scale_command_option.dart';
part 'th_sketch_command_option.dart';
part 'th_station_names_command_option.dart';
part 'th_stations_command_option.dart';
part 'th_subtype_command_option.dart';
part 'th_text_command_option.dart';
part 'th_title_command_option.dart';
part 'th_unrecognized_command_option.dart';

enum THCommandOptionType {
  altitude,
  altitudeValue,
  author,
  clip,
  context,
  copyright,
  cs,
  dateValue,
  dimensionsValue,
  dist,
  explored,
  extend,
  from,
  id,
  lineHeight,
  lineScale,
  lSize,
  mark,
  multipleChoice,
  name,
  orientation,
  passageHeightValue,
  pointHeightValue,
  pointScale,
  projection,
  scrap,
  scrapScale,
  sketch,
  stationNames,
  stations,
  subtype,
  text,
  title,
  unrecognizedCommandOption,
}

abstract class THCommandOption {
  late final int parentMapiahID;
  final String originalLineInTH2File;

  THCommandOption.forCWJM({
    required this.parentMapiahID,
    required this.originalLineInTH2File,
  });

  THCommandOption({
    required THHasOptionsMixin optionParent,
    this.originalLineInTH2File = '',
  }) : parentMapiahID = optionParent.mapiahID {
    optionParent.addUpdateOption(this);
  }

  THCommandOptionType get optionType;

  String typeToFile() {
    return optionType.name;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'originalLineInTH2File': originalLineInTH2File,
    };
  }

  THCommandOption copyWith();

  static THCommandOption fromMap(Map<String, dynamic> map) {
    final THCommandOptionType type =
        THCommandOptionType.values.byName(map['optionType']);

    switch (type) {
      case THCommandOptionType.altitude:
        return THAltitudeCommandOption.fromMap(map);
      case THCommandOptionType.altitudeValue:
        return THAltitudeValueCommandOption.fromMap(map);
      case THCommandOptionType.author:
        return THAuthorCommandOption.fromMap(map);
      case THCommandOptionType.clip:
        return THClipCommandOption.fromMap(map);
      case THCommandOptionType.context:
        return THContextCommandOption.fromMap(map);
      case THCommandOptionType.copyright:
        return THCopyrightCommandOption.fromMap(map);
      case THCommandOptionType.cs:
        return THCSCommandOption.fromMap(map);
      case THCommandOptionType.dateValue:
        return THDateValueCommandOption.fromMap(map);
      case THCommandOptionType.dimensionsValue:
        return THDimensionsValueCommandOption.fromMap(map);
      case THCommandOptionType.dist:
        return THDistCommandOption.fromMap(map);
      case THCommandOptionType.explored:
        return THExploredCommandOption.fromMap(map);
      case THCommandOptionType.extend:
        return THExtendCommandOption.fromMap(map);
      case THCommandOptionType.from:
        return THFromCommandOption.fromMap(map);
      case THCommandOptionType.id:
        return THIDCommandOption.fromMap(map);
      case THCommandOptionType.lineHeight:
        return THLineHeightCommandOption.fromMap(map);
      case THCommandOptionType.lineScale:
        return THLineScaleCommandOption.fromMap(map);
      case THCommandOptionType.lSize:
        return THLSizeCommandOption.fromMap(map);
      case THCommandOptionType.mark:
        return THMarkCommandOption.fromMap(map);
      case THCommandOptionType.multipleChoice:
        return THMultipleChoiceCommandOption.fromMap(map);
      case THCommandOptionType.name:
        return THNameCommandOption.fromMap(map);
      case THCommandOptionType.orientation:
        return THOrientationCommandOption.fromMap(map);
      case THCommandOptionType.passageHeightValue:
        return THPassageHeightValueCommandOption.fromMap(map);
      case THCommandOptionType.pointHeightValue:
        return THPointHeightValueCommandOption.fromMap(map);
      case THCommandOptionType.pointScale:
        return THPointScaleCommandOption.fromMap(map);
      case THCommandOptionType.projection:
        return THProjectionCommandOption.fromMap(map);
      case THCommandOptionType.scrap:
        return THScrapCommandOption.fromMap(map);
      case THCommandOptionType.scrapScale:
        return THScrapScaleCommandOption.fromMap(map);
      case THCommandOptionType.sketch:
        return THSketchCommandOption.fromMap(map);
      case THCommandOptionType.stationNames:
        return THStationNamesCommandOption.fromMap(map);
      case THCommandOptionType.stations:
        return THStationsCommandOption.fromMap(map);
      case THCommandOptionType.subtype:
        return THSubtypeCommandOption.fromMap(map);
      case THCommandOptionType.text:
        return THTextCommandOption.fromMap(map);
      case THCommandOptionType.title:
        return THTitleCommandOption.fromMap(map);
      case THCommandOptionType.unrecognizedCommandOption:
        return THUnrecognizedCommandOption.fromMap(map);
    }
  }

  THHasOptionsMixin optionParent(THFile thFile) =>
      thFile.elementByMapiahID(parentMapiahID) as THHasOptionsMixin;

  String specToFile();
}
