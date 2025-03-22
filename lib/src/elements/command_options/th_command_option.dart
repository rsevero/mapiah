library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_type_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
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
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_adjust_command_option.dart';
part 'th_align_command_option.dart';
part 'th_altitude_command_option.dart';
part 'th_altitude_value_command_option.dart';
part 'th_anchors_command_option.dart';
part 'th_arrow_position_command_option.dart';
part 'th_author_command_option.dart';
part 'th_border_command_option.dart';
part 'th_clip_command_option.dart';
part 'th_close_command_option.dart';
part 'th_context_command_option.dart';
part 'th_copyright_command_option.dart';
part 'th_cs_command_option.dart';
part 'th_date_value_command_option.dart';
part 'th_dimensions_value_command_option.dart';
part 'th_dist_command_option.dart';
part 'th_explored_command_option.dart';
part 'th_extend_command_option.dart';
part 'th_flip_command_option.dart';
part 'th_from_command_option.dart';
part 'th_has_altitude_mixin.dart';
part 'th_has_length_mixin.dart';
part 'th_head_command_option.dart';
part 'th_id_command_option.dart';
part 'th_line_direction_command_option.dart';
part 'th_line_gradient_command_option.dart';
part 'th_line_height_command_option.dart';
part 'th_line_point_direction_command_option.dart';
part 'th_line_point_gradient_command_option.dart';
part 'th_line_scale_command_option.dart';
part 'th_lsize_command_option.dart';
part 'th_mark_command_option.dart';
part 'th_multiple_choice_command_option.dart';
part 'th_name_command_option.dart';
part 'th_on_off_auto_command_option.dart';
part 'th_on_off_command_option.dart';
part 'th_orientation_command_option.dart';
part 'th_outline_command_option.dart';
part 'th_passage_height_value_command_option.dart';
part 'th_place_command_option.dart';
part 'th_point_height_value_command_option.dart';
part 'th_point_scale_command_option.dart';
part 'th_projection_command_option.dart';
part 'th_rebelays_command_option.dart';
part 'th_reverse_command_option.dart';
part 'th_scrap_command_option.dart';
part 'th_scrap_scale_command_option.dart';
part 'th_sketch_command_option.dart';
part 'th_smooth_command_option.dart';
part 'th_station_names_command_option.dart';
part 'th_stations_command_option.dart';
part 'th_subtype_command_option.dart';
part 'th_text_command_option.dart';
part 'th_title_command_option.dart';
part 'th_unrecognized_command_option.dart';
part 'th_visibility_command_option.dart';
part 'th_walls_command_option.dart';
part 'types/th_command_option_type.dart';
part 'types/th_option_choices_adjust_type.dart';
part 'types/th_option_choices_align_type.dart';
part 'types/th_option_choices_arrow_position_type.dart';
part 'types/th_option_choices_flip_type.dart';
part 'types/th_option_choices_line_gradient_type.dart';
part 'types/th_option_choices_line_point_direction_type.dart';
part 'types/th_option_choices_line_point_gradient_type.dart';
part 'types/th_option_choices_on_off_auto_type.dart';
part 'types/th_option_choices_on_off_type.dart';
part 'types/th_option_choices_outline_type.dart';
part 'types/th_option_choices_place_type.dart';

abstract class THCommandOption {
  final int parentMPID;
  final String originalLineInTH2File;

  THCommandOption.forCWJM({
    required this.parentMPID,
    required this.originalLineInTH2File,
  });

  THCommandOption({
    required THHasOptionsMixin optionParent,
    this.originalLineInTH2File = '',
  }) : parentMPID = optionParent.mpID {
    optionParent.addUpdateOption(this);
  }

  THCommandOptionType get type;

