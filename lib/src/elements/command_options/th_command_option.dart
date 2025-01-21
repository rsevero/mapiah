import 'dart:convert';

import 'package:mapiah/src/auxiliary/th_serializeable.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
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

abstract class THCommandOption implements THSerializable {
  late final int parentMapiahID;
  late final String optionType;

  THCommandOption({
    required this.parentMapiahID,
    required this.optionType,
  });

  THCommandOption.addToOptionParent({
    required THHasOptions optionParent,
    required this.optionType,
  }) : parentMapiahID = optionParent.mapiahID {
    optionParent.addUpdateOption(this);
  }

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  static THCommandOption fromMap(Map<String, dynamic> map) {
    if ((map['optionType'] as String)
        .startsWith(thMultipleChoiceCommandOptionID)) {
      return THMultipleChoiceCommandOption.fromMap(map);
    }

    switch (map['optionType']) {
      case 'altitude':
        return THAltitudeCommandOption.fromMap(map);
      case 'altitudevalue':
        return THAltitudeValueCommandOption.fromMap(map);
      case 'author':
        return THAuthorCommandOption.fromMap(map);
      case 'clip':
        return THClipCommandOption.fromMap(map);
      case 'context':
        return THContextCommandOption.fromMap(map);
      case 'copyright':
        return THCopyrightCommandOption.fromMap(map);
      case 'cs':
        return THCSCommandOption.fromMap(map);
      case 'datevalue':
        return THDateValueCommandOption.fromMap(map);
      case 'dimensionsvalue':
        return THDimensionsValueCommandOption.fromMap(map);
      case 'dist':
        return THDistCommandOption.fromMap(map);
      case 'explored':
        return THExploredCommandOption.fromMap(map);
      case 'from':
        return THFromCommandOption.fromMap(map);
      case 'id':
        return THIDCommandOption.fromMap(map);
      case 'lineheight':
        return THLineHeightCommandOption.fromMap(map);
      case 'linescale':
        return THLineScaleCommandOption.fromMap(map);
      case 'lsize':
        return THLSizeCommandOption.fromMap(map);
      case 'mark':
        return THMarkCommandOption.fromMap(map);
      case 'name':
        return THNameCommandOption.fromMap(map);
      case 'orientation':
        return THOrientationCommandOption.fromMap(map);
      case 'passageheightvalue':
        return THPassageHeightValueCommandOption.fromMap(map);
      case 'pointheightvalue':
        return THPointHeightValueCommandOption.fromMap(map);
      case 'projection':
        return THProjectionCommandOption.fromMap(map);
      case 'scrap':
        return THScrapCommandOption.fromMap(map);
      case 'scrapscale':
        return THScrapScaleCommandOption.fromMap(map);
      case 'sketch':
        return THSketchCommandOption.fromMap(map);
      case 'stationnames':
        return THStationNamesCommandOption.fromMap(map);
      case 'stations':
        return THStationsCommandOption.fromMap(map);
      case 'subtype':
        return THSubtypeCommandOption.fromMap(map);
      case 'text':
        return THTextCommandOption.fromMap(map);
      case 'title':
        return THTitleCommandOption.fromMap(map);
      case 'unrecognized':
        return THUnrecognizedCommandOption.fromMap(map);
      default:
        throw Exception('Unknown optionType: ${map['optionType']}');
    }
  }

  THHasOptions optionParent(THFile thFile) =>
      thFile.elementByMapiahID(parentMapiahID) as THHasOptions;

  String specToFile();
}
