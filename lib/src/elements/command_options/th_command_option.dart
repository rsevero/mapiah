import 'dart:convert';

import 'package:mapiah/src/auxiliary/th_serializeable.dart';
import 'package:mapiah/src/elements/command_options/th_altitude_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_altitude_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_author_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_clip_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_context_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_copyright_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_cs_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_date_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_dimensions_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_dist_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_explored_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_from_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_id_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_line_height_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_line_scale_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_lsize_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_mark_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_name_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_orientation_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_passage_height_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_point_height_value_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_projection_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_scrap_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_scrap_scale_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_sketch_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_station_names_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_stations_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_subtype_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_text_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_title_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

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

abstract class THCommandOption implements THSerializable {
  late final int parentMapiahID;

  THCommandOption({
    required this.parentMapiahID,
  });

  THCommandOption.addToOptionParent({
    required THHasOptions optionParent,
  }) : parentMapiahID = optionParent.mapiahID {
    optionParent.addUpdateOption(this);
  }

  THCommandOptionType get optionType;

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  static THCommandOption fromMap(Map<String, dynamic> map) {
    if (map['optionType'] == THCommandOptionType.multipleChoice) {
      return THMultipleChoiceCommandOption.fromMap(map);
    }

    switch (map['optionType'] as THCommandOptionType) {
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
      case THCommandOptionType.name:
        return THNameCommandOption.fromMap(map);
      case THCommandOptionType.orientation:
        return THOrientationCommandOption.fromMap(map);
      case THCommandOptionType.passageHeightValue:
        return THPassageHeightValueCommandOption.fromMap(map);
      case THCommandOptionType.pointHeightValue:
        return THPointHeightValueCommandOption.fromMap(map);
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
      default:
        throw Exception('Unknown optionType: ${map['optionType']}');
    }
  }

  THHasOptions optionParent(THFile thFile) =>
      thFile.elementByMapiahID(parentMapiahID) as THHasOptions;

  String specToFile();
}
