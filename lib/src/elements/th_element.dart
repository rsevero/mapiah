library;

import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box.dart';
import 'package:mapiah/src/elements/interfaces/th_point_interface.dart';
import 'package:mapiah/src/elements/mixins/th_calculate_children_bounding_box_mixin.dart';
import 'package:mapiah/src/elements/mixins/th_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_id.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

part 'th_area_border_thid.dart';
part 'th_area.dart';
part 'th_bezier_curve_line_segment.dart';
part 'th_comment.dart';
part 'th_empty_line.dart';
part 'th_encoding.dart';
part 'th_endarea.dart';
part 'th_endcomment.dart';
part 'th_endline.dart';
part 'th_endscrap.dart';
part 'mixins/th_has_options_mixin.dart';
part 'mixins/th_has_platype_mixin.dart';
part 'th_line_segment.dart';
part 'th_line.dart';
part 'th_multiline_comment_content.dart';
part 'th_multilinecomment.dart';
part 'th_point.dart';
part 'th_scrap.dart';
part 'th_straight_line_segment.dart';
part 'th_unrecognized_command.dart';
part 'th_xtherion_config.dart';

enum THElementType {
  areaBorderTHID,
  area,
  bezierCurveLineSegment,
  comment,
  emptyLine,
  encoding,
  endarea,
  endcomment,
  endline,
  endscrap,
  line,
  lineSegment,
  multilineCommentContent,
  multilineComment,
  point,
  scrap,
  straightLineSegment,
  unrecognizedCommand,
  xTherionConfig,
}

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  final int _mpID;
  final int parentMPID;
  String? sameLineComment;
  final String originalLineInTH2File;

  THElement.forCWJM({
    required int mpID,
    required this.parentMPID,
    this.sameLineComment,
    required this.originalLineInTH2File,
  }) : _mpID = mpID;

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement.addToParent({
    required this.parentMPID,
    this.sameLineComment,
    this.originalLineInTH2File = '',
  }) : _mpID = mpLocator.mpGeneralController.nextMPIDForElements();

  THIsParentMixin parent(THFile thFile) {
    return (parentMPID < 0)
        ? thFile
        : thFile.elementByMPID(parentMPID) as THIsParentMixin;
  }

  THElementType get elementType;

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'elementType': elementType.name,
      'mpID': mpID,
      'parentMPID': parentMPID,
      'sameLineComment': sameLineComment,
      'originalLineInTH2File': originalLineInTH2File,
    };
  }

  @override
  bool operator ==(covariant THElement other) {
    if (identical(this, other)) return true;

    return other.mpID == mpID &&
        other.parentMPID == parentMPID &&
        other.sameLineComment == sameLineComment &&
        other.originalLineInTH2File == originalLineInTH2File;
  }

  @override
  int get hashCode => Object.hash(
        mpID,
        parentMPID,
        sameLineComment,
        originalLineInTH2File,
      );

  THElement copyWith();

  static THElement fromMap(Map<String, dynamic> map) {
    final THElementType type = THElementType.values.byName(map['elementType']);

    switch (type) {
      case THElementType.areaBorderTHID:
        return THAreaBorderTHID.fromMap(map);
      case THElementType.area:
        return THArea.fromMap(map);
      case THElementType.bezierCurveLineSegment:
        return THBezierCurveLineSegment.fromMap(map);
      case THElementType.comment:
        return THComment.fromMap(map);
      case THElementType.emptyLine:
        return THEmptyLine.fromMap(map);
      case THElementType.encoding:
        return THEncoding.fromMap(map);
      case THElementType.endarea:
        return THEndarea.fromMap(map);
      case THElementType.endcomment:
        return THEndcomment.fromMap(map);
      case THElementType.endline:
        return THEndline.fromMap(map);
      case THElementType.endscrap:
        return THEndscrap.fromMap(map);
      case THElementType.line:
        return THLine.fromMap(map);
      case THElementType.lineSegment:
        throw THCustomException(
            'THElementType.lineSegment should not by instantiated by THElementfromMap().');
      case THElementType.multilineCommentContent:
        return THMultilineCommentContent.fromMap(map);
      case THElementType.multilineComment:
        return THMultilineCommentContent.fromMap(map);
      case THElementType.point:
        return THPoint.fromMap(map);
      case THElementType.scrap:
        return THScrap.fromMap(map);
      case THElementType.straightLineSegment:
        return THStraightLineSegment.fromMap(map);
      case THElementType.unrecognizedCommand:
        return THUnrecognizedCommand.fromMap(map);
      case THElementType.xTherionConfig:
        return THXTherionConfig.fromMap(map);
    }
  }

  int get mpID => _mpID;

  bool isSameClass(Object object);
}