  String typeToFile() {
    return type.name;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'optionType': type.name,
      'parentMPID': parentMPID,
      'originalLineInTH2File': originalLineInTH2File,
    };
  }

  THCommandOption copyWith();

  static THCommandOption fromMap(Map<String, dynamic> map) {
    final THCommandOptionType type =
        THCommandOptionType.values.byName(map['optionType']);

    switch (type) {
      case THCommandOptionType.adjust:
        return THAdjustCommandOption.fromMap(map);
      case THCommandOptionType.align:
        return THAlignCommandOption.fromMap(map);
      case THCommandOptionType.altitude:
        return THAltitudeCommandOption.fromMap(map);
      case THCommandOptionType.altitudeValue:
        return THAltitudeValueCommandOption.fromMap(map);
      case THCommandOptionType.anchors:
        return THAnchorsCommandOption.fromMap(map);
      case THCommandOptionType.author:
        return THAuthorCommandOption.fromMap(map);
      case THCommandOptionType.border:
        return THBorderCommandOption.fromMap(map);
      case THCommandOptionType.clip:
        return THClipCommandOption.fromMap(map);
      case THCommandOptionType.close:
        return THCloseCommandOption.fromMap(map);
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
      case THCommandOptionType.flip:
        return THFlipCommandOption.fromMap(map);
      case THCommandOptionType.from:
        return THFromCommandOption.fromMap(map);
      case THCommandOptionType.head:
        return THHeadCommandOption.fromMap(map);
      case THCommandOptionType.id:
        return THIDCommandOption.fromMap(map);
      case THCommandOptionType.lineDirection:
        return THLineDirectionCommandOption.fromMap(map);
      case THCommandOptionType.lineGradient:
        return THLineGradientCommandOption.fromMap(map);
      case THCommandOptionType.lineHeight:
        return THLineHeightCommandOption.fromMap(map);
      case THCommandOptionType.linePointDirection:
        return THLinePointDirectionCommandOption.fromMap(map);
      case THCommandOptionType.linePointGradient:
        return THLinePointGradientCommandOption.fromMap(map);
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
      case THCommandOptionType.outline:
        return THOutlineCommandOption.fromMap(map);
      case THCommandOptionType.passageHeightValue:
        return THPassageHeightValueCommandOption.fromMap(map);
      case THCommandOptionType.place:
        return THPlaceCommandOption.fromMap(map);
      case THCommandOptionType.pointHeightValue:
        return THPointHeightValueCommandOption.fromMap(map);
      case THCommandOptionType.pointScale:
        return THPointScaleCommandOption.fromMap(map);
      case THCommandOptionType.projection:
        return THProjectionCommandOption.fromMap(map);
      case THCommandOptionType.rebelays:
        return THRebelaysCommandOption.fromMap(map);
      case THCommandOptionType.reverse:
        return THReverseCommandOption.fromMap(map);
      case THCommandOptionType.scrap:
        return THScrapCommandOption.fromMap(map);
      case THCommandOptionType.scrapScale:
        return THScrapScaleCommandOption.fromMap(map);
      case THCommandOptionType.sketch:
        return THSketchCommandOption.fromMap(map);
      case THCommandOptionType.smooth:
        return THSmoothCommandOption.fromMap(map);
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
      case THCommandOptionType.visibility:
        return THVisibilityCommandOption.fromMap(map);
      case THCommandOptionType.walls:
        return THWallsCommandOption.fromMap(map);
    }
  }

  factory THCommandOption.byType({
    required THCommandOptionType type,
    required THHasOptionsMixin optionParent,
    dynamic value,
  }) {
    switch (type) {
      case THCommandOptionType.adjust:
        return THAdjustCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.align:
        return THAlignCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.altitude:
      // return THAltitudeCommandOption(value);
      case THCommandOptionType.altitudeValue:
      // return THAltitudeValueCommandOption(value);
      case THCommandOptionType.anchors:
        return THAnchorsCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.author:
      // return THAuthorCommandOption(value);
      case THCommandOptionType.border:
        return THBorderCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.clip:
        return THClipCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.close:
        return THCloseCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.context:
      // return THContextCommandOption(value);
      case THCommandOptionType.copyright:
      // return THCopyrightCommandOption(value);
      case THCommandOptionType.cs:
      // return THCSCommandOption(value);
      case THCommandOptionType.dateValue:
      // return THDateValueCommandOption(value);
      case THCommandOptionType.dimensionsValue:
      // return THDimensionsValueCommandOption(value);
      case THCommandOptionType.dist:
      // return THDistCommandOption(value);
      case THCommandOptionType.explored:
      // return THExploredCommandOption(value);
      case THCommandOptionType.extend:
      // return THExtendCommandOption(value);
      case THCommandOptionType.flip:
        return THFlipCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.from:
      // return THFromCommandOption(value);
      case THCommandOptionType.head:
        return THHeadCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.id:
      // return THIDCommandOption(value);
      case THCommandOptionType.lineDirection:
        return THLineDirectionCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.lineGradient:
        return THLineGradientCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.lineHeight:
      // return THLineHeightCommandOption(value);
      case THCommandOptionType.linePointDirection:
        return THLinePointDirectionCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.linePointGradient:
        return THLinePointGradientCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.lineScale:
      // return THLineScaleCommandOption(value);
      case THCommandOptionType.lSize:
      // return THLSizeCommandOption(value);
      case THCommandOptionType.mark:
      // return THMarkCommandOption(value);
      case THCommandOptionType.name:
      // return THNameCommandOption(value);
      case THCommandOptionType.orientation:
      // return THOrientationCommandOption(value);
      case THCommandOptionType.outline:
        return THOutlineCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.passageHeightValue:
      // return THPassageHeightValueCommandOption(value);
      case THCommandOptionType.place:
        return THPlaceCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.pointHeightValue:
      // return THPointHeightValueCommandOption(value);
      case THCommandOptionType.pointScale:
      // return THPointScaleCommandOption(value);
      case THCommandOptionType.projection:
      // return THProjectionCommandOption(value);
      case THCommandOptionType.rebelays:
        return THRebelaysCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.reverse:
        return THReverseCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.scrap:
      // return THScrapCommandOption(value);
      case THCommandOptionType.scrapScale:
      // return THScrapScaleCommandOption(value);
      case THCommandOptionType.sketch:
      // return THSketchCommandOption(value);
      case THCommandOptionType.smooth:
        return THSmoothCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.stationNames:
      // return THStationNamesCommandOption(value);
      case THCommandOptionType.stations:
      // return THStationsCommandOption(value);
      case THCommandOptionType.subtype:
      // return THSubtypeCommandOption(value);
      case THCommandOptionType.text:
      // return THTextCommandOption(value);
      case THCommandOptionType.title:
      // return THTitleCommandOption(value);
      case THCommandOptionType.unrecognizedCommandOption:
      // return THUnrecognizedCommandOption(value);
      case THCommandOptionType.visibility:
        return THVisibilityCommandOption.fromString(
          optionParent: optionParent,
          choice: value,
        );
      case THCommandOptionType.walls:
      // return THWallsCommandOption(value);
    }

    throw THCustomException(
      'THCommandOption.byType: Unsupported option type: $type',
    );
  }

  @override
  bool operator ==(covariant THCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
        type,
        parentMPID,
        originalLineInTH2File,
      );

  THHasOptionsMixin optionParent(THFile thFile) =>
      thFile.elementByMPID(parentMPID) as THHasOptionsMixin;

  String specToFile();
}
